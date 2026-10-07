;; TX 01/08 -- SWPI, AQP-ANK          (~265,816 B, ~115k gas)
;;
;; 2.16.1: `SWPI|XE>ISSUE-WRITE` and `ANK|XE>SWEEP-REVOKE` were evented while the C_ entering each
;; is evented too, so both operations announced themselves twice.
;;
;; They lead the round because both are dot-callees further down: AQP-ANK is dot-called by RPS,
;; AQP-VCT and AQP-BOOT, all of which ship later.
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

;; ---- source: 1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact (module only -- its interface is already live)
(module SWPI GOV
    @doc "SWPI (SwapperIssueV4) handles SWP pool issuance and the swap-math/pricing engine. \
        \ It computes direct and inverse swaps with fees across Stable/Weighted/standard \
        \ pool types, runs the Hopper multi-hop router (best-of-candidate selection), and \
        \ prices tokens/pools in WSTOA. C_Issue/XE_IssueWrite mint the LP token and register \
        \ the pool (folding in XE_AddLPTracker so every issuance path registers)."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SwapperIssueV4)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SWPI                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SWPI_ADMIN)))
    (defcap GOV|SWPI_ADMIN ()                           (enforce-guard GOV|MD_SWPI))
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
    (defcap P|SWPI|CALLER ()
        true
    )
    (defcap P|SWPI|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SWPI|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT ()
        (compose-capability (P|SWPI|REMOTE-GOV))
        (compose-capability (P|SWPI|CALLER))
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
        (with-capability (GOV|SWPI_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SWPI_ADMIN)
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
        (with-capability (GOV|SWPI_ADMIN)
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
        (with-capability (GOV|SWPI_ADMIN)
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
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (ref-P|SWPT:module{OuronetPolicyV2} SWPT)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|SWPI|CALLER)))
            )
            (ref-P|SWP::P|A_Add
                "SWPI|RemoteSwpGov"
                (create-capability-guard (P|SWPI|REMOTE-GOV))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
            (ref-P|SWPT::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    ;;
    (defconst EMPTY_HOPPER
        [
            {
                "nodes" : [],
                "edges" : [],
                "output-values" : []
            }
        ]
    )
    (defconst BAR                                       (CT_Bar))
    ;;#36M/M5 fix: named, single source of truth for the genesis LP mint amount —
    ;;was a bare 10000000.0 literal duplicated independently in both C_Issue and
    ;;MTX|C_Issue's own write sequences; now lives once, inside the shared
    ;;XE_IssueWrite both call.
    (defconst GENESIS_LP_SUPPLY                         10000000.0)
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;#36M/M5 fix: local cap for XE_IssueWrite (forward-module entrypoint) — no
    ;;checks of its own beyond P|UEV_IMC in the defun itself. Real validation
    ;;(UEV_Issue) already ran in whichever caller's own defcap got here first
    ;;(SWPI|C>ISSUE for C_Issue, or MTX-SWP's own Step 1) — this function only
    ;;performs the already-validated writes, matching the XE_* contract of no
    ;;enforce/UEV_* beyond P|UEV_IMC.
    (defcap SWPI|XE>ISSUE-WRITE (account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap SWPI|C>ISSUE (account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @event
        ;;CONDITIONAL authorisation, hoisted 2026-09-14: only a PRIMORDIAL issuance (p) needs the
        ;;admin key, so this cannot become an unconditional gate -- but when it does apply it must
        ;;apply BEFORE UEV_Issue, or a stranger's refusal comes from a shape rule and the admin
        ;;check is never the thing that stopped them. The branch is preserved exactly.
        (if p
            (compose-capability (GOV|SWPI_ADMIN))
            true
        )
        (UEV_Issue account pool-tokens fee-lp weights amp p)
        (compose-capability (P|DT))
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
    (defun UDC_DirectRawSwapInput:object{UtilitySwpV2.DirectRawSwapInput}
        (
            dsid:object{UtilitySwpV2.DirectSwapInputData}
            A:decimal X:[decimal] input-positions:[integer] output-position:integer weights:[decimal]
        )
        (let
            (
                ;;Unwrap Object Data
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-U|SWP::UDC_DirectRawSwapInput
                A
                X
                input-amounts 
                input-positions
                output-position
                (ref-DPTF::UR_Decimals output-id)
                weights
            )
        )
    )
    (defun UDC_InverseRawSwapInput:object{UtilitySwpV2.InverseRawSwapInput}
        (
            rsid:object{UtilitySwpV2.ReverseSwapInputData}
            A:decimal X:[decimal] output-position:integer input-position:integer weights:[decimal]
        )
        (let
            (
                ;;Unwrap Object Data
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-U|SWP::UDC_InverseRawSwapInput
                A
                X
                output-amount
                output-position
                input-position
                (ref-DPTF::UR_Decimals input-id)
                weights
            )
        )
    )
    (defun UDC_Hopper:object{SwapperIssueV4.Hopper} (a:[string] b:[string] c:[decimal])
        {"nodes"            : a
        ,"edges"            : b
        ,"output-values"    : c}
    )
    ;;{5.2}  Compute [UC]
    (defun UCv_DeviationInValueShares:decimal (pool-reserves:[decimal] asymmetric-liq:[decimal] w:[decimal])
        @doc "Maximum Pool Deviation is (n-1)/n, and max allowed deviation for asymmetric liq is 40% of this value"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (l1:integer (length pool-reserves))
                (l2:integer (length asymmetric-liq))
                (l3:integer (length w))
                (iz-asymmetric:bool (contains 0.0 asymmetric-liq))
            )
            (ref-U|INT::UEV_UniformList [l1 l2 l3])
            (enforce iz-asymmetric "Invalid Values to Compute Deviation In Value Shares")
            (let
                (
                    (ref-U|VST:module{UtilityVstV2} U|VST)
                    (sw:decimal (fold (+) 0.0 w))
                    (iz-weigthed:bool (if (= sw 1.0) true false))
                    ;;
                    (initial-shares:[decimal] (UC_PoolShares pool-reserves w))
                    (asymmetric-shares:[decimal] (zip (*) initial-shares asymmetric-liq))
                    (new-total-shares:decimal (+ 5040000.0 (fold (+) 0.0 asymmetric-shares)))
                    (new-supply:[decimal] (zip (+) pool-reserves asymmetric-liq))
                    ;;
                    (aw:[decimal] (if iz-weigthed w (ref-U|VST::UCv_SplitBalanceForVesting 24 1.0 l1)))
                    (deviated-shares:[decimal] (UC_DeviatedShares new-supply initial-shares new-total-shares))
                    (diff-with-deviated-shares:[decimal] (zip (-) aw deviated-shares))
                    (abs-dwds:[decimal]
                        (fold
                            (lambda
                                (acc:[decimal] idx:integer)
                                (ref-U|LST::UC_AppL acc (abs (at idx diff-with-deviated-shares )))
                            )
                            []
                            (enumerate 0 (- l1 1))
                        )
                    )
                    ;;Total Deviation must be divided by 2, to account for gain and losses in share variation
                    (total-deviation:decimal (floor (/ (fold (+) 0.0 abs-dwds) 2.0) 24))
                )
                total-deviation
            )
        )
    )
    (defun UC_DeviatedShares:[decimal] (pool-reserves:[decimal] pool-shares:[decimal] new-total-shares:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (ref-U|LST::UC_AppL acc
                        (floor (/ (* (at idx pool-reserves)(at idx pool-shares)) new-total-shares) 24)
                    )
                )
                []
                (enumerate 0 (- (length pool-reserves) 1))
            )
        )
    )
    (defun UC_PoolShares:[decimal] (pool-reserves:[decimal] w:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (size:decimal (dec (length pool-reserves)))
                (sw:decimal (fold (+) 0.0 w))
                (iz-weigthed:bool (if (= sw 1.0) true false))
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (let
                        (
                            (amount:decimal (at idx pool-reserves))
                            (position-share:decimal
                                (if iz-weigthed
                                    (* 5040000.0 (at idx w))
                                    (/ 5040000.0 size)
                                )
                            )
                            (amount-share:decimal
                                (floor (/ position-share amount) 24)
                            )
                        )
                        (ref-U|LST::UC_AppL acc amount-share)
                    )
                )
                []
                (enumerate 0 (- (length w) 1))
            )
        )
    )
    (defun UC_VirtualSwap:object{UtilitySwpV2.VirtualSwapEngine} 
        (vse:object{UtilitySwpV2.VirtualSwapEngine} dsid:object{UtilitySwpV2.DirectSwapInputData})
        @doc "Executes a Virtual Swap, saving data in the Output Object"
        (let
            (
                ;;Unwrap Input Objects
                (v-tokens:[string] (at "v-tokens" vse))
                (v-prec:[integer] (at "v-prec" vse))
                (account:string (at "account" vse))
                (account-supply:[decimal] (at "account-supply" vse))
                (swpair:string (at "swpair" vse))
                (X:[decimal] (at "X" vse))
                (A:decimal (at "A" vse))
                (W:[decimal] (at "W" vse))
                (F:object{UtilitySwpV2.SwapFeez} (at "F" vse))
                (fuel:[decimal] (at "fuel" vse))
                (special:[decimal] (at "special" vse))
                (boost:[decimal] (at "boost" vse))
                (swaps:[object{UtilitySwpV2.DirectSwapInputData}] (at "swaps" vse))
                ;;
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (input-positions:[integer] (UCv_PoolTokenPositions swpair input-ids))
                (output-position:integer (at 0 (UCv_PoolTokenPositions swpair [output-id])))
                ;;
                (swap-result:object{UtilitySwpV2.DirectTaxedSwapOutput}
                    (UC_BareboneSwapWithFeez account pool-type dsid F A X v-prec input-positions output-position W)
                )
                (tsoa:decimal (fold (+) 0.0 [(at "o-id-special" swap-result) (at "o-id-liquid" swap-result) (at "o-id-netto" swap-result)]))
                (tsoa-filled:[decimal] (URC_IndirectRefillAmounts X [output-position] [tsoa]))
                (remainder-filled:[decimal] (URC_IndirectRefillAmounts X [output-position] [(at "o-id-netto" swap-result)]))
                (input-amounts-filled:[decimal] (URC_IndirectRefillAmounts X input-positions input-amounts))
            )
            (ref-U|SWP::UDC_VirtualSwapEngine
                v-tokens v-prec account
                (zip (+) remainder-filled (zip (-) account-supply input-amounts-filled)) 
                swpair 
                (zip (-) (zip (+) X input-amounts-filled) remainder-filled)
                A W F
                (zip (+) fuel (at "lp-fuel" swap-result))
                (ref-U|LST::UC_ReplaceAt special output-position (+ (at output-position special) (at "o-id-special" swap-result)))
                (ref-U|LST::UC_ReplaceAt boost output-position (+ (at output-position boost) (at "o-id-liquid" swap-result)))
                (ref-U|LST::UC_AppL swaps dsid)
            )
        )
    )
    (defun UC_BareboneSwapWithFeez:object{UtilitySwpV2.DirectTaxedSwapOutput}
        (
            account:string pool-type:string 
            dsid:object{UtilitySwpV2.DirectSwapInputData} fees:object{UtilitySwpV2.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] input-positions:[integer] output-position:integer weights:[decimal]
        )
        @doc "Performs a Direct Swap with Fees Computation, outputing results in an object{UtilitySwpV2.DirectTaxedSwapOutput} \
            \ Given proper inputs, can be used for an actual Swap Functions, to save redundant code."
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                ;;
                ;;Get Working fees
                (reduced-fees:object{UtilitySwpV2.SwapFeez} (URC_EliteFeeReduction account fees))
                (f1:decimal (at "lp" reduced-fees))
                (f2:decimal (at "special" reduced-fees))
                (f3:decimal (at "boost" reduced-fees))
                (o-prec:integer (at output-position X-prec))
                ;;
                ;;From the input amounts, compute FeeSharesExcludingLpFee <fselp>
                (fselp:decimal (- 1000.0 f1))
                (input-amounts-for-swap:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (floor
                                    (* (at idx input-amounts) (/ fselp 1000.0))
                                    (at (at idx input-positions) X-prec)
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length input-amounts) 1))
                    )
                )
                (dsid-for-swap:object{UtilitySwpV2.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts-for-swap output-id)
                )
                (drsi:object{UtilitySwpV2.DirectRawSwapInput}
                    (UDC_DirectRawSwapInput dsid-for-swap A X input-positions output-position weights)
                )
                (input-amounts-for-lp:[decimal] (zip (-) input-amounts input-amounts-for-swap))
                (input-amounts-for-lp-filled:[decimal] (URC_IndirectRefillAmounts X input-positions input-amounts-for-lp))
                ;;
                ;;Total-Swap-Output-Amount <tsoa> is computed without them, then splited into 3 parts: 
                ;;special, boost, remainder
                (tsoa:decimal (UCv_BareboneSwap pool-type drsi))
                (special:decimal (floor (* (/ f2 fselp) tsoa) o-prec))
                (boost:decimal (floor (* (/ f3 fselp) tsoa) o-prec))
                (remainder:decimal (- tsoa (+ special boost)))
                (output:object{UtilitySwpV2.DirectTaxedSwapOutput}
                    (ref-U|SWP::UDC_DirectTaxedSwapOutput
                        input-amounts-for-lp-filled
                        output-id
                        special
                        boost
                        remainder
                    )
                )
            )
            output
        )
    )
    (defun UC_InverseBareboneSwapWithFeez:object{UtilitySwpV2.InverseTaxedSwapOutput}
        
        (
            account:string pool-type:string 
            rsid:object{UtilitySwpV2.ReverseSwapInputData} fees:object{UtilitySwpV2.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] output-position:integer input-position:integer weights:[decimal]
        )
        @doc "Performs a Reverse Swap with Fees Computation, outputing results in an object{UtilitySwpV2.InverseTaxedSwapOutput} \
            \ Use Case is displaying Input Amounts for a Swap when the desired Output Amount of a Token is entered first. \
            \ However not only the input required can be displayed, but also the susequent fees that would be incurred"
        (let
            (
                ;;Unwrap Object Data
                (output-id:string (at "output-id" rsid))
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                ;;
                ;;Get Working fees
                (reduced-fees:object{UtilitySwpV2.SwapFeez} (URC_EliteFeeReduction account fees))
                (f1:decimal (at "lp" reduced-fees))
                (f2:decimal (at "special" reduced-fees))
                (f3:decimal (at "boost" reduced-fees))
                (o-prec:integer (at output-position X-prec))
                (i-prec:integer (at input-position X-prec))
                ;;
                ;;Star by computing the Output fee shares <ofs>
                (ofs:decimal (- 1000.0 (fold (+) 0.0 [f1 f2 f3])))
                ;;Compute Output-Amount per fee Share <oapfs>
                (oapfs:decimal (floor (/ output-amount ofs) o-prec))
                (boost:decimal (floor (* f3 oapfs) o-prec))
                (special:decimal (floor (* f2 oapfs) o-prec))
                ;;Then Compute Total-Swap-Output-Amount <tsoa>
                (tsoa:decimal (fold (+) 0.0 [output-amount boost special]))
                ;:Remake a new rsid
                (new-rsid:object{UtilitySwpV2.ReverseSwapInputData} 
                    (ref-U|SWP::UDC_ReverseSwapInputData output-id tsoa input-id)
                )
                (irsi:object{UtilitySwpV2.InverseRawSwapInput}
                    (UDC_InverseRawSwapInput new-rsid A X output-position input-position weights)
                )
                ;;Now Compute the Input Amount needed to get the <tsoa>, the Partial-Input-Amount <pia>
                ;;<pia> is part of the TotalInputAmount, that would be used for a direct swap, after LP fees have been retained
                (pia:decimal (UC_BareboneInverseSwap pool-type irsi))
                ;;Now Compute the Total-Input-Amouant <tia>
                (tia:decimal (floor (/ (* 1000.0 pia) (- 1000.0 f1)) i-prec))
                (output:object{UtilitySwpV2.InverseTaxedSwapOutput}
                    (ref-U|SWP::UDC_InverseTaxedSwapOutput
                        boost
                        special
                        (URC_IndirectRefillAmounts X [input-position] [(- tia pia)])
                        input-id
                        tia
                    )
                )
            )
            output
        )
    )
    ;;
    (defun UCv_BareboneSwap:decimal
        (pool-type:string drsi:object{UtilitySwpV2.DirectRawSwapInput})
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (l1:integer (length (at "input-amounts" drsi)))
            )
            (if (= pool-type "S")
                (enforce (= l1 1) "Only a single Input can be used in Stable Swap")
                true
            )
            (cond
                ((= pool-type "S") (ref-U|SWP::UC_ComputeY drsi))
                ((= pool-type "W") (ref-U|SWP::UC_ComputeWP drsi))
                ((= pool-type "P") (ref-U|SWP::UC_ComputeEP drsi))
                -1.0
            )
        )
    )
    (defun UC_BareboneInverseSwap:decimal 
        (pool-type:string irsi:object{UtilitySwpV2.InverseRawSwapInput})
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (cond
                ((= pool-type "S") (ref-U|SWP::UCv_ComputeInverseY irsi))
                ((= pool-type "W") (ref-U|SWP::UC_ComputeInverseWP irsi))
                ((= pool-type "P") (ref-U|SWP::UC_ComputeInverseEP irsi))
                -1.0
            )
        )
    )
    (defun UCv_PoolTokenPositions:[integer] (swpair:string input-ids:[string])
        @doc "Same result as <URCv_PoolTokenPositions> but being done without reading <swpair> data \
        \ Result is simply computed, through the <swpair> string"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (are-on-pool:bool (ref-SWP::UEV_CheckAgainst input-ids pool-tokens))
            )
            (enforce are-on-pool (format "Input Token IDs {} arent on pool {}" [input-ids swpair]))
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (ref-SWP::UCv_PoolTokenPosition swpair (at idx input-ids))
                    )
                )
                []
                (enumerate 0 (- (length input-ids) 1))
            )
        )
    )
    (defun UC_BestHopper:object{SwapperIssueV4.Hopper} (candidates:[object{SwapperIssueV4.Hopper}])
        @doc "Picks the candidate Hopper with the highest final output value. \
            \ <candidates> must be non-empty (caller's responsibility — <URCx_Hopper> \
            \ only calls this once it has confirmed at least one route was found)."
        (if (<= (length candidates) 1)
            (at 0 candidates)
            (fold
                (lambda
                    (best:object{SwapperIssueV4.Hopper} idx:integer)
                    (let
                        (
                            (candidate:object{SwapperIssueV4.Hopper} (at idx candidates))
                            (best-final:decimal (at 0 (take -1 (at "output-values" best))))
                            (candidate-final:decimal (at 0 (take -1 (at "output-values" candidate))))
                        )
                        (if (> candidate-final best-final) candidate best)
                    )
                )
                (at 0 candidates)
                (enumerate 1 (- (length candidates) 1))
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCx_Hopper:object{SwapperIssueV4.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal swpairs:[string])
        @doc "Shared Hopper-computation core for <URC_Hopper>/<URC_HopperActive> — \
            \ identical in every respect except which <swpairs> universe routing \
            \ is allowed to consider. Internal only, not on <SwapperIssueV4>. \
            \ #65bL Phase 5 fix: was best-of-3 via <SWPT::URC_ComputeAlternateRoutes> \
            \ (#34M/M2's original fix). Measured directly against this codebase's \
            \ real, organically-grown ~102-pool topology (not a hand-engineered one) \
            \ across 7 representative pairs spanning 1-8 hops: best-of-3 found a \
            \ better route than the single first-found one in ZERO of them — 0.0% \
            \ difference every time. #34M/M2's own original proof that best-of-3 \
            \ matters used a deliberately hand-built diamond topology (issuance order \
            \ controlled specifically to make BFS's first-found route the weak one) \
            \ to demonstrate the FAILURE MODE is real — it never claimed the failure \
            \ mode manifests naturally at scale, and per this measurement, it \
            \ doesn't, here: with dozens of parallel pools and organic swap activity \
            \ pushing chronically-unbalanced pools back toward parity, first-found \
            \ and best-of-3 converge. Switched to a single <SWPT::URC_ComputeGraphPath> \
            \ call — the greedy, single-shot search <URC_HopperActiveShortest> \
            \ already uses elsewhere. <SWPT::URC_ComputeAlternateRoutes> itself is \
            \ NOT deleted (still correct, still tested, `SWP|TX 032c`-`032g`'s own \
            \ adversarial proof of the original failure mode stays as regression \
            \ coverage) — just no longer the default live-routing path. \
            \ CAVEAT, worth stating plainly: URCx_HopperForNodes's own per-hop \
            \ <URC_BestEdgeFiltered> selection is a GREEDY choice — picking the best \
            \ available edge at each individual hop does not mathematically guarantee \
            \ the overall path is the highest-value one achievable end to end (a \
            \ locally-optimal choice at every step is not the same as a globally- \
            \ optimal path). This was already true before this fix, at every K \
            \ (including best-of-3) — this fix does not introduce that limitation, it \
            \ was always structurally present; it only removes the (measured, at this \
            \ topology, not currently earning its cost) 2-candidate cross-route \
            \ comparison layered on top of it. \
            \ #65bL Phase 1 fix: checks SWPT|PathCache (via URC_ReadPathCacheFresh) \
            \ first — on a fresh hit, skips the live BFS search entirely and \
            \ uses the cached node-path as the sole candidate. Safe because the real \
            \ per-hop edge is always re-derived live downstream in \
            \ URCx_HopperForNodes regardless of where the node-path came from — a \
            \ cache hit only changes WHICH nodes get tried, never how an edge gets \
            \ picked or validated. On a miss (or a stale entry, topology-version \
            \ behind current), falls through to the unchanged live search."
        (let
            (
                ;;#21H: SWPT no longer needs a principal list at all — the Tracer's
                ;;storage is principal-agnostic (SwapTracerV3).
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (cached:object{SwapTracerV3.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                ;;Only computed on an actual cache miss — a `let` binding here would
                ;;evaluate unconditionally even on a hit, silently paying for the live
                ;;search Phase 1's whole point is to skip. Nested inside the `if`
                ;;instead so a cache hit never touches SWPT::URC_ComputeGraphPathFromRaw.
                (routes:[[string]]
                    (if (!= cached-nodes [BAR])
                        [cached-nodes]
                        ;;#65bL Phase 5 fix: must go through the raw-graph-once path
                        ;;(URC_FetchRawGraph + URC_ComputeGraphPathFromRaw), NOT the
                        ;;plain self-fetching URC_ComputeGraphPath — that function was
                        ;;never touched by Phase 2's optimization (it only ever makes
                        ;;one call, so cross-attempt sharing never applied to it), so
                        ;;using it here would mean a SINGLE search that's still paying
                        ;;the pre-Phase-2 cost, while best-of-3's own first attempt
                        ;;(via URC_ComputeAlternateRoutes's own internal fetch) is
                        ;;already Phase-2-cheap. Measured directly: using the plain
                        ;;self-fetching path here was NET MORE EXPENSIVE than
                        ;;best-of-3, exactly backwards from the goal — caught before
                        ;;shipping, not after.
                        (let
                            (
                                (single-route:[string]
                                    (ref-SWPT::URC_ComputeGraphPathFromRaw
                                        hopper-input-id hopper-output-id swpairs
                                        (ref-SWPT::URC_FetchRawGraph
                                            (ref-U|SWP::UC_MakeGraphNodes hopper-input-id hopper-output-id swpairs)
                                        )
                                    )
                                )
                            )
                            (if (= single-route [BAR]) [] [single-route])
                        )
                    )
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV4.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCx_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URCx_HopperFromRaw:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            swpairs:[string] raw-graph:[object{SwapTracerV3.RawGraphNode}]
        )
        @doc "#65bL Phase 4 fix: <URCx_Hopper>, sourcing its routing search via an \
            \ ALREADY-FETCHED <raw-graph> (<SWPT::URC_FetchRawGraph>) instead of \
            \ letting <SWPT::URC_ComputeGraphPathFromRaw> fetch its own — for a caller \
            \ making MULTIPLE unrelated Hopper queries in one transaction (the \
            \ STOA-repricing loop: one query per distinct pool touched, each to a \
            \ different first-token but the SAME destination, WSTOA) who fetches the \
            \ whole topology's raw graph exactly ONCE and reuses it across every \
            \ query. Safe because <SWPT::UC_MakeGraphNodes> (the node-universe \
            \ derivation both the fetch and every query rely on) is <input>/<output>- \
            \ independent by construction — it derives every token appearing across \
            \ the full <swpairs> list, regardless of which specific pair is being \
            \ queried — so ONE raw-graph fetched against a given <swpairs> universe \
            \ is valid for EVERY query against that same universe, not just the one \
            \ it happened to be fetched for. Still checks SWPT|PathCache first, \
            \ identically to <URCx_Hopper> — a cache hit is even cheaper than a \
            \ shared-raw-graph live search, this doesn't replace that, it only makes \
            \ the miss case cheaper too. \
            \ #65bL Phase 5 fix: was best-of-3 via <SWPT::URC_ComputeAlternateRoutesFromRaw> \
            \ — see <URCx_Hopper>'s own doc for the full measured rationale (identical \
            \ here, same shared decision)."
        (let
            (
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (cached:object{SwapTracerV3.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                ;;Only computed on an actual cache miss — see URCx_Hopper's own comment
                ;;on this exact same eager-`let`-evaluation trap.
                (routes:[[string]]
                    (if (!= cached-nodes [BAR])
                        [cached-nodes]
                        (let
                            (
                                (single-route:[string]
                                    (ref-SWPT::URC_ComputeGraphPathFromRaw hopper-input-id hopper-output-id swpairs raw-graph)
                                )
                            )
                            (if (= single-route [BAR]) [] [single-route])
                        )
                    )
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV4.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCx_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URCx_HopperFromGraph:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            swpairs:[string] graph:[object{BreadthFirstSearchV2.GraphNode}]
        )
        @doc "#65bL Phase 7 fix: <URCx_HopperFromRaw>, sourcing its routing search \
            \ via an ALREADY-BUILT <graph> (<SWPT::UC_MakeGraphFromRaw>) instead of \
            \ rebuilding it from <raw-graph> on every call — see \
            \ <URC_HopperFromGraph>'s own doc for the full rationale (repricing- \
            \ loop graph-build sharing, one layer deeper than Phase 4's raw-graph \
            \ sharing). Still checks SWPT|PathCache first, identically to \
            \ <URCx_Hopper>/<URCx_HopperFromRaw> — a cache hit is even cheaper than \
            \ a shared-graph live search, this doesn't replace that, it only makes \
            \ the miss case cheaper too."
        (let
            (
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (cached:object{SwapTracerV3.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                ;;Only computed on an actual cache miss — see URCx_Hopper's own comment
                ;;on this exact same eager-`let`-evaluation trap.
                (routes:[[string]]
                    (if (!= cached-nodes [BAR])
                        [cached-nodes]
                        (let
                            (
                                (single-route:[string]
                                    (ref-SWPT::URC_ComputeGraphPathFromGraph hopper-input-id hopper-output-id graph)
                                )
                            )
                            (if (= single-route [BAR]) [] [single-route])
                        )
                    )
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV4.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCx_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URC_EliteFeeReduction:object{UtilitySwpV2.SwapFeez} (account:string fees:object{UtilitySwpV2.SwapFeez})
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (major:integer (ref-DALOS::UR_Elite-Tier-Major account))
                (minor:integer (ref-DALOS::UR_Elite-Tier-Minor account))
            )
            (ref-U|SWP::UDC_SwapFeez
                (ref-U|DALOS::UC_GasCost (at "lp" fees) major minor false)
                (ref-U|DALOS::UC_GasCost (at "special" fees) major minor false)
                (ref-U|DALOS::UC_GasCost (at "boost" fees) major minor false)
            )
        )
    )
    (defun URCv_PoolTokenPositions:[integer] (swpair:string input-ids:[string])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens (ref-SWP::UR_PoolTokens swpair))
                (are-on-pool:bool (ref-SWP::UEV_CheckAgainst input-ids pool-tokens))
            )
            (enforce are-on-pool (format "Input Token IDs {} arent on pool {}" [input-ids swpair]))
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (ref-SWP::URv_PoolTokenPosition swpair (at idx input-ids))
                    )
                )
                []
                (enumerate 0 (- (length input-ids) 1))
            )
        )
    )
    ;;
    (defun URC_DirectRawSwapInput:object{UtilitySwpV2.DirectRawSwapInput}
        (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-U|SWP::UDC_DirectRawSwapInput
                (ref-SWP::UR_Amplifier swpair)
                (ref-SWP::UR_PoolTokenSupplies swpair)
                input-amounts 
                (URCv_PoolTokenPositions swpair input-ids)
                (ref-SWP::URv_PoolTokenPosition swpair output-id)
                (ref-DPTF::UR_Decimals output-id)
                (ref-SWP::UR_Weigths swpair)
            )
        )
    )
    (defun URC_InverseRawSwapInput:object{UtilitySwpV2.InverseRawSwapInput}
        (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (output-id:string (at "output-id" rsid))
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-U|SWP::UDC_InverseRawSwapInput
                (ref-SWP::UR_Amplifier swpair)
                (ref-SWP::UR_PoolTokenSupplies swpair)
                output-amount
                (ref-SWP::URv_PoolTokenPosition swpair output-id)
                (ref-SWP::URv_PoolTokenPosition swpair input-id)
                (ref-DPTF::UR_Decimals input-id)
                (ref-SWP::UR_Weigths swpair)
            )
        )
    )
    ;;
    (defun URCv_Swap:decimal 
        (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} validation:bool)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (l1:integer (length (at "input-amounts" dsid)))
            )
            (if (= pool-type "S")
                (enforce (= l1 1) "Only a single Input can be used in Stable Swap")
                true
            )
            (if validation
                (UEV_SwapData swpair dsid)
                true
            )
            (cond
                ((= pool-type "S") (URC_S-Swap swpair dsid))
                ((= pool-type "W") (URC_W-Swap swpair dsid))
                ((= pool-type "P") (URC_P-Swap swpair dsid))
                -1.0
            )
        )
    )
    (defun URC_S-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        @doc "Performs a Swap Computation in a Swable Pool. Data needed: \
            \ <A> = Pool Amplifier\
            \ <X> = Pool Token Supplies (must be read) \
            \ <input-amounts> = Amounts of the Input Tokens that make the swap. They must be in the same order as the <input-ids> \
            \ ip = Position of the input token (must be read) \
            \ op = position in the pool of the output token (must be read) \
            \ o-prec = precision of the output token (must be read) \
            \ w = weigths of the swpair"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeY
                (URC_DirectRawSwapInput swpair dsid)
            )
        )
    )
    (defun URC_W-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        @doc "Performs a Swap Computation in a Weigthed Constant Product Pool. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <input-amounts> = Amounts of the Input Tokens that make the swap. They must be in the same order as the <input-ids> \
            \ ip = list with the pool position of the input tokens (must be read) \
            \ op = position in the pool of the output token (must be read) \
            \ o-prec = precision of the output token (must be read) \
            \ w = weigths of the swpair"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeWP
                (URC_DirectRawSwapInput swpair dsid)
            )
        )
    )
    (defun URC_P-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        @doc "Performs a Swap Computation in a Constant Product Pool. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <input-amounts> = Amounts of the Input Tokens that make the swap. They must be in the same order as the <input-ids> \
            \ ip = list with the pool position of the input tokens (must be read) \
            \ op = position in the pool of the output token (must be read) \
            \ o-prec = precision of the output token (must be read)"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeEP
                (URC_DirectRawSwapInput swpair dsid)
            )
        )
    )
    (defun URC_InverseSwap:decimal
        (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData} validation:bool)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
            )
            (if validation
                (UEV_InverseSwapData swpair rsid)
                true
            )
            (cond
                ((= pool-type "S") (URC_S-InverseSwap swpair rsid))
                ((= pool-type "W") (URC_W-InverseSwap swpair rsid))
                ((= pool-type "P") (URC_P-InverseSwap swpair rsid))
                -1.0
            )
        )
    )
    (defun URC_S-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        @doc "Performs a Swap Computation in a Swable Pool. Data needed: \
            \ <A> = Pool Amplifier\
            \ <X> = Pool Token Supplies (must be read) \
            \ <output-amount> = How much output must be achieved by swaping the input amount that must be solved for \
            \ <op> = output position in the pool (must be read) \
            \ <ip> = input position in the pool (must be read) \
            \ <i-prec> = precision of the input token (must be read)"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UCv_ComputeInverseY
                (URC_InverseRawSwapInput swpair rsid)
            )
        )
    )
    (defun URC_W-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        @doc "Inverse Swap solves how much of a given SINGLE input is needed to get a specific SINGLE output. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <output-amount> = How much output must be achieved by swaping the input amount that must be solved for \
            \ <op> = output position in the pool (must be read) \
            \ <ip> = input position in the pool (must be read) \
            \ <i-prec> = precision of the input token (must be read) \
            \ w = weigths of the swpair"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeInverseWP 
                (URC_InverseRawSwapInput swpair rsid)
            )
        )
    )
    (defun URC_P-InverseSwap (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        @doc "Inverse Swap solves how much of a given SINGLE input is needed to get a specific SINGLE output. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <output-amount> = How much output must be achieved by swaping the input amount that must be solved for \
            \ <op> = output position in the pool (must be read) \
            \ <ip> = input position in the pool (must be read) \
            \ <i-prec> = precision of the input token (must be read)"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeInverseEP 
                (URC_InverseRawSwapInput swpair rsid)
            )
        )
    )
    ;;
    (defun URCx_HopperForNodes:object{SwapperIssueV4.Hopper}
        (nodes:[string] hopper-input-amount:decimal swpairs:[string])
        @doc "Computes the Hopper object (best per-hop edge + accumulated output) for \
            \ an ALREADY-KNOWN <nodes> path. Split out of <URCx_Hopper> (#34M/M2 fix) \
            \ so the identical per-hop best-edge computation can be run once per \
            \ candidate route in <URCx_Hopper>'s best-of-K comparison, not just the \
            \ single first-found route. Computes: \
            \ 1] The hops along <nodes>, the <edges> as the highest-output edge from all available \
            \ #49L fix: was 'cheapest available edge' — backwards framing (C1/#6C's own fix made \
            \ this maximize output among parallel pools, not minimize cost) \
            \ 2] The best <output> values using said best <edges>, given the <hopper-input-amount>"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (if (!= nodes [BAR])
                (let
                    (
                        (fl:[object{SwapperIssueV4.Hopper}]
                            (fold
                                (lambda
                                    (acc:[object{SwapperIssueV4.Hopper}] idx:integer)
                                    (ref-U|LST::UC_ReplaceAt
                                        acc
                                        0
                                        (let
                                            (
                                                (input:decimal
                                                    (if (= idx 0)
                                                        hopper-input-amount
                                                        (at 0 (take -1 (at "output-values" (at 0 acc))))
                                                    )
                                                )
                                                (i-id:string (at idx nodes))
                                                (o-id:string (at (+ idx 1) nodes))
                                                ;;#19H fix: restrict edge candidates to this call's
                                                ;;<swpairs> universe (full for <URC_Hopper>, active-only
                                                ;;for <URC_HopperActive>) — a disabled parallel pool can
                                                ;;never be chosen over an active one, or at all when
                                                ;;routing active-only.
                                                (best-edge:string (URC_BestEdgeFiltered input i-id o-id swpairs))
                                                (dsid:object{UtilitySwpV2.DirectSwapInputData}
                                                    (ref-U|SWP::UDC_DirectSwapInputData [i-id] [input] o-id)
                                                )
                                                (output:decimal (URCv_Swap best-edge dsid false))
                                            )
                                            (UDC_Hopper
                                                nodes
                                                (ref-U|LST::UC_AppL (at "edges" (at 0 acc)) best-edge)
                                                (ref-U|LST::UC_AppL (at "output-values" (at 0 acc)) output)
                                            )
                                        )
                                    )
                                )
                                EMPTY_HOPPER
                                (enumerate 0 (- (length nodes) 2))
                            )
                        )
                    )
                    (at 0 fl)
                )
                (at 0 EMPTY_HOPPER)
            )
        )
    )
    (defun URC_HopperForKnownRoute:object{SwapperIssueV4.Hopper}
        (nodes:[string] edges:[string] hopper-input-amount:decimal)
        @doc "#34 Phase 8: like URCx_HopperForNodes, computes the feeless per-hop output \
            \ chain for a KNOWN path — but walks the caller-supplied <edges> directly \
            \ instead of re-deriving a 'best' edge per hop via URC_BestEdgeFiltered. \
            \ This matters: a dirty-read-injected bundle's swap-route is what real \
            \ execution (XI_SmartSwapCore) will actually walk, hop for hop — the feeless \
            \ quote used for the slippage floor check must be computed against those SAME \
            \ edges, not a possibly-different 'best' edge a live re-derivation might pick \
            \ when parallel pools exist between the same two tokens (that mismatch could \
            \ silently let a worse real execution slip past a floor check computed on a \
            \ better hypothetical route). Also reused for pricing paths (boost-path, \
            \ stoa-paths) where the caller-chosen edges are likewise the ones that matter, \
            \ not a re-optimized alternative. Caller validates nodes/edges beforehand — \
            \ this function trusts its input and only computes."
        (if (!= nodes [BAR])
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                    (le:integer (length edges))
                )
                (if (= le 0)
                    (UDC_Hopper nodes [] [])
                    (let
                        (
                            (fl:[object{SwapperIssueV4.Hopper}]
                                (fold
                                    (lambda
                                        (acc:[object{SwapperIssueV4.Hopper}] idx:integer)
                                        (ref-U|LST::UC_ReplaceAt
                                            acc
                                            0
                                            (let
                                                (
                                                    (input:decimal
                                                        (if (= idx 0)
                                                            hopper-input-amount
                                                            (at 0 (take -1 (at "output-values" (at 0 acc))))
                                                        )
                                                    )
                                                    (i-id:string (at idx nodes))
                                                    (o-id:string (at (+ idx 1) nodes))
                                                    (swpair:string (at idx edges))
                                                    (dsid:object{UtilitySwpV2.DirectSwapInputData}
                                                        (ref-U|SWP::UDC_DirectSwapInputData [i-id] [input] o-id)
                                                    )
                                                    (output:decimal (URCv_Swap swpair dsid false))
                                                )
                                                (UDC_Hopper
                                                    nodes
                                                    (ref-U|LST::UC_AppL (at "edges" (at 0 acc)) swpair)
                                                    (ref-U|LST::UC_AppL (at "output-values" (at 0 acc)) output)
                                                )
                                            )
                                        )
                                    )
                                    [(UDC_Hopper nodes [] [])]
                                    (enumerate 0 (- le 1))
                                )
                            )
                        )
                        (at 0 fl)
                    )
                )
            )
            (at 0 EMPTY_HOPPER)
        )
    )
    (defun URC_HopperExhaustive:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            swpairs:[string] max-attempts:integer
        )
        @doc "#34 Phase 11 — the original #34 ask: genuine exhaustive route discovery, \
            \ not URCx_Hopper's fixed best-of-3 approximation. Identical shape to \
            \ URCx_Hopper (route-then-price-then-pick-best) but sources candidate \
            \ node-paths from SWPT::URC_ComputeAllRoutes (a real parameterized search \
            \ up to <max-attempts>, P0.2's flat +1000 caller-side escalation pattern \
            \ and P0.2/P0.4's outer-hard-stop/depth-cap already enforced inside that \
            \ function) instead of the K=3-capped URC_ComputeAlternateRoutes. Reuses \
            \ URCx_HopperForNodes (per-candidate feeless value) and UC_BestHopper (pick \
            \ the genuinely highest-output candidate, P1.8's requirement — never by hop \
            \ count as a proxy for cost) completely unchanged; no new value-computation \
            \ logic needed, same division of labor URCx_Hopper already established. \
            \ Exposes <swpairs> directly (unlike the hidden-universe URC_Hopper/ \
            \ URC_HopperActive public wrappers) so a caller picks the routing universe \
            \ explicitly — active-only for real swap discovery, or any subset for \
            \ Phase 12's varying-scale measurement (P2.1). Off-chain dirty-read use \
            \ only — never call this from a paid transaction, that defeats the entire \
            \ point of the #34/#34M redesign."
        (let
            (
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (routes:[[string]]
                    (ref-SWPT::URC_ComputeAllRoutes hopper-input-id hopper-output-id swpairs max-attempts)
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV4.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCx_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URC_Hopper:object{SwapperIssueV4.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal)
        @doc "Creates a Hopper Object routed over the FULL swpair universe, \
            \ including <can-swap>=false pools. Used internally for issuance-time \
            \ pricing (<URC_WorthWSTOA>, <UEV_Issue>'s principal-anchoring check), \
            \ which must work even when neighboring pools aren't swap-enabled yet. \
            \ Live swap-execution/quote callers must use <URC_HopperActive> \
            \ instead (#19H) — routing a real user swap over disabled pools is \
            \ the exact bug that fix closes."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (URCx_Hopper hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_Swpairs))
        )
    )
    (defun URC_HopperFromRaw:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            raw-graph:[object{SwapTracerV3.RawGraphNode}]
        )
        @doc "#65bL Phase 4 fix: <URC_Hopper>, sourcing its routing search via an \
            \ ALREADY-FETCHED <raw-graph> instead of a fresh self-fetch — see \
            \ <URCx_HopperFromRaw>'s own doc for the full rationale."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (URCx_HopperFromRaw hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_Swpairs) raw-graph)
        )
    )
    (defun URC_HopperFromGraph:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            graph:[object{BreadthFirstSearchV2.GraphNode}]
        )
        @doc "#65bL Phase 7 fix: <URC_HopperFromRaw>, sourcing its routing search \
            \ via an ALREADY-BUILT <graph> instead of rebuilding it from \
            \ <raw-graph> on every call — see <URCx_HopperFromGraph>'s own doc for \
            \ the full rationale."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (URCx_HopperFromGraph hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_Swpairs) graph)
        )
    )
    (defun URC_HopperActive:object{SwapperIssueV4.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal)
        @doc "Live-swap-execution routing entrypoint — restricts BFS routing to \
            \ <can-swap>=true pools only, so a disabled pool can never be \
            \ BFS-selected and then rejected downstream with no fallback (#19H). \
            \ Used by SWPU's actual swap-execution and slippage-quote call sites."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (URCx_Hopper hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_ActiveSwpairs))
        )
    )
    (defun URC_HopperActiveShortest:object{SwapperIssueV4.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal)
        @doc "Lightweight Hopper routing over <can-swap>=true pools only — a single \
            \ shortest BFS route (<SWPT::URC_ComputeGraphPath>), never the best-of-3 \
            \ alternate-route search <URC_HopperActive> runs (P0.6, SWP exhaustive- \
            \ path-search HANDOFF doc). Built for <SWPU::XI_RawLiquidPump>'s Liquid \
            \ Boost pump: that call only needs *a* valid route to SSTOA to price a \
            \ small residual fee slice for burning, not the *optimal* one — but it \
            \ fires once per SmartSwap hop, so routing it through the same up-to-3x \
            \ alternate-route search real swap execution uses multiplies cost by \
            \ hop-count x 3 for no pricing benefit worth the gas. Do not use this for \
            \ any live user-facing quote/execution path — those must keep using \
            \ <URC_HopperActive> so users still get the best available route. \
            \ #65fL Phase 8a fix: this was the one Hopper variant left completely \
            \ untouched by #65bL Phases 1-7 — no PathCache check, no shared \
            \ raw-graph. Now checks SWPT|PathCache first (URC_ReadPathCacheFresh), \
            \ identically to URCx_Hopper's own Phase 1 pattern — on a fresh hit, \
            \ skips the live BFS entirely and uses the cached node-path as the \
            \ sole candidate, safe for the same reason Phase 1 established (the \
            \ real per-hop edge is always re-derived live downstream in \
            \ URCx_HopperForNodes against the <swpairs> active-only universe, \
            \ regardless of where the node-path came from). Especially valuable \
            \ here since this targets exactly the pair a bundle-assisted swap's \
            \ own <boost-path> already warms in this same cache (#65bL Phase 6) — \
            \ a self-searching swap running after one for the same input token \
            \ gets this for free. On a miss, falls through to the unchanged live \
            \ search."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (swpairs:[string] (ref-SWP::URC_ActiveSwpairs))
                (cached:object{SwapTracerV3.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                (nodes:[string]
                    (if (!= cached-nodes [BAR])
                        cached-nodes
                        (ref-SWPT::URC_ComputeGraphPath hopper-input-id hopper-output-id swpairs)
                    )
                )
            )
            (URCx_HopperForNodes nodes hopper-input-amount swpairs)
        )
    )
    (defun URC_ValidatePathActive:bool (nodes:[string] edges:[string])
        @doc "#34 Phase 7: active-required validation for the A->B execution route — \
            \ SWPT's exists-only structural check (real edges, correctly connected, \
            \ within the depth cap) PLUS every edge must be <can-swap>=true, since this \
            \ route is actually walked with real user funds, unlike the boost/stoa-value \
            \ pricing paths (SWPT::URC_ValidatePathStructure alone, exists-only, is \
            \ sufficient for those — see the P3.0 split in the exhaustive-path-search \
            \ HANDOFF doc)."
        (let
            (
                (ref-SWPT:module{SwapTracerV3} SWPT)
            )
            (if (not (ref-SWPT::URC_ValidatePathStructure nodes edges))
                false
                (if (= (length edges) 0)
                    true
                    (let
                        (
                            (ref-SWP:module{SwapperV4} SWP)
                        )
                        (fold
                            (lambda (acc:bool e:string) (and acc (ref-SWP::UR_CanSwap e)))
                            true
                            edges
                        )
                    )
                )
            )
        )
    )
    (defun URCx_BestEdgeOf:string (ia:decimal i:string o:string edges:[string])
        @doc "Shared best-edge-selection core for <URC_BestEdge>/<URC_BestEdgeFiltered> \
            \ — identical in every respect except which <edges> candidate list is \
            \ passed in. Internal only, not on the interface."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (svl:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (URCv_Swap (at idx edges) (ref-U|SWP::UDC_DirectSwapInputData [i] [ia] o) false)
                            )
                        )
                        []
                        (enumerate 0 (- (length edges) 1))
                    )
                )
                ;;C1 fix: keep the index with the LARGER output (argmax), not smaller (argmin) — "best"
                ;;edge for a fixed input means most output, matching URC_Hopper's own documented intent.
                (sp:integer
                    (fold
                        (lambda
                            (acc:integer idx:integer)
                            (if (= idx 0)
                                acc
                                (if (> (at idx svl) (at acc svl))
                                    idx
                                    acc
                                )
                            )
                        )
                        0
                        (enumerate 0 (- (length svl) 1))
                    )
                )
            )
            (at sp edges)
        )
    )
    (defun URC_BestEdge:string (ia:decimal i:string o:string)
        @doc "Best edge across ALL swpairs connecting <i>/<o>, including disabled \
            \ ones — matches <URC_Hopper>'s full-universe scope. Live \
            \ swap-execution callers should use <URC_BestEdgeFiltered> instead."
        (let
            (
                ;;#21H: SWPT no longer needs a principal list.
                (ref-SWPT:module{SwapTracerV3} SWPT)
            )
            (URCx_BestEdgeOf ia i o (ref-SWPT::URC_Edges i o))
        )
    )
    (defun URC_BestEdgeFiltered:string (ia:decimal i:string o:string swpairs:[string])
        @doc "Best edge restricted to swpairs also present in <swpairs> — used by \
            \ <URCx_Hopper> so a disabled parallel pool between the same token \
            \ pair is never selected as the executed hop, even when an active \
            \ parallel pool exists between the same two tokens (#19H)."
        (let
            (
                ;;#21H: SWPT no longer needs a principal list.
                (ref-SWPT:module{SwapTracerV3} SWPT)
            )
            (URCx_BestEdgeOf ia i o (ref-SWPT::URC_EdgesActive i o swpairs))
        )
    )
    ;;Value Computations
    (defun URC_SingleSSTOAWorthWSTOA:decimal ()
        @doc "#65fL Phase 8b: SSTOA's own worth in WSTOA terms, per unit — the ATS \
            \ autostake index (the 'liquid staking conversion, backwards'), zero \
            \ graph search. Extracted as its own function, mirroring \
            \ <URC_SingleOuroWorthWSTOA>, so <URCx_PrimordialValueAndOuroSupply> can \
            \ call it directly instead of going through <URC_SingleWorthWSTOA>/ \
            \ <URC_WorthWSTOA> — routing through those would create a genuine STATIC \
            \ recursive cycle at compile time (URC_WorthWSTOA's own id==OURO branch \
            \ calls into URCx_PrimordialValueAndOuroSupply), caught by Pact 5's own \
            \ cycle detector when this was first wired that way — even though the \
            \ actual runtime call chain (always SSTOA's own id here, which never \
            \ re-enters the OURO branch) would never truly recurse. <URC_WorthWSTOA>'s \
            \ own id==SSTOA branch also uses this now, instead of its own inline copy \
            \ of the same lookup."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (ats-pairs-with-sstoa-id:[string] (ref-DPTF::UR_RewardBearingToken sstoa))
                (stoaliquindex:string (at 0 ats-pairs-with-sstoa-id))
            )
            (ref-ATS::URC_Index stoaliquindex)
        )
    )
    (defun URCx_PrimordialValueAndOuroSupply:[decimal] ()
        @doc "#65fL Phase 8b: shared core extracted from <URC_OuroPrimordialPrice> — \
            \ [<primordial-wstoa-value> <ouro-supply>], where <primordial-wstoa-value> \
            \ is the primordial pool's total value in WSTOA-equivalent terms (native \
            \ WSTOA reserve plus the SSTOA reserve converted via its own cheap \
            \ index-based shortcut, URC_SingleSSTOAWorthWSTOA — zero graph search either \
            \ way). \
            \ #73C fix, scope note: originally shared by BOTH <URC_OuroPrimordialPrice> \
            \ (dollar-denominated) and <URC_SingleOuroWorthWSTOA> (WSTOA-denominated) — \
            \ the WSTOA-denominated side moved to a real 1-unit weighted-pool swap \
            \ instead (see <URC_SingleOuroWorthWSTOA>'s own doc for why: this helper's \
            \ ratio ignores the primordial pool's own weights, undervaluing OURO). \
            \ <URC_OuroPrimordialPrice> is the only remaining caller. Flagged, not \
            \ fixed here (out of scope — the WSTOA-denominated case is what surfaced \
            \ this): <URC_OuroPrimordialPrice>'s own final division likely has the \
            \ identical weight-omission issue, unverified, left for a follow-up. \
            \ Internal only, not on the public interface."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (primordial:string (ref-SWP::UR_PrimordialPool))
                (pts:[decimal] (ref-SWP::UR_PoolTokenSupplies primordial))
                ;;
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (sstoa-supply:decimal (at 0 pts))
                (ouro-supply:decimal (at 1 pts))
                (wstoa-supply:decimal (at 2 pts))
                ;;
                (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                (sstoa-in-wstoa:decimal (URC_SingleSSTOAWorthWSTOA))
                (sstoa-in-wstoa-value (floor (* sstoa-supply sstoa-in-wstoa) sstoa-prec))
                (primordial-wstoa-value:decimal (+ wstoa-supply sstoa-in-wstoa-value))
            )
            [primordial-wstoa-value ouro-supply]
        )
    )
    (defun URC_OuroPrimordialPrice:decimal ()
        @doc "OURO's price in dollars. \
            \ #73C-TWIN FIX (2026-09-17): this used to compute its own flat reserve ratio -- \
            \ (primordial-wstoa-value * stoa-pid) / ouro-supply -- which READ NO WEIGHT and so \
            \ silently assumed the primordial pool was equal-weighted. It cannot be: \
            \ SWP|C>DEFINE-PRIMORDIAL-POOL enforces a WEIGHTED pool of exactly three tokens, and \
            \ genesis ships [SSTOA 0.3, OURO 0.5, WSTOA 0.2]. Measured before the fix, with \
            \ reserves held constant and weights varied through the live C_ModifyWeights path, \
            \ the old output was BIT-IDENTICAL across [0.4 0.4 0.2], [0.2 0.6 0.2] and genesis \
            \ [0.3 0.5 0.2] -- it did not move one digit across three weightings of the pool it \
            \ prices. Error at genesis weights: -38.65%, reproducing #73C's independently \
            \ measured ~38% on the WSTOA twin, which is the same bug this is the twin of. \
            \ It reached the OURO oracle write, DEMIPAD launchpad payments and the Explorer. \
            \ The fix DELEGATES rather than re-deriving: URC_TokenDollarPrice -> \
            \ URC_SingleWorthWSTOA -> URC_WorthWSTOA's OURO short-circuit -> \
            \ URC_SingleOuroWorthWSTOA, a real 1-unit weighted swap through UC_ComputeWP -- the \
            \ only math in the family that consumes (at \"weights\" drsi). That path is #73C's \
            \ own repair, already live and already proven, so this carries no new arithmetic. \
            \ See DEFECT-LEDGER 8.1."
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (ids:object{OuronetDalosV2.CanonicalStoaIds} (ref-DALOS::UR_CanonicalStoaIds))
            )
            (URC_TokenDollarPrice (at "gas-source-id" ids) stoa-pid)
        )
    )
    (defun URC_SingleOuroWorthWSTOA:decimal (ouro:string wstoa:string)
        @doc "#73C fix: OURO's own worth in WSTOA, per unit — a real 1-unit swap \
            \ through the primordial pool's own weighted-pool math (URC_W-Swap, the \
            \ exact same UC_ComputeWP invariant a live swap would use), instead of the \
            \ old hand-rolled <primordial-wstoa-value / ouro-supply> ratio. The old \
            \ formula was mathematically wrong for THIS pool, not just approximate: it \
            \ implicitly assumed every token in the primordial pool carries equal \
            \ weight, but the pool is genuinely weighted (SSTOA 0.3 / OURO 0.5 / WSTOA \
            \ 0.2 at issuance) — a weighted pool's real exchange rate depends on \
            \ reserve/weight ratios, not a flat sum-of-other-reserves-over-own-reserve \
            \ ratio. Confirmed live: the old formula returned 91.95 WSTOA for 100 OURO \
            \ against real reserves [sstoa=3200.0 ouro=10002.0 wstoa=5997.009] and \
            \ weights [0.3 0.5 0.2], while the weighted spot formula \
            \ ((wstoa/wstoa_w)/(ouro/ouro_w)) gives ~149.9, matching the pre-existing \
            \ graph-search fallback's 147.31 (the small remainder being real, correctly \
            \ modeled AMM slippage from an actual ~1%-of-reserves trade — see \
            \ URC_WorthWSTOA's own doc for why THAT part is now handled at the caller, \
            \ not here). Still zero graph search: OURO and WSTOA are direct pool \
            \ siblings in the SAME primordial pool, this is one single-hop direct-pool \
            \ swap computation, not a BFS route search. <ouro>/<wstoa> passed in by the \
            \ caller (not self-fetched) — every real caller already holds them via \
            \ DALOS::UR_CanonicalStoaIds, so this adds no new read."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (primordial:string (ref-SWP::UR_PrimordialPool))
            )
            (URC_W-Swap primordial (ref-U|SWP::UDC_DirectSwapInputData [ouro] [1.0] wstoa))
        )
    )
    (defun URC_TokenDollarPrice (id:string stoa-pid:decimal)
        @doc "Retrieves Token Price in Dollars, via DIA Oracle that outputs STOA Price"
        ;;<stoa-pid> or <stoa-price-in-dollars> can be retrieved prior to the function call with:
        ;;(at "value" (n_bfb76eab37bf8c84359d6552a1d96a309e030b71.dia-oracle.get-value "STOA/USD"))
        ;;This function is structured like this, to allow price retrieval from any source.
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (id-in-stoa:decimal (URC_SingleWorthWSTOA id))
                (id-precision:integer (ref-DPTF::UR_Decimals id))
            )
            (floor (* id-in-stoa stoa-pid) id-precision)
        )
    )
    (defun URC_SingleWorthWSTOA (id:string)
        (URC_WorthWSTOA id 1.0)
    )
    (defun URC_WorthWSTOA (id:string amount:decimal)
        @doc "#65fL Phase 8b fix: added an id==OURO short-circuit (URC_SingleOuroWorthWSTOA, \
            \ straight off the primordial pool's own reserves), zero graph search — same \
            \ shape as the pre-existing id==SSTOA short-circuit below. WSTOA/SSTOA/OURO are the \
            \ only tokens with a canonical zero-search pricing mechanism; every other id \
            \ still falls through to the graph-search branch. The OURO shortcut only fires \
            \ when a primordial pool has actually been defined (SWP::UR_PrimordialPool != \
            \ BAR, checked via a short-circuited `and` so this extra read only happens for \
            \ id==OURO, never for any other id) — SAFETY, not a guess: caught live, a real \
            \ pre-bootstrap crash reading an unset primordial pool during that very pool's \
            \ OWN issuance (UEV_Issue's spawn-limit check prices the first token before any \
            \ primordial pool could exist yet). Falls through to the exact original \
            \ graph-search behavior when unsafe — matches pre-Phase-8b behavior byte for \
            \ byte in that edge case, not a new approximation. Fetches WSTOA/SSTOA/OURO via \
            \ DALOS::UR_CanonicalStoaIds — ONE read for all 3, instead of 3 independent \
            \ reads of the same DALOS row — caught live: adding a naive 3rd standalone \
            \ UR_OuroborosID call regressed the P0.5/P2-scale worst-case checkpoints \
            \ (measured +928 gas) despite neither pool ever pricing OURO/SSTOA in that \
            \ scenario, isolated via git-stash bisection before this fix, not guessed. \
            \ #73C fix: the graph-search fallback below now prices ONE unit and scales \
            \ linearly, instead of simulating a swap of the full <amount> — see the \
            \ fallback branch's own comment for why (depth-skew: 'worth of N tokens' is \
            \ not N times 'worth of 1 token' once a simulated swap eats meaningfully into \
            \ pool depth, and URC_PoolValue's own caller passes an ENTIRE pool reserve as \
            \ <amount>, not a small swap-sized figure)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-SWP:module{SwapperV4} SWP)
                (ids:object{OuronetDalosV2.CanonicalStoaIds} (ref-DALOS::UR_CanonicalStoaIds))
                (wstoa:string (at "wrapped-stoa-id" ids))
                (sstoa:string (at "silver-stoa-id" ids))
                (ouro:string (at "gas-source-id" ids))
            )
            (if (= id wstoa)
                amount
                (if (= id sstoa)
                    (let
                        (
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                            (index-value:decimal (URC_SingleSSTOAWorthWSTOA))
                            (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                        )
                        (floor (* amount index-value) sstoa-prec)
                    )
                    (if (and (= id ouro) (!= (ref-SWP::UR_PrimordialPool) BAR))
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ouro-worth-per-unit:decimal (URC_SingleOuroWorthWSTOA ouro wstoa))
                                (ouro-prec:integer (ref-DPTF::UR_Decimals ouro))
                            )
                            (floor (* amount ouro-worth-per-unit) ouro-prec)
                        )
                        ;;#73C fix: price ONE unit via the real route (URC_Hopper amount=1.0,
                        ;;not <amount>), then scale linearly — never simulate a swap of the
                        ;;full requested <amount>, since a real swap of a large amount eats
                        ;;into pool depth (AMM slippage), so "worth of N" would come out
                        ;;systematically LESS than N times "worth of 1," most severely
                        ;;exactly where this function is actually called from
                        ;;(URC_PoolValue prices a pool's ENTIRE first-token reserve this
                        ;;way). "1 unit" is an accepted, unavoidable approximation of the
                        ;;true marginal/instantaneous spot price (an exact closed-form
                        ;;derivative isn't implemented anywhere in this codebase and isn't
                        ;;worth building for this) — computing at a smaller-than-1 amount
                        ;;isn't meaningful once atomic-unit precision is reached.
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (h-obj:object{SwapperIssueV4.Hopper} (URC_Hopper id wstoa 1.0))
                                (ovs:[decimal] (at "output-values" h-obj))
                                (per-unit-worth:decimal (if (= (length ovs) 0) 0.0 (at 0 (take -1 ovs))))
                                (id-prec:integer (ref-DPTF::UR_Decimals id))
                            )
                            (floor (* amount per-unit-worth) id-prec)
                        )
                    )
                )
            )
        )
    )
    (defun URC_WorthWSTOAFromRaw (id:string amount:decimal raw-graph:[object{SwapTracerV3.RawGraphNode}])
        @doc "#65bL Phase 4 fix: <URC_WorthWSTOA>, sourcing any graph search it needs \
            \ via an ALREADY-FETCHED <raw-graph> (<URC_HopperFromRaw>) instead of a \
            \ fresh self-fetch — see <URCx_HopperFromRaw>'s own doc for the full \
            \ rationale (repricing-loop sharing). The WSTOA/SSTOA short-circuit branches \
            \ never needed a graph search to begin with and stay unchanged. \
            \ #65fL Phase 8b fix: added the same id==OURO short-circuit \
            \ <URC_WorthWSTOA> gained (URC_SingleOuroWorthWSTOA) — also never needed a \
            \ graph search. Same pre-bootstrap safety guard too: only fires when \
            \ a primordial pool has actually been defined, see <URC_WorthWSTOA>'s \
            \ own doc for the crash this closes."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-SWP:module{SwapperV4} SWP)
                (ids:object{OuronetDalosV2.CanonicalStoaIds} (ref-DALOS::UR_CanonicalStoaIds))
                (wstoa:string (at "wrapped-stoa-id" ids))
                (sstoa:string (at "silver-stoa-id" ids))
                (ouro:string (at "gas-source-id" ids))
            )
            (if (= id wstoa)
                amount
                (if (= id sstoa)
                    (let
                        (
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                            (index-value:decimal (URC_SingleSSTOAWorthWSTOA))
                            (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                        )
                        (floor (* amount index-value) sstoa-prec)
                    )
                    (if (and (= id ouro) (!= (ref-SWP::UR_PrimordialPool) BAR))
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ouro-worth-per-unit:decimal (URC_SingleOuroWorthWSTOA ouro wstoa))
                                (ouro-prec:integer (ref-DPTF::UR_Decimals ouro))
                            )
                            (floor (* amount ouro-worth-per-unit) ouro-prec)
                        )
                        ;;#73C fix: price ONE unit, scale linearly — see URC_WorthWSTOA's
                        ;;own comment on this same branch for the full rationale.
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (h-obj:object{SwapperIssueV4.Hopper} (URC_HopperFromRaw id wstoa 1.0 raw-graph))
                                (ovs:[decimal] (at "output-values" h-obj))
                                (per-unit-worth:decimal (if (= (length ovs) 0) 0.0 (at 0 (take -1 ovs))))
                                (id-prec:integer (ref-DPTF::UR_Decimals id))
                            )
                            (floor (* amount per-unit-worth) id-prec)
                        )
                    )
                )
            )
        )
    )
    (defun URC_WorthWSTOAFromGraph (id:string amount:decimal graph:[object{BreadthFirstSearchV2.GraphNode}])
        @doc "#65bL Phase 7 fix: <URC_WorthWSTOA>, sourcing any graph search it needs \
            \ via an ALREADY-BUILT <graph> (<URC_HopperFromGraph>) instead of \
            \ rebuilding it from <raw-graph> per call — see \
            \ <URCx_HopperFromGraph>'s own doc for the full rationale (repricing- \
            \ loop graph-build sharing). The WSTOA/SSTOA short-circuit branches never \
            \ needed a graph search to begin with and stay unchanged. \
            \ #65fL Phase 8b fix: added the same id==OURO short-circuit \
            \ <URC_WorthWSTOA> gained (URC_SingleOuroWorthWSTOA) — also never needed a \
            \ graph search. Same pre-bootstrap safety guard too: only fires when \
            \ a primordial pool has actually been defined, see <URC_WorthWSTOA>'s \
            \ own doc for the crash this closes."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-SWP:module{SwapperV4} SWP)
                (ids:object{OuronetDalosV2.CanonicalStoaIds} (ref-DALOS::UR_CanonicalStoaIds))
                (wstoa:string (at "wrapped-stoa-id" ids))
                (sstoa:string (at "silver-stoa-id" ids))
                (ouro:string (at "gas-source-id" ids))
            )
            (if (= id wstoa)
                amount
                (if (= id sstoa)
                    (let
                        (
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                            (index-value:decimal (URC_SingleSSTOAWorthWSTOA))
                            (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                        )
                        (floor (* amount index-value) sstoa-prec)
                    )
                    (if (and (= id ouro) (!= (ref-SWP::UR_PrimordialPool) BAR))
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ouro-worth-per-unit:decimal (URC_SingleOuroWorthWSTOA ouro wstoa))
                                (ouro-prec:integer (ref-DPTF::UR_Decimals ouro))
                            )
                            (floor (* amount ouro-worth-per-unit) ouro-prec)
                        )
                        ;;#73C fix: price ONE unit, scale linearly — see URC_WorthWSTOA's
                        ;;own comment on this same branch for the full rationale.
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (h-obj:object{SwapperIssueV4.Hopper} (URC_HopperFromGraph id wstoa 1.0 graph))
                                (ovs:[decimal] (at "output-values" h-obj))
                                (per-unit-worth:decimal (if (= (length ovs) 0) 0.0 (at 0 (take -1 ovs))))
                                (id-prec:integer (ref-DPTF::UR_Decimals id))
                            )
                            (floor (* amount per-unit-worth) id-prec)
                        )
                    )
                )
            )
        )
    )
    (defun URC_PoolValue:[decimal] (swpair:string)
        @doc "Outputs the Pool Value in WSTOA. \
            \ If the Pool is empty, even though its value is technically zero, \
            \ The Value of the Genesis Initiation is outputed \
            \ PoolValue includes two decimal values: \
            \ 1st Value: Total Value of the Pool in WSTOA \
            \ 2nd Value: Value of 1 LP Token in WSTOA"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (lp-supply:decimal
                    (if (= current-lp-supply 0.0)
                        10000000.0
                        current-lp-supply
                    )
                )
                (pool-token-supplies:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (w:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_GenesisWeigths swpair)
                        (ref-SWP::UR_Weigths swpair)
                    )
                )
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (how-many:integer (length pool-tokens))
                (lp-prec:integer (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair)))
                ;;
                (first-token:string (at 0 pool-tokens))
                (first-token-supply:decimal (at 0 pool-token-supplies))
                (first-token-precision:integer (ref-DPTF::UR_Decimals first-token))
                (first-weigth:decimal (at 0 w))
                (first-worth:decimal (URC_WorthWSTOA first-token first-token-supply))
                ;;
                (pool-worth:decimal
                    (if (or (= pool-type "S") (= pool-type "P"))
                        (floor (* (dec how-many) first-worth) first-token-precision)
                        (floor (/ first-worth first-weigth) first-token-precision)
                    )
                )
                (lp-worth:decimal
                    (floor (/ pool-worth lp-supply) lp-prec)
                )
            )
            [pool-worth lp-worth]
        )
    )
    (defun URC_PoolValueFromRaw:[decimal] (swpair:string raw-graph:[object{SwapTracerV3.RawGraphNode}])
        @doc "#65bL Phase 4 fix: <URC_PoolValue>, sourcing its <URC_WorthWSTOA> call via \
            \ an ALREADY-FETCHED <raw-graph> (<URC_WorthWSTOAFromRaw>) instead of a \
            \ fresh self-fetch. Built for the STOA-repricing loop \
            \ (TS01-C3::SWP|CC_SmartSwap{With,No}Slippage, one URC_PoolValue call per \
            \ distinct pool a self-searching swap touched) — every call in that loop \
            \ now shares ONE raw-graph fetch instead of each one independently \
            \ re-reading and rebuilding the whole graph, same shape of win Phase 2 \
            \ already proved for a single Hopper call's own best-of-3 attempts, \
            \ extended here across the WHOLE loop's separate calls. Everything else \
            \ (genesis-vs-live supply/weight selection, pool-worth/lp-worth formulas) \
            \ is byte-for-byte identical to <URC_PoolValue> — only the one \
            \ <first-worth> line changes."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (lp-supply:decimal
                    (if (= current-lp-supply 0.0)
                        10000000.0
                        current-lp-supply
                    )
                )
                (pool-token-supplies:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (w:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_GenesisWeigths swpair)
                        (ref-SWP::UR_Weigths swpair)
                    )
                )
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (how-many:integer (length pool-tokens))
                (lp-prec:integer (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair)))
                ;;
                (first-token:string (at 0 pool-tokens))
                (first-token-supply:decimal (at 0 pool-token-supplies))
                (first-token-precision:integer (ref-DPTF::UR_Decimals first-token))
                (first-weigth:decimal (at 0 w))
                (first-worth:decimal (URC_WorthWSTOAFromRaw first-token first-token-supply raw-graph))
                ;;
                (pool-worth:decimal
                    (if (or (= pool-type "S") (= pool-type "P"))
                        (floor (* (dec how-many) first-worth) first-token-precision)
                        (floor (/ first-worth first-weigth) first-token-precision)
                    )
                )
                (lp-worth:decimal
                    (floor (/ pool-worth lp-supply) lp-prec)
                )
            )
            [pool-worth lp-worth]
        )
    )
    (defun URC_PoolValueFromGraph:[decimal] (swpair:string graph:[object{BreadthFirstSearchV2.GraphNode}])
        @doc "#65bL Phase 7 fix: <URC_PoolValue>, sourcing its <URC_WorthWSTOA> call via \
            \ an ALREADY-BUILT <graph> (<URC_WorthWSTOAFromGraph>) instead of \
            \ rebuilding it from <raw-graph> per call. Built for the STOA-repricing \
            \ loop (TS01-C3::SWP|CC_SmartSwap{With,No}Slippage) — every call in that \
            \ loop already shared ONE raw-graph fetch (Phase 4); this shares the \
            \ downstream graph-BUILD too (SWPT::UC_MakeGraphFromRaw, a linear scan \
            \ per node in the whole topology, previously rebuilt identically on \
            \ every one of the loop's N distinct-first-token queries despite always \
            \ producing byte-identical output for the same <raw-graph>/<swpairs> \
            \ universe). Everything else (genesis-vs-live supply/weight selection, \
            \ pool-worth/lp-worth formulas) is byte-for-byte identical to \
            \ <URC_PoolValue>/<URC_PoolValueFromRaw> — only the one <first-worth> \
            \ line changes."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (lp-supply:decimal
                    (if (= current-lp-supply 0.0)
                        10000000.0
                        current-lp-supply
                    )
                )
                (pool-token-supplies:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (w:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_GenesisWeigths swpair)
                        (ref-SWP::UR_Weigths swpair)
                    )
                )
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (how-many:integer (length pool-tokens))
                (lp-prec:integer (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair)))
                ;;
                (first-token:string (at 0 pool-tokens))
                (first-token-supply:decimal (at 0 pool-token-supplies))
                (first-token-precision:integer (ref-DPTF::UR_Decimals first-token))
                (first-weigth:decimal (at 0 w))
                (first-worth:decimal (URC_WorthWSTOAFromGraph first-token first-token-supply graph))
                ;;
                (pool-worth:decimal
                    (if (or (= pool-type "S") (= pool-type "P"))
                        (floor (* (dec how-many) first-worth) first-token-precision)
                        (floor (/ first-worth first-weigth) first-token-precision)
                    )
                )
                (lp-worth:decimal
                    (floor (/ pool-worth lp-supply) lp-prec)
                )
            )
            [pool-worth lp-worth]
        )
    )
    (defun URC_DirectRefillAmounts:[decimal] (swpair:string ids:[string] amounts:[decimal])
        @doc "Refill incomplete amount values with zeros, to create an amount list equal to the <swpair> token number"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (let
                        (
                            (pt:string (at idx pool-tokens))
                            (spt:[integer] (ref-U|LST::UC_Search ids pt))
                            (pos:integer
                                (if (> (length spt) 0)
                                    (at 0 spt)
                                    -1
                                )
                            )
                            (value:decimal
                                (if (= pos -1)
                                    0.0
                                    (at pos amounts)
                                )
                            )
                        )
                        (ref-U|LST::UC_AppL acc value)
                    )
                )
                []
                (enumerate 0 (- (length pool-tokens) 1))
            )
        )
    )
    (defun URC_IndirectRefillAmounts:[decimal] (X:[decimal] positions:[integer] amounts:[decimal])
        @doc "Refill incomplete amount values with zeros, to create an amount equal to the <X> positions number"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (let
                        (
                            (spt:[integer] (ref-U|LST::UC_Search positions idx))
                            (pos:integer
                                (if (> (length spt) 0)
                                    (at 0 spt)
                                    -1
                                )
                            )
                            (value:decimal
                                (if (= pos -1)
                                    0.0
                                    (at pos amounts)
                                )
                            )
                        )
                        (ref-U|LST::UC_AppL acc value)
                    )
                )
                []
                (enumerate 0 (- (length X) 1))
            )
        )
    )
    (defun URC_TrimIdsWithZeroAmounts:[string] (swpair:string input-amounts:[decimal])
        @doc "From a complete list of input amounts, also containing zeroes, \
            \ creates a list of Pool Token IDs for the amounts greater than zero."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (zero-positions:[integer] (ref-U|LST::UC_Search input-amounts 0.0))
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (let
                        (
                            (iz-index-zero:bool (contains idx zero-positions))
                        )
                        (if (not iz-index-zero)
                            (ref-U|LST::UC_AppL
                                acc
                                (at idx pool-tokens)
                            )
                            acc
                        )
                    )
                )
                []
                (enumerate 0 (- (length input-amounts) 1))
            )
        )
    )
    (defun URCi_IssueStoa:decimal ()
        @doc "STOA leg of a SINGLE-TX swap-pair issue. Read-only twin of the <stoa-costs> that \
            \ C_Issue hands to XE_CollectStoa, so the exec and its INFO_ previews are sourced from \
            \ one place and cannot drift. \
            \ NOTE this is deliberately NOT the same figure as the DEFPACT pool-issue path: \
            \ MTX-SWP charges (+ UsagePrice \"dptf\" \"swp\") while this charges \
            \ UC_StoaPrice \"issue-swp-pair\". The two paths really do cost different amounts, and \
            \ all six INFO_SWP|Issue* previews used to quote the MTX figure for both -- over-quoting \
            \ the single-tx path. Mirrors ATS::URCi_IssueStoa. \
            \ Pinned by `Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl <<SWP-ISSUE-INFO>>`."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UC_StoaPrice "issue-swp-pair")
        )
    )
    (defun URC_IssuePoolIgnis:decimal ()
        @doc "The ONE-leg IGNIS total the MULTI-STEP (defpact) pool issuance bills in \
            \ MTX-SWP::MTX|C_Issue step 2. Lives here, beside URCi_Issue, so the preview and the \
            \ exec read the SAME number from the SAME place: MTX-SWP deploys after SWPI, so the \
            \ exec can call down to this, and INFO_SWP|Issue*Pool previews through URCi_IssuePool. \
            \ ADDED 2026-09-14 with the GS-04 repair -- see URCi_IssuePool."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (fold (+) 0.0
                [
                    (ref-IGNIS::UC_IgnisDeter "issue-swp-pair")
                    (ref-IGNIS::UC_IgnisLeg "tier-token-issue")
                    (ref-IGNIS::UC_IgnisLeg "tier-biggest")
                    (ref-IGNIS::UC_IgnisLeg "tier-smallest")
                ]
            )
        )
    )
    (defun URCi_IssuePool:object{IgnisCollectorV3.OutputCumulator}
        (account:string pool-tokens:[object{SwapperV4.PoolTokens}])
        @doc "Cost preview for the MULTI-STEP pool issuance -- MTX-SWP::MTX|C_Issue -- as opposed \
            \ to URCi_Issue below, which previews the SINGLE-TX SWPI::C_Issue. TWO legs, matching \
            \ that step's concat exactly: the folded one-leg total (URC_IssuePoolIgnis) and the \
            \ account->SWP pool-token multi-transfer. \
            \ GS-04 (2026-09-14): the three INFO_SWP|Issue*Pool previews used to route through \
            \ URCi_Issue, which is tuned to the single-tx exec -- FOUR non-transfer legs totalling \
            \ 6158 against the defpact's ONE leg of 5506, an over-quote of 652. The leg COUNT \
            \ mattered independently: UDC_PrimeIgnisCumulator discounts and quarter-splits PER LEG, \
            \ so even equal totals could round apart. The tell was a dead `op-key` parameter, still \
            \ in URCi_Issue's signature and used nowhere in its body -- one reader serving two \
            \ executions that bill differently, the same shape as the red team's RT-A-001. \
            \ Measured, not reasoned about, at modules/DEFPACT-BILLING.repl <<DPB-02>>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (pool-token-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                (pool-token-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (URC_IssuePoolIgnis) SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                    )
                    (ref-TFT::URCi_MultiTransferCumulator
                        pool-token-ids account SWP|SC_NAME pool-token-amounts
                    )
                ]
                []
            )
        )
    )
    (defun URCi_Issue:object{IgnisCollectorV3.OutputCumulator}
        (account:string pool-tokens:[object{SwapperV4.PoolTokens}])
        @doc "Cost preview for the SINGLE-TX C_Issue's IGNIS cumulator (the STOA dptf+swp usage prices are \
            \ billed separately). Five legs, matching C_Issue's concat: \
            \ ico1 = LP-token issue gas (URCi_IssueGas 1 on SWP); \
            \ ico2 = the account->SWP pool-token multi-transfer (EXISTING tokens, real reader); \
            \ ico3 = the genesis LP mint (origin -> biggest on SWP); \
            \ ico4 = the SWP->account LP transfer-out (fresh LP is fee-toggle-off => class-1 \
            \        Simple => smallest); \
            \ ico5 = the flat swp-issue gas. \
            \ ico3/ico4 are reconstructed from XE_IssueLP's FIXED LP invariants (issued via \
            \ XB_IssueFree with fee-toggle off, so a fresh LP always transfers as class 1) rather \
            \ than calling URCi_Mint/URCi_Transfer, because the LP id is a block-hash write product \
            \ that does not exist at preview time. Every trigger reduces to the GLOBAL \
            \ URC_IsVirtualGasZero: URC_IsVirtualGasZeroAbsolutely on a non-gas id is global, \
            \ SWP is not in GAS_EXCEPTION, and <account> is a normal (non-exempt) account. \
            \ Output ([swpair token-lp]) is empty here (write products)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (pool-token-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                (pool-token-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (swp-sc:string SWP|SC_NAME)
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator (ref-DPTF::URCi_IssueGas 1) swp-sc trigger [])
                    (ref-TFT::URCi_MultiTransferCumulator pool-token-ids account swp-sc pool-token-amounts)
                    ;;ico3 — the genesis LP mint. The LP id is a block-hash write product that does
                    ;;not exist at preview time, so we cannot call URCi_Mint on it; we charge the
                    ;;SAME PRICE it would return. This MUST track DPTF|C_Mint: it was a hardcoded
                    ;;"tier-biggest" (5) and silently desynced when C_Mint was re-priced to its real
                    ;;computation (87), leaving the preview 82 BELOW what the exec charges.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "DPTF|C_Mint" "usage") swp-sc trigger [])
                    ;;ico4 — the SWP->account LP transfer-out. A fresh LP is fee-toggle-off, so it
                    ;;always transfers as class-1 Simple = smallest.
                    (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisLeg "tier-smallest") swp-sc trigger [])
                    ;;ico5 — MUST equal what C_Issue bills, which is the DETERRENCE ALONE. Using
                    ;;UC_IgnisPrice here added the op's 35-point component cost to the preview only,
                    ;;overstating it by 35. A preview's job is to equal the exec, not to be the
                    ;;price we think the exec ought to charge.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisDeter "issue-swp-pair") swp-sc trigger [])
                ]
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_SwapData 
        (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (l1:integer (length input-ids))
                (l2:integer (length input-amounts))
                (l3:integer (length pool-tokens))
                (lengths:[integer] [l1 l2])
                (iz-on-pool:bool (ref-SWP::UEV_CheckAgainst input-ids pool-tokens))
                (t1:bool (contains output-id input-ids))
                (t2:bool (contains output-id pool-tokens))
            )
            (ref-U|INT::UEV_UniformList lengths)
            (enforce iz-on-pool "Input Tokens are not part of the pool")
            (enforce (not t1) "Output-ID cannot be within the Input-IDs")
            (enforce t2 "OutputID is not part of Swpair Tokens")
            (enforce (and (>= l2 1) (< l2 l3)) "Incorrect amount of swap Tokens")
        )
    )
    (defun UEV_InverseSwapData 
        (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (output-id:string (at "output-id" rsid))
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (t1:bool (contains input-id pool-tokens))
                (t2:bool (contains output-id pool-tokens))
            )
            (enforce (and t1 t2) "Invalid Pool Tokens")
            (ref-DPTF::UEV_Amount output-id output-amount)
        )
    )
    (defun UEV_Issue
        (account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "#74 note (2026-08-29): deliberately does NOT enforce that <pool-tokens>' \
            \ token IDs are distinct — that protection already exists, composed for \
            \ free, one layer down. Both real issuance paths (this function, via \
            \ XI_IssueWrite's SWPI|C>ISSUE, and MTX-SWP's defpact issuance) collect the \
            \ caller's genesis deposits through the SAME shared XE_IssueWrite chokepoint \
            \ (Fix #22/M5), which calls TFT::C_MultiTransfer — and C_MultiTransfer's own \
            \ U|LST::UC_IzUnique check already rejects a repeated token ID in the \
            \ transfer list ('Unique Items Required, duplicate item found: <id>'), for \
            \ its own unrelated reason (a batched multi-transfer can't sensibly resolve \
            \ two different amounts for the same ID). Confirmed live, not assumed: \
            \ issuing [OURO, OURO, W1] as a nominal 3-token pool reverts cleanly \
            \ (whole-tx atomicity, no partial/orphaned pool state) at \
            \ TFT|C>MULTI-TRANSFER, before this function's own writes ever run. \
            \ Duplicating that check HERE would be pure redundant gas cost for a \
            \ property a composed dependency already guarantees on every real call \
            \ path — the same 'no single non-tier choke point exists, OR one already \
            \ does and it's downstream' reasoning StoicSyntax's `v`-specialization rule \
            \ asks for before adding an intrinsic bounds guard (§6.1) applies in \
            \ reverse here: the choke point already exists, just not in this module."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (fee-precision:integer (ref-U|CT::CT_FEE_PRECISION))
                (principals:[string] (ref-SWP::UR_Principals))
                (l1:integer (length pool-tokens))
                (l2:integer (length weights))
                (ws:decimal (fold (+) 0.0 weights))
                (pt-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                (ptte:[string]
                    (if (= amp -1.0)
                        (drop 1 pt-ids)
                        pt-ids
                    )
                )
                (first-pool-token:string (at 0 pt-ids))
                (iz-principal:bool (contains first-pool-token principals))
                (contains-principals:bool
                    (fold
                        (lambda
                            (acc:bool idx:integer)
                            (or
                                acc
                                (contains (at idx pt-ids) principals)
                            )
                        )
                        false
                        (enumerate 0 (- (length pt-ids) 1))
                    )
                )
            )
            ;;Functions
            (ref-SWP::UEV_PoolFee fee-lp)
            (ref-SWP::UEV_New pt-ids weights amp)
            ;;Mappings
            (map
                (lambda
                    (id:string)
                    (ref-DPTF::CAP_Owner id)
                )
                ptte
            )
            ;;#11C fix: real per-weight enforce — the original computed this exact precision check via
            ;;`=` and discarded the result (same dead-map pattern independently flagged as H5/#23H;
            ;;fixing this map in place closes both, since it's the one place the check lives). Combines
            ;;the precision check with a >=0.1 floor per weight — rules out the 0.0-weight div-by-zero
            ;;this finding is about, matching the floor already enforced for post-issuance reweights
            ;;(SWP|S>WEIGHTS, C7/#8C fix) so issuance and modification agree on the same bound.
            (map
                (lambda
                    (w:decimal)
                    (enforce
                        (fold (and) true [(= (floor w fee-precision) w) (>= w 0.1)])
                        (format "Weight {} must respect fee precision and be at least 0.1" [w])
                    )
                )
                weights
            )

            ;;Enforcements
            (enforce (!= principals [BAR]) "Principals must be defined before a Swap Pair can be issued")
            (enforce (or (= amp -1.0) (>= amp 1.0)) "Invalid amp value")
            (enforce (and (>= l1 2) (<= l1 7)) "2 - 7 Tokens can be used to create a Swap Pair")
            (enforce (= l1 l2) "Number of weigths does not concide with the pool-tokens Number")
            (enforce-one
                "Invalid Weight Values"
                [
                    (enforce (= ws 1.0) "Weights must add to exactly 1.0")
                    (enforce (= ws (dec l1)) "Weights must all be 1.0")
                ]
            )
            ;;Ifs
            ;;On a W or P pool, first Pool Token must be a Principal Token
            (if (= amp -1.0)
                (enforce iz-principal "1st Token is not a Principal")
                true
            )
            ;;#34bM fix: was checking multi-hop BFS connectivity to SSTOA specifically
            ;;(SWPT::URC_Hopper, unbounded hop count, one hardcoded target token) —
            ;;owner's actual design: if a Stable Pool's first Token isn't itself a
            ;;Principal, it must be DIRECTLY pooled (one hop, an existing pool) with
            ;;ANY current Principal — not transitively connected through a chain of
            ;;non-Principal tokens, and not specifically SSTOA. Fixed to check the
            ;;first Token's direct neighbours (SWPT::URC_TokenNeighbours, one hop,
            ;;every existing pool regardless of type) against the full current
            ;;<principals> list.
            (if (and (> amp 0.0) (not contains-principals))
                (let
                    (
                        (ref-SWPT:module{SwapTracerV3} SWPT)
                        (neighbours:[string] (ref-SWPT::URC_TokenNeighbours first-pool-token))
                        (has-principal-neighbour:bool
                            (> (length (filter (lambda (n:string) (contains n principals)) neighbours)) 0)
                        )
                    )
                    (enforce
                        has-principal-neighbour
                        (format "{} is not directly pooled with any Principal token" [first-pool-token])
                    )
                )
                true
            )
            ;;If pool is not a principal pool, its initial liquidity must be worth at least <spawn-limit>
            (if (not p)
                (let
                    (
                        (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                        (pt-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
                        (first-pool-token-amount:decimal (at 0 pt-amounts))
                        (prefix:string (ref-U|SWP::UC_Prefix weights amp))
                        (how-many:integer (length pool-tokens))
                        ;;
                        (first-worth:decimal (URC_WorthWSTOA first-pool-token first-pool-token-amount))
                        (pool-worth-with-input-tokens-in-wstoa:decimal
                            (if (or (= prefix "S") (= prefix "P"))
                                (* (dec how-many) first-worth)
                                (/ first-worth (at 0 weights))
                            )
                        )
                        (spawn-limit:decimal (ref-SWP::UR_SpawnLimit))
                    )
                    (enforce (>= pool-worth-with-input-tokens-in-wstoa spawn-limit) "More liquidity is needed to open a new pool!")
                )
                true
            )
            (format "Validation prior to pool creation executed succesfully {}" ["!"])
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          SWPI|XE>ISSUE-WRITE
    (defun XE_IssueWrite:list
        (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "#36M/M5 fix: forward-module entrypoint holding the ONE shared pool-issuance \
            \ write sequence — mint the LP token, register the pool, transfer pool tokens \
            \ in, mint genesis LP supply, transfer LP out to the account, register the \
            \ swap-tracer graph edge. Both SWPI::C_Issue (this module) and \
            \ MTX-SWP::MTX|C_Issue's Step 3 (a different module, reached via a \
            \ module{SwapperIssueV4} ref) call this instead of each independently \
            \ reimplementing it. \
            \ Returns [swpair token-lp ico-lp ico-transfer-in ico-mint ico-transfer-out] — \
            \ a wider list, not an IgnisCollectorV3.OutputCumulator (this codebase's XE_* \
            \ convention: the forward module's own C_ composes IGNIS, not this function). \
            \ C_Issue aggregates all four sub-cumulators into its own single billed \
            \ response; MTX|C_Issue's Step 3 only needs swpair/token-lp (it already billed \
            \ separately, in its own Step 2, before Step 3 ever runs) and ignores the rest."
        (P|UEV_IMC)
        (with-capability (SWPI|XE>ISSUE-WRITE account pool-tokens fee-lp weights amp p)
            (let
                (
                    (ref-BRD:module{BrandingV2} BRD)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;#21H: SWPT no longer needs a principal list.
                    (ref-SWPT:module{SwapTracerV3} SWPT)
                    (ref-SWP:module{SwapperV4} SWP)
                    (pool-token-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                    (pool-token-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
                    (lp-name-ticker:[string] (ref-SWP::URC_LpComposer pool-tokens weights amp))
                    (ico-lp:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::XE_IssueLP (at 0 lp-name-ticker) (at 1 lp-name-ticker))
                    )
                    (token-lp:string (at 0 (at "output" ico-lp)))
                    (swpair:string (ref-SWP::XE_Issue account pool-tokens token-lp fee-lp weights amp p))
                )
                (ref-BRD::XE_Issue swpair)
                (let
                    (
                        (ico-transfer-in:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_MultiTransfer patron account SWP|SC_NAME pool-token-ids pool-token-amounts true)
                        )
                        (ico-mint:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPTF::C_Mint patron SWP|SC_NAME token-lp GENESIS_LP_SUPPLY true)
                        )
                        (ico-transfer-out:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_Transfer patron SWP|SC_NAME account token-lp GENESIS_LP_SUPPLY true)
                        )
                    )
                    ;;C9 fix (preserved): SWP|LP registration lives inside SWP::XE_Issue
                    ;;itself (called above via <swpair>'s own binding) — not a standalone
                    ;;call either caller needs to remember separately.
                    (ref-SWPT::XE_UpdateGraph swpair)
                    [swpair token-lp ico-lp ico-transfer-in ico-mint ico-transfer-out]
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_RebuildGraph (patron:string executor:string)
        @doc "One-time migration/backfill utility (#21H). Rebuilds SWPT's adjacency \
            \ graph (SwapTracerV3) from every currently-existing swpair \
            \ (SWP::URC_Swpairs()), by calling SWPT::XE_UpdateGraph exactly as normal \
            \ issuance already does — just once per EXISTING pool instead of once for \
            \ a newly-issued one. Lives here rather than in SWPT itself because SWPT \
            \ deploys before SWP in this codebase's deploy order and can't hold a \
            \ compile-time reference to SwapperV4; SWPI already deploys after both and \
            \ is already a legitimate XE_UpdateGraph caller (C_Issue uses the same \
            \ call). XE_UpdateGraph's own writes are idempotent (XI_UpdatePair only \
            \ appends a swpair if not already present), so this is safe to re-run — \
            \ pools issued after this upgrade (which already populate the graph \
            \ directly at issuance) are a no-op here. Intended to be run exactly once \
            \ by an admin immediately after deploying the #21H architecture change, to \
            \ backfill every pool that was issued under the old, now-removed \
            \ principal-keyed SWPT|Tracer storage. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-21). The AUTHORITY is the admin \
            \ key, composed by GOV|SWPI_ADMIN; the executor is the ACTOR among the keyholders, \
            \ proven by CAP_EnforceAccountOwnership. This entrypoint has NO Talos wrapper -- it \
            \ is a one-shot migration an admin invokes directly -- so unlike a Talos A_ it keeps \
            \ its own <patron> rather than being handed GASLESS-PATRON by the blessed path."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (GOV|SWPI_ADMIN)
            ;;XE_UpdateGraph's own P|UEV_IMC checks that P|SWPI|CALLER (the guard SWPI
            ;;registers with SWPT via P|A_Define) is actively composed — true when
            ;;reached via C_Issue's cap chain (SWPI|C>ISSUE -> P|DT), not true by
            ;;default just because this code happens to live in SWPI's module.
            (with-capability (P|SECURE-CALLER)
                (let
                    (
                        (ref-SWP:module{SwapperV4} SWP)
                        (ref-SWPT:module{SwapTracerV3} SWPT)
                    )
                    (map (lambda (sp:string) (ref-SWPT::XE_UpdateGraph sp)) (ref-SWP::URC_Swpairs))
                )
            )
        )
    )
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "Issues a new SWPair (Liquidty Pool). \
            \ #36M/M5 fix: the write sequence itself (mint/transfer/tracker) now lives in \
            \ the shared XE_IssueWrite — MTX-SWP::MTX|C_Issue's own Step 3 calls the same \
            \ function instead of independently reimplementing it. This function still \
            \ owns all of ITS OWN IGNIS billing/aggregation (MTX|C_Issue bills separately, \
            \ in its own Step 2, before Step 3 ever runs). \
            \ \
            \ Executor: ENFORCED INDIRECTLY, and this is the route the canon requires be \
            \ written here rather than left to be rediscovered. SWPI|C>ISSUE does NOT prove \
            \ the executor -- its UEV_Issue is a SHAPE check on the pool, and its admin \
            \ compose is conditional on <p>. The proof is one level down: XE_IssueWrite calls \
            \ TFT::C_MultiTransfer with <executor> in the executor slot, moving the pool \
            \ tokens OUT of that account, and C_MultiTransfer's own @doc records its chain -- \
            \ DPTF|C>MULTI-TRANSFER -> XB_DebitTrueFungible -> DPTF|C>DEBIT -> \
            \ CAP_EnforceAccountOwnership, run once per leg. \
            \ \
            \ It is UNCONDITIONAL because that call is a plain <let> binding, and Pact's <let> \
            \ is EAGER -- the same evaluation rule that is the root cause of the mute-guard \
            \ class elsewhere in this codebase is what makes the proof here unavoidable. If \
            \ that binding is ever moved into a branch, the executor stops being proven on the \
            \ other side of it and this paragraph becomes false. \
            \ (patron/executor canon 2.2; gap found by _modulecomplete check 7 at 16_SWPI's \
            \ own turn, 2026-09-22 -- the executor was added in an earlier module's cascade \
            \ and the route was never written down.)"
        (P|UEV_IMC)
        (with-capability (SWPI|C>ISSUE executor pool-tokens fee-lp weights amp p)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;STOA leg of a swap-pair issue: the SAME DOLLAR VALUE as its IGNIS deter
                    ;;($50 => 500 STOA at the $0.10 peg), via UC_StoaPrice. Replaces the two
                    ;;legacy sub-cent UsagePrice legs ("dptf" + "swp").
                    (stoa-costs:decimal (ref-IGNIS::UC_StoaPrice "issue-swp-pair"))
                    (gas-swp-cost:decimal (ref-IGNIS::UC_IgnisDeter "issue-swp-pair"))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (write-result:list (XE_IssueWrite patron executor pool-tokens fee-lp weights amp p))
                    (swpair:string (at 0 write-result))
                    (token-lp:string (at 1 write-result))
                    (ico1:object{IgnisCollectorV3.OutputCumulator} (at 2 write-result))
                    (ico2:object{IgnisCollectorV3.OutputCumulator} (at 3 write-result))
                    (ico3:object{IgnisCollectorV3.OutputCumulator} (at 4 write-result))
                    (ico4:object{IgnisCollectorV3.OutputCumulator} (at 5 write-result))
                    (ico5:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator gas-swp-cost SWP|SC_NAME trigger [])
                    )
                )
                (ref-IGNIS::XE_CollectStoa patron stoa-costs)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4 ico5] [swpair token-lp])
            )
        )
    )

)

;; ---- source: 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact (module only -- its interface is already live)
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
    (implements AcquisitionAnchorsV1)

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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (deftable ANK|T|Anchor:{AcquisitionSchemasV1.ANK|Schema})                        ;;Key = <Anchor-ID>
    (deftable ANK|T|BoostClass:{AcquisitionSchemasV1.ANK|BoostClass})                ;;Key = <Boost-Class-ID>
    (deftable ANK|T|AssetAnchors:{AcquisitionSchemasV1.ANK|AssetAnchors})            ;;Key = <Asset-ID>
    (deftable ANK|T|BoostClassScoreLinks:{AcquisitionSchemasV1.ANK|BoostClassScoreLinks}) ;;Key = <Boost-Class-ID>
    ;;
    (deftable ANK|T|Anchors:{AcquisitionSchemasV1.ANK|UserSchema})                   ;;Key = <Ouronet-Account> | <Anchor-ID>
    (deftable ANK|T|UserBoost:{AcquisitionSchemasV1.ANK|UserBoostSchema})            ;;Key = <Ouronet-Account> | <Boost-Class-ID>

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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
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
                (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data boost-class-id))
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
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
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
                (ref-DPDC:module{DpdcV2} DPDC)
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
                (ref-DPDC:module{DpdcV2} DPDC)
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
                (ref-DPDC:module{DpdcV2} DPDC)
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
                (ref-DPDC:module{DpdcV2} DPDC)
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
    (defun UDC_ANK|Schema:object{AcquisitionSchemasV1.ANK|Schema}
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
    (defun UDC_BoostClass:object{AcquisitionSchemasV1.ANK|BoostClass}
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
    (defun UDC_EmptyInternalGroup:object{AcquisitionSchemasV1.ANK|InternalGroup} ()
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
    (defun UDC_IG|WithAddedAnchor:object{AcquisitionSchemasV1.ANK|InternalGroup}
        (ig:object{AcquisitionSchemasV1.ANK|InternalGroup} new-anchor-id:string)
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
    (defun UDC_IG|WithRemovedAnchor:object{AcquisitionSchemasV1.ANK|InternalGroup}
        (ig:object{AcquisitionSchemasV1.ANK|InternalGroup} revoked-anchor-id:string)
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
    (defun UDC_BC|WithAddedAnchor:object{AcquisitionSchemasV1.ANK|BoostClass}
        (bc:object{AcquisitionSchemasV1.ANK|BoostClass} new-anchor-id:string)
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
    (defun UDC_BC|WithRemovedAnchor:object{AcquisitionSchemasV1.ANK|BoostClass}
        (bc:object{AcquisitionSchemasV1.ANK|BoostClass} revoked-anchor-id:string)
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
    (defun UDC_AA|PlaceAnchor:object{AcquisitionSchemasV1.ANK|AssetAnchors}
        (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} new-anchor-id:string)
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
                                            (grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (URC_AA|GroupAtSlot aa gi))
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
                            (updated-grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (at 0 result))
                            (slot:integer (at 2 result))
                            (prev-grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (URC_AA|GroupAtSlot aa slot))
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
                            (new-grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (UDC_IG|WithAddedAnchor (UDC_EmptyInternalGroup) new-anchor-id))
                        )
                        (URC_AA|SetGroupAtSlot aa new-grp ga (+ ta 1) ga true)
                    )
                )
            )
        )
    )
    (defun UDC_AA|RemoveAnchor:object{AcquisitionSchemasV1.ANK|AssetAnchors}
        (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} revoked-anchor-id:string)
        @doc "Removes anchor from its group in AssetAnchors."
        (let
            (
                (ga:integer (at "groups-active" aa))
                (ta:integer (at "anchors-active" aa))
                (aid:string (at "asset-id" aa))
            )
            (fold
                (lambda (acc:object{AcquisitionSchemasV1.ANK|AssetAnchors} gi:integer)
                    (let
                        (
                            (grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (URC_AA|GroupAtSlot acc gi))
                        )
                        (if (URC_IG|ContainsAnchor grp revoked-anchor-id)
                            (let
                                (
                                    (updated-grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (UDC_IG|WithRemovedAnchor grp revoked-anchor-id))
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
    (defun UDC_AccountAnchor:object{AcquisitionSchemasV1.ANK|UserSchema}
        (a:decimal b:string c:string)
        @doc "Constructs user-anchor contribution object."
        {"promile"              : a
        ,"ouronet-account"      : b
        ,"anchor-id"            : c}
    )
    (defun UDC_UserBoost:object{AcquisitionSchemasV1.ANK|UserBoostSchema}
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
    (defun UR_ANK|Data:object{AcquisitionSchemasV1.ANK|Schema} (anchor-id:string)
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
    (defun UR_BC|Data:object{AcquisitionSchemasV1.ANK|BoostClass} (boost-class-id:string)
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
    (defun UR_AA|Data:object{AcquisitionSchemasV1.ANK|AssetAnchors} (asset-id:string)
        @doc "Reads full per-asset bookkeeping row (with-default-read when absent)."
        (let
            (
                (eg:object{AcquisitionSchemasV1.ANK|InternalGroup} (UDC_EmptyInternalGroup))
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
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data asset-id))
                (ga:integer (at "groups-active" aa))
            )
            (if (<= ga 0)
                []
                (fold
                    (lambda (acc:[string] gi:integer)
                        (let
                            (
                                (grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (URC_AA|GroupAtSlot aa gi))
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
    (defun UR_ANK-U|Data:object{AcquisitionSchemasV1.ANK|UserSchema} (account:string anchor-id:string)
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
    (defun UR_UB|Data:object{AcquisitionSchemasV1.ANK|UserBoostSchema} (account:string boost-class-id:string)
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
                (ref-DPDC:module{DpdcV2} DPDC)
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
                (ref-DPDC:module{DpdcV2} DPDC)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (unit:decimal (ref-IGNIS::UC_IgnisLeg "tier-small"))
                )
                (* (dec n-live) unit)
            )
        )
    )
    ;; --- AssetAnchors / BoostClass slot helpers (in-memory; UDC_AA|* and XI_2|Recompute*) ---
    (defun URC_BC|AnchorIdAtSlot:string (bc:object{AcquisitionSchemasV1.ANK|BoostClass} idx:integer)
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
    (defun URC_AA|GroupAtSlot:object{AcquisitionSchemasV1.ANK|InternalGroup} (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} idx:integer)
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
    (defun URC_IG|AnchorIdAtSlot:string (ig:object{AcquisitionSchemasV1.ANK|InternalGroup} idx:integer)
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
    (defun URC_IG|ContainsAnchor:bool (ig:object{AcquisitionSchemasV1.ANK|InternalGroup} anchor-id:string)
        @doc "URC: true when InternalGroup contains anchor-id (in-memory scan of seven slots)."
        (or (= anchor-id (at "anchor-primary" ig))
        (or (= anchor-id (at "anchor-secondary" ig))
        (or (= anchor-id (at "anchor-tertiary" ig))
        (or (= anchor-id (at "anchor-quaternary" ig))
        (or (= anchor-id (at "anchor-quinary" ig))
        (or (= anchor-id (at "anchor-senary" ig))
            (= anchor-id (at "anchor-septenary" ig))))))))
    )
    (defun URC_AA|SetGroupAtSlot:object{AcquisitionSchemasV1.ANK|AssetAnchors}
        (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} grp:object{AcquisitionSchemasV1.ANK|InternalGroup} slot:integer ta:integer ga:integer adjust-ga:bool)
        @doc "URC: returns updated AssetAnchors with group replaced at slot (in-memory; used by UDC_AA|PlaceAnchor / RemoveAnchor)."
        (let
            (
                (g1:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 0) grp (at "group-primary" aa)))
                (g2:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 1) grp (at "group-secondary" aa)))
                (g3:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 2) grp (at "group-tertiary" aa)))
                (g4:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 3) grp (at "group-quaternary" aa)))
                (g5:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 4) grp (at "group-quinary" aa)))
                (g6:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 5) grp (at "group-senary" aa)))
                (g7:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 6) grp (at "group-septenary" aa)))
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
    (defun URCi_IssueAnchor:object{IgnisCollectorV3.OutputCumulator} (op-key:string output:[string])
        @doc "IGNIS cost for the 4 anchor-issue ops: a FLAT 500 deterrence for every anchor type \
            \ plus that op's own component cost (owner 2026-09-06). This supersedes the \
            \ 2026-09-05 rule of half the anchored asset's issuance price, which is why the \
            \ caller now passes its TALOS OP KEY (AQP-ANK|C_Issue…Anchor) rather than a deter \
            \ tier — the tier is the same for all four. <output> carries \
            \ anchor-id[+boost-class-id]. Shared by exec and the INFO_* previews."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (* (ref-IGNIS::UC_StoaPrice "anchor") (if acnoi 2.0 1.0))
        ))
    (defun URCi_RevokeAnchor:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "IGNIS cost for C_RevokeAnchor — owner-priced 100 deterrence + its component cost, via the central IG|DETER/IG|COMPONENTS \
            \ map. Shared by exec and the INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "AQP-ANK|C_RevokeAnchor" "revoke-anchor") AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        ))
    (defun URCi_RevokeBoostClass:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "IGNIS cost for C_RevokeBoostClass — owner-priced 500 deterrence + its component cost, via the central IG|DETER/IG|COMPONENTS \
            \ map. Shared by exec and the INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
                (ref-DPDC:module{DpdcV2} DPDC)
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
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
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
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data ank-asset))
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DPDC:module{DpdcV2} DPDC)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data ank-asset))
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
                (ref-DPDC:module{DpdcV2} DPDC)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
        (anchor-id:string row:object{AcquisitionSchemasV1.ANK|Schema})
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
        (boost-class-id:string row:object{AcquisitionSchemasV1.ANK|BoostClass})
        @doc "Insert ANK|T|BoostClass full row (inline issue when acnoi)."
        (require-capability (SECURE))
        (insert ANK|T|BoostClass boost-class-id row)
    )
    (defun WW_BoostClass:string
        (boost-class-id:string row:object{AcquisitionSchemasV1.ANK|BoostClass})
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
        (asset-id:string row:object{AcquisitionSchemasV1.ANK|AssetAnchors})
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
                (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data asset-id))
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
                (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data ank-asset))
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
                        (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data bcid))
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
    (defun XE_UpdateTrueFungibleUserAnchorValues:object{IgnisCollectorV3.OutputCumulator}
        (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Backward (FVT::XI_RefreshTrueFungibleStakeAnchors / C_Sync*): P|UEV_IMC + XI_1|UpdateTrueFungibleUserAnchorValues \
            \ when n_live > 0; IGNIS = ignis|small × n_live (live anchors on dptf-id). \
            \ IGNIS interactor = AQP|SC_NAME (pool vault receiver)."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
    (defun XE_ResyncSemiFungibleUserAnchorValues:object{IgnisCollectorV3.OutputCumulator}
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Backward (AQP::C_SyncCollectableAnchors): rewrite SF promile from full rollup inventory; IGNIS per live anchor."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
    (defun XE_ResyncNonFungibleUserAnchorValues:object{IgnisCollectorV3.OutputCumulator}
        (account:string dpnf-id:string nonces:[integer])
        @doc "Backward (AQP::C_SyncCollectableAnchors): rewrite NF promile from full rollup inventory; IGNIS per live anchor."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
    (defun C_RevokeBoostClass:object{IgnisCollectorV3.OutputCumulator}
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
    (defun C_IssueTrueFungibleAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Issues a DPTF anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPTF executor anchor-name dptf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dptf-amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
    (defun C_IssueSemiFungibleAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Issues a DPSF anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPSF executor anchor-name dpsf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpsf-nonce)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
    (defun C_IssueNonFungibleAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Issues a DPNF trait-anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPNF executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-trait-key dpnf-trait-value)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
    (defun C_IssueNonFungibleSetAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Issues a DPNF set-anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPNF-SET executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-nonce-class)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
    (defun C_RevokeAnchor:object{IgnisCollectorV3.OutputCumulator}
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


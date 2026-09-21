;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 7 of 24
;; This is STEP 7 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-6 must have run first, including the init steps between deploys.
;; 2 source file(s), 212,803 gas measured in the REPL gas model, 179,119 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/17_SWPL.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact
;;
;; TOTAL: 3 interface(s), 2 module(s), 4 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/17_SWPL.pact
;;      interface  SwapperLiquidityV2
;;      module     SWPL
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact
;;      interface  BrandingUsageSecondaryV2
;;      interface  SwapperLiquidityClientV2
;;      module     SWPLC
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/17_SWPL.pact ====================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface SwapperLiquidityV2
    @doc "Exposes Liquidity Functions;"

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
    ;;
    ;;  SCHEMAS
    ;;
    (defschema OutputLP
        primary:decimal
        secondary:decimal
    )
    (defschema LiquiditySplit
        balanced:[decimal]
        asymmetric:[decimal]
    )
    (defschema LiquiditySplitType
        iz-balanced:bool
        iz-asymmetric:bool
    )
    (defschema LiquidityData
        sorted-lq:object{LiquiditySplit}
        sorted-lq-type:object{LiquiditySplitType}
        balanced:decimal
        asymmetric:decimal
        asymmetric-fee:decimal
    )
    (defschema LiquidityComputationData
        li:integer
        pool-type:string
        lp-prec:integer
        current-lp-supply:decimal
        lp-supply:decimal
        pool-token-supplies:[decimal]
    )
    (defschema AsymmetricTax
        tad:decimal                     ;;The value of Token A Deficit
        tad-diff:decimal                ;;Difference between <tad> and Fee Shares
        fuel:decimal                    ;;Token A amount as Fuel
        special:decimal                 ;;Token A amount for Special Targets
        boost:decimal                   ;;Token A amount for Boost
        fuel-to-lp:decimal              ;;Token A amount for Fuel converted to LP amounts
    )
    (defschema CompleteLiquidityAdditionData
        total-input-liquidity:[decimal]
        balanced-liquidity:[decimal]
        asymmetric-liquidity:[decimal]
        asymmetric-deviation:[decimal]
        ;;
        primary-lp:decimal
        secondary-lp:decimal
        ;;
        total-ignis-tax-needed:decimal
        ;;
        gaseous-ignis-fee:decimal
        deficit-ignis-tax:decimal
        special-ignis-tax:decimal
        lqboost-ignis-tax:decimal
        relinquish-lp:decimal
        ;;
        gaseous-text:string
        deficit-text:string
        special-text:string
        lqboost-text:string
        fueling-text:string
        ;;
        clad-op:object{CladOperation}
    )
    (defschema CladOperation
        perfect-ignis-fee:object{IgnisCollectorV3.OutputCumulator}   
                                    ;;Ignis Cumulator for the Operation
                                    ;;Can be used to Collect Fees in Advance
        mt-ids:[string]             ;;IDs the User Moves to swp-sc
        mt-amt:[decimal]            ;;Their Amounts
        lp-mint:bool                ;;True Mints only Primary, false mints both
        bk-ids:[string]             ;;IDs of the special Targets, in case none then BAR
        bk-amt:[decimal]            ;;Amounts for the BulkT, in case none, then 0.0
        ;;
        ppb:[decimal]               ;;Pool Amounts plus balanced-liq
        ppa:[decimal]               ;;Pool Amounts plus all input-lq

    )
    (defschema PoolState
        A:decimal
        F:object{UtilitySwpV2.SwapFeez}
        X:[decimal]
        W:[decimal]
        ;;
        LP:decimal
        FT:[string]
        FTP:[decimal]
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
    (defun UDC_VirtualSwapEngineSwpair:object{UtilitySwpV2.VirtualSwapEngine} (account:string account-liq:[decimal] swpair:string pool-liq:[decimal]))
    (defun UDC_VirtualSwapEngine:object{UtilitySwpV2.VirtualSwapEngine}
        (
            account:string account-liq:[decimal] swpair:string starting-liq:[decimal]
            A:decimal W:[decimal] F:object{UtilitySwpV2.SwapFeez}
        )
    )
    (defun UDC_PoolFees:object{UtilitySwpV2.SwapFeez} (swpair:string))
        ;;
    (defun UDC_OutputLP:object{OutputLP} (a:decimal b:decimal))
    (defun UDC_LiquiditySplit:object{LiquiditySplit} (a:[decimal] b:[decimal]))
    (defun UDC_LiquiditySplitType:object{LiquiditySplitType} (a:bool b:bool))
    (defun UDC_LiquidityData:object{LiquidityData} (a:object{LiquiditySplit} b:object{LiquiditySplitType} c:decimal d:decimal e:decimal))
    (defun UDC_LiquidityComputationData:object{LiquidityComputationData} (a:integer b:string c:integer d:decimal e:decimal f:[decimal]))
    (defun UDC_AsymmetricTax:object{AsymmetricTax} (a:decimal b:decimal c:decimal d:decimal e:decimal f:decimal))
    (defun UDC_CompleteLiquidityAdditionData:object{CompleteLiquidityAdditionData}
        (
            a:[decimal] b:[decimal] c:[decimal] d:[decimal]
            e:decimal f:decimal
            g:decimal
            h:decimal i:decimal j:decimal k:decimal l:decimal
            m:string n:string o:string p:string q:string
            r:object{CladOperation}
        )
    )
    (defun UDC_CladOperation:object{CladOperation} (a:object{IgnisCollectorV3.OutputCumulator} b:[string] c:[decimal] d:bool e:[string] f:[decimal] g:[decimal] h:[decimal]))
    (defun UDC_PoolState:object{PoolState} (a:decimal b:object{UtilitySwpV2.SwapFeez} c:[decimal] d:[decimal] e:decimal f:[string] g:[decimal]))
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    ;;  [UC] Functions
    ;;
    (defun UC_DetermineLiquidity:object{LiquiditySplitType} (input-lqs:object{LiquiditySplit}))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;  [URC] Functions
    ;;
    (defun URC_STOA-PID|LpToIgnis:decimal (swpair:string amount:decimal stoa-pid:decimal))
    (defun URC_STOA-PID|TokenToIgnis (id:string amount:decimal stoa-pid:decimal))
    (defun URC_STOA-PID|CLAD:object{CompleteLiquidityAdditionData}
        (
            account:string swpair:string ld:object{LiquidityData} 
            asymmetric-collection:bool gaseous-collection:bool stoa-pid:decimal
        )
    )
    (defun URC_TokenPrecision (id:string))
    (defun URC_IgnisPrecision ())
        ;;
    (defun URC_LD:object{LiquidityData} (swpair:string input-amounts:[decimal]))
    (defun URC_AsymmetricTax:object{AsymmetricTax} (account:string swpair:string ld:object{LiquidityData}))
    (defun URC_SortLiquidity:object{LiquiditySplit} (swpair:string input-amounts:[decimal]))
        ;;
    ;;#56L fix: renamed to URCv_AreAmountsBalanced (StoicSyntax v1.11.0 'validating'
    ;;specialization) — see the defun's own @doc for the full rationale.
    (defun URCv_AreAmountsBalanced:bool (swpair:string input-amounts:[decimal]))
    (defun URC_BalancedLiquidity:[decimal] (swpair:string input-id:string input-amount:decimal with-validation:bool))
    (defun URC_LpBreakAmounts:[decimal] (swpair:string input-lp-amount:decimal))
    (defun URCv_CustomLpBreakAmounts:[decimal] (swpair:string swpair-pool-token-supplies:[decimal] swpair-lp-supply:decimal input-lp-amount:decimal))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;
    ;;  [UEV] Functions
    ;;
    (defun UEV_Liquidity:[decimal] (swpair:string ld:object{LiquidityData}))
    (defun UEV_BalancedLiquidity (swpair:string input-id:string input-amount:decimal))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    (defun XE_STOA-PID|AddLiquidity (patron:string account:string swpair:string asymmetric-collection:bool gaseous-collection:bool stoa-pid:decimal ld:object{LiquidityData} clad:object{CompleteLiquidityAdditionData}))
    (defun XE_AutonomousSwapManagement (swpair:string))
    ;;{5.7}  User [A/C]

)
;;
(module SWPL GOV
    @doc "Exposes Liquidity Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SwapperLiquidityV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SWPL                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SWPL_ADMIN)))
    (defcap GOV|SWPL_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (master:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
                (g1:guard GOV|MD_SWPL)
                (g2:guard (ref-DALOS::UR_AccountGuard master))
            )
            (enforce-one
                "SWPL Ownership not verified"
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
    (defcap P|SWPL|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SWPL|CALLER))
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
        (with-capability (GOV|SWPL_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SWPL_ADMIN)
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
        (with-capability (GOV|SWPL_ADMIN)
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
        (with-capability (GOV|SWPL_ADMIN)
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
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                ;(ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (mg:guard (create-capability-guard (P|SWPL|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            ;(ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
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
    (defcap SWPL|S>ASYMMETRIC-LQ-GASEOUS-TAX (text:string)
        @doc "ASYMMETRIC-LQ-GASEOUS-TAX \
            \   PURPOSE     Compensates for the LP token deficit arising from asymmetric liquidity additions, \
            \               as determined by the Curve liquidity formula, which calculates excess LP tokens \
            \               compared to a balanced addition. Unlike the Curve approach, which restricts LP minting, \
            \               this tax permits minting but imposes a gas fee in Ignis to offset the deficit. \
            \   CALCULATION The tax is the Ignis equivalent of the LP token deficit (e.g., X LP units), \
            \               computed using the Curve formula based on V-POOL reserves. \
            \               where the V-Pool reserves are: [Pool-Reserves + Balanced Liq Part] from Input Liquidty) \
            \               The LP value is converted to Ignis \
            \   APPLICATION Collected as gas during the liquidity addition transaction, \
            \               subject to Elite Account Gas Discounts (e.g., reduced by Z%). \
            \               This tax maintains pool balance by charging users for excess LP tokens minted"
        @event
        true
    )
    (defcap SWPL|S>ASYMMETRIC-LQ-DEFICIT-TAX (text:string)
        @doc "ASYMMETRIC-LQ-DEFICIT-TAX \
        \   PURPOSE     The Asymmetric Liquidity Deficit Tax mitigates pool imbalance and LP token dilution \
        \               from asymmetric liquidity additions. It targets the difference between \
        \               the deficit (Token A cost to achieve the Asymmetric Break Amounts, ABA) \
        \               and fees (Boost, Fuel, Special), which are computed via virtual swaps. \
        \ \
        \   DEFICIT and ABA Derivationa \
        \               The deficit is the Token A cost to balance an asymmetric input \
        \               (e.g., [0 A, X B, Y C, Z D]) using the Virtual Swap Engine (VSE) \
        \               on the Virtual Pool (V-POOL) (original reserves + balanced liquidity). \
        \               The ABA ([A_aba, B_aba, C_aba, D_aba]) is obtained by calculating \
        \               full LP tokens for the asymmetric addition on V-POOL and removing them, preserving pool ratios. \
        \       VIRTUAL SWAPS \
        \           DIRECT SWAPS \
        \               Convert non-A tokens (e.g., X B → W A) to Token A, with fees (save Fee Values) \
        \              (which are subject to Elite Account Discoutn). No swap if only A is input \
        \           REVERSE|FORWARD SWAPS (For (n-1) non-A ABA tokens (n = pool tokens)) \
        \               Compute A needed for B_aba via reverse swap with fees \
        \               Perform forward swap (Computed A → B_aba, save Fee Values) \
        \               Repeat for C, D, etc \
        \           DEFICIT \
        \               The absolute value of the negative A amount accrued in the virtual swap account \
        \               after all the Forward Virtual Swaps is the TOTAL Deficit \
        \               This value incorporates all the Fees generated by the forward virtual swaps. \
        \               Difference Deficit = Total Deficit minus value of Fees. \
        \       REASONING \
        \               Virtual swaps measure the cost of achieving ABA, using V-POOL for stable ratios \
        \               and incorporating fees to assess damage. \
        \   TAX CALCULATION \
        \       FIXED       50% of the Difference Deficit, flat fee \
        \       VARIABLE    Imbalance cause by asymmetric liquidity (share deviation e.g., W%) \
        \                   capped at 40% Maximum Pool Deviation (which is (n-1)/n given n number of Pool Tokens) \
        \       TOTAL       FIXED + VARIABLE \
        \ \
        \   APPLICATION Collectes as IGNIS to the SWP|SC_NAME Smart Ouronet Account \
        \   SUMMARY     The Deficit Tax, based on Virtual Swaps Computation on V-POOL Data, \
        \               addresses residual damage. ABA is derived by removing LP tokens, \
        \               with deficit accrued from the forward swaps. \
        \               The tax (50% flat + deviation, capped at 40%) ensures fairness and scalability"
        @event
        true
    )
    (defcap SWPL|S>ASYMMETRIC-LQ-FUELING-TAX (text:string)
        @doc "ASYMMETRIC-LQ-FUELING-TAX \
        \   PURPOSE     Enhances LP token value during asymmetric liquidity additions \
        \               by reducing the number of LP tokens minted, counteracting dilution. \
        \               It is based on the Fuel fee computed via virtual swaps, \
        \               as detailed in the Asymmetric Liquidity Deficit Tax documentation \
        \   DERIVATION  Corresponds to the Fuel fee portion from the Virtual Swap Engine (VSE) swaps \
        \               performed on the Virtual Pool (V-POOL) (original reserves + balanced liquidity) \
        \               to achieve the Asymmetric Break Amounts (ABA), \
        \               as detailed in the Asymmetric Liquidity Deficit Tax documentation \
        \   TAC CALCULATION \
        \               The Fee Value computed in pool Tokens, is converted to Token A equivalents using the Pool ratio \
        \               which are then converted to an IGNIS amount value, then to an LP Token Value. \
        \       REASONING \
        \               The Fuel fee, derived from virtual swaps, represents the cost of processing asymmetric inputs. \
        \               Reducing LP minting by this amount preserves LP value, mimicking traditional fueling mechanisms. \
        \ \
        \   APPLICATION Applied by reducing the amount of LP Tokens minted by the calculated amount \
        \   SUMMARY     The Fueling Tax, based on the Fuel fee from VSE swaps on the V-POOL, \
        \               mitigates LP dilution by reducing minted LP tokens (e.g., V LP). \
        \               It leverages the swap process outlined in the Deficit Tax documentation, \
        \               ensuring efficiency and fairness in asymmetric liquidity additions."
        @event
        true
    )
    (defcap SWPL|S>ASYMMETRIC-LQ-SPECIAL-TAX (text:string)
        @doc "ASYMMETRIC-LQ-SPECIAL-TAX \
        \   PURPOSE     Allocates funds to ecosystem targets \
        \               (e.g., governance, incentives) during asymmetric liquidity additions, \
        \               using the Special fee computed via virtual swaps, \
        \               as detailed in the Asymmetric Liquidity Deficit Tax documentation \
        \   DERIVATION  Corresponds to the Special fee portion from the Virtual Swap Engine (VSE) swaps \
        \               performed on the Virtual Pool (V-POOL) (original reserves + balanced liquidity) \
        \               to achieve the Asymmetric Break Amounts (ABA), \
        \               as detailed in the Asymmetric Liquidity Deficit Tax documentation \
        \   TAC CALCULATION \
        \               The Fee Value computed in pool Tokens, is converted to Token A equivalents using the Pool ratio \
        \               which are then converted to an IGNIS amount value \
        \       REASONING \
        \               The Special fee reflects swap processing costs, redirected to support ecosystem functions. \
        \ \
        \   APPLICATION Collected in Ignis and transferred to designated targets via BulkTransfer \
        \   SUMMARY     The Special Tax, based on the Special fee from VSE swaps on the V-POOL, \
        \               supports ecosystem targets (e.g., V Ignis). \
        \               It leverages the Deficit Tax’s swap process, promoting fairness in asymmetric liquidity additions"
        @event
        true
    )
    (defcap SWPL|S>ASYMMETRIC-LQ-LQBOOST-TAX (text:string)
        @doc "ASYMMETRIC-LQ-LQBOOST-TAX \
        \   PURPOSE     Enhances the LiquidIndex of the SSTOA Token, during asymmetric liqudity Additions \
        \               using the Boost fee computed via virtual swaps, \
        \               as detailed in the Asymmetric Liquidity Deficit Tax documentation \
        \   DERIVATION  Corresponds to the Boost fee portion from the Virtual Swap Engine (VSE) swaps \
        \               performed on the Virtual Pool (V-POOL) (original reserves + balanced liquidity) \
        \               to achieve the Asymmetric Break Amounts (ABA), \
        \               as detailed in the Asymmetric Liquidity Deficit Tax documentation \
        \   TAC CALCULATION \
        \               The Fee Value computed in pool Tokens, is converted to Token A equivalents using the Pool ratio \
        \               which are then converted to an IGNIS amount value. \
        \       REASONING \
        \               The Boost fee reflects swap processing costs, redirected to increase the value of SSTOA \
        \   APPLICATION Resulted IGNIS is compressed to OURO, \
        \               which is then further used to fuel the SSTOA-OURO-WSTOA Primal Ouronet Pool, \
        \               while burning an equivalent amount of SSTOA, thus increasing the LiquidIndex \
        \               which further increases SSTOA value in WSTOA \
        \   SUMMARY     The Boost Tax, based on the Boost fee from the VSE Swaps on the V-POOL \
        \               supports the Ouronet Ecosystem by increasing the value of SSTOA in WSTOA \
        \               It leverages the Deficit Tax’s swap process, promoting fairness in asymmetric liquidity additions"
        @event
        true
    )
    (defcap SWPL|S>ADD_ASYMMETRIC-LQ (account:string swpair:string input-amounts:[decimal])
        @doc "Exposes <input-amounts> when they have an asymetric part \
            \ when Liquidity is added from <account> on <swpair>"
        @event
        true
    )
    (defcap SWPL|S>ADD_BALANCED-LQ (account:string swpair:string input-amounts:[decimal])
        @doc "Exposes <input-amounts> when they have a balanced part \
            \ when Liquidity is added from <account> on <swpair>"
        @event
        true
    )
    ;;{C3}  Composed
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
    ;;
    (defun UDC_VirtualSwapEngineSwpair:object{UtilitySwpV2.VirtualSwapEngine}
        (account:string account-liq:[decimal] swpair:string pool-liq:[decimal])
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (A:decimal (ref-SWP::UR_Amplifier swpair))
                (W:[decimal] (ref-SWP::UR_Weigths swpair))
            )
            (UDC_VirtualSwapEngine
                account account-liq swpair pool-liq
                A W (UDC_PoolFees swpair)
            )
        )
    )
    (defun UDC_VirtualSwapEngine:object{UtilitySwpV2.VirtualSwapEngine}
        (
            account:string account-liq:[decimal] swpair:string starting-liq:[decimal]
            A:decimal W:[decimal] F:object{UtilitySwpV2.SwapFeez}
        )
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (zero-lst:[decimal] (make-list (length pool-tokens) 0.0))
            )
            (ref-U|SWP::UDC_VirtualSwapEngine
                pool-tokens
                (ref-SWP::UC_PoolTokenPrecisions swpair)
                account account-liq swpair starting-liq
                A W F
                zero-lst zero-lst zero-lst []
            )
        )
    )
    (defun UDC_PoolFees:object{UtilitySwpV2.SwapFeez} (swpair:string)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (lb:bool (ref-SWP::UR_LiquidBoost))
                (lp-fee:decimal (ref-SWP::UR_FeeLP swpair))
                (special-fee:decimal (ref-SWP::UR_FeeSP swpair))
                (boost-fee:decimal (if lb lp-fee 0.0))
            )
            (ref-U|SWP::UDC_SwapFeez lp-fee special-fee boost-fee)
        )
    )
    (defun UDC_OutputLP:object{SwapperLiquidityV2.OutputLP} (a:decimal b:decimal)
        {"primary"                  : a
        ,"secondary"                : b}
    )
    (defun UDC_LiquiditySplit:object{SwapperLiquidityV2.LiquiditySplit} (a:[decimal] b:[decimal])
        {"balanced"                 : a
        ,"asymmetric"               : b}
    )
    (defun UDC_LiquiditySplitType:object{SwapperLiquidityV2.LiquiditySplitType} (a:bool b:bool)
        {"iz-balanced"              : a
        ,"iz-asymmetric"            : b}
    )
    (defun UDC_LiquidityData:object{SwapperLiquidityV2.LiquidityData}
        (a:object{SwapperLiquidityV2.LiquiditySplit} b:object{SwapperLiquidityV2.LiquiditySplitType} c:decimal d:decimal e:decimal)
        {"sorted-lq"                : a
        ,"sorted-lq-type"           : b
        ,"balanced"                 : c
        ,"asymmetric"               : d
        ,"asymmetric-fee"           : e}
    )
    (defun UDC_LiquidityComputationData:object{SwapperLiquidityV2.LiquidityComputationData}
        (a:integer b:string c:integer d:decimal e:decimal f:[decimal])
        {"li"                       : a
        ,"pool-type"                : b
        ,"lp-prec"                  : c
        ,"current-lp-supply"        : d
        ,"lp-supply"                : e
        ,"pool-token-supplies"      : f}
    )
    (defun UDC_AsymmetricTax:object{SwapperLiquidityV2.AsymmetricTax}
        (a:decimal b:decimal c:decimal d:decimal e:decimal f:decimal)
        {"tad"                      : a
        ,"tad-diff"                 : b
        ,"fuel"                     : c
        ,"special"                  : d
        ,"boost"                    : e
        ,"fuel-to-lp"               : f}
    )
    (defun UDC_CompleteLiquidityAdditionData:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (
            a:[decimal] b:[decimal] c:[decimal] d:[decimal]
            e:decimal f:decimal
            g:decimal
            h:decimal i:decimal j:decimal k:decimal l:decimal
            m:string n:string o:string p:string q:string
            r:object{SwapperLiquidityV2.CladOperation}
        )
        {"total-input-liquidity"    : a
        ,"balanced-liquidity"       : b
        ,"asymmetric-liquidity"     : c
        ,"asymmetric-deviation"     : d
        ;;
        ,"primary-lp"               : e
        ,"secondary-lp"             : f
        ;;
        ,"total-ignis-tax-needed"   : g
        ;;
        ,"gaseous-ignis-fee"        : h
        ,"deficit-ignis-tax"        : i
        ,"special-ignis-tax"        : j
        ,"lqboost-ignis-tax"        : k
        ,"relinquish-lp"            : l
        ;;
        ,"gaseous-text"             : m
        ,"deficit-text"             : n
        ,"special-text"             : o
        ,"lqboost-text"             : p
        ,"fueling-text"             : q
        ;;
        ,"clad-op"                  : r}
    )
    (defun UDC_CladOperation:object{SwapperLiquidityV2.CladOperation}
        (a:object{IgnisCollectorV3.OutputCumulator} b:[string] c:[decimal] d:bool e:[string] f:[decimal] g:[decimal] h:[decimal])
        {"perfect-ignis-fee"        : a
        ;;
        ,"mt-ids"                   : b
        ,"mt-amt"                   : c
        ,"lp-mint"                  : d
        ,"bk-ids"                   : e
        ,"bk-amt"                   : f
        ;;
        ,"ppb"                      : g
        ,"ppa"                      : h}
    )
    (defun UDC_PoolState:object{SwapperLiquidityV2.PoolState}
        (a:decimal b:object{UtilitySwpV2.SwapFeez} c:[decimal] d:[decimal] e:decimal f:[string] g:[decimal])
        {"A"    : a
        ,"F"    : b
        ,"X"    : c
        ,"W"    : d
        ;;
        ,"LP"   : e
        ,"FT"   : f
        ,"FTP"  : g}
    )
    ;;{5.2}  Compute [UC]
    (defun UC_DetermineLiquidity:object{SwapperLiquidityV2.LiquiditySplitType}
        (input-lqs:object{SwapperLiquidityV2.LiquiditySplit})
        (UDC_LiquiditySplitType
            (!= (at "balanced" input-lqs) (make-list (length (at "balanced" input-lqs)) 0.0))
            (!= (at "asymmetric" input-lqs) (make-list (length (at "asymmetric" input-lqs)) 0.0))
        )
    )
    (defun UCx_Step2AsymmetricTaxVirtualSwapper:object{UtilitySwpV2.VirtualSwapEngine}
        (vse:object{UtilitySwpV2.VirtualSwapEngine} first-token-id:string liq-ids:[string] liq-amounts:[decimal])
        (let
            (
                (l1:integer (length liq-ids))
                (l2:integer (length liq-amounts))
            )
            (if (and (= l1 l2) (= l1 0))
                vse
                (let
                    (
                        (ref-U|LST:module{StringProcessorV2} U|LST)
                        (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                        (ref-SWPI:module{SwapperIssueV4} SWPI)
                        ;;
                        ;;Unwrap VSE Object Data for fixed Variables
                        (account:string (at "account" vse))
                        (pool-type:string (ref-U|SWP::UC_PoolType (at "swpair" vse)))
                        (fees:object{UtilitySwpV2.SwapFeez} (at "F" vse))
                        (A:decimal (at "A" vse))
                        (X-prec:[integer] (at "v-prec" vse))
                        (v-tokens:[string] (at "v-tokens" vse))
                        (W:[decimal] (at "W" vse))
                        ;;
                        (vse-single-chain:[object{UtilitySwpV2.VirtualSwapEngine}]
                            (fold
                                (lambda
                                    (acc:[object{UtilitySwpV2.VirtualSwapEngine}] idx:integer)
                                    (let
                                        (
                                            (prev-vse:object{UtilitySwpV2.VirtualSwapEngine} (at 0 acc))
                                            (id:string (at idx liq-ids))
                                            (amount:decimal (at idx liq-amounts))
                                            ;;
                                            ;;Unwrap VSE Object Data for mutable Variables
                                            (X:[decimal] (at "X" prev-vse))
                                            (output-position:integer (at 0 (ref-U|LST::UC_Search v-tokens id)))
                                            ;;
                                            (rsid:object{UtilitySwpV2.ReverseSwapInputData}
                                                (ref-U|SWP::UDC_ReverseSwapInputData
                                                    id amount first-token-id
                                                )
                                            )
                                            (itso:object{UtilitySwpV2.InverseTaxedSwapOutput}
                                                (ref-SWPI::UC_InverseBareboneSwapWithFeez
                                                    account pool-type rsid fees A X X-prec output-position 0 W
                                                )
                                            )
                                            (input-amount:decimal (at "i-id-brutto" itso))
                                            ;;
                                            (dsid:object{UtilitySwpV2.DirectSwapInputData}
                                                (ref-U|SWP::UDC_DirectSwapInputData
                                                    [first-token-id]
                                                    [input-amount]
                                                    id
                                                )
                                            )
                                            (new-vse:object{UtilitySwpV2.VirtualSwapEngine}
                                                (ref-SWPI::UC_VirtualSwap prev-vse dsid)
                                            )
                                        )
                                        (ref-U|LST::UC_ReplaceAt acc 0 new-vse)
                                    )
                                )
                                [vse]
                                (enumerate 0 (- l1 1))
                            )
                        )
                    )
                    (at 0 vse-single-chain)
                )
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_STOA-PID|LpToIgnis:decimal (swpair:string amount:decimal stoa-pid:decimal)
        (let
            (
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (ignis-prec:integer (URC_IgnisPrecision))
                (pool-value:[decimal] (ref-SWPI::URC_PoolValue swpair))
                (lp-value-in-dwk:decimal (at 1 pool-value))
            )
            (floor (fold (*) 100.0 [amount lp-value-in-dwk stoa-pid]) 2)
        )
    )
    (defun URC_STOA-PID|TokenToIgnis (id:string amount:decimal stoa-pid:decimal)
        (let
            (
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (ignis-prec:integer (URC_IgnisPrecision))
                (a-price:decimal (ref-SWPI::URC_TokenDollarPrice id stoa-pid))
            )
            (floor (fold (*) 1.0 [100.0 a-price amount]) ignis-prec)
        )
    )
    (defun URC_STOA-PID|CLAD:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (
            account:string swpair:string ld:object{SwapperLiquidityV2.LiquidityData} 
            asymmetric-collection:bool gaseous-collection:bool stoa-pid:decimal
        )
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (iz-balanced:bool (at "iz-balanced" (at "sorted-lq-type" ld)))
                (iz-asymmetric:bool (at "iz-asymmetric" (at "sorted-lq-type" ld)))
                (balanced-liquidity:[decimal] (at "balanced" (at "sorted-lq" ld)))
                (asymmetric-liquidity:[decimal] (at "asymmetric" (at "sorted-lq" ld)))
                (total-input-liquidity:[decimal] (zip (+) balanced-liquidity asymmetric-liquidity))
                ;;
                (balanced-lp-amount:decimal (at "balanced" ld))
                ;;
                ;;Create <ico-flat>
                (flat-ignis-lq-fee:decimal 1000.0)
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ico-flat:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator flat-ignis-lq-fee SWP|SC_NAME trigger [])
                )
                ;;Initial Transfer IDs and Amounts
                (input-ids-for-transfer:[string]
                    (if (and (not iz-balanced) iz-asymmetric)
                        (ref-SWPI::URC_TrimIdsWithZeroAmounts swpair total-input-liquidity)
                        (ref-SWP::UR_PoolTokens swpair)
                    )
                )
                (input-amounts-for-transfer:[decimal]
                    (if (and (not iz-balanced) iz-asymmetric)
                        (ref-U|LST::UC_RemoveItem total-input-liquidity 0.0)
                        total-input-liquidity
                    )
                )
                ;;General Variables
                (pt-ids:[string] (ref-SWP::UR_PoolTokens swpair))
                (pt-current-amounts:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (pt-amounts-with-balanced:[decimal] 
                    (zip (+) pt-current-amounts balanced-liquidity)
                )
                (pt-amounts-with-asymmetric:[decimal] 
                    (zip (+) pt-amounts-with-balanced asymmetric-liquidity)
                )
            )
            (if iz-asymmetric
                (let
                    (
                        (asymmetric-lp-amount:decimal (at "asymmetric" ld))
                        (asymmetric-lp-fee-amount:decimal (at "asymmetric-fee" ld))
                        (full-asymmetric-deviation:[decimal] (UEV_Liquidity swpair ld))
                        (asymmetric-deviation:decimal (at 0 full-asymmetric-deviation))
                        (computed-gaseous-fee:decimal (URC_STOA-PID|LpToIgnis swpair asymmetric-lp-fee-amount stoa-pid))
                        (raw-gaseous-fee:decimal
                            (if (< computed-gaseous-fee 50.0)
                                50.0
                                (dec (ceiling computed-gaseous-fee))
                            )
                        )
                        (gaseous-ignis-fee:decimal
                            (if gaseous-collection
                                raw-gaseous-fee
                                0.0
                            )
                        )
                        (ico-gaseous:object{IgnisCollectorV3.OutputCumulator}
                            (if gaseous-collection
                                (ref-IGNIS::UDC_ConstructOutputCumulator gaseous-ignis-fee SWP|SC_NAME trigger [])
                                EOC
                            )
                        )
                        (gaseous-text:string
                            (format "~{} LP out of a total ~{} Asym-LP, covered by {} IGNIS (discounted as GAS), as Asym-Liq.-FEE"
                                [(floor asymmetric-lp-fee-amount 4) (floor asymmetric-lp-amount 4) gaseous-ignis-fee]
                            )
                        )
                    )
                    (if asymmetric-collection
                        ;;Asymmetric Liquidity With Asymetric TAX Collection
                        (let
                            (
                                (ref-U|LST:module{StringProcessorV2} U|LST)
                                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                                (ignis-id:string (ref-DALOS::UR_IgnisID))
                                (ignis-prec:integer (ref-DPTF::UR_Decimals ignis-id))
                                (sstoa-id:string (ref-DALOS::UR_SilverStoaID))
                                ;;Compute Asymetric Tax
                                (asymmetric-tax:object{SwapperLiquidityV2.AsymmetricTax} (URC_AsymmetricTax account swpair ld))
                                ;;
                                (a-id:string (at 0 pt-ids))
                                (a-prec:integer (ref-DPTF::UR_Decimals a-id))
                                
                                ;;
                                ;;<ASYMMETRIC-LQ-DEFICIT-TAX>
                                (tad-diff-fillup:decimal (+ asymmetric-deviation 0.5))
                                (tad-diff:decimal (at "tad-diff" asymmetric-tax))
                                (tad-diff-fillup-as-a:decimal (floor (* tad-diff tad-diff-fillup) a-prec))
                                (raw-deficit-ignis-tax:decimal (URC_STOA-PID|TokenToIgnis a-id tad-diff-fillup-as-a stoa-pid))
                                (deficit-ignis-tax:decimal
                                    (if (< raw-deficit-ignis-tax 50.0)
                                        50.0 (ceiling raw-deficit-ignis-tax 2)
                                    )
                                )
                                ;;
                                ;;ASYMMETRIC-LQ-FUELING-TAX
                                (relinquish-lp:decimal (at "fuel-to-lp" asymmetric-tax))
                                ;;
                                ;;ASYMMETRIC-LQ-SPECIAL-TAX
                                (special-as-a:decimal (at "special" asymmetric-tax))
                                (raw-special-ignis-tax:decimal (URC_STOA-PID|TokenToIgnis a-id special-as-a stoa-pid))
                                (special-ignis-tax:decimal
                                    (if (and (> raw-special-ignis-tax 0.0) (< raw-special-ignis-tax 50.0))
                                        50.0 (ceiling raw-special-ignis-tax 2)
                                    )
                                )
                                ;;
                                ;;ASYMMETRIC-LQ-LQBOOST-TAX
                                (boost-as-a:decimal (at "boost" asymmetric-tax))
                                (raw-lqboost-ignis-tax:decimal 
                                    (if (= boost-as-a 0.0)
                                        0.0
                                        (URC_STOA-PID|TokenToIgnis a-id boost-as-a stoa-pid)
                                    )
                                )
                                (lqboost-ignis-tax:decimal
                                    (if (and (> raw-lqboost-ignis-tax 0.0) (< raw-lqboost-ignis-tax 100.0))
                                        100.0 (dec (ceiling raw-lqboost-ignis-tax))
                                    )
                                )
                                ;;Construc ICOz
                                (ignis-swp:decimal (fold (+) 0.0 [deficit-ignis-tax special-ignis-tax lqboost-ignis-tax]))
                                ;;DUPLICATE READ REMOVED 2026-09-13: <ignis-id> is already bound at
                                ;;the top of this same let group, from the identical
                                ;;(ref-DALOS::UR_IgnisID) call, and is consumed there by <ignis-prec>.
                                ;;Rebinding it here shadowed that one for the rest of the group with
                                ;;the same value, at the cost of a second table read on every
                                ;;asymmetric-collection swap -- a transactional path, so real user gas.
                                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                                (secondary-ids-for-transfer:[string] (ref-U|LST::UC_InsertFirst input-ids-for-transfer ignis-id))
                                (secondary-amounts-for-transfer:[decimal] (ref-U|LST::UC_InsertFirst input-amounts-for-transfer ignis-swp))
                                (ico1:object{IgnisCollectorV3.OutputCumulator}
                                    ;;For initial Transfer towards the SWP|SC_NAME of input tokens and ignis (removed Ignis additions as is always zero)
                                    (ref-TFT::URCi_MultiTransferCumulator input-ids-for-transfer account SWP|SC_NAME input-amounts-for-transfer)
                                )
                                (ico2:object{IgnisCollectorV3.OutputCumulator}
                                    ;;For LP Minting (2)
                                    (ref-IGNIS::UDC_LegCumulator "lp-mint" SWP|SC_NAME)
                                )
                                ;;
                                (read-bk-ids:[string] (ref-SWP::UR_SpecialFeeTargets swpair))
                                (bk-ids:[string] (if (= read-bk-ids [BAR]) [BAR] read-bk-ids))
                                (bk-amt:[decimal]
                                    (if (= read-bk-ids [BAR])
                                        [0.0]
                                        (ref-U|SWP::UC_SpecialFeeOutputs
                                            (ref-SWP::UR_SpecialFeeTargetsProportions swpair)
                                            special-ignis-tax
                                            ignis-prec
                                        )
                                    )
                                )
                                ;;Cumulator needed if Liquid Boost is enabled and executed
                                (ico5:object{IgnisCollectorV3.OutputCumulator}
                                    ;;ico3 for IGNIS to special Targets is always zero: removed
                                    ;;Ico4 for IGNIS burn is always zero;removed
                                    ;;Used for the OURO Mint (2)
                                    (ref-IGNIS::UDC_ConstructOutputCumulator 
                                        (ref-IGNIS::UC_IgnisLeg "tier-small") 
                                        SWP|SC_NAME 
                                        (ref-IGNIS::URC_ZeroGAS ouro-id account) []
                                    )
                                )
                                (ico6:object{IgnisCollectorV3.OutputCumulator}
                                    ;;Used for SSTOA Burn (2)
                                    (ref-IGNIS::UDC_ConstructOutputCumulator 
                                        (ref-IGNIS::UC_IgnisLeg "tier-small") 
                                        SWP|SC_NAME 
                                        (ref-IGNIS::URC_ZeroGAS sstoa-id account) []
                                    )
                                )
                                (ico56:object{IgnisCollectorV3.OutputCumulator}
                                    (if (= lqboost-ignis-tax 0.0)
                                        EOC
                                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                            [ico5 ico6] 
                                            []
                                        )
                                    )
                                )
                                (s-ico1:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                        [ico-flat ico-gaseous ico1 ico2 ico56] 
                                        []
                                    )
                                )
                            )
                            (UDC_CompleteLiquidityAdditionData
                                total-input-liquidity
                                balanced-liquidity
                                asymmetric-liquidity
                                full-asymmetric-deviation
                                ;;
                                (- (+ balanced-lp-amount asymmetric-lp-amount) relinquish-lp)
                                0.0
                                ;;
                                (fold (+) 0.0 [deficit-ignis-tax special-ignis-tax lqboost-ignis-tax])
                                ;;
                                gaseous-ignis-fee
                                deficit-ignis-tax
                                special-ignis-tax
                                lqboost-ignis-tax
                                relinquish-lp
                                ;;
                                gaseous-text
                                (format "{} IGNIS costs for a Deviation of ~{}%, as Asym-Liq.-Deficit-TAX"
                                    [deficit-ignis-tax (floor (* 100.0 asymmetric-deviation) 4)]
                                )
                                (if (= special-ignis-tax 0.0)
                                    "Without Asym-Liq.-Special-Tax, as Pool isn't setup up with a special fee"
                                    (format "{} IGNIS credited to Special Targets, as Asym-Liq.-Special-TAX"
                                        [special-ignis-tax]
                                    )
                                )
                                (if (= lqboost-ignis-tax 0.0)
                                    "Without Asym-Liq.LqBoost-TAX, as Global Liquid Boost is disabled"
                                    (format "{} IGNIS fueling SSTOA LiquidIndex, as Asym-Liq.LqBoost-TAX"
                                        [lqboost-ignis-tax]
                                    )
                                )
                                (format "Relinquish ~{} LP increasing LP Value, as Asym-Liq.-Fueling-TAX"
                                    [(floor relinquish-lp 4)]
                                )
                                (UDC_CladOperation
                                    s-ico1
                                    ;;
                                    secondary-ids-for-transfer
                                    secondary-amounts-for-transfer
                                    true
                                    bk-ids
                                    bk-amt
                                    ;;
                                    pt-amounts-with-balanced
                                    pt-amounts-with-asymmetric
                                )
                            )
                        )
                        ;;Asymmetric Liquidity Without Asymetric TAX Collection
                        (UDC_CompleteLiquidityAdditionData
                            total-input-liquidity
                            balanced-liquidity
                            asymmetric-liquidity
                            full-asymmetric-deviation
                            ;;
                            (if gaseous-collection
                                (+ balanced-lp-amount asymmetric-lp-fee-amount)
                                balanced-lp-amount
                            )
                            (if gaseous-collection
                                (- asymmetric-lp-amount asymmetric-lp-fee-amount)
                                asymmetric-lp-amount
                            )
                            ;;
                            0.0
                            ;;
                            gaseous-ignis-fee
                            0.0
                            0.0
                            0.0
                            0.0
                            ;;
                            (if gaseous-collection
                                gaseous-text
                                (format "Credited ~{} LP out of a total ~{} Asym-LP, with no IGNIS Asym-Liq.-Fee"
                                    [(floor asymmetric-lp-fee-amount 4) (floor asymmetric-lp-amount 4)]
                                )
                            )
                            (format "Asymmetric Deviation ~{}%: no Asym-Liq.-Deficit-Tax"
                                [(floor (* 100.0 asymmetric-deviation) 4)]
                            )
                            "Without Asym-Liq.-Special-Tax"
                            "Without Asym-Liq.-LqBoost-Tax"
                            "Without Asym-Liq.-Fueling-Tax"
                            (UDC_CladOperation
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                    [
                                        ico-flat ico-gaseous 
                                        (ref-TFT::URCi_MultiTransferCumulator 
                                            input-ids-for-transfer account SWP|SC_NAME input-amounts-for-transfer
                                        )
                                        (ref-IGNIS::UDC_LegCumulator "lp-mint" SWP|SC_NAME)
                                    ] 
                                    []
                                )
                                ;;
                                input-ids-for-transfer
                                input-amounts-for-transfer
                                false
                                [BAR]
                                [0.0]
                                ;;
                                pt-amounts-with-balanced
                                pt-amounts-with-asymmetric
                            )
                        )
                    )
                )
                (UDC_CompleteLiquidityAdditionData
                    total-input-liquidity
                    balanced-liquidity
                    asymmetric-liquidity
                    [0.0 0.0]
                    ;;
                    balanced-lp-amount
                    0.0
                    ;;
                    0.0
                    ;;
                    0.0
                    0.0
                    0.0
                    0.0
                    0.0
                    ;;
                    (format "Balanced-Liquidity, ({} IGNIS as Asym-Liq.-Fee)" [0.0])
                    (format "Balanced-Liquidity, ({} IGNIS as Asym-Liq.-Deficit-Tax)" [0.0])
                    (format "Balanced-Liquidity, ({} IGNIS as Asym-Liq.-Special-Tax)" [0.0])
                    (format "Balanced-Liquidity, ({} IGNIS as Asym-Liq.-LqBoost-Tax)" [0.0])
                    (format "Balanced-Liquidity, ({} LP relinquished as Asym-Liq.-Fueling-Tax)" [0.0])
                    (UDC_CladOperation
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [
                                ico-flat 
                                (ref-TFT::URCi_MultiTransferCumulator 
                                    input-ids-for-transfer account SWP|SC_NAME input-amounts-for-transfer
                                )
                                (ref-IGNIS::UDC_LegCumulator "lp-mint" SWP|SC_NAME)
                            ] 
                            []
                        )
                        ;;
                        input-ids-for-transfer
                        input-amounts-for-transfer
                        true
                        [BAR]
                        [0.0]
                        ;;
                        pt-amounts-with-balanced
                        pt-amounts-with-asymmetric
                    )
                )
            )
        )
    )
    (defun URC_TokenPrecision (id:string)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::UR_Decimals id)
        )
    )
    (defun URC_IgnisPrecision ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (URC_TokenPrecision (ref-DALOS::UR_IgnisID))
        )
    )
    ;;
    (defun URC_LD:object{SwapperLiquidityV2.LiquidityData} (swpair:string input-amounts:[decimal])
        @doc "Computes the LP amounts, valid for all 3 pool types, outputing a TripleLP object containing: \
        \ 1st Value: A Liquidity Split Object, containing the Liquidity Split \
        \ 2nd Value: The Type of Liquidity existing in the input \
        \ 3rd Value: LP for the Balanced Part \
        \ 4th Value: Full LP for the asymmetric Part \
        \ 5th Value: LP Amount as Liquidity Fee for the asymmetric Part"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (sorted-lq:object{SwapperLiquidityV2.LiquiditySplit} (URC_SortLiquidity swpair input-amounts))
                (sorted-lq-type:object{SwapperLiquidityV2.LiquiditySplitType} (UC_DetermineLiquidity sorted-lq))
                (balanced-lq:[decimal] (at "balanced" sorted-lq))
                (asymmetric-lq:[decimal] (at "asymmetric" sorted-lq))
                (iz-balanced:bool (at "iz-balanced" sorted-lq-type))
                (iz-asymmetric:bool (at "iz-asymmetric" sorted-lq-type))
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
                (lcd:object{SwapperLiquidityV2.LiquidityComputationData}
                    (UDC_LiquidityComputationData
                        (length input-amounts)
                        (ref-U|SWP::UC_PoolType swpair)
                        (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair))
                        current-lp-supply
                        lp-supply
                        pool-token-supplies
                    )
                )
                ;;Balanced Liq Computation
                (x:decimal 
                    (if iz-balanced
                        (URCx_BalancedLP lcd balanced-lq)
                        0.0
                    )
                )
                ;;asymmetric Liq Computation
                (y-with-z:[decimal]
                    (if iz-asymmetric
                        (let
                            (
                                (asymmetric-lp:[decimal] (URCx_AsymmetricLP swpair asymmetric-lq lcd))
                                (full-lp:decimal (at 0 asymmetric-lp))
                                (taxd-lp:decimal (at 1 asymmetric-lp))
                            )
                            [full-lp (- full-lp taxd-lp)]
                        )
                        [0.0 0.0]
                    )
                )
            )
            (UDC_LiquidityData
                sorted-lq
                sorted-lq-type
                x
                (at 0 y-with-z)
                (at 1 y-with-z)
            )
        )
    )
    (defun URCx_BalancedLP:decimal (lcd:object{SwapperLiquidityV2.LiquidityComputationData} balanced-lq:[decimal])
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_LP 
                balanced-lq 
                (at "pool-token-supplies" lcd)
                (at "lp-supply" lcd)
                (at "lp-prec" lcd)
            )
        )
    )
    (defun URCx_AsymmetricLP:[decimal] (swpair:string asymmetric-lq:[decimal] lcd:object{SwapperLiquidityV2.LiquidityComputationData})
        @doc "Computes the Full LP (at 0) and Reduced LP (at 1) from Liquidity Fee for asymmetric-liquidity"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|VST:module{UtilityVstV2} U|VST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (li:integer (at "li" lcd))
                (pool-type:string (at "pool-type" lcd))
                (lp-prec:integer (at "lp-prec" lcd))
                (current-lp-supply:decimal (at "current-lp-supply" lcd))
                (lp-supply:decimal (at "lp-supply" lcd))
                (pool-token-supplies:[decimal] (at "pool-token-supplies" lcd))
                ;;
                ;;Compute Full LP for asymmetric Liq
                (percent-lst:[decimal]
                    (if (= pool-type "W")
                        (if (= current-lp-supply 0.0)
                            (ref-SWP::UR_GenesisWeigths swpair)
                            (ref-SWP::UR_Weigths swpair)
                        )
                        (ref-U|VST::UCv_SplitBalanceForVesting 24 1.0 li)
                    )
                )
                (lp-amounts:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL 
                                acc 
                                (floor 
                                    (fold (*) 1.0 [(/ (at idx asymmetric-lq) (at idx pool-token-supplies)) (at idx percent-lst) lp-supply]) 
                                    lp-prec
                                )
                            )
                        )
                        []
                        (enumerate 0 (- li 1))
                    )
                )
                (full-asymmetric-lp:decimal (fold (+) 0.0 lp-amounts))
                ;;Compute Taxed LP for asymmetric Liq
                (liquidity-fee:decimal (/ (ref-SWP::URC_LiquidityFee swpair) 1000.0))
                (amp:decimal (ref-SWP::UR_Amplifier swpair))
                (new-balances:[decimal] (zip (+) pool-token-supplies asymmetric-lq))
                (d0:decimal
                    (if (= pool-type "S")
                        (ref-U|SWP::UC_ComputeD amp pool-token-supplies)
                        5040000.0
                    )
                )
                (d1:decimal
                    (if (= pool-type "S")
                        (ref-U|SWP::UC_ComputeD amp new-balances)
                        (+ 5040000.0 (URC_D1forWP swpair pool-token-supplies asymmetric-lq))
                    )
                )
                (dr:decimal (floor (/ d0 d1) 24))
                (Xp:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                (adjusted-balances:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (- 
                                    (at idx new-balances) 
                                    (floor 
                                        (* 
                                            (abs 
                                                (- 
                                                    (at idx new-balances) 
                                                    (floor 
                                                        (* 
                                                            (at idx pool-token-supplies)
                                                            dr
                                                        ) 
                                                        (at idx Xp)
                                                    )
                                                )
                                            )
                                            liquidity-fee
                                        )
                                        (at idx Xp)
                                    )
                                )
                            )
                        )
                        []
                        (enumerate 0 (- li 1))
                    )
                )
                (taxed-asymmetric-lp:decimal
                    (floor 
                        (/ 
                            (* 
                                (-
                                    (if (= pool-type "S")
                                        (ref-U|SWP::UC_ComputeD amp adjusted-balances) 
                                        (URC_D1forWP swpair pool-token-supplies adjusted-balances)
                                    )
                                    d0
                                ) 
                                lp-supply
                            ) 
                            d0
                        ) 
                        lp-prec
                    )
                )
            )
            [full-asymmetric-lp taxed-asymmetric-lp]
        )
    )
    (defun URC_D1forWP:decimal (swpair:string current:[decimal] input:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (how-many:decimal (dec (length current)))
                (weigths:[decimal] (ref-SWP::UR_Weigths swpair))
                (vpt:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL 
                                acc 
                                (floor 
                                    (/ 
                                        (if (= pool-type "P")
                                            (/ 5040000.0 how-many)
                                            (* 5040000.0 (at idx weigths))
                                        )
                                        (at idx current)
                                    ) 
                                    24
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length current) 1))
                    )
                )
                (input-values:[decimal] (zip (lambda (x:decimal y:decimal) (* x y)) input vpt))
            )
            (fold (+) 0.0 input-values)
        )
    )
    (defun URC_AsymmetricTax:object{SwapperLiquidityV2.AsymmetricTax}
        (account:string swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                ;;Unwrap Object Data
                (iz-balanced:bool (at "iz-balanced" (at "sorted-lq-type" ld)))
                (iz-asymmetric:bool (at "iz-asymmetric" (at "sorted-lq-type" ld)))
            )
            (if (and iz-balanced (not iz-asymmetric))
                (UDC_AsymmetricTax 0.0 0.0 0.0 0.0 0.0 0.0)
                (let
                    (
                        (balanced-liquidity:[decimal] (at "balanced" (at "sorted-lq" ld)))
                        (asymmetric-liquidity:[decimal] (at "asymmetric" (at "sorted-lq" ld)))
                        (total-input-liqudity:[decimal] 
                            (zip (+) balanced-liquidity asymmetric-liquidity)
                        )
                        (balanced-lp-amount:decimal (at "balanced" ld))
                        (asymmetric-lp-amount:decimal (at "asymmetric" ld))
                        (asymmetric-lp-fee-amount:decimal (at "asymmetric-fee" ld))
                        (lp-amount:decimal (+ balanced-lp-amount asymmetric-lp-amount))
                        ;;
                        ;;
                        ;;Get Data to Construct the Virtual Swapper and the Values to compute ABA
                        (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                        (first-pt:string (at 0 pool-tokens))
                        (pool-token-supplies:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                        (lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                        ;;
                        (w:[decimal] (ref-SWP::UR_Weigths swpair))
                        (lp-prec:integer (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair)))
                        ;;
                        ;;The Asymetric Break Amounts <aba>
                        ;;<aba> is the Output Liquidity one would get by removing LP made with asymmetric Liquidity
                        ;;These are hypothetical values one would get, if all input Liqudity were to be added into the Pool
                        ;;While minting all the LP generated by it via raw mathematical computation.
                        ;;Against these hypothetical Values the Token A Deficit is calculated, which is the base for the Asymetric Taxes.
                        (pool-token-supplies-for-aba:[decimal]
                            ;; on Pool that has a liqudity equal to <pool-liq> + <input-balanced-lq> + <input-asymmetric-lq>
                            (zip (+) pool-token-supplies total-input-liqudity)
                        )
                        (lp-supply-for-aba:decimal
                            ;; and an LP amount equal to <lp-supply> + <balanced-lp-amount> + <asymmetric-lp-amount>
                            (+ lp-supply lp-amount)
                            ;;<aba> is the base for computing the AsymmetricTax
                        )
                        (aba:[decimal]
                            (URCv_CustomLpBreakAmounts swpair pool-token-supplies-for-aba lp-supply-for-aba asymmetric-lp-amount)
                        )
                        ;;
                        ;;
                        ;;Constructing the Pool Supplies of the Virtual Swapper, and the Virtual Account Starting Liquidity
                        (virtual-pool-token-supplies:[decimal] 
                            ;;<virtual-pool-token-supplies> = <pool-token-supplies> + <balanced-liquidity> when it exists
                            (if iz-balanced
                                (zip (+) pool-token-supplies balanced-liquidity)
                                pool-token-supplies
                            )
                        )
                        (virtual-lp-supply:decimal
                            ;; Used to compute Fuel Shares as LP
                            (if iz-balanced
                                (+ lp-supply balanced-lp-amount)
                                lp-supply
                            )
                        )
                        (first-bonus-amount:decimal (at 0 aba))
                        (fba-filled:[decimal] (ref-SWPI::URC_IndirectRefillAmounts pool-token-supplies [0] [first-bonus-amount]))
                        (account-starting-liq:[decimal]
                            ;;The Liquidity the Virtual Account starts with on the Virtual Swap Engine
                            ;;Equal to the Asymetric Liqudity minus the A amount from ABA
                            (zip (-) asymmetric-liquidity fba-filled)
                        )
                        (vse:object{UtilitySwpV2.VirtualSwapEngine}
                            (UDC_VirtualSwapEngineSwpair 
                                account account-starting-liq
                                swpair virtual-pool-token-supplies
                            )
                        )
                        (a-prec:integer 
                            (at 0 (at "v-prec" vse))
                            ;;Preparing Step 1 of the Virtual Swaps
                            ;;STEP 1.
                            ;;All no-A Tokens on the Virtual Account are swapped in the Virtual Pool to Token A.
                            ;;      This consumes all non token-A in the Virtual Account of the Swap Engine
                            ;;STEP 2.
                            ;;For each non-A Token the Value of Token A is computed with Reverse Swap (with fees) Math,
                            ;;      that would results in its coresponding value in <aba>
                            ;;      the computed A Amount is then forward swapped in the Virtual Swap Engine
                            ;;      this is done sequentially for each positive value of non-A Tokens present in <aba>
                            ;;After the Virtual Swaps are done, 
                            ;;  1)A deficit of Token A would result.
                            ;;      This deficit represents how much more Token A you would have needed to get the <aba> values of non-A Tokens,
                            ;;          if you were to execute natural Swaps in the pool using Token A as input for these Swaps.
                            ;;      Naturally, the amount of Token A present in the <asymmetric-liquidity> counts against the deficit (since you already have it)
                            ;;      And the amount of Token A in the <aba> counts towards the deficit (since you would have gotten it by breaking the <asymmetric-lp-amount>)
                            ;;          Which is why the Token A in the <aba> needs to be subtracted from the Starting Asymmetric Liquidity 
                            ;;          the Virtual Account starts with in the Virtual Swap Engine
                            ;;  2)Various Fees saved by the VSE (Virtual Swap Engine) related to existing POOL Fees
                            ;;      These are the basis for the computed Taxes.
                        )
                        (df-pool-tokens:[string] (drop 1 pool-tokens))
                        (df-asymmetric-liquidity:[decimal] (drop 1 asymmetric-liquidity))
                        (df-asymmetric-liquidity-no-zeroes:[decimal] (ref-U|LST::UC_RemoveItem df-asymmetric-liquidity 0.0))
                        (df-pool-tokens-no-zeroes:[string]
                            (fold
                                (lambda
                                    (acc:[string] idx:integer)
                                    (if (!= (at idx df-asymmetric-liquidity) 0.0)
                                        (ref-U|LST::UC_AppL
                                            acc
                                            (at idx df-pool-tokens)
                                        )
                                        acc
                                    )
                                )
                                []
                                (enumerate 0 (- (length df-pool-tokens) 1))
                            )
                        )
                        (l1:integer (length df-asymmetric-liquidity-no-zeroes))
                        (swap-no1-data:object{UtilitySwpV2.DirectSwapInputData}
                            (ref-U|SWP::UDC_DirectSwapInputData
                                df-pool-tokens-no-zeroes
                                df-asymmetric-liquidity-no-zeroes
                                (at 0 pool-tokens)
                            )
                        )
                        ;;
                        ;;First Virtual Swap
                        (vse1:object{UtilitySwpV2.VirtualSwapEngine}
                            (if (!= l1 0)
                                (ref-SWPI::UC_VirtualSwap vse swap-no1-data)
                                vse
                            )
                        )
                        (vse2:object{UtilitySwpV2.VirtualSwapEngine}
                            (UCx_Step2AsymmetricTaxVirtualSwapper 
                                vse1 first-pt df-pool-tokens (drop 1 aba)
                            )
                        )
                        ;;Get Needed Virtual Swap Values
                        (token-a-deficit:decimal (abs (at 0 (at "account-supply" vse2))))
                        
                        (fuel:[decimal] (at "fuel" vse2))
                        (special:[decimal] (at "special" vse2))
                        (boost:[decimal] (at "boost" vse2))
                        ;;
                        ;;Get Share Values on <virtual-pool-token-supplies>
                        (shares:[decimal] (ref-SWPI::UC_PoolShares virtual-pool-token-supplies w))
                        (a-share:decimal (at 0 shares))
                        (tad-shares:decimal (floor (* token-a-deficit a-share) 24))

                        (fuel-shares:decimal (floor (fold (+) 0.0 (zip (*) fuel shares)) 24))
                        (special-shares:decimal (floor (fold (+) 0.0 (zip (*) special shares)) 24))
                        (boost-shares:decimal (floor (fold (+) 0.0 (zip (*) boost shares)) 24))
                        (fee-shares:decimal (fold (+) 0.0 [fuel-shares special-shares boost-shares]))
                        (diff-shares:decimal (- tad-shares fee-shares))
                        ;;
                        (fuel-as-a:decimal (floor (/ fuel-shares a-share) a-prec))
                        (special-as-a:decimal (floor (/ special-shares a-share) a-prec))
                        (boost-as-a:decimal (floor (/ boost-shares a-share) a-prec))
                        (tad-diff:decimal (- token-a-deficit (fold (+) 0.0 [fuel-as-a special-as-a boost-as-a])))
                        ;;
                        ;;Get Fuel Shares as LP
                        (fuel-to-lp:decimal (floor (/ (* virtual-lp-supply fuel-shares) 5040000.0) lp-prec))
                    )
                    (UDC_AsymmetricTax
                        token-a-deficit
                        tad-diff
                        fuel-as-a
                        special-as-a
                        boost-as-a
                        fuel-to-lp
                    )
                )
            )
        )
    )
    (defun URC_SortLiquidity:object{SwapperLiquidityV2.LiquiditySplit} (swpair:string input-amounts:[decimal])
        @doc "Sorts Liquidity into a balanced part and an asymmetric part"
        (let
            (
                (iz-balanced:bool (URCv_AreAmountsBalanced swpair input-amounts))
            )
            (if iz-balanced
                (UDC_LiquiditySplit
                    input-amounts
                    (make-list (length input-amounts) 0.0)
                )
                (let
                    (
                        (has-zeroes:bool (contains 0.0 input-amounts))
                    )
                    (if has-zeroes
                        (UDC_LiquiditySplit
                            (make-list (length input-amounts) 0.0)
                            input-amounts
                        )
                        (let
                            (
                                (ref-SWP:module{SwapperV4} SWP)
                                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                                (balanced-chain:[decimal]
                                    (fold
                                        (lambda
                                            (acc:[decimal] idx:integer)
                                            (let
                                                (
        
                                                    (input-id:string (at idx pool-tokens))
                                                    (input-amount:decimal (at idx input-amounts))
                                                    (balanced-lq:[decimal] (URC_BalancedLiquidity swpair input-id input-amount false))
                                                    (iz-it-fitting:bool
                                                        (fold
                                                            (lambda
                                                                (acc:bool idxx:integer)
                                                                (let
                                                                    (
                                                                        (element:decimal (at idxx balanced-lq))
                                                                        (iz-smaller:bool (<= element (at idxx input-amounts)))
                                                                    )
                                                                    (and acc iz-smaller)
                                                                )
                                                            )
                                                            true
                                                            (enumerate 0 (- (length balanced-lq) 1))
                                                        )
                                                    )
                                                )
                                                (if iz-it-fitting
                                                    balanced-lq
                                                    acc
                                                )
                                            )
                                        )
                                        []
                                        (enumerate 0 (- (length input-amounts) 1))
                                    )
                                )
                            )
                            (UDC_LiquiditySplit
                                balanced-chain
                                (zip (-) input-amounts balanced-chain)
                            )
                        )
                    )
                )
            )
        )
    )
    ;;
    (defun URCv_AreAmountsBalanced:bool (swpair:string input-amounts:[decimal])
        @doc "Determines if <input-amounts> are balanced according to <swpair>. \
            \ #56L fix: renamed URC_ -> URCv_ (new StoicSyntax v1.11.0 'validating' \
            \ specialization) — both enforces below are intrinsic shape guards on this \
            \ computation itself, not business validation. Traced all 11 real callers \
            \ (SWPL/SWPLC/MTX-SWP/INFO-ONE+) before keeping them here: 8 of 11 pass raw, \
            \ caller-controlled amounts with zero upstream validation, so both checks are \
            \ genuinely reachable, not tautological; and no single non-URC_* choke point \
            \ exists upstream shared by all of them (3 separate modules call in \
            \ directly), so relocating to a UEV_* would mean duplicating the identical \
            \ checks 8 times instead of once, here. Added the missing per-element \
            \ non-negative check — the old sum-only check let a mixed-sign list like \
            \ [-5.0, 10.0] pass clean (sum=5.0>0) despite containing a negative amount; \
            \ matches the equivalent check already correct in UEV_InputsForLP (used by \
            \ the one path -- C_Fuel -- that already validates this properly)."
        (let
            (
                (sum:decimal (fold (+) 0.0 input-amounts))
                (l1:integer (length input-amounts))
            )
            (enforce (> sum 0.0) "At least a single input value must be greater than zero!")
            (map
                (lambda
                    (idx:integer)
                    (enforce (>= (at idx input-amounts) 0.0) "No input amount may be negative")
                )
                (enumerate 0 (- l1 1))
            )
            (let
                (
                    (has-zeroes:bool (contains 0.0 input-amounts))
                )
                (if has-zeroes
                    false
                    (let
                        (
                            (ref-U|LST:module{StringProcessorV2} U|LST)
                            (ref-SWPI:module{SwapperIssueV4} SWPI)
                            (positive-amounts:[decimal] (ref-U|LST::UC_RemoveItem input-amounts 0.0))
                            (positive-ids:[string] (ref-SWPI::URC_TrimIdsWithZeroAmounts swpair input-amounts))
                        )
                        (fold
                            (lambda
                                (acc:bool idx:integer)
                                (let
                                    (
                                        (amount:decimal (at idx positive-amounts))
                                        (id:string (at idx positive-ids))
                                        (computed-balance:[decimal] (URC_BalancedLiquidity swpair id amount false))
                                        (checks:bool (= input-amounts computed-balance))
                                    )
                                    (or acc checks)
                                )
                            )
                            false
                            (enumerate 0 (- (length positive-amounts) 1))

                        )
                    )
                )
            )
        )
    )
    (defun URC_BalancedLiquidity:[decimal] (swpair:string input-id:string input-amount:decimal with-validation:bool)
        @doc "Computes the amounts of Balanced Liquidity from one <input-id> with an <input-amount> on a given <swpair> \
        \ <with-validation> specifies if additional validation should also be executed to validate the inputs."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (input-position:integer (ref-SWP::URv_PoolTokenPosition swpair input-id))
                (input-precision:integer (ref-DPTF::UR_Decimals input-id))
                (X:[decimal]
                    (if (= (ref-SWP::URC_LpCapacity swpair) 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (Xp:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
            )
            (if with-validation
                (UEV_BalancedLiquidity swpair input-id input-amount)
                true
            )
            (ref-U|SWP::UC_BalancedLiquidity input-amount input-position input-precision X Xp)
        )
    )
    (defun URC_LpBreakAmounts:[decimal] (swpair:string input-lp-amount:decimal)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (pool-token-supplies:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
            )
            (URCv_CustomLpBreakAmounts swpair pool-token-supplies lp-supply input-lp-amount)
        )
    )
    (defun URCv_CustomLpBreakAmounts:[decimal]
        (swpair:string swpair-pool-token-supplies:[decimal] swpair-lp-supply:decimal input-lp-amount:decimal)
        @doc "Computes the Pool Token Amounts that result from removing <input-lp-amount> of LP Token \
        \ Using Custom values for PoolTokenSupplies and PoolLPSupply"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-SWP:module{SwapperV4} SWP)
                (ratio:decimal (floor (/ input-lp-amount swpair-lp-supply) 24))
                (pool-token-precisions:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                (l1:integer (length swpair-pool-token-supplies))
                (l2:integer (length pool-token-precisions))
            )
            ;;Validation of inputs
            (enforce 
                (and
                    (<= input-lp-amount swpair-lp-supply)
                    (= l1 l2)
                )
                "Invalid Input Data for Break LP Computation"
            )
            (if (= input-lp-amount swpair-lp-supply)
                swpair-pool-token-supplies
                (fold
                    (lambda
                        (acc:[decimal] idx:integer)
                        (ref-U|LST::UC_AppL
                            acc
                            (floor (* ratio (at idx swpair-pool-token-supplies)) (at idx pool-token-precisions))
                        )
                    )
                    []
                    (enumerate 0 (- (length swpair-pool-token-supplies) 1))
                )
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_Liquidity:[decimal]
        (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
            @doc "Validates the asymmetric Liquidity amount, if it exists within the LD Object. \
            \ Validation means that it doesent produce a Share Deviation \
            \ greater than 40% of the Maximum Pool Deviation \
            \ Maximum Pool Deviation is given by its token Size \
            \ and is given by the formula (n-1)/n \
            \ The Deviation is computed on existing <swpair> liquidity, plus \
            \ any balanced-liq, should it exist within the <ld> \
            \ Outputs the Share deviation <ld> would produce on the <swpair> \
            \ If no asymmetric liq exists within the LD, then outputs zero, as no Deviation would occur"
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                ;;Unwrap Object Data
                (balanced-liquidity:[decimal] (at "balanced" (at "sorted-lq" ld)))
                (asymmetric-liquidity:[decimal] (at "asymmetric" (at "sorted-lq" ld)))
                (iz-balanced:bool (at "iz-balanced" (at "sorted-lq-type" ld)))
                (iz-asymmetric:bool (at "iz-asymmetric" (at "sorted-lq-type" ld)))
                ;;
                ;;Get Data to Construct the Virtual Swapper
                (pool-token-supplies:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (virtual-pool-token-supplies:[decimal] 
                    (if iz-balanced
                        (zip (+) pool-token-supplies balanced-liquidity)
                        pool-token-supplies
                    )
                )
            )
            (if (not iz-asymmetric)
                [0.0 0.0]
                (let
                    (
                        (ref-SWPI:module{SwapperIssueV4} SWPI)
                        ;;
                        (w:[decimal] (ref-SWP::UR_Weigths swpair))
                        (n:decimal (dec (length w)))
                        (max-dev:decimal (floor (* 0.4 (/ (- n 1.0) n)) 24))
                        (dev:decimal (ref-SWPI::UCv_DeviationInValueShares virtual-pool-token-supplies asymmetric-liquidity w))
                    )
                    (enforce (<= dev max-dev) (format "asymmetric Liqudity incurrs {} deviation, which is greater than the maximum allowed deviation of {}" [dev max-dev]))
                    [dev max-dev]
                )
            )
        )
    )
    (defun UEV_BalancedLiquidity (swpair:string input-id:string input-amount:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (iz-on-pool:bool (contains input-id pool-tokens))
            )
            (enforce iz-on-pool (format "Token {} is not part of SWPair {}" [input-id swpair]))
            (ref-DPTF::UEV_Amount input-id input-amount)
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_STOA-PID|AddLiquidity
        (patron:string 
            account:string swpair:string asymmetric-collection:bool gaseous-collection:bool stoa-pid:decimal
            ld:object{SwapperLiquidityV2.LiquidityData} clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        )
        @doc "#59L note: every branch below calls XE_UpdateSupplies (reserve bump) BEFORE \
            \ XI_AddLiqSendAndMint (the actual token transfer-in + LP mint). That ordering \
            \ is only safe because this whole function always executes as one atomic \
            \ unit — never split across a transaction/step boundary. Confirmed for both \
            \ real call shapes: the single-tx SWPLC client paths call this directly \
            \ inside one transaction; MTX-SWP::MTX|C_AddLiquidity's defpact calls it \
            \ entirely within Step 1's own step-with-rollback block (never spanning \
            \ Step 1 and a later step) — a defpact step is itself a single atomic \
            \ transaction, so the same guarantee holds there too. If a future caller \
            \ ever needs to split this function's bump and transfer across two separate \
            \ steps, this ordering would need re-deriving from scratch, not assumed safe."
        (P|UEV_IMC)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (balanced-liquidity:[decimal] (at "balanced" (at "sorted-lq" ld)))
                (asymmetric-liquidity:[decimal] (at "asymmetric" (at "sorted-lq" ld)))
                (iz-balanced:bool (at "iz-balanced" (at "sorted-lq-type" ld)))
                (iz-asymmetric:bool (at "iz-asymmetric" (at "sorted-lq-type" ld)))
                (pt-amounts-with-asymmetric:[decimal] (at "ppa" (at "clad-op" clad)))
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (gw:[decimal] (ref-SWP::UR_GenesisWeigths swpair))
                (read-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (primary-lp-amount:decimal (at "primary-lp" clad))
                (secondary-lp-amount:decimal (at "secondary-lp" clad))
                (lp-mint:bool (at "lp-mint" (at "clad-op" clad)))
                (lp-to-mint:decimal (if lp-mint primary-lp-amount (+ primary-lp-amount secondary-lp-amount)))
            )
            (if iz-asymmetric
                (do
                    (if iz-balanced
                        (with-capability (SWPL|S>ADD_BALANCED-LQ account swpair balanced-liquidity)
                            (with-capability (SWPL|S>ADD_ASYMMETRIC-LQ account swpair asymmetric-liquidity)
                                (ref-SWP::XE_UpdateSupplies swpair pt-amounts-with-asymmetric)
                                (if (= read-lp-supply 0.0)
                                    (ref-SWP::XB_ModifyWeights swpair gw)
                                    true
                                )
                            )
                        )
                        (with-capability (SWPL|S>ADD_ASYMMETRIC-LQ account swpair asymmetric-liquidity)
                            (ref-SWP::XE_UpdateSupplies swpair pt-amounts-with-asymmetric)
                        )
                    )
                    (with-capability (SWPL|S>ASYMMETRIC-LQ-GASEOUS-TAX (at "gaseous-text" clad)) true)
                    (if asymmetric-collection
                        (let
                            (
                                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                                (ref-DALOS:module{OuronetDalosV2} DALOS)
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                                (ref-ORBR:module{OuroborosV2} OUROBOROS)
                                (ref-SWPI:module{SwapperIssueV4} SWPI)
                                ;;
                                (ignis-id:string (ref-DALOS::UR_IgnisID))
                                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                                (sstoa-id:string (ref-DALOS::UR_SilverStoaID))
                                (primordial-swpair:string (ref-SWP::UR_PrimordialPool))
                                (lqboost-ignis-tax:decimal (at "lqboost-ignis-tax" clad))
                                (primordial-supplies:[decimal] (ref-SWP::UR_PoolTokenSupplies primordial-swpair))
                                ;;
                                ;;Computing the LQ Boost Tax
                                ;;
                                (ouro-mint-amount:decimal 
                                    (if (= lqboost-ignis-tax 0.0)
                                        0.0
                                        (at 0 (ref-ORBR::URCv_Compress lqboost-ignis-tax))
                                    )
                                )    
                                (dsid:object{UtilitySwpV2.DirectSwapInputData}
                                    (ref-U|SWP::UDC_DirectSwapInputData
                                        [ouro-id]
                                        [ouro-mint-amount]
                                        sstoa-id
                                    )
                                )
                                (sstoa-burn-amount:decimal 
                                    (if (= lqboost-ignis-tax 0.0)
                                        0.0
                                        (ref-SWPI::URCv_Swap primordial-swpair dsid false)
                                    )
                                )
                                (bk-ids:[string] (at "bk-ids" (at "clad-op" clad)))
                                (bk-amt:[decimal] (at "bk-amt" (at "clad-op" clad)))
                            )
                            (with-capability (SECURE) (XI_AddLiqSendAndMint patron account lp-id lp-to-mint clad))
                            ;;Handle Special Targets
                            (if (!= bk-ids [BAR])
                                (ref-TFT::C_MultiBulkTransfer
                                    patron
                                    SWP|SC_NAME
                                    [bk-ids]
                                    [ignis-id]
                                    [bk-amt]
                                )
                                true
                            )
                            ;;Handle Liquid Boost
                            (if (!= lqboost-ignis-tax 0.0)
                                (do
                                    (ref-DPTF::C_Burn patron SWP|SC_NAME ignis-id lqboost-ignis-tax)
                                    (ref-DPTF::C_Mint patron SWP|SC_NAME ouro-id ouro-mint-amount false)
                                    (ref-DPTF::C_Burn patron SWP|SC_NAME sstoa-id sstoa-burn-amount)
                                    (ref-SWP::XE_UpdateSupplies 
                                        primordial-swpair 
                                        (zip (+) primordial-supplies [(- 0.0 sstoa-burn-amount) ouro-mint-amount 0.0])
                                    )
                                )
                                true
                            )
                            (with-capability (SWPL|S>ASYMMETRIC-LQ-DEFICIT-TAX (at "deficit-text" clad)) true)
                            (with-capability (SWPL|S>ASYMMETRIC-LQ-FUELING-TAX (at "fueling-text" clad)) true)
                            (with-capability (SWPL|S>ASYMMETRIC-LQ-SPECIAL-TAX (at "special-text" clad)) true)
                            (with-capability (SWPL|S>ASYMMETRIC-LQ-LQBOOST-TAX (at "lqboost-text" clad)) true)
                        )
                        (with-capability (SECURE) (XI_AddLiqSendAndMint patron account lp-id lp-to-mint clad))
                    )
                )
                (with-capability (SWPL|S>ADD_BALANCED-LQ account swpair balanced-liquidity)
                    (if (= read-lp-supply 0.0)
                        (ref-SWP::XB_ModifyWeights swpair gw)
                        true
                    )
                    (ref-SWP::XE_UpdateSupplies swpair (at "ppb" (at "clad-op" clad)))
                    (with-capability (SECURE) (XI_AddLiqSendAndMint patron account lp-id lp-to-mint clad))
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_AddLiqSendAndMint 
        (patron:string 
            account:string lp-id:string lp-amount:decimal 
            clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        )
        (require-capability (SECURE))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
            )
            (ref-TFT::C_MultiTransfer
                patron
                account
                SWP|SC_NAME
                (at "mt-ids" (at "clad-op" clad))
                (at "mt-amt" (at "clad-op" clad))
                true
            )
            (ref-DPTF::C_Mint patron SWP|SC_NAME lp-id lp-amount false)
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_AutonomousSwapManagement (swpair:string)
        (P|UEV_IMC)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (pool-worth:decimal (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (inactive-limit:decimal (ref-SWP::UR_InactiveLimit))
            )
            (with-capability (P|SWPL|CALLER)
                (if (< pool-worth inactive-limit)
                    (ref-SWP::XE_CanAddOrSwapToggle swpair false false)
                    (ref-SWP::XE_CanAddOrSwapToggle swpair true false)
                )
            )
        )
    )
    ;;{5.7}  User [A/C]

)

;; --- tables for 17_SWPL.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact ===================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface BrandingUsageSecondaryV2
    @doc "Exposes Branding Functions for True-Fungible LP Tokens \
        \ <entity-pos>: 1 (Native LP), 2 (Freezing LP), 3 (Sleeping LP)"

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
    (defun C_UpdatePendingBrandingLPs:object{IgnisCollectorV3.OutputCumulator} (swpair:string entity-pos:integer logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun C_UpgradeBrandingLPs (patron:string swpair:string entity-pos:integer months:integer))

)
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface SwapperLiquidityClientV2
    @doc "Exposes the Client Functions of Swapper Liquidity"

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
    ;;
    ;;
    ;;  [URC] Functions
    ;;
    (defun URC_EntityPosToID:string (swpair:string entity-pos:integer))
    (defun URCi_UpdatePendingBrandingLPs:object{IgnisCollectorV3.OutputCumulator} (swpair:string entity-pos:integer))
    (defun URCi_UpgradeBrandingLPs:decimal (months:integer))
    (defun URCi_ToggleAddLiquidity:object{IgnisCollectorV3.OutputCumulator} (swpair:string toggle:bool))
    (defun URCi_Fuel:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string input-amounts:[decimal] direct-or-indirect:bool))
    (defun URCi_AddStandardLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddIcedLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddGlacialLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddFrozenLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData} (account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal))
    (defun URCi_AddSleepingLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData} (account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal))
    (defun URCi_AddStandardLiquidity:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddIcedLiquidity:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddGlacialLiquidity:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddFrozenLiquidity:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal))
    (defun URCi_AddSleepingLiquidity:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal))
    (defun URCi_RemoveLiquidity:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string lp-amount:decimal))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;
    ;;  [UEV] Functions
    ;;
    (defun UEV_InputsForLP (swpair:string input-amounts:[decimal]))
    (defun UEV_AddFrozenLiquidity (swpair:string frozen-dptf:string))
    (defun UEV_AddSleepingLiquidity (account:string swpair:string sleeping-dpof:string nonce:integer))
    (defun UEV_AddDormantLiquidity (swpair:string))
    (defun UEV_AddChilledLiquidity (swpair:string ld:object{SwapperLiquidityV2.LiquidityData}))
    (defun UEV_AddLiquidity (swpair:string ld:object{SwapperLiquidityV2.LiquidityData}))
    (defun UEV_RemoveLiquidity (swpair:string lp-amount:decimal))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  []C] Functions
    ;;
    ;;
    (defun C_ToggleAddLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string toggle:bool))
    (defun C_Fuel:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string input-amounts:[decimal] direct-or-indirect:bool validation:bool))
        ;;
    (defun STOA-PID|C_AddStandardLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun STOA-PID|C_AddIcedLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun STOA-PID|C_AddGlacialLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun STOA-PID|C_AddFrozenLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal))
    (defun STOA-PID|C_AddSleepingLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal))
        ;;
    (defun C_RemoveLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string account:string swpair:string lp-amount:decimal))

)
;;
(module SWPLC GOV
    @doc "SWPLC (SwapperLiquidityClientV2 + BrandingUsageSecondaryV2) is the \
        \ liquidity-client module for SWP pools. It exposes C_ entrypoints to add liquidity \
        \ in several modes (standard, iced, glacial, frozen, sleeping) and remove liquidity, \
        \ plus fuel pools and update/upgrade LP-token branding, each with a matching URCi_ \
        \ cost-preview reader that composes IGNIS OutputCumulators. It wires LP-token \
        \ transfers, VST freeze/sleep, and complete-liquidity-addition-data fee handling, \
        \ with UEV_ validators gating each liquidity path."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingUsageSecondaryV2)
    (implements SwapperLiquidityClientV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SWPLC                              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SWPLC_ADMIN)))
    (defcap GOV|SWPLC_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (master:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
                (g1:guard GOV|MD_SWPLC)
                (g2:guard (ref-DALOS::UR_AccountGuard master))
            )
            (enforce-one
                "SWPLC Ownership not verified"
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
    (defcap P|SWPLC|CALLER ()
        true
    )
    (defcap P|SWPLC|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SWPLC|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT ()
        (compose-capability (P|SWPLC|REMOTE-GOV))
        (compose-capability (P|SWPLC|CALLER))
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
        (with-capability (GOV|SWPLC_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SWPLC_ADMIN)
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
        (with-capability (GOV|SWPLC_ADMIN)
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
        (with-capability (GOV|SWPLC_ADMIN)
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
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (ref-P|SWPL:module{OuronetPolicyV2} SWPL)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|SWPLC|CALLER)))
            )
            (ref-P|VST::P|A_Add
                "SWPLC|RemoteSwpGov"
                (create-capability-guard (P|SWPLC|REMOTE-GOV))
            )
            (ref-P|SWP::P|A_Add
                "SWPLC|RemoteSwpGov"
                (create-capability-guard (P|SWPLC|REMOTE-GOV))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
            (ref-P|SWPL::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
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
    (defcap SWPLC|C>UPDATE-BRD (swpair:string)
        @event
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-SWP::CAP_Owner swpair)
            (compose-capability (P|SWPLC|CALLER))
        )
    )
    (defcap SWPLC|C>UPGRADE-BRD (swpair:string)
        @event
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-SWP::CAP_Owner swpair)
            (compose-capability (P|SWPLC|CALLER))
        )
    )
    ;;
    (defcap SWPLC|C>INDIRECT-FUEL
        (account:string swpair:string id-lst:[string] transfer-amount-lst:[decimal])
        @event
        (compose-capability (P|SWPLC|CALLER))
    )
    (defcap SWPLC|C>DIRECT-FUEL
        (account:string swpair:string id-lst:[string] transfer-amount-lst:[decimal])
        @event
        (compose-capability (P|DT))
    )
    ;;
    (defcap SWPLC|C>ADD-STANDARD-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (compose-capability (SWPLC|C>X-ADD-LQ swpair ld))
    )
    (defcap SWPLC|C>ADD-ICED-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (compose-capability (SWPLC|C-ADD-CHILLED-LQ swpair ld))
    )
    (defcap SWPLC|C>ADD-GLACIAL-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (compose-capability (SWPLC|C-ADD-CHILLED-LQ swpair ld))
    )
    (defcap SWPLC|C>ADD-FROZEN-LQ 
        (swpair:string frozen-dptf:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (UEV_AddFrozenLiquidity swpair frozen-dptf)
        (compose-capability (SWPLC|C-ADD-CHILLED-LQ swpair ld))
        (compose-capability (P|SWPLC|REMOTE-GOV))
    )
    (defcap SWPLC|C>ADD-SLEEPING-LQ 
        (account:string swpair:string sleeping-dpof:string nonce:integer ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (UEV_AddSleepingLiquidity account swpair sleeping-dpof nonce)
        (compose-capability (SWPLC|C-ADD-DORMANT-LQ swpair ld))
        (compose-capability (P|SWPLC|REMOTE-GOV))
    )
    (defcap SWPLC|C-ADD-DORMANT-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (UEV_AddDormantLiquidity swpair)
        (compose-capability (SWPLC|C>X-ADD-LQ swpair ld))
    )
    (defcap SWPLC|C-ADD-CHILLED-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (UEV_AddChilledLiquidity swpair ld)
        (compose-capability (SWPLC|C>X-ADD-LQ swpair ld))
    )
    (defcap SWPLC|C>X-ADD-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (UEV_AddLiquidity swpair ld)
        (compose-capability (P|SECURE-CALLER))
        (compose-capability (P|SWPLC|REMOTE-GOV))
    )
    ;;
    (defcap SWPLC|C>REMOVE_LQ (swpair:string lp-amount:decimal)
        @event
        (UEV_RemoveLiquidity swpair lp-amount)
        (compose-capability (P|SECURE-CALLER))
        (compose-capability (P|SWPLC|REMOTE-GOV))
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
    (defun URC_EntityPosToID:string (swpair:string entity-pos:integer)
        @doc "For the LP Branding Functions"
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-U|INT::UEV_PositionalVariable entity-pos 3 "Invalid entity position")
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (lp-id:string (ref-SWP::UR_TokenLP swpair))
                )
                (if (= entity-pos 1)
                    lp-id
                    (if (= entity-pos 2)
                        (ref-DPTF::UR_Frozen lp-id)
                        (ref-DPTF::UR_Sleeping lp-id)
                    )
                )
            )
        )
    )
    ;;
    ;;LP DPTF Branding
    (defun URCi_UpdatePendingBrandingLPs:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string entity-pos:integer)
        @doc "Cost preview for C_UpdatePendingBrandingLPs: the fixed branding cumulator (2.0) \
            \ billed on the entity owner, re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (entity-id:string (URC_EntityPosToID swpair entity-pos))
                (entity-owner:string
                    (if (= entity-pos 3)
                        (ref-DPOF::UR_Konto entity-id)
                        (ref-DPTF::UR_Konto entity-id)
                    )
                )
            )
            (ref-IGNIS::UDC_BrandingCumulator entity-owner 2.0)
        )
    )
    (defun URCi_UpgradeBrandingLPs:decimal (months:integer)
        @doc "STOA cost single-source for C_UpgradeBrandingLPs — months x branding price. \
            \ Pure sibling of the impure XE_UpgradeBranding derivation the exec uses."
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (ref-BRD::URCi_UpgradeBranding months)
        )
    )
    ;;LQ Functions
    (defun URCi_ToggleAddLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string toggle:bool)
        @doc "Cost preview for C_ToggleAddLiquidity: delegates to SWP's add-or-swap toggle \
            \ cost (add-or-swap = true)."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-SWP::URCi_ToggleAddOrSwap swpair toggle true)
        )
    )
    (defun URCi_Fuel:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] direct-or-indirect:bool)
        @doc "Cost preview for C_Fuel: a direct fuel bills the multi-transfer of the non-zero \
            \ input tokens into the pool; an indirect fuel only updates supplies (EOC). The \
            \ XE_UpdateSupplies aggregate write carries no cumulator cost. Re-derived purely."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (has-zeros:bool (contains 0.0 input-amounts))
                (input-ids-for-transfer:[string]
                    (if has-zeros
                        (ref-SWPI::URC_TrimIdsWithZeroAmounts swpair input-amounts)
                        pool-tokens
                    )
                )
                (input-amounts-for-transfer:[decimal]
                    (if has-zeros
                        (ref-U|LST::UC_RemoveItem input-amounts 0.0)
                        input-amounts
                    )
                )
            )
            (if direct-or-indirect
                (ref-TFT::URCi_MultiTransferCumulator input-ids-for-transfer account SWP|SC_NAME input-amounts-for-transfer)
                EOC
            )
        )
    )
    ;;  [URCi] — CLAD readers. SINGLE SOURCE (2026-09-14) for the five add-liquidity shapes.
    ;;  Adding liquidity takes TWO different things from the caller: gas, which travels through the
    ;;  OutputCumulator and lands in <ignis-need>, and an Asymmetric-Liquidity TAX, which is IGNIS
    ;;  moved as PRINCIPAL and never enters a cumulator at all. The CLAD computes both, plus the
    ;;  human wording for each tax leg. These readers exist so the INFO_ layer can DECLARE the tax
    ;;  half without rebuilding the CLAD from scratch -- rebuilding it means restating the two
    ;;  collection flags per variant, and a preview that guesses those flags describes a different
    ;;  operation than the one it prices. Each URCi_Add*Liquidity below now reads its own twin.
    (defun URCi_AddStandardLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "The CLAD behind STOA-PID|C_AddStandardLiquidity: asymmetric-collection ON, \
            \ gaseous-collection ON -- the one add shape that takes an IGNIS tax as PRINCIPAL."
        (let
            (
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
            )
            (ref-SWPL::URC_STOA-PID|CLAD account swpair
                (ref-SWPL::URC_LD swpair input-amounts) true true stoa-pid)
        )
    )
    (defun URCi_AddIcedLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "The CLAD behind STOA-PID|C_AddIcedLiquidity: asymmetric-collection OFF, \
            \ gaseous-collection ON. No asymmetric collection means no IGNIS in <mt-ids> at all."
        (let
            (
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
            )
            (ref-SWPL::URC_STOA-PID|CLAD account swpair
                (ref-SWPL::URC_LD swpair input-amounts) false true stoa-pid)
        )
    )
    (defun URCi_AddGlacialLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "The CLAD behind STOA-PID|C_AddGlacialLiquidity: asymmetric-collection OFF, \
            \ gaseous-collection OFF -- no IGNIS tax and no gaseous LP fee."
        (let
            (
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
            )
            (ref-SWPL::URC_STOA-PID|CLAD account swpair
                (ref-SWPL::URC_LD swpair input-amounts) false false stoa-pid)
        )
    )
    (defun URCi_AddFrozenLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        @doc "The CLAD behind STOA-PID|C_AddFrozenLiquidity. The liquidity vector is built from \
            \ the UNDERLYING token's pool position, and the adder of record is the VST smart \
            \ account (it holds the position while the frozen wrapper is burnt), not <account>. \
            \ Both collection flags OFF."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (dptf:string (ref-DPTF::UR_Frozen frozen-dptf))
            )
            (ref-SWPL::URC_STOA-PID|CLAD (ref-DALOS::GOV|VST|SC_NAME) swpair
                (ref-SWPL::URC_LD swpair
                    (ref-U|SWP::UC_MakeLiquidityList swpair
                        (ref-SWP::URv_PoolTokenPosition swpair dptf) input-amount))
                false false stoa-pid)
        )
    )
    (defun URCi_AddSleepingLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        @doc "The CLAD behind STOA-PID|C_AddSleepingLiquidity. As the frozen twin, but the amount \
            \ is the whole nonce supply rather than a caller-chosen figure. Both collection \
            \ flags ON, so this shape DOES carry the IGNIS asymmetry tax."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (dptf:string (ref-DPOF::UR_Sleeping sleeping-dpof))
            )
            (ref-SWPL::URC_STOA-PID|CLAD (ref-DALOS::GOV|VST|SC_NAME) swpair
                (ref-SWPL::URC_LD swpair
                    (ref-U|SWP::UC_MakeLiquidityList swpair
                        (ref-SWP::URv_PoolTokenPosition swpair dptf)
                        (ref-DPOF::UR_NonceSupply sleeping-dpof nonce)))
                true true stoa-pid)
        )
    )
    (defun URCi_AddStandardLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "Cost preview for STOA-PID|C_AddStandardLiquidity: the CLAD perfect-ignis-fee + the \
            \ SWP->account LP transfer. clad is a pure reader; the add-liquidity + autonomous- \
            \ swap-management writes are free."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (URCi_AddStandardLiquidityClad account swpair input-amounts stoa-pid))
                (native-lp:decimal (at "primary-lp" clad))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;LP churn deterrent (central IG|DETER lp-churn, owner 2026-09-05)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddStandardLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (ref-TFT::URCi_Transfer lp-id SWP|SC_NAME account native-lp)
                ]
                [native-lp]
            )
        )
    )
    (defun URCi_AddIcedLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "Cost preview for STOA-PID|C_AddIcedLiquidity: CLAD fee + native-LP transfer + \
            \ freeze of the secondary (iced) LP to the account."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (URCi_AddIcedLiquidityClad account swpair input-amounts stoa-pid))
                (native-lp:decimal (at "primary-lp" clad))
                (frozen-lp:decimal (at "secondary-lp" clad))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;LP churn deterrent (central IG|DETER lp-churn, owner 2026-09-05)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddIcedLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (ref-TFT::URCi_Transfer lp-id SWP|SC_NAME account native-lp)
                    (ref-VST::URCi_Freeze SWP|SC_NAME account lp-id frozen-lp)
                ]
                [native-lp frozen-lp]
            )
        )
    )
    (defun URCi_AddGlacialLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "Cost preview for STOA-PID|C_AddGlacialLiquidity: CLAD fee + (conditional) native-LP \
            \ transfer + freeze of the secondary (glacial) LP."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (URCi_AddGlacialLiquidityClad account swpair input-amounts stoa-pid))
                (native-lp:decimal (at "primary-lp" clad))
                (frozen-lp:decimal (at "secondary-lp" clad))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;LP churn deterrent (central IG|DETER lp-churn, owner 2026-09-05)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddGlacialLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (if (!= native-lp 0.0)
                        (ref-TFT::URCi_Transfer lp-id SWP|SC_NAME account native-lp)
                        EOC
                    )
                    (ref-VST::URCi_Freeze SWP|SC_NAME account lp-id frozen-lp)
                ]
                [native-lp frozen-lp]
            )
        )
    )
    (defun URCi_AddFrozenLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        @doc "Cost preview for STOA-PID|C_AddFrozenLiquidity: move the frozen DPTF to VST + burn + \
            \ CLAD fee + re-freeze the resulting LP. Uses the frozen-token's underlying position."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (URCi_AddFrozenLiquidityClad account swpair frozen-dptf input-amount stoa-pid))
                (frozen-lp:decimal (at "secondary-lp" clad))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;LP churn deterrent (central IG|DETER lp-churn, owner 2026-09-05)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddFrozenLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    (ref-TFT::URCi_Transfer frozen-dptf account vst-sc input-amount)
                    (ref-DPTF::URCi_Burn frozen-dptf vst-sc)
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (ref-VST::URCi_Freeze SWP|SC_NAME account lp-id frozen-lp)
                ]
                [frozen-lp]
            )
        )
    )
    (defun URCi_AddSleepingLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        @doc "Cost preview for STOA-PID|C_AddSleepingLiquidity: move the sleeping nonce to VST + \
            \ burn + IGNIS-tax transfer + CLAD fee + re-sleep the resulting LP over the remaining \
            \ lock. Uses the sleeping-token's underlying position."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (URCi_AddSleepingLiquidityClad account swpair sleeping-dpof nonce stoa-pid))
                (sleeping-lp:decimal (at "primary-lp" clad))
                ;;
                (release-date:time (at "release-date" (at 0 (ref-DPOF::UR_NonceMetaData sleeping-dpof nonce))))
                (dt:integer (floor (diff-time release-date (at "block-time" (chain-data)))))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;LP churn deterrent (central IG|DETER lp-churn, owner 2026-09-05)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddSleepingLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    (ref-DPOF::URCi_MoveCumulator sleeping-dpof [nonce] false)
                    (ref-DPOF::URCi_Burn sleeping-dpof)
                    (ref-TFT::URCi_Transfer ignis-id account vst-sc (at "total-ignis-tax-needed" clad))
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (ref-VST::URCi_Sleep SWP|SC_NAME account lp-id sleeping-lp dt)
                ]
                [sleeping-lp]
            )
        )
    )
    ;;
    (defun URCi_RemoveLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string lp-amount:decimal)
        @doc "Cost preview for C_RemoveLiquidity: the flat 10$ (1000 IGNIS) removal fee + the \
            \ account->SWP LP transfer + LP burn + SWP->account multi-transfer of the pool tokens \
            \ at current ratio. Output == pt-output-amounts (URC_LpBreakAmounts), purely derived \
            \ (the supply update + autonomous-swap-management writes carry no cumulator cost)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (pool-token-ids:[string] (ref-SWP::UR_PoolTokens swpair))
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (pt-output-amounts:[decimal] (ref-SWPL::URC_LpBreakAmounts swpair lp-amount))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;LP add/remove churn deterrent. PRICE-SOURCE FIX (2026-09-14, owner ruling
                    ;;"make them consistent"): preview and exec disagreed here -- the preview read
                    ;;UC_IgnisPrice "SWP|C_RemoveLiquidity" "lp-churn" (1029.0 = the 1000.0 central
                    ;;deterrent PLUS this op's own 29.0 component) while C_RemoveLiquidity's ico-flat
                    ;;read the BARE UC_IgnisDeter "lp-churn" (1000.0), so every removal was over-quoted
                    ;;by 29.0 raw IGNIS. The disagreement was SIDE-WIDE, not just preview-vs-exec: the
                    ;;five ADD ops bill UC_IgnisPrice on BOTH sides (:546 / :1029 and siblings), so an
                    ;;add paid deter+component while a remove paid deter alone and the 29.0 row sat in
                    ;;the price table billed by nothing. Resolved toward the ADD side and toward
                    ;;UC_IgnisPrice's own contract ("every URCi_* reader should bill through this"):
                    ;;BOTH sides of remove now read UC_IgnisPrice, and the exec at :1333 reads it too.
                    ;;Measured by modules/SWP.repl <<SWP-I25>>.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "SWP|C_RemoveLiquidity" "lp-churn")
                        SWP|SC_NAME trigger [])
                    (ref-TFT::URCi_Transfer lp-id account SWP|SC_NAME lp-amount)
                    (ref-DPTF::URCi_Burn lp-id SWP|SC_NAME)
                    (ref-TFT::URCi_MultiTransferCumulator pool-token-ids SWP|SC_NAME account pt-output-amounts)
                ]
                pt-output-amounts
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_InputsForLP (swpair:string input-amounts:[decimal])
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (l1:integer (length input-amounts))
                (l2:integer (length pool-tokens))
                (sum:decimal (fold (+) 0.0 input-amounts))
            )
            (enforce (= l1 l2) "Invalid input amounts")
            (enforce (>= sum 0.0) "Input amounts Sum must be greater than zero")
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (amount:decimal (at idx input-amounts))
                            (pool-token:string (at idx pool-tokens))
                        )
                        (enforce (>= amount 0.0) "Amounts must be greater or equal to zero")
                        (if (> amount 0.0)
                            (ref-DPTF::UEV_Amount pool-token amount)
                            true
                        )
                    )
                )
                (enumerate 0 (- l1 1))
            )
        )
    )
    (defun UEV_AddFrozenLiquidity
        (swpair:string frozen-dptf:string)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (dptf:string (ref-DPTF::UR_Frozen frozen-dptf))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (iz-frozen-dptf-compatible:bool (contains dptf pool-tokens))
            )
            (enforce iz-frozen-dptf-compatible (format "Frozen-DPTF {} isnt't compatible with Swpair {}" [frozen-dptf swpair]))
        )
    )
    (defun UEV_AddSleepingLiquidity 
        (account:string swpair:string sleeping-dpof:string nonce:integer)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-VST:module{VestingV2} VST)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (dptf:string (ref-DPOF::UR_Sleeping sleeping-dpof))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (iz-sleeping-dpof-compatible:bool (contains dptf pool-tokens))
            )
            (enforce iz-sleeping-dpof-compatible (format "sleeping-dpof {} isnt't compatible with Swpair {}" [sleeping-dpof swpair]))
            (ref-DPOF::UEV_NoncesToAccount sleeping-dpof account [nonce])
            (ref-VST::UEV_StillHasSleeping sleeping-dpof nonce)
        )
    )
    (defun UEV_AddDormantLiquidity (swpair:string)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (iz-sleeping:bool (ref-SWP::UR_IzSleepingLP swpair))
            )
            (enforce iz-sleeping (format "Sleeping LP Functionality is not enabled on Swpair {}" [swpair]))
        )
    )
    (defun UEV_AddChilledLiquidity (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (iz-frozen:bool (ref-SWP::UR_IzFrozenLP swpair))
                (iz-asymmetric:bool (at "iz-asymmetric" (at "sorted-lq-type" ld)))
            )
            (enforce iz-asymmetric "Chilled Liquidity can only be added when asymtric liquidity exists")
            ;;PRODUCED-TRIAGED (_eagerlet --produced, 2026-09-16): <iz-frozen> comes from a hard
            ;;read, so for a swpair that does not exist the raw table error fires before this line.
            ;;Left as is, deliberately. This message makes a STATE claim about a pool that exists;
            ;;for a pool that does NOT exist, "Frozen LP Functionality is not enabled on Swpair X"
            ;;is a MISLEADING answer -- it implies the pair is real and merely unconfigured. The raw
            ;;"no value found" is the lesser evil, and defaulting the reader would manufacture
            ;;exactly the wrong-diagnosis problem RT-K-004 found in DPDC. Same disposition as
            ;;UEV_LockState / UEV_EliteState. The preview half was handled by RT-K-005.
            (enforce iz-frozen (format "Frozen LP Functionality is not enabled on Swpair {}" [swpair]))
        )
    )
    (defun UEV_AddLiquidity (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (can-add:bool (ref-SWP::UR_CanAdd swpair))
                (read-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (iz-asymmetric:bool (at "iz-asymmetric" (at "sorted-lq-type" ld)))
                (iz-balanced:bool (at "iz-balanced" (at "sorted-lq-type" ld)))
                (iz-asymmetric-allowed:bool (ref-SWP::UR_Asymetric))
            )
            (if iz-asymmetric
                (enforce iz-asymmetric-allowed "Asymetric Liquidity Addition isn't enabled by an Ouronet Administrator")
                true
            )
            (if (= read-lp-supply 0.0)
                (enforce iz-balanced
                    "Liquidity Addition on an empty Pool must have a Balanced Part present!"
                )
                true
            )
            (enforce can-add (format "Adding|Removing Liquidity isn't enabled on pool {}" [swpair]))
        )
    )
    (defun UEV_RemoveLiquidity (swpair:string lp-amount:decimal)
        @doc "H11 fix: intentionally does NOT gate on <can-add>. <can-add> is a pool-owner switch meant \
            \ to pause new liquidity provisioning; it must never also block existing LPs from getting \
            \ their own principal back — an admin-controlled ability to freeze user funds already \
            \ deposited isn't a safety mechanism, it's a trust violation (owner's own framing, matching \
            \ how Curve's kill_me exempts plain remove_liquidity and Balancer's Recovery Mode is \
            \ deliberately permissionless while paused, 'so that funds can never be locked by governance \
            \ action'). Removal stays subject only to genuine validity checks below, never to the pool \
            \ owner's add-liquidity switch."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (pool-lp-amount:decimal (ref-DPTF::UR_Supply lp-id))
            )
            (ref-DPTF::UEV_Amount lp-id lp-amount)
            (enforce (<= lp-amount pool-lp-amount) (format "{} is an invalid LP Amount for removing Liquidity" [lp-amount]))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    (defun C_UpdatePendingBrandingLPs:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string entity-pos:integer logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (entity-id:string (URC_EntityPosToID swpair entity-pos))
                (entity-owner:string
                    (if (= entity-pos 3)
                        (ref-DPOF::UR_Konto entity-id)
                        (ref-DPTF::UR_Konto entity-id)
                    )
                )
            )
            (with-capability (SWPLC|C>UPDATE-BRD swpair)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (ref-IGNIS::UDC_BrandingCumulator entity-owner 2.0)
            )
        )
    )
    (defun C_UpgradeBrandingLPs (patron:string swpair:string entity-pos:integer months:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
                (ref-SWP:module{SwapperV4} SWP)
                (owner:string (ref-SWP::UR_OwnerKonto swpair))
                (entity-id:string (URC_EntityPosToID swpair entity-pos))
                (stoa-payment:decimal
                    (with-capability (SWPLC|C>UPGRADE-BRD swpair)
                        (ref-BRD::XE_UpgradeBranding entity-id owner months)
                    )
                )
            )
            (ref-IGNIS::XB_CollectStoaWithTrigger patron stoa-payment false)
        )
    )
    (defun C_ToggleAddLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string toggle:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (with-capability (P|SWPLC|CALLER)
                (ref-SWP::C_ToggleAddOrSwap patron swpair toggle true)
            )
        )
    )
    (defun C_Fuel:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] direct-or-indirect:bool validation:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (pt-current-amounts:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (has-zeros:bool (contains 0.0 input-amounts))
                (input-ids-for-transfer:[string]
                    (if has-zeros
                        (ref-SWPI::URC_TrimIdsWithZeroAmounts swpair input-amounts)
                        pool-tokens
                    )
                )
                (input-amounts-for-transfer:[decimal]
                    (if has-zeros
                        (ref-U|LST::UC_RemoveItem input-amounts 0.0)
                        input-amounts
                    )
                )
                (new-balances:[decimal] 
                    (zip (+) pt-current-amounts input-amounts)
                )
            )
            (if validation
                (UEV_InputsForLP swpair input-amounts)
                true
            )
            (if direct-or-indirect
                (with-capability (SWPLC|C>DIRECT-FUEL account swpair input-ids-for-transfer input-amounts-for-transfer)
                    (ref-SWP::XE_UpdateSupplies swpair new-balances)
                    (ref-TFT::C_MultiTransfer account account SWP|SC_NAME input-ids-for-transfer input-amounts-for-transfer true)
                )
                (with-capability (SWPLC|C>INDIRECT-FUEL account swpair input-ids-for-transfer input-amounts-for-transfer)
                    (ref-SWP::XE_UpdateSupplies swpair new-balances)
                    EOC
                )
            )
        )
    )
    (defun STOA-PID|C_AddStandardLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair input-amounts)
                )
            )
            (with-capability (SWPLC|C>ADD-STANDARD-LQ swpair ld)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        (ref-SWP:module{SwapperV4} SWP)
                        
                        ;;
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        ;;Compute Liquidity Addition Data
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD account swpair ld true true stoa-pid)
                        )
                        ;;
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                        )
                        (native-lp-transfer-amount:decimal (at "primary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity patron account swpair true true stoa-pid ld clad)
                    (let
                        (
                            (ico2:object{IgnisCollectorV3.OutputCumulator}
                                (ref-TFT::C_Transfer patron SWP|SC_NAME account lp-id native-lp-transfer-amount true)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [(ref-IGNIS::UDC_ConstructOutputCumulator
                ;;the STOA-PID variant is the same work as its plain sibling, and both
                ;;branches are the SAME Talos op (SWP|C_AddLiquidity), so it bills the
                ;;sibling component key rather than inventing a second entry
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddStandardLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []) ico1 ico2] [native-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun STOA-PID|C_AddIcedLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair input-amounts)
                )
            )
            (with-capability (SWPLC|C>ADD-ICED-LQ swpair ld)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        (ref-VST:module{VestingV2} VST)
                        (ref-SWP:module{SwapperV4} SWP)
                        ;;
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        ;;Compute Liquidity Addition Data
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD account swpair ld false true stoa-pid)
                        )
                        ;;
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                            
                        )
                        (native-lp-transfer-amount:decimal (at "primary-lp" clad))
                        (frozen-lp-transfer-amount:decimal (at "secondary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity patron account swpair false true stoa-pid ld clad)
                    (let
                        (
                            (ico2:object{IgnisCollectorV3.OutputCumulator}
                                (ref-TFT::C_Transfer patron SWP|SC_NAME account lp-id native-lp-transfer-amount true)
                            )
                            (ico3:object{IgnisCollectorV3.OutputCumulator}
                                (ref-VST::C_Freeze patron SWP|SC_NAME account lp-id frozen-lp-transfer-amount)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators [
                            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;the STOA-PID variant is the same work as its plain sibling, and both
                ;;branches are the SAME Talos op (SWP|C_AddLiquidity), so it bills the
                ;;sibling component key rather than inventing a second entry
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddIcedLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []) ico1 ico2 ico3] [native-lp-transfer-amount frozen-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun STOA-PID|C_AddGlacialLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair input-amounts)
                )
            )
            (with-capability (SWPLC|C>ADD-GLACIAL-LQ swpair ld)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        (ref-VST:module{VestingV2} VST)
                        (ref-SWP:module{SwapperV4} SWP)
                        ;;
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        ;;Compute Liquidity Addition Data
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD account swpair ld false false stoa-pid)
                        )
                        ;;
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                            
                        )
                        (native-lp-transfer-amount:decimal (at "primary-lp" clad))
                        (frozen-lp-transfer-amount:decimal (at "secondary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity patron account swpair false false stoa-pid ld clad)
                    (let
                        (
                            (ico2:object{IgnisCollectorV3.OutputCumulator}
                                (if (!= native-lp-transfer-amount 0.0)
                                    (ref-TFT::C_Transfer patron SWP|SC_NAME account lp-id native-lp-transfer-amount true)
                                    EOC
                                )
                            )
                            (ico3:object{IgnisCollectorV3.OutputCumulator}
                                (ref-VST::C_Freeze patron SWP|SC_NAME account lp-id frozen-lp-transfer-amount)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [(ref-IGNIS::UDC_ConstructOutputCumulator
                ;;the STOA-PID variant is the same work as its plain sibling, and both
                ;;branches are the SAME Talos op (SWP|C_AddLiquidity), so it bills the
                ;;sibling component key rather than inventing a second entry
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddGlacialLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []) ico1 ico2 ico3] [native-lp-transfer-amount frozen-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun STOA-PID|C_AddFrozenLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (dptf:string (ref-DPTF::UR_Frozen frozen-dptf))
                (ptp:integer (ref-SWP::URv_PoolTokenPosition swpair dptf))
                (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp input-amount))
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair lq-lst)
                )
            )
            (with-capability (SWPLC|C>ADD-FROZEN-LQ swpair frozen-dptf ld)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-DALOS:module{OuronetDalosV2} DALOS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        (ref-VST:module{VestingV2} VST)
                        ;;
                        (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                        (ignis-id:string (ref-DALOS::UR_IgnisID))
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        ;;Move F|DPTF to vst-sc and burn it
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_Transfer patron account vst-sc frozen-dptf input-amount true)
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPTF::C_Burn patron vst-sc frozen-dptf input-amount)
                        )
                        ;;
                        ;;Compute CLAD
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD vst-sc swpair ld false false stoa-pid)
                        )
                        ;;
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                        )
                        (frozen-lp-transfer-amount:decimal (at "secondary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity patron vst-sc swpair false false stoa-pid ld clad)
                    (let
                        (
                            (ico4:object{IgnisCollectorV3.OutputCumulator}
                                (ref-VST::C_Freeze patron SWP|SC_NAME account lp-id frozen-lp-transfer-amount)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [(ref-IGNIS::UDC_ConstructOutputCumulator
                ;;the STOA-PID variant is the same work as its plain sibling, and both
                ;;branches are the SAME Talos op (SWP|C_AddLiquidity), so it bills the
                ;;sibling component key rather than inventing a second entry
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddFrozenLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []) ico1 ico2 ico3 ico4] [frozen-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun STOA-PID|C_AddSleepingLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (dptf:string (ref-DPOF::UR_Sleeping sleeping-dpof))
                (ptp:integer (ref-SWP::URv_PoolTokenPosition swpair dptf))
                (batch-amount:decimal (ref-DPOF::UR_NonceSupply sleeping-dpof nonce))
                (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp batch-amount))
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair lq-lst)
                )
            )
            (with-capability (SWPLC|C>ADD-SLEEPING-LQ account swpair sleeping-dpof nonce ld)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-DALOS:module{OuronetDalosV2} DALOS)
                        (ref-VST:module{VestingV2} VST)
                        ;;
                        (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                        (ignis-id:string (ref-DALOS::UR_IgnisID))
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        (nonce-md:[object] (ref-DPOF::UR_NonceMetaData sleeping-dpof nonce))
                        (release-date:time (at "release-date" (at 0 nonce-md)))
                        (present-time:time (at "block-time" (chain-data)))
                        (dt:integer (floor (diff-time release-date present-time)))
                        ;;
                        ;;
                        ;;Move the sleeping DPOF (Z| prefix) to vst-sc and burn it
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Transfer patron account vst-sc sleeping-dpof [nonce] true)
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Burn patron vst-sc sleeping-dpof nonce batch-amount)
                        )
                        ;;
                        ;;Compute CLAD
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD vst-sc swpair ld true true stoa-pid)
                        )
                        ;;
                        ;;MOVE IGNIS to vst-sc, paying for the ignis-tax
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_Transfer patron account vst-sc ignis-id (at "total-ignis-tax-needed" clad) true)
                        )
                        ;;
                        (ico4:object{IgnisCollectorV3.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                        )
                        (sleeping-lp-transfer-amount:decimal (at "primary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity patron vst-sc swpair true true stoa-pid ld clad)
                    (let
                        (
                            (ico5:object{IgnisCollectorV3.OutputCumulator}
                                (ref-VST::C_Sleep patron SWP|SC_NAME account lp-id sleeping-lp-transfer-amount dt)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [(ref-IGNIS::UDC_ConstructOutputCumulator
                ;;the STOA-PID variant is the same work as its plain sibling, and both
                ;;branches are the SAME Talos op (SWP|C_AddLiquidity), so it bills the
                ;;sibling component key rather than inventing a second entry
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddSleepingLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []) ico1 ico2 ico3 ico4 ico5] [sleeping-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun C_RemoveLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string account:string swpair:string lp-amount:decimal)
        @doc "Removes <swpair> Liquidity using <lp-amount> of LP Tokens \
            \ Always returns all Pool Tokens at current Pool Token Ratio"
        ;;
        (P|UEV_IMC)
        (with-capability (SWPLC|C>REMOVE_LQ swpair lp-amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                    ;;
                    (pool-token-ids:[string] (ref-SWP::UR_PoolTokens swpair))
                    (lp-id:string (ref-SWP::UR_TokenLP swpair))
                    (pt-output-amounts:[decimal] (ref-SWPL::URC_LpBreakAmounts swpair lp-amount))
                    (pt-current-amounts:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                    (pt-new-amounts:[decimal] (zip (-) pt-current-amounts pt-output-amounts))
                    ;;
                    ;;Removing Liquidity requires a flat fee of 10$ in Ignis
                    ;;This deincentivizes frequent Liquidity removals
                    ;;
                    ;;LP add/remove churn deterrent — central IG|DETER lp-churn (owner 2026-09-05).
                    ;;2026-09-14: was the BARE UC_IgnisDeter, which made removal the one liquidity op
                    ;;that skipped its own component while its 29.0 row sat unbilled in the price
                    ;;table. Now UC_IgnisPrice, matching the five ADD ops. See URCi_RemoveLiquidity.
                    (flat-ignis-lq-rm-fee:decimal
                        (ref-IGNIS::UC_IgnisPrice "SWP|C_RemoveLiquidity" "lp-churn"))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (ico-flat:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator flat-ignis-lq-rm-fee SWP|SC_NAME trigger [])
                    )
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_Transfer patron account SWP|SC_NAME lp-id lp-amount true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Burn patron SWP|SC_NAME lp-id lp-amount)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_MultiTransfer patron SWP|SC_NAME account pool-token-ids pt-output-amounts true)
                    )
                )
                ;;Updates Pool Supplies
                (ref-SWP::XE_UpdateSupplies swpair pt-new-amounts)
                ;;Autonomous Swap Mangement
                (ref-SWPL::XE_AutonomousSwapManagement swpair)
                ;;Output Cumulator
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico-flat ico1 ico2 ico3] pt-output-amounts)
            )
        )
    )

)

;; --- tables for 18_SWPLC.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)


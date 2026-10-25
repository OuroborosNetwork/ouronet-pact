;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 1 of 22
;; This is STEP 1 of 22 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-0 must have run first, including the init steps between deploys.
;; 4 source file(s), 240,612 gas measured in the REPL gas model, 291,787 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/01_DALOS.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/04_BRD.pact
;;
;; TOTAL: 5 interface(s), 4 module(s), 12 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact
;;      interface  UtilitySwpV3
;;      module     U|SWP
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/01_DALOS.pact
;;      interface  OuronetDalosV3
;;      module     DALOS
;;      table      P|T
;;      table      P|MT
;;      table      DALOS|PropertiesTable
;;      table      DALOS|GasManagementTable
;;      table      DALOS|PricesTable
;;      table      DALOS|AccountTable
;;      table      DALOS|KadenaLedger
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact
;;      interface  IgnisCollectorV4
;;      interface  OuronetInfoV3
;;      module     IGNIS
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/04_BRD.pact
;;      interface  BrandingV3
;;      module     BRD
;;      table      P|T
;;      table      P|MT
;;      table      BRD|BrandingTable
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact ==============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface UtilitySwpV3
    @doc "Exported Utility Functions for the SWP Module"

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
    ;;Raw Swap INPUT Data - <drsi> and <irsi>
    ;;Data needed to perform the actual swap computation with no fees.
    (defschema DirectRawSwapInput
        A:decimal
        X:[decimal]
        input-amounts:[decimal]
        input-positions:[integer]
        output-position:integer
        output-precision:integer
        weights:[decimal]
    )
    (defschema InverseRawSwapInput
        A:decimal
        X:[decimal]
        output-amount:decimal
        output-position:integer
        input-position:integer
        input-precision:integer
        weights:[decimal]
    )
    ;;Swap INPUT Data - <dsid> and <rsid>
    (defschema DirectSwapInputData
        ;;Stores Input Data for a Direct Swap
        input-ids:[string]
        input-amounts:[decimal]
        output-id:string
    )
    (defschema ReverseSwapInputData
        ;;Stores Input Data fora Reverse Swap
        output-id:string
        output-amount:decimal
        input-id:string
    )
    ;;Swap OUTPUT Data - Always Taxed (with swap fees)
    (defschema DirectTaxedSwapOutput
        ;;Direct Taxed Swap starts from <Brutto Input-IDs Amounts>:[decimal] and yields in this order:
        lp-fuel:[decimal]           ;;<Input-IDs-Amounts> going fueling the Pool, in a full List, that is:
                                    ;;Contains 0.0 for Pool Token IDs not involved in the Input.
        o-id:string                 ;;Output-ID of the Direct-Swap
        o-id-special:decimal        ;;Output-ID-amount that goes to Special-Targets
        o-id-liquid:decimal         ;;Output-ID-amount that is used for Stoa Liquid Staking Boost
        o-id-netto:decimal          ;;Output-ID-amount resulted after the Direct Taxed Swap (END-RESULT)
    )
    (defschema InverseTaxedSwapOutput
        ;;Reverse Taxed Swap starts from <Netto Output-ID Amount>:decimal and yields
        o-id-liquid:decimal         ;;Output-ID-amount that would be used by Stoa Liquid Staking
        o-id-special:decimal        ;;Output-ID-amount that would go to Special-Targets
        lp-fuel:[decimal]           ;;Since the Inverse Swap can be computed for a single Input,
                                    ;;Contains the <Input-ID-Amount> of the Pool Token the Reverse Swap computes for
                                    ;;Therefore the List contains a single non zero element, 
                                    ;;filled with 0.0 for the rest of the Pool Tokens
        i-id:string                 ;;Input-ID of the Reverse Swap; It is also the id of the Single non Zero Value in <lp-fuel>
        i-id-brutto:decimal         ;;Input-ID-amount of the Token the Reverse Taxed Swap computed for (END-RESULT).
    )
    ;;
    (defschema SwapFeez
        lp:decimal
        special:decimal
        boost:decimal
    )
    ;;Virtual Swap Engine (VSE) Schema
    ;;The Virtual Swap Engine is used to perform Swap Computations on Data 
    ;;(that can be either true Swap Pool Data or Virtual Data), Performing always Direct Swaps, 
    ;;The Swaps being carried out are stored in the <swaps> field in an Object{VirtualSwap}
    ;;with their Input-Ids, Input-Amounts, and Output-ID;
    ;;As Supply, it always stores the "current" state of the virtual swap in the <account-supply> and <pool-supply>
    (defschema VirtualSwapEngine
        ;;Virtual Token IDs
        v-tokens:[string]           ;;Stores the Token IDs the VSE is operating with.
                                    ;;These are also the Pool Tokens, in this exact order
        v-prec:[integer]            ;;Decimal Precision of the Pool Tokens
        ;;
        ;;Virtual Account
        account:string              ;;The Account Performing the Virtual Swap (needed to fetch its Tier for Fee Reduction Purposes)
        account-supply:[decimal]    ;;The Virtual Token Supply of the Virtual Account. Gets updated with every Virtual Swap being executed
        ;;
        ;;Virtual Pool
        swpair:string               ;;While the VirtualSwapEngine doesnt operate on Swpair Data, storing the swpair ID is necesary
                                    ;;Because through it, the Pool Tokens can be known, and through them
                                    ;;the positions of the <input-ids>
        X:[decimal]                 ;;Token Supply of the Virtual Pool
        A:decimal                   ;;Amplifier supply of the Virtual Pool
        W:[decimal]                 ;;Weights of the Virtual Pool
        F:object{SwapFeez}          ;;Fee Values of the Virtual Pool
        ;;
        ;;Swap-Results - use <v-tokens> ID Order
        fuel:[decimal]              ;;Stores the Amounts that would go as Fuel for the Pool, boosting LP Token Value
        special:[decimal]           ;;Stores the Amounts that would go to the Pool Special Targets
        boost:[decimal]             ;;Stores the Amounts that would go to Stoa Liquid Staking Boost
        ;;
        ;;Virtual Swap Chains
        swaps:[object{DirectSwapInputData}] ;;Stores the Data of the Swaps in a Chain
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
    (defun UDC_DirectRawSwapInput:object{DirectRawSwapInput} (a:decimal b:[decimal] c:[decimal] d:[integer] e:integer f:integer g:[decimal]))
    (defun UDC_InverseRawSwapInput:object{InverseRawSwapInput} (a:decimal b:[decimal] c:decimal d:integer e:integer f:integer g:[decimal]))
    (defun UDC_DirectSwapInputData:object{DirectSwapInputData} (a:[string] b:[decimal] c:string))
    (defun UDC_ReverseSwapInputData:object{ReverseSwapInputData} (a:string b:decimal c:string))
    (defun UDC_DirectTaxedSwapOutput:object{DirectTaxedSwapOutput} (a:[decimal] b:string c:decimal d:decimal e:decimal))
    (defun UDC_InverseTaxedSwapOutput:object{InverseTaxedSwapOutput} (a:decimal b:decimal c:[decimal] d:string e:decimal))
    (defun UDC_SwapFeez:object{SwapFeez} (a:decimal b:decimal c:decimal))
    (defun UDC_VirtualSwapEngine:object{VirtualSwapEngine} (a:[string] b:[integer] c:string d:[decimal] e:string f:[decimal] g:decimal h:[decimal] i:object{SwapFeez} j:[decimal] k:[decimal] l:[decimal] m:[object{DirectSwapInputData}]))
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_ComputeY (drsi:object{DirectRawSwapInput}))
    (defun UCv_ComputeInverseY (irsi:object{InverseRawSwapInput}))
    (defun UC_YNext (Y:decimal A:decimal D:decimal n:decimal S-Prime:decimal P-Prime:decimal))
    (defun UC_ZNext (Y:decimal A:decimal D:decimal n:decimal S-Prime:decimal P-Prime:decimal))
    (defun UC_ComputeD:decimal (A:decimal X:[decimal]))
    (defun UC_DNext (D:decimal A:decimal X:[decimal]))
        ;;
    (defun UC_ComputeWP (drsi:object{DirectRawSwapInput}))
    (defun UC_ComputeInverseWP (irsi:object{InverseRawSwapInput}))
        ;;
    (defun UC_ComputeEP:decimal (drsi:object{DirectRawSwapInput}))
    (defun UC_ComputeInverseEP:decimal (irsi:object{InverseRawSwapInput}))
    ;;
    ;;
    (defun UC_BalancedLiquidity:[decimal] (ia:decimal ip:integer i-prec X:[decimal] Xp:[integer]))
    (defun UC_LP:decimal (input-amounts:[decimal] pts:[decimal] lps:decimal lpp:integer))
    (defun UC_LpID:[string] (token-names:[string] token-tickers:[string] weights:[decimal] amp:decimal))
    (defun UC_AddSupply:[decimal] (X:[decimal] input-amounts:[decimal] ip:[integer]))
    (defun UC_RemoveSupply:[decimal] (X:[decimal] output-amount:decimal op:integer))
    (defun UC_PoolID:string (token-ids:[string] weights:[decimal] amp:decimal))
    (defun UC_Prefix:string (weights:[decimal] amp:decimal))
    ;;
    (defun UC_AreOnPools:[bool] (id1:string id2:string swpairs:[string]))
    (defun UC_FilterOne:[string] (swpairs:[string] id:string))
    (defun UC_FilterTwo:[string] (swpairs:[string] id1:string id2:string))
    (defun UC_IzOnPool:bool (id:string swpair:string))
    (defun UC_IzOnPools:[bool] (id:string swpairs:[string]))
    (defun UC_MakeGraphNodes:[string] (input-id:string output-id:string swpairs:[string]))
    (defun UC_PoolTokensFromPairs:[[string]] (swpairs:[string]))
    (defun UC_SpecialFeeOutputs:[decimal] (sftp:[decimal] input-amount:decimal output-precision:integer))
    (defun UC_TokensFromSwpairString:[string] (swpair:string))
    (defun UC_UniqueTokens:[string] (swpairs:[string]))
    (defun UC_MakeLiquidityList (swpair:string ptp:integer amount:decimal))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]


    ;;<=========================================================================>
    ;; ADDED 2026-10-12 -- interface-membership sweep (StoicSyntax-Prefixes.md Sec5,
    ;; owner ruling). Every one of these was already live in the module body; this
    ;; closes the gap between what the module DOES and what its interface SAYS it does.
    ;;<=========================================================================>
    (defun UC_IntPow:decimal (base:decimal power:integer))
    (defun UC_PoolType:string (swpair:string))
)

(module U|SWP GOV
    @doc "Swap-pool math and helper library (implements UtilitySwpV3). Defines swap \
        \ input/output schemas with UDC constructors, and implements the pool invariant \
        \ solvers: Curve-style stable-pool math, weighted and equal-weight constant-product \
        \ swaps and inverses, plus LP and pool-id helpers and swpair/token routing \
        \ utilities."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements UtilitySwpV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|SWP_ADMIN)))
    (defcap GOV|U|SWP_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
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
    (defconst BAR                                       (CT_Bar))
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
    ;;
    ;;
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
    (defun UDC_DirectRawSwapInput:object{UtilitySwpV3.DirectRawSwapInput}
        (a:decimal b:[decimal] c:[decimal] d:[integer] e:integer f:integer g:[decimal])
        {"A"                : a
        ,"X"                : b
        ,"input-amounts"    : c
        ,"input-positions"  : d
        ,"output-position"  : e
        ,"output-precision" : f
        ,"weights"          : g}
    )
    (defun UDC_InverseRawSwapInput:object{UtilitySwpV3.InverseRawSwapInput}
        (a:decimal b:[decimal] c:decimal d:integer e:integer f:integer g:[decimal])
        {"A"                : a
        ,"X"                : b
        ,"output-amount"    : c
        ,"output-position"  : d
        ,"input-position"   : e
        ,"input-precision"  : f
        ,"weights"          : g}
    )
    ;;
    (defun UDC_DirectSwapInputData:object{UtilitySwpV3.DirectSwapInputData}
        (a:[string] b:[decimal] c:string)
        {"input-ids"        : a
        ,"input-amounts"    : b
        ,"output-id"        : c}
    )
    (defun UDC_ReverseSwapInputData:object{UtilitySwpV3.ReverseSwapInputData}
        (a:string b:decimal c:string)
        {"output-id"        : a
        ,"output-amount"    : b
        ,"input-id"         : c}
    )
    ;;
    (defun UDC_DirectTaxedSwapOutput:object{UtilitySwpV3.DirectTaxedSwapOutput}
        (a:[decimal] b:string c:decimal d:decimal e:decimal)
        {"lp-fuel"          : a
        ,"o-id"             : b
        ,"o-id-special"     : c
        ,"o-id-liquid"      : d
        ,"o-id-netto"       : e}
    )
    (defun UDC_InverseTaxedSwapOutput:object{UtilitySwpV3.InverseTaxedSwapOutput}
        (a:decimal b:decimal c:[decimal] d:string e:decimal)
        {"o-id-liquid"      : a
        ,"o-id-special"     : b
        ,"lp-fuel"          : c
        ,"i-id"             : d
        ,"i-id-brutto"      : e}
    )
    (defun UDC_SwapFeez:object{UtilitySwpV3.SwapFeez}
        (a:decimal b:decimal c:decimal)
        {"lp"               : a
        ,"special"          : b
        ,"boost"            : c}
    )
    (defun UDC_VirtualSwapEngine:object{UtilitySwpV3.VirtualSwapEngine}
        (a:[string] b:[integer] c:string d:[decimal] e:string f:[decimal] g:decimal h:[decimal] i:object{UtilitySwpV3.SwapFeez} j:[decimal] k:[decimal] l:[decimal] m:[object{UtilitySwpV3.DirectSwapInputData}])
        {"v-tokens"         : a
        ,"v-prec"           : b
        ,"account"          : c
        ,"account-supply"   : d
        ,"swpair"           : e
        ,"X"                : f
        ,"A"                : g
        ,"W"                : h
        ,"F"                : i
        ,"fuel"             : j
        ,"special"          : k
        ,"boost"            : l
        ,"swaps"            : m}
    )
    ;;{5.2}  Compute [UC]
    ;;S - Stable Pools Computation using Curve Finance original math.
    (defun UC_ComputeY 
        (drsi:object{UtilitySwpV3.DirectRawSwapInput})
        @doc "Computes <output-amount> of the Swap given the <input-amount>"
        (let
            (
                ;;Unwrap Object Data
                (A:decimal (at "A" drsi))
                (X:[decimal] (at "X" drsi))
                (input-amount:decimal (at 0 (at "input-amounts" drsi)))
                (ip:integer (at 0 (at "input-positions" drsi)))
                (op:integer (at "output-position" drsi))
                (o-prec:integer (at "output-precision" drsi))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (prec:integer 24)
                (D:decimal (UC_ComputeD A X))
                (n:decimal (dec (length X)))
                (xo:decimal (at op X))
                (xi:decimal (at ip X))
                (xi-plus:decimal (+ xi input-amount))
                (X1:[decimal] (ref-U|LST::UC_ReplaceAt X ip xi-plus))
                (X2:[decimal] (ref-U|LST::UC_ReplaceAt X1 op -1.0))
                (X3:[decimal] (ref-U|LST::UC_RemoveItem X2 -1.0))
                (S-Prime:decimal (floor (fold (+) 0.0 X3) prec))
                (P-Prime:decimal (floor (fold (*) 1.0 X3) prec))
                ;;Y0 Initial Assumption
                ;;Seeded at <D> (matching the Curve-style reference `get_y`), not <xo - input-amount> \
                ;;<xo - input-amount> goes negative once <input-amount> >= <xo>, walking Newton into the \
                ;;non-physical negative root of the same quadratic; <D> is always in the correct root's \
                ;;basin regardless of trade size (C2 fix)
                (y0:decimal D)
                (output-lst:[decimal]
                    (fold
                        (lambda
                            (y-values:[decimal] idx:integer)
                            (let
                                (
                                    (prev-y:decimal (at idx y-values))
                                    (y-value:decimal (UC_YNext prev-y A D n S-Prime P-Prime))
                                )
                                (ref-U|LST::UC_AppL y-values y-value)
                            )
                        )
                        [y0]
                        ;;#24H fix: 11 -> 12 iterations, for uniformity with UC_ComputeD's bumped
                        ;;count (owner direction) — measured fully converged at 11 already (proven
                        ;;via a 255-iteration reference at 1000x reserve skew), so this is pure
                        ;;margin, not a measured shortfall like UC_ComputeD's was.
                        (enumerate 0 11)
                    )
                )
            )
            ;;C3 fix: floor the FINAL output, not the intermediate solved balance. Flooring <Y> before
            ;;subtracting it from <xo> made <output> systematically LARGER than the exact invariant value
            ;;(favoring the trader); flooring the final <xo - Y> instead rounds what's actually paid out
            ;;down, favoring the pool, matching the Curve reference convention.
            (floor (- xo (ref-U|LST::UC_LE output-lst)) o-prec)
        )
    )
    (defun UCv_ComputeInverseY
        (irsi:object{UtilitySwpV3.InverseRawSwapInput})
        @doc "Computes the <input-amount> for the Swap given the <output-amount>"
        (let        
            (
                ;;Unwrap Object Data
                (A:decimal (at "A" irsi))
                (X:[decimal] (at "X" irsi))
                (output-amount:decimal (at "output-amount" irsi))
                (op:integer (at "output-position" irsi))
                (ip:integer (at "input-position" irsi))
                (i-prec:integer (at "input-precision" irsi))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (prec:integer 24)
                (D:decimal (UC_ComputeD A X))
                (n:decimal (dec (length X)))
                (xo:decimal (at op X))
                (xi:decimal (at ip X))
                ;;#72C fix (C2's still-open sibling): <xo-minus> feeds <P-Prime> as a plain factor
                ;;(not just an addend), so at <output-amount> == <xo> it is exactly 0.0, making
                ;;<P-Prime> == 0.0 and dividing by zero inside <UC_YNext>'s `c` term — an ugly,
                ;;uncatchable-via-`try` native crash (confirmed live). Past that (<output-amount>
                ;;> <xo>) <xo-minus> goes negative, flips the sign on every coefficient chained off
                ;;<P-Prime>/<S-Prime>, and the solver does NOT crash — it silently converges to a
                ;;plausible-looking but mathematically meaningless number (confirmed live: asking
                ;;for 1.01x/1.5x/5x a pool's real output reserve returned ~1.01x/~1.5x/~5x back as
                ;;the "required input," when no finite input can ever buy more than 100% of a
                ;;pool's own reserve of a token). Unlike <UC_ComputeY>'s C2 fix (a reseed was
                ;;enough there, because the physical root exists for ANY positive input), no seed
                ;;choice can fix this: the coefficients themselves are invalid before Newton ever
                ;;starts, for a request that has no valid answer by construction. Rejecting it here,
                ;;before <xo-minus>/<P-Prime> are computed, is the only correct fix — mirrors the
                ;;same load-bearing, computation-intrinsic bounds-guard treatment StoicSyntax §6.1
                ;;already documents for this exact function (the <U|LST> bounds-guard exception).
                (domain-guard:bool
                    (enforce (< output-amount xo)
                        "UCv_ComputeInverseY: output-amount must be strictly less than the pool's current output-token reserve"))
                (xo-minus:decimal (- xo output-amount))
                (X1:[decimal] (ref-U|LST::UC_ReplaceAt X op xo-minus))
                (X2:[decimal] (ref-U|LST::UC_ReplaceAt X1 ip -1.0))
                (X3:[decimal] (ref-U|LST::UC_RemoveItem X2 -1.0))
                (S-Prime:decimal (floor (fold (+) 0.0 X3) prec))
                (P-Prime:decimal (floor (fold (*) 1.0 X3) prec))
                ;;Y0 Initial Assumption
                ;;For best results <output-amount> < 0.9975 * xi
                (y0:decimal (+ xi output-amount))
                (output-lst:[decimal]
                    (fold
                        (lambda
                            (y-values:[decimal] idx:integer)
                            (let
                                (
                                    (prev-y:decimal (at idx y-values))
                                    (y-value:decimal (UC_ZNext prev-y A D n S-Prime P-Prime))
                                )
                                (ref-U|LST::UC_AppL y-values y-value)
                            )
                        )
                        [y0]
                        ;;#24H fix: 11 -> 12 iterations, mirroring UC_ComputeY (see its comment).
                        (enumerate 0 11)
                    )
                )
            )
            ;;C3 fix: ceiling the FINAL input-needed, not the intermediate solved balance. Flooring <Y>
            ;;before subtracting <xi> made <input-needed> systematically SMALLER than the exact invariant
            ;;value (favoring the trader); ceiling-ing the final <Y - xi> instead rounds what's actually
            ;;required in up, favoring the pool.
            (ceiling (- (ref-U|LST::UC_LE output-lst) xi) i-prec)
        )
    )
    (defun UC_YNext (Y:decimal A:decimal D:decimal n:decimal S-Prime:decimal P-Prime:decimal)
        @doc "Swapping 100B for y amount of C >> Equation in a stable swap pool: \
            \ How much C do you get from swapping 100B ? \
            \ D-of-[A B C] = D-of-[A (B + 100) (C - y)] \
            \ Function solves for Y iteratively, where Y = (C - y) [y  = swap value] \
            \ \
            \ <input> = 100 ; <output> = ?? \
            \ \
            \ S-Prime = A + (B + 100) without (C - ??) \
            \ P-Prime = A * (B + 100) without (C - ??) \
            \ \
            \ c = (D^(n+1))/(n^n * Pp * A * n^n) \
            \ b = Sp + (D/(A * n^n)) \
            \ Numerator = Y^2 + c \
            \ Denominator = 2*Y + b - D \
            \ YNext = Numerator / Denominator"
        (let
            (
                (prec:integer 24)
                (n1:decimal (+ 1.0 n))
                ;;C3 fix: <n>/<n1>/<Y^2> are always whole-number powers — use exact UC_IntPow / plain
                ;;multiplication, not native <^> (see UC_IntPow @doc for why <^> isn't safe here).
                (ni:integer (round n))
                (nn:decimal (UC_IntPow n ni))
                (c:decimal (floor (/ (UC_IntPow D (+ ni 1)) (fold (*) 1.0 [nn P-Prime A nn])) prec))
                (b:decimal (floor (+ S-Prime (/ D (* A nn))) prec))
                (Ysq:decimal (* Y Y))
                (numerator:decimal (floor (+ Ysq c) prec))
                (denominator:decimal (floor (- (+ (* Y 2.0) b) D) prec))
            )
            (floor (/ numerator denominator) prec)
        )
    )
    (defun UC_ZNext (Y:decimal A:decimal D:decimal n:decimal S-Prime:decimal P-Prime:decimal)
        @doc "Swapping ??B for 100C  >> Equation in a stable swap pool: \
            \ How much B do you need to swap to get 100C ? \
            \ D-of-[A B C] = D-of-[A (B + y) (C - 100)] \
            \ Function solves for Y iteratively, where Y = (B + y) [y  = swap value] \
            \ \
            \ <input> = ?? ; <output> = 100 \
            \ \
            \ S-Prime = A + (C - 100) without (B + ??) \
            \ P-Prime = A * (C - 100) without (B + ??) \
            \ \
            \ c = (D^(n+1))/(n^n * Pp * A * n^n) \
            \ b = Sp + (D/(A * n^n)) \
            \ Numerator = Y^2 + c \
            \ Denominator = 2*Y + b - D \
            \ YNext = Numerator / Denominator"
        (UC_YNext Y A D n S-Prime P-Prime)
    )
    (defun UC_IntPow:decimal (base:decimal power:integer)
        @doc "Computes <base>^<power> for a non-negative INTEGER <power> via exact repeated multiplication. \
            \ C3 fix: Pact's native <^> silently drops to IEEE-754 double precision for decimal \
            \ exponentiation (confirmed empirically — a ~2550.0 base raised to a whole-number power via \
            \ <^> differs from the exact repeated-multiplication result by ~1e-2 in absolute terms), which \
            \ was the true source of the stable-pool round-trip rounding bias, not the floor/ceiling \
            \ placement. Use this instead of <^> everywhere the exponent is a whole number (token-count- \
            \ derived powers); genuinely fractional exponents (weighted-pool <x^weight>) still route \
            \ through native <^> and are NOT fixed by this helper."
        (fold (*) 1.0 (make-list power base))
    )
    (defun UC_ComputeD:decimal (A:decimal X:[decimal])
        @doc "Computes D Parameter given an amplifier <A> and a value of Pool Tokens \
        \ Uses <UC_DNext> for aproximation over 12 fixed iterations. \
        \ #24H fix: was 6 (docstring claimed 5, itself a doc/code mismatch) — measured \
        \ directly against a 255-iteration reference at 1000x reserve skew \
        \ (X=[500000,500,500], A=85, a legally reachable pool state): 6 iterations left \
        \ D off by 0.0078 absolute, while the same computation is already fully \
        \ converged (bit-identical to 255 iterations) by iteration 10. Pact has no \
        \ dynamic-length loop / early-exit-on-convergence construct (Turing-incomplete — \
        \ the iteration count must be a fixed number decided in advance, not runtime- \
        \ dependent), so the fix is a plain static bump, not an adaptive break: 12 \
        \ gives 2 iterations of margin past the measured convergence point, for a small, \
        \ fixed, uniform gas cost on every call regardless of pool state."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (output-lst:[decimal]
                    (fold
                        (lambda
                            (d-values:[decimal] idx:integer)
                            (let
                                (
                                    (prev-d:decimal (at idx d-values))
                                    (d-value:decimal (UC_DNext prev-d A X))
                                )
                                (ref-U|LST::UC_AppL d-values d-value)
                            )
                        )
                        [(fold (+) 0.0 X)]
                        (enumerate 0 11)
                    )
                )
            )
            (ref-U|LST::UC_LE output-lst)
        )
    )
    (defun UC_DNext (D:decimal A:decimal X:[decimal])
        @doc "Computes Dnext: \
        \ n = (length X) \
        \ S=x1+x2+x3+... \
        \ P=x1*x2*x3*... \
        \ Dp = (D^(n+1))/(P*n^n) \
        \ Numerator = (A*n^n*S + Dp*n)*D \
        \ Denominator = (A*n^n-1)*D + (n+1)*Dp \
        \ DNext = Numerator / Denominator"
        (let
            (
                (prec:integer 24)
                (n:decimal (dec (length X)))
                (S:decimal (fold (+) 0.0 X))
                (P:decimal (floor (fold (*) 1.0 X) prec))
                (n1:decimal (+ 1.0 n))
                ;;C3 fix: <n>/<n1> are always whole numbers (token count / +1) — use exact UC_IntPow,
                ;;not native <^>, which silently loses precision through a float64 path (see UC_IntPow @doc).
                (nn:decimal (UC_IntPow n (length X)))
                (Dp:decimal (floor (/ (UC_IntPow D (+ (length X) 1)) (* nn P)) prec))
                ;;
                (v1:decimal (floor (fold (*) 1.0 [A nn S]) prec))
                (v2:decimal (* Dp n))
                (v3:decimal (+ v1 v2))
                (numerator:decimal (floor (* v3 D) prec))
                ;;
                (v4:decimal (- (* A nn) 1.0))
                (v5:decimal (* v4 D))
                (v6:decimal (floor (* n1 Dp) prec))
                (denominator:decimal (+ v5 v6))
            )
            (floor (/ numerator denominator) prec)
        )
    )
    ;;W - Weigthed Constant Product Pools Computations
    ;;
    ;;<x^weight> below routes through Pact's native <^>, which computes decimal exponentiation via
    ;;power via <^> differs from the exact repeated-multiplication result by ~1e-2 absolute) — unlike
    ;;+/-/*// on Pact decimals, which genuinely are exact/arbitrary-precision. <UC_IntPow> works around
    ;;this for the STABLE-pool math (UC_ComputeD/UC_YNext), which only ever needs whole-number exponents.
    ;;It cannot work around this here: <weight> is a genuine fraction (e.g. 0.3), so this needs a real
    ;;fractional power, and no exact-multiplication trick exists for that in pure Pact. Fixing this fully
    ;;would mean writing a from-scratch high-precision power routine (Newton's method / power series) —
    ;;assessed and explicitly declined as disproportionate to the residual risk: the resulting bias scales
    ;;with float64's ~1e-16 *relative* precision times the magnitude of the numbers involved, is many
    ;;orders of magnitude below anything resembling pool insolvency, stays internally consistent (the same
    ;;computed value backs both the transfer and the tracked-reserve update), and for realistic (non-24-
    ;;decimal) token precisions is routinely swallowed entirely by the final settlement-precision rounding.
    ;;Accepted as a bounded, documented limitation of the underlying language, not tracked as an open bug.
    (defun UC_ComputeWP
        (drsi:object{UtilitySwpV3.DirectRawSwapInput})
        @doc "Swapping 100A for y amount of C >> Equation in a weighted constant product pool: \
            \ How much C do you get for swapping 100A ? \
            \ xA^wA * xB^wB * xC^wC * xD^wD = (xA + 100)^wA * xB^wB * (xC - y)^wC * xD^wD \
            \ This functions solves for y"
        (let
            (
                ;;Unwrap Object Data
                (X:[decimal] (at "X" drsi))
                (input-amounts:[decimal] (at "input-amounts" drsi))
                (ip:[integer] (at "input-positions" drsi))
                (op:integer (at "output-position" drsi))
                (o-prec:integer (at "output-precision" drsi))
                (w:[decimal] (at "weights" drsi))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (raised:[decimal] (zip (lambda (x:decimal y:decimal) (floor (^ x y) 24)) X w))
                (pool-product:decimal (floor (fold (*) 1.0 raised) 24))
                (added-supplies:[decimal] (UC_AddSupply X input-amounts ip))
                (rm-output:[decimal] (ref-U|LST::UC_RemoveItemAt added-supplies op))
                (rw:[decimal] (ref-U|LST::UC_RemoveItemAt w op))
                (rm-output-raised:[decimal] (zip (lambda (x:decimal y:decimal) (^ x y)) rm-output rw))
                (rm-output-raised-multiplied:decimal (floor (fold (*) 1.0 rm-output-raised) 24))
                (ow:decimal (at op w))
                (inverse-ow:decimal (floor (/ 1.0 ow) 24))
                (output-missing-term-raised:decimal (floor (/ pool-product rm-output-raised-multiplied) 24))
                ;;C3 fix: keep this intermediate at internal precision (24), not <o-prec> — the final
                ;;<output> rounding happens once, below, on the actual amount paid out.
                (output-missing-term:decimal (floor (^ output-missing-term-raised inverse-ow) 24))
            )
            ;;C3 fix: floor the FINAL output, not the intermediate missing-term. Flooring the missing-term
            ;;before subtracting it from <X[op]> made <output> systematically larger than the exact
            ;;invariant value (favoring the trader); flooring the final subtraction favors the pool.
            (floor (- (at op X) output-missing-term) o-prec)
        )
    )
    (defun UC_ComputeInverseWP
        (irsi:object{UtilitySwpV3.InverseRawSwapInput})
        @doc "Swapping ??A for 100C >> Equation in a weighted constant product pool: \
            \ How much A do you need to swap to get 100C ?  \
            \ xA^wA * xB^wB * xC^wC * xD^wD = (xA + y)^wA * xB^wB * (xC - 100)^wC * xD^wD \
            \ This functions solves for y"
        (let
            (
                ;;Unwrap Object Data
                (X:[decimal] (at "X" irsi))
                (output-amount:decimal (at "output-amount" irsi))
                (op:integer (at "output-position" irsi))
                (ip:integer (at "input-position" irsi))
                (i-prec:integer (at "input-precision" irsi))
                (w:[decimal] (at "weights" irsi))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (raised:[decimal] (zip (lambda (x:decimal y:decimal) (floor (^ x y) 24)) X w))
                (pool-product:decimal (floor (fold (*) 1.0 raised) 24))
                (removed-supplies:[decimal] (UC_RemoveSupply X output-amount op))
                (rm-input:[decimal] (ref-U|LST::UC_RemoveItemAt removed-supplies ip))
                (rw:[decimal] (ref-U|LST::UC_RemoveItemAt w ip))
                (rm-input-raised:[decimal] (zip (lambda (x:decimal y:decimal) (^ x y)) rm-input rw))
                (rm-input-raised-multiplied:decimal (floor (fold (*) 1.0 rm-input-raised) 24))
                (iw:decimal (at ip w))
                (inverse-iw:decimal (floor (/ 1.0 iw) 24))
                (input-missing-term-raised:decimal (floor (/ pool-product rm-input-raised-multiplied) 24))
                ;;C3 fix: keep this intermediate at internal precision (24), not <i-prec> — the final
                ;;<input-needed> rounding happens once, below, on the actual amount required in.
                (input-missing-term:decimal (floor (^ input-missing-term-raised inverse-iw) 24))
            )
            ;;C3 fix: ceiling the FINAL input-needed, not the intermediate missing-term. Flooring the
            ;;missing-term before subtracting <X[ip]> made <input-needed> systematically smaller than the
            ;;exact invariant value (favoring the trader); ceiling-ing the final subtraction favors the
            ;;pool.
            (ceiling (- input-missing-term (at ip X)) i-prec)
        )
    )
    ;;W - Equal Weight Constant Product Pools Computations
    (defun UC_ComputeEP:decimal 
        (drsi:object{UtilitySwpV3.DirectRawSwapInput})
        @doc "Swapping 100A for y amount of C >> Equation in an equal weight constant product pool: \
            \ xA * xB * xC * xD = (xA + 100) * xB * (xC - y) * xD \
            \ This Functions solves for y"
        (let
            (
                ;;Unwrap Object Data
                (X:[decimal] (at "X" drsi))
                (input-amounts:[decimal] (at "input-amounts" drsi))
                (ip:[integer] (at "input-positions" drsi))
                (op:integer (at "output-position" drsi))
                (o-prec:integer (at "output-precision" drsi))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (pool-product:decimal (floor (fold (*) 1.0 X) 24))
                (added-supplies:[decimal] (UC_AddSupply X input-amounts ip))
                (rm-output:[decimal] (ref-U|LST::UC_RemoveItemAt added-supplies op))
                (rm-output-multiplied:decimal (floor (fold (*) 1.0 rm-output) 24))
                ;;C3 fix: keep this intermediate at internal precision (24), not <o-prec> — see UC_ComputeY.
                (output-missing-term:decimal (floor (/ pool-product rm-output-multiplied) 24))
            )
            ;;C3 fix: floor the FINAL output, not the intermediate missing-term (see UC_ComputeWP).
            (floor (- (at op X) output-missing-term) o-prec)
        )
    )
    (defun UC_ComputeInverseEP:decimal
        (irsi:object{UtilitySwpV3.InverseRawSwapInput})
        @doc "How Much A is needed to get 100C >> Equation in an equal weight constant product pool: \
            \ xA * xB * xC * xD = (xA + y) * xB * (xC - 100) * xD \
            \ This function solves for Y"
        (let
            (
                ;;Unwrap Object Data
                (X:[decimal] (at "X" irsi))
                (output-amount:decimal (at "output-amount" irsi))
                (op:integer (at "output-position" irsi))
                (ip:integer (at "input-position" irsi))
                (i-prec:integer (at "input-precision" irsi))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (pool-product:decimal (floor (fold (*) 1.0 X) 24))
                (removed-supplies:[decimal] (UC_RemoveSupply X output-amount op))
                (rm-input:[decimal] (ref-U|LST::UC_RemoveItemAt removed-supplies ip))
                (rm-input-multiplied:decimal (floor (fold (*) 1.0 rm-input) 24))
                ;;C3 fix: keep this intermediate at internal precision (24), not <i-prec> — see UC_ComputeInverseWP.
                (input-missing-term:decimal (floor (/ pool-product rm-input-multiplied) 24))
            )
            ;;C3 fix: ceiling the FINAL input-needed, not the intermediate missing-term (see UC_ComputeInverseWP).
            (ceiling (- input-missing-term (at ip X)) i-prec)
        )
    )
    ;;LP Computations
    (defun UC_BalancedLiquidity:[decimal] (ia:decimal ip:integer i-prec X:[decimal] Xp:[integer])
        @doc "Computes Balanced Liquidity Amounts from input sources"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ratio:decimal (floor (/ ia (at ip X)) i-prec))
                (output:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (if (= idx ip)
                                    ia
                                    (floor (* ratio (at idx X)) (at idx Xp))
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length X) 1))
                    )
                )
            )
            output
        )
    )
    (defun UC_LP:decimal (input-amounts:[decimal] pts:[decimal] lps:decimal lpp:integer)
        @doc "Computes the amount of LP that would result from <input-amounts> of tokens added to the pool, when \
            \ the pools has <pts> token supply, and the lp amounts is <lps> and the lp token has <lpp> precision \
            \ Must only be used when <input-amounts> are balanced, otherwise LP computation results in an inccorect value"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (nz:[decimal] (ref-U|LST::UC_RemoveItem input-amounts 0.0))
                (fnz:decimal (at 0 nz))
                (fnzp:integer (at 0 (ref-U|LST::UC_Search input-amounts fnz)))
            )
            (floor (* (/ (at fnzp input-amounts) (at fnzp pts)) lps) lpp)
        )
    )
    (defun UC_LpID:[string] (token-names:[string] token-tickers:[string] weights:[decimal] amp:decimal)
        @doc "Creates a LP Id from input sources. \
            \ #40L fix: dropped the cross-module UEV_UniformList length-parity enforce \
            \ that used to live here — a UC_* purity violation (UC_* may not enforce, \
            \ even transitively via another module's UEV_*). Confirmed dead defense, \
            \ not load-bearing: the only real caller (SWP::URC_LpComposer) builds both \
            \ <token-names> and <token-tickers> from the exact same source list via the \
            \ exact same enumerate range, so they can never actually differ in length. \
            \ Residual, not pursued: UC_LpID is declared on the public UtilitySwpV2 \
            \ interface, so a hypothetical future caller passing mismatched-length \
            \ lists would hit a plain out-of-bounds crash inside the folds below \
            \ instead of a clean enforce message — same class of residual risk as M1's \
            \ own write-up, not a live path today."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (prefix:string (UC_Prefix weights amp))
                (l1:integer (length token-names))
                (minus:string "-")
                (caron:string "^")
            )
            (let
                (
                    (lp-name-elements:[string]
                        (fold
                            (lambda
                                (acc:[string] idx:integer)
                                (if (!= idx (- l1 1))
                                    (ref-U|LST::UC_AppL acc (+ (at idx token-names) caron))
                                    (ref-U|LST::UC_AppL acc (at idx token-names))
                                )
                            )
                            []
                            (enumerate 0 (- l1 1))
                        )
                    )
                    (lp-ticker-elements:[string]
                        (fold
                            (lambda
                                (acc:[string] idx:integer)
                                (if (!= idx (- l1 1))
                                    (ref-U|LST::UC_AppL acc (+ (at idx token-tickers) minus))
                                    (ref-U|LST::UC_AppL acc (at idx token-tickers))
                                )
                            )
                            []
                            (enumerate 0 (- l1 1))
                        )
                    )
                    (lp-name:string (concat [prefix BAR (concat lp-name-elements)]))
                    (lp-ticker:string (concat [prefix BAR (concat lp-ticker-elements) BAR "LP"]))
                )
                [lp-name lp-ticker]
            )
        )
    )
    (defun UC_AddSupply:[decimal] (X:[decimal] input-amounts:[decimal] ip:[integer])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (+
                            (if (contains idx ip)
                                (at (at 0 (ref-U|LST::UC_Search ip idx)) input-amounts)
                                0.0
                            )
                            (at idx X)
                        )
                    )
                )
                []
                (enumerate 0 (- (length X) 1))
            )
        )
    )
    (defun UC_RemoveSupply:[decimal] (X:[decimal] output-amount:decimal op:integer)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (-
                            (at idx X)
                            (if (= idx op)
                                output-amount
                                0.0
                            )
                        )
                    )
                )
                []
                (enumerate 0 (- (length X) 1))
            )
        )
    )
    (defun UC_PoolID:string (token-ids:[string] weights:[decimal] amp:decimal)
        @doc "Creates a Swap Pool Id from input sources"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (prefix:string (UC_Prefix weights amp))
                (swpair-elements:[string]
                    (fold
                        (lambda
                            (acc:[string] idx:integer)
                            (if (!= idx (- (length token-ids) 1))
                                (ref-U|LST::UC_AppL acc (+ (at idx token-ids) BAR))
                                (ref-U|LST::UC_AppL acc (at idx token-ids))
                            )
                        )
                        []
                        (enumerate 0 (- (length token-ids) 1))
                    )
                )
            )
            (concat [prefix BAR (concat swpair-elements)])
        )
    )
    (defun UC_Prefix:string (weights:[decimal] amp:decimal)
        (let
            (
                (ws:decimal (fold (+) 0.0 weights))
            )
            (if (= amp -1.0)
                (if (= ws 1.0)
                    "W"
                    "P"
                )
                "S"
            )
        )
    )
    ;;
    (defun UC_AreOnPools:[bool] (id1:string id2:string swpairs:[string])
        ;;#37M/M3 fix: empty <swpairs> short-circuits to [] instead of the
        ;;<enumerate 0 -1> / <at 0 []> "Array index out of bounds" crash.
        (if (= 0 (length swpairs))
            []
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[bool] idx:integer)
                        (ref-U|LST::UC_AppL
                            acc
                            (let*
                                (
                                    (pool-tokens:[string] (UC_TokensFromSwpairString (at idx swpairs)))
                                    (iz-id1:bool (contains id1 pool-tokens))
                                    (iz-id2:bool (contains id2 pool-tokens))
                                )
                                (and iz-id1 iz-id2)
                            )
                        )
                    )
                    []
                    (enumerate 0 (- (length swpairs) 1))
                )
            )
        )
    )
    (defun UC_FilterOne:[string] (swpairs:[string] id:string)
        (let*
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (l1:[bool] (UC_IzOnPools id swpairs))
                (l2:[string] (zip (lambda (s:string b:bool) (if b s BAR)) swpairs l1))
                (l3:[string] (ref-U|LST::UC_RemoveItem l2 BAR))
            )
            l3
        )
    )
    (defun UC_FilterTwo:[string] (swpairs:[string] id1:string id2:string)
        (let*
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (l1:[bool] (UC_AreOnPools id1 id2 swpairs))
                (l2:[string] (zip (lambda (s:string b:bool) (if b s BAR)) swpairs l1))
                (l3:[string] (ref-U|LST::UC_RemoveItem l2 BAR))
            )
            l3
        )
    )
    (defun UC_IzOnPool:bool (id:string swpair:string)
        (contains id (UC_TokensFromSwpairString swpair))
    )
    (defun UC_IzOnPools:[bool] (id:string swpairs:[string])
        ;;#37M/M3 fix: empty <swpairs> short-circuits to [] instead of the
        ;;<enumerate 0 -1> / <at 0 []> "Array index out of bounds" crash.
        (if (= 0 (length swpairs))
            []
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[bool] idx:integer)
                        (ref-U|LST::UC_AppL
                            acc
                            (UC_IzOnPool id (at idx swpairs))
                        )
                    )
                    []
                    (enumerate 0 (- (length swpairs) 1))
                )
            )
        )
    )
    (defun UC_MakeGraphNodes:[string] (input-id:string output-id:string swpairs:[string])
        @doc "Builds the BFS node set as every token appearing across the FULL \
            \ passed-down <swpairs> list (the caller is expected to already have \
            \ narrowed <swpairs> to whatever universe should be routable, e.g. \
            \ active-only via <SWP::URC_ActiveSwpairs> — see <SWPI::URC_Hopper>). \
            \ \
            \ #13C fix: previously this only kept swpairs directly touching \
            \ <input-id> or <output-id> (<=1 hop from either end), while \
            \ <SWPT::URC_TokenNeighbours> (post-#21H: reads SWPT|Graph directly) \
            \ read the FULL unrestricted set for each node's links — a node envelope \
            \ narrower than the live edge-set, so BFS could expand into a token \
            \ with no <GraphNode> entry and corrupt/lose the chain. Building nodes \
            \ from the full <swpairs> list makes the envelope equal to the \
            \ edge-set by construction, so that mismatch is now structurally \
            \ impossible. <input-id>/<output-id> stay in the signature (unused) so \
            \ this remains a zero-interface-change fix. \
            \ \
            \ Uses p2-p7 s2-s7 Swpair Information Data via passed down <swpairs>"
        (let*
            (
                (non-distinct-nodes-array:[[string]] (UC_PoolTokensFromPairs swpairs))
                (non-distinct-nodes:[string] (fold (+) [] non-distinct-nodes-array))
            )
            (distinct non-distinct-nodes)
        )
    )
    (defun UC_PoolTokensFromPairs:[[string]] (swpairs:[string])
        ;;#37M/M3 fix: empty <swpairs> short-circuits to [] instead of the
        ;;<enumerate 0 -1> / <at 0 []> "Array index out of bounds" crash. Real,
        ;;live path: SWPU|X>SMART-SWAP's defcap calls this (via UC_UniqueTokens
        ;;-> URC_AllPoolTokens) unconditionally, and <swpairs> is genuinely []
        ;;before the first pool is ever issued.
        (if (= 0 (length swpairs))
            []
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[[string]] idx:integer)
                        (ref-U|LST::UC_AppL
                            acc
                            (UC_TokensFromSwpairString (at idx swpairs))
                        )
                    )
                    []
                    (enumerate 0 (- (length swpairs) 1))
                )
            )
        )
    )
    (defun UC_SpecialFeeOutputs:[decimal] (sftp:[decimal] input-amount:decimal output-precision:integer)
        (if (= (length sftp) 1)
            [input-amount]
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (sftp-sum:decimal (fold (+) 0.0 sftp))
                    (sftp-wl:[decimal] (drop -1 sftp))
                    (ipl:[decimal]
                        (fold
                            (lambda
                                (acc:[decimal] idx:integer)
                                (ref-U|LST::UC_AppL
                                    acc
                                    (floor (* (/ (at idx sftp-wl) sftp-sum) input-amount) output-precision)
                                )
                            )
                            []
                            (enumerate 0 (- (length sftp-wl) 1))
                        )
                    )
                    (ipl-sum:decimal (fold (+) 0.0 ipl))
                    (last:decimal (- input-amount ipl-sum))
                )
                (ref-U|LST::UC_AppL ipl last)
            )
        )
    )
    (defun UC_TokensFromSwpairString:[string] (swpair:string)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (bar:string (ref-U|CT::CT_BAR))
            )
            (drop 1 (ref-U|LST::UC_SplitString bar swpair))
        )
    )
    (defun UC_UniqueTokens:[string] (swpairs:[string])
        (distinct (fold (+) [] (UC_PoolTokensFromPairs swpairs)))
    )
    (defun UC_MakeLiquidityList (swpair:string ptp:integer amount:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (how-many-pts:integer (length (UC_TokensFromSwpairString swpair)))
                (zeroes:[decimal] (make-list how-many-pts 0.0))
            )
            (ref-U|LST::UC_ReplaceAt zeroes ptp amount)
        )
    )
    (defun UC_PoolType:string (swpair:string)
        (take 1 swpair)
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/01_DALOS.pact ===================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; OuronetPolicyV2: already deployed and unchanged -- see LIVE_INTERFACES


;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface OuronetDalosV3
    @doc "Interface exposing the DALOS public API — the sovereign identity, account and \
        \ ledger core. Declares the account and ledger readers, account-ownership \
        \ enforcement, virtual-gas and action-price readers, and the governance hooks \
        \ that other Ouronet modules reference for account authority."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    ;;
    ;;  [GOV]
    ;;
    (defun GOV|DALOS|SC_STOA-NAME ())
    (defun GOV|DALOS|GUARD ())
    ;;
    (defun GOV|Demiurgoi ())
    (defun GOV|DalosKey ())
    (defun GOV|AutostakeKey ())
    (defun GOV|VestingKey ())
    (defun GOV|LiquidKey ())
    (defun GOV|OuroborosKey ())
    (defun GOV|SwapKey ())
    (defun GOV|DHVKey ())
    ;;
    (defun GOV|DALOS|SC_NAME ())
    (defun GOV|ATS|SC_NAME ())
    (defun GOV|VST|SC_NAME ())
    (defun GOV|LIQUID|SC_NAME ())
    (defun GOV|OUROBOROS|SC_NAME ())
    (defun GOV|SWP|SC_NAME ())
    (defun GOV|DHV1|SC_NAME ())
    (defun GOV|DHV2|SC_NAME ())
    ;;
    (defun GOV|DALOS|PBL ())
    (defun GOV|ATS|PBL ())
    (defun GOV|VST|PBL ())
    (defun GOV|LIQUID|PBL ())
    (defun GOV|OUROBOROS|PBL ())
    (defun GOV|SWP|PBL ())
    (defun GOV|DHV|PBL ())

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
    (defschema DPTF|BalanceSchema
        @doc "Schema that Stores Account Balances for DPTF Tokens (True Fungibles)\
            \ Key for the Table is a string composed of: <DPTF id> + BAR + <account> \
            \ This ensure a single entry per DPTF id per account. \
            \ As an Exception OUROBOROS and IGNIS Account Data is Stored at the DALOS Account Level"
        balance:decimal
        frozen:bool
        role-burn:bool
        role-mint:bool
        role-fee-exemption:bool
        role-transfer:bool
        ;;
        ;;ForSelect, store Key Make-up
        id:string
        account:string
    )
    (defschema CanonicalStoaIds
        @doc "#65fL Phase 8b: OURO/WSTOA/SSTOA's canonical token ids, all 3 read together \
            \ in ONE table read (all 3 live on the same DALOS|PropertiesTable row) — \
            \ for a caller (SWPI::URC_WorthWSTOA and its FromRaw/FromGraph siblings) that \
            \ previously needed all 3 identities via 3 separate UR_OuroborosID/ \
            \ UR_WrappedStoaID/UR_SilverStoaID calls, each independently re-reading the \
            \ same row. Field names match DALOS|PropertiesSchema's own field names \
            \ exactly, so the read is a pure passthrough — no renaming/reconstruction."
        gas-source-id:string      ;;OUROBOROS
        wrapped-stoa-id:string    ;;OWS - Ouronet Wrapped Stoa
        silver-stoa-id:string     ;;OSS - Ouronet Silver (Liquid) Stoa
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
    (defun CT_Info ())
    (defun CT_VirtualGasData ())
    ;;
    ;;  [UDC]
    ;;
    (defun UDC_TrueFungibleAccount:object{DPTF|BalanceSchema}
        (a:decimal b:bool c:bool d:bool e:bool f:bool g:string h:string)
    )
    (defun UDC_BlankTrueFungible:object{DPTF|BalanceSchema} (account:string))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;  [UR]
    ;;
    ;;  [0]     DALOS|KadenaLedger:{DALOS|StoaSchema}
    (defun UR_StoaLedger:[string] (stoa:string))
    ;;  [1]     DALOS|PropertiesTable:{DALOS|PropertiesSchema}
    (defun UR_GAP:bool ())
    (defun UR_DemiurgoiID:[string] ())
    (defun UR_UnityID:string ())
    (defun UR_OuroborosID:string ())
    (defun UR_OuroborosPrice:decimal ())
    (defun UR_IgnisID:string ())
    (defun UR_AurynID:string ())
    (defun UR_EliteAurynID:string ())
    (defun UR_WrappedStoaID:string ())
    (defun UR_SilverStoaID:string ())
    ;;#65fL Phase 8b: OURO/WSTOA/SSTOA together, one read instead of 3 — see the
    ;;CanonicalStoaIds schema's own doc.
    (defun UR_CanonicalStoaIds:object{CanonicalStoaIds} ())
    (defun UR_GoldenStoaID:string ())
    (defun UR_UrStoaID:string ())
    (defun UR_DispoType:integer ())
    (defun UR_DispoTDP:decimal ())
    (defun UR_DispoTDS:decimal ())
    (defun UR_OuroAutoPriceUpdate:bool ())
    ;;  [2]     DALOS|GasManagementTable:{DALOS|GasManagementSchema}
    (defun UR_Tanker:string ())
    (defun UR_VirtualToggle:bool ())
    (defun UR_VirtualSpent:decimal ())
    (defun UR_NativeToggle:bool ())
    (defun UR_AccountCreationStoa:bool ())
    (defun UR_NativeSpent:decimal ())
    (defun UR_AutoFuel:bool ())
    ;; [3]      DALOS|PricesTable:{DALOS|PricesSchema}
    (defun UR_UsagePrice:decimal (action:string))
    ;; [4]      DALOS|AccountTable:{DALOS|AccountSchema}
    (defun UR_AccountPublicKey:string (account:string))
    (defun UR_AccountGuard:guard (account:string))
    (defun UR_AccountStoa:string (account:string))
    (defun UR_AccountSovereign:string (account:string))
    (defun UR_AccountGovernor:guard (account:string))
    (defun UR_AccountProperties:[bool] (account:string))
    (defun UR_AccountType:bool (account:string))
    (defun UR_AccountPayableAs:bool (account:string))
    (defun UR_AccountPayableBy:bool (account:string))
    (defun UR_AccountPayableByMethod:bool (account:string))
    (defun UR_AccountNonce:integer (account:string))
    (defun UR_Elite (account:string))
    ;;  [4.1]   ELITE Info
    (defun UR_Elite-Class (account:string))
    (defun UR_Elite-Name (account:string))
    (defun UR_Elite-Tier (account:string))
    (defun UR_Elite-Tier-Major:integer (account:string))
    (defun UR_Elite-Tier-Minor:integer (account:string))
    (defun UR_Elite-DEB (account:string))
    ;;  [4.2]   TrueFungible INFO
    (defun UR_TrueFungible:object{DPTF|BalanceSchema} (account:string snake-or-gas:bool))
    (defun UR_TF_AccountSupply:decimal (account:string snake-or-gas:bool))
    (defun UR_TF_AccountRoleBurn:bool (account:string snake-or-gas:bool))
    (defun UR_TF_AccountRoleMint:bool (account:string snake-or-gas:bool))
    (defun UR_TF_AccountRoleTransfer:bool (account:string snake-or-gas:bool))
    (defun UR_TF_AccountRoleFeeExemption:bool (account:string snake-or-gas:bool))
    (defun UR_TF_AccountFreezeState:bool (account:string snake-or-gas:bool))
    (defun UR_AutonomicRoles:bool (account:string))
    ;;
    ;;  [URC]
    ;;
    (defun URC_IgnisGasDiscount:decimal (account:string))
    (defun URC_StoaGasDiscount:decimal (account:string))
    (defun URC_GasDiscount:decimal (account:string native:bool))
    (defun URC_SplitSTOAPrices:[decimal] (account:string stoa-price:decimal))
    (defun URC_SplitSTOAPricesFull:[decimal] (stoa-price:decimal))
    (defun URC_Transferability:bool (sender:string receiver:string method:bool))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_NotSmartOuronetAccount (account:string))
    (defun UEV_StandardAccOwn (account:string))
    (defun UEV_SmartAccOwn (account:string))
    (defun UEV_EnforceAccountExists (dalos-account:string))
    (defun UEV_EnforceAccountType (account:string smart:bool))
    (defun UEV_EnforceTransferability (sender:string receiver:string method:bool))
    (defun UEV_SenderWithReceiver (sender:string receiver:string))
        ;;
    (defun UEV_StoaCollectionState (state:bool))
    (defun UEV_IgnisCollectionState (state:bool))
    (defun UEV_IgnisCollectionRequirements ())
        ;;
    (defun UEV_Glyph (account:string))
    ;;
    ;;  [CAP]
    ;;
    (defun CAP_EnforceAccountOwnership (account:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [X]
    ;;
    (defun XB_UpdateOuroPrice (price:decimal))
    (defun XE_UpdateTreasury (type:integer tdp:decimal tds:decimal))
    (defun XE_IgnisIncrement (native:bool increment:decimal))
    (defun XE_IncrementOuronetAccountNonce (account:string))
    (defun XE_UpdateElite (account:string amount:decimal))
    (defun XB_UpdateBalance (account:string snake-or-gas:bool new-balance:decimal))
    (defun XE_UpdateFreeze (account:string snake-or-gas:bool new-freeze:bool))
    (defun XE_UpdateBurnRole (account:string snake-or-gas:bool new-burn:bool))
    (defun XE_UpdateMintRole (account:string snake-or-gas:bool new-mint:bool))
    (defun XE_UpdateFeeExemptionRole (account:string snake-or-gas:bool new-fee-exemption:bool))
    (defun XE_UpdateTransferRole (account:string snake-or-gas:bool new-transfer:bool))
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A]
    ;;
    (defun A_MigrateLiquidFunds:decimal (patron:string executor:string migration-target-stoa-account:string))
    (defun A_ToggleOAPU (patron:string executor:string oapu:bool))
    (defun A_ToggleGAP (patron:string executor:string gap:bool))
    (defun A_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string))
    (defun A_DeployStandardAccount (executor:string guard:guard stoa:string public:string))
    (defun A_ToggleGasCollection (patron:string executor:string native:bool toggle:bool))
    (defun A_ToggleAccountCreationStoa (patron:string executor:string toggle:bool))
    (defun A_SetIgnisSourcePrice (patron:string executor:string price:decimal))
    (defun A_SetAutoFueling (patron:string executor:string toggle:bool))
    (defun A_UpdatePublicKey (patron:string executor:string new-public:string))
    (defun A_UpdateUsagePrice (patron:string executor:string action:string new-price:decimal))
    ;;
    ;;  [C]
    ;;
    (defun C_ControlSmartAccount
        (patron:string executor:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool)
    )
    (defun C_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string))
    (defun C_DeployStandardAccount (executor:string guard:guard stoa:string public:string))
    (defun C_RotateGovernor (patron:string executor:string governor:guard))
    (defun C_RotateGuard (patron:string executor:string new-guard:guard safe:bool))
    (defun C_RotateStoa (patron:string executor:string stoa:string))
    (defun C_RotateSovereign (patron:string executor:string new-sovereign:string))


    ;;<=========================================================================>
    ;; ADDED 2026-10-12 -- interface-membership sweep (StoicSyntax-Prefixes.md Sec5,
    ;; owner ruling). Every one of these was already live in the module body; this
    ;; closes the gap between what the module DOES and what its interface SAYS it does.
    ;;<=========================================================================>
    (defun UC_GuardProtocol:string (g:guard))
    (defun UEV_EnforceGuardProtocol (g:guard is-keyset-based:bool))
    (defun UEV_enforce-notional-at-floor:bool ())
    (defun URH_AccountCounter ())
)
;;
(module DALOS GOV
    @doc "DALOS — the sovereign identity, executor and ledger core of Ouronet. Owns the \
        \ Stoa ledger (native-coin balances), the Ouronet executor registry (smart and \
        \ standard accounts with their governance guards), global properties, virtual-gas \
        \ management, action prices and ELITE accounts, plus the namespace and keyset \
        \ governance. Every other module references DALOS to resolve executor ownership \
        \ and authority."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements stoa-ns.gas-payer-v1)
    (implements OuronetPolicyV2)
    (implements OuronetDalosV3)

    ;;<=========================================================================>
    ;;{#}  GASSTATION
    ;;
    ;;Ouronet DALOS Gas-Station
    (defconst DALOS|GAS-BUDGET                          2000000)
    (defconst DALOS|GAS-PRICE-HEADROOM-ANU              100)
    ;;
    (defcap GAS_PAYER:bool (user:string limit:integer price:decimal)
        (let
            (
                (iz-single:bool (contains "exec-code" (read-msg)))
                (exec-lines:[string] (at "exec-code" (read-msg)))
                (n:integer (length exec-lines))
            )
            ;;GENERAL CHECKS
            ;;2]Enforce either GOV|MD_DALOS guard or maximum gas notional 0.02
            (enforce-one
                "Add multiple conditions needed to use Ouronet DALOS Gas-Station"
                [
                    (enforce-guard GOV|MD_DALOS)
                    (UEV_enforce-notional-at-floor)
                    ;;(enforce-guard (ref-U|ST::UEV_max-gas-notional 0.02))
                ]
            )
            ;;UNREACHABLE: <iz-single> and <exec-lines> are bound in the SAME let above, and Pact
            ;;evaluates both eagerly -- so (at "exec-code" …) raises on a message without the key
            ;;before this enforce is ever consulted. A caller who omits exec-code sees
            ;;`Key "exec-code" not found in object: {}` instead of this message. Pinned AS IT
            ;;BEHAVES in REPL/modules/DALOS-ADMIN.repl <<DALOS-G1e>>. To make it live, bind
            ;;<exec-lines> lazily (inside the branch) or hoist this check above the let.
            (enforce iz-single "Only for transactions with code")
            ;; Exec-code: 1 = single allowed form; 2 = only both coin.C_; 3 = namespace+IGNIS+(let
            (enforce (>= n 1) "Empty exec code")
            ;;UNREACHABLE: the line above already enforces n >= 1, and `n=1 or n=2 or n>=3` then
            ;;covers every remaining integer -- a tautology. It reads like a whitelist of accepted
            ;;shapes and is a no-op; the real shape enforcement is the enforce-one below. No input
            ;;can trip it. Demonstrated in REPL/modules/DALOS-ADMIN.repl <<DALOS-G1e>>.
            (enforce (fold (or) false [(= n 1) (= n 2) (>= n 3)]) "Exec code must be 1 form, 2 coin forms, or namespace+IGNIS+let (3+ lines)")
            (enforce-one
                "Payable Modules / form count not satisfied"
                [
                    ;; Case 1: single top-level form — coin.C_, ouronet-ns.TS, or ouronet-ns.DSP only
                    ;;NOTE ON THE MESSAGES BELOW THIS POINT: every enforce / enforce-one nested
                    ;;inside this enforce-one is MUTE. Pact tries each branch, and when all fail
                    ;;it raises the OUTER enforce-one's own message -- so a caller always sees
                    ;;"Payable Modules / form count not satisfied" and never the specific reason.
                    ;;That includes the nested enforce-one "First form must be coin.C_, …", whose
                    ;;message is swallowed exactly like a nested enforce's. Demonstrated by
                    ;;REPL/modules/DALOS-ADMIN.repl <<DALOS-G2c>>, which drives (bogus.thing) and
                    ;;receives the outer message. These strings document intent; they are not
                    ;;diagnostics. If per-case feedback is wanted, the cases have to be dispatched
                    ;;with `if` on the form count instead of raced by enforce-one.
                    (enforce 
                        (fold (and) true
                            [
                                (enforce (= n 1) "Single form required for coin/TS/DSP")
                                (enforce-one "First form must be coin.C_, ouronet-ns.TS, or ouronet-ns.DSP"
                                    [
                                        (enforce (= "(coin.C_" (take 8 (at 0 exec-lines))) "Only STOA coin Client Functions allowed")
                                        (enforce (= "(ouronet-ns.TS" (take 14 (at 0 exec-lines))) "Only TALOS or DSP Modules allowed")
                                        (enforce (= "(ouronet-ns.DSP" (take 15 (at 0 exec-lines))) "Only TALOS or DSP Modules allowed")
                                        (enforce (= "(ouronet-ns.STOAICO." (take 20 (at 0 exec-lines))) "Only STOAICO Modules allowed")
                                    ]
                                )
                            ]
                        )
                        "Ouronet GasStation Case 1 Enforcement Fail!"
                    )
                    ;; Case 2: two top-level forms — both must be coin.C_ (e.g. CreateAccount + Collect)
                    (enforce
                        (fold (and) true
                            [
                                (enforce (= n 2) "Two forms only allowed when both are coin.C_")
                                (enforce (= "(coin.C_" (take 8 (at 0 exec-lines))) "First form must be coin.C_")
                                (enforce (= "(coin.C_" (take 8 (at 1 exec-lines))) "Second form must be coin.C_")
                            ]
                        )
                        "Ouronet GasStation Case 2 Enforcement Fail!"
                    )
                    ;; Case 3: three+ top-level forms — namespace + IGNIS DONATION + (let ...)
                    ;;
                    ;;THE SPONSORED-LET PRODUCT, and it is a PRODUCT, not a leak. The caller pays
                    ;;IGNIS through form 1 and the station funds form 2 -- an arbitrary `let` block
                    ;;of any size -- plus anything appended after it. Forms beyond index 2 are
                    ;;deliberately NOT inspected: they are what the payment BUYS. Rationed
                    ;;execution, with the ration priced at the door.
                    ;;
                    ;;THE DOOR MOVED, 2026-09-20. It used to be a direct
                    ;;`IGNIS.XE_CollectIgnis(... UDC_CustomCodeCumulator)`. That call no longer
                    ;;exists as a client entrypoint: the collectors became IMC-gated X_ functions,
                    ;;so exec-code -- which has no calling module -- cannot reach them. The door is
                    ;;now a TRANSMUTE of the IGNIS DPTF through Talos, which is the IGNIS donation
                    ;;(see TFT::C_Transmute's @doc). It carries a 25-IGNIS floor for exactly this
                    ;;reason: the transmute itself is ignis-free and the station pays the STOA, so
                    ;;without a floor a 0.001 transmute would be a free sponsored transaction,
                    ;;repeatable until the station drained.
                    (enforce
                        (fold (and) true
                            [
                                (enforce (>= n 3) "Three+ lines only for namespace+donation+let pattern")
                                (enforce (= "(namespace \"ouronet-ns\")" (at 0 exec-lines)) "Namespace entry must be (namespace \"ouronet-ns\")")
                                (enforce (= "(TS01-C1.DPTF|C_Transmute" (take 25 (at 1 exec-lines))) "Second form must be the Talos IGNIS donation TS01-C1.DPTF|C_Transmute")
                                (enforce (= "(let" (take 4 (at 2 exec-lines))) "Third form must start with (let")
                            ]
                        )
                        "Ouronet GasStation Case 3 Enforcement Fail!"
                    )
                ]
            )
            ;;
            (compose-capability (DALOS|NATIVE-AUTOMATIC))
        )
    )
    (defun create-gas-payer-guard:guard ()
        GOV|DALOS|GUARD
    )
    (defun CT_VirtualGasData ()                         (at 0 ["VirtualGasData"]))
    (defun UEV_enforce-notional-at-floor:bool ()
        @doc "Enforces that gas-price * gas-limit stays within DALOS|GAS-BUDGET gas units \
            \ priced at the CURRENT protocol minimum. Takes NO argument on purpose: the floor \
            \ is read live from <coin> on every enforcement, so the allowance no longer decays \
            \ as the minimum gas price rises. Comparison is scaled UP into ANU by multiplying, \
            \ never dividing, so no precision is lost."
        (let
            (
                (gas-price:decimal      (at "gas-price" (chain-data)))
                (gas-limit:integer      (at "gas-limit" (chain-data)))
                (floor-anu:integer      (coin.UC_MinimumGasPriceANU))
                (ceiling-anu:integer    (+ floor-anu DALOS|GAS-PRICE-HEADROOM-ANU))
            )
            (enforce
                (<= (* (* gas-price (dec gas-limit)) 1000000000000.0)
                    (* (dec DALOS|GAS-BUDGET) (dec ceiling-anu)))
                (format
                    "Gas notional exceeds the Gas-Station allowance of {} gas at the current protocol minimum of {} ANU"
                    [DALOS|GAS-BUDGET floor-anu]
                )
            )
        )
    )

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DALOS                              (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_DALOS                              (keyset-ref-guard DALOS|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DALOS_ADMIN)))
    (defcap GOV|DALOS_ADMIN ()
        @event
        (enforce-one
            "DALOS Admin not satisfed"
            [
                (enforce-guard GOV|MD_DALOS)
                (enforce-guard GOV|SC_DALOS)
            ]
        )
    )
    (defcap GOV|GAP (gap:bool)
        @event
        (let
            (
                (current-gap:bool (UR_GAP))
            )
            ;;AUTHORISATION FIRST (2026-09-16). The admin gate used to sit BELOW this enforce,
            ;;so a caller asking for the value GAP already holds was refused by the business
            ;;rule with the admin gate never consulted -- the shadowed-gate shape of the
            ;;2026-09-14 ruling. The correctly-ordered twin is ten lines down in this same
            ;;file (DALOS|C>TOGGLE-ACCOUNT-CREATION-STOA), which is why only a scan found this.
            (compose-capability (GOV|DALOS_ADMIN))
            (enforce (!= gap current-gap) (format "GAP is already toggled to {}" [gap]))
        )
    )
    (defcap GOV|MIGRATE (migration-target-stoa-account:string)
        @event
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (target-balance:decimal (ref-coin::get-balance migration-target-stoa-account))
                (gap:bool (UR_GAP))
            )
            ;;WORDING FIXED 2026-09-14 (the LOGIC was always right). This read "...is offline" while
            ;;`(enforce gap ...)` requires gap TRUE -- i.e. the pause ONLINE. An operator reading the
            ;;refusal would disarm the pause and retry forever, doing the exact opposite of what the
            ;;guard wants. The behaviour is deliberate: P|TS, behind nearly every Talos client op,
            ;;enforces (not gap), so demanding GAP ON means the chain is frozen for the whole window
            ;;in which the gas station is empty. Only the message was wrong.
            ;;AUTHORISATION FIRST (2026-09-16), and this one is the 2026-09-14 ruling's own
            ;;motivating shape. GAP OFFLINE IS THE NORMAL STATE, so with the admin gate below
            ;;these enforces every caller -- admin or stranger -- was turned away by the
            ;;business rule and GOV|DALOS_ADMIN was never reached. Deleting it would not have
            ;;changed a single refusal, exactly as with GOV|WIPE_ALL-TREASURY-DEBT.
            ;;DALOS|NATIVE-AUTOMATIC is a C1 `true` with no precondition, so it moves safely.
            (compose-capability (GOV|DALOS_ADMIN))
            (compose-capability (DALOS|NATIVE-AUTOMATIC))
            (enforce gap "Migration can only be executed when Global Administrative Pause is online")
            (enforce (= target-balance 0.0) "Migration can only be executed to an empty stoa account")
        )
    )
    ;;{G5}  functions
    (defun GOV|DALOS|SC_STOA-NAME ()                    (create-principal (GOV|DALOS|GUARD)))
    (defun GOV|DALOS|GUARD ()                           (create-capability-guard (DALOS|NATIVE-AUTOMATIC)))
    (defun GOV|Demiurgoi ()                             (+ (CT_Namespace) ".dh_master-keyset"))
    (defun GOV|DalosKey ()                              (+ (CT_Namespace) ".dh_sc_dalos-keyset"))
    (defun GOV|AutostakeKey ()                          (+ (CT_Namespace) ".dh_sc_autostake-keyset"))
    (defun GOV|VestingKey ()                            (+ (CT_Namespace) ".dh_sc_vesting-keyset"))
    (defun GOV|LiquidKey ()                             (+ (CT_Namespace) ".dh_sc_stoaliquidstaking-keyset"))
    (defun GOV|OuroborosKey ()                          (+ (CT_Namespace) ".dh_sc_ouroboros-keyset"))
    (defun GOV|SwapKey ()                               (+ (CT_Namespace) ".dh_sc_swapper-keyset"))
    (defun GOV|DHVKey ()                                (+ (CT_Namespace) ".dh_sc_dhvault-keyset"))
    ;;
    ;; [SC-Names]
    (defun GOV|DALOS|SC_NAME ()                         (at 0 ["Σ.W∇ЦwÏξБØnζΦψÕłěîбηжÛśTã∇țâĆã4ЬĚIŽȘØíÕlÛřбΩцμCšιÄиMkλ€УщшàфGřÞыÎäY8È₳BDÏÚmßOozBτòÊŸŹjПкцğ¥щóиś4h4ÑþююqςA9ÆúÛȚβжéÑψéУoЭπÄЩψďşõшżíZtZuψ4ѺËxЖψУÌбЧλüșěđΔjÈt0ΛŽZSÿΞЩŠ"]))
    (defun GOV|ATS|SC_NAME ()                           (at 0 ["Σ.ëŤΦșźUÉM89ŹïuÆÒÕ£żíëцΘЯнŹÿxжöwΨ¥Пууhďíπ₱nιrŹÅöыыidõd7ì₿ипΛДĎĎйĄшΛŁPMȘïõμîμŻIцЖljÃαbäЗŸÖéÂЫèpAДuÿPσ8ÎoŃЮнsŤΞìтČ₿Ñ8üĞÕPșчÌșÄG∇MZĂÒЖь₿ØDCПãńΛЬõŞŤЙšÒŸПĘЛΠws9€ΦуêÈŽŻ"]))
    (defun GOV|VST|SC_NAME ()                           (at 0 ["Σ.şZïζhЛßdяźπПЧDΞZülΦпφßΣитœŸ4ó¥ĘкÌЦ₱₱AÚюłćβρèЬÍŠęgĎwтäъνFf9źdûъtJCλúp₿ÌнË₿₱éåÔŽvCOŠŃpÚKюρЙΣΩìsΞτWpÙŠŹЩпÅθÝØpтŮыØșþшу6GтÃêŮĞбžŠΠŞWĆLτЙđнòZЫÏJÿыжU6ŽкЫVσ€ьqθtÙѺSô€χ"]))
    (defun GOV|LIQUID|SC_NAME ()                        (at 0 ["Σ.śκν9₿ŻşYЙΣJΘÊO9jпF₿wŻ¥уPэõΣÑïoγΠθßÙzěŃ∇éÖиțșφΦτşэßιBιśiĘîéòюÚY$êFЬŤØ$868дyβT0ςъëÁwRγПŠτËMĚRПMaäЗэiЪiςΨoÞDŮěŠβLé4čØHπĂŃŻЫΣÀmăĐЗżłÄăiĞ₿йÎEσțłGΛЖΔŞx¥ÁiÙNğÅÌlγ¢ĎwдŃ"]))
    (defun GOV|OUROBOROS|SC_NAME ()                     (at 0 ["Σ.4M0èÞbøXśαiΠ€NùÇèφqλËãØÓNCнÌπпЬ4γTмыżěуàđЫъмéLUœa₿ĞЬŒѺrËQęíùÅЬ¥τ9£φď6pÙ8ìжôYиșîŻøbğůÞχEшäΞúзêŻöŃЮüŞöućЗßřьяÉżăŹCŸNÅìŸпĐżwüăŞãiÜą1ÃγänğhWg9ĚωG₳R0EùçGΨфχЗLπшhsMτξ"]))
    (defun GOV|SWP|SC_NAME ()                           (at 0 ["Σ.fĘĐżØиmΞüȚÓ0âGœȘйцań₿ѺĐЦãúα0šwř4QąйZЛgãŽ₿ßÇöđ2zFtмÄäþťûκpíČX₳ĂBÞãÅhλÚțqýвáêйâ₳ЫDżfÙŃλыêąйíâβPЫůjыáaπÕpnýOĄåęümÚJηğȘôρ8şnνEβęůйΛÑćλòxЧUdÑĎÈčVΞÌFAx£Ы2τżŻzДŽYуRČñÜ"]))
    (defun GOV|DHV1|SC_NAME ()                          (at 0 ["Ѻ.ъΦĞρλξäFφVПÉЫÍЬÙGěЭыц¥ĄïsKзŤ8£ΞδĚãlÍŃÝþáΩĘΞȘĎĄЛδůÖîĎĄΠДÈrЪqyςkѺδKłĄρțØänÀŚxчtÍςÃΩ₳9ť7ÇяŠΛδÓdťЗΞŻÛπΩ∇цжuлiØłÛáYπOкæáYoùχmŒуŞËЛΞьPĘáÛÝaBÑБžя₳țςhrĚë₱dÑLÞЛεñeîÓУłëΦ"]))
    (defun GOV|DHV2|SC_NAME ()                          (+ "Σ" (drop 1 (GOV|DHV1|SC_NAME))))
    (defun GOV|AQP|SC_NAME ()                           (at 0 ["Σ.ЖřÎzэóΣQз3ÌĄăådìÜλÅË9γğ7χûПæ0₳ПûÖŞrĄθXtFìмkщsGвÅgλąÇπЩAĚЭDíéαэБùđáżñИïПÆΣтцξsηåäялÃБц¢r6ÁíäзуμþĄĐЫîÉAćýìЧыQPнŁзßξĂйjay£üѺçRЫfУQșÏΠÜqîÔĄťß6ЗSρŠeΦñëdmûΦøШâΞýκъиřк"]))
    ;;
    ;; [PBLs]
    (defun GOV|DALOS|PBL ()                             (at 0 ["9G.DwF3imJMCp4ht88DD1vx6pdjEkLM4j7Fvzso8zJF7Ixe1p2oKfGb53a5svtEF0Lz1q4MjvHaMrgqCfjlA1cBj2bzvs86EeLIMg2fmutzwbA5vI4woKoqq0acDHllAonxC4qLBulsLclMGwcw9iGxiw919t4tfD8FpcIc4MJ059ki7giFIAyCghgMwwr199v3qiDfIon426rbz1jMLmCe4jhHwD3sEarwMlmzLJ5li43J70CEDzouh7x8pu4u1GxJHa6Cabrsc147gIlzIdDmCC2j87LFpEdvqLge9o0w4av8mLr0lDAfalpnEabfkl0E6zE9KMG7LH2w7uvBIup3Hxxxu2Giwu29Cqye3fJ5ihcjacop4vtcLsi33ip742uAhGzjHaDLwAh933ntp8tEC1zkt9yi6n89JtsDLk477p80rscbGtsi14nxsMf7y0d7GxzE8FFmljElu5yE3vx25cEvc9574Hw4iIi23FFKfdhGF77LMqaBkDB9hJKmpc1B2rM1a8mfilyvLAdzpj57Ae5FG5vvm1n1nzgau373dBF7CuBAu2zbts09du55"]))
    (defun GOV|ATS|PBL ()                               (at 0 ["9H.9I8veD6Lqmcd5nKlb1vlHkg976FhdtooE3iH73h8i2Gq9tLKdclnpo07sC29i2yvMeuB0ikkKghiIgdAfkfDiM57o2phj2quCD8gutjIgDs6AlecMtw2lG6kMMBxBH4B5d1xqhpzA7AHkgEqF7Hgqwpx6E5aIMAtqxIpMhjyqziDiwLA69dKlhlwpjoze34Bwz6swBjlA880ItKfwxtulKEJG9oI3Gjmwgn6bbAgL7xy4brdbgK5DukMBHc0K1jIs1DjcDzhJz2liKultB67rKaBf3nMHMkbzhwl1hdu2wBCeHMLLphug2kE3tDtpxw6kLcj80qfBxvwmuxbeHjk349Md2B7eB4brt8fldi2CxGltfj41KA7GkgmtMa6szivDl5aCk9ozab9ohrsfBHikGL7GJ5Az4A2a8ufnIAJIz2mAgwGDmsAl7yyavbx12e5KhFFupclbKadmiFx8dvqkqwziu4vtt3AcKDhl96EzhuiKAF49vGoaAMo5vxM4h0t94nscG8IGl33De5MJGCpdf3g23D13eJ9BDi034wECutafzao4zzCe9IyvD3E"]))
    (defun GOV|VST|PBL ()                               (at 0 ["9G.5s5hoiGo96tMqyh3JBklmsvo8Lc3ol9m6zavJcCuqg4mBvkbDfcv5gEorMit8v8Mj9Jc18EI36Gq7cJ1IyA4e4wvl199KuCx3chsDKGDdfsvzk8mo317ulGk00pbxu7MLc2zw7joouaxt3Ax1KnlJz153ko0JtIxz7pqylfis45pDo2vvm1MH2kA2wmE2crxiEo6oEckuGqzz8oEaa9ez8ADLyqnj48lq4jGp4slkKo6a06ElezH619fsihIdmiMdfB036CJAr0rlzA2b5DgvEJcoyIFioru7vynBjLMLv3pvLFnbFeswrlyLjF8ry7kB52cD7bD7xaamCEjgIC2DsKMv5Mrd69BIKn2yKHC86f0hme9zs5dwMekAd6mc4wM4bDAk6Jrsl6s74ykKLF71pk45rIE1xxzFC4EjykBf6G0neBdaExI32HufaE5mEloDtvnC6vJ7HA9akkI3616MnLErA8eMIn7Kr2wI4l9CvGpKcF9HilzJmdqMa4kzJwqzuFc9LhDnrKcu0LvBHqsx2CrCM9EwHqpkkGe7w8eK8x0xK6K8drLaoBKmaB1"]))
    (defun GOV|LIQUID|PBL ()                            (at 0 ["9H.b49lfzLzvC25g87fst6MqCkfbuqq39iGu50gDqi9jBEk6Cn86w54b91zDxeGgLdCxIjJDfyi6gBBwA93lyGLcdfggf0LzwKu405piavx0nEnqpzyHK125h2BhECnobmDBAps61c7mGmw5GrczBjvBMLxHwl2avt5jwhKeGxh7Ibm1ui6wI6lpAKBMay4tvEwHK0EibhbeaA2lLqjIwqMKnldp22txeje3DFLautFC798ExbLxG7q3om8l1f9qpMJkw9f5nmHsHGJcrcIF2mou9lmpr3hbz64La6nF9w26h7osABLMLlK9Glp48yrj4h1MkI7xjftytKDnJFyqvoMFqKvA43cJ81bJCvmn63eJ9jx5n3GxFbc9H4v400iFwtyIilmhKymsa1iCnwL29g21DvkaE6JJyxl5eLCiGH3Ml1nb0jkg16zJbf9cfg41KHA0IGFIvLj9LBhj7okL6wspCEBfkc5Aui6DAM7dvAqH54LApEaAzIgyMloEmqvBgt5wF0lyd05xHxz4Mtb3ItGb5fLpzbMGqGKBffi4dElI7Hbs6Id0hCKGaeIg9JL"]))
    (defun GOV|OUROBOROS|PBL ()                         (at 0 ["9H.28jB2BBny4op601Cfqz9brFJKAEo67jbEDJi91i00pGjcD1Mpn0y0A1CxcAwGgBu35Ix3bG4e4p56Mu6x7Mmd50nKfmpDGtLy1ywyCjoDD5xiHBb0y5dAjB0fuokrqyx3ula9rtxyEHK1A4gkG4g3GEyysMtgF40IBgKjm7t8ffGshICIypFeF3gA5x0MixA0soiCx9tBnMDzI6G5xC8yIJJ3Bt2sCvJHAp7HAEA3rKK6Bgnx8hK94oDbgrpCkxw3zpo7tbeHhcakzbg0ELG3EJvk19hyd9LC73t2gizl0B6puq3Ljji5EDAhzno7K32x8vCagc5D2GLiMfdzEzsj5KEe1c2p7hxj76lMvp40r9F56vzlK8Kb7mrKt90ILEMqCghLrok7D4uH8h28EGqbK75wiyguimc1jDGxthyBJFfApClymKA57ehqbv2Lyv323w44b0kIItu35fjmhe2DCBMwjn67ffDII97b6AdyG010wvAHf55xFt25Mbm2pflsggL4D5jHtokl7qn6g4ltM5ilvHvsxn7jHe23Cfgoxn1JssdFMBpcDvB2xki7"]))
    (defun GOV|SWP|PBL ()                               (at 0 ["9G.4Bl3bJ5o1eIoBkhynF39lFdvkA3E0n8m5fBr9iG4D6Ahj3xfop72b98rr33vFFLjqaiozE1btl7lgzKcjHwjzu5GuFqvMb43v9CHHe8je3buLbHMkcAyKdEMD85yIHsb9ty58Kzyado3ho1n1mf9GzpeegMrpK9wDFteeKexdL7HHq8GF7ptD2w45IkMf2A8j4pm7E6vJ1ytCckhclD9nd3JzL2j5cyLxawnE76leKmEmFaxqnF76yyJe5Mu6yLkg2yonJa6vx6jd1kr0hdEf81o42Asr8EcCDeeqD4nAehC3w3pFDMwbln4Mbl6t55GHGephx99LJKH1ojhlMlnyC4bbJFAiyD1h6vs0o7mKAaazFG9y0vfbvM9imcs1vCMmpk2cGDAAAqH6iJe32ugHA3AECEgCvxCskw4Mfx6Cc4rx2BkmKMlxeHqyDceI6wa2qjzuyI80vKg6H6tMwEg48H0ywIMDyxteDfHav08eEJE2lljEIAc1jxLlLcosbiknAyxJvu8g7kA4oAlcio2jI8lMxp76vosd5FxpatowuFktILfyCFyHvKfcozy"]))
    (defun GOV|DHV|PBL ()                               (at 0 ["9G.7G3mkhkk34Bg37uslsu3M7psBc40xsKFibE9DL0jb43JcJ7fzDh9cz3Edn8uvlkh0bCeFafFntCKt0HvJsmczx3Lek9d3mqr38BbIwmBrDkd8sordjr4L7tJ5Fnqj39F6s55hD3rEFvMGors4sws3lDcKiEHkMEE7kHuuB31gGe3F5HsI0yHbwsm2IcspsB1ICiD1g73vup127pjLauIc6gxl3sJy0lAml1uA9g18Btcl6prinGmo3uFomeoyvx9oLGlf6ctFsfavKa5vFrvaw2FB1KsAiejqqjaeMu1I1cEey3m55allFm5pg9LaFK307qnmjxfmqv38vvr2wBerI4BnvFKLgpB7e7pCCmarDJq1l6nHEIv6wl3d96iwAqEHxKEwpH7ljzqnsnBpcEFlpKu6xjc5o78DiwzrltiDxa5c9ug7wML3MGqDEH9tzIj2IreF5yEnw4M15yy38z7gqKbd7l3Fb3qc7kvrgHKG8cpq9M54kg6v5a1k7Laqea07ynccK6r2bjwl7L8IkE7EsAep77M1kb4455klFFH2qx2uEuGBlfsu1rztiMa"]))

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
    ;;{P5}  functions
    (defun P|Info ()                                    (at 0 ["InterModulePolicies"]))
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
        (with-capability (GOV|DALOS_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DALOS_ADMIN)
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
        (with-capability (GOV|DALOS_ADMIN)
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
        (with-capability (GOV|DALOS_ADMIN)
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
        true
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DALOS|SC_KEY                              (GOV|DalosKey))
    (defconst DALOS|SC_NAME                             (GOV|DALOS|SC_NAME))
    (defconst DALOS|SC_STOA-NAME                        (GOV|DALOS|SC_STOA-NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst DALOS|INFO                                (CT_Info))
    (defconst DALOS|VGD                                 (CT_VirtualGasData))
    (defconst DALOS|PLEB
        {"class"    : "NOVICE"
        ,"name"     : "Infidel"
        ,"tier"     : "0.0"
        ,"deb"      : 1.0 }
    )
    (defconst DALOS|VOID
        {"class"    : "VOID"
        ,"name"     : "Undead"
        ,"tier"     : "0.0"
        ,"deb"      : 0.0 }
    )
    ;;{3.2}  schemas
    ;;
    (defschema DALOS|StoaSchema
        dalos:[string]
    )
    (defschema DALOS|PropertiesSchema
        global-administrative-pause:bool    ;;Stores the GAP Boolean
        demiurgoi:[string]                  ;;Stores Demiurgoi DALOS Accounts
        unity-id:string                     ;;Unity
        gas-source-id:string                ;;OUROBOROS
        gas-source-id-price:decimal         ;;OUROBOROS Price
        gas-id:string                       ;;IGNIS
        ats-gas-source-id:string            ;;AURYN
        elite-ats-gas-source-id:string      ;;ELITE-AURYN
        wrapped-stoa-id:string              ;;OWS - Ouronet Wrapped Stoa
        silver-stoa-id:string               ;;OSS - Ouronet Silver (Liquid) Stoa
        golden-stoa-id:string               ;;OGS - Ouronet Golden (Pension) Stoa
        ur-stoa-id:string                   ;;OUS - Ouronet UrStoa
        ;;
        treasury-dispo-type:integer
        treasury-dynamic-promille:decimal
        treasury-static-tds:decimal
        ;;
        ouro-auto-price-via-swaps:bool      ;;Determines if Ouro Price Auto Update Via Swaps is on
    )
    (defschema DALOS|GasManagementSchema
        virtual-gas-tank:string             ;;IGNIS|SC_NAME = "GasTanker"
        virtual-gas-toggle:bool             ;;IGNIS collection toggle
        virtual-gas-spent:decimal           ;;IGNIS spent
        native-gas-toggle:bool              ;;STOA collection toggle
        native-gas-spent:decimal            ;;STOA spent
        native-gas-pump:bool                ;;controls automatic LiquidStaking fueling
        account-creation-stoa:bool          ;;STOA collection on Ouronet ACCOUNT CREATION only.
                                            ;;Deliberately INDEPENDENT of native-gas-toggle so the
                                            ;;global STOA collection can be ON while onboarding
                                            ;;stays free. Default FALSE (onboarding is free).
    )
    (defschema DALOS|PricesSchema
        price:decimal                       ;;Stores price for action
    )
    (defschema DALOS|AccountSchemaV2
        @doc "Schema that stores Ouronet (DALOS) Account Information"
        public:string
        guard:guard
        ;;STORED COLUMN NAME -- DO NOT RENAME. Reverted 2026-09-24 after an outage.
        ;;
        ;;The 2026-08-31 KDA->STOA sweep (0b0ad318) renamed this field `kadena-konto` ->
        ;;`stoa-konto` along with the function that reads it. Renaming the FUNCTION was correct.
        ;;Renaming the COLUMN was not: a Pact module upgrade REWRITES CODE AND LEAVES ROWS
        ;;UNTOUCHED, so every account already on chain kept a `kadena-konto` field while the new
        ;;code asked for `stoa-konto`. UR_AccountStoa then threw "Key stoa-konto not found in
        ;;object" for EVERY account -- verified live on the owner's account, the Stage Two
        ;;bucket, and DALOS's own smart account -- taking out 33 call sites across 9 modules and
        ;;blanking the dashboard.
        ;;
        ;;A COLUMN NAME IS A WIRE FORMAT. It is the one identifier in a module that is shared
        ;;with data that outlives the code. Rename freely above this line; never here.
        ;;
        ;;The other fields that sweep renamed -- ClientStoaCosts' stoa-discount/full/need/split/
        ;;targets/text -- were safe precisely because that schema backs no table: it is built,
        ;;returned and discarded. That is the distinction, and it is worth checking before the
        ;;next sweep rather than after.
        kadena-konto:string
        sovereign:string
        governor:guard
        ;;
        smart-contract:bool
        payable-as-smart-contract:bool
        payable-by-smart-contract:bool
        payable-by-method:bool
        ;;
        nonce:integer
        elite:object{DALOS|EliteSchema}
        ouroboros:object{OuronetDalosV3.DPTF|BalanceSchema}
        ignis:object{OuronetDalosV3.DPTF|BalanceSchema}
    )
    (defschema DALOS|EliteSchema
        class:string
        name:string
        tier:string
        deb:decimal
    )
    ;;{3.3}  tables
    ;;THE SAME MISTAKE AS `kadena-konto`, AND FROM THE SAME COMMIT. 0b0ad318 renamed the column
    ;;AND this table -- KadenaLedger -> StoaLedger. The column was reverted on 2026-09-24 when the
    ;;dashboard went down; the TABLE was missed, because a renamed table does not throw the way a
    ;;renamed column does. It just is not there, and Pact reports it as though it were merely
    ;;uncreated: "Table access failed because table ... was not found".
    ;;
    ;;That reading is what nearly cost the data. The repair looked like a missing `create-table`,
    ;;and creating it would have made an EMPTY DALOS|StoaLedger beside a populated
    ;;DALOS|KadenaLedger that nothing could reach any more -- every account's Stoa-key ledger
    ;;orphaned, silently, with the page looking fixed.
    ;;
    ;;A TABLE NAME IS A WIRE FORMAT, exactly as a column name is. The FUNCTIONS stay renamed --
    ;;UR_StoaLedger, XI_UpdateStoaLedger -- because a function name is not shared with anything
    ;;that outlives the code. Only the two identifiers the database holds are pinned:
    ;;
    ;;    the table  DALOS|KadenaLedger      (here)
    ;;    the column kadena-konto            (in DALOS|AccountSchemaV2, ~line 825)
    ;;
    ;;Rename freely around them; never these.
    (deftable DALOS|KadenaLedger:{DALOS|StoaSchema})            ;;Key = <k:account>
    (deftable DALOS|PropertiesTable:{DALOS|PropertiesSchema})       ;;Key = DALOS|INFO
    (deftable DALOS|GasManagementTable:{DALOS|GasManagementSchema}) ;;Key = DALOS|VGD
    (deftable DALOS|PricesTable:{DALOS|PricesSchema})               ;;Key = <action>
    (deftable DALOS|AccountTable:{DALOS|AccountSchemaV2})           ;;Key = <account>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap DALOS|NATIVE-AUTOMATIC  ()
        @doc "Autonomic management of <kadena-konto> of the DALOS Smart Ouronet Account"
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap DALOS|S>SET-OURO-PRICE (price:decimal)
        @event
        (let
            (
                (dalos-guard:guard (UR_AccountGuard DALOS|SC_NAME))
                (dalos-sov-guard:guard (UR_AccountGuard (UR_AccountSovereign DALOS|SC_NAME)))
                (dalos-gov-guard:guard (UR_AccountGovernor DALOS|SC_NAME))
            )
            (enforce-one
                "Permission not granted to Update OURO Price !"
                [
                    (enforce-guard dalos-guard)
                    (enforce-guard dalos-sov-guard)
                    (enforce-guard dalos-gov-guard)
                    (enforce-guard GOV|MD_DALOS)
                    (enforce-guard GOV|SC_DALOS)
                ]
            )
        )
    )
    (defcap DALOS|S>ROTATE-OA-SOVEREIGN (account:string new-sovereign:string)
        @event
        (CAP_EnforceAccountOwnership account)
        (UEV_EnforceAccountType account true)
        (UEV_EnforceAccountType new-sovereign false)
        (UEV_SenderWithReceiver (UR_AccountSovereign account) new-sovereign)
    )
    ;;{C3}  Composed
    ;;
    ;;
    (defcap AHU ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ah:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
            )
            (ref-DALOS::CAP_EnforceAccountOwnership ah)
            (compose-capability (SECURE))
        )
    )
    (defcap SECURE-ADMIN ()
        (compose-capability (SECURE))
        (compose-capability (GOV|DALOS_ADMIN))
    )
    (defcap DALOS|C>TOGGLE-GAS-COLLECTION (native:bool toggle:bool)
        (compose-capability (GOV|DALOS_ADMIN))
        (if native
            (UEV_StoaCollectionState (not toggle))
            (UEV_IgnisCollectionState (not toggle))
        )
    )
    (defcap DALOS|C>TOGGLE-ACCOUNT-CREATION-STOA (toggle:bool)
        @doc "Admin gate for the account-creation STOA switch. Deliberately does NOT reuse \
            \ DALOS|C>TOGGLE-GAS-COLLECTION: that one validates the GLOBAL STOA state, which \
            \ would couple this switch to the very flag it must stay independent of. Guards \
            \ only against a redundant flip of its own field."
        (compose-capability (GOV|DALOS_ADMIN))
        (enforce (!= toggle (UR_AccountCreationStoa))
            "Account-creation STOA collection is already in that state")
    )
    (defcap DALOS|C>CONTROL-SMART-OURONET-ACCOUNT (account:string pasc:bool pbsc:bool pbm:bool)
        @event
        (compose-capability (DALOS|F>GOV account))
        (enforce (= (or (or pasc pbsc) pbm) true) "At least one Smart DALOS Account parameter must be true")
    )
    (defcap DALOS|C>DEPLOY-STANDARD-OURONET-ACCOUNT (account:string guard:guard stoa:string)
        @event
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
                (first:string (take 1 account))
                (ouroboros:string "Ѻ")
            )
            (ref-U|G::UEV_Any
                [
                    guard
                    (create-capability-guard (GOV))
                ]
            )
            (enforce (= first ouroboros) (format "Account {} doesn|t have the corrrect Format for a Standard DALOS Account" [account]))
            (UEV_Glyph account)
            (UEV_EnforceGuardProtocol guard true)
            (compose-capability (SECURE))
        )
    )
    (defcap DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT (account:string guard:guard stoa:string sovereign:string)
        @event
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
                (first:string (take 1 account))
                (sigma:string "Σ")
            )
            (ref-U|G::UEV_Any
                [
                    guard
                    (create-capability-guard (GOV))
                ]
            )
            (enforce (= first sigma) (format "Account {} doesn|t have the corrrect Format for a Smart DALOS Account" [account]))
            (UEV_Glyph account)
            (UEV_EnforceAccountType sovereign false)
            (UEV_EnforceGuardProtocol guard true)
            (compose-capability (SECURE))
        )
    )
    ;;#26M fix: dedicated client cap for the admin (fee-free) deploy path, composing the shared
    ;;validation above rather than duplicating it - keeps A_DeploySmartAccount's own admin gate
    ;;(GOV|DALOS_ADMIN) distinct from C_DeploySmartAccount's, while both funnel into the same
    ;;single definition of the account-format/guard validation.
    (defcap DALOS|A>DEPLOY-SMART-OURONET-ACCOUNT (account:string guard:guard stoa:string sovereign:string)
        @event
        (compose-capability (GOV|DALOS_ADMIN))
        (compose-capability (DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT account guard stoa sovereign))
    )
    (defcap DALOS|C>ROTATE-OA_GOVERNOR (account:string governor:guard)
        @event
        (UEV_EnforceGuardProtocol governor false)
        (compose-capability (DALOS|F>GOV account))
    )
    (defcap DALOS|C>ROTATE-OA-GUARD (account:string new-guard:guard safe:bool)
        @event
        (UEV_EnforceGuardProtocol new-guard true)
        (if safe
            (enforce-guard new-guard)
            true
        )
        (compose-capability (SECURE))
        (compose-capability (DALOS|F>OWNER account))
    )
    (defcap DALOS|C>ROTATE-OA-STOA (account:string)
        @event
        (compose-capability (SECURE))
        (compose-capability (DALOS|F>OWNER account))
    )
    ;;{C4}  Ownership [gold]
    (defcap DALOS|F>OWNER (account:string)
        (CAP_EnforceAccountOwnership account)
    )
    (defcap DALOS|F>GOV (account:string)
        (CAP_EnforceAccountOwnership account)
        (UEV_EnforceAccountType account true)
    )

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    ;; [Keys]
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
    (defun CT_Info ()                                   (at 0 ["DalosInformation"]))
    ;;
    (defun UDC_TrueFungibleAccount:object{OuronetDalosV3.DPTF|BalanceSchema}
        (a:decimal b:bool c:bool d:bool e:bool f:bool g:string h:string)
        {"balance"              : a
        ,"frozen"               : b
        ,"role-burn"            : c
        ,"role-mint"            : d
        ,"role-fee-exemption"   : e
        ,"role-transfer"        : f
        ,"id"                   : g
        ,"account"              : h}
    )
    (defun UDC_BlankTrueFungible:object{OuronetDalosV3.DPTF|BalanceSchema} (account:string)
        (UDC_TrueFungibleAccount 0.0 false false false false false BAR account)
    )
    ;;{5.2}  Compute [UC]
    (defun UC_GuardProtocol:string (g:guard)
        @doc "Principal protocol prefix for a guard (k:/w:/r:/u:/c:/m:/p:)."
        (typeof-principal (create-principal g))
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URH_AccountCounter ()
        (format "Ouronet has {} real Accounts!"
            [(length (keys DALOS|AccountTable))]
        )
    )
    ;;[0]   DALOS|KadenaLedger:{DALOS|StoaSchema}
    (defun UR_StoaLedger:[string] (stoa:string)
        (with-default-read DALOS|KadenaLedger stoa
            { "dalos"    : [BAR] }
            { "dalos"    := d }
            d
        )
    )
    ;;[1]   DALOS|PropertiesTable:{DALOS|PropertiesSchema}
    (defun UR_GAP:bool ()
        (at "global-administrative-pause" (read DALOS|PropertiesTable DALOS|INFO ["global-administrative-pause"]))
    )
    (defun UR_DemiurgoiID:[string] ()
        (at "demiurgoi" (read DALOS|PropertiesTable DALOS|INFO ["demiurgoi"]))
    )
    (defun UR_UnityID:string ()
        (at "unity-id" (read DALOS|PropertiesTable DALOS|INFO ["unity-id"]))
    )
    (defun UR_OuroborosID:string ()
        (at "gas-source-id" (read DALOS|PropertiesTable DALOS|INFO ["gas-source-id"]))
    )
    (defun UR_OuroborosPrice:decimal ()
        (at "gas-source-id-price" (read DALOS|PropertiesTable DALOS|INFO ["gas-source-id-price"]))
    )
    (defun UR_IgnisID:string ()
        (with-default-read DALOS|PropertiesTable DALOS|INFO
            { "gas-id" :  BAR }
            { "gas-id" := gas-id}
            gas-id
        )
    )
    (defun UR_AurynID:string ()
        (at "ats-gas-source-id" (read DALOS|PropertiesTable DALOS|INFO ["ats-gas-source-id"]))
    )
    (defun UR_EliteAurynID:string ()
        (at "elite-ats-gas-source-id" (read DALOS|PropertiesTable DALOS|INFO ["elite-ats-gas-source-id"]))
    )
    (defun UR_WrappedStoaID:string ()
        (at "wrapped-stoa-id" (read DALOS|PropertiesTable DALOS|INFO ["wrapped-stoa-id"]))
    )
    (defun UR_SilverStoaID:string ()
        (at "silver-stoa-id" (read DALOS|PropertiesTable DALOS|INFO ["silver-stoa-id"]))
    )
    (defun UR_CanonicalStoaIds:object{OuronetDalosV3.CanonicalStoaIds} ()
        @doc "#65fL Phase 8b: OURO/WSTOA/SSTOA together in ONE read, for a caller that \
            \ needs all 3 identities to check against a single <id> (e.g. \
            \ SWPI::URC_WorthWSTOA's 3-way WSTOA/SSTOA/OURO shortcut dispatch) — replaces \
            \ 3 independent single-field reads of the same row with 1 multi-field \
            \ read of it."
        (read DALOS|PropertiesTable DALOS|INFO ["gas-source-id" "wrapped-stoa-id" "silver-stoa-id"])
    )
    (defun UR_GoldenStoaID:string ()
        (at "golden-stoa-id" (read DALOS|PropertiesTable DALOS|INFO ["golden-stoa-id"]))
    )
    (defun UR_UrStoaID:string ()
        (at "ur-stoa-id" (read DALOS|PropertiesTable DALOS|INFO ["ur-stoa-id"]))
    )
    (defun UR_DispoType:integer ()
        (at "treasury-dispo-type" (read DALOS|PropertiesTable DALOS|INFO ["treasury-dispo-type"]))
    )
    (defun UR_DispoTDP:decimal ()
        (at "treasury-dynamic-promille" (read DALOS|PropertiesTable DALOS|INFO ["treasury-dynamic-promille"]))
    )
    (defun UR_DispoTDS:decimal ()
        (at "treasury-static-tds" (read DALOS|PropertiesTable DALOS|INFO ["treasury-static-tds"]))
    )
    (defun UR_OuroAutoPriceUpdate:bool ()
        (at "ouro-auto-price-via-swaps" (read DALOS|PropertiesTable DALOS|INFO ["ouro-auto-price-via-swaps"]))
    )
    ;;[2]   DALOS|GasManagementTable:{DALOS|GasManagementSchema}
    (defun UR_Tanker:string ()
        (at "virtual-gas-tank" (read DALOS|GasManagementTable DALOS|VGD ["virtual-gas-tank"]))
    )
    (defun UR_VirtualToggle:bool ()
        (with-default-read DALOS|GasManagementTable DALOS|VGD
            {"virtual-gas-toggle" : false}
            {"virtual-gas-toggle" := tg}
            tg
        )
    )
    (defun UR_VirtualSpent:decimal ()
        (at "virtual-gas-spent" (read DALOS|GasManagementTable DALOS|VGD ["virtual-gas-spent"]))
    )
    (defun UR_NativeToggle:bool ()
        (with-default-read DALOS|GasManagementTable DALOS|VGD
            {"native-gas-toggle" : false}
            {"native-gas-toggle" := tg}
            tg
        )
    )
    (defun UR_AccountCreationStoa:bool ()
        @doc "Is STOA collected on Ouronet account creation? Independent of the global STOA \
            \ toggle (UR_NativeToggle) so onboarding can stay free while global STOA is ON. \
            \ Defaults FALSE for rows written before this flag existed."
        (with-default-read DALOS|GasManagementTable DALOS|VGD
            {"account-creation-stoa" : false}
            {"account-creation-stoa" := t}
            t
        )
    )
    (defun UR_NativeSpent:decimal ()
        (at "native-gas-spent" (read DALOS|GasManagementTable DALOS|VGD ["native-gas-spent"]))
    )
    (defun UR_AutoFuel:bool ()
        (at "native-gas-pump" (read DALOS|GasManagementTable DALOS|VGD ["native-gas-pump"]))
    )
    ;;[3]   DALOS|PricesTable:{DALOS|PricesSchema}
    (defun UR_UsagePrice:decimal (action:string)
        (at "price" (read DALOS|PricesTable action ["price"]))
    )
    ;;[4]   DALOS|AccountTable:{DALOS|AccountSchemaV2}
    (defun UR_AccountPublicKey:string (account:string)
        (at "public" (read DALOS|AccountTable account ["public"]))
    )
    (defun UR_AccountGuard:guard (account:string)
        (at "guard" (read DALOS|AccountTable account ["guard"]))
    )
    (defun UR_AccountStoa:string (account:string)
        (at "kadena-konto" (read DALOS|AccountTable account ["kadena-konto"]))
    )
    (defun UR_AccountSovereign:string (account:string)
        (at "sovereign" (read DALOS|AccountTable account ["sovereign"]))
    )
    (defun UR_AccountGovernor:guard (account:string)
        (at "governor" (read DALOS|AccountTable account ["governor"]))
    )
    (defun UR_AccountProperties:[bool] (account:string)
        (with-default-read DALOS|AccountTable account
            { "smart-contract" : false, "payable-as-smart-contract" : false, "payable-by-smart-contract" : false, "payable-by-method" : false}
            { "smart-contract" := sc, "payable-as-smart-contract" := pasc, "payable-by-smart-contract" := pbsc, "payable-by-method" := pbm }
            [sc pasc pbsc pbm]
        )
    )
    (defun UR_AccountType:bool (account:string)
        (at 0 (UR_AccountProperties account))
    )
    (defun UR_AccountPayableAs:bool (account:string)
        (at 1 (UR_AccountProperties account))
    )
    (defun UR_AccountPayableBy:bool (account:string)
        (at 2 (UR_AccountProperties account))
    )
    (defun UR_AccountPayableByMethod:bool (account:string)
        (at 3 (UR_AccountProperties account))
    )
    (defun UR_AccountNonce:integer (account:string)
        @doc "Patron transaction counter on DALOS|AccountTable (incremented by IGNIS XE_CollectIgnis when virtual gas is charged)."
        (with-default-read DALOS|AccountTable account
            { "nonce" : 0 }
            { "nonce" := n }
            n
        )
    )
    (defun UR_Elite (account:string)
        (with-default-read DALOS|AccountTable account
            { "elite" : DALOS|PLEB }
            { "elite" := e}
            e
        )
    )
    ;;[4.1] ELITE Info
    (defun UR_Elite-Class (account:string)
        (at "class" (UR_Elite account))
    )
    (defun UR_Elite-Name (account:string)
        (at "name" (UR_Elite account))
    )
    (defun UR_Elite-Tier (account:string)
        (at "tier" (UR_Elite account))
    )
    (defun UR_Elite-Tier-Major:integer (account:string)
        (str-to-int (take 1 (UR_Elite-Tier account)))
    )
    (defun UR_Elite-Tier-Minor:integer (account:string)
        (str-to-int (take -1 (UR_Elite-Tier account)))
    )
    (defun UR_Elite-DEB (account:string)
        (at "deb" (UR_Elite account))
    )
    ;;[4.2] TrueFungible INFO
    (defun UR_TrueFungible:object{OuronetDalosV3.DPTF|BalanceSchema}
        (account:string snake-or-gas:bool)
        (if snake-or-gas
            (with-default-read DALOS|AccountTable account
                { "ouroboros" : (UDC_BlankTrueFungible account) }
                { "ouroboros" := o}
                o
            )
            (with-default-read DALOS|AccountTable account
                { "ignis" : (UDC_BlankTrueFungible account) }
                { "ignis" := i}
                i
            )
        )
    )
    (defun UR_TF_AccountSupply:decimal (account:string snake-or-gas:bool)
        (at "balance" (UR_TrueFungible account snake-or-gas))
    )
    (defun UR_TF_AccountRoleBurn:bool (account:string snake-or-gas:bool)
        (at "role-burn" (UR_TrueFungible account snake-or-gas))
    )
    (defun UR_TF_AccountRoleMint:bool (account:string snake-or-gas:bool)
        (at "role-mint" (UR_TrueFungible account snake-or-gas))
    )
    (defun UR_TF_AccountRoleTransfer:bool (account:string snake-or-gas:bool)
        (at "role-transfer" (UR_TrueFungible account snake-or-gas))
    )
    (defun UR_TF_AccountRoleFeeExemption:bool (account:string snake-or-gas:bool)
        (at "role-fee-exemption" (UR_TrueFungible account snake-or-gas))
    )
    (defun UR_TF_AccountFreezeState:bool (account:string snake-or-gas:bool)
        (at "frozen" (UR_TrueFungible account snake-or-gas))
    )
    ;;
    (defun UR_AutonomicRoles:bool (account:string)
        (fold (or) false 
            [
                (= account DALOS|SC_NAME)
                (= account (GOV|ATS|SC_NAME))
                (= account (GOV|VST|SC_NAME))
                (= account (GOV|LIQUID|SC_NAME))
                (= account (GOV|OUROBOROS|SC_NAME))
                (= account (GOV|SWP|SC_NAME))
                (= account (GOV|DHV2|SC_NAME))
                (= account (GOV|AQP|SC_NAME))
            ]
        )
    )
    ;;
    (defun URC_IgnisGasDiscount:decimal (account:string)
        @doc "Computes the Discount for Ignis Gas Costs. A value of 1.00 means no discount"
        (URC_GasDiscount account false)
    )
    (defun URC_StoaGasDiscount:decimal (account:string)
        @doc "Computes the Discount for Stoa Gas Costs. A value of 1.00 means no discount"
        (URC_GasDiscount account true)
    )
    (defun URC_GasDiscount:decimal (account:string native:bool)
        @doc "Computes Gas Discount Values, a value of 1.00 means no discount"
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (major:integer (UR_Elite-Tier-Major account))
                (minor:integer (UR_Elite-Tier-Minor account))
            )
            (ref-U|DALOS::UC_GasCost 1.00 major minor native)
        )
    )
    (defun URC_SplitSTOAPrices:[decimal] (account:string stoa-price:decimal)
        @doc "Computes the STOA Split required for Native Gas Collection \
          \ This is 10% 20% 30% and 40% split, outputed as 4 element list \
          \ Takes in consideration the Discounted STOA for <account>"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-discount:decimal (URC_StoaGasDiscount account))
                (discounted-stoa:decimal (* stoa-discount stoa-price))
            )
            (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit discounted-stoa stoa-prec)
        )
    )
    (defun URC_SplitSTOAPricesFull:[decimal] (stoa-price:decimal)
        @doc "Same 10/20/30/40 STOA split as URC_SplitSTOAPrices but WITHOUT the Elite \
            \ discount — for the rare costs the pricing spec says are taxed in FULL (PYTHIA's \
            \ fees, and some asymmetric-liquidity legs). Takes no account precisely BECAUSE no \
            \ account-dependent discount applies."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
            )
            (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit stoa-price (ref-U|CT::CT_STOA_PRECISION))
        )
    )
    (defun URC_Transferability:bool (sender:string receiver:string method:bool)
        @doc "Computes Transferability of Assets between a <sender> and a <receiver> with the given <method>"
        (UEV_SenderWithReceiver sender receiver)
        (let
            (
                (s-sc:bool (UR_AccountType sender))
                (r-sc:bool (UR_AccountType receiver))
                (r-pasc:bool (UR_AccountPayableAs receiver))
                (r-pbsc:bool (UR_AccountPayableBy receiver))
                (r-mt:bool (UR_AccountPayableByMethod receiver))
            )
            (if (= s-sc false)
                (if (= r-sc false)              ;;sender is normal
                    true                        ;;receiver is normal (Normal => Normal | Case 1)
                    (if (= method true)         ;;receiver is smart  (Normal => Smart | Case 3)
                        r-mt
                        r-pasc
                    )
                )
                (if (= r-sc false)              ;;sender is smart
                    true                        ;;receiver is normal (Smart => Normal | Case 4)
                    (if (= method true)         ;;receiver is false (Smart => Smart | Case 2)
                        r-mt
                        r-pbsc
                    )
                )
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_NotSmartOuronetAccount (account:string)
        (enforce (not (UR_AutonomicRoles account)) "Non Smart Ouronet Accounts required for exec")
    )
    (defun UEV_StandardAccOwn (account:string)
        @doc "Validates Ownership for a Standard Ouronet Account"
        (let
            (
                (account-guard:guard (UR_AccountGuard account))
                (sovereign:string (UR_AccountSovereign account))
                (governor:guard (UR_AccountGovernor account))
            )
            (enforce (= sovereign account) "Incompatible Sovereign detected for a Standard DALOS Account")
            (enforce (= account-guard governor) "Incompatible Governer Guard detected for Standard DALOS Account")
            (enforce-guard account-guard)
        )
    )
    (defun UEV_SmartAccOwn (account:string)
        @doc "Validates Ownership for a Smart Ouronet Account"
        (let
            (
                (account-guard:guard (UR_AccountGuard account))
                (sovereign:string (UR_AccountSovereign account))
                (sovereign-guard:guard (UR_AccountGuard sovereign))
                (governor:guard (UR_AccountGovernor account))
            )
            (enforce (!= sovereign account) "Incompatible Sovereign detected for Smart DALOS Account")
            (enforce-one
                (format "Smart DALOS Account {} Ownership could not be verified!" [account])
                [
                    (enforce-guard account-guard)
                    (enforce-guard sovereign-guard)
                    (enforce-guard governor)
                ]
            )
        )
    )
    (defun UEV_EnforceAccountExists (dalos-account:string)
        @doc "Enforces a given <dalos-account> exists by reading its DEB"
        (with-default-read DALOS|AccountTable dalos-account
            { "elite" : DALOS|VOID }
            { "elite" := e }
            (let
                (
                    (deb:decimal (at "deb" e))
                )
                (enforce
                    (>= deb 1.0)
                    (format "The {} DALOS Account doesnt exist" [dalos-account])
                )
            )
        )
    )
    (defun UEV_EnforceAccountType (account:string smart:bool)
        @doc "Enforces that <account> is of type <smart> (either Standard or Smart Ouronet Account)"
        (let
            (
                (x:bool (UR_AccountType account))
                (first:string (take 1 account))
                (ouroboros:string "Ѻ")
                (sigma:string "Σ")
            )
            (if smart
                (enforce (and (= first sigma) (= x true)) (format "Operation requires a Smart DALOS Account; Account {} isnt" [account]))
                (enforce (and (= first ouroboros) (= x false)) (format "Operation requires a Standard DALOS Account; Account {} isnt" [account]))
            )
        )
    )
    (defun UEV_EnforceTransferability (sender:string receiver:string method:bool)
        @doc "Enforces transferability between <sender> and <receiver> with <method>"
        (let
            (
                (x:bool (URC_Transferability sender receiver method))
            )
            (enforce (= x true) (format "Transferability between {} and {} with {} Method is not ensured" [sender receiver method]))
        )
    )
    (defun UEV_SenderWithReceiver (sender:string receiver:string)
        @doc "Enforces <sender> and <receiver> are valid for a transfer event"
        (UEV_EnforceAccountExists sender)
        (UEV_EnforceAccountExists receiver)
        (enforce (!= sender receiver) "Sender and Receiver must be different")
    )
    (defun UEV_StoaCollectionState (state:bool)
        (let
            (
                (t:bool (UR_NativeToggle))
            )
            (enforce (= t state) "Invalid native gas collection state!")
        )
    )
    (defun UEV_IgnisCollectionState (state:bool)
        (let
            (
                (t:bool (UR_VirtualToggle))
            )
            (enforce (= t state) "Invalid virtual gas collection state!")
            (if (not state)
                (UEV_IgnisCollectionRequirements)
                true
            )
        )
    )
    (defun UEV_IgnisCollectionRequirements ()
        (let
            (
                (ouro-id:string (UR_OuroborosID))
                (gas-id:string (UR_IgnisID))
            )
            (enforce (!= ouro-id BAR) "OURO Id must be set for IGNIS Collection to turn ON!")
            (enforce (!= gas-id BAR) "IGNIS Id must be set for IGNIS Collection to turn ON!")
            (enforce (!= gas-id ouro-id) "OURO and IGNIS id must be different for the IGNIS Collection to turn ON!")
        )
    )
    (defun UEV_Glyph (account:string)
        (let
            (
                (ref-U|GLYPHS:module{UtilityDalosGlyphsV3} U|DALOS)
            )
            (ref-U|GLYPHS::GLYPH|UEV_DalosAccount account)
        )
    )
    (defun UEV_EnforceGuardProtocol (g:guard is-keyset-based:bool)
        @doc "When is-keyset-based is true, guard must be k:/w:/r:. When false, must be u:/c:/m:/p:."
        (let
            (
                (proto (UC_GuardProtocol g))
            )
            (if is-keyset-based
                (enforce (contains proto ["k:" "w:" "r:"])
                    (format "Guard must be key-based (keyset/keyset-ref); got '{}'" [proto]))
                (enforce (contains proto ["u:" "c:" "m:" "p:"])
                    (format "Governor must be non-key-based (user/capability/module/pact); got '{}'" [proto])))
        ))
    ;;
    (defun CAP_EnforceAccountOwnership (account:string)
        @doc "Enforces OuroNet Account Ownership"
        (if (UR_AccountType account)
            (UEV_SmartAccOwn account)
            (UEV_StandardAccOwn account)
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;
    ;;      [X-A]
    ;;Protection: Class 3 — Custom: DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT
    (defun XI_DeploySmartAccount (account:string guard:guard stoa:string sovereign:string public:string)
        ;;#26M fix: validation now happens in the caller's own client cap
        ;;(A_DeploySmartAccount composes DALOS|A>DEPLOY-SMART-OURONET-ACCOUNT,
        ;;C_DeploySmartAccount composes DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT directly) - this
        ;;writer only requires the shared validating cap is already active, it doesn't compose
        ;;or enforce anything itself.
        (require-capability (DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT account guard stoa sovereign))
        (insert DALOS|AccountTable account
            { "public"                      : public
            , "guard"                       : guard
            , "kadena-konto"                : stoa
            , "sovereign"                   : sovereign
            , "governor"                    : guard
            ;;
            , "smart-contract"              : true
            , "payable-as-smart-contract"   : false
            , "payable-by-smart-contract"   : false
            , "payable-by-method"           : true
            ;;
            , "nonce"                       : 0
            , "elite"                       : DALOS|PLEB
            , "ouroboros"                   : (UDC_BlankTrueFungible account)
            , "ignis"                       : (UDC_BlankTrueFungible account)
            }
        )
        (XI_UpdateStoaLedger stoa account true)
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_DeployStandardAccount (account:string guard:guard stoa:string public:string)
        (require-capability (SECURE))
        (with-capability (DALOS|C>DEPLOY-STANDARD-OURONET-ACCOUNT account guard stoa)
            (insert DALOS|AccountTable account
                { "public"                      : public
                , "guard"                       : guard
                , "kadena-konto"                : stoa
                , "sovereign"                   : account
                , "governor"                    : guard
                ;;
                , "smart-contract"              : false
                , "payable-as-smart-contract"   : false
                , "payable-by-smart-contract"   : false
                , "payable-by-method"           : false
                ;;
                , "nonce"                       : 0
                , "elite"                       : DALOS|PLEB
                , "ouroboros"                   : (UDC_BlankTrueFungible account)
                , "ignis"                       : (UDC_BlankTrueFungible account)
                }
            )
            (XI_UpdateStoaLedger stoa account true)
        )
    )
    ;;Protection: Class 3 — Custom: GOV|DALOS_ADMIN
    (defun XI_GasToggle (native:bool toggle:bool)
        (require-capability (GOV|DALOS_ADMIN))
        (if (= native true)
            (update DALOS|GasManagementTable DALOS|VGD
                {"native-gas-toggle" : toggle}
            )
            (update DALOS|GasManagementTable DALOS|VGD
                {"virtual-gas-toggle" : toggle}
            )
        )
    )
    ;;Protection: Class 3 — Custom: GOV|DALOS_ADMIN
    (defun XI_ToggleAccountCreationStoa (toggle:bool)
        (require-capability (GOV|DALOS_ADMIN))
        (update DALOS|GasManagementTable DALOS|VGD
            {"account-creation-stoa" : toggle}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_UpdateOuroPrice (price:decimal)
        (P|UEV_IMC)
        (update DALOS|PropertiesTable DALOS|INFO
            {"gas-source-id-price" : price}
        )
    )
    ;;      [X-C]
    ;;Protection: Class 3 — Custom: DALOS|C>CONTROL-SMART-OURONET-ACCOUNT
    (defun XI_UpdateSmartAccountParameters (account:string pasc:bool pbsc:bool pbm:bool)
        (require-capability (DALOS|C>CONTROL-SMART-OURONET-ACCOUNT account pasc pbsc pbm))
        (update DALOS|AccountTable account
            {"payable-as-smart-contract"    : pasc
            ,"payable-by-smart-contract"    : pbsc
            ,"payable-by-method"            : pbm}
        )
    )
    ;;Protection: Class 3 — Custom: DALOS|C>ROTATE-OA_GOVERNOR
    (defun XI_RotateGovernor (account:string governor:guard)
        @doc "Under DALOS|C>ROTATE-OA_GOVERNOR: update governor only. Write only."
        (require-capability (DALOS|C>ROTATE-OA_GOVERNOR account governor))
        (update DALOS|AccountTable account
            {"governor" : governor}
        )
    )
    ;;Protection: Class 3 — Custom: DALOS|C>ROTATE-OA-GUARD
    (defun XI_RotateGuard (account:string new-guard:guard safe:bool)
        @doc "Under DALOS|C>ROTATE-OA-GUARD: update guard (and governor on standard accounts). Write only."
        (require-capability (DALOS|C>ROTATE-OA-GUARD account new-guard safe))
        (if (UR_AccountType account)
            (update DALOS|AccountTable account
                {"guard"    : new-guard}
            )
            (update DALOS|AccountTable account
                {"guard"    : new-guard
                ,"governor" : new-guard}
            )
        )
    )
    ;;Protection: Class 3 — Custom: DALOS|C>ROTATE-OA-STOA
    (defun XI_RotateStoa (account:string stoa:string)
        @doc "Under DALOS|C>ROTATE-OA-STOA: update kadena-konto only. Write only."
        (require-capability (DALOS|C>ROTATE-OA-STOA account))
        (update DALOS|AccountTable account
            {"kadena-konto"                  : stoa}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateStoaLedger (stoa:string dalos:string direction:bool)
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (with-default-read DALOS|KadenaLedger stoa
                { "dalos"    : [BAR] }
                { "dalos"    := d }
                (let
                    (
                        (add-lst:[string]
                            (if (= d [BAR])
                                [dalos]
                                (if (contains dalos d)
                                    d
                                    (ref-U|LST::UC_AppL d dalos)
                                )
                            )
                        )
                        (data-len:integer (length d))
                        (first:string (at 0 d))
                        (rmv-lst:[string]
                            (if (and (= data-len 1)(!= first BAR))
                                [BAR]
                                (ref-U|LST::UC_RemoveItem d dalos)
                            )
                        )
                    )
                    (if direction
                        (write DALOS|KadenaLedger stoa
                            { "dalos" : add-lst}
                        )
                        (write DALOS|KadenaLedger stoa
                            { "dalos" : rmv-lst}
                        )
                    )

                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: DALOS|S>ROTATE-OA-SOVEREIGN
    (defun XI_RotateSovereign (account:string new-sovereign:string)
        (require-capability (DALOS|S>ROTATE-OA-SOVEREIGN account new-sovereign))
        (update DALOS|AccountTable account
            {"sovereign"                        : new-sovereign}
        )
    )
    ;;      [X-DALOS|PropertiesTable]
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateTreasury (type:integer tdp:decimal tds:decimal)
        (P|UEV_IMC)
        (update DALOS|PropertiesTable DALOS|INFO
            {"treasury-dispo-type"          : type
            ,"treasury-dynamic-promille"    : tdp
            ,"treasury-static-tds"          : tds}

        )
    );;     [X-DALOS|GasManagementTable]
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_IgnisIncrement (native:bool increment:decimal)
        (P|UEV_IMC)
        (if (= native true)
            (update DALOS|GasManagementTable DALOS|VGD
                {"native-gas-spent" : (+ (UR_NativeSpent) increment)}
            )
            (update DALOS|GasManagementTable DALOS|VGD
                {"virtual-gas-spent" : (+ (UR_VirtualSpent) increment)}
            )
        )
    )
    ;;      [X-DALOS|AccountTable]
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_IncrementOuronetAccountNonce (account:string)
        (P|UEV_IMC)
        (with-read DALOS|AccountTable account
            { "nonce" := n }
            (update DALOS|AccountTable account { "nonce" : (+ n 1)})
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateElite (account:string amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (if (= (UR_AccountType account) false)
                (update DALOS|AccountTable account
                    { "elite" : (ref-U|ATS::UDC_Elite amount)}
                )
                true
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateTF (account:string snake-or-gas:bool new-obj:object{OuronetDalosV3.DPTF|BalanceSchema})
        (require-capability (SECURE))
        (if snake-or-gas
            (update DALOS|AccountTable account
                {"ouroboros" : new-obj}
            )
            (update DALOS|AccountTable account
                {"ignis" : new-obj}
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_UpdateBalance (account:string snake-or-gas:bool new-balance:decimal)
        (P|UEV_IMC)
        (with-capability (SECURE)
            (let
                (
                    (data-obj:object (UR_TrueFungible account snake-or-gas))
                    (has-removable:bool (contains "exist" data-obj))
                    (new-balance-obj:object
                        (+
                            {"balance" : new-balance}
                            (remove "balance" data-obj)
                        )
                    )
                )
                (XI_UpdateTF account snake-or-gas
                    (if has-removable
                        (remove "exist" new-balance-obj)
                        new-balance-obj
                    )
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateFreeze (account:string snake-or-gas:bool new-freeze:bool)
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateTF account snake-or-gas
                (+
                    {"frozen" : new-freeze}
                    (remove "frozen" (UR_TrueFungible account snake-or-gas))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateBurnRole (account:string snake-or-gas:bool new-burn:bool)
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateTF account snake-or-gas 
                (+
                    {"role-burn" : new-burn}
                    (remove "role-burn" (UR_TrueFungible account snake-or-gas))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateMintRole (account:string snake-or-gas:bool new-mint:bool)
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateTF account snake-or-gas
                (+
                    {"role-mint" : new-mint}
                    (remove "role-mint" (UR_TrueFungible account snake-or-gas))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateFeeExemptionRole (account:string snake-or-gas:bool new-fee-exemption:bool)
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateTF account snake-or-gas
                (+
                    {"role-fee-exemption" : new-fee-exemption}
                    (remove "role-fee-exemption" (UR_TrueFungible account snake-or-gas))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateTransferRole (account:string snake-or-gas:bool new-transfer:bool)
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateTF account snake-or-gas
                (+
                    {"role-transfer" : new-transfer}
                    (remove "role-transfer" (UR_TrueFungible account snake-or-gas))
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_MigrateLiquidFunds:decimal (patron:string executor:string migration-target-stoa-account:string)
        (P|UEV_IMC)
        (CAP_EnforceAccountOwnership executor)
        (with-capability (GOV|MIGRATE migration-target-stoa-account)
            (let
                (
                    (ref-coin:module{stoa-ns.fungible-v1} coin)    
                    (dalos-stoa:string DALOS|SC_STOA-NAME)
                    (present-stoa-balance:decimal (ref-coin::get-balance dalos-stoa))
                )
                (install-capability (ref-coin::TRANSFER dalos-stoa migration-target-stoa-account present-stoa-balance))
                (ref-coin::transfer dalos-stoa migration-target-stoa-account present-stoa-balance)
                present-stoa-balance
            )
        )
    )
    (defun A_ToggleOAPU (patron:string executor:string oapu:bool)
        (P|UEV_IMC)
        (CAP_EnforceAccountOwnership executor)
        (with-capability (GOV|DALOS_ADMIN)
            (update DALOS|PropertiesTable DALOS|INFO
                {"ouro-auto-price-via-swaps"    : oapu}
            )
        )
    )
    (defun A_ToggleGAP (patron:string executor:string gap:bool)
        (P|UEV_IMC)
        (CAP_EnforceAccountOwnership executor)
        (with-capability (GOV|GAP gap)
            (update DALOS|PropertiesTable DALOS|INFO
                {"global-administrative-pause"  : gap}
            )
        )
    )
    (defun A_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string)
        @doc "ADMIN deploy of a Smart Ouronet Account -- gasless, and PATRONLESS by design: \
            \ there is no patron at the moment an account comes into existence. \
            \ \
            \ Executor: SELF-PROVING. <executor> is the account being CREATED, so its ownership \
            \ cannot be read from a table -- there is no row yet. It does not need to be: the \
            \ GUARD the account will be governed by is enforced in this same transaction, by \
            \ UEV_Any inside the capability below, BEFORE any other check. That is the same \
            \ proof UEV_StandardAccOwn performs on an existing account (`enforce-guard \
            \ account-guard`) with the same key; the guard simply travels with the call, because \
            \ at creation there is nowhere else it could come from. \
            \ \
            \ UEV_Any is enforce-ONE over [guard, (create-capability-guard (GOV))], and the \
            \ second element is the governance door in-line -- module GOV may create an account \
            \ without its guard being signed, which is how genesis bootstraps the first one. \
            \ Pinned by REPL/modules/DALOS-ADMIN.repl <<DALOS-G4b>>. (patron/executor canon 2.2, \
            \ the base case.)"
        (with-capability (DALOS|A>DEPLOY-SMART-OURONET-ACCOUNT executor guard stoa sovereign)
            (XI_DeploySmartAccount executor guard stoa sovereign public)
        )
    )
    (defun A_DeployStandardAccount (executor:string guard:guard stoa:string public:string)
        @doc "ADMIN deploy of a Standard Ouronet Account -- gasless, and PATRONLESS by design: \
            \ there is no patron at the moment an account comes into existence. \
            \ \
            \ Executor: SELF-PROVING. <executor> is the account being CREATED, so its ownership \
            \ cannot be read from a table -- there is no row yet. It does not need to be: the \
            \ GUARD the account will be governed by is enforced in this same transaction, by \
            \ UEV_Any inside the capability below, BEFORE any other check. That is the same \
            \ proof UEV_StandardAccOwn performs on an existing account (`enforce-guard \
            \ account-guard`) with the same key; the guard simply travels with the call, because \
            \ at creation there is nowhere else it could come from. \
            \ \
            \ UEV_Any is enforce-ONE over [guard, (create-capability-guard (GOV))], and the \
            \ second element is the governance door in-line -- module GOV may create an account \
            \ without its guard being signed, which is how genesis bootstraps the first one. \
            \ Pinned by REPL/modules/DALOS-ADMIN.repl <<DALOS-G4b>>. (patron/executor canon 2.2, \
            \ the base case.)"
        (with-capability (SECURE-ADMIN)
            (XI_DeployStandardAccount executor guard stoa public)
        )
    )
    (defun A_ToggleGasCollection (patron:string executor:string native:bool toggle:bool)
        @doc "Enables or disable GAS Collection. \
            \ <native> true reffers to STOA Collection \
            \ <native> false reffers to IGNIS Collection"
        (P|UEV_IMC)
        (CAP_EnforceAccountOwnership executor)
        (with-capability (DALOS|C>TOGGLE-GAS-COLLECTION native toggle)
            (XI_GasToggle native toggle)
        )
    )
    (defun A_ToggleAccountCreationStoa (patron:string executor:string toggle:bool)
        @doc "ADMIN: switch STOA collection for Ouronet account creation on/off, independently \
            \ of the global STOA switch. OFF = onboarding is free (the default). Admin op, so \
            \ it is itself IGNIS+STOA exempt."
        (P|UEV_IMC)
        (CAP_EnforceAccountOwnership executor)
        (with-capability (DALOS|C>TOGGLE-ACCOUNT-CREATION-STOA toggle)
            (XI_ToggleAccountCreationStoa toggle)
        )
    )
    (defun A_SetIgnisSourcePrice (patron:string executor:string price:decimal)
        (P|UEV_IMC)
        (CAP_EnforceAccountOwnership executor)
        (with-capability (DALOS|S>SET-OURO-PRICE price)
            (XB_UpdateOuroPrice price)
        )
    )
    (defun A_SetAutoFueling (patron:string executor:string toggle:bool)
        (P|UEV_IMC)
        (CAP_EnforceAccountOwnership executor)
        (with-capability (GOV|DALOS_ADMIN)
            (update DALOS|GasManagementTable DALOS|VGD
                {"native-gas-pump" : toggle}
            )
        )
    )
    (defun A_UpdatePublicKey (patron:string executor:string new-public:string)
        @doc "ADMIN key recovery: set <executor>'s public key. The EXECUTOR's ownership is \
            \ enforced INDIRECTLY, by GOV|DALOS_ADMIN alone -- deliberately, because this is the \
            \ path used when an account holder has LOST the key that would prove that ownership. \
            \ Demanding it here would leave the function unable to do the only job it has. \
            \ (patron/executor canon 2026-09-20: an indirect executor route is permitted and MUST \
            \ be named -- this paragraph is that naming.)"
        (P|UEV_IMC)
        (with-capability (GOV|DALOS_ADMIN)
            (update DALOS|AccountTable executor
                {"public"     : new-public}
            )
        )
    )
    ;;#53L fix: added a non-negative bound check on <new-price> - defense-in-depth for an
    ;;admin-only fat-finger, not a security gate (GOV|DALOS_ADMIN already fully trusted). A
    ;;stray 0/negative price here was flagged as a contributing cause of #8H (IGNIS XE_CollectIgnis's
    ;;since-fixed zero-leg abort) - purely additive, no change to the existing valid-price path.
    (defun A_UpdateUsagePrice (patron:string executor:string action:string new-price:decimal)
        (P|UEV_IMC)
        (CAP_EnforceAccountOwnership executor)
        (with-capability (GOV|DALOS_ADMIN)
            (enforce (> new-price 0.0) "New price must be a positive amount")
            (let
                (
                    (ref-U|CT:module{OuronetConstantsV2} U|CT)
                    (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                )
                (write DALOS|PricesTable action
                    {"price"     : (floor new-price stoa-prec)}
                )
            )
        )
    )
    (defun AU_OuronetAccounts (accounts:[string])
        @doc "Get Accounts with <(keys DALOS|AccountTable)>"
        (with-capability (AHU)
            (map (AU_OuronetAccount) accounts)
        )
    )
    (defun AU_OuronetAccount (account:string)
        (require-capability (SECURE))
        (update DALOS|AccountTable account
            {"ouroboros"    : (AUx_UpdateTrueFungibleObject (UR_TrueFungible account true) account)
            ,"ignis"        : (AUx_UpdateTrueFungibleObject (UR_TrueFungible account false) account)}
        )
    )
    (defun AUx_UpdateTrueFungibleObject:object{OuronetDalosV3.DPTF|BalanceSchema}
        (input-obj:object account:string)
        (let
            (
                (has-exist:bool (contains "exist" input-obj))
                (v1:object
                    (+
                        {"id" : BAR}
                        (remove "id" input-obj)
                    )
                )
                (v2:object
                    (+
                        {"account" : account}
                        (remove "account" v1)
                    )
                )
            )
            (if has-exist
                (remove "exist" v2)
                v2
            )
        )
    )
    (defun C_ControlSmartAccount
        (patron:string executor:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool)
        (P|UEV_IMC)
        (with-capability (DALOS|C>CONTROL-SMART-OURONET-ACCOUNT executor payable-as-smart-contract payable-by-smart-contract payable-by-method)
            (XI_UpdateSmartAccountParameters executor payable-as-smart-contract payable-by-smart-contract payable-by-method)
        )
    )
    (defun C_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string)
        @doc "PERMISSIONLESS self-deploy of a Smart Ouronet Account, paid in STOA. The admin twin \
            \ A_DeploySmartAccount is the gasless route. \
            \ \
            \ Executor: SELF-PROVING. <executor> is the account being CREATED, so its ownership \
            \ cannot be read from a table -- there is no row yet. It does not need to be: the \
            \ GUARD the account will be governed by is enforced in this same transaction, by \
            \ UEV_Any inside the capability below, BEFORE any other check. That is the same \
            \ proof UEV_StandardAccOwn performs on an existing account (`enforce-guard \
            \ account-guard`) with the same key; the guard simply travels with the call, because \
            \ at creation there is nowhere else it could come from. \
            \ \
            \ UEV_Any is enforce-ONE over [guard, (create-capability-guard (GOV))], and the \
            \ second element is the governance door in-line -- module GOV may create an account \
            \ without its guard being signed, which is how genesis bootstraps the first one. \
            \ Pinned by REPL/modules/DALOS-ADMIN.repl <<DALOS-G4b>>. (patron/executor canon 2.2, \
            \ the base case.)"
        (P|UEV_IMC)
        (with-capability (DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT executor guard stoa sovereign)
            (XI_DeploySmartAccount executor guard stoa sovereign public)
        )
    )
    (defun C_DeployStandardAccount (executor:string guard:guard stoa:string public:string)
        @doc "PERMISSIONLESS self-deploy of a Standard Ouronet Account, paid in STOA. The admin \
            \ twin A_DeployStandardAccount is the gasless route; both exist for flexibility, \
            \ and in normal operation neither is needed -- an account is created automatically \
            \ as required. \
            \ \
            \ Executor: SELF-PROVING. <executor> is the account being CREATED, so its ownership \
            \ cannot be read from a table -- there is no row yet. It does not need to be: the \
            \ GUARD the account will be governed by is enforced in this same transaction, by \
            \ UEV_Any inside the capability below, BEFORE any other check. That is the same \
            \ proof UEV_StandardAccOwn performs on an existing account (`enforce-guard \
            \ account-guard`) with the same key; the guard simply travels with the call, because \
            \ at creation there is nowhere else it could come from. \
            \ \
            \ UEV_Any is enforce-ONE over [guard, (create-capability-guard (GOV))], and the \
            \ second element is the governance door in-line -- module GOV may create an account \
            \ without its guard being signed, which is how genesis bootstraps the first one. \
            \ Pinned by REPL/modules/DALOS-ADMIN.repl <<DALOS-G4b>>. (patron/executor canon 2.2, \
            \ the base case.)"
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_DeployStandardAccount executor guard stoa public)
        )
    )
    (defun C_RotateGovernor
        (patron:string executor:string governor:guard)
        (P|UEV_IMC)
        (with-capability (DALOS|C>ROTATE-OA_GOVERNOR executor governor)
            (XI_RotateGovernor executor governor)
        )
    )
    (defun C_RotateGuard
        (patron:string executor:string new-guard:guard safe:bool)
        (P|UEV_IMC)
        (with-capability (DALOS|C>ROTATE-OA-GUARD executor new-guard safe)
            (XI_RotateGuard executor new-guard safe)
        )
    )
    (defun C_RotateStoa
        (patron:string executor:string stoa:string)
        (P|UEV_IMC)
        (with-capability (DALOS|C>ROTATE-OA-STOA executor)
            ;;#25M fix: read the OLD stoa address before XI_RotateStoa overwrites it -
            ;;otherwise UR_AccountStoa returns the already-rotated NEW address, the ledger
            ;;cleanup targets the wrong key, and the old address's ledger row is orphaned forever.
            (let
                (
                    (old-stoa:string (UR_AccountStoa executor))
                )
                (XI_RotateStoa executor stoa)
                (XI_UpdateStoaLedger old-stoa executor false)
                (XI_UpdateStoaLedger stoa executor true)
            )
        )
    )
    (defun C_RotateSovereign
        (patron:string executor:string new-sovereign:string)
        (P|UEV_IMC)
        (with-capability (DALOS|S>ROTATE-OA-SOVEREIGN executor new-sovereign)
            (XI_RotateSovereign executor new-sovereign)
        )
    )

)

;;Tables exist from initial DALOS

;; --- tables for 01_DALOS.pact (7 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table DALOS|PropertiesTable)
;; (create-table DALOS|GasManagementTable)
;; (create-table DALOS|PricesTable)
;; (create-table DALOS|AccountTable)
;; (create-table DALOS|KadenaLedger)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact ===================

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface IgnisCollectorV4
    @doc "IgnisCollectorV3 — the interface defining Ouronet's virtual-gas (IGNIS) data model \
        \ and collection API. Declares the cumulator schemas \
        \ (OutputCumulator/ModularCumulator per-interactor legs, plus Compressed and Primed \
        \ forms), UDC cumulator constructors and tier presets, URC zero-gas readers, DALOS \
        \ cost readers, and the XE_CollectIgnis / STOA-collect entrypoints that every core C_ \
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
    (defun XE_CollectIgnis (patron:string input-output-cumulator:object{OutputCumulator}))
    (defun XB_MoveDalosFuel (executor:string executee:string amount:decimal))
    (defun XB_CollectDalosFuel (patron:string amount:decimal))
    (defun XB_CollectStoaDiscountedFrom (patron:string discount-account:string amount:decimal trigger:bool))
    (defun XB_CollectStoaFull (patron:string amount:decimal trigger:bool))
    (defun XB_CollectStoaWithTrigger (patron:string amount:decimal trigger:bool))
    (defun XE_CollectStoa (patron:string amount:decimal))
    (defun C_DonateStoa (executor:string amount:decimal))


    ;;<=========================================================================>
    ;; ADDED 2026-10-12 -- interface-membership sweep (StoicSyntax-Prefixes.md Sec5,
    ;; owner ruling). Every one of these was already live in the module body; this
    ;; closes the gap between what the module DOES and what its interface SAYS it does.
    ;;<=========================================================================>
    (defun UC_FindKeyIndex:integer (key-lst:[string] key:string))
    (defun UDC_EmptyOutputCumulatorV2:object{OutputCumulator} ())
)

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface OuronetInfoV3
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
    (defun OI|UC_IfpFromOutputCumulator:decimal (input:object{IgnisCollectorV4.OutputCumulator}))
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

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/04_BRD.pact =====================
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface BrandingV3
    @doc "Interface Exposing the Branding Functions needed to create the Branding Functionality \
        \ Entities are DPTF DPMF DPSF DPNF ATSPairs SWPairs \
        \ Should Future entities be added, they too can be branded via this module \
        \ UR(Utility-Read), URC(Utility-Read-Compute), UDC(Utility-Data-Composition) \
        \ are NOT sorted alphabetically"

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
    (defschema Schema
        logo:string
        description:string
        website:string
        social:[object{SocialSchema}]
        flag:integer
        genesis:time
        premium-until:time
    )
    (defschema SocialSchema
        social-media-name:string
        social-media-link:string
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
    (defun UDC_BrandingLogo:object{Schema} (input:object{Schema} logo:string))
    (defun UDC_BrandingDescription:object{Schema} (input:object{Schema} description:string))
    (defun UDC_BrandingWebsite:object{Schema} (input:object{Schema} website:string))
    (defun UDC_BrandingSocial:object{Schema} (input:object{Schema} social:[object{SocialSchema}]))
    (defun UDC_BrandingFlag:object{Schema} (input:object{Schema} flag:integer))
    (defun UDC_BrandingPremium:object{Schema} (input:object{Schema} premium:time))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_Branding:object{Schema} (id:string pending:bool))
    (defun UR_Logo:string (id:string pending:bool))
    (defun UR_Description:string (id:string pending:bool))
    (defun UR_Website:string (id:string pending:bool))
    (defun UR_Social:[object{SocialSchema}] (id:string pending:bool))
    (defun UR_Flag:integer (id:string pending:bool))
    (defun UR_Genesis:time (id:string pending:bool))
    (defun UR_PremiumUntil:time (id:string pending:bool))
    ;;
    (defun URC_MaxBluePayment (account:string))
    (defun URCi_UpgradeBranding:decimal (months:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    (defun XE_Issue (entity-id:string))
    (defun XE_UpdatePendingBranding (entity-id:string logo:string description:string website:string social:[object{SocialSchema}]))
    (defun XE_UpgradeBranding:decimal (entity-id:string entity-owner-account:string months:integer))
    ;;{5.7}  User [A/C]
    ;;
    (defun A_Live (patron:string executor:string entity-id:string))
    (defun A_SetFlag (patron:string executor:string entity-id:string flag:integer))


    ;;<=========================================================================>
    ;; ADDED 2026-10-12 -- interface-membership sweep (StoicSyntax-Prefixes.md Sec5,
    ;; owner ruling). Every one of these was already live in the module body; this
    ;; closes the gap between what the module DOES and what its interface SAYS it does.
    ;;<=========================================================================>
    (defun UDC_BrandingGenesis:object{Schema} (input:object{Schema} genesis:time))
)

(module BRD GOV
    @doc "BRD — the branding core for all Ouronet entities (DPTF, DPOF, ATS pairs, SWP pairs \
        \ and future ones), implementing BrandingV2. It stores per-entity live and pending \
        \ branding (logo, description, website, socials, flag, genesis, premium-until) in \
        \ BRD|BrandingTable; owners edit pending data then push it live, an admin sets \
        \ flags, and blue-flag premium upgrades are priced in STOA by Elite tier."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPTF                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|BRD_ADMIN)))
    (defcap GOV|BRD_ADMIN ()                            (enforce-guard GOV|MD_DPTF))
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
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|BRD|CALLER ()
        true
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
        (with-capability (GOV|BRD_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|BRD_ADMIN)
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
        (with-capability (GOV|BRD_ADMIN)
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
        (with-capability (GOV|BRD_ADMIN)
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
                (mg:guard (create-capability-guard (P|BRD|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    ;;"this entity has never held premium", as a deliberate sentinel rather than an accident.
    ;;<premium-until> used to be `(at "block-time" (chain-data))` inside this `defconst`, which Pact
    ;;evaluates ONCE at module load -- so it was BRD's own deploy timestamp, shared by every entity
    ;;and drifting with each redeploy. A fresh entity has no premium at all, and the honest encoding
    ;;of that is a fixed point in the past that no clock can overtake.
    (defconst BRD|NO_PREMIUM:time (time "1970-01-01T00:00:00Z"))
    ;;<genesis> here is a PLACEHOLDER ONLY -- same defconst problem, and a birth date must be the
    ;;entity's own. <XE_Issue> overwrites it with the issuance time; see the note there.
    (defconst BRD|DEFAULT
        {"logo"                 : BAR
        ,"description"          : BAR
        ,"website"              : BAR
        ,"social"               : [SOCIAL|EMPTY]
        ,"flag"                 : 3
        ,"genesis"              : (at "block-time" (chain-data))
        ,"premium-until"        : BRD|NO_PREMIUM}
    )
    (defconst SOCIAL|EMPTY
        {"social-media-name"    : BAR
        ,"social-media-link"    : BAR}
    )
    ;;{3.2}  schemas
    ;;
    (defschema BRD|PropertiesSchema
        branding:object{BrandingV3.Schema}
        branding-pending:object{BrandingV3.Schema}
    )
    ;;{3.3}  tables
    (deftable BRD|BrandingTable:{BRD|PropertiesSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap BRD|C>ADMIN_SET (flag:integer)
        @event
        (compose-capability (GOV|BRD_ADMIN))
        (enforce (contains flag (enumerate 0 4)) "Invalid Integer Flag")
        (compose-capability (SECURE))
    )
    (defcap BRD|C>LIVE ()
        @event
        (compose-capability (GOV|BRD_ADMIN))
        (compose-capability (SECURE))
    )
    (defcap BRD|C>UPGRADE (entity-id:string entity-owner-account:string months:integer)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (mp:integer (URC_MaxBluePayment entity-owner-account))
                (flag:integer (UR_Flag entity-id false))
                (premium:time (UR_PremiumUntil entity-id false))
                (current:time (at "block-time" (chain-data)))
                (remaining:decimal (diff-time premium current))
            )
        ;;1] Enforces <entity-id> ownership
            (ref-DALOS::CAP_EnforceAccountOwnership entity-owner-account)
        ;;2] Flags 0 and 4 cannot be upgraded
            (enforce (!= flag 0) "Golden Flag cannot be upgraded")
            (enforce (!= flag 4) "Red Flag cannot be upgraded")
        ;;3] Max Payments in months depends on <entity-owner-account> Elite Account Level
            (enforce (<= months mp) "Invalid Months Integer")
        ;;4] Upgrading can only be done if premium time is less than 15 days. Also works when no premium time is available.
            (enforce (< remaining 1296000.0) "Blue Flag has more than 15 days remainig!")
        ;;5] Capability needed for accesing <XI_UpdateBrandingData>
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
    (defun UDC_BrandingLogo:object{BrandingV3.Schema} (input:object{BrandingV3.Schema} logo:string)
        (+
            {"logo" : logo}
            (remove "logo" input)
        )
    )
    (defun UDC_BrandingDescription:object{BrandingV3.Schema} (input:object{BrandingV3.Schema} description:string)
        (+
            {"description" : description}
            (remove "description" input)
        )
    )
    (defun UDC_BrandingWebsite:object{BrandingV3.Schema} (input:object{BrandingV3.Schema} website:string)
        (+
            {"website" : website}
            (remove "website" input)
        )
    )
    (defun UDC_BrandingSocial:object{BrandingV3.Schema} (input:object{BrandingV3.Schema} social:[object{BrandingV3.SocialSchema}])
        (+
            {"social" : social}
            (remove "social" input)
        )
    )
    (defun UDC_BrandingFlag:object{BrandingV3.Schema} (input:object{BrandingV3.Schema} flag:integer)
        (enforce (contains flag (enumerate 0 4)) "Invalid Flag Integer")
        (+
            {"flag" : flag}
            (remove "flag" input)
        )
    )
    (defun UDC_BrandingPremium:object{BrandingV3.Schema} (input:object{BrandingV3.Schema} premium:time)
        (+
            {"premium-until" : premium}
            (remove "premium-until" input)
        )
    )
    ;;MODULE-ONLY, unlike its six siblings above, and deliberately so: declaring it in
    ;;the BrandingV2 interface would bump the interface and pull every consumer along
    ;;under the cascade rule, for a constructor only <XE_Issue> needs. The siblings are
    ;;interface-declared because external modules build branding objects with them;
    ;;nothing outside BRD sets a genesis.
    (defun UDC_BrandingGenesis:object{BrandingV3.Schema} (input:object{BrandingV3.Schema} genesis:time)
        (+
            {"genesis" : genesis}
            (remove "genesis" input)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_Branding:object{BrandingV3.Schema} (id:string pending:bool)
        (if pending
            (with-read BRD|BrandingTable id
                { "branding-pending" := b }
                b
            )
            (with-read BRD|BrandingTable id
                { "branding" := b }
                b
            )
        )
    )
    (defun UR_Logo:string (id:string pending:bool)
        (at "logo" (UR_Branding id pending))
    )
    (defun UR_Description:string (id:string pending:bool)
        (at "description" (UR_Branding id pending))
    )
    (defun UR_Website:string (id:string pending:bool)
        (at "website" (UR_Branding id pending))
    )
    (defun UR_Social:[object{BrandingV3.SocialSchema}] (id:string pending:bool)
        (at "social" (UR_Branding id pending))
    )
    (defun UR_Flag:integer (id:string pending:bool)
        (at "flag" (UR_Branding id pending))
    )
    (defun UR_Genesis:time (id:string pending:bool)
        (at "genesis" (UR_Branding id pending))
    )
    (defun UR_PremiumUntil:time (id:string pending:bool)
        (at "premium-until" (UR_Branding id pending))
    )
    (defun URC_MaxBluePayment (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (mt:integer (ref-DALOS::UR_Elite-Tier-Major account))
            )
            (if (<= mt 2)
                1
                (if (and (> mt 2)(< mt 5))
                    2
                    3
                )
            )
        )
    )
    (defun URCi_UpgradeBranding:decimal (months:integer)
        @doc "Blue-flag upgrade cost = months * UsagePrice(\"blue\"), a STOA price. \
            \ \"blue\" is DERIVED from IG|DETER \"branding-blue\" via UC_StoaPrice, so the month \
            \ carries a fixed DOLLAR value ($25 = 250 STOA at the $0.10 peg) and the amount \
            \ moves with the oracle while the value does not. Single source for both the \
            \ XE_UpgradeBranding write (exec billing) and every C_UpgradeBranding INFO preview."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (* (dec months) (ref-DALOS::UR_UsagePrice "blue"))
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_Issue (entity-id:string)
        @doc "Creates the branding row for <entity-id>, stamping <genesis> and \
            \ <premium-until> with the issuance time."
        (P|UEV_IMC)
        ;;<genesis> IS STAMPED HERE, PER ISSUANCE. It used to come straight from the
        ;;BRD|DEFAULT defconst, and Pact evaluates a defconst ONCE at module load -- so
        ;;every entity ever issued inherited BRD's OWN DEPLOY TIME as its birth date,
        ;;identical for all of them and different after every redeploy.
        ;;
        ;;<premium-until> is NOT stamped with the issuance time: a fresh entity has never
        ;;held premium, and BRD|NO_PREMIUM says exactly that at a fixed point no clock can
        ;;overtake. Stamping it with "now" would read as "premium expired this instant",
        ;;which is a different claim and one that depends on when the row was written.
        ;;Fixed 2026-09-12, owner-authorised.
        (let
            (
                (fresh:object{BrandingV3.Schema}
                    (UDC_BrandingGenesis BRD|DEFAULT (at "block-time" (chain-data))))
            )
            (insert BRD|BrandingTable entity-id
                {"branding"                 : fresh
                ,"branding-pending"         : fresh}
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdatePendingBranding (entity-id:string logo:string description:string website:string social:[object{BrandingV3.SocialSchema}])
        @doc "Updates <pending-branding> with new branding data. \
            \ This is done by <entity-id> owners to brand their <entity-id> \
            \ Branding Administrator must afterwards set this <pending-branding> data to live, \
            \ in order to activate the actual branding for the <entity-id>"
        (P|UEV_IMC)
        (let
            (
                (pending:object{BrandingV3.Schema} (UR_Branding entity-id true))
                (p1:object{BrandingV3.Schema} (UDC_BrandingLogo pending logo))
                (p2:object{BrandingV3.Schema} (UDC_BrandingDescription p1 description))
                (p3:object{BrandingV3.Schema} (UDC_BrandingWebsite p2 website))
                (p4:object{BrandingV3.Schema} (UDC_BrandingSocial p3 social))
            )
            (with-capability (SECURE)
                (XI_UpdateBrandingData entity-id true p4)
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          BRD|C>UPGRADE
    (defun XE_UpgradeBranding:decimal (entity-id:string entity-owner-account:string months:integer)
        @doc "Upgrades Branding for <entity-id> to Blue Flag; Initial Cost set at 25 STOA per Month \
            \ STOA Cost may be adjusted in the future reflecting STOA Value \
            \ Number of months can be 1, 2 or 3, depending on <entity-owner-account> Major Elite Tier \
            \ Returns the value in STOA that is due to be collected \
            \ \
            \ \
            \ Upgrading a <4> Red Flag is not possible \
            \ \
            \ Upgrading a <3> Gray Flag, converts it to a <1> Blue Flag, and moves <pending-branding> to <live-branding> \
            \       essentialy setting the branding to live; Usefull when you dont need to wait for Branding Administrator \
            \       to manualy set the branding to live \
            \   When upgrading from a <3> Gray Flag, it is recommended to upgrade the <pending-branding> Data First \
            \       so as to benefit from the autonomic moving of the branding to live \
            \ \
            \ Upgrading a <2> Green Flag, converts it to a <1> Blue Flag \
            \       Keeps branding Data as is for both <branding> and <branding-pending> \
            \ \
            \ Upgrading a <1> Blue Flag is allowed if the <entity-id> remaining premium time is less than 15 days \
            \       This Extends the Premium Time \
            \       Keeps branding Data as is for both <branding> and <branding-pending> \
            \ \
            \ Upgrading a <0> Golden Flag is restricted, as Golden Flags are higher in hierachy than Blue Flags"
        (P|UEV_IMC)
        (with-capability (BRD|C>UPGRADE entity-id entity-owner-account months)
            (let
                (
                    (branding:object{BrandingV3.Schema} (UR_Branding entity-id false))
                    (branding-pending:object{BrandingV3.Schema} (UR_Branding entity-id true))
                    (flag:integer (UR_Flag entity-id false))
                    (premium:time (UR_PremiumUntil entity-id false))
                    (current:time (at "block-time" (chain-data)))
                    (seconds:decimal (fold (*) 1.0 [86400.0 30.0 (dec months)]))
                    (payment:decimal (URCi_UpgradeBranding months))
                    ;;THE EXTENSION BASE IS CLAMPED TO NOW WHEN THE PREMIUM HAS
                    ;;LAPSED. This used to be (add-time premium seconds) flat: correct
                    ;;for a LIVE subscription, where extending from the stored date
                    ;;loses no time between renewals, and wrong for a lapsed one -- the
                    ;;buyer paid for 30 days measured from a date already gone and got a
                    ;;BLUE flag with ZERO usable premium. Fixed 2026-09-12,
                    ;;owner-authorised; pinned by modules/SWP.repl <<SWP-G24>>.
                    (premium-until:time
                        (add-time
                            (if (> (diff-time premium current) 0.0) premium current)
                            seconds
                        )
                    )

                    (as-is1:object{BrandingV3.Schema} (UDC_BrandingFlag branding 1))
                    (as-is2:object{BrandingV3.Schema} (UDC_BrandingPremium as-is1 premium-until))

                    (from-pending1:object{BrandingV3.Schema} (UDC_BrandingFlag branding-pending 1))
                    (from-pending2:object{BrandingV3.Schema} (UDC_BrandingPremium from-pending1 premium-until))

                    (np1:object{BrandingV3.Schema} (UDC_BrandingLogo branding-pending BAR))
                    (np2:object{BrandingV3.Schema} (UDC_BrandingDescription np1 BAR))
                    (np3:object{BrandingV3.Schema} (UDC_BrandingWebsite np2 BAR))
                    (np4:object{BrandingV3.Schema} (UDC_BrandingSocial np3 [SOCIAL|EMPTY]))
                )
                (if (= flag 3)
                    (do
                        (XI_UpdateBrandingData entity-id false from-pending2)
                        (XI_UpdateBrandingData entity-id true np4)
                    )
                    (XI_UpdateBrandingData entity-id false as-is2)
                )
                payment
            )
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateBrandingData (entity-id:string pending:bool branding:object{BrandingV3.Schema})
        (require-capability (SECURE))
        (if pending
            (update BRD|BrandingTable entity-id
                {"branding-pending" : branding}
            )
            (update BRD|BrandingTable entity-id
                {"branding" : branding}
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_Live (patron:string executor:string entity-id:string)
        @doc "ADMIN: promotes <entity-id>'s pending Branding to live, resetting the pending slot. \
            \ <executor> is the Branding Administrator; ownership is enforced here directly, \
            \ because BRD|C>LIVE composes the SHARED GOV|BRD_ADMIN keyset and therefore proves \
            \ admin-ness without proving WHICH account acted."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (BRD|C>LIVE)
            (let
                (
                    (branding-pending:object{BrandingV3.Schema} (UR_Branding entity-id true))
                    (flag:integer (UR_Flag entity-id false))
                    (updated-flag:integer (if (<= flag 1) flag 2))
                    (updated-branding:object{BrandingV3.Schema} (UDC_BrandingFlag branding-pending updated-flag))
                    (np1:object{BrandingV3.Schema} (UDC_BrandingLogo branding-pending BAR))
                    (np2:object{BrandingV3.Schema} (UDC_BrandingDescription np1 BAR))
                    (np3:object{BrandingV3.Schema} (UDC_BrandingWebsite np2 BAR))
                    (np4:object{BrandingV3.Schema} (UDC_BrandingSocial np3 [SOCIAL|EMPTY]))
                )
                (XI_UpdateBrandingData entity-id false updated-branding)
                (XI_UpdateBrandingData entity-id true np4)
            )
        )
    )
    (defun A_SetFlag (patron:string executor:string entity-id:string flag:integer)
        @doc "ADMIN: forcibly sets the Branding Flag of <entity-id>. \
            \ <executor> is the Branding Administrator; ownership is enforced here directly, \
            \ because BRD|C>ADMIN_SET composes the SHARED GOV|BRD_ADMIN keyset and therefore \
            \ proves admin-ness without proving WHICH account acted."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (BRD|C>ADMIN_SET flag)
            (let
                (
                    (existing-branding:object{BrandingV3.Schema} (UR_Branding entity-id false))
                    (modified-branding:object{BrandingV3.Schema} (UDC_BrandingFlag existing-branding flag))
                )
                (XI_UpdateBrandingData entity-id false modified-branding)
            )
        )
    )

)

;; --- tables for 04_BRD.pact (3 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table BRD|BrandingTable)


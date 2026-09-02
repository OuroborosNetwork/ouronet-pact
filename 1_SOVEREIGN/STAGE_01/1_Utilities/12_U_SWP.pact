(module U|SWP GOV


    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements UtilitySwpV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                  (compose-capability (GOV|U|SWP_ADMIN)))
    (defcap GOV|U|SWP_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
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
    (defconst BAR                   (CT_Bar))
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
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    ;;
    ;;
    (defun UDC_DirectRawSwapInput:object{UtilitySwpV1.DirectRawSwapInput}
        (a:decimal b:[decimal] c:[decimal] d:[integer] e:integer f:integer g:[decimal])
        {"A"                : a
        ,"X"                : b
        ,"input-amounts"    : c
        ,"input-positions"  : d
        ,"output-position"  : e
        ,"output-precision" : f
        ,"weights"          : g}
    )
    (defun UDC_InverseRawSwapInput:object{UtilitySwpV1.InverseRawSwapInput}
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
    (defun UDC_DirectSwapInputData:object{UtilitySwpV1.DirectSwapInputData}
        (a:[string] b:[decimal] c:string)
        {"input-ids"        : a
        ,"input-amounts"    : b
        ,"output-id"        : c}
    )
    (defun UDC_ReverseSwapInputData:object{UtilitySwpV1.ReverseSwapInputData}
        (a:string b:decimal c:string)
        {"output-id"        : a
        ,"output-amount"    : b
        ,"input-id"         : c}
    )
    ;;
    (defun UDC_DirectTaxedSwapOutput:object{UtilitySwpV1.DirectTaxedSwapOutput}
        (a:[decimal] b:string c:decimal d:decimal e:decimal)
        {"lp-fuel"          : a
        ,"o-id"             : b
        ,"o-id-special"     : c
        ,"o-id-liquid"      : d
        ,"o-id-netto"       : e}
    )
    (defun UDC_InverseTaxedSwapOutput:object{UtilitySwpV1.InverseTaxedSwapOutput}
        (a:decimal b:decimal c:[decimal] d:string e:decimal)
        {"o-id-liquid"      : a
        ,"o-id-special"     : b
        ,"lp-fuel"          : c
        ,"i-id"             : d
        ,"i-id-brutto"      : e}
    )
    (defun UDC_SwapFeez:object{UtilitySwpV1.SwapFeez}
        (a:decimal b:decimal c:decimal)
        {"lp"               : a
        ,"special"          : b
        ,"boost"            : c}
    )
    (defun UDC_VirtualSwapEngine:object{UtilitySwpV1.VirtualSwapEngine}
        (a:[string] b:[integer] c:string d:[decimal] e:string f:[decimal] g:decimal h:[decimal] i:object{UtilitySwpV1.SwapFeez} j:[decimal] k:[decimal] l:[decimal] m:[object{UtilitySwpV1.DirectSwapInputData}])
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
        (drsi:object{UtilitySwpV1.DirectRawSwapInput})
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
    (defun UC_ComputeInverseY
        (irsi:object{UtilitySwpV1.InverseRawSwapInput})
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                        "UC_ComputeInverseY: output-amount must be strictly less than the pool's current output-token reserve"))
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
        (drsi:object{UtilitySwpV1.DirectRawSwapInput})
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
        (irsi:object{UtilitySwpV1.InverseRawSwapInput})
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
        (drsi:object{UtilitySwpV1.DirectRawSwapInput})
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
        (irsi:object{UtilitySwpV1.InverseRawSwapInput})
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
            \ Residual, not pursued: UC_LpID is declared on the public UtilitySwpV1 \
            \ interface, so a hypothetical future caller passing mismatched-length \
            \ lists would hit a plain out-of-bounds crash inside the folds below \
            \ instead of a clean enforce message — same class of residual risk as M1's \
            \ own write-up, not a live path today."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                    (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                    (ref-U|LST:module{StringProcessorV1} U|LST)
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
                    (ref-U|LST:module{StringProcessorV1} U|LST)
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
                    (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
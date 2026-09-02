
(module U|DPTF GOV



    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements UtilityDptfV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                  (compose-capability (GOV|U|DPTF_ADMIN)))
    (defcap GOV|U|DPTF_ADMIN ()
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
    (defun UDC_EmptyDispo:object{UtilityDptfV1.DispoData} ()
        {"elite-auryn-amount"           :0.0
        ,"auryndex-value"               :-1.0
        ,"elite-auryndex-value"         :-1.0
        ,"major-tier"                   :0
        ,"minor-tier"                   :0
        ,"ouroboros-precision"          :24}
    )
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    (defun UC_TwoSplitter:[integer] (input:integer)
        (let
            (
                (dec-in:decimal (dec input))
                (div:decimal (/ dec-in 2.0))
                (rest:decimal (- div (dec (floor div))))
            )
            (cond
                ((= rest 0.0) (make-list 2 (floor div)))
                ((= rest 0.5) (+ (make-list 1 (+ 1 (floor div))) (make-list 1 (floor div))))
                [0 0 0 0]
            )
        )
    )
    (defun UC_FourSplitter:[integer] (input:integer)
        (let
            (
                (dec-in:decimal (dec input))
                (div:decimal (/ dec-in 4.0))
                (rest:decimal (- div (dec (floor div))))
            )
            (cond
                ((= rest 0.0) (make-list 4 (floor div)))
                ((= rest 0.25) (+ (make-list 1 (+ 1 (floor div))) (make-list 3 (floor div))))
                ((= rest 0.5) (+ (make-list 2 (+ 1 (floor div))) (make-list 2 (floor div))))
                ((= rest 0.75) (+ (make-list 3 (+ 1 (floor div))) (make-list 1 (floor div))))
                [0 0 0 0]
            )
        )
    )
    (defun UC_EightSplitter:[integer] (input:integer)
        (let
            (
                (dec-in:decimal (dec input))
                (div:decimal (/ dec-in 8.0))
                (rest:decimal (- div (dec (floor div))))
            )
            (cond
                ((= rest 0.0) (make-list 8 (floor div)))
                ((= rest 0.125) (+ (make-list 1 (+ 1 (floor div))) (make-list 7 (floor div))))
                ((= rest 0.25) (+ (make-list 2 (+ 1 (floor div))) (make-list 6 (floor div))))
                ((= rest 0.375) (+ (make-list 3 (+ 1 (floor div))) (make-list 5 (floor div))))
                ((= rest 0.5) (+ (make-list 4 (+ 1 (floor div))) (make-list 4 (floor div))))
                ((= rest 0.625) (+ (make-list 5 (+ 1 (floor div))) (make-list 3 (floor div))))
                ((= rest 0.75) (+ (make-list 6 (+ 1 (floor div))) (make-list 2 (floor div))))
                ((= rest 0.875) (+ (make-list 7 (+ 1 (floor div))) (make-list 1 (floor div))))
                [0 0 0 0]
            )
        )
    )
    (defun UC_OuroDispo:decimal (input:object{UtilityDptfV1.DispoData})
        (let
            (
                (ea-amount:decimal (at "elite-auryn-amount" input))
                (a-idx:decimal (at "auryndex-value" input))
                (ea-idx:decimal (at "elite-auryndex-value" input))
                (major:decimal (dec (at "major-tier" input)))
                (minor:decimal (dec (at "minor-tier" input)))
                (o-prec:integer (at "ouroboros-precision" input))

                (olp:decimal
                    (if (< major 3.0)
                        0.0
                        (floor (+ (/ (- (+ (* (- major 1) 7.0) minor) 15.0) 10.0) 11.5) 1)
                    )
                )
                (olpd:decimal (floor (/ olp 100.0) 3))
            )
            (if (or (= -1.0 a-idx) (= -1.0 ea-idx))
                0.0
                (floor (fold (*) 1.0 [a-idx ea-idx ea-amount olpd]) o-prec)
            )
        )
    )
    (defun UC_UnlockPrice:[decimal] (unlocks:integer)
        @doc "Computes DPTF unlock price (audit finding #27L / L9: doc said 'ATS', a copy- \
            \ paste from U_ATS - the code itself is a correct shared-core wrapper, not a \
            \ duplicate-logic bug). \
            \ Outputs [virtual-gas-costs (IGNIS) native-gas-cost(STOA)]"
        (let
            (
                (ref-U|DEC:module{OuronetDecimalsV1} U|DEC)
            )
            (ref-U|DEC::UC_UnlockPrice unlocks true)
        )
    )
    (defun UC_VolumetricTax (precision:integer amount:decimal)
        @doc "Computes Volumetric-Transaction-Tax (VTT) value, given an Input Decimal <amount>"
        (let*
            (
                (amount-int:integer (floor amount))
                (amount-str:string (int-to-str 10 amount-int))
                (amount-str-rev-lst:[string] (reverse (str-to-list amount-str)))
                (amount-dec-rev-lst:[decimal] (map (lambda (x:string) (dec (str-to-int 10 x))) amount-str-rev-lst))
                (integer-lst:[integer] (enumerate 0 (- (length amount-dec-rev-lst) 1)))
                (logarithm-lst:[decimal] (map (lambda (u:integer) (UCx_VolumetricPermile precision u)) integer-lst))
                (multiply-lst:[decimal] (zip (lambda (x:decimal y:decimal) (* x y)) amount-dec-rev-lst logarithm-lst))
                (volumetric-fee:decimal (floor (fold (+) 0.0 multiply-lst) precision))
            )
            volumetric-fee
        )
    )
    (defun UCx_VolumetricPermile:decimal (precision:integer unit:integer)
        @doc "Auxiliary computation function needed to compute the volumetric the VTT"
        (let*
            (
                (logarithm-base:decimal (if (= unit 0) 0.0 (dec (str-to-int 10 (concat (make-list unit "7"))))))
                (logarithm-number:decimal (dec (^ 10 unit)))
                (logarithm:decimal (floor (log logarithm-base logarithm-number) precision))
                (volumetric-permile:decimal (floor (* logarithm-number (/ logarithm 1000.0)) precision))
            )
            volumetric-permile
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
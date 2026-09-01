(module U|DEC GOV
    ;;
    (implements OuronetDecimalsV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    ;;{G2}
    (defcap GOV ()
        (compose-capability (GOV|U|DEC_ADMIN))
    )
    (defcap GOV|U|DEC_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G3}
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    ;;{P3}
    ;;{P4}
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    ;;{2}
    ;;{3}
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    ;;{C2}
    ;;{C3}
    ;;{C4}
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F1}  Construct [UDC]
    ;;{F2}  Compute [UC]
    (defun UC_AddArray:[decimal] (array:[[decimal]])
        @doc "Adds all column elements in an array of decimal elements, while ensuring all rows are of equal length"
        (UEV_DecimalArray array)
        (fold
            (lambda
                (acc:[decimal] item:[decimal])
                (zip (+) acc item)
            )
            (make-list (length (at 0 array)) 0.0)
            array
        )
    )
    (defun UC_AddHybridArray (lists)
        @doc "Adds all column elements in an array of numbers, even if the inner lists are of unequal lengths"
        (let
            (
                (maxl
                    (fold
                        (lambda
                            (acc lst)
                            (UC_Max acc (length lst))
                        )
                        0
                        lists
                    )
                )
            )
            ;;#20H fix: empty <lists> (or a set of all-empty inner lists) makes maxl=0, and
            ;;(enumerate 0 -1) returns [0 -1] rather than [], not [] as one might assume - the
            ;;same enumerate/negative-range footgun class as #N2's IGNIS UC_FindKeyIndex fix.
            ;;Guarded explicitly rather than touching the (already-correct, per every real
            ;;caller) non-empty path below.
            (if (= maxl 0)
                []
                (map
                    (lambda
                        (i)
                        (fold
                            (+)
                            0.0
                            (map
                                (lambda
                                    (inner-lst)
                                    (if (< i (length inner-lst))
                                        (at i inner-lst)
                                        0.0
                                    )
                                )
                                lists
                            )
                        )
                    )
                    (enumerate 0 (- maxl 1))
                )
            )
        )
    )
    (defun UC_Max (x y)
        (if (> x y) x y)
    )
    (defun UC_Percent:decimal (x:decimal percent:decimal precision:integer)
        (enforce (and (>= percent 0.0)(<= percent 100.0)) "Invalid percent amount")
        (floor (* (/ percent 100.0) x) precision)
    )
    (defun UC_Promille:decimal (x:decimal promille:decimal precision:integer)
        (enforce (and (>= promille 0.0)(<= promille 1000.0)) "Invalid permille amount")
        (floor (* (/ promille 1000.0) x) precision)
    )
    (defun UC_UnlockPrice:[decimal] (unlocks:integer dptf-or-ats:bool)
        @doc "Computes  ATS or DPTF unlock price \
        \ Outputs [virtual-gas-costs native-gas-cost] \
        \ Virtual Gas Token = IGNIS; Native Gas Token = STOA"
        (let*
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (dptf:decimal (ref-U|CT::CT_DPTF-FeeLock))
                (ats:decimal (ref-U|CT::CT_ATS-FeeLock))
                (multiplier:decimal (dec (+ unlocks 1)))
                (base:decimal (if dptf-or-ats dptf ats))
                (gas-cost:decimal (* base multiplier))
                (gaz-cost:decimal (/ gas-cost 100.0))
            )
            [gas-cost gaz-cost]
        )
    )
    ;;{F3}  Read [UR/URC/URH/URCi]
    ;;{F4}  Validate [UEV/CAP]
    (defun UEV_DecimalArray (array:[[decimal]])
        @doc "Enforces all inner list inside an array of decimal elements are of equal size"
        (enforce
            (=
                true
                (fold
                    (lambda
                        (acc:bool inner-lst:[decimal])
                        (and
                            acc
                            (if (=
                                    (length inner-lst)
                                    (length (at 0 array))
                                )
                                true
                                false
                            )
                        )
                    )
                    true
                    array
                )
            )
            "All Fee-Array Lists must be of equal length !"
        )
    )
    ;;{F5}  Write [W]
    ;;{F6}  Aux/Protected [X]
    ;;{F7}  User [A]
    ;;{F8}  User [C]
    ;;
)
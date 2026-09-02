(interface OuronetIntegersV1
    @doc "Exported Integer Functions"

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
    (defschema NonceSplitter
        negative-nonces:[integer]
        positive-nonces:[integer]
        negative-counterparts:[integer]
        positive-counterparts:[integer]
    )
    (defschema SplitIntegers
        negative:[integer]
        positive:[integer]
    )
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
    (defun UDC_SplitIntegers:object{SplitIntegers} (neg:[integer] pos:[integer]))
    (defun UDC_NonceSplitter:object{NonceSplitter} (a:[integer] b:[integer] c:[integer] d:[integer]))
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_SplitAuxiliaryIntegerList:object{SplitIntegers} (primary:[integer] auxiliary:[integer]))
    (defun UC_SplitIntegerList:object{SplitIntegers} (input:[integer]))
    (defun UC_NonceSplitter:object{NonceSplitter} (nonces:[integer] amounts:[integer]))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_ContainsAll:bool (l1:[integer] l2:[integer]))
    (defun UEV_PositionalVariable (integer-to-validate:integer positions:integer message:string))
    (defun UEV_UniformList (input:[integer]))
    ;;#45M fix: moved from [UC] - was UC_MaxInteger, crashed uncatchably (raw array-bounds
    ;;error, not even `try`-catchable) on an empty list via `(at 0 lst)`. There is no safe
    ;;benign default for "max of nothing" (unlike #20H/Fix #18's HybridArray sum-of-nothing=[]
    ;;case), so the correct fix is a real `enforce`, not a silent default - same root cause/fix
    ;;shape as #44M's UC_IzUnique -> UEV_IzUnique rename.
    (defun UEV_MaxInteger:integer (lst:[integer]))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|INT GOV



    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetIntegersV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                  (compose-capability (GOV|U|INT_ADMIN)))
    (defcap GOV|U|INT_ADMIN ()
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
    ;;
    ;;
    (defun UDC_SplitIntegers:object{OuronetIntegersV1.SplitIntegers} (neg:[integer] pos:[integer])
        {"negative" : neg
        ,"positive" : pos}
    )
    (defun UDC_NonceSplitter:object{OuronetIntegersV1.NonceSplitter}
        (a:[integer] b:[integer] c:[integer] d:[integer])
        {"negative-nonces"          : a
        ,"positive-nonces"          : b
        ,"negative-counterparts"    : c
        ,"positive-counterparts"    : d}
    )
    ;;{5.2}  Compute [UC]
    (defun UC_SplitAuxiliaryIntegerList:object{OuronetIntegersV1.SplitIntegers} (primary:[integer] auxiliary:[integer])
        @doc "Splits an auxiliary integer list into 2 integers list, according to the negatives and positives of the primary"
        (let 
            (
                (indices (enumerate 0 (- (length primary) 1)))
                (neg-indices (filter (lambda (i:integer) (< (at i primary) 0)) indices))
                (pos-indices (filter (lambda (i:integer) (> (at i primary) 0)) indices))
                (neg-counterparts (map (lambda (i:integer) (at i auxiliary)) neg-indices))
                (pos-counterparts (map (lambda (i:integer) (at i auxiliary)) pos-indices))
            )
            (UDC_SplitIntegers neg-counterparts pos-counterparts)
        )
    )
    (defun UC_SplitIntegerList:object{OuronetIntegersV1.SplitIntegers} (input:[integer])
        @doc "Splits an integer list into a negative and postive integer list"
        (let 
            (
                (negatives (filter (lambda (x:integer) (< x 0)) input))
                (positives (filter (lambda (x:integer) (> x 0)) input))
            )
            (UDC_SplitIntegers negatives positives)
        )
    )
    (defun UC_NonceSplitter:object{OuronetIntegersV1.NonceSplitter} (nonces:[integer] amounts:[integer])
        (let
            (
                (ref-U|INT:module{OuronetIntegersV1} U|INT)
                (split-nonces:object{OuronetIntegersV1.SplitIntegers} (ref-U|INT::UC_SplitIntegerList nonces))
                (negative-nonces:[integer] (at "negative" split-nonces))
                (positive-nonces:[integer] (at "positive" split-nonces))
                (split-amounts:object{OuronetIntegersV1.SplitIntegers} (ref-U|INT::UC_SplitAuxiliaryIntegerList nonces amounts))
                (negative-counterparts:[integer] (at "negative" split-amounts))
                (positive-counterparts:[integer] (at "positive" split-amounts))
            )
            (UDC_NonceSplitter
                negative-nonces
                positive-nonces
                negative-counterparts
                positive-counterparts
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;#45M fix: renamed UC_MaxInteger -> UEV_MaxInteger (was a UC_-prefixed function that crashed
    ;;uncatchably - a raw array-bounds runtime error, not even `try`-catchable - on an empty
    ;;list via `(at 0 lst)`). There's no safe benign default for "max of an empty list," so the
    ;;fix is a real `enforce` converting the crash into a clean, catchable rejection - same
    ;;root-cause/fix shape as #44M. Body below the enforce is byte-for-byte unchanged.
    (defun UEV_MaxInteger:integer (lst:[integer])
        (enforce (> (length lst) 0) "UEV_MaxInteger: list cannot be empty")
        (fold
            (lambda
                (acc:integer element:integer)
                (if (> element acc) element acc)
            )
            (at 0 lst)
            (drop 1 lst)
        )
    )
    (defun UEV_ContainsAll:bool (l1:[integer] l2:[integer])
        (let*
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (tl:[bool]
                    (fold
                        (lambda
                            (acc:[bool] item:integer)
                            (ref-U|LST::UC_AppL acc (contains item l2))
                        )
                        []
                        l1
                    )
                )
                (sl:[integer] (ref-U|LST::UC_Search tl true))
                (tl2:integer (length sl))
            )
            (if (= tl2 (length l1))
                true
                false
            )
        )
    )
    (defun UEV_PositionalVariable (integer-to-validate:integer positions:integer message:string)
        @doc "Validates a number (positions-number) as positional variable"
        (enforce (= (contains integer-to-validate (enumerate 1 positions)) true) message)
    )
    (defun UEV_UniformList (input:[integer])
        @doc "Enforces that all elements in the integer list are the same."
        (let
            (
                (fe:integer (at 0 input))
            )  ;; Get the first element in the list
            (map
                (lambda
                    (index:integer)
                    (enforce (= fe (at index input)) "List elements are not the same")
                    true
                )
                (enumerate 0 (- (length input) 1))
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
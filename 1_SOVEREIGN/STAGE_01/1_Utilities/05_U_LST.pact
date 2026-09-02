;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface StringProcessorV2
    @doc "Exported List and String Processor Functions"

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
    ;;
    (defun UC_AppL:list (in:list item))
    (defun UC_Chain:list (in:list))
    (defun UC_FE (in:list))
    (defun UC_InsertFirst:list (in:list item))
    (defun UC_IsNotEmpty:bool (x:list))
    (defun UC_LE (in:list))
    (defun UC_RemoveItem:list (in:list item))
    (defun UC_RemoveItemAt:list (in:list position:integer))
    (defun UC_ReplaceAt:list (in:list idx:integer item))
    (defun UC_ReplaceItem:list (in:list old-item new-item))
    (defun UC_Search:[integer] (searchee:list item))
    (defun UC_SecondListElement (in:list))
    (defun UC_SplitString:[string] (splitter:string splitee:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_NotEmpty:bool (x:list))
    (defun UEV_StringPresence (item:string item-lst:[string]))
    ;;#44M fix: moved from [UC] - was UC_IzUnique, enforces (violates UC_ contract), renamed.
    (defun UEV_IzUnique (lst:[string]))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|LST GOV





    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements StringProcessorV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|LST_ADMIN)))
    (defcap GOV|U|LST_ADMIN ()
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
    ;;
    ;;
    ;;
    ;;
    (defun UC_AppL:list (in:list item)
        @doc "Append an item at the end of the list"
        (+ in [item])
    )
    (defun UC_Chain:list (in:list)
        @doc "Chain list of lists"
        (fold (+) [] in)
    )
    (defun UC_FE (in:list)
        @doc "Returns the first item of a list"
        (UEV_NotEmpty in)
        (at 0 in)
    )
    (defun UC_InsertFirst:list (in:list item)
        @doc "Insert an item at the left of the list"
        (+ [item] in)
    )
    (defun UC_IsNotEmpty:bool (x:list)
        @doc "Return true if the list is not empty"
        (< 0 (length x))
    )
    (defun UC_LE (in:list)
        @doc "Returns the last item of the list"
        (UEV_NotEmpty in)
        (at (- (length in) 1) in)
    )
    (defun UC_RemoveItem:list (in:list item)
        @doc "Remove an item from a list"
        (filter (!= item) in)
    )
    (defun UC_RemoveItemAt:list (in:list position:integer)
        @doc "Removes and item from a list existing at a given position"
        (enforce (and (>= position 0) (< position (length in))) "Position must be non-negative and within the bounds of the list")
        (let
            (
                (before (take position in))
                (after (drop (+ position 1) in))
            )
            (+ before after)
        )
    )
    (defun UC_ReplaceAt:list (in:list idx:integer item)
        @doc "Replace the item at position idx"
        (enforce (and? (<= 0) (> (length in)) idx) "Index out of bounds")
        (UC_Chain
            [
                (take idx in),
                [item],
                (drop (+ 1 idx) in)
            ]
        )
    )
    (defun UC_ReplaceItem:list (in:list old-item new-item)
        @doc "Replace each occurrence of old-item by new-item"
        (map (lambda (x) (if (= x old-item) new-item x)) in)
    )
    (defun UC_Search:[integer] (searchee:list item)
        @doc "Search an item into the list and returns a list of index"
        (if (contains item searchee)
            (let
                (
                    (indexes (enumerate 0 (length searchee)))
                    (match (lambda (v i) (if (= item v) i -1)))
                )
                (UC_RemoveItem (zip (match) searchee indexes) -1)
            )
            []
        )
    )
    (defun UC_SecondListElement (in:list)
        @doc "Returns the second item of a list"
        (UEV_NotEmpty in)
        (at 1 in)
    )
    (defun UC_SplitString:[string] (splitter:string splitee:string)
        @doc "Splits a string using a single string as splitter"
        (if (= 0 (length splitee))
            [] ;If the string is empty return a zero length list
            (let*
                (
                    (sep-pos (UC_Search (str-to-list splitee) splitter))
                    (substart (map (+ 1) (UC_InsertFirst sep-pos -1)))
                    (sublen  (zip (-) (UC_AppL sep-pos 10000000) substart))
                    (cut (lambda (start len) (take len (drop start splitee))))
                )
                (zip (cut) substart sublen)
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;#44M fix: renamed UC_IzUnique -> UEV_IzUnique (was a UC_-prefixed function that enforces,
    ;;violating the UC_ pure-compute contract - same root cause as #43M). There is no "not
    ;;unique" case to return false for: a duplicate aborts the whole transaction via enforce,
    ;;there is no graceful path. The old inline comment ("If all items are unique, the function
    ;;returns true") misleadingly implied a real false-returning predicate contract that never
    ;;existed - fixed to state the actual contract plainly.
    (defun UEV_IzUnique (lst:[string])
        @doc "Enforces that <lst> is composed of unique elements. Aborts the transaction on the \
            \ first duplicate found - there is no false-returning case; always returns true."
        (let
            (
                (unique-set
                    (fold
                        (lambda
                            (acc:[string] item:string)
                            (enforce
                                (not (contains item acc))
                                (format "Unique Items Required, duplicate item found: {}" [item])
                            )
                            (UC_AppL acc item)
                        )
                        []
                        lst
                    )
                )
            )
            true
        )
    )
    (defun UEV_NotEmpty:bool (x:list)
        @doc "Verify and Enforces that a list is not empty"
        (enforce (UC_IsNotEmpty x) "List cannot be empty")
    )
    ;;#75L fix: the [bar]-sentinel check alone let a genuinely empty list [] fall through to
    ;;the generic "not present" message instead of the specific "Empty List detected!" one -
    ;;both cases still correctly aborted the transaction either way (no functional bug), just
    ;;with an inconsistent/less helpful message for the real-[] case. Added `(UC_IsNotEmpty
    ;;item-lst)` to the same enforce so both the [bar] sentinel and a real [] get the specific
    ;;message.
    (defun UEV_StringPresence (item:string item-lst:[string])
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (bar:string (ref-U|CT::CT_BAR))
                (iz-present:bool (contains item item-lst))
            )
            (enforce (and (!= item-lst [bar]) (UC_IsNotEmpty item-lst)) "Empty List detected!")
            (enforce iz-present (format "String {} is not present in list {}." [item item-lst]))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
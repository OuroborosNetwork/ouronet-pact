(module U|VST GOV



    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements UtilityVstV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                  (compose-capability (GOV|U|VST_ADMIN)))
    (defcap GOV|U|VST_ADMIN ()
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
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    (defun UC_MakeVestingDateList:[time] (offset:integer duration:integer milestones:integer)
        @doc "Makes a Times list with unvesting milestones according to vesting parameters"
        (let*
            (
                (present-time:time (at "block-time" (chain-data)))
                (first-time:time (add-time present-time offset))
                (times:[time] [first-time])
            )
            (if (= milestones 1)
                [(add-time first-time duration)]
                (fold
                    (lambda
                        (acc:[time] idx:integer)
                        (let*
                            (
                                (to-add:integer (* idx duration))
                                (new-time:time (add-time first-time to-add))
                            )
                            (+ acc [new-time])
                        )
                    )
                    times
                    (enumerate 1 (- milestones 1))
                )
            )

        )
    )
    (defun UC_SplitBalanceForVesting:[decimal] (precision:integer amount:decimal milestones:integer)
        @doc "Splits an Amount according to vesting parameters"
        (UEV_Milestone milestones)
        (enforce (!= milestones 0) "Cannot split with zero milestones")
        (let
            (
                (split:decimal (floor (/ amount (dec milestones)) precision))
                (multiply:integer (- milestones 1))
            )
            ;;#74L fix: typo "to small" -> "too small" (message text only, no logic change).
            (enforce (> split 0.0) (format "Amount {} too small to split into {} milestones" [amount milestones]))
            (let*
                (
                    (big-chunk:decimal (floor (* split (dec multiply)) precision))
                    (last-split:decimal (floor (- amount big-chunk) precision))
                )
                (enforce (= (+ big-chunk last-split) amount) (format "Amount of {} could not be split into {} milestones succesfully" [amount milestones]))
                (+ (make-list multiply split) [last-split])
            )
        )
    )
    ;;
    (defun UC_VestingID:[string] (dptf-name:string dptf-ticker:string)
        (UCx_SpecialID dptf-name dptf-ticker "Vested" "V")
    )
    (defun UC_SleepingID:[string] (dptf-name:string dptf-ticker:string)
        (UCx_SpecialID dptf-name dptf-ticker "Sleeping" "Z")
    )
    (defun UC_HibernationID:[string] (dptf-name:string dptf-ticker:string)
        (UCx_SpecialID dptf-name dptf-ticker "Hibernating" "H")
    )
    ;;
    (defun UC_FrozenID:[string] (dptf-name:string dptf-ticker:string)
        (UCx_SpecialID dptf-name dptf-ticker "Frozen" "F")
    )
    (defun UC_ReservedID:[string] (dptf-name:string dptf-ticker:string)
        (UCx_SpecialID dptf-name dptf-ticker "Reserved" "R")
    )
    ;;
    (defun UC_EquityID:[string] (sft-name:string sft-ticker:string)
        (UCx_SpecialID sft-name sft-ticker "Equity" "E")  
    )
    ;;
    (defun UCx_SpecialID:[string] (dptf-name:string dptf-ticker:string special-name:string special-prefix:string)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (max-name:integer (ref-U|CT::CT_MAX_TOKEN_NAME_LENGTH))
                (max-ticker:integer (ref-U|CT::CT_MAX_TOKEN_TICKER_LENGTH))
                (caron:string "^")
                (s1:string (+ special-name caron))
                (s2:string (+ special-prefix BAR))
                (l1:integer (- max-name (length s1)))
                (l2:integer (- max-ticker (length s2)))
                (vested-name:string (concat [s1 (take l1 dptf-name)]))
                (vested-ticker:string (concat [s2 (take l2 dptf-ticker)]))
            )
            [vested-name vested-ticker]
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_Milestone (milestones:integer)
        @doc "Restrict Milestone integer between 1 and 250 Milestones"
        (enforce
            (and (>= milestones 1) (<= milestones 250))
            (format "Milestone splitting number {} is out of bounds"[milestones])
        )
    )
    (defun UEV_MilestoneWithTime (offset:integer duration:integer milestones:integer upper-limit-in-seconds:integer)
        @doc "Validates Milestone duration to be lower than 25 years"
        (UEV_Milestone milestones)
        (enforce
            (and (>= offset 0) (>= duration 0))
            "Offset and Duration cannot be negative"
        )
        (enforce
            (<= (+ (* milestones duration ) offset) upper-limit-in-seconds)
            "Upper Lock Time Exceeded"
        )
        ;;<upper-limit-in-seconds> = 788400000 for Vesting and Sleeping
        ;;<upper-limit-in-seconds> = 3153600000 for Hibernating
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
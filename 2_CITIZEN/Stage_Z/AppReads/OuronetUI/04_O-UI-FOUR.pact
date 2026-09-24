;; ===========================================================================================
;; O-UI-FOUR -- the Stoa ICO page.
;; ===========================================================================================
;; OuronetUI entity 4. Template: 01_O-UI-ONE.pact. Rules: ../RULES.md.
;;
;; REPLACES DPL-UR::URC_0013_StoaICO. One read, and it carries TWO live defects.
;;
;; ------------------------------------------------------------------------------------------
;; DEFECT 1 -- DIVISION BY ZERO. FIXED HERE.
;; ------------------------------------------------------------------------------------------
;;     (stoa-for-redemption (floor (* 10000000.0 (/ dollarz-contributed ico-dollarz-contributed)) 12))
;;
;; `ico-dollarz-contributed` is the ICO's running total. Before the first contribution it is
;; 0.0, and Pact raises `Arithmetic exception: div by zero, decimal`.
;;
;; That is worse than an ordinary throw, and this is the part worth remembering: a caller
;; CANNOT defend against it. Measured, not assumed --
;;
;;     (try "THREW" (floor (* 10000000.0 (/ 0.0 0.0)) 12))   ;; still raises; `try` does not catch it
;;
;; so no `try` at any level of a composer would have saved the page. The ICO page was
;; un-renderable from deploy until the first dollar arrived, and it returns to that state if
;; the total is ever reset.
;;
;; FIXED by guarding the divisor. A zero total means nothing has been contributed, so a share
;; of it is 0.0 -- and `price-discovery` is already 0.0 on that path, because dividing by the
;; ten-million CONSTANT is always safe. The two now agree instead of one answering and the
;; other exploding.
;;
;; ------------------------------------------------------------------------------------------
;; DEFECT 2 -- THE END DATE IS SEVEN MONTHS LATE. *** NOT FIXED -- NEEDS AN OWNER RULING. ***
;; ------------------------------------------------------------------------------------------
;;     (time "2026-15-05T20:00:00Z")
;;
;; There is no fifteenth month. Pact does NOT reject this; it CLAMPS. Measured:
;;
;;     (time "2026-15-05T20:00:00Z")  =>  2026-12-05T20:00:00Z
;;     (time "2026-05-15T20:00:00Z")  =>  2026-05-15T20:00:00Z
;;
;; So the countdown every visitor has been shown reads 5 December 2026. The digits are `15` and
;; `05`, and the only valid reading of them is the 15th of May -- a transposed day and month.
;; The live page is therefore almost certainly advertising a deadline seven months after the
;; real one.
;;
;; THE VALUE IS CARRIED THROUGH UNCHANGED, deliberately. A publicly-displayed deadline is not
;; something a porting pass gets to decide, and shipping 15 May because it looks right would
;; move a date the owner has not agreed to move. What changes is that it is no longer HIDDEN:
;; the constant below states the instant it actually produces, in a form that cannot be
;; misread, with the intended alternative beside it. Change CT_IcoEnd and redeploy once ruled.
;; ===========================================================================================

(namespace "ouronet-ns")

(interface OUiFourV1
    @doc "Stoa ICO page read: one account's contribution and earned urSTOA, the global \
        \ totals, the discovered price, and this account's redeemable share."

    ;;{5.2}  Compute [UC]
    (defun UC_Price:string (input-price:decimal))
    ;;{5.3}  Read [UR/URC/URH]
    (defun URC_01|Ico:object (account:string))
)

(module O-UI-FOUR GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiFourV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-FOUR              (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_FOUR_ADMIN)))
    (defcap GOV|O_UI_FOUR_ADMIN ()          (enforce-guard GOV|MD_O-UI-FOUR))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{3}  CONSTANTS
    ;;THE INSTANT DPL-UR ACTUALLY PRODUCES TODAY -- see DEFECT 2 in the file header.
    ;;Its source reads (time "2026-15-05T20:00:00Z"); month 15 does not exist and Pact clamps
    ;;it to 12. Written out here so the date the page displays is legible in the source.
    ;;    intended, pending an owner ruling:  "2026-05-15T20:00:00Z"
    (defconst CT_IcoEnd                     (time "2026-12-05T20:00:00Z"))
    ;;The urSTOA allocation the ICO distributes, and the denominator of the discovered price.
    (defconst CT_IcoAllocation              10000000.0)

    ;;{5}  FUNCTIONS
    ;;{5.2}  Compute [UC]
    (defun UC_Price:string (input-price:decimal)
        @doc "Dollar/cent display form. Copied, not shared -- ../RULES.md rule 7."
        (if (< input-price 0.00001)
            "<0.001¢"
            (if (< input-price 1.00)
                (format "{}¢" [(floor (* input-price 100.0) 3)])
                (format "{}$" [(floor input-price 2)])
            )
        )
    )

    ;;{5.3}  Read [UR/URC/URH]
    ;; ---------------------------------------------------------------------------------------
    ;; CLIENT READS -- called BY NAME from OuronetUI. The `NN|` designator is the pin:
    ;; argument list and key shape are a wire contract.
    ;; ---------------------------------------------------------------------------------------
    (defun URC_01|Ico:object (account:string)
        @doc "THE ONE READ FOR THE PAGE: this account's contribution and earned urSTOA, the \
            \ four global totals, the price the contributions have discovered, and the STOA \
            \ this account could redeem at that price. \
            \ \
            \ Replaces DPL-UR::URC_0013_StoaICO, key-for-key, with the div-by-zero fixed."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (dollarz-contributed:decimal (STOAICO.UR_User1 account))
                (ico-dollarz-contributed:decimal (STOAICO.UR_Global1))
            )
            {"dollarz-contributed"  : dollarz-contributed
            ,"ur-stoa-earned"       : (STOAICO.UR_User2 account)
            ;;
            ,"urstoa-left"          : (STOAICO.UR_Global2)
            ,"ico-dollarz"          : ico-dollarz-contributed
            ,"participants"         : (STOAICO.UR_Global3)
            ;;
            ,"vault-wstoa"          : (STOAICO.UR_Global4)
            ,"ico-end"              : CT_IcoEnd
            ,"price-discovery"      : (UC_Price (/ ico-dollarz-contributed CT_IcoAllocation))
            ;;THE FIX. An empty ICO means an empty share, not an arithmetic exception that no
            ;;caller's `try` can catch. See DEFECT 1 in the file header.
            ,"stoa-for-redemption"  :
                (if (= ico-dollarz-contributed 0.0)
                    0.0
                    (floor (* CT_IcoAllocation
                              (/ dollarz-contributed ico-dollarz-contributed)) 12)
                )
            ,"iz-activated"         :
                (!= (ref-U|CT::CT_BAR)
                    (try (ref-U|CT::CT_BAR) (ref-DALOS::UR_AccountPublicKey account)))
            }
        )
    )
)

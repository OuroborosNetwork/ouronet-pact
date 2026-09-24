;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 11
;; OUiFourV1 (interface) + O-UI-FOUR (module)  --  OuronetUI entity 4: STOAICO
;; =========================================================================================
;; INDEPENDENT of the other PureV2 files. One read, and it carries TWO live defects.
;;
;; DEFECT 1 -- DIVISION BY ZERO. FIXED.
;; stoa-for-redemption divides by the ICO's running dollar total, which is 0.0 before the first
;; contribution. Pact raises `Arithmetic exception: div by zero, decimal`, and -- measured, not
;; assumed -- `try` DOES NOT CATCH IT. No composer at any level could have defended the page.
;; The ICO page was un-renderable from deploy until the first dollar arrived. Guarded now: an
;; empty ICO yields an empty share, which is what price-discovery already returned on that path
;; because it divides by the ten-million CONSTANT.
;;
;; DEFECT 2 -- THE END DATE IS SEVEN MONTHS LATE. *** NOT FIXED. NEEDS AN OWNER RULING. ***
;; The source says (time "2026-15-05T20:00:00Z"). There is no fifteenth month, and Pact does
;; not reject it -- it CLAMPS. Measured:
;;
;;     (time "2026-15-05T20:00:00Z")  =>  2026-12-05T20:00:00Z
;;     (time "2026-05-15T20:00:00Z")  =>  2026-05-15T20:00:00Z
;;
;; So the countdown every visitor sees reads 5 December 2026, and the only sensible reading of
;; those digits is the 15th of May. The value is CARRIED THROUGH UNCHANGED on purpose: a
;; publicly-advertised deadline is not a porting decision. What changes is that it is no longer
;; hidden -- CT_IcoEnd states the instant it actually produces, with the intended alternative
;; beside it. Change that one constant and redeploy once ruled.
;;
;; SIGNING -- namespace keyset only. Both are FIRST deploys -- no interface-upgrade hazard, and a
;; module's first deploy checks no governance. A later UPGRADE will check the module's
;; own GOV|*_ADMIN.
;;
;; MEASURED in the REPL fixture (Stage 1 + Stage 2, nothing else from this round):
;;   deploy 4,672 gas
;;   URC_01|Ico == DPL-UR.URC_0013 field for field on a funded ICO
;;   on an unfunded ICO DPL-UR raises and this answers
;; =========================================================================================

;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/04_O-UI-FOUR.pact
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


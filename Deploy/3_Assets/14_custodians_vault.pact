;; ===========================================================================================
;; TRANSACTION 14 of 15  —  THE CUSTODIANS VAULT  (admin)
;; AQP-BOOT.C_Step13_CreateCustodiansVault
;;
;; WHAT THIS DOES — seven operations, one transaction. Everything the Custodians delegated-
;; staking vault needs to exist, and NO agency:
;;     1. three quintessence score MODELS          bronze / silver / golden
;;     2. the TRIPLET model                        what every agency instantiates
;;     3. the class-0 FVT                          the vault itself
;;     4. a MULTIPLET_BASE OURO reward link        on the Step-10 OURO|AURYN|ELITEAURYN ladder
;;     5. the HETEROGENEOUS quality split          20/40/40 · 40/30/30 · 60/20/20
;;     6. the DSA template                         unit-score 20000
;;     7. the Custodians pool                      aqp-class 3 (DPSF)
;;
;; RUN THIS ONCE. Transaction 15 opens the first agency and is run once per operator.
;;
;; PREREQUISITES, all from earlier transactions in this folder:
;;   * transaction 10 (C_Step10_IssueMultipletFamily) — the OURO|AURYN|ELITEAURYN family.
;;     The family id is deterministic, a plain concat, NOT UDC_Makeid, so you can write it
;;     out rather than paste it:  F|<ouro>|<auryn>|<elite-auryn>
;;   * the live Custodians DPSF collection.
;;
;; WHY class 0 AND NOT A TREASURY. This is a "DSA Treasury" in product terms and behaves like
;; one — users stake an SFT collection, no LP involved — but 08_DSA.pact refuses anything
;; else outright:  (enforce (= (RPS.UR_FVT|FvtClass fvt-id) 0) "DSA vault must be a class-0 FVT")
;; Capture arithmetic is denominated in an LP denominator that classes 1-2 do not have.
;; Delegation members are then admitted with swpair "|" and ghost-tvl 0.0, which skips every
;; LP rule. So class 0 is the container; the behaviour is vault-like.
;;
;; ORDER INSIDE THE FUNCTION IS FORCED, not stylistic. C_SetQualitySplit's guard requires the
;; reward link to already exist, to BE MULTIPLET_BASE, and to carry an ACTIVE family — and a
;; link is MULTIPLET_BASE precisely because C_AddRewardLink was handed a family id instead of
;; BAR. family -> reward link -> split. It cannot be reordered.
;;
;; THE NUMBERS
;;   unit-score 20000 publishes BOTH thresholds. UEV_OpenGate requires quintessence >=
;;   unit-score/2, so 20000 per earning unit and 10000 to open an agency. Fixed at half by
;;   design — there is no second knob and one is not wanted: a settable gate could be raised
;;   above unit-score, making agencies unopenable while looking valid.
;;
;;   Per-unit quintessence is 1 / 10 / 100 for bronze / silver / golden, which is not invented:
;;   the collection's own descriptions say nonces 1, 2 and 3 are EACH "a third of Ouronet
;;   Financial Ownership", spread over 10000 / 1000 / 100 units. So each tier is worth 10000
;;   quintessence and the whole collection 30000.
;;
;;   >> CONSEQUENCE WORTH SEEING BEFORE YOU SEND THIS. At unit-score 20000 an agency needs a
;;   >> FULL THIRD of all Custodians, and the entire collection supports ONE node
;;   >> (floor 30000/20000 = 1). If that is not the intended exclusivity, change
;;   >> BOOT|CUSTODIANS_UNIT_SCORE now — it is one constant today and a migration later.
;;
;; NOT COVERED HERE, and each needs its own decision:
;;   * Nonce 4 (OG Founder, 105 units) scores nothing. A triplet has no fourth lane.
;;   * "20% of daily OURO issuance delivered here" is an inject/emission lever OUTSIDE AQP.
;;     Rewards arrive through AQP-FVT|CC_Inject; no FVT field schedules them.
;;   * The oracle. Capture stays 0 until one reports nodes — see transaction 15's tail.
;;
;; SIGNING: GOV|AQP_BOOT_ADMIN, plus coin.TRANSFER managed caps for the STOA-priced issuances
;; (score models, FVT, pool). Measured in the REPL at 12x UR_UsagePrice "smart", four-way split.
;;
;; PROVEN: <<TX-BOOT-13>> in REPL/Stage_02/[6.2.9]_AQP-BOOT-FULL.repl drives this exact
;; function and reads the result back out of RPS and DSA — class, unit-score, template active,
;; split mode and two of the three split rows. It runs in the gate.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step13_CreateCustodiansVault
    PATRON_KONTO
    OWNER_KONTO                          ;; <- owner of the vault FVT
    "CUSTODIANS_DPSF_ID"                 ;; <- the live Custodians collection (REPL: DHOC-98c486052a51)
    "OURO-8Nh-JO8JO4F5"                  ;; <- OURO: BOTH the FVT common-denominator and the reward token
    "F|OURO-8Nh-JO8JO4F5|AURYN-8Nh-JO8JO4F5|ELITEAURYN-8Nh-JO8JO4F5"
                                         ;; <- the Step-10 multiplet family. MUST be this ladder:
                                         ;;    the split routes per-mille across ITS t0/t1/t2, so a
                                         ;;    different family silently redirects every payout.
)

;; OUTPUT — keep it. It names the fvt-id, pool-id and the four model ids. Transaction 15 needs
;; none of them (it derives all of them from the same constants), but the ids carry this
;; transaction's block hash and cannot be recomputed once the block closes.

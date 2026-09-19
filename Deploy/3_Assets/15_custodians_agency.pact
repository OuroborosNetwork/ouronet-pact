;; ===========================================================================================
;; TRANSACTION 15 of 15  —  THE FIRST CUSTODIANS AGENCY  (you, staking your own assets)
;; AQP-BOOT.CC_Step14_OpenCustodiansAgency
;;
;; WHAT THIS DOES — four operations, one transaction:
;;     1. instantiate the triplet model for THIS operator — the factory mints three scores,
;;        their SF definitions, and the triplet, in a single call
;;     2. employ all three scores in the Custodians pool
;;     3. admit the triplet as a delegation member of the vault
;;     4. stake YOUR nonces and clear the open gate — atomically
;;
;; Run once PER OPERATOR. This run is the vault's first agency.
;;
;; YOU ARE THE OPERATOR — there is deliberately no separate operator argument. The caller is
;; the operator: C_AdmitAgency admits with `XE_AdmitDelegationMember fvt-id triplet PATRON`,
;; RPS then enforces `silver-owner == operator` AND that operator's account ownership, and the
;; stake in step 4 comes from patron as well. An earlier draft of this function took an
;; `operator-konto` beside `patron`; it could only ever hold the same value, and anything else
;; failed deep inside RPS with a message naming neither. Removed — a parameter that cannot vary
;; is worse than no parameter, because it reads like a choice.
;;
;; THE OPEN IS ALL-OR-NOTHING. UEV_OpenGate is the TERMINAL step inside CC_OpenAgency
;; (admit -> stake -> gate). A stake too small to reach unit-score/2 does not leave a
;; half-built agency: it reverts the entire transaction. So a failure here costs gas and
;; nothing else.
;;
;; HOW MUCH YOU MUST STAKE — 10000 quintessence (unit-score/2), by any mix:
;;
;;     nonce 1 Bronze   1 per unit    ->  10000 units   (the entire bronze tier)
;;     nonce 2 Silver  10 per unit    ->   1000 units   (the entire silver tier)
;;     nonce 3 Golden 100 per unit    ->    100 units   (the entire golden tier)
;;
;;   Each tier is exactly one third of the collection and exactly 10000 quintessence, which is
;;   why any ONE tier in full opens an agency. Mixing works: 50 golden + 500 silver = 10000.
;;
;;   FRAGMENTS COUNT THE SAME. A fragmented nonce is negative (-1/-2/-3) and scales x0.001,
;;   and one whole fragments into exactly 1000 pieces — so 100 whole golden and 100000 golden
;;   fragments are both 10000 quintessence. Stake whichever you hold; pass the NEGATIVE nonce
;;   for fragments. Nonces 1, 2 and 3 are fragmentable; nonce 4 (OG Founder) is not, and scores
;;   nothing — it has no lane in a triplet.
;;
;; AFTER THIS TRANSACTION THE AGENCY EARNS NOTHING YET, and that is expected, not a fault:
;;     capture-units  = min( floor(Q / unit-score), NODES )
;;   `nodes` is oracle-reported and starts at 0, so capture is 0 and the agency's share of any
;;   inject is 0. Two more calls, in order, and they are NOT in this folder because they are
;;   operational rather than deployment:
;;     (TS02-C3.AQP-DSA|C_SetOracleAuth  patron fvt-id <oracle-guard>)   <- once, vault owner
;;     (TS02-C3.AQP-DSA|C_OracleWrite    patron fvt-id <triplet-id> <nodes> <uptime>)
;;   C_SetOracleAuth MUST come first: C_OracleWrite hard-reads the oracle-auth row and aborts
;;   if it is missing. `uptime` is per-mille (1000 = full). If quintessence later changes,
;;   AQP-DSA|C_RecomputeCapture is permissionless.
;;
;; FUTURE AGENCIES. This function is GOV|AQP_BOOT_ADMIN-gated, like every AQP-BOOT step, which
;; is right for the first agency. Other operators do NOT need it and must not be given the
;; admin key: the public path is TS02-C3.AQP-DSA|CC_OpenAgency, preceded by their own
;; AQP-SCR|C_IssueScoreFromModel against the SAME triplet model and three AQP-POOL|C_AddScore
;; calls. This function is exactly that sequence with the model id supplied for you.
;;
;; SIGNING: GOV|AQP_BOOT_ADMIN + your account ownership + coin.TRANSFER managed caps for the
;; STOA-priced score issuance, and the DPSF custody transfer of your stake.
;;
;; PROVEN: <<TX-BOOT-14>> in REPL/Stage_02/[6.2.9]_AQP-BOOT-FULL.repl opens an agency through
;; this function staking 100 WHOLE golden units and asserts the operator row and exactly
;; 10000.0 quintessence. Whole nonces are tested deliberately: every DSA fixture in Kursan/
;; stakes fragment negatives only, and under a fragment-only score model a whole-nonce stake
;; scores ZERO with nothing to catch it.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.CC_Step14_OpenCustodiansAgency
    PATRON_KONTO                         ;; <- YOU. The operator, the staker, the fee earner.
    "AGENCY_NAME"                        ;; <- names the three scores <name>Bronze/Silver/Golden.
                                         ;;    Must be unique per agency or the second collides
                                         ;;    on the shared branding table. REPL uses "OuronetPrime".
    "CUSTODIANS_DPSF_ID"                 ;; <- same collection id as transaction 14
    [3]                                  ;; <- YOUR opening stake. [3] = whole golden (100 units
                                         ;;    = 10000 quintessence). Use [-3] for golden fragments,
                                         ;;    [1] for the whole bronze tier, [1 2 3] to stake all.
    100                                  ;; <- fee-per-mille on DELEGATORS only, never on your own
                                         ;;    stake. 100 = 10%. Range 10..500 (1%..50%).
)

;; OUTPUT — keep it. It names the agency, the triplet id, and the three score ids. The triplet
;; id is what C_OracleWrite, C_SetAgencyFee, C_RecomputeCapture and CC_Collect all take, and it
;; carries this transaction's block hash, so it cannot be recomputed once the block closes.

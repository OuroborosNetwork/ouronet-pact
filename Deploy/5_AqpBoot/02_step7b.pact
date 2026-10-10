;; =========================================================================================
;; AQP-BOOT STEP 7b — the pool StoicPower never had
;; =========================================================================================
;;
;; REQUIRES the PureV5 AQP-BOOT upgrade to be deployed first.
;;
;; Creates `StoicismPool` at aqp-class 1 (non-LP true fungible) over the STOICISM token and
;; employs the existing StoicPower score in it. StoicPower is the only score on chain with no
;; pool at all.
;;
;; MUST RUN BEFORE 9b, and that is a HARD abort rather than a shortfall: admission reads the
;; score's pool row even at vault class where the value is discarded, so a pool-less score fails
;; `C_AddScoreEntity` with `No value found in table AQP|T|Pool for key: |`.
;;
;; STOICISM-hCNmIIxczuBs confirmed by the owner 2026-10-08 (not STOICPAY-64EvuR4kgZHd).
;; A pool's asset is permanent.
;; =========================================================================================

(ouronet-ns.AQP-BOOT.C_Step7b_CreateStoicismPool
    "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî"
    "STOICISM-hCNmIIxczuBs"
    "StoicPower-8dDr4Cq6glCH"
)

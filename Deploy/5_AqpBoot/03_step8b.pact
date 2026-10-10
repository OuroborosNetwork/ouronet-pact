;; =========================================================================================
;; AQP-BOOT STEP 8b — the three FVT entities Step 8 never issued
;; =========================================================================================
;;
;; REQUIRES the PureV5 AQP-BOOT upgrade to be deployed first.
;;
;;   NosferatuTreasury    fvt-class 2 (treasury)  -- admits NosferatuDracula, score-class 4
;;   WonderCoachTreasury  fvt-class 2 (treasury)  -- admits WonderCoach,      score-class 3
;;   StoicismVault        fvt-class 1 (VAULT)     -- admits StoicPower,       score-class 1
;;
;; THE STOICISM ONE IS A VAULT, NOT A TREASURY. `URC_ScoreClassMatchesFvtClass` admits 3/4 at
;; treasury(2) and 1/2 at vault(1); issuing it as a treasury would deploy fine and then refuse
;; StoicPower at admission, a failure three steps downstream of its cause.
;;
;; SAFE AFTER STEP 8 -- three NEW names, so nothing collides.
;;
;; Its three ids are NOT pastable in advance (`UDC_Makeid` is `<name>-<prev-block-hash>`), which
;; is why 04 and 05 look theirs up by name instead of taking them as arguments.
;; =========================================================================================

(ouronet-ns.AQP-BOOT.C_Step8b_IssueLateFvtEntities
    "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî"
    "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî"
)

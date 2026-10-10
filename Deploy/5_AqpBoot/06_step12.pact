;; =========================================================================================
;; AQP-BOOT STEP 12 — reward tokens on the five Step-8 treasuries
;; =========================================================================================
;;
;; THE LAST OF THE ORIGINAL LADDER. Measured on chain 2026-10-08: steps 10 and 11 have landed
;; (OuroLpFarm carries 1 reward, SilverSnakePower's fvt-link is the farm), and all five
;; treasuries below read `EnabledRewardCount = 0` -- so this is the only one left.
;;
;; THE MAPPING IS THE MODULE'S, not a choice made here:
;;     SubsidiaryTreasury      <- Auryn
;;     CodingDivisionTreasury  <- wSTOA
;;     SnakesTreasury          <- Auryn
;;     CompanySharesTreasury   <- Ouroboros
;;     BloodshedTreasury       <- Auryn AND wSTOA   (owner ruling 2026-09-19; the only
;;                                                   multi-reward entity in the round)
;; Step 12 issues six links from five arguments. Reward state is per (FVT, token) --
;; `FVT|T|RPS|Global` is keyed `fvt-id | dptf-id` -- so two links are two rows, by construction.
;;
;; THE TOKEN IDS WERE RESOLVED FROM THEIR CANONICAL READERS, not from a ticker guess:
;;     (ouronet-ns.DALOS.UR_OuroborosID)    -> OURO-8Nh-JO8JO4F5
;;     (ouronet-ns.DALOS.UR_WrappedStoaID)  -> WSTOA-8Nh-JO8JO4F5
;;
;; WITHOUT THIS, NOTHING THE LADDER BUILT CAN BE STAKED INTO: an employed score whose FVT has no
;; enabled reward token aborts every stake in the FVT pipeline (05_FVT.pact:1210). Step 9 admitted
;; the nine scores; until this lands, all five treasury-backed pools still refuse.
;;
;; 12b is independent of this one -- it covers the three LATE entities and depends only on 8b.
;; Either order.
;; =========================================================================================

(ouronet-ns.AQP-BOOT.C_Step12_AddFvtRewardLinks
    "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî"
    "SubsidiaryTreasury-x_P-KU2bWWt9"
    "CodingDivisionTreasury-x_P-KU2bWWt9"
    "SnakesTreasury-x_P-KU2bWWt9"
    "CompanySharesTreasury-x_P-KU2bWWt9"
    "BloodshedTreasury-x_P-KU2bWWt9"
    "AURYN-8Nh-JO8JO4F5"     ;; reward-auryn-id
    "OURO-8Nh-JO8JO4F5"      ;; reward-ouroboros-id
    "WSTOA-8Nh-JO8JO4F5"     ;; reward-wstoa-id
)

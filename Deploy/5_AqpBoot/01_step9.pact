;; =========================================================================================
;; AQP-BOOT STEP 9 — admit the nine ladder scores onto the five Step-8 treasuries
;; =========================================================================================
;;
;; EVERY ID BELOW WAS READ OFF MAINNET on 2026-10-08, not derived. `UDC_Makeid` is
;; `<name>-<prev-block-hash>`, so recomputing an id for an entity created in an EARLIER
;; transaction returns a DIFFERENT id -- which is why these are pasted literals and why the
;; three block suffixes differ:
;;
;;     -x_P-KU2bWWt9   the five FVT entities, from Step 8
;;     -kzrnaRLI1ht9   the five Subsidiary scores, from Step 5
;;     -S2KMEHRINZER   the four core scores, from Step 4
;;
;; SIMULATED UNSIGNED AGAINST MAINNET: this stops at `GOV|AQP_BOOT_ADMIN` -- the admin keyset --
;; and nowhere earlier, so every precondition already holds. Nothing needs to be deployed first.
;;
;; INDEPENDENT of the PureV5 round and of Steps 7b/8b/9b/12b. Run it whenever.
;; =========================================================================================

(ouronet-ns.AQP-BOOT.C_Step9_AddFvtScoreEntities
    "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî"
    "SubsidiaryTreasury-x_P-KU2bWWt9"
    "CodingDivisionTreasury-x_P-KU2bWWt9"
    "SnakesTreasury-x_P-KU2bWWt9"
    "CompanySharesTreasury-x_P-KU2bWWt9"
    "BloodshedTreasury-x_P-KU2bWWt9"
    [
        "SubsidiaryBloodshed-kzrnaRLI1ht9"
        "SubsidiaryBunnies-kzrnaRLI1ht9"
        "SubsidiaryCodingDivision-kzrnaRLI1ht9"
        "SubsidiaryNosferatu-kzrnaRLI1ht9"
        "SubsidiaryWonderCoach-kzrnaRLI1ht9"
    ]
    "TheCodingDivision-S2KMEHRINZER"
    "DemiourgosSnakes-S2KMEHRINZER"
    "DemiourgosShareholder-S2KMEHRINZER"
    "Bloodshed-S2KMEHRINZER"
)

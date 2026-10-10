;; =========================================================================================
;; AQP-BOOT STEP 9b — admit the three late scores
;; =========================================================================================;;
;; !! THE FIRST VERSION OF THIS FILE FAILED ON CHAIN, and the cause was in the file, not the
;;    step. It resolved the three ids itself with
;;
;;        (keys ouronet-ns.AQP-FVT.FVT|T)
;;
;;    -- a DIRECT TABLE READ from outside the owning module, which Pact requires module admin
;;    for. The real transaction refused it:
;;
;;        Module admin is necessary for operation but has not been acquired: ouronet-ns.AQP-FVT
;;
;;    IT SIMULATED CLEAN. A `/local` read does not enforce module admin, so the check that was
;;    supposed to catch exactly this kind of mistake could not see it. The lesson is narrow and
;;    worth keeping: `/local` proves a body RESOLVES; it does not prove the privileges are there.
;;
;;    The lookup existed only because 8b's ids are `<name>-<prev-block-hash>` and could not be
;;    predicted. They can now: 8b has run, and these are the ids it minted (VbI5pmK2CWEf).
;;    Literals need no privilege, so the problem is gone rather than worked around.
;;
;; PRECONDITIONS, all confirmed on chain 2026-10-08:
;;   7b ran -- StoicPower sits in StoicismPool-k78OydjHV7T-   (without a pool this ABORTS)
;;   8b ran -- the three entities below exist
;;
;; ADMISSION IS WRITE-ONCE: `fvt-link` is never re-pointed, so re-running this ABORTS rather
;; than moving a score between aggregators. The failed attempt wrote nothing.
;; =========================================================================================

(ouronet-ns.AQP-BOOT.C_Step9b_AddLateFvtScoreEntities
    "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî"
    "NosferatuTreasury-VbI5pmK2CWEf"
    "WonderCoachTreasury-VbI5pmK2CWEf"
    "StoicismVault-VbI5pmK2CWEf"
    "NosferatuDracula-RSzEOOdoQqc9"
    "WonderCoach-nK4O_C00so9w"
    "StoicPower-8dDr4Cq6glCH"
)

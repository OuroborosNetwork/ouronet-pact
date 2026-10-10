;; =========================================================================================
;; AQP-BOOT STEP 12b — one reward token on each late entity
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
;; NOT OPTIONAL -- an employed score whose FVT has no enabled reward token makes every stake
;; abort in the FVT pipeline (05_FVT.pact:1210), so 7b/8b/9b without this build three
;; aggregators nobody can stake into.
;;
;; !! CHECK THE WONDERCOACH LINE BEFORE SIGNING.
;;    Owner, 2026-10-08: "coding division and nosferatu dracula we use wstoa as reward tokens."
;;    NosferatuDracula -> WSTOA is explicit. CodingDivisionTreasury is NOT one of these three --
;;    it is a Step-8 entity and Step 12 already links it to WSTOA. The second NEW entity is
;;    WONDERCOACH, which that sentence does not name, so WSTOA below is an INFERENCE and not a
;;    ruling. Change the one line if it is wrong.
;;    Reward links are additive (FVT|T|RPS|Global is keyed `fvt-id | dptf-id`), so a wrong one
;;    is corrected by ADDING the right one, never by replacing.
;;
;; DEPENDS ONLY ON 8b. It may run before or after 10/11/12 -- nothing in those touches these
;; three entities.
;; =========================================================================================

(ouronet-ns.AQP-BOOT.C_Step12b_AddLateFvtRewardLinks
    "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî"
    "NosferatuTreasury-VbI5pmK2CWEf"
    "WonderCoachTreasury-VbI5pmK2CWEf"
    "StoicismVault-VbI5pmK2CWEf"
    "WSTOA-8Nh-JO8JO4F5"   ;; NosferatuTreasury   <- owner ruling
    "WSTOA-8Nh-JO8JO4F5"   ;; WonderCoachTreasury <- INFERRED, confirm
    "WSTOA-8Nh-JO8JO4F5"   ;; StoicismVault       <- owner ruling: stake Stoicism, earn WSTOA
)

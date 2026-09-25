;; ===========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 15
;; CREATE EIGHT MISSING TABLES, then rebuild the swap graph.  *** RUN THIS FIRST. ***
;; ===========================================================================================
;; NOT A MODULE DEPLOY. Eight `create-table` forms and one admin call. Hand-written, which is
;; why `REPL/tools/_purev2.py` lists it as HANDWRITTEN rather than generating its body.
;;
;; ------------------------------------------------------------------------------------------
;; WHAT IS BROKEN, AND IT IS NOT THE READ MIGRATION
;; ------------------------------------------------------------------------------------------
;; The True Fungibles and Orto Fungibles pages show no amounts. The cause is one table:
;;
;;     Error during database operation: Table access failed because table
;;     ouronet-ns.SWPT_SWPT|PathCache was not found.
;;
;; `SWPI::URC_TokenDollarPrice` reaches SWPT's path cache, every wallet row is priced through
;; it, and a MISSING-TABLE error is not catchable -- `try` does not stop it, so the whole list
;; read fails rather than degrading row by row. That is why the pages are blank rather than
;; showing zeroes.
;;
;; MEASURED, BOTH SIDES: `DPL-UR::URC_0008a_TrueFungibleEntry` fails with the identical error.
;; So this predates the AppReads migration and the redirect's fallback cannot help -- both
;; paths sit on the same broken read. The migration did not cause it; it made it visible.
;;
;; ------------------------------------------------------------------------------------------
;; HOW EIGHT TABLES WENT MISSING
;; ------------------------------------------------------------------------------------------
;; `_deploybundle.py` decides per module whether a round is a FIRST deploy or an UPGRADE. An
;; upgrade must not re-run `create-table` -- doing so aborts the whole transaction -- so in
;; upgrade mode it emits the calls COMMENTED OUT, with a note saying "if any of these is NEW
;; since the last deploy, uncomment JUST it".
;;
;; That decision came from `NEW_KEYS`, a HAND-MAINTAINED list which for round V1 held exactly
;; `["/03_AQP/", "04_AQP-BOOT.pact"]`. Every other module was assumed already live, so 161
;; create-table calls shipped commented, and nobody uncommented the ones that were genuinely
;; new. Probing all 161 against mainnet found EIGHT that do not exist:
;;
;;     DALOS      DALOS|StoaLedger                                      (02_deploy)
;;     SWPT       SWPT|Graph, SWPT|PathCache, SWPT|TopologyVersion      (06_deploy)
;;     TS02-C3    P|T, P|MT                                             (21_deploy)
;;     TS02-CPAD  P|T, P|MT                                             (22_deploy)
;;
;; THE GATE COULD NOT HAVE CAUGHT THIS, and that is the part worth fixing rather than just
;; patching. Every REPL fixture loads modules in GENESIS mode, where every create-table runs --
;; so the tables always exist in test and the pricing path is always healthy. The deploy round
;; runs in UPGRADE mode, where none of them runs. Nothing compared the two. See
;; `REPL/tools/_livetables.py`.
;;
;; ------------------------------------------------------------------------------------------
;; WHY A STANDALONE create-table AND NOT FOUR MODULE REDEPLOYS
;; ------------------------------------------------------------------------------------------
;; `create-table` is a top-level form that needs the owning module's admin, not a place in that
;; module's own deploy transaction. Verified in the REPL: a table declared by `deftable` but
;; never created can be created in a LATER transaction, and reads against it work immediately
;; afterwards. So this is one cheap transaction instead of four module upgrades, and it touches
;; no code.
;;
;; ------------------------------------------------------------------------------------------
;; THE REBUILD IS NOT OPTIONAL
;; ------------------------------------------------------------------------------------------
;; Creating SWPT|Graph gives an EMPTY graph. It is written by XI_UpdatePair at pool issuance,
;; and every pool now on chain was issued while the table did not exist, so those writes were
;; lost. An empty graph means no route to a priced token, which reads as a price of zero --
;; better than a crash, still wrong.
;;
;; `SWPI::A_RebuildGraph` exists for exactly this: it calls SWPT::XE_UpdateGraph once per
;; EXISTING swpair, which is what issuance already does per new one. Its writes are idempotent,
;; so it is safe to re-run. Measured in the fixture: 65,534 gas.
;;
;; SIGNING -- namespace keyset AND the Demiurgoi keyset. `create-table` enforces each owning
;; module's admin, and DALOS, SWPT, TS02-C3, TS02-CPAD and SWPI are all
;; keyset-ref-guard(GOV|Demiurgoi), so one signature set covers every form here.
;;
;; A_RebuildGraph runs CAP_EnforceAccountOwnership on its `executor`, so the second argument
;; must be an Ouronet account the signer owns. It is filled in below with AncientHodler's
;; account, read off the chain rather than typed -- NOTHING TO EDIT, paste and send.
;;
;; IF ANY create-table BELOW ABORTS with "table already exists", that table was created between
;; the probe and this transaction. Delete just that line and resend -- the forms are
;; independent, and the probe that produced this list is re-runnable:
;;     python3 REPL/tools/_livetables.py --probe
;; ===========================================================================================

(namespace "ouronet-ns")

;; --- DALOS ---------------------------------------------------------------------------------
(create-table ouronet-ns.DALOS.DALOS|StoaLedger)

;; --- SWPT: the three that break every token price ---------------------------------------
(create-table ouronet-ns.SWPT.SWPT|Graph)
(create-table ouronet-ns.SWPT.SWPT|PathCache)
(create-table ouronet-ns.SWPT.SWPT|TopologyVersion)

;; --- Talos policy tables ---------------------------------------------------------------
(create-table ouronet-ns.TS02-C3.P|T)
(create-table ouronet-ns.TS02-C3.P|MT)
(create-table ouronet-ns.TS02-CPAD.P|T)
(create-table ouronet-ns.TS02-CPAD.P|MT)

;; --- backfill the adjacency graph from every pool already on chain -----------------------
(ouronet-ns.SWPI.A_RebuildGraph "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî" "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")

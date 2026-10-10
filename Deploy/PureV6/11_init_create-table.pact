;; -------------------------------------------------------------------------
;; TX 11/11 -- INIT: create the sleep-term ledger table
;;
;; RUN THIS *AFTER* TX 03 (AQP-SCORE) HAS LANDED, AND BEFORE ANYONE STAKES A SLEEPING BATCH.
;;
;; WHY IT IS A SEPARATE TRANSACTION. `create-table` ABORTS when the table already exists, so an
;; UPGRADE source must not contain one -- `_deploybundle.py` and `_purev6.py` both strip them for
;; exactly that reason, and `check_shape()` is fatal on any that survive. A table added to an
;; already-deployed module therefore has to be created by itself, once, by hand. That is this file.
;;
;; WHAT IT IS FOR. `SCR|T|SleepStake` records the time a sleeping or hibernating lock had LEFT at
;; the moment it was staked, keyed `<DPOF-ID> | <Nonce>` -- the same pair DPOF keys its own nonce
;; data by. The unstake reverses THAT figure instead of recomputing from the live multiplier.
;;
;; Without it, a duration-weighted multiplier decays while the position is held, so the reversal
;; returns LESS than was credited and the difference stays on the holder's base forever as weight
;; for a position nobody holds -- and tradeable. Measured in [6.2.17] TX-RERATE-04: a 25-year
;; batch credits 200.0 and a recomputation gives back 100.0.
;;
;; IF THIS TRANSACTION IS SKIPPED, every sleeping stake aborts on the first read of the table.
;; That is a loud failure rather than a silent one, which is the right way round -- but it means
;; sleeping stakes are DOWN until it lands, so do not announce custody before then.
;;
;; ONE ROW PER NONCE EVER STAKED, holding a single decimal -- the TERM, not the weight.
;; A term is ceiling-INDEPENDENT, which is what lets one row serve every score on the pool: each
;; re-derives its own figure at its own precision. Storing the weight would have needed one row
;; per (score, nonce) -- seven times the rows on a seven-score pool. Rows are written once and never
;; cleared: every employed score reverses against the row in the same transaction, so clearing it
;; would leave whichever score ran second reading 0.0. Pact cannot delete rows in any case, and a
;; nonce cannot return -- unsleeping burns it and `DPOF::XI_DebitNonces` retires a fully-debited
;; nonce to supply -1.0 permanently.
;;
;; SIGNERS: the AQP-SCORE module governance keyset (the same one that signed TX 03).
;; NOTE: `acquire-module-admin` is REQUIRED -- see the comment above the form.
;; -------------------------------------------------------------------------

(namespace "ouronet-ns")

;; MODULE ADMIN MUST BE ACQUIRED FIRST, and omitting it is what made the first attempt at this
;; transaction fail on chain with "Module admin is necessary but has not been acquired".
;;
;; `create-table` on a module you are not currently inside is a GOVERNED operation: Pact 5 will
;; not let an outside caller create a table belonging to AQP-SCORE without first satisfying that
;; module's governance. Inside a module's own deploy this is implicit, which is why every other
;; create-table in this repo -- all of them in first-deploy sources -- needs no such line and why
;; the omission was invisible until a table was added to an ALREADY-DEPLOYED module.
;;
;; The signer below must therefore be the AQP-SCORE governance keyset, not merely any admin.
(acquire-module-admin AQP-SCORE)

(create-table ouronet-ns.AQP-SCORE.SCR|T|SleepStake)

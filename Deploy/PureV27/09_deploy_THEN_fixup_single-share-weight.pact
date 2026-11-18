;; ═══════════════════════════════════════════════════════════════════════════
;;  PureV27 · REPAIR  —  single-share-weight onto every score.  CHAIN 0.
;;
;;  RUN THIS AFTER 09_deploy.pact — it needs the AQP-SCORE upgrade to be live,
;;  because the column it writes does not exist in the deployed schema until
;;  then. Nothing earlier in the round depends on it.
;;
;;  NOT A MODULE FUNCTION, BY CANON (StoicSyntax-Prefixes.md §7.24, owner ruling
;;  2026-11-10): a one-shot migration added to a module is permanent dead
;;  surface on every chain it lives on, and Pact can never remove a definition
;;  from a deployed module. `coin`'s vault repair rides its upgrade the same
;;  way. RPS got a function instead and that cost a 725,729-gas cleanup
;;  transaction to undo. So this is a top-level block.
;;
;;  IT WORKS BECAUSE `acquire-module-admin` REACHES THE TABLE. The governance
;;  signature this transaction already carries grants module admin for its
;;  remainder, so `keys` and `update` on AQP-SCORE's own table resolve from out
;;  here. Verified in the REPL before it was written.
;;
;; ───────────────────────────────────────────────────────────────────────────
;;  WHY A BACKFILL AT ALL — because strictly, correctness does not need one.
;;
;;  The column is absent on all 15 live score rows, and `UR_SCR|SingleShareWeight`
;;  is `contains`-guarded to TRUE — which is exactly how every score already
;;  behaves. Nothing defaults an absent column (not `with-default-read`, which
;;  defaults an absent ROW, and not `try`, which does not catch it at all; both
;;  measured, and the 16h chain halt of 2026-11-09 is what taught it). So the
;;  guard is what makes the deploy safe, and this transaction is what makes the
;;  state EXPLICIT: every row carries the field, and the one score that must
;;  differ says so on the row rather than by the absence of a value.
;;
;;  THE ONE WRITE THAT IS NOT COSMETIC is DemiourgosSnakes.
;;
;; ───────────────────────────────────────────────────────────────────────────
;;  WHAT IT WRITES
;;
;;    all 15 scores            single-share-weight = true
;;    DemiourgosSnakes-S2KM…   single-share-weight = FALSE
;;
;;  DemiourgosSnakes and DemiourgosShareholder employ scores over the SAME
;;  equity collection and must weigh it differently: Shareholder counts raw
;;  shares (nonce 1 = 1 share), Snakes counts only aggregated packages (nonces
;;  2-8). That is the entire reason the field exists.
;;
;;  A HARD, FORCED REPAIR — it writes the table directly rather than going
;;  through `C_SetSingleShareWeight`. That entrypoint refuses unless the score
;;  is empty and charges IGNIS per call; this is an admin one-shot over every
;;  row. BOTH EQUITY SCORES WERE CONFIRMED VACATED FIRST (nzs-count = 0,
;;  drift-locked false, read from chain 2026-11-11), so the forced path writes
;;  exactly what the gated path would have allowed. Direct writes bypass the
;;  SECURE-gated `WU_` writer, so they inherit none of its invariants — stated
;;  rather than left implied.
;;
;;  IDEMPOTENT: every value is SET, never toggled. Re-sending changes nothing.
;;
;;  Signing: the AQP-SCORE governance keyset.
;; ═══════════════════════════════════════════════════════════════════════════

(namespace "ouronet-ns")

(acquire-module-admin ouronet-ns.AQP-SCORE)

;;ONE PASS, DRIVEN BY THE TABLE'S OWN KEYS. Every score gets `true` except the one
;;that must differ, which gets `false` in the same sweep.
;;
;;THE EARLIER FORM SWEPT, THEN UPDATED SNAKES SEPARATELY, and the round simulator
;;caught why that is worse: a bare `update` on a hardcoded key ABORTS with a raw
;;"No row found during update" if that key is not there -- which is exactly what a
;;TYPO in the score id would produce, and it reads like a chain fault rather than a
;;wrong constant. Driving the write from `keys` makes referencing a non-existent row
;;impossible.
;;
;;THE ENFORCE IS THE OTHER HALF, and it is deliberately LOUD rather than tolerant.
;;Having made the sweep typo-proof, a wrong id would now SILENTLY no-op -- the one
;;write this transaction exists for, quietly skipped, with every other row correct
;;and nothing on screen to show it. So the id must be present or the whole
;;transaction refuses.
(let
    (
        (snakes:string "DemiourgosSnakes-S2KMEHRINZER")
        (ids:[string] (keys ouronet-ns.AQP-SCORE.SCR|T|Score))
    )
    (enforce (> (length ids) 0)
        "No score rows found -- this is the wrong chain, or AQP-SCORE did not deploy")
    (enforce (contains snakes ids)
        "DemiourgosSnakes-S2KMEHRINZER is not among the scores on chain -- wrong id or wrong chain")
    (map
        (lambda (sid:string)
            (update ouronet-ns.AQP-SCORE.SCR|T|Score sid
                {"single-share-weight": (!= sid snakes)}))
        ids)
)

;; ═══════════════════════════════════════════════════════════════════════════
;;  VERIFY AFTERWARDS (read-only, /local, no signature):
;;
;;    (map (lambda (k:string)
;;           [k (ouronet-ns.AQP-SCORE.UR_SCR|SingleShareWeight k)])
;;         (keys ouronet-ns.AQP-SCORE.SCR|T|Score))
;;
;;  -> 15 rows, every one `true` EXCEPT DemiourgosSnakes-S2KMEHRINZER = false.
;;  And the column must now be PRESENT rather than defaulted:
;;
;;    (contains "single-share-weight"
;;      (read ouronet-ns.AQP-SCORE.SCR|T|Score "DemiourgosSnakes-S2KMEHRINZER"))
;;  -> true
;;
;;  THEN, AND ONLY THEN, re-open the Snakes pool and have holders restake. This
;;  transaction does NOT re-value existing positions — there are none, because
;;  the score was vacated, which is the whole reason the gate requires that.
;; ═══════════════════════════════════════════════════════════════════════════

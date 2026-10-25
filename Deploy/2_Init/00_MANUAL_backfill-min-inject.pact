;; ---------------------------------------------------------------------------
;; OURONET INIT -- MANUAL step, hand-authored.
;; Label : backfill min-inject-amount onto every pre-existing reward lane
;;
;; RUN THIS IMMEDIATELY AFTER the deploy transaction carrying 04_RPS.pact,
;; and BEFORE any other transaction touches a reward lane.
;;
;; "Immediately" is not a style preference here, and neither half of that
;; sentence is optional. See THE ORDER IS LOAD-BEARING below.
;;
;; THIS FILE IS NOT GENERATED. _deploybundle.py emits MODULE deploys; it has no
;; way to know that a schema gained a field and that live rows therefore need a
;; pass. It knows this file by name (KEEP) and will not report it as an orphan.
;;
;; ---------------------------------------------------------------------------
;; WHAT IT DOES
;;
;; The 2026-10-23 round added `min-inject-amount:decimal` to FVT|RPS|Global --
;; the per-lane floor on a single injection. A lane created from this round on
;; is born carrying CT_DEFAULT_MIN_INJECT (1.0), because XI_AddRewardLink now
;; supplies it. Every lane written BEFORE this round has no such field, and
;; this transaction is what gives them one.
;;
;; ---------------------------------------------------------------------------
;; WHY A PASS, AND NOT A DEFAULTING READ
;;
;; The obvious alternative -- read the field through `with-default-read` and let
;; absent mean 1.0 -- does not work, and the reason is a Pact detail worth
;; stating because it is easy to assume otherwise: `with-default-read` supplies
;; its default when the ROW is absent. It does NOT supply per-field defaults for
;; a row that exists but predates a field. A pre-round lane row exists; it is
;; simply missing a key. So the first read of `min-inject-amount` against it
;; faults, and no amount of defensive reading avoids that.
;;
;; ---------------------------------------------------------------------------
;; THE ORDER IS LOAD-BEARING -- BOTH SIDES OF IT
;;
;; AFTER the RPS deploy, obviously: the function does not exist before it.
;;
;; BEFORE anything else touches a lane, less obviously: UR_FVT-RG|RpsGlobal does
;; a FULL `read` of the lane row and binds every schema field, `min-inject-amount`
;; included. So the first inject, collect, stake or stream against an un-migrated
;; lane faults on a missing key -- not with a clean refusal, but with a raw table
;; error. There is no window in which the system is merely degraded: it is either
;; migrated or those lanes are unusable.
;;
;; AND BEFORE ANY OWNER SETS A CUSTOM FLOOR. This pass writes the default
;; UNCONDITIONALLY -- it cannot test whether a typed field is absent on a row,
;; because Pact will not let it ask -- so it would quietly reset a lane whose
;; owner had already raised its floor. Re-running after a partial run is safe
;; (idempotent against un-customised lanes); re-running after customisation is
;; destructive. Run it once, here, before the surface is open to owners.
;;
;; ---------------------------------------------------------------------------
;; SCALE
;;
;; AA_ (doubled) because it walks every lane via `keys` -- a heavy scan. At the
;; lane counts this system currently carries, one transaction covers it. If the
;; table ever outgrows a single transaction this needs a paginated twin; the
;; symptom would be this transaction exceeding the block gas limit, which is a
;; loud failure rather than a silent partial, so it cannot half-migrate without
;; telling you.
;;
;; ---------------------------------------------------------------------------
;; SIGNING
;;
;; GOV|RPS_ADMIN -- the Demiurgoi keyset. Same signer as any other RPS admin op.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

(ouronet-ns.RPS.AA_MigrateMinInject)

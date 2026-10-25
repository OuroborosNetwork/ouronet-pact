;; ---------------------------------------------------------------------------
;; OURONET INIT -- MANUAL step, hand-authored.
;; Label : backfill drift-locked onto every pre-existing score
;;
;; RUN THIS IMMEDIATELY AFTER the deploy transaction carrying 02_SCORE.pact,
;; and BEFORE any other transaction touches a score.
;;
;; THIS FILE IS NOT GENERATED. _deploybundle.py emits MODULE deploys; it has no
;; way to know that a schema gained a field and that live rows therefore need a
;; pass. It knows this file by name (KEEP) and will not report it as an orphan.
;;
;; ---------------------------------------------------------------------------
;; WHAT IT DOES
;;
;; The 2026-10-25 (V14) round added `drift-locked:bool` to SCR|Schema -- the
;; permanent "this score cannot drift" latch that a streaming FVT requires of
;; every member. A score issued from this round on is born carrying `false`,
;; because UDC_SCR|Schema now supplies it. Every score written BEFORE this round
;; has no such field, and this transaction is what gives them one.
;;
;; ---------------------------------------------------------------------------
;; WHY A PASS, AND NOT A DEFAULTING READ
;;
;; `with-default-read` supplies its default when the ROW is absent. It does NOT
;; supply per-field defaults for a row that exists but predates a field. A
;; pre-round score row exists; it is simply missing a key. Worse than the new
;; reader faulting: UR_SCR|Score... readers that bind the whole row fault on
;; ORDINARY traffic -- a stake, an unstake, a collect -- not merely on anything
;; asking about the new field. There is no window in which the system is merely
;; degraded: it is either migrated or those scores are unusable.
;;
;; ---------------------------------------------------------------------------
;; FALSE IS THE SAFE DEFAULT, AND THE DIRECTION MATTERS
;;
;; `false` means "not yet proven drift-proof", which costs an owner exactly one
;; deliberate AQP-SCR|C_LockScoreDrift call. Defaulting `true` would assert a
;; property nothing has checked, on scores that may well carry deb-boost or a
;; boost-class link -- and because the latch is ONE-WAY, a wrong `true` is
;; permanent and unfixable.
;;
;; ---------------------------------------------------------------------------
;; THE ORDER IS LOAD-BEARING -- AND RE-RUNNING LATER IS DESTRUCTIVE
;;
;; This pass writes `false` UNCONDITIONALLY. It cannot test whether a typed field
;; is absent on a row, because Pact will not let it ask. So re-running it AFTER
;; an owner has locked a score would silently UNLOCK that score -- which is
;; precisely the one-way contract the latch exists to provide, broken by its own
;; migration. Run it ONCE, here, before the surface is open to owners.
;;
;; ---------------------------------------------------------------------------
;; SCALE
;;
;; AA_ (doubled) because it walks every score via `keys` -- a heavy scan. At
;; current score counts one transaction covers it. If the table ever outgrows a
;; single transaction this needs a paginated twin; the symptom would be this
;; transaction exceeding the block gas limit, which is a loud failure rather
;; than a silent partial, so it cannot half-migrate without telling you.
;;
;; ---------------------------------------------------------------------------
;; SIGNING
;;
;; GOV|AQP-SCORE_ADMIN -- the Demiurgoi keyset. Same signer as any other
;; AQP-SCORE admin op.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

(ouronet-ns.AQP-SCORE.AA_MigrateDriftLocked)

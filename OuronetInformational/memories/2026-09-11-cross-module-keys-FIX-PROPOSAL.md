# WITHDRAWN — the cross-module `keys` "fix proposal" (there was nothing to fix)

**Date opened:** 2026-09-11 · **Withdrawn:** 2026-09-12 · **Nothing was ever applied.**
**Superseded by:** `2026-09-11-stage-z-cross-module-keys.md` (corrected in place)

## Why it is withdrawn

Owner ruling: **"keys can be called freely, there is no admin gating on this."**

I had proposed adding `URH_` counters to four sovereign modules and rewriting 10 call sites in two
citizen files, to escape an admin gate I believed made six UI readers uncallable. **The premise was
wrong.** The gate is real but applies to **transactional** execution only:

- A Pact **REPL executes transactionally**, always. That is where I measured the aborts.
- Chainweb nodes run with **`--allowReadsInLocal`** — verified on this project's own two nodes via
  `ps aux` — which makes `keys` / `select` / `fold-db` unrestricted in `/local` queries.
- `/local` is how a UI reader is invoked. None of these is ever in a transaction.
- The REPL **cannot model the production mode**: `(env-exec-config ['FlagAllowReadInLocal])` is
  rejected — *"Repl flags not recognized"*. It is a node exec flag, not a repl flag.
- Final check before withdrawing: **all six readers have ZERO callers in Pact code.** Nothing
  transactional reaches them, so the constraint never bites.

Cost of the error: several passes of investigation, a conformance rule filed at the wrong severity,
and a fix proposal put in front of the owner that would have added code for no reason.

**Lesson, recorded because it generalises:** an error reproduced in a REPL is an error *in a REPL*.
Before calling REPL behaviour a production defect, establish that production runs in the same
execution mode the test used. Checking "does anything actually call this?" is cheap and would have
caught it on pass one.

## The two facts from this investigation that ARE durable

Both were verified by execution and survive the withdrawal:

1. **A module-only `URH_` is callable from another module without any interface change.**
   `DALOS::URH_AccountCounter` is declared in no interface, yet `(DALOS.URH_AccountCounter)` from
   outside DALOS returns `"Ouronet has 27 real Accounts!"`. So "add a reader in the owning module"
   never implies an interface bump or a cascade — useful the next time a transactional scan is
   genuinely needed. Pinned by `STAGEZ-05`.

2. **A `keys` scan costs a FLAT ~40,000 gas**, independent of row count (measured at 10 / 100 / 400 /
   1000 rows). Against Kadena's 150,000-gas transaction limit that is **three scans per transaction,
   maximum** — and it is why these readers belong on `/local` by design, not by accident. Pinned by
   `STAGEZ-17`; see `2026-09-11-scan-gas-budget.md`.

The superseded proposal body is not preserved: its scope, diffs and sequencing all described work
that should not happen.

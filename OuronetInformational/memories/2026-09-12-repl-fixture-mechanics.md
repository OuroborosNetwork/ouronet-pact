# Three REPL fixture mechanics that each cost a cycle

**Date:** 2026-09-12. All three surfaced while closing the guard worklist from 74 to 59.

## 1. A managed `coin.TRANSFER` cap is a per-TRANSACTION BUDGET, not a per-call permission

`env-sigs` with `(coin.TRANSFER from to AMOUNT)` grants `AMOUNT` **in total for the whole
transaction**, spread across every call that spends it. It is not re-granted per call.

`VST-G9` drives six STOA-priced client calls in one transaction. Signed for one call's worth, the
**second** call died with:

```
STOA TRANSFER exceeded for balance 0.000000000000
```

which reads like the patron is out of funds and is nothing of the kind — the patron is fine, the
signature budget is spent. Fix: multiply the split by the number of priced calls.

```pact
(let ((sp:[decimal] (map (* 6.0)
          (ref-DALOS::URC_SplitSTOAPrices KST.ANHD (ref-DALOS::UR_UsagePrice "dptf")))))
```

**Tell:** the error names a *balance* of exactly `0.0` after an earlier call in the same tx
succeeded. A real funding problem fails on the FIRST call, not the second.

## 2. `try` evaluates its body in READ-ONLY mode — any write inside it fails

Probing a client call with `(try "ERR" (SomeModule.C_Something …))` to "see what happens without
aborting the file" does not work when the call writes. It fails with:

```
Error during database operation: Operation disallowed in read-only or sys-only mode
```

pointing at an `insert` deep inside the call — a database error that has nothing to do with the
guard being probed. This compounds the already-recorded trap that **`try` returns its FALLBACK on
failure and never the error text**.

**The probe idiom that does work** is `expect-failure` with a deliberately unmatchable expected
message. The failure report prints the ACTUAL message in full:

```pact
(expect-failure "PROBE" "zzz-unmatchable" (TS01-C2.VST|C_CreateFrozenLink KST.ANHD "R|MOCKA-…"))
;; FAILURE: PROBE: expected error message 'zzz-unmatchable', got '<the real one>'
```

`expect-failure` is the only construct that reports which error actually came out. Use it to probe,
then paste the real message back as the expectation.

## 3. Prefer the CLIENT path to `env-module-admin` — and know which one the guard deserves

`env-module-admin` + `rollback-tx` is powerful enough to reach almost anything, which makes it easy
to reach for when a legitimate route exists. Three cases, and the rule that separates them:

- **A client produces the state → use the client.** `02_SCORE:744` ("Score control requires
  can-upgrade true") looked like it needed a forced field write. It does not: `C_ControlScore` takes
  the new `can-upgrade` as an argument, so calling it with `false` writes the very flag the guard
  requires and every later call is refused — including the one that would set it back. `AQP-G39`
  pins it with no admin at all, and the test documents a real product property: **can-upgrade is a
  one-way door**, because re-enabling control needs the control operation the flag just disabled.
- **No flow produces the state, but the state is operationally real → `env-module-admin`.** A
  revoked boost class, a paused collection, an inactive multiplet family. The field write reproduces
  a state the system genuinely has; it does not invent one.
- **Only an OWNERSHIP obstacle stands in the way → `env-module-admin`, minimally.** `VST-G8`/`G9`
  reassign one `owner-konto` because special wrappers belong to a smart-contract account whose module
  guard no key can satisfy, and `CAP_Owner` runs before the rule under test. Reassigning ownership
  restores the precondition the rule is written to be evaluated *after*; it does not weaken the rule.

**And the annotate-vs-execute rule, which is the one that generalises furthest:**

> When a guard is unreachable because an **INVARIANT holds**, drive the invariant false and EXECUTE
> it. Annotate `;;UNREACHABLE` only when **no state could ever reach it** — when the call itself does
> not exist.

`01_DALOS:1215` had a three-way proof that guard and governor cannot diverge on a standard account,
and a standing proposal to annotate it away. Executing it was strictly better: an `;;UNREACHABLE`
note is a claim about *today's* call graph and goes stale silently the first time someone adds a
writer, whereas this guard's whole job is to fire in a state the writers are supposed to prevent.
`DALOS-G8` produces that state and watches it fire — and picks up a fact the proof could not: it
fires **with a correctly-signed caller**, so the structural check runs before `enforce-guard`.

Contrast `03_DPDC-C:279`, which is annotated rather than executed: no caller passes the
`(son=TRUE, sft-set-mode=TRUE)` combination, and the SFT-set path does not route through that
function at all. There is no state to drive — the call does not exist.


---

## Waiting on a long run: never `pgrep` for the thing you are also in the command line of

Hit for the **second** time on 2026-09-13. This loop never exits:

    timeout 900 bash -c 'while pgrep -f "_gate.py" >/dev/null; do sleep 20; done'

`pgrep -f` matches **full command lines**, and the waiter's own `bash -c` command line contains the
string `_gate.py`. It matches itself, forever, until `timeout` kills it -- which shows up as a task
that "failed with exit code 144" and, in the terminal, as a pile of stuck agent pills.

Three things that do work, in order of preference:

1. **Don't wait at all.** Launch the long command with `run_in_background: true` and let the harness
   notify you when it exits. That is the whole point of the mechanism; a polling loop on top of it
   is pure waste, and it is what produced both incidents.
2. **Poll the OUTPUT FILE for the terminal string**, not the process table -- grep for
   `GATE GREEN\|GATE FAILED` in the redirect target. Always give the poll its own wall-clock
   ceiling; a loop with no ceiling can never be told apart from real work again if the thing it
   watches dies before printing.
3. If you really must inspect processes, match on something the waiter cannot contain:
   `ps -eo args --no-headers | grep -c '^python3 .*_gate\.py'` anchors on the interpreter and the
   line start, so the shell wrapper does not self-count.

**The same self-counting explains an earlier confusion**: a `ps` that appeared to show phantom
shells running was mostly the `ps` pipeline counting its own `grep`. Before reporting "N things are
running", re-run the count with an anchored pattern.

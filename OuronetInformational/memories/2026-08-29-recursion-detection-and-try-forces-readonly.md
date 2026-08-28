# 2026-08-29 — Recursion detection extends beyond the same function, and `try` forces read-only

**Context:** off-cycle SWP discussion comparing our AMM engine against Kaddex/KDX's real mainnet
source. Kaddex's `exchange.pact` carries an explicit `MUTEX`/`locked` field guarding every
swap/add/remove — defense-in-depth its own authors admit they couldn't build a PoC exploit for
("Pact detects the recursion attempt"). Recommended (and owner agreed) that SWP doesn't need an
equivalent lock, on the strength of that claim plus general understanding of Pact's recursion
guard — but that claim was never independently proven *this session*, only asserted from Kaddex's
own source comment plus the general shape of the existing H9 memory note
(`2026-08-17-reentrancy-is-sandboxed-not-absent.md`, which proved a *different*, narrower
guarantee: guard-evaluation callbacks specifically run read-only). Went back and built real,
isolated REPL proofs before letting that recommendation stand as verified fact in the final audit
report — and found the first proof attempt was itself confounded by an unrelated Pact behavior.

## False start: `try` masks writes as "read-only" regardless of recursion

First attempt wrapped everything in `(try "default" ...)` for safety, matching this session's usual
adversarial-proof pattern. Every test — even a single module writing to its own table, zero
recursion, zero cross-module calls — failed inside `try` with:

```
Error during database operation: Operation disallowed in read-only or sys-only mode
```

Isolated by removing `try` piece by piece: **`try` itself forces its wrapped expression into
read-only/local-exec mode in Pact 5** — it's not just an error-catcher, wrapping a write inside
`try` unconditionally blocks that write, with or without recursion, with or without
`with-capability`. Confirmed directly: the identical write succeeds fine called plainly, and fails
identically inside `try` even with zero other changes. **Standing rule for this codebase's own
adversarial proofs going forward: never wrap a state-mutating call in `try` expecting to observe
its success/failure — use `expect-failure` (which does *not* impose this restriction, confirmed
working correctly in `#74`'s own permanent proof, `SWP|TX 032o3`, which asserts a real duplicate-
token issuance attempt fails for the right reason) or a raw, unwrapped call if you need to see the
actual error trace.

## The real answer, proven clean once `try` was removed

Two distinct Pact 5 runtime guarantees, confirmed with isolated module-to-module REPL repros (not
inferred from Kaddex's comment, not assumed from the H9 precedent — independently reproduced):

1. **Same-function recursion (including indirect, through a callback) is a hard runtime error.**
   `modA.risky` (via a `module{interface}`-typed callback parameter, the only way two Pact modules
   can call each other without a compile-time circular dependency) calling out to `modB.callback`,
   which calls back into `modA.risky` again while the first call is still active on the stack:
   ```
   Recursion detected by the runtime. Recursing in function: modA.risky
   ```
   Exact, unambiguous, no `try` needed to observe it — the transaction just aborts.

2. **Re-entering the same MODULE mid-execution via a *different* function, through an external
   callback, is separately blocked — read-only-sandboxed, not a "recursion" error.** Same setup,
   but the callback calls `modA.other` (a distinct function, not `risky` itself) while `risky` is
   still active inside its own `with-capability` write scope:
   ```
   Error during database operation: Operation disallowed in read-only or sys-only mode
   ```
   This is the more important guarantee for the Kaddex/`MUTEX` comparison specifically — a classic
   reentrancy attack rarely re-invokes the *exact same* function; it calls a *different* function of
   the same contract (e.g. `withdraw()` while `swap()` is still mid-flight) to exploit inconsistent
   intermediate state. Proven here: Pact blocks that shape too, not just literal self-recursion.

Sequential (non-overlapping) calls to the same function, including indirectly through another
module, are completely unaffected — called `modA.inner` twice in one transaction (once directly,
once through `modB.callback`), both succeeded, no restriction, because neither call was still on
the stack when the other started. The guarantee is specifically about *overlapping* activation of
the same module, not "you can only call a function once per transaction."

## Durable rule

Kaddex's `MUTEX` really is redundant insurance in Pact, for a stronger and more specific reason
than "recursion is detected" alone would suggest — the VM independently blocks *both* same-function
recursion *and* cross-function reentry into an already-active module, reached through any real
callback channel (which in Pact means a `module{interface}`-typed dynamic-dispatch parameter,
since concrete modules can't reference each other circularly at compile time). If a future SWP
design ever introduces something callback-shaped (a caller-supplied `module{interface}` parameter
invoked mid-operation, the flash-swap-callback pattern Kaddex's `exchange.swap` uses and SWP
currently has no equivalent of), re-verify this from scratch for that *specific* shape rather than
assuming the general guarantee — same posture the H9 note already established, now with a second,
independently-confirmed data point instead of one.

And separately, permanently: **don't use `try` to observe whether a write-containing call
succeeded or failed in a REPL proof** — it will report "failed" unconditionally regardless of the
real outcome, for a reason that has nothing to do with what's actually being tested. Use
`expect-failure` for expected-failure assertions on state-mutating calls, or an unwrapped call if
you need the raw error trace.

# 2026-08-17 — Pact doesn't lack callbacks; guard-evaluation callbacks are read-only-sandboxed

**Context:** SWP audit, finding H9 (suspected reentrancy window in `XI_Swap`: input debit runs before the
pool-reserve commit, via a smart-account guard that could theoretically execute arbitrary code). Owner
asked for a plain-English explanation and a real REPL proof before accepting or rejecting it, then pushed
back further on the proposed mechanism itself.

## The owner's objection

"The only things that can execute are those the module admin wrote down... the code can never 'turn
around' and 'call someone else,' unless its written down... there is no reentrancy possible in Pact, for
this very reason, and why other smart contract languages are open to vulnerabilities."

The conclusion (no exploit here) turned out to be correct. The reasoning ("callbacks are impossible in
Pact") was not quite right, and I pushed back on that specifically rather than just agreeing with a
convenient-sounding but imprecise model.

## What's actually true

Pact **does** have a real, deliberate callback primitive: `create-user-guard` + `enforce-guard`. A
function can accept a `guard` value as a parameter and check it generically, without knowing in advance
which specific function is wrapped inside it. That's not a loophole — it's the entire mechanism multisig
guards, time-locked guards, and (in this codebase) smart-account `governor` rotation depend on.
`DALOS::C_RotateGovernor` deliberately allows an account owner to install a `u:`-protocol user-guard
wrapping arbitrary code as their governor (`01_DALOS.pact:602`, `UEV_EnforceGuardProtocol governor false`
— note this is the *opposite* restriction from the account's own `guard` field, which is locked to
keyset-only protocols, `:596`). `CAP_EnforceAccountOwnership` → `UEV_SmartAccOwn` (`:924-943`) evaluates
that governor's guard as a fallback inside an `enforce-one`, reached from the true-fungible debit path
(`05_DPTF.pact:777`). So: the callback is real, reachable, and genuinely executes caller-chosen code
synchronously mid-transaction. If Pact stopped there, this would be exploitable exactly like a Solidity
reentrancy bug.

**What actually closes it** is a separate, specific VM-level rule: code invoked to satisfy a guard or
`enforce` condition runs **read-only**, unconditionally. Proved this directly with an isolated repro (not
just cited the docs) — a `victim` module doing `(enforce-one "auth" [(enforce-guard real-guard)
(enforce-guard malicious-guard)])`, where `malicious-guard` wraps a function that attempts a table
`insert`:

```
Error during database operation: Operation disallowed in read-only or sys-only mode
```

thrown exactly at the write, inside the callback, propagating up through the guard call. Then tried
wrapping the malicious write in `try` (hypothesis: could the attacker swallow the failure and let their
own transaction proceed anyway, guard silently "succeeding" despite the blocked write?) — **same error,
same abort.** This specific violation is not `try`-catchable the way an ordinary `enforce` failure is; it
kills the whole transaction outright. No partial, narrow, or degraded exploit survives from this position.

## Durable rule

Don't reason about reentrancy in this codebase as "Pact has no callbacks, so it's a non-issue by
construction." The precise, correct version: **callbacks that arrive via guard/`enforce` evaluation are
safe because they're read-only-sandboxed at the VM level — not because callbacks don't exist.** If a
future code path ever invokes caller-supplied or account-supplied code through some *other* channel (not
through `enforce-guard`/`enforce`/`enforce-one`), the read-only guarantee wouldn't automatically apply, and
that path would need its own check, on its own merits — the same way this one did. Folded the precise
version into `pact5/SEMANTICS.md`'s footguns section (the existing "`enforce`/user-guards run read-only"
bullet, enriched with this evidence) so future audits reach for the right mental model immediately instead
of re-deriving it, and don't over-generalize a real finding into a blanket exemption.

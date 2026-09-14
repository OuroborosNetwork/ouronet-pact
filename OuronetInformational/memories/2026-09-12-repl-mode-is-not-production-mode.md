# A REPL error is a REPL error: execution mode before severity

**Date:** 2026-09-12 · **Status:** standing rule, learned the expensive way
**Cost:** two findings withdrawn, one fix proposal put in front of the owner that should not have been

## The rule

**Before calling REPL behaviour a production defect, establish two things:**

1. **Production runs in the same execution mode the test used.**
2. **Something actually calls the function.**

Both checks are minutes of work. Skipping them cost several passes of investigation twice in two days.

## Case 1 — "six UI readers are uncallable on any chain"

Measured, correctly: `keys` on another module's table aborts with
`Module admin necessary for operation but has not been acquired:ouronet-ns.<MODULE>`. Concluded,
wrongly: six Stage-Z UI readers are dead on mainnet. Filed as a runtime-fatal conformance rule and a
decision-ready fix proposal (new `URH_` counters in four sovereign modules, 10 call-site edits).

Owner ruling: **"keys can be called freely, there is no admin gating on this."**

What I missed:

- Pact admin-gates cross-module scans in **transactional** mode. **A REPL is always transactional.**
- Chainweb nodes run **`--allowReadsInLocal`** — verifiable on the spot with `ps aux` on this
  project's own nodes — which makes reads unrestricted in `/local` queries.
- `/local` is how a UI reader is invoked. None of these is ever in a transaction.
- The REPL **cannot model production here at all**: `(env-exec-config ['FlagAllowReadInLocal])` is
  rejected — *"Repl flags not recognized"*. It is a node exec flag.
- **All six readers have ZERO callers in Pact code.** One `grep` would have ended it on pass one.

The tell I walked past: the REPL had no way to express the production configuration. That is a
signal the test environment is not the production environment, not a detail to work around.

## Case 2 — "liquid staking reports LIVE when it is not live"

Measured, correctly: inside `[4.0]`'s boot sequence, at the moment both STOA ids are set and the
Autostake pair does not exist, `UEV_IzLiquidStakingLive` returns `true`. Concluded, wrongly: the
function reports liveness on a chain where liquid staking is not live — phrased as a property of the
function instead of a property of one transient state.

Owner ruling: **"liquid staking is live on mainnet, i dont know what you mean by saying it without an
ATS pair?"**

The deployed chain has the pair (`StoaLiquindex-98c486052a51`); the guard is true because it is live,
and it correctly refuses all three misconfigurations that have a pair. The window I measured exists
only between the tx that sets the ids and the tx that creates the pair, and **pairs are not deleted**,
so mainnet is past it and cannot re-enter. Real content: a boot-robustness gap, recorded at that size.

## What both have in common

A true observation about a **state or mode the REPL happened to be in**, promoted to a claim about
**the function**. The fix is a sentence added to the finding template:

> In which execution mode and which chain state did I observe this, and is production ever in it?

## What each cost, and what each bought

| | cost | kept |
|---|---|---|
| cross-module `keys` | multi-pass investigation, a mis-scoped rule, a proposal to the owner | the rule survives as an **observation/watch list** — a cross-module scan cannot be called from a transaction, so if one ever gains a `C_`/`A_` caller it becomes a real defect then; plus scans cost a FLAT ~40k gas, so three per tx maximum |
| liquid staking | an overstated defect in the handoff for two days | **three guards pinned** that the same note had called unpinnable — the re-examination found the `env-module-admin` + `rollback-tx` technique (`2026-09-12-state-driven-guard-coverage.md`), which then unlocked two more in DPTF |

Both retractions were net positive *because the technical work was right*. The error was in the
severity sentence, every time. Keep the measurement; slow down on the conclusion.

## Related

- `2026-09-11-stage-z-cross-module-keys.md` (corrected in place)
- `2026-09-11-cross-module-keys-FIX-PROPOSAL.md` (withdrawn)
- `2026-09-11-liquid-staking-liveness-sentinel.md` (re-framed)
- `2026-09-12-state-driven-guard-coverage.md` (what the re-examination produced)

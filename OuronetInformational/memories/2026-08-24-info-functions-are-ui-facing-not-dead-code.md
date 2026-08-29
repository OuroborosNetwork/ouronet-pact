# 2026-08-24 — `INFO_*` functions are UI-facing preview endpoints, not dead/uncalled code

**Context:** DALOS audit, Cluster 6 (INFO-ONE), findings #5C/#11H/#12H. The lens's own framing note
observed that `INFO-ONE+.pact` has zero on-chain callers anywhere in the repo except one discarded
REPL reference, and treated that as suspicious/orphaned. Owner clarified the real architecture.

## What was assumed

That a module with (almost) zero in-repo callers is dead code, or at best speculative
future-proofing — the default read for "nothing calls this" anywhere else in this codebase's audit
history (DPMF, several `LIQUID|INFO_*`/`ORBR|INFO_*` functions, etc., where that read was correct).

## What's actually true

`MODULE|INFO_FunctionName` functions are **UI-facing preview endpoints**, one designed per
user-facing function (`MODULE|C_FunctionName`), called **directly by the frontend** before the user
executes the real transaction — not by any other on-chain module. Each one returns an
`object{OuronetInfoV1.ClientInfo}` built specifically so the UI can show the user, before they sign
anything: what the operation costs (IGNIS + Kadena breakdown) and what it will actually do
(pre-text/post-text description). This is why grepping the repo for `INFO-ONE::` or
`MODULE|INFO_*` callers finds essentially nothing — the real caller is off-chain (the UI), invisible
to any on-chain grep, by design. Zero on-chain callers is the *expected*, healthy state for this
module family, not evidence of dead code.

This does **not** mean bugs inside these functions are harmless, though — a wrong cost estimate or
wrong description is exactly the kind of defect a user-facing preview exists to prevent, and ships
straight to the person about to sign a real transaction. Confirmed findings inside INFO-ONE (a
doubled-prefix typo crashing a function outright, a copy-paste wrong-token cumulator, a
duplicate-variable-name bug silently dropping a cost component from a total) are real bugs on real
UI-facing output, just currently invisible to on-chain test coverage because nothing on-chain ever
calls them to fail loudly.

## The durable rule

When auditing an `INFO_*`/`MODULE|INFO_*` function and it has zero on-chain callers: that's the
expected state, not a red flag by itself — the caller is the UI. Don't default to "probably dead
code" for this specific naming family the way you would for an ordinary internal helper. Do still
scrutinize the function's actual output correctness (right token, right amount, right message) as
carefully as any other user-facing surface, since a wrong number here is a wrong number shown to a
real signer, and the near-total absence of on-chain test coverage for this family (also confirmed
during this audit) means bugs here currently have no safety net at all beyond a full-repo code read.

## Separate, larger fact captured here for planning purposes (not part of this audit's scope)

Every real `C_*`/user-facing function is *supposed* to have a matching `INFO_*` counterpart, written
by hand as UI buttons were added — owner confirmed a large number are still missing across **both**
Stage 1 and Stage 2. This is explicitly **out of scope for the current DALOS/StoicSyntax audit
cycle** — owner's stated sequencing: finish all in-flight audits (DALOS + SWP) → merge to main →
**then** a dedicated INFO-function coverage project (enumerate every `C_*` across Stage 1 and Stage
2, confirm which already have a matching `INFO_*`, audit those for correctness against their real
counterpart's actual cost/behavior, and write the missing ones) → **then** the StoicSyntax sweep.
Tracked in `1_SOVEREIGN/STAGE_01/2_Core/Audit/DALOS/README.md`'s "Downstream plan" section so it
isn't lost between now and when that phase actually starts.

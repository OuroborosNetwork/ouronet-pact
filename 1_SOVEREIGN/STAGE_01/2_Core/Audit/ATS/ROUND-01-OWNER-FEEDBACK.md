# ROUND I — Owner feedback (ATS modules)

**Date:** 2026-08-16 · **Status:** living (append as verdicts arrive). Frozen per-entry once recorded;
new verdicts append, don't rewrite prior entries.

## C1 — `ATS|GOV` "forgeable governor guard, full vault drain" — **REFUTED**

**Owner's correction:** `with-capability` on `ATS|GOV` cannot be done without ATS module admin, unless
composed *from within the ATS module itself* — which is exactly how the capability-guard saved on the
`ats-sc` smart account is meant to work. Not a bug.

**Verification before retracting (not taken on faith):** built an isolated two-module Pact 5.4 repro
(`/tmp/pact_verify/verify.repl`, `verify2.repl`) modeling the exact shape (`(defcap FREE () true)` in
module `M`, a `create-capability-guard` built from it, a foreign module `B` and bare top-level code both
attempting to acquire it without holding `M`'s admin). Confirmed:
- Code inside `M` freely composes `M`'s own trivially-true capability — the intended pattern.
- A foreign module or bare transaction code, holding zero relation to `M`, **cannot** acquire it:
  `"Module admin necessary for operation but has not been acquired: M"`.

This matches `StoicSyntax.md §14.5`'s documented "Simple vault" pattern (`MODULE|GOV` on send/receive,
"home only") exactly — `ATS|GOV` is that pattern, correctly applied. The C1 exploit scenario (an outside
transaction forging `(with-capability (ATS.ATS|GOV) ...)` to drain `ats-sc` via `TFT::C_Transfer`) does
not work; it fails before reaching the transfer.

**Verdict: REFUTED.** Retracted from the ranked findings list and the severity count. Full correction
detail + underlying Pact semantics: `memories/2026-08-16-with-capability-requires-module-admin-for-foreign-
callers.md`; durable rule folded into `StoicSyntax.md §14.5`.

**What survives from C1's investigation, unaffected by the correction:**
- **C5** (`C_HOT-RBT|UpdatePendingBranding`/`UpgradeBranding` compose `ATS|GOV` with no preceding
  `CAP_Owner` check) is **not** refuted by this — it's a different, narrower, still-real bug: anyone can
  trigger those *specific public functions* (no cross-module forgery needed — they're ATS's own code, so
  they compose `ATS|GOV` successfully by design), and nothing gates *who* may call them first. C5 stands.
- The cross-cutting note about `VST|GOV`/`LIQUID|GOV`/`ORBR|GOV`/`SWP|GOV` is **downgraded, not deleted**:
  those are *not* independently forgeable either, by the same corrected reasoning — but each is still
  worth a per-module pass checking whether any of *their own* public functions compose their `GOV` cap
  without a preceding ownership/authorization check (the actual pattern C5 demonstrates). Not an emergency
  cross-vault-drain; a narrower "check each module's own call sites" follow-up.

## Numbering after this correction

Findings renumber sequentially with C1 removed; former C2-C5 become C1-C4, H1-H4 stay H1-H4 (unaffected),
etc. See `ISSUES-RANKED.md` for the corrected list. `README.md`'s status tracker keeps the original finding
IDs (C1-C5, H1-H4, ...) for traceability against `ROUND-01-FINDINGS.md`'s frozen text, with C1 marked
REFUTED rather than renumbered out of that table.

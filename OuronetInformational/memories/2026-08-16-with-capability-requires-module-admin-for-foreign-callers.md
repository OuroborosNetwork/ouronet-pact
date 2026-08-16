# 2026-08-16 — `with-capability` on a foreign module's capability requires that module's admin

**Context:** ATS audit, finding C1 (`ATS|GOV` flagged as a forgeable, unconditionally-`true` capability
wired as `ats-sc`'s smart-account governor guard, claimed to allow any caller to drain the whole Autostake
vault). Owner corrected this as a non-issue; verified precisely before retracting.

## What was wrong

I (and a subagent lens whose "empirical reproduction" was flawed) assumed Pact's capability model lets
**any** caller — a different module, or bare transaction/top-level code — freely `with-capability` an
arbitrary `defcap` defined in another module, as long as that defcap's own body has no `enforce`. Under
that (wrong) assumption, `(defcap ATS|GOV () true)` looked like a skeleton key: anyone could
`(with-capability (ns.ATS.ATS|GOV) ...)` and walk straight through any guard checking for it.

## What's actually right

Pact requires the **calling module's admin** to already be held before a `with-capability` call can
acquire a capability defined in a **different, foreign module** — unless that capability is already in the
granted set for the current call stack. Concretely, verified in an isolated two-module Pact 5.4 REPL
(`/tmp/pact_verify/verify.repl`, `verify2.repl`):

- Code **inside** module `M` (a `defun` defined in `M`) can `with-capability (FREE)` on `M`'s own
  `(defcap FREE () true)` freely, for any caller/signer — the intended, safe pattern.
- A **separate** module `B` (deployed independently, no relation to `M`) calling
  `(with-capability (M.FREE) ...)` from **inside its own code** fails:
  `"Module admin necessary for operation but has not been acquired: M"`.
- Bare top-level/transaction code attempting the same, or a fresh `enforce-guard` on
  `(create-capability-guard (M.FREE))` from outside with nothing pre-granted, also fails.

This is why the `MODULE|GOV` **"Simple vault"** pattern in `StoicSyntax.md §14.5` is safe as documented
(`"MODULE|GOV = 'I own this account' (home only)"`): only `M`'s own code can ever get `M|GOV` into the
granted set in the first place. A `create-capability-guard (M.M|GOV)` sitting on `M`'s own smart account is
therefore *not* forgeable by foreign code, even though the defcap body itself performs no `enforce`.

## The corollary that IS real

The safety of `MODULE|GOV` composed-as-`true` depends entirely on **every call site inside the home
module** that composes it being preceded by real authorization for whatever operation is being performed —
because *any* public function of the home module can compose it freely, and Pact only blocks *foreign*
callers, not unauthorized *internal* call paths reachable via the module's own public surface. This is
exactly what ATS audit finding C5 is (`C_HOT-RBT|UpdatePendingBranding`/`UpgradeBranding` compose
`ATS|GOV` with no preceding `CAP_Owner` check) — a real bug, just narrower than C1 claimed: it's "anyone
can trigger this specific public function with no ownership check," not "anyone can forge the smart
account's guard directly."

## Durable rule

When auditing a `MODULE|GOV`-style "Simple vault" capability (StoicSyntax §14.5): do **not** flag the
capability itself as forgeable just because its body is `true`/has no `enforce`. Instead, enumerate every
**public function inside the home module** that composes it, and check each one has real authorization
(ownership/policy check) *before* composing — that's where the actual risk lives. Cross-module capability
"forgery" of a foreign module's capability is not possible in Pact without that foreign module's admin
already held, or the capability already being in-scope from earlier in the same call stack.

Folded into `StoicSyntax.md §14.5` (added a one-line note on the underlying guarantee) so future audits
don't re-derive this the hard way.

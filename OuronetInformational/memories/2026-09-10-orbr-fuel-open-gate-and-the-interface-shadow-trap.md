# 2026-09-10 — An open admin gate on `ORBR|A_Fuel`, and the tooling trap that hid it

## The defect

`TS01-A::ORBR|A_Fuel` was written:

```pact
(with-capability (SECURE)
    (XI_DirectFuelSTOA)
)
```

`SECURE` in `01_TS01-A.pact` is `(defcap SECURE () true)` — a C1 trivial capability that grants
itself. So the function's own `@doc` — *"As Stand-Alone Function, can only be used by the Admin"* —
was documented and **not enforced**. Any signer could call it. Verified by calling it with only
`PK_Emma` signing: it succeeded and billed her 87 IGNIS.

Every other `|A_` entrypoint in that module composes `P|ADMINISTRATIVE-SUMMONER`
(`P|TS` + `GOV|TS01-A_ADMIN`). This was a single-identifier outlier.

**Impact.** Not theft — the collected STOA reaches the Liquid Index either way. What an attacker
gained was *timing*: the ability to force the fuelling, and therefore an index move, at a moment of
their choosing rather than when the fee-collecting paths do it. That matters to anyone holding a
position on either side of the move.

## The fix, and the first wrong version

The obvious fix — swap `SECURE` for the admin cap — **is wrong** and the suite caught it:
`XI_DirectFuelSTOA` does `(require-capability (SECURE))` internally, so removing the grant breaks
the call. The admin cap must *gate*; `SECURE` must still be *granted*:

```pact
(with-capability (P|ADMINISTRATIVE-SUMMONER)
    (with-capability (SECURE)
        (XI_DirectFuelSTOA)))
```

Same shape as `XB_DynamicFuelSTOA`, the automatic path, which gates on `P|UEV_IMC` and grants
`SECURE` inside it. The one live caller (`[6.3]_SWP.repl:2443`) already signs with a Demiurgoi key,
so no legitimate access was lost.

## The rule, and why it had to be narrow

`_conformance.py [admin-gate-terminal]`. The naive rule — *"an `A_` gated by a trivial cap"* — is
wrong: that shape is **correct** for a Talos wrapper, where `P|TS` merely marks "arrived via Talos"
and the real gate lives in the core module it delegates to (`DALOS|A_ToggleGAP` →
`DALOS::A_ToggleGAP` → `GOV|DALOS_ADMIN`, pinned by `<<CONF-04>>`). Nineteen entrypoints match that
shape and all nineteen are fine.

The defect is **trivial cap AND no delegation** — the body calls a module-local function and never
crosses a modref, so there is no downstream module left to hold the gate. Either condition alone is
not a defect.

The rule was verified by reverting the fix and watching it fire, then restoring. A lint rule that
reports zero because it is broken is worse than no rule.

## The tooling trap — this has now cost three tools

**Every name in this codebase resolves twice**: once as an interface declaration with an *empty
body*, once as the real implementation. Any tool that finds a member by name and takes the **first**
match reads the declaration, sees no body, and concludes "touches no table" / "has no gate" for
every function in the file.

Bitten so far:
- `_xprotect.py` — `MEM` keyed by name only; `XI_Issue` in DPTF read SCORE's body.
- the guard-seam classifier — reported 159 pure-argument guards; the true number was 69.
- the admin-gate sweep — reported 224 ungated `A_` functions; the true number was 1.

Each time the symptom was the same: **an implausibly large finding count**. Treat that as the
signature. The fix is always to collect every match and keep the longest body.

## Coverage side-note

`_enforce_coverage.py` gained a `;;UNREACHABLE` marker category — guards proven unreachable by hand
(a stricter guard upstream, or an atomic write making a mismatch unconstructible). It is
**deliberately never folded into PINNED**: trusting a comment is abusable, so it gets its own
reported line, lists every site it claims, is capped at 12 lines from marker to enforce, and is
subtracted from the *worklist* only. Coverage percentages are untouched.

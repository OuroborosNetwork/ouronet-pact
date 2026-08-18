# 2026-08-17 — Pact 5's `^` on `decimal` silently loses precision via IEEE-754 double

**Context:** SWP audit, finding C3 (all six swap-amount formulas round toward the trader — a repeatable,
fee-free round-trip profit). First fix attempt (reorder `floor`/`ceiling` to wrap the final answer instead
of an intermediate term) was verified, empirically, to be a **complete no-op** — same numbers before and
after. Digging into why led to a much deeper and more consequential discovery than the original finding.

## What was assumed

That Pact's `decimal` type — documented in this repo's own `pact5/SEMANTICS.md` as "exact" — behaves
exactly for *all* arithmetic, including exponentiation (`^`). Under that assumption, C3's bias had to come
from either (a) where the `floor`/`ceiling` was placed, or (b) the internal Newton iteration's own repeated
`floor(...,24)` truncations compounding over 11 steps.

## What's actually true

`+ - * /` on Pact decimals genuinely are exact/arbitrary-precision (verified: `1.0 / 3.0` carries 255+
digits). **`^` is not** — it silently computes decimal exponentiation via IEEE-754 double precision
internally, regardless of whether the exponent is typed `:integer` or `:decimal`. Proven directly:

```pact
(let ((d 2549.996147035166093620040554))
  [(^ d 4.0)                       ;; = 42282250700760.0859375
   (^ d 4)                         ;; = 42282250700760.0859375  (same float64 path, integer exponent)
   (* d (* d (* d d)))])           ;; = 42282250700760.099021482473331191153317335329175719323256875718459007868358138754818195565982177117931551671056 (the TRUE value)
```

A ~0.013 absolute error on a single `^` call — many orders of magnitude larger than the `floor(...,24)`
truncations that were the original suspect. Confirmed as the actual root cause by diffing a Python
high-precision replica against a directly-instrumented Pact `UC_ComputeD`: they diverged starting ~17
significant digits in, which is exactly float64's precision ceiling, not a 24-decimal-floor artifact.

Small-magnitude sanity checks (`2.0^3`, `85.0^4`, `3.0^3`) misleadingly matched exact values in early
probing — because those results have few enough significant digits to fit inside float64's ~15-17 digit
precision without visible loss. The bug only became visible once the base/result needed *more* precision
than that (D-invariant values in the low thousands, raised to the 4th power, needing ~14+ integer digits
*before* any fractional precision is even considered).

## The corollary that matters for fixes

**Whole-number exponents can be made exact** by replacing `^` with repeated multiplication — this is a
real, clean, zero-risk fix. Added `UC_IntPow (base:decimal power:integer) = (fold (*) 1.0 (make-list power
base))` to `12_U_SWP.pact` and used it everywhere the exponent is a token-count-derived whole number
(`n^n`, `D^(n+1)` in `UC_ComputeD`/`UC_DNext`/`UC_YNext`; `Y^2` → `(* Y Y)` directly). Verified: stable-pool
round trips are now exact to 24 decimal places, zero bias, both directions.

**Genuinely fractional exponents have no such workaround.** The weighted-pool formula needs `x^weight`
where `weight` is a real fraction (e.g. `0.3`) — there's no exact-multiplication trick for that in pure
Pact. Fixing it fully would mean writing a from-scratch high-precision fractional power routine (Newton's
method / power series) — real numerical work, real gas cost, real risk, for a residual that (after
scoping) poses no meaningful solvency risk (bounded to float64's ~1e-16 *relative* epsilon times the
magnitude of the numbers involved — a fraction of a token, not a fraction of the pool, for any realistic
pool size/token precision). Owner's explicit call: accept and document this as a known language-level
limitation rather than attempt the rewrite. Documented in-source (block comment above `UC_ComputeWP` in
`12_U_SWP.pact`) and in `Audit/SWP/ROUND-02-FIXES.md` Fix #3.

## Two smaller, related corrections made to `pact5/SEMANTICS.md`

- `floor`/`ceiling` (2-arg form) are directional truncation (toward −∞/+∞), **not** banker's rounding as
  the doc previously stated — verified: `(floor 2.999 0)` → `2.0`, `(ceiling 2.001 0)` → `3.0`. Only plain
  `round` (no explicit direction) does round-half-to-even. The doc conflated the two; fixed.
- A parameter/binding literally named `exp` fails to load — shadows the native exponential function
  (`"Variable exp shadows native with the same name"`). Caught mid-fix while naming `UC_IntPow`'s exponent
  parameter; renamed to `power`.

## Durable rule

Any AMM/iterative math in this codebase that uses `^` on decimals with results/operands needing more than
~15 significant digits should be treated as carrying a real, silent precision risk — not a cosmetic
floor/ceiling nuance. Before trusting a `^`-based formula's precision, check whether the exponent is a
whole number (fixable via `UC_IntPow`-style repeated multiplication) or genuinely fractional (not fixable
in pure Pact without a much larger, deliberate numerical-methods effort — a decision for the owner, not a
default "just fix it" assumption). Folded into `pact5/SEMANTICS.md`'s footguns section so future audits
don't re-derive this the hard way.

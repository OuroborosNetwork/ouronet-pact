# Pact's `or` is binary — a three-argument `or` in 05_FVT bricks non-mosaic triplet admission

**Date:** 2026-09-12
**Status:** **FIXED 2026-09-12, owner-ruled.** Pinned by `REPL/Kursan/dsa-grand-tour.repl` GT-16
section 03, which now drives all four membership modes against a non-mosaic vault.
**Site:** `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_FVT.pact:1954`, in
`UEV_AddScoreEntityTripletContext`.

## The code

```pact
(enforce
    (or (ref-RPS::UR_FVT|Mosaic fvt-id)
        (let ((mode:string (ref-RPS::UR_FVT|MembershipMode fvt-id)))
            (or (= mode CT_MEMBERSHIP_MODE_BAR)
                (and (= mode CT_MEMBERSHIP_MODE_TRUE_TRIPLET) is-true-triplet)
                (and (= mode CT_MEMBERSHIP_MODE_STANDARD_TRIPLET) (not is-true-triplet)))
        ))
    "Non-mosaic FVT membership mode mismatch for triplet admission")
```

The inner `or` has **three** arguments. **Pact's `or` is BINARY.** Evaluating it raises

```
Attempted to apply a closure to too many arguments
```

The written `enforce` message is unreachable — it has never once been produced.

## Why nobody noticed: the outer `or` short-circuits

The broken form is the second argument of `(or (UR_FVT|Mosaic fvt-id) <this>)`. `or`
short-circuits, so **while the vault is mosaic the broken branch is never evaluated.** Every FVT
this suite builds — and, judging by the constant's use, every FVT built so far — is mosaic. The
defect sat behind a `true`.

## Why this is a BREAK, not a bad message

This is the part that matters and the part a message-class reading would miss. It is not "the
refusing case gets an unhelpful error." **The admitting cases fail too.**

`CT_MEMBERSHIP_MODE_BAR` is the mode the code plainly intends to admit unconditionally — it is the
first disjunct. Drive a non-mosaic vault in BAR mode and it raises the same arity error. So:

> **A non-mosaic FVT cannot admit a triplet at all.** Not in BAR, not in TRUE_TRIPLET, not in
> STANDARD_TRIPLET. Every path through that branch dies on arity.

GT-16.03 asserts all three legs so the claim cannot rot:
1. non-mosaic + mismatching mode (SCORE) → arity error, **not** the written message;
2. non-mosaic + **BAR**, the legitimate case → the *same* arity error;
3. flip `mosaic` back to `true` → admits, because the broken branch is skipped again.

Leg 3 is what proves the mechanism rather than just recording a symptom.

## The contrast that isolates the cause

The SCORE twin, `UEV_AddScoreEntityScoreContext` at `05_FVT.pact:1873`, expresses the same idea
with a legal **two**-argument `or` and works correctly on a non-mosaic vault (pinned by GT-14).
Same concept, same module, same neighbourhood — so the fault is the arity, not the design.

## Scope: exactly one instance codebase-wide

A scan for `(or` / `(and` with more than two top-level arguments found **1** real hit — this one.
Unique defect, no pattern, **no detector warranted**.

**Scan trap, hit again:** the first pass returned **24** hits and every extra one was prose inside
a `;;` comment. Always strip comments before counting. (This is the same lesson as the bare-template
scan and the `(format "…")` scan: run the counter over stripped source, never raw.)

## The fix — APPLIED

Owner ruling, verbatim: *"triple or or multiple or is not allowed. instead use fold construction
using or over false."*

```pact
(fold (or) false
    [(= mode CT_MEMBERSHIP_MODE_BAR)
     (and (= mode CT_MEMBERSHIP_MODE_TRUE_TRIPLET) is-true-triplet)
     (and (= mode CT_MEMBERSHIP_MODE_STANDARD_TRIPLET) (not is-true-triplet))])
```

This is the `or` analogue of the 3+ boolean rule CLAUDE.md already states for `and`, and **two
`(fold (or) false ...)` sites already existed in this same module** (`05_FVT.pact:1549` and `:1754`)
— so the ruling matched established practice rather than introducing an idiom.

`fold` is not short-circuiting, which is a real hazard elsewhere in this codebase (see the mute-guard
class). It is safe **here** and the reason should be stated rather than assumed: all three disjuncts
are comparisons over locals already bound in the enclosing `let`. Nothing is read, nothing can abort,
so evaluating all three costs nothing and risks nothing.

## The test that now guards it — and a trap it caught

GT-16.03 drives **all four** membership modes plus the mosaic short-circuit. Four cells, not two, and
the reason is concrete: a first draft used `"TRUE_TRIPLET"` / `"STANDARD_TRIPLET"` with UNDERSCORES
while the constants are **hyphenated** (`"TRUE-TRIPLET"`, `"STANDARD-TRIPLET"`). The TRUE-TRIPLET cell
**passed anyway** — an unknown mode string matches no disjunct, so it refuses for the wrong reason.
Only the STANDARD-TRIPLET cell failing exposed it.

A two-cell test (one refusal, one acceptance) would have shipped green while proving nothing about
two of the three disjuncts — which is *exactly* the class of fault the original bug was.

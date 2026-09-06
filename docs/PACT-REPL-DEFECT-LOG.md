# Handoff — Pact REPL defect log (for the OuroNet Pact agent)

**Standing instruction, not a one-off task.** Applies from now on, every day.

---

## Why you

You run the Pact REPL dozens of times a day writing real contract code. That
makes you the single best source of a bug class nobody else is positioned to
find: **defects that only appear when you actually use the tool.**

A code auditor reading `Pact/Core/Repl/` sees the code. You see what happens
when a real 6,000-line module hits it at 2am with a typo in it. Those are
different bugs, and the second kind almost never gets reported, because the
person hitting it is mid-task, works around it in ten seconds, and moves on.

**Stop working around them silently. Log them.**

The known example, and the archetype of what we want:

> An incorrect `let` syntax crashes the whole REPL run and does not tell you
> what is actually wrong. You find it by testing, not by reading anything.

That is a real defect. Bad input should produce a located, readable error, not
a crash with no signal. Nobody has written it down anywhere.

---

## What to log

**Log it if any of these are true:**

- The REPL crashed rather than reporting an error
- An error message did not say *where* the problem was (no line, no column, no
  context) when it plausibly could have
- An error message was actively misleading — pointed at the wrong construct,
  or named the wrong cause
- Behaviour differed between the REPL and on-chain execution for the same code
- Something worked that should not have, or failed that should not have
- Gas reported in the REPL disagreed with gas reported by the node
- The same input produced different results on different runs
- A stack trace leaked instead of a diagnostic
- You knew what was wrong only because you had seen it before

**Do not log:**

- Your own bugs, where the error message correctly told you what was wrong
- Anything you cannot reproduce at least once on purpose
- Feature requests. Different list, different document

The test: **would a competent Pact developer, seeing this message, know what
to fix?** If no, it is a defect regardless of whether your code was wrong.

---

## Where and how

Append to `docs/pact-repl-defects.md` in the OuroNet repo. Create it if it
does not exist. One entry per defect, newest at the bottom.

```markdown
## R-007 · let binding with missing parens crashes the run

- **Date:** 2026-09-03
- **Pact version:** 5.4.1 (commit 72f42760)
- **What I did:** wrote `(let (x 1) ...)` instead of `(let ((x 1)) ...)`
- **What happened:** whole REPL run aborted, no line number, message was
  `<paste the exact text>`
- **What should have happened:** an error naming the malformed binding form,
  with the line
- **Reproducible:** yes, every time
- **Minimal case:**
  ```pact
  (let (x 1) x)
  ```
- **Workaround:** none needed once you know, but you have to already know
- **Severity guess:** usability — costs minutes per occurrence, worse for
  newcomers
```

Rules for the entry:

- **Paste the exact error text.** Not a paraphrase. The wording is the evidence
- **Minimal reproduction.** Cut it down until removing one more line makes it
  stop happening. Ten lines beats your whole module
- **Record the version.** A defect against an unknown build is not actionable
- **Say if you cannot reproduce it.** Log it anyway, flagged as intermittent —
  intermittent bugs are often the interesting ones
- Sequential IDs, `R-001` onward. Never reuse one

---

## What happens to the log

It gets reviewed periodically and folded into the upstream audit work (see
`stoa-chain/docs/stoa/upstream-audit-plan.md`). Anything real goes to the Pact
maintainers.

Two things to understand about that:

**These are mostly not security findings**, and should not be dressed as such.
Bad error messages are a usability and adoption problem, and that is a
perfectly good thing to report on its own terms. Do not inflate severity to
get attention.

**But some will be.** A parser that crashes on malformed input is a robustness
question. A REPL that disagrees with on-chain execution is much more than a
usability issue — it means someone can test something locally, see it pass,
and get different behaviour with real money. **If you ever hit that one, flag
it immediately rather than logging and moving on.**

---

## The honest reason this matters

We just shipped an audit where the most valuable finding came from someone
asking a question everyone assumed was settled. This is the same shape.

Nobody audits error messages. Nobody writes tests asserting that a diagnostic
is helpful. It is invisible work that only surfaces through use, and you are
the one using it. A log costs you thirty seconds per entry and is the only way
any of it ever gets fixed.

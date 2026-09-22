This is a single consolidated record of every audit performed on Ouronet: four rounds of work,
carried out over several months, against a virtual blockchain of ninety-three Pact modules.

It is written to be read by three different people, and it is worth saying at the outset which one
you are.

**If you are evaluating the system.** Read {{ch:system}} for what Ouronet is and {{ch:plant}} for
how it was verified, then Appendix B
({{ch:state}}) for the verification state — what is proven, what is bounded, and what is explicitly
not claimed. Then read {{ch:defects}}, which is the defect record. Those three chapters are the answer
to "should I trust this", including the parts of the answer that are "not entirely".

**If you are auditing it yourself, or auditing this audit.** {{ch:method}} is the methodological core:
it is about the five ways a security test can look like a proof and be worthless, all five of which
this programme committed before it learned to detect them. {{ch:repro}} tells you how to re-run
everything here from a clean checkout. {{ch:register}} is the full attack register, generated from the
attacks themselves.

**If you are going to work on this codebase.** Read {{ch:system}}, then Part I, which is the per-module
audit and doubles as the most honest description of how each subsystem actually behaves. {{ch:instruments}}
is about the instruments — and about the fifteen defects found *in the instruments*, which is the
chapter most likely to change how you think about your own tooling.

Whichever you are, read {{ch:sweepdefects}} if you have read an earlier edition of this book. The
canon sweep changed **694 entrypoint signatures across 58 files**, so every adversarial call site
in the attack register has moved, and an attack that still passes without being re-pointed is
passing on an arity error rather than on the guard it names.

## What this book claims, and in what voice

Three commitments shape every chapter, and they are worth stating because they are unusual.

**Findings are reported with their measurements, not their suspicions.** Where a defect was found,
the exploit was executed and its effect recorded *before* the fix was written. This is why figures
in this book are specific — 2,919.77 IGNIS committed before a gate refused, a 10.5× discrepancy
between two doors to the same operation, a 38.65% mispricing. Three findings in this programme
would have been published with fabricated magnitudes without that rule, and one would have been
published as a defect that did not exist.

**The programme's own errors are in the book.** Not in an appendix of lessons learned — in the
chapters, at the point where they happened. A measurement that was wrong four times says so and
explains each wrong version. A figure published without being measured says so. An instrument that
reported a tidier number than the truth says which direction it was tidier in. This is not
self-flagellation; it is the only way a reader can calibrate how much to trust the figures that
were *not* found to be wrong. An audit document with no errors in it is either extraordinary or
incomplete, and the reader has no way to tell which.

**Negative results are labelled as negative results.** An attack that was refused is reported as
refused — which is weaker evidence than a fix, not stronger. A gate that has never been observed to
turn anybody away is reported as never observed, not as "presumed working". A bound is presented as
a bound. Where the honest answer is "nothing is known about this from the outside", the book says
that.

## How to read a figure in this book

Every quantitative claim here is re-derivable, and most are generated rather than typed. The
headline tables are checked by `REPL/tools/_booktables.py`, which fails the build if a table stops
summing to its own total. The attack register in {{ch:register}} is emitted directly from the attack
files. This document itself is assembled by `REPL/tools/_auditbook.py` and a `--check` run fails the
build if the assembled file drifts from its chapter sources.

That machinery exists because of a specific, repeated failure: **three times in this programme, a
published figure went stale while every document agreed with every other document.** Cross-checking
documents against each other detects nothing, because they were all copied from the same original.
Only re-derivation from the tree detects it.

So: where a number in this book looks important, {{ch:repro}} tells you how to reproduce it. If it
does not reproduce, the book is wrong and the tree is right.

## Structure

- **{{ch:system}}–{{ch:plant}}** — orientation: what the system is, and the test plant that
  verified it. Every later chapter cites these.
- **Part I** (Chapters {{n:part1}}–{{n:aqp}}) — the per-module audits. Six subsystems, read line by line.
- **Part II** (Chapters {{n:part2}}–{{n:suite}}) — the main-work round: the cost-preview surface, the IGNIS
  re-pricing, the module-size question, and the architecture of the test suite itself.
- **Part III** (Chapters {{n:part3}}–{{n:register}}) — the red team. How the round was designed, the method, the
  ownership-gate programme, the defects, and the complete register.
- **Part IV** ({{ch:instruments}}) — the instruments, and what was wrong with them.
- **Part V** (Chapters {{n:part5}}–{{n:sweepmethod}}) — the patron/executor/executee canon
  sweep: the round that re-signed the client surface of every module so the system can say WHO
  performed an operation, and the three live defects that asking the question exposed.
- **Appendices** (Chapters {{n:repro}}–{{n:state}}) — reproduction, and the verification state.

A reader going front to back will find Part I heavy. Part I is a reference; Parts II and III are
arguments. Reading Part III first and returning to Part I for the subsystem detail is a reasonable
route, and the cross-references are written to support it.

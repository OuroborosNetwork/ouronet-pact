# The Ouronet Audit Book

> **Status: IN ASSEMBLY** (started 2026-09-17). Roadmap §1.6.2.1.
> One consolidated, publishable account of every audit performed on Ouronet, end to end.

## What this book is

Ouronet is a virtual blockchain implemented entirely in Pact, deployed on StoaChain under the
`ouronet-ns` namespace. This book is the record of how it was audited: what was looked for, what was
found, what was done about it, and — the part most audit reports omit — **what proves the fix is
still there**.

It is written to be read by someone who did not do the work and has no reason to take its word for
anything.

## The three parts

| Part | Covers | Source material |
|---|---|---|
| **I** | The initial per-module audits — ATS, DALOS, SWP, DPDC, DEMIPAD, AQP | the `…/Audit/*` trees (31,225 lines) |
| **II** | The main-work round, Phases 1.1–1.5 — every `URCi_`/`INFO_` reader, re-pricing, module split and REPL change, documented audit-style | `POST-AUDIT-MAIN-ROADMAP.md`, the commit history, `IGNIS-PRICING/` |
| **III** | The red-team round — vulnerabilities sought, found, fixed | `RED-TEAM-REPORT.md`, `DEFECT-LEDGER.md`, `REPL/RedTeam/*` |

## Three rules this book holds itself to

These are not stylistic. Each exists because violating it produced a wrong result during the work
being documented, and each is recorded in `ARCHITECTURE/DEFECT-LEDGER.md` with the incident attached.

**1. Every claim carries its evidence class.** A finding is marked as established by *execution*, by
*reading*, or by *inference*, and the three are never blurred. Reading the call chain to decide what
refuses first was wrong **four separate times** in this programme — eager `let` bindings fire before
the `with-capability` that follows them, so the first raiser is routinely somewhere other than where
the code reads like it is. Where this book says "measured", something was run.

**2. Every fix names the assertion that would go red if it were reverted.** A fix with no witness is
a claim, not a repair. Several findings in Part I were recorded as *"adversarially proven"* at the
time with nothing retained; Part III includes cases where the proof of a fix was **deleted by a later
automated sweep** and nobody noticed, because deletion turned nothing red.

**3. A count is reported with its exclusions, or not at all.** Ratios in this book state their
denominator. The programme's own coverage instrument spent days reporting "39 of 112 owner gates
witnessed" while the tree held **185** — a third of them, including the entire token-DEBIT layer,
were excluded from their own denominator and therefore appeared in no column at all. An excluded item
is not reported as a gap; it is absent, which reads as neither.

> Where this book is uncertain, it says so. Where it was wrong earlier and corrected itself, it says
> that too, and keeps the wrong version visible — a correction with the error deleted teaches nobody
> anything, and this project's most useful findings came from re-examining its own conclusions.

## Layout

```
AUDIT-BOOK/
  README.md            <- this file: front matter, rules, reading order
  PART-I/              <- per-module audit chapters
  PART-II/             <- main-work chapters (1.1-1.5)
  PART-III/            <- the red-team round
  APPENDIX/            <- registers, instrument notes, reproduction commands
```

## Reading order

Part III is the shortest and the most concrete; a reader wanting to judge the work quickly should
start at `PART-III/README.md`. Part I is the historical foundation and explains why Part II exists.
Part II is the largest and the least dramatic — it is mostly the systematic construction of the
preview/pricing surface, and its value is in completeness rather than in individual findings.

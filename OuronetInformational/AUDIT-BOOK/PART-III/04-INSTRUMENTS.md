# Part III · Chapter 4 — The instruments, and the defects found in them

An audit is only as good as the things it measures with. This chapter records the defects found in
the **measuring tools** rather than in the contracts, and it is here for a specific reason: several
of them were more consequential than the contract defects in {{ch:defects}}, because a wrong instrument
does not fail — **it reports.**

Every item below was found during this round, and every one had been reporting confidently before it
was found.

---

## The pattern

Fifteen instrument defects, and the majority are one shape:

> **A measurement that silently excludes part of its own subject, and therefore reports `clean` or a
> ratio about a population it never examined.**

An excluded item is not reported as a gap. It is **absent**, which reads as neither a problem nor a
success. That is strictly worse than a known gap, because a known gap gets worked and an invisible
one does not.

---

## The coverage instrument reported ratios without their exclusions — twice

`_ownerobs.py` spent days reporting *"39 of 112 ownership gates witnessed"*. The tree contains
**185**. Seventy-three were outside the denominator, including the entire token-DEBIT layer — the
gates that stop a stranger moving somebody else's tokens. {{ch:ownergates}} tells that story in full.

The second time was subtler and is the one worth generalising. The tool's own documentation already
catalogued this error **in other tools**. It recurred in the tool written to audit it.

---

## The tool index was wrong about a quarter of the tools it indexed

The repository documentation names `TOOLS.md` as the safe way to learn what a tool does — explicitly,
*"never run a tool to find out what it does; read its docstring, or check the table"*. That guidance
exists because a loop that imported five source-rewriting tools *"just to prove they load"* had
silently deleted 111 lines of schemas from a contract.

The index was wrong about **13 of 49 entries**. The documented alternative to the dangerous action
was itself unreliable.

---

## Five tools reported on populations they had defined to exclude the gaps

This is the dominant failure mode in the whole record, and it is worth naming precisely because each
instance looked different and none looked like a bug.

| tool | enumerated | missed | what it reported |
|---|---|---|---|
| path checker | 3 tool directories | a 4th, holding a tool that **rewrote contract sources by default** | `clean` |
| owner-gate mapper | 4 of the 8 documented client prefixes | an entire batch-operation family | a shrinking worklist |
| preview coverage | **3 hardcoded files** | 14 previews, one of them never tested at all | **{{fig:previews_measured}} of {{fig:previews_client}}, {{fig:previews_unmeasured}} gaps** |
| stats generator | 2 log file *extensions* | a run written with a third | a report from **the previous day** |
| attack register | one directory | an attack that had to live beside its fixtures | a total of 37 where 38 existed |

Five tools. Five hand-maintained lists. **No list can report its own incompleteness**, so each
reported confidently about a population it had never seen in full — and the preview tool reported a
*perfect score*, which is worse than a gap, because a perfect score ends the enquiry.

The remedy in every case was the same: **discover the population, then check the list against it.**
Where discovery is impossible — a figure that needs a live run the tool cannot perform — the honest
move is to say the tool cannot see it, not to check a number it cannot derive.

## Two checks that enforced what they should have questioned

Worse than a tool that misses something is a tool that **locks in the error**.

- The **price-sheet generator** computed its headline by summing three of its four categories,
  dropping the rows priced in one currency rather than another — publishing **431** where the sheet
  listed **442**. And the artefact checker *required the narrative to quote that total*. **The gate
  enforced the undercount and would have gone red on anyone correcting it.**
- The **figure checker** verified that every narrative document agreed with a generated stats file,
  and never that the stats file agreed with the tree. Perfectly circular: **every figure in every
  document matched, and all of them were wrong together** — by 275 assertions and counting. Closing
  the loop moved four published figures at once, the first movement in weeks.

> A consistency check between N documents and one source proves the N documents consistent. It says
> nothing about the source — and a stale source reads *more* convincingly than a correct one,
> because everything agrees.

## The path checker scanned three of the four tool directories

`_toolpaths.py` exists to catch tools that reference paths which no longer resolve — a real incident,
in which moving the tool directory killed eleven tools that died at *import*, so nothing that diffed
their output could see it.

It enumerated three tool directories. There are four. The fourth held a tool that **rewrites contract
sources and wrote by default** — the exact inversion of the repository's own rule that source-rewriting
tools must require an explicit `--apply` flag — while being invisible to the checker.

The comment above that enumeration had been added earlier, specifically to warn against
under-enumeration. **It under-enumerated.**

> That is the argument for discovery over enumeration in one line: a hardcoded list **cannot report
> its own incompleteness**, so it says `clean` about what it never opened. The fix was not to add the
> fourth directory — it was to make the checker report any directory holding tools that its list does
> not cover, and to verify that report fires by planting one.

---

## Three metrics that were wrong in the direction of a tidier number

{{ch:ownergates}} records the binary → dilution → depth progression in full. The generalisable part:

> **A single number chosen to summarise a distribution is a claim about that distribution.** The
> binary scored "1 of 63" and read as *the observed column is worthless*; it was technically true and
> substantively false. It was only caught because the distribution was printed before the summary was
> published.

Two further corrections in the same instrument went in **opposite** directions within an hour —
first discarding real work by treating a capability-composition edge as a wall, then recovering it
but still filing an entire band as unreachable because the filter matched four of the **eight**
documented client prefixes. The first error shrank the worklist by more than half.

> A worklist that shrinks reads as progress, which is why errors in that direction are the ones that
> survive review.

---

## Two mistakes made while checking for mistakes

These are recorded because they are the most instructive items in the chapter.

**A truncated shell pipeline nearly produced a false finding against the audit record.** A search for
the regression test protecting a fixed defect was piped through `head -6` and showed nothing —
making a previous audit's *"adversarially proven"* look like an unretained claim. The tests exist,
at two named lines. A confident wrong answer from a pipeline artefact, and the second such artefact
in two days.

**A mutation test reported success without having applied its mutation.** While verifying a fix to
the coverage instrument's blind spot, a literal was patched, the tool re-run, and the result recorded
as *"10 → 10, unchanged"* — from a patch that had replaced **zero occurrences**. The slicing matched
nothing.

> **A mutation test that reports "no change" is indistinguishable from a mutation that never
> happened.** The remedy is a fixture where non-application is impossible: the verification is now
> three synthetic snippets — inline, hoisted, and an unrelated binding that must **not** credit —
> where the negative control is what keeps the fix honest.

This one is worth stating plainly: it happened one screen after writing a negative control into
somebody else's test, in the instrument built to audit exactly this class of error, by the person
auditing it.

---

## Two process defects

**Source-rewriting tools that ran on a bare invocation.** Two REPL formatters rewrote the tree
without `--apply`, and because one of them also performs the other's work, running both duplicated
every banner it inserted — **188 files, 16,457 insertions** during a routine tool census. Nothing was
lost because the tree was committed. *"The tree was committed" is not a safety property.*

**`git add -A` in a tree with concurrent work.** Committing while other work was in flight swept
other agents' in-progress scratch state into commits that had nothing to do with it — including
deliberately-failing probes, which made two test suites red **by construction** under commit messages
describing something else entirely. Both were repaired by later commits. *"The next commit fixed it"*
is the same sentence as *"the tree was committed"*, and it is not a safety property either.

It also **misattributes authorship**, which matters more than it sounds: this entire audit's value
rests on the record of who established what, and with what evidence.

---

## What was added

| instrument | what it protects |
|---|---|
| `_ownerobs.py` | which ownership gates have actually refused somebody, at what evidence depth |
| `_modref.py` | cross-module calls to members that **do not exist** — invisible to every other check, because the language resolves them dynamically and only raises if the branch is taken |
| `_toolpaths.py` *(extended)* | now discovers tool directories rather than listing them, and says so when it finds one it does not cover |
| `_redteam.py` *(extended)* | the attack register and the defect ledger must agree; a defect recorded in only one is one the audit undercounts |

The `_modref.py` result is worth stating because it is a **clean** one: of the calls it flags, the
class that is genuinely dead — a call to a member defined nowhere — numbers **13, every one of them
inside the legacy module** the architecture marks as frozen. **Live code: zero.** That zero is now
gated rather than remembered.

> It also refutes a finding. A reviewer flagged a single instance of the *other* class — a member
> that exists but is not declared on the interface — as a coupling defect. Counting the population
> first showed **{{fig:modref_undeclared}} live instances**, one member accounting for 57. That is the convention, stated
> as such in the architecture documentation. **A single instance cannot tell you whether it is a
> defect or a dialect.** Fixing it would have made the tree less consistent and reported a practice
> as a bug.

---

## Turning the instrument on the book

*(Added 2026-09-18, when this book was consolidated into a single volume.)*

Every failure mode in this chapter is about a measurement that was wrong while looking right. The
obvious next question is whether this book — which is nothing but measurements — has the same
problem. It was asked directly: a full re-derivation pass over all nineteen chapter sources,
checking every quantitative claim against the tree rather than against the other chapters.

**Result: 124 stale figures, against roughly 516 that still held.**

Not one had been written carelessly. Every one was correct on the day it was typed and the tree
moved underneath it — the assertion total, the preview count, a dozen `file:NNN` citations whose
line numbers had drifted, an entire section documenting a defect that had since been fixed. Two
chapters came back completely clean.

Three things follow, and they are the reason this section exists rather than a quiet round of edits.

**A book about stale figures had 124 stale figures.** Knowing the failure mode confers no immunity
from it. The chapters that were *most* careful — the ones that footnote their method and name their
denominator — were not meaningfully less stale than the rest, because carefulness is a property of
the moment of writing and staleness is a property of elapsed time.

**Hand-correcting 124 numbers would have fixed nothing.** It resets the clock and changes no
mechanism. So the volatile figures are no longer written in the chapters at all: a source now writes
`{{fig:assertions}}` or `{{fig:previews_measured}}`, and the assembler substitutes the number it
**measures at build time** by running the tool that owns it. About eight seconds per build. A figure
that cannot be measured is a build failure rather than a fallback to the last known value — a
default would be a stale figure with extra steps. Twenty-two figures are wired this way, and that
class of drift is now closed rather than corrected.

**One of the 124 was not stale, and how it failed is the chapter's own lesson.** The sweep reported
that {{ch:swp}}'s closing claim was false: the chapter cites `SWP|TX 015b` as the live witness for
finding `#72C`, and the file that holds it —
`Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl` — is in `_gate.py`'s `EXCLUDED` list. The reasoning
is sound and the premise is true. The conclusion is wrong.

`EXCLUDED` is a list of files not run **as entrypoints**, for the stated reason that this one is an
*alternative* to `[6.2]`+`[6.3]` and would duplicate their work. It says nothing about
reachability. `Stage01_Tester.repl` loads the file at line 42, and thirteen files load
`Stage01_Tester.repl`, of which eight are gate entrypoints. Running one of them and grepping the
output settles it in two minutes:

```
"--- [SWP|TX 015b - #72C Regression: Stable-Swap Inverse Newton Domain Guard · 02 · let / invocation] ---"
"Expect: success #72C regression — in-domain inverse quote (output=0.5x reserve) is positive"
```

The witness runs, several times per gate run. The chapter's claim stands.

This is the book's own rule — **locate by execution, not by reading** — failing in the one place it
would be most embarrassing: an audit *of* the book, by a reader who had the rule available and
reached a confident, well-argued, false conclusion from a list. Exclusion is not unreachability. A
name absent from a runner's entrypoints is not a name absent from the run, and only running it can
tell you which.

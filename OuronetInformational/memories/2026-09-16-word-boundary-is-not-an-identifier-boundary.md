# `\b` is not an identifier boundary — and the triage that found it

*2026-09-16. Closes the four `--produced` candidates left open by RT-K-007. No new contract defect:
one of the four was a TOOL defect, the other three are correctly left alone. The tool defect was in
the shared lexer and reached eight call sites across five scanners.*

## What was open

`_eagerlet.py --produced` left four sites needing the question asked by hand — *does this guard's
message already cover absence?* If it does, the raising read is stealing a sentence the guard was
written to say; if it only claims a STATE, defaulting the reader manufactures a wrong diagnosis
(the `must be set` trap).

| site | message | verdict |
|---|---|---|
| `08_ATS.pact:1790` | "Amount of EA used for Cold Recovery cannot be greater than what exists" | **TOOL FALSE POSITIVE** |
| `18_SWPLC.pact:926` | "Frozen LP Functionality is not enabled on Swpair {}" | STATE claim — leave |
| `05_FVT.pact:1843` | "FVT mosaic update requires can-upgrade true" | STATE claim — leave |
| `02_SCORE.pact:884` | "score **must exist** as DPNF (class 4)…" | existence claim — but see below |

## The one that looked real, and why it is still not actionable

`02_SCORE.pact:884` is the only one whose message claims existence, so by the rule it qualifies.
Two facts, both measured, say otherwise:

**1. The flagged line is not the first raiser.** On `SCR|C>ISSUE-NF-SCORE-DEFINITION`, the caller
never reaches :884 — `UEV_NonFungibleScoreDefinition` runs first and opens with
`(UR_SCR|ScorePrecision score-id)`, a bare `read`. Defaulting the reader the scanner points at
would change **nothing any caller sees**. *A detector that finds a guard which cannot speak does
not thereby find the thing that silenced it* — check which read actually fires first before
repairing the one that was reported.

**2. The reader is shared with the preview, and the preview's abort is pinned.** Both halves reach
`UR_SCR|ScoreOwnerKonto`. `Stage_02/[6.5]_AQP-INFO.repl:190` pins the preview aborting on an unknown
score as a FINDING, and that suite is **deliberately fixture-free** — it passes `"SCR-x"`, `"DPNF-x"`
to all 83 AQP readers on the sound principle that AQP prices are argument-independent. Defaulting the
shared reader turns that pinned `expect-failure` red. This is the same blocker RT-K-007 already
recorded for the AQP preview half, and its reasoning stands: making AQP previews validate ids needs
anchor/score/boost-class fixtures for every one of them, which is a real piece of work with a design
question inside it.

Unlike RT-K-007, there is also **no purpose-built guard being silenced here**. `UEV_LiveAnchor`
existed and was written for the missing-anchor case; SCORE has no existence validator at all, and
the "must exist" clause is one conjunct of a compound message already annotated at source as a
data-integrity assertion.

## The tool defect: `\b` treats a hyphen as a boundary

`08_ATS.pact:1790` was reported as *"an enforce here tests `c-rbt`"*. The enforce tests
`c-rbt-amount`. In Python, `\b` is a word/non-word transition and `-` is a NON-word character, so

    re.search(r'\bc-rbt\b', '(<= c-rbt-amount ea-supply)')   ->  MATCHES

Pact identifiers use `-` freely, so `\b` silently turns every hyphenated name into a **prefix match
against every longer name containing it**. The same `\b` appeared in **eight places across five
tools**, including `_pactlex.reader_kinds`'s own hardness test, where a read keyed on `pool-id`
"mentions" a parameter named `id` and the reader gets marked hard.

Replaced by a shared `_pactlex.ident_re(name)`. Measured effect, all diffed against saved baselines:

| tool | before | after |
|---|---:|---:|
| `_eagerlet` (narrow) | 0 | 0 — identical |
| `_eagerlet --produced` | 4 | **3** — the ATS false positive gone |
| `_eagerlet --wide` | 15 | **10** — `ouro` inside `ouro-id`, `dptf` inside `dptf-id`, `sov` inside `sovereign`, … |
| `_foldeager` | 4 | 4 — identical |
| `_docclaims` | 1 | 1 — identical |
| `_pricesync --check` | ok | ok — generated artefact byte-identical |

**Mutation-tested both before and after the correction below**: reverting RT-K-007's fix to
`UR_ANK|State` makes `--produced` name `UEV_LiveAnchor` again. A boundary change to a detector is
exactly the kind of edit that can quietly stop it detecting.

## THE CORRECTION THAT MATTERED MORE THAN THE FIX

The first version of `ident_re` put `|` in the identifier class. That is wrong, and it produced a
confident, entirely false result:

> `_docclaims.py`: claims whose function is NEVER mentioned in any .repl: **1 → 25**

Twenty-four new "unverified doc claims", every one false. `_docclaims` matches
`name.split('|')[-1]`, so `ATS|HOT-RBT|C_Repurpose` is searched for as `C_Repurpose` — and **every
standalone `C_Repurpose` in the REPL corpus is preceded by `|`**, because that is how qualified
names are written. Treating `|` as part of the identifier made the left boundary reject the real
mentions. Pact uses `|` as a SEGMENT SEPARATOR, exactly like `.` and `:`.

It would have been easy to report those 24 as a find. They looked like a find: a bigger number from
a tightened checker, in a tool whose whole job is catching unverified claims. **A checker that gets
stricter and reports more is the single easiest result to believe and the easiest to get wrong** —
the number moves in the direction that flatters the change. What caught it was checking ONE of the
24 by hand against the corpus, which took one `grep` and showed 17 live mentions of the function the
tool had just declared unmentioned.

So: two corrections against evidence, in a helper of one line. The RT-K-007 note said the detector
needed three. That is not a run of bad luck — it is what tightening a matcher costs, and the price
is paid in verification, not in cleverness.

## THE SECOND TOOL DEFECT: a 300-character window, wrong in BOTH directions

Annotating the triaged sites made one of them vanish from the scanner entirely instead of moving to
the "known" list. That is not what an annotation does, so it was worth chasing.

`_eagerlet` took the text of an `enforce` as a FIXED 300 CHARACTERS from its opening paren. That is
wrong twice over:

**It BLEEDS into the next guard.** `18_SWPLC.pact` has two adjacent enforces:

    (enforce iz-asymmetric "Chilled Liquidity can only be added when asymtric liquidity exists")
    (enforce iz-frozen     "Frozen LP Functionality is not enabled on Swpair {}")

Scanning from the FIRST, the window reached the second. So the tool took its VARIABLE (`iz-frozen`)
from one guard and its EXISTENCE signal (`exists` — in a sentence about *liquidity* existing, not
about a row) from another, and reported a defect at a third place. **I then hand-triaged the guard
the tool NAMED rather than the guard it had actually matched, and reached a defensible conclusion
for entirely the wrong reason.** A compound artefact can survive human review precisely because the
site it points at is real code that deserves a thought.

**It also TRUNCATES.** An `enforce` whose message sits past 300 characters — every multi-line
`(fold (and) true [...])` guard in AQP — loses its message, so the existence test cannot fire. **Six
real candidates were invisible for that reason alone.**

Running to the next `(enforce` fixes the truncation and keeps the bleed. The bound that is neither
too short nor too long is the form's OWN balanced parens, and `_pactlex.balanced` was already
imported. Measured: `--wide` 15 → 6, `--produced` surfaced the 6 hidden AQP sites, narrow stayed 0,
mutation test still names `UEV_LiveAnchor`.

## WHAT THE FIXED TOOL THEN SHOWED: a class, not an anecdote

With both defects fixed, `--produced` reports **seven** AQP guards whose message claims existence
while a hard read of the same subject raises first:

    02_SCORE.pact  805  "score must exist, sft-equality false, nonce/value lists aligned ..."
    02_SCORE.pact  884  "score must exist as DPNF (class 4) with matching score-id"
    02_SCORE.pact  943  "boost-score-id must exist, be non-BAR, not equal this score-id ..."
    02_SCORE.pact  980  (triplet row-id equality fold)
    03_AQP.pact   2332  "Invalid score-id for pool assignment (missing score, class mismatch ...)"
    05_FVT.pact   1903  "Invalid AddScoreEntity score: row exists, links, class, or swpair mismatch"
    05_FVT.pact   1982  "Invalid AddScoreEntity triplet: row exists, links, or swpair mismatch"

**One root cause and one blocker.** The readers are shared with the `INFO_` previews, and
`Stage_02/[6.5]_AQP-INFO.repl` is DELIBERATELY fixture-free — it passes `"SCR-x"` / `"DPNF-x"` to all
83 AQP readers on the sound principle that AQP prices are argument-independent — and PINS those
aborts as findings. Defaulting any shared reader turns a pinned `expect-failure` red. That is the
same blocker DEFECT-LEDGER 7.3 already records for RT-K-007's preview half, and the same real design
question sits inside it.

All seven are annotated `;;PRODUCED-TRIAGED` at source, so the mode now reports **7 known, 0
unexamined**. The third marker was added for them: `UNREACHABLE` and `CANNOT PROTECT` both ASSERT
something strong, and these guards ARE reachable and DO protect the rows that exist. **Annotating
them with an existing marker would have meant writing down something untrue in order to quiet a
scanner** — the cheapest possible way to corrupt a codebase's own record of itself.

**The tool fix is what turned this from an anecdote into a class.** Before it, this was "one AQP
guard found by accident during RT-K-007". After it, it is seven guards, one cause, one decision —
and the decision is now stated once, at the site, in seven places that point at it.

## Rule

**Never use `\b` on a Pact identifier.** Import `_pactlex.ident_re`. Its boundary class is
`[A-Za-z0-9_-]`: hyphens and underscores are part of a name, `|` / `.` / `:` are separators between
names. Both halves of that were established by measurement, in opposite directions, an hour apart.

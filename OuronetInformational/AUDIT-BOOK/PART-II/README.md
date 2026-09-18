# Part II — The Main-Work Round

> Roadmap Phases 1.1–1.5. Source records: `POST-AUDIT-MAIN-ROADMAP.md`, `IGNIS-PRICING/`,
> `ARCHITECTURE/REPL_TEST_ARCHITECTURE.md`, `ARCHITECTURE/REPL-ROUND-REPORT.md`,
> `ARCHITECTURE/DEFECT-LEDGER.md`, and 370 commits between 2026-08-30 and 2026-09-14.

## What this round was

Part I audited modules that already existed. Part III attacked a system that was already finished.
This Part covers the work in between: building, across the whole codebase, **one cost reader per
priced operation and one free preview per client operation**, re-pricing everything those readers
return, splitting the one module that had grown past the point where it could be deployed, and
rebuilding the test suite around the result.

The roadmap describes its own value accurately, and this Part does not inflate it:

> *"mostly the systematic construction of the preview/pricing surface, and its value is in
> completeness rather than in individual findings."*

So the chapters demonstrate completeness with counts, and they state the exclusions those counts
carry. Where something did go wrong — and several things did, including a repricing script that
duplicated 1.78 million lines of contract source and a pricing headline that is **still** eleven
operations short — the chapter says so with the file and the number.

---

## The round, in numbers

**[VERIFIED by command]** — `git diff --shortstat 0ab7639 b8284a5`, the first commit of the phased
roadmap board (2026-08-30) to the round's own closing checkpoint (2026-09-14).

| | |
|---|---:|
| commits | **370** |
| files changed | **500** |
| lines added / removed | **+154,877 / −42,312** |

Per area, from `git diff --numstat` over the same range:

| area | files | + | − |
|---|---:|---:|---:|
| `REPL/` | 290 | 74,454 | 6,177 |
| `1_SOVEREIGN/` | 90 | 45,809 | 29,163 |
| `OuronetInformational/` | 69 | 25,180 | 758 |
| `2_CITIZEN/` | 30 | 7,506 | 5,890 |

And what those deltas did to the two things a reader cares about — **[VERIFIED by command]**,
`git archive <rev> | wc -l` at each endpoint:

| | 2026-08-30 | 2026-09-14 | today (HEAD) |
|---|---:|---:|---:|
| Pact source files | 91 | 93 | **{{fig:modules}}** |
| Pact source lines | 96,310 | 114,156 | **{{fig:pact_lines}}** |
| `.repl` files (excl. `archive/`) | 181 | 209 | **{{fig:repl_files}}** |
| `.repl` lines | 68,435 | 120,603 | **{{fig:repl_lines}}** |
| distinct assertions written | **1,604** | **5,262** | **{{fig:assertions_distinct}}** |

> **These are a SNAPSHOT, and the book says so rather than implying permanence.** The distinct
> count moved four times on 2026-09-17 alone as witnesses were added; it was **5,555** when the
> figure-sync tool's own source of truth was found stale, **5,830** when that loop was closed, and
> **{{fig:assertions_distinct}}**, measured when this book was built. The canonical value is whatever `ARCHITECTURE/REPL_SUITE_STATS.md`
> holds, which `_figuresync.py --check` now verifies **against the tree** rather than against itself
> — see DEFECT-LEDGER §8.22.

The test suite grew faster than the contracts it tests, by a factor of about four. That is the
shape of the round.

---

## What each phase produced, measured today

Every figure below is re-derived from the working tree, not quoted from a status document. The
command is named in the chapter that owns it.

| phase | what it built | measured in the tree |
|---|---|---|
| **1.1** `URCi_` cost architecture | one pure cost reader per priced operation | **322** implementations across **40** modules; **291** declared on an interface, **31** in-module-only and **none of those 31** called cross-module |
| **1.2** `INFO_` preview rehaul | one free preview per client operation | **426** implementations across **10** modules: **346** wrap a `URCi_`, **59** delegate to a sibling preview, **20** declare the op free, **1** is a data view |
| **1.3** IGNIS re-pricing | the whole cost model moved into four constant maps | `IG\|DETER` **54** keys · `IG\|COMPONENTS` **396** · `IG\|WEIGHTS` **14** · `IG\|LEGS` **22**; the generated price sheet carries **442** priced rows + **5** declared unpriced |
| **1.4** module splits | `04_FVT.pact` cut below the deploy ceiling | `04_RPS.pact` **5,621** lines + `05_FVT.pact` **3,977**; **0 of 93** modules over the ~6,635-line cliff, **1 in the project's own "Danger" band** |
| **1.5** REPL finalisation | a one-command gate over the whole suite | **{{fig:entrypoints}}** gate entrypoints, **14** fatal static checks, **{{fig:assertions_distinct}}** distinct assertions, orphaned asserting files **0** |

---

## Three published figures that the tree did not support

Found while writing this Part. Each was a live discrepancy when written, each was verifiable with
one command, and each was a different failure mode.

> **ALL THREE ARE NOW CLOSED.** *(Verified 2026-09-18.)* They are kept in full, as they were
> written, because the point of this section is the three failure modes and not the three numbers —
> and because a finding deleted once it is fixed leaves a book that cannot show its own working. Each
> carries a dated closure note below.
>
> That they were all fixed within days is worth one caution, though. These three were found by
> re-deriving published figures from the tree. A staleness sweep of this book's own chapters on
> 2026-09-18 found **124** stale figures against ~516 that still held — in a book whose third rule is
> about counts. Finding three in someone else's documents is easy; the discipline is turning the same
> instrument on your own, which is why the volatile figures in this book are now measured at build
> time rather than typed. {{ch:repro}} says how.

**1. The roadmap's own correction notice is itself wrong.** `POST-AUDIT-MAIN-ROADMAP.md` carries a
2026-09-17 banner warning that its dashboard is stale, and supplies replacement figures: *"267
distinct `URCi_` readers"* and *"335 distinct `INFO_` previews"*. The first is a count of distinct
**names** (268 today) and undercounts implementations by 54, because names legitimately repeat
across modules. The second matches nothing: the tree holds **426** implementations and **425**
distinct names. *A correction notice is read with more trust than the thing it corrects.* {{ch:previews}}.
>
> **CLOSED 2026-09-18.** The banner now reads *"256 distinct `URCi_` readers (307 implementations)"*
> and *"420 distinct `INFO_` previews"*, scoped to `1_SOVEREIGN/` as it always claimed to be. The
> maxim in italics above went on to apply to this book: {{ch:previews}} §2 published a correction
> that was itself wrong and reverted a correct figure, and it was believed precisely because
> corrections are.

**2. The designated authoritative pricing reference quotes a superseded census.**
`IGNIS-PRICING/IGNIS-PRICING.md` §5 states *"345 of 365 INFO implementations are thin wrappers over
a `URCi_` reader; 14 declare their op free, 4 are data views."* Those figures were exactly right on
2026-09-06, when commit `6b7a85b` measured them and said so. The tree today is **346 / 426 / 20 / 1**,
and the document's own three sub-counts sum to 363, not 365. {{ch:previews}}.
>
> **CLOSED 2026-09-17.** §5 was re-measured and now publishes {{fig:previews_declared}} declared /
> {{fig:previews_client}} client-facing / {{fig:previews_measured}} measured, quoting the 345/365/14/4
> census explicitly as superseded rather than replacing it silently.

**3. The generated price sheet publishes a total that omits eleven of its own rows.** The footer
reads *"431 Talos client functions"*. The sheet contains **442** priced rows. The generator computes
the total as `nsimple + ncomplex + nexempt` and omits `nstoaonly` — so every operation priced in
STOA and not in IGNIS (branding upgrades, the PYTHIA tolls, the CODEX StoicTag family) is counted in
its own column and then dropped from the headline. This was recorded as an internal inconsistency in
`DEFECT-LEDGER.md` §5 item 14 on 2026-09-15, at the then-current values of 420 and 430. It was not
fixed; the numbers had since grown to 431 and 442. **And a control added the same week required the
prose document to quote the wrong total, and failed the gate if it did not.** {{ch:pricing}}.
>
> **CLOSED 2026-09-17.** `_ignis_price_sheet.py` now sums `nsimple + ncomplex + nstoaonly + nexempt`;
> the sheet's footer reads **442**, `IGNIS-PRICING.md` quotes 442, and the literal `431` no longer
> appears anywhere. The fix was one identifier. What made it a finding worth a section was never the
> eleven rows — it was that a **generated** artefact had been wrong for weeks while a gate check
> enforced agreement with it, so the control was actively holding the error in place. A check that
> enforces consistency between two things says nothing about whether either is right.

> None of the three was a defect in the chain. All three were defects in what the project publishes
> about itself, which is what an audit book is made of.

---

## Chapters

| | |
|---|---|
| `01-URCI-INFO.md` | The cost-reader and preview surfaces: what they are, how complete they are, and what the completeness claim excludes |
| `02-PRICING.md` | The cost model, the decisions, the generator, and the gate mechanism that makes the generated artefacts re-derivable |
| `03-SPLITS.md` | The deploy ceiling, the FVT split, what the split cost, and what it did not finish |
| `04-REPL.md` | The test architecture: six gates, 92 entrypoints, and where the verification has holes |

## How to re-derive anything in this Part

The book's reproduction appendix (`APPENDIX/01-REPRODUCTION.md`) covers the gate and the two money
defects. The counts specific to this Part come from the following, all read-only and all runnable
from the repository root:

```bash
# URCi_ / INFO_ census, separating interface declarations from implementations
python3 - <<'PY'
import re, glob, os
PFX = re.compile(r'^(?:[A-Za-z0-9|_-]+\|)?([A-Z]+[a-z]?)_')
DEF = re.compile(r'\(defun\s+([A-Za-z0-9|_>-]+)')
impl = {}; decl = {}
for f in sorted(glob.glob("1_SOVEREIGN/**/*.pact", recursive=True)
                + glob.glob("2_CITIZEN/**/*.pact", recursive=True)):
    if "/Audit/" in f: continue
    src = open(f).read()
    mi = [m.start() for m in re.finditer(r'^\(module\s', src, re.M)]
    start = mi[0] if mi else None
    for m in DEF.finditer(src):
        p = PFX.match(m.group(1))
        k = p.group(1) if p else None
        if k not in ('URCi', 'INFO'): continue
        (impl if start is not None and m.start() >= start else decl
         ).setdefault(k, set()).add((f, m.group(1)))
for k in ('URCi', 'INFO'):
    print(k, "implementations:", len(impl[k]), " interface declarations:", len(decl[k]))
PY

# price-sheet categories, counted from the artefact's own row markers
f=OuronetInformational/IGNIS-PRICING/IGNIS-PRICE-SHEET.md
grep -c 'admin/exempt' $f; grep -c 'empty cumulator' $f; grep -c 'collects none of them' $f
grep -c 'collects no IGNIS and no STOA' $f; grep -c '| STOA only |' $f
grep -c '| COMPLEX |' $f; grep -cE '\| \$[0-9]' $f

# module size bands, against MODULE-SIZING.md section 1
find 1_SOVEREIGN 2_CITIZEN -name '*.pact' -not -path '*/Audit/*' -print0 | xargs -0 wc -l \
  | sort -rn | head -10

# gate entrypoint arithmetic, without running the gate
cd REPL && echo $(( 7 + $(ls deb-staleness-*.repl | wc -l) + $(ls modules/*.repl | wc -l) \
  + $(ls RedTeam/*.repl | grep -vc '/_') + 27 + 6 ))
```

**Do not run `REPL/tools/_suite_stats.py` or `REPL/tools/_toolindex.py` to inspect them.** Both
rewrite a tracked artefact on a bare invocation, with no `--apply` flag. They are generators and
regenerating is the intended action, but the repository's own rule about tools that write on import
applies to the habit, not only to the five tools that caused the incident behind it.

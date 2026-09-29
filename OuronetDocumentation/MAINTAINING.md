# Maintaining this documentation

> "and of course this has to be tied to some sort of skeleton, such that when the code changes, we
> can easily update every places that needs to be update becuase of that change. i dont know how
> wed achieve this. **i dont want to stay a week everytime something change to update the
> documentation, or it risks becoming stale very quickly.**"
>
> — owner, 2026-09-23

This is a requirement about how the folder is **built**, not about what it says. It is written
before the bulk of the pages, because it decides which parts of them are typed by a human and
which are emitted by a tool — and retrofitting that decision across 79 module pages is precisely
the week of work it forbids.

**The test it has to pass**, stated so it can be checked rather than believed:

> A function is added to a module. How many files must a human edit, and how does the human find
> out which?

The answer has to be "one page, one heading, and a tool said which" — not "grep and hope".

---

## 1. Why the obvious approach fails

The instinct is to generate everything. It does not work here, and the reason is worth stating
because it is the whole design constraint.

A generator can produce the **enumeration**: every schema, every table, every capability, every
function with its signature and prefix. It cannot produce the **explanation** — what a row means,
why a capability composes another, what happens when you call this, what bit someone. The
directive asks for exactly that second thing:

> "something someone could read, and udnerstand what we wanted to create, **without having to go
> an read the code**"

A fully generated reference is a worse `MODULE-INDEX.md`. A fully hand-written one is stale in a
month. So the pages are **both**, in the same file, with a machine-checkable seam between them.

## 2. The split

Every page that describes code has two kinds of content:

| | produced by | staleness risk | check |
|---|---|---|---|
| **Enumeration** — schemas, tables, capabilities, function signatures, entrypoint lists, all figures | a tool, between markers | silent and total | regenerate and diff |
| **Explanation** — purpose, mechanism, rationale, traps, limitations | a human | visible (it reads as vague) | coverage: every enumerated item is mentioned |

Generated regions are delimited exactly as the Pact deploy files already do it — the pattern is
proven in `REPL/tools/_purev2.py`, where each deploy file keeps a hand-written prose header above
a `;;@GENERATED-BODY-BELOW` marker and the body is emitted byte for byte:

```markdown
<!-- @generated:functions -- do not edit below; run REPL/tools/_docsmodules.py --write -->
...emitted table...
<!-- @end:functions -->
```

A human edits everything outside the markers and nothing inside them.

## 2a. LIVE CODE IS THE SOURCE OF TRUTH — the repo is the comparison

Owner refinement, 2026-09-29, and it changes what "generated" means here.

The enumerations are derived from the **deployed contracts**, not from the repository, and the
repository is then **diffed against them**. Priority is live; the repo is the check.

The reason is that they can differ, and when they do the repo is the one that is wrong in the way
that matters — a reader of this documentation is going to call the chain, not the checkout. A page
generated from a source file that has drifted ahead of mainnet describes a system nobody can use.

**This is already how the client surface works**, so it is a pattern to extend rather than invent:

```bash
python3 REPL/tools/_registry.py --probe    # reads the CHAIN, rebuilds, records divergences
# generatedFrom: "chain+repo"   divergences: 0   notDeployed: 0
```

The registry carries a `divergences` list precisely for this — deployed-vs-repo mismatches,
reported rather than silently resolved either way. It is 0 today. A module-level generator must do
the same thing one level down: `describe-module` for the deployed shape, the source for what the
repo believes, and **the difference published rather than reconciled**.

Three consequences for the build:

- **A page states which it describes.** Where live and repo agree, say so once. Where they differ,
  the page shows the deployed behaviour and flags the divergence — that is a finding, not a
  formatting problem.
- **A module not yet deployed is marked as such**, not silently documented as though it were live.
  `Deploy/MANIFEST.md` already records every deliberate exclusion with a reason.
- **The generator needs the network**, so it cannot sit inside `_gate.py`, which must run offline.
  Same split `_registrylive.py` already makes: the gate checks the artefact, a separate recorded
  run confirms the artefact against the chain and dates it.

## 3. What the tools must do

Three jobs, in increasing order of value.

**a. Regenerate the enumerations.** `--write` rewrites every marked region from the tree;
`--check` regenerates into memory and reports drift. This is the mechanism already used for
`IGNIS-PRICE-SHEET.md`, `ARCHITECTURE/*.md`, `Deploy/` and the PureV2 batches, all of which are
fatal inside `REPL/tools/_gate.py`. Nothing new is being invented.

**b. Check the figures in prose.** A number written into a sentence cannot live inside a marker.
`REPL/tools/_chapterfigures.py` already solves this for `docs/CHAPTER-INTEGRATION/` — it
recomputes fifteen registry-derived figures and fails on a stale one *and* on reworded prose that
no longer matches the pattern. The same tool, extended to this folder, covers the front-page
table and every figure quoted in a sentence.

**c. Check coverage — the join, and the part that earns the whole design.** For each module page:
every function, capability, schema and table that exists in the source must be *mentioned* on the
page. A new function therefore surfaces as:

```
30-modules/28-ATS.md: 3 items in source not mentioned on the page
    defun  UCx_FilterHibernatedAts
    defcap ATS|C>COIL
    table  ATS|Pairs
```

That is the sentence which converts "a week of reading" into "edit one heading". It is also the
only one of the three that catches an **omission** rather than a contradiction — and omission is
the failure mode of hand-written documentation.

## 4. Status, stated honestly

| job | state |
|---|---|
| the marker convention | **decided** (this file) |
| (a) regenerate enumerations | **not built.** Pattern proven by `_purev2.py` / `_deploybundle.py` |
| (b) figure checking | **built for `docs/CHAPTER-INTEGRATION/`** as `_chapterfigures.py`; not yet extended here |
| (c) coverage checking | **not built.** This is the one with no precedent in the repo |
| gate membership | **not yet.** Deliberate: see below |

Nothing above claims a tool that does not exist. Two of the three are patterns this repository
already runs in anger, which is the reason to believe the third is tractable rather than a plan.

**Why not in the gate yet.** A check added while the thing it checks is half-written fails
constantly, and a check that always fails gets disabled — which is worse than never having added
it. These join `_gate.py` when `30-modules/` is complete. Until then they are run by hand, and
this table is how a reader knows which.

## 5. The rules that hold regardless of tooling

These are enforceable by review today and cost nothing.

**Cite, never copy.** Where a fact is maintained elsewhere — the price sheet, the registry, the
Audit Book, `MODULE-INDEX.md` — link to it. A copy is a second version to keep in step, and the
second version is always the stale one.

**Every figure carries its scope.** "105" is meaningless; "105 `.pact` files under `1_SOVEREIGN`
and `2_CITIZEN`" is checkable. This folder already has one near-miss on record:
`MODULE-INDEX.md` reports 423 *tables* for the whole tree and the registry reports 423 *client
entrypoints* for the deployed surface. Equal today, unrelated forever.

**A figure with no command is a rumour.** `90-reference/03-how-these-figures-were-obtained.md`
carries the command for every number in this folder. It is also the proof that this discipline is
not optional: that file previously published "68 interfaces", with the command that produced it
printed on the line below — and the command used `-l`, which counts *files containing a match*,
and omitted half the scope. The real figure is 98. It had already reached the front page.

**Never hand-edit a generated region**, and never hand-edit a generated artefact anywhere in this
repository. Edit the generator. This rule exists in `CLAUDE.md` because it was broken: two
generated audit artefacts drifted for a day and were hand-edited while their generators were dead.

## 6. What a code change costs, once this is running

The point of all of it, as a procedure:

1. change the Pact.
2. `python3 REPL/tools/_docsmodules.py --write` — enumerations catch up, no judgement needed.
3. `python3 REPL/tools/_docsfigures.py --check` — names any sentence whose figure moved.
4. `python3 REPL/tools/_docscoverage.py --check` — names any page, and heading, now missing an
   explanation.
5. write prose for exactly what step 4 listed.

Steps 2–4 are seconds. Step 5 is the only human work, and it is bounded by the size of the change
rather than the size of the documentation. That is the requirement.

---

## Sources

- The requirement, verbatim: `90-reference/04-the-owner-directive.md` §4a
- Generated-artefact discipline and the incidents behind it: `CLAUDE.md`, *"Generated artefacts
  are gate-enforced"*
- The marker pattern in use: `REPL/tools/_purev2.py`
- Figure-checking in use: `REPL/tools/_chapterfigures.py`
- The 68-vs-98 correction: `90-reference/03-how-these-figures-were-obtained.md`

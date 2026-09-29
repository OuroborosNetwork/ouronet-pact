# The gate

One command decides whether this codebase is in a shippable state:

```bash
python3 REPL/tools/_gate.py
```

It does two things, and the second is the one that matters.

---

## 1. Job one: run everything

The gate executes every test entry point in parallel and reports what happened. A measured run,
on sixteen cores:

```
wall 312.8s   executed 26128 assertions (20952 positive, 5176 negative)
GATE GREEN
```

**26,128 assertions** across **93 entry points** reaching **334 files**. Five minutes, because
wall time is the slowest single entry point rather than the sum of all of them — a Pact test run
opens no file for writing, so each is an independent OS process with its own in-memory database.
That was verified by tracing system calls, not assumed.

**5,176 of those assertions are negative** — one in five. They check that something is correctly
*refused*: a stranger turned away, a malformed argument rejected, an exhausted balance declined.
That ratio is worth pausing on, because negative tests are the easiest to skip. Nothing visibly
breaks when they are missing. The system simply becomes permissive in ways nobody notices until
someone tries.

---

## 2. Job two: prove nothing is orphaned

The second job is unusual enough to be the interesting part of this chapter.

> Every file carrying assertions must be **reachable** from a gate entry point, or be explicitly
> excluded with a stated reason. Anything else fails the gate.

Running the tests tells you the tests that ran. It says nothing about tests that exist and
*didn't*. The gate's own docstring explains why that distinction earned a second job:

> In an earlier phase four test drivers were archived on an "assertion-free" heuristic — **true of
> the drivers themselves, false of what they load.** They were the only path to two whole test
> families, and moving them also broke their relative load paths, so they could not have run even
> in place. **~125 assertions silently left the suite and the ledger never noticed, because the
> ledger counts files, not execution.**

And the conclusion, which is the sentence this chapter exists for:

> **An assertion that nothing executes is not coverage — it is decoration that reads as coverage,
> to a ledger and to a human.**

This half is cheap. `--audit-only` runs the reachability proof and no tests at all, in seconds
rather than minutes:

```
GATE: 93 entrypoints, 334 files reachable
orphan check: clean -- every asserting file is reachable from the gate
```

---

## 3. The thirty-one static checks

Before any test runs, the gate invokes **31** separate analysis tools, and exits on **34**
distinct fatal conditions.

They group into five families below, which account for 28; the twenty-ninth is the assertion
checker of §4, and the remaining two are the conformance and heavy-read checkers that
`02-semi-self-auditing.md` describes. The rows are stated with their arithmetic because a
classification that does not add up to its own total is the thing this chapter is about.

### Generated artefacts must equal their generator — 12

Twelve checks regenerate a file into memory and diff it against what is committed. The price
sheet, the deploy bundles, the consumer registry, the audit book, the tool index, the published
package's copy of the surface.

The rule that follows is absolute: **edit the generator, never the artefact.** A hand-edited
generated file is a lie that survives exactly until someone regenerates it.

This family grew by incident. The deploy bundles were the *one* generated artefact the gate did
not diff — purely because they arrived later than the others — and the failure mode was specific:
edit a module, gate green, ship a deploy batch that no longer matches the module it claims to
deploy. The check caught real drift the hour it was added: two batches stale from a function
reorder.

### Static properties of the code — 7

Seven checks read the tree and assert things no test can easily reach: that every call site passes
the right number of arguments; that a cross-module call names a member its interface actually
declares; that a projecting read asks for a column its table has; that no computed binding is
discarded; that every prefix used is one the canon knows.

These are cheap and they are absolute. A call-arity error is not a matter of judgement.

### Registered exceptions — 2

Two checks are different in kind. They do not forbid a pattern — they require that every instance
of it be **written down**.

Some argument slots legitimately carry something other than what their name suggests, and some
entity identifiers are legitimately hardcoded. Neither can be banned. So the tools carry a
registry of every known instance with its justification, and are **fatal only on an unregistered
new one**.

That converts an unbounded judgement call into a bounded one: nobody has to decide whether a
pattern is acceptable, only whether *this* instance was declared.

### Proof obligations — 5

Five checks assert that a property holds across the whole surface: that every executor is provably
enforced, that no client entry point has lost its ownership check, that every recorded attack
still fails, that the citizen batch ladders tile their range without gap or overlap, and that
every non-ASCII literal the retired read layer emitted survives byte-for-byte in its replacement.

That last one exists because a formatter was once re-typed with an ASCII `c` in place of a cent
sign, and reached mainnet in two modules.

### Chain truth, and the gate's own tools — 2

One check asks the **chain** which tables actually exist, refusing to suppress a table creation
without evidence. And one check — `_toolpaths.py` — statically resolves every hardcoded path in
every tool, because a tool that dies at import produces no output, and nothing that compares its
output can tell the difference between "clean" and "did not run."

That check exists because moving the tools directory once killed eleven tools in exactly that way.

---

## 4. The check that examines the tests

The most interesting tool in the set does not look at the contracts at all. It looks at the
assertions:

```
positive `expect` sites: 4694
  VACUOUS (cannot fail)                 : 0
  WEAK    (bound the domain guarantees) : 12
```

A **vacuous** assertion is one that cannot fail for any input — it compares a value to itself,
or asserts something the type system already guarantees. It passes forever, contributes to the
count, and proves nothing. A **weak** one can fail, but only outside the domain the function
already restricts.

**Zero vacuous out of 4,694**, and twelve weak ones carried deliberately.

This is the gate turning its method on itself. Everywhere else it asks *"is the code sound?"*;
here it asks *"is the evidence real?"* — and it is the only check whose absence would be
invisible, because a suite full of vacuous assertions is indistinguishable from a healthy one by
every other measure.

---

## 5. What the gate cannot do

**It must run offline**, which excludes any check that asks the chain. That has a real cost. The
consumer registry is generated *from* the chain, but the guards on it compare it to a copy of
itself — so after a deployment the artefact stays as generated, every guard reports "in sync",
and everything derived from it agrees with itself about the **previous** surface.

A separate tool asks the chain directly and records a dated sidecar. The gate then prints **when
the snapshot was last confirmed against mainnet** — a date, not a verdict, and it says so when the
artefact has been regenerated since:

```
registry: last confirmed against mainnet 2026-09-27 ... the artefact has been
regenerated since; rerun _registrylive.py
```

That is the right shape for a check that cannot be authoritative: report the staleness rather than
imply freshness.

**It cannot check meaning.** Every one of the 31 checks asks a structural or mechanical question.
None of them can tell that a correctly-shaped call names the wrong entity.

**And it is not free.** Five minutes of sixteen cores is enough that people avoid running it,
which is precisely how it goes red without anyone noticing. Which brings us to the thing that
happened while this chapter was being written.

---

## 6. The gate was red, and had been for three sessions

Running `--audit-only` to gather figures for this chapter produced:

```
TOOLS.md is STALE: 83 tools on disk, index does not match.
GATE FAILED: TOOLS.md does not index every tool on disk.
```

Four tools were missing from the index. All four had been written for **this documentation
project**, across three sessions. The rule — *regenerate the index after adding a tool* — is in
the index file's own header.

Nothing had been asking. The check worked perfectly and caught the problem the first time it was
run; it simply had not been run, because the full gate is expensive and the cheap half was not
being used as the routine it should be.

There is no clever lesson here, which is why it is worth including. **A check nobody runs is
exactly as useful as a check that does not exist**, and the failure mode is entirely social.

---

## 7. And this chapter miscounted the checks

The count in §3 was wrong when first written. The figure was **29**, produced by extracting every
tool path from the runner's source:

```bash
grep -oE 'tools/_[a-z0-9]+\.py' REPL/tools/_gate.py | sort -u | wc -l   # 29
```

Twenty-nine literal paths, correctly found. But two checks are invoked through **string
concatenation** rather than a literal:

```python
for _tool, _why in (("_conformance.py", ...), ("_heavy.py", ...)):
    subprocess.run([sys.executable, "tools/" + _tool, "--check"], ...)
```

A pattern matching `tools/_something.py` cannot see a path that only exists at runtime. The real
number is **31**, and the two it missed are the conformance checker — the subject of the previous
chapter — and the heavy-read detector.

This is the same defect class the gate exists to prevent, committed in the act of describing it:
a measurement whose method was narrower than its claim, reported as a fact. It is recorded rather
than quietly corrected because the alternative is a chapter about verification that conceals its
own.

The general form appears throughout this project, and is worth stating plainly:

> **A count is meaningless without the rule that produced it.** The rule is exactly what gets
> lost when a number is quoted onward.

---

## Where to go next

- `01-stoicsyntax.md` — the naming system the structural checks depend on
- `02-semi-self-auditing.md` — what those checks can and cannot decide
- `04-what-went-wrong.md` — the failures, including checks that passed while proving nothing

## Sources

- `REPL/tools/_gate.py` — the runner, its exclusions and their stated reasons
- `REPL/TOOLS.md` — the generated index of all 83 analysis tools
- `OuronetInformational/ARCHITECTURE/REPL_AND_TESTS.md` — the test architecture rules

All figures in this chapter are from a measured run on 2026-09-29, not from record. The 31-check
count was corrected after the method that produced 29 was found to be narrower than the claim.

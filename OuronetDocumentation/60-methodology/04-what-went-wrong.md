# What went wrong

The previous chapters describe checks that work. This one is about the times they did not — and
specifically about the ones that **reported success while proving nothing**, because those are the
only failures that teach anything general.

A bug that breaks a test is a normal day. A check that passes for a reason unrelated to the
property it claims to verify is a different kind of problem: it consumes the attention that would
otherwise have found the bug, and it does so indefinitely.

This chapter is in the documentation deliberately. A system claiming to be semi-self-auditing owes
the reader the cases where the auditing failed.

---

## 1. The verifier that fixed what it was checking

A tool regenerated the pricing artefacts and compared them to what was committed. It was wired
into the gate, and the first full run after wiring was green.

It could not have been anything else. The argument dispatch read:

```python
check("--check" in sys.argv)      # ...whose parameter was `write`
```

So `--check` passed `write=True`. **Verify mode silently rewrote the artefacts, then found no
drift.** The tool's own post-mortem, written at the site:

> "A checker that resolves drift by overwriting it is worse than no checker: **it is a green light
> wired to nothing.**"

Nothing about the output distinguished it from a real verification. The fix was two characters;
the lesson is that a checker must be shown failing before its passing means anything. It now
hardcodes `write=False`, and that was proved by re-injecting a known defect and watching the gate
exit non-zero and name the line.

---

## 2. Everything agreed, and all of it was wrong

A second checker verified that several narrative documents quoted the same figures as a generated
statistics file. It was green for weeks.

It verified that *N documents agreed with one source*. It never verified that **the source agreed
with the tree**.

When the loop was finally closed, the statistics file claimed **5,555** distinct assertions
against **5,830** in the tree, and **22,454** executed against a suite running about 25,000. Every
figure in every document matched. All of them were wrong together.

> "A consistency check between N documents and one source proves the N documents consistent. It
> says nothing whatever about the source, and **a stale source reads exactly like a correct one —
> *more* convincingly, because everything agrees.**"

That is the sharpest sentence in this project's failure record. Agreement between derived
artefacts is not evidence. It is the expected outcome whether the source is right or wrong.

### The same day, the same shape, inverted

A sibling tool computed a total by summing three categories and silently dropping a fourth. The
sheet listed **442** rows and published **431** — and the artefact checker *required* the prose to
quote that wrong total.

> "**The gate enforced the undercount, and anyone correcting the prose to 442 would have turned it
> red.**"

One tool enforced a number that was wrong; the other enforced a number that was unchecked. Both
were green, and both would have stayed green indefinitely.

---

## 3. Checkers that covered part of a class and read as covering the class

A figure-consistency tool checked **three** sites out of **nine**. Four of the six it skipped were
stale — and two of those sat *directly beneath* rows it was checking.

> "**A checker that covers some rows of a table reads, to anyone glancing at it, as covering the
> table.**"

A preview-coverage tool reported a **perfect score**: 401 declared, 401 named in a test, 401
measured, 0 never named. It scanned three hardcoded files. Discovering the population instead of
listing it found fourteen more previews, and the true figures:

| | reported | actual |
|---|---:|---:|
| declared | 410 | **423** |
| measured | 401 | **413** |
| **never named by a test** | **0** | **1** |

> "A hardcoded list cannot report its own incompleteness, so it reports **clean** about what it
> never opened. Here it reported a **perfect score**, which is worse — **a perfect score ends the
> enquiry.**"

That single uncovered preview turned out to quote **88× the real cost** on the ordinary case.

---

## 4. A zero from a tool that examined nothing

Moving the analysis tools into a subdirectory broke eleven of them, and they broke in three
distinct ways:

| symptom | why it survived |
|---|---|
| errors out with a wrong diagnosis | the message blamed the user's working directory, so following it never helped |
| **runs, reports a clean zero** | nothing about the output looked wrong |
| prints nothing at all | silent |

The middle one is the dangerous shape. A tool invoked a second script through a path that no
longer existed; the failed subprocess returned empty output, and empty became the reassuring zero.
The real figure was **120 orphans examined**. The conclusion happened to survive re-measurement —
but "it was unfounded for two days and presented as measured."

> "*A zero from a tool that examined nothing is the most expensive kind of green.*"

**And the checker built in response to that incident could not see it.** A path-validation tool was
written precisely because of this move, was validated against it (correctly reporting 11 of 11 on
the broken tree), and **reported clean while three tools were still dead** — because it modelled
the ways a Python file opens another file, and not the way one *invokes* another.

A check validated against the incident that motivated it will pass on that incident. That says
nothing about the neighbouring case.

---

## 5. One comment can hide an unbilled operation

A tool searched for a function name and reported zero sites to review — twice, while real defects
sat in the tree. Two independent bugs: it matched **prose**, because the name appears inside
documentation strings, and it required a cross-module call syntax that most real calls do not use.

The class was then measured rather than assumed. **Eighteen** of the Pact-analysing tools had no
comment handling at all:

| token | real uses | exists only in comments |
|---|---:|---:|
| the collector name | 508 | **26** |
| the cost-reader prefix | 1,578 | **45** |
| `with-default-read` | 260 | 11 |

Most of that is harmless inflation. One case was demonstrated to be dangerous. A check exists to
find *an operation that builds a bill and never charges it* — and it was unit-tested by adding a
single comment near the code:

```pact
;;NOTE: the caller does (ref-IGNIS::C_Collect patron ico)
```

That flipped the result from **flagged** to **hidden**. One comment, mentioning the thing the
scanner looks for, conceals an unbilled operation.

> "A scanner that cannot distinguish code from commentary is not wrong yet; **it is wrong as soon
> as someone documents the thing it is looking for** — which, in a codebase that annotates its
> defects in place, is the most likely sentence anyone will write near it."

---

## 6. The shadowed gate

This one produced an owner ruling, and it is the clearest security-relevant example in the
project.

A capability both **authorises** (is the caller an admin?) and **validates** (is this request
sensible?). One had them in this order:

```pact
(enforce (< treasury-supply 0.0) "Cannot Wipe Positive Treasury Balance")   ;; business rule
(compose-capability (GOV|DPTF_ADMIN))                                       ;; authorisation
```

A solvent treasury is the normal state. So **every** attempt — admin or stranger — was refused by
the business rule, and the admin gate was never reached.

> A red-team test could report "a non-admin was refused" and be **telling the truth while proving
> nothing**: had the admin capability been deleted entirely, the test would still have passed.
> **A shadowed gate is indistinguishable from an absent one from the outside.**

The ruling was: authorisation first, before any business rule.

### The sweep's scope was narrower than the rule it implemented

The fix was swept across the sites that matched a specific pattern. Two years of this project's
habits then produced the useful part: someone re-scanned **all 989 capabilities** against the rule
*as written* rather than as implemented, and found two more — **both in the same module as the
original**, one reproducing its shape exactly.

The two sat ten lines apart from a correctly-ordered twin:

> "`01_DALOS.pact` held both the swept shape and the missed shape ten lines apart, and **nothing
> short of a scan tells them apart by reading.**"

### And the count depends entirely on what you mean

The same tree, the same question, four defensible definitions of "authorisation":

| definition | sites |
|---|---:|
| the sweep's literal scope | 2 |
| including ownership gates | 62 |
| …restricted to state-reading shadows | 36 |
| a detector written the same day, same intent | 50 |

> "**A headline of 'N ordering violations' would have been a property of the detector, not of the
> contracts**, so none is published as a defect count."

### Why the remedy was not a blanket reorder

Reordering exposes only one of two state-dependent guards at a time — it moves the problem rather
than removing it. Two existing tests *depend* on the current order to reach an argument check
without a signature; hoisting the ownership gate would make those unreachable instead.

**A fixture that satisfies the first guard exposes both.** Ordering is a proxy for testability:
neither necessary, nor free.

The substantive finding was not the ordering at all. Four ownership gates sat behind a latched
flag, and exactly **one** had ever been reached by a non-owner. The other three had *never once
been shown refusing anybody*.

The programme that followed is the right way to close such a thing:

| | before | after |
|---|---:|---:|
| ownership gates reachable from a named operation | 112 | **167** |
| actually observed refusing someone | 19 | **84** |
| **shadowed and never witnessed — testable** | **23** | **0** |

And the sharpest technique in it: where the fixture's signature made a refusal ambiguous, the
remedy was to **move the role to a different account** — so the owner, still the owner, is refused,
naming the new role-holder. **An owner gate cannot refuse the owner**, so a test where it appears
to is testing something else.

---

## 7. Tools that damaged the tree

Three incidents, escalating.

**Importing a tool ran it.** Five one-shot migration scripts mutated source files *at module
level*, with no main guard. A loop that imported each one "just to prove it loads" fired all five
and **silently deleted 111 lines of schemas** from a contract.

> "**Reviving a dead mutator is not neutral**: it turns an inert file into a loaded one, and a
> one-shot migration script does not stop being a weapon just because its job is finished."

The rule adopted: *never run a tool to find out what it does.* Read its docstring.

**The rule was given to the five, not to the class.** Two formatters still rewrote the tree on a
bare run. A later census that ran every tool to find out which were alive did exactly what the
instructions forbade: **188 files, 16,457 insertions.**

> "Nothing was lost, because the tree was committed. **'The tree was committed' is not a safety
> property** — it is a description of luck at that moment."

**And the formatter corrupted code.** The standing warning said the risk was duplicate banners
from running two tools. It was worse. Applied and gated: **186 files, five suites broken,
assertions 25,029 → 24,711, reverted.**

Two defects. It inserted a test-harness directive into an inline module definition — which failed
loudly. And it inserted markers **inside multi-line expressions**, splitting one between an
assertion's arguments.

> "**The second defect is the dangerous one.** A banner inserted between an expression's arguments
> fails loudly *only when the result no longer parses* — and an insertion that happens to leave a
> parseable form would change what the expression **means**, silently, across 186 files. The gate
> caught this instance. Nothing guarantees it catches the next."

The root cause was that the tool scanned lines while the repository already owned a
paren-balancing library that every other tool uses for exactly this reason.

The fix was verified by re-running the failed experiment:

| | before fix | after |
|---|---|---|
| files changed | 186 | 186 |
| suites broken | **5** | **0** |
| gate | FAILED at 24,711 | **GREEN at 25,029** |

> "**25,029 is the same count as before the tool ran at all.** That identity — not the green — is
> the evidence that 186 files of insertion changed no behaviour."

And a coda that belongs in this chapter more than the incident does. The author wrote *"a bare
`--apply` is now a no-op"* into the project's instructions **and published it without testing it**.
Tested afterwards: a second run added **5,738 duplicate lines across 167 files**.

The commit message reads: *"Make the formatter idempotent — found by testing a claim I had already
published."* And it corrected a warning that had blamed the wrong cause for a month: the
duplication was never about running both tools. Running the **one** tool twice did it.

---

## 8. A rename outruns the tools that grep for the old name

The gas collectors were renamed. The price-sheet generator matched the old name, which no longer
existed anywhere in the tree.

**Nothing failed.** Three wrappers simply stopped being recognised and fell through to a generic
case, so the sheet quietly stopped naming the cost reader holding their real price.

> "A price sheet that drops an entrypoint silently reports as complete **while a client can still
> call them and be charged.** A rename pass has to carry the **tools** that grep for the old name."

The same tool had the same class of defect a second time, from a hardcoded interface *version*.
An interface bump stopped it matching, and one operation **silently changed classification** —
the tally moved from `199 floor / 50 exempt` to `200 / 49`.

> "A tool keyed to an interface version mis-prices on every future bump and does it quietly: the
> sheet regenerates, the artefact check passes against the new file, and **only the tally moves.**"

---

## 9. An error reproduced in a test harness is an error in a test harness

A note was written with real confidence:

> "**This is not a sandbox artefact.** These six functions — the primary entry points for the
> explorer and the dashboard — have never been callable by anyone, on any chain, including
> mainnet."

It was measured, reproducible, and wrong about the thing that mattered.

Pact restricts cross-module table scans in **transactional** mode. The local harness is *always*
transactional and structurally cannot be put into the other mode — the relevant flag is a node
setting the harness rejects. Production nodes run with it enabled, and these functions are only
ever invoked as read-only queries.

**Every observation came from the one execution mode these functions never run in.**

> "**An error reproduced in a test harness is an error in a test harness.** Before calling it a
> production defect, establish that production runs in the same execution mode the test used."

That became a standing question on the finding template: *in which execution mode and which chain
state did I observe this, and is production ever in it?*

Two details from the same investigation are worth carrying:

**The first error absorbed the blame.** Pact's `let` is eager, so a stale-identifier failure fired
*in the bindings* and the function never reached the scan. An earlier note concluded the right
thing about the first blocker and the wrong thing about the function, "because the investigation
stopped at the first error message."

**And the probe lied.** Wrapping a call in `try` puts the database in read-only mode, so the probe
produced *its own* error rather than the code's — while a simpler probe under the same `try` was
fine, which is exactly why the earlier ones looked trustworthy.

---

## 10. The pattern

Nineteen incidents were examined for this chapter. They are not nineteen kinds of mistake. They
are roughly four, repeated:

**A check whose method is narrower than its claim.** Three files instead of a discovered
population. Three table rows instead of nine. Literal paths instead of constructed ones. Sovereign
directories instead of the whole tree — where a tool reported **89** entrypoints against a real
**482**, because its filter was blind to every function in the one client-facing layer. (That
surface is **776** today; 482 was correct when the error was found, which is why the corrected
instruction reads *"trust the tool, and check the tool"* rather than naming a number.)

**A green result that was never shown to be capable of red.** The verifier that rewrote what it
checked. The mutation test that reported "no change" from a patch that replaced **zero
occurrences** — indistinguishable from a mutation that never happened.

**Agreement mistaken for evidence.** Documents matching a stale source. A total that reconciled
because two off-by-one errors compensated — "a total that reconciles is the reason nobody
re-counted the parts."

**A figure that outlived its measurement.** A registry of justified exceptions where five entries
had **outlived their sites** — the tool checked that a registered expression still matched the
source, and never asked whether the site still existed. A site that gains a real value is skipped
by the scan, so those five were never consulted again while the tool reported *"every slot is
registered."*

> "An entry with no site is a **written excuse bound to a location**, and the next function to
> reuse that location inherits it."

They were found by an orphan check added the same day, **not by anyone reviewing the list**.

---

## 11. What this chapter is for

The instinct is to present a system's checks and omit their failures. That produces a document
that is useless precisely when a reader most needs it — when deciding whether to believe the
green.

The honest position is narrower and more useful: **these checks catch structural mistakes
reliably, and they have failed silently often enough that a green result is evidence about the
checker as much as about the code.** Every incident here was found by measuring something that
had previously been asserted. None was found by reading carefully.

That is the actual method, and it is more mundane than "semi-self-auditing" sounds. Re-derive the
number. Break the thing and check the check goes red. Ask what population the tool actually
opened.

Two small verifications while writing this chapter make the point better than the argument does.
A researched brief flagged a sixth unguarded mutating tool and a possibly-diverged second copy of
the defect ledger. Both were checked: the tool only reads and prints, and the second copy **does
not exist**. Two plausible findings, neither real, and the cost of checking was one command each.

The third flag reported a registry count of **8** where this project's instructions say **19**.
Both are correct. The tool scans **19 sites** and carries **8 registered exceptions** — different
populations, both called "entries" in prose. Which is, once more, the same lesson:

> **A count is meaningless without the rule that produced it.**

---

## Where to go next

- `01-stoicsyntax.md` — the naming system
- `02-semi-self-auditing.md` — what the checks decide
- `03-the-gate.md` — what runs, and what it costs

## Sources

- `Audit/records/DEFECT-LEDGER.md` — the full ledger; sections cited throughout
- `OuronetInformational/memories/` — dated incident captures written at the time
- `REPL/RedTeam/` — 14 adversarial suites
- `CLAUDE.md` — carries its own dated corrections, several quoted here

Two figures in this chapter are **self-reported and not reproducible from version history**: the
188-file census and the 111 deleted lines were both reverted before being committed. Each is
corroborated by two independent in-tree sources written at different times, including safety
guards added to the tools themselves. They are marked here rather than presented as measured.

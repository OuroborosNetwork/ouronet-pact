# Part II · Chapter 4 — The test-architecture round

> Source records: `ARCHITECTURE/REPL_TEST_ARCHITECTURE.md` (the model),
> `ARCHITECTURE/REPL-ROUND-REPORT.md` (the round's own report),
> `ARCHITECTURE/REPL_SUITE_STATS.md` (generated), `ARCHITECTURE/REPL-TEST-LEDGER.md` (generated),
> `REPL/modules/README.md`, and `REPL/tools/_gate.py` — which is the gate.

The audits in Part I kept finding the same thing: functions with **zero** REPL coverage, and real
bugs living in them precisely because nothing called them. ATS finding `#22L` alone named twelve
untested configuration functions and two live bugs inside them. Phase 1.5 is the phase that closed
that, and rebuilt the runner architecture around the result.

---

## 1. What was built, in size

**[VERIFIED by command]** — `git archive <rev> REPL | wc -l`, and the same `(expect…)` regex
`REPL/tools/_suite_stats.py` uses for its own "distinct assertions written" row:

| | 2026-08-30 | 2026-09-04 | 2026-09-09 | 2026-09-14 | 2026-09-16 | HEAD |
|---|---:|---:|---:|---:|---:|---:|
| `.repl` files (excl. `archive/`) | 181 | — | — | 209 | — | **{{fig:repl_files}}** |
| `.repl` lines (excl. `archive/`) | 68,435 | — | — | 120,603 | — | **{{fig:repl_lines}}** |
| distinct assertions | **1,604** | 1,663 | 2,431 | **5,262** | 5,555 | **{{fig:assertions_distinct}}** |

<sub>CORRECTED 2026-09-18 — the HEAD column was written as literals and had rotted. It published
**128,567** `.repl` lines, which was true around 2026-09-17 and is roughly nine thousand short
today. All three HEAD cells are now build-time macros. The two size macros carry
`_scale_report.py`'s counting rule, reaching this chapter through `REPL_SUITE_STATS.md`; that rule
differs from the historical columns' `git archive … | wc -l` by about twenty lines. Much smaller
than the drift it replaces, but not zero, and worth knowing before reading the row as one
measurement.</sub>

The suite roughly **3.3×'d** across the round, and most of that arrived between 2026-09-09 and
2026-09-14 — the guard-pinning phase, which is the bulk of the work by volume.

One fifth of the suite is comment, and the round's report argues that is a design decision rather
than slack. The argument is testable and this book accepts it, because the mechanism is stated:
several defects in the round were found **while writing the explanation**, because stating precisely
what an assertion proved exposed that it proved nothing.

---

## 2. The model: three suites, six gates

The architecture document's opening distinction is the one that organises everything else:

| suite | asks | derived from | can it be complete? |
|---|---|---|---|
| **NORMAL** | does the specified behaviour work? | the spec / the op list | **yes** — every entrypoint, exercised |
| **ADVERSARIAL** | is every door we built actually locked? | **the code itself** — every `enforce`, every defcap | **yes** — it is enumerable |
| **RED TEAM** | is there a door we forgot to build? | attack hypotheses | **no** — open-ended |

The middle one is the insight. An adversarial suite is *derivable*: list every `enforce`, write an
`expect-failure` proving it rejects, and when the count matches, that suite is provably finished.
Red teaming cannot be derived that way, because the bug it looks for is an **absence** — and you
cannot derive what you forgot from the code that forgot it. The document says so in one sentence
that belongs in this book:

> *Reaching 100% adversarial coverage does NOT mean the code is secure — it means every lock we
> installed has been tested. It says nothing about the doors we never built.*

That is also why **RULE 3** is stated without an exemption category: *an `enforce` you cannot write a
failing test for is dead code — delete it.* There is no "unreachable, skip it" bucket. Either a
caller can violate the condition, or the guard is noise and its removal makes the guarantee clearer.

The six gates, each a number recomputable from a script. **[VERIFIED by reading]** the generated
statistics of 2026-09-16 and the architecture document's own order-of-work block:

| gate | asks | at 2026-09-09 | now |
|---|---|---|---|
| **G1** Surface | every Talos entrypoint invoked **inside its own module tester** | ~65% | **448 / 448 = 100%**. It read 447 until 2026-09-18, and the missing one was the ledger's blind spot, not a gap in the suite (§5) |
| **G2** Adversarial | every `enforce` / defcap rejection has an `expect-failure` | 293 tests / 1,015 sites = 29% | **live unpinned = 0**; 709 pinned unambiguously, 766 including shared wording |
| **G3** Determinism | every test passes standalone **and** inside the full run | — | every module tester boots its own environment; the gate runs them as separate processes |
| **G4** Conformance | every rule the architecture *states* is proven to hold | 44 deviations / 4,919 defuns | **violations 0**, observations 114 |
| **G5** Doc claims | every `@doc` stating a RULE has a test proving it | 100 unverified | **0 left** — scoped at ~100, the real worklist was 19 |
| **G6** Function reach | every client-reachable function is exercised | 3,230 / 4,498 = 72% | **3,826 / 4,525 = 84%**, 699 never reached |

<sub>CORRECTED 2026-09-18, re-measured by running the instruments rather than by reading the
2026-09-16 generated statistics this table originally quoted. The "now" column used to read **G1
448 / 448 = 100%**, **G2 live unpinned = 1** (707 unambiguous, 763 including shared wording), and
**G6 3,816 / 4,524 = 84%, 708 never reached**. G2 and G6 simply moved: the last live unpinned guard
was pinned, and the tree gained one client-reachable function while nine more were reached.

G1 never moved at all, in either direction. It read 100%, then 447/448, then 100% again — and the
suite drove every entrypoint throughout. The dip was a defect in the measuring tool, found on
2026-09-18 and repaired the same day; §5 has it. It gets a section because a coverage number wrong
in the **pessimistic** direction is the harder kind to notice: nobody investigates a number that is
asking for more work, and a figure that has quietly *understated* coverage for months will be
believed indefinitely. None of these four figures has a live-figure macro behind it, so all four are
snapshots and will rot again. That is §7.1's subject.</sub>

**G2's denominator, stated rather than assumed.** The "live unpinned = 0" figure is conditioned on
three exclusions that the generated statistics list beside it, so the subtraction is visible rather
than taken on trust: **24** guards in the dead `00_DPMF` module, **40** unreachable inside an
`enforce-one`, and **31** proven unreachable by hand and annotated. All three counts re-derive
unchanged on 2026-09-18; only the headline moved, from 1 to 0. A zero needs its exclusions stated
more urgently than a one did, because a zero is the number a reader stops interrogating. An excluded
guard is not reported as a gap — and the project's own rule for the third bucket is the thing that keeps it honest: *every
`;;UNREACHABLE` annotation is backed by a test that drives the route to whatever wall actually stops
it and reads the message that comes back.* That is what turns an annotation from a claim into a
regression trip-wire.

**G5 is the one most projects do not have, and it can fail in a way G2 cannot.** G2 asks whether the
guard we wrote works; G5 asks whether the guard we **promised** exists at all. Closing it found two
*vacuous existing proofs* — shared-graph equalities that short-circuited on OURO and never read the
graph argument they were written to test.

**G6 is the one that is not closed, and the round says so.** The target was ~93%; the measured
position is 84%, with **699 client-reachable functions never reached**, concentrated in per-field
readers and internal constructors. The round report files it under *"Remaining, and deliberately not
closed here"*, which is the correct disposition and the correct place for it.

---

## 3. The gate

`python3 REPL/tools/_gate.py`. It resolves its own paths and `chdir`s to its own directory, so it
runs from anywhere. **[VERIFIED by reading]**, it does four things in order.

### (a) It refuses to start on a dirty workspace

Any `modules/_*.repl`, `RedTeam/_*.repl`, or non-`_verify_finding_` `Kursan/_*.repl` fails the gate
immediately. `modules/` is globbed into the entrypoint list, so a forgotten iteration probe becomes a
real entrypoint — which happened, and failed the gate 200 seconds in with a message about wrong
expected strings rather than about a leftover file.

### (b) Fifteen static checks, every one fatal

**[VERIFIED by reading `_gate.py`]** — fifteen tools are invoked as `--check` subprocesses, and
**every one of them `sys.exit`s the gate on a non-zero return**:

| check | what a failure means |
|---|---|
| `_stagez_variant --check` | the generated Stage-Z testing variant is stale against canonical — *"the STAGE-Z assertions are testing a stale copy and would still go green"* |
| `_ladder --check` | a citizen minter's batch ladder does not tile its collection — gap, overlap, or a rung over the per-transaction gas budget |
| `_colproj --check` | a projecting `read` names a column its own table's schema lacks |
| `_redteam --check` | a `RedTeam/` block has a malformed or duplicate attack header — *"a shrinking register looks exactly like a clean one"* |
| `_figuresync --check` | an audit document quotes a figure the generated statistics do not support |
| `_pricesync --check` | a generated pricing artefact does not match its generator ({{ch:pricing}} §5) |
| `_toolpaths --check` | a tool hard-codes a path that no longer resolves |
| `_prefixsync --check` | a function prefix live in the tree is unknown to the tooling's vocabulary |
| `_eagerlet --check` | an `enforce` is shadowed by an eager hard read in the same `let`, and nobody has annotated it |
| `_booktables --check` | a headline table in this book does not sum to its own total, or disagrees with the attack register |
| `_auditbook --check` | the assembled single-file book is stale against its chapter sources, or a source writes a chapter number as a literal |
| `_modref --check` | a `(ref-X::member …)` call where `member` is defined **nowhere** in the implementing module |
| `_vacuous --check` | a positive assertion that **cannot fail** |
| `_conformance --check` | an architectural conformance **violation** (observations stay advisory) |
| `_heavy --check` | a single-prefixed `C_`/`A_` whose tree reaches a heavy scan |

<sub>CORRECTED 2026-09-18. This section was headed *"Twelve static checks"* and said that exactly
twelve tools implement `--check` and that all twelve are gated. Three were missing — `_eagerlet`
(`_gate.py:368`), `_booktables` (`:380`) and `_auditbook` (`:392`), all three fatal. The last two
arrived with this book's own generator, so the chapter describing the gate was out of date about the
check that exists to keep the chapter honest. The wording was wrong in a second way that caused the
first: *"of the tools in `REPL/tools/`, exactly twelve implement a `--check` mode, and all twelve are
run by the gate"* fuses two different counts into one number, and a fused count cannot show which
half has drifted. What is stated now is the second question alone, read off `_gate.py` — which is
also why a sixteenth tool implementing `--check` tomorrow would not make this sentence wrong, only
incomplete.</sub>

Two of these deserve a sentence each. `_modref` exists because **Pact 5 resolves modref members
dynamically**, so a call to a member that does not exist loads and runs and only raises if that
branch is taken — invisible to every other check. And `_conformance` / `_heavy` were **added as gate
checks on 2026-09-14 after a verification pass found their "0" was a hand-measured figure**: the gate
byte-compiled them and ran one selftest, but never ran either tool, so re-introducing a defect that
had been *verified exploitable* before it was fixed would have left the gate green.

### (c) Tool integrity

Every `_*.py` in `REPL/tools/` is byte-compiled, and `--selftest` is run on the nine that have one.
<sub>CORRECTED 2026-09-18: this said **ten**. Nine `_*.py` in `REPL/tools/` contain `--selftest`
once `_gate.py` itself is excluded, and the gate excludes itself explicitly. Ten is what you get by
grepping the directory without that exclusion — counting the gate as one of the tools it checks.</sub>
This exists for a specific reason: an edit to `_conformance.py`'s rule text left an unescaped quote
inside a string, **and the gate went green twice while the conformance checker could not start.**

> *A tool that cannot run is worse than a missing tool, because its silence reads as clean.*

### (d) The orphan check, which is the load-bearing one

The gate computes the transitive `(load …)` closure of all 92 entrypoints and **fails if any `.repl`
containing an assertion is outside it** and not on an 18-entry exclusion list, each entry of which
must carry a reason. *"It is slow" is not a reason; "it is an alternative path to something already
gated" is.*

This exists because it was missing. Four `deb-staleness-*` drivers were archived on an
"assertion-free" heuristic — true of the drivers, false of what they *load* — and they were the only
path to an entire AQP suite family. **~125 assertions silently left the suite and the ledger never
noticed, because the ledger counts files, not execution.**

### What the gate actually runs

**[VERIFIED by command]**, reconstructing the entrypoint list from `_gate.py` without running it:

```
 7  named runners  (ZALL, AQP-FULL, AQP-core-vct, triplet-collect-golden,
                    launchpad-groundtruth, Stage00b_Run, Stage00b_RunGas)
 4  deb-staleness-*.repl
34  modules/*.repl          (the per-module standalone testers)
14  RedTeam/*.repl          (globbed, so a new attack is gated the day it exists)
27  Kursan/                 (scale + finding-verification harnesses)
 6  named _scratch_ audit proofs
──
92  entrypoints
```

The report's measured parallel economics: **6,386 seconds of work serial — 1 hour 46 minutes —
completing in ~427 seconds wall on 16 workers, a 15.0× speedup.** The speedup is deliberately
sub-linear and the bound is stated: **wall time can never fall below the slowest single entrypoint**,
and `ZALL.repl` alone is ~354 s of the ~375 s total. Adding workers past 16 buys almost nothing.

That ratio is not a performance note. It is the difference between running the gate once a day and
bisecting a regression across twenty edits, and running it after every coherent change so the
regression names itself. Most of what this round found was found in the second mode.

---

## 4. "One command tests the entire system" — what that actually means

Roadmap step **1.5.1.3** asks for a *"single comprehensive run — the whole codebase, one boot… one
hermetic run that boots once and exercises ALL Pact code."*

**[VERIFIED by command]** — computing the transitive `(load …)` closure of `ZALL.repl`, the one-boot
runner, and intersecting it with the set of `.repl` files that contain assertions:

| | |
|---|---:|
| asserting `.repl` files in the suite (excl. `archive/`) | **149** |
| …inside `ZALL.repl`'s closure | **34** |
| distinct assertions in the suite | **5,804** |
| …inside `ZALL.repl`'s closure | **1,437 (25%)** |

<sub>The 5,804 here excludes `archive/`; §1's {{fig:assertions_distinct}} is the project's own `_suite_stats.py` rule, which
walks all of `REPL/` including the 68 archived files. Same corpus, two denominators — quoted
separately rather than reconciled, because each is the right one for its own question.
CORRECTED 2026-09-18: these four rows read **148 / 34 / 5,747 / 1,434 (25%)** when the chapter was
written on 2026-09-16, and drifted with the suite. What did **not** move is the pair the section's
argument rests on — the closure is still 34 files and still 25% of the assertions — so the one-boot
runner has taken on none of the suite's growth.</sub>

So the single-boot runner exists, is gated, deploys the entire stack in dependency order, and carries
**about a quarter of the suite's distinct assertions.** The other three quarters live in the 34
module testers, the Kursan harnesses, the 14 red-team files and the named runners — each of which
boots its own environment.

**The goal was met by a different mechanism than the one specified, and the substitution is a good
one.** One command does test the entire system: it is `_gate.py`, and it is a 92-way parallel run
rather than one boot. The reason it is better is the reason the parallelism rule exists — a single
hermetic boot is bounded by its own serial length, and at 354 s for a quarter of the assertions, a
one-boot run of the whole suite would be the 1-hour-46 figure. But the roadmap step is not ticked and
nothing in the tree records that it was consciously superseded, so a reader checking whether "one
boot exercises all Pact code" would conclude, correctly, that it does not.

The two figures should not be conflated the way they have been elsewhere: `DEPLOY-READY-GATE.md`
cites *"`ZALL.repl` … runs 787 assertions green"* as the proof of deploy readiness. That is a true
statement about deployment order — ZALL does deploy the whole stack fresh — and it is 787 of what
was then a much larger suite. **Deploy-order proof and coverage proof are different claims and ZALL
only carries the first one well.**

---

## 5. The entrypoint surface, independently reproduced

`REPL-TEST-LEDGER.md` is generated by `REPL/tools/_test_ledger.py`. Running that generator on
2026-09-18 reports:

| metric | value |
|---|---:|
| client entrypoints (the auditable contract) | **448** |
| exercised at least once | **448 (100%)** |
| **exercised by a file the gate runs** | **448 (100%)** |
| exercised only in an ungated file | **0** |
| **never exercised** | **1** — `P\|A_AddIMP` |
| exercised but with **no adversarial assertion in any of its blocks** | **170** |
| total invocations across the suite | 3,649 |

**[VERIFIED by command]** — parsing every `ENTITY|C_`/`CC_`/`A_`/`AA_`/`Cp_`/`CCp_` defun from the
eleven Talos modules gives **482 definitions and 448 distinct names**, with 7 names defined in more
than one Talos file. The ledger's denominator reproduces exactly.

<sub>CORRECTED 2026-09-18. This table published **448 (100%)** exercised, **448 (100%)** gated and
**289** without an adversarial assertion — and the sentence that used to close the section said
`REPL-TEST-LEDGER.md` *"was last regenerated on 2026-09-14 and is not re-derived by the gate"*, then
quoted that artefact's figures as the current position anyway. Naming a staleness hazard and then
relying on the stale number is worse than not naming it, because the caveat reads to a reviewer as
though it had been applied. The figures above come from running the generator, not from reading the
committed `.md`, and the committed `.md` has not been regenerated since. The 289 had fallen to 167 as
the adversarial phase landed. The 100% is the subject of the rest of this section, because it did not
fall for the reason the ledger gives.</sub>

### G1 read 447 of 448, and the one that was missing was the instrument

> **REPAIRED 2026-09-18.** The one-line fix described at the end of this section has since been
> made. `_test_ledger.py` now accepts `(rollback-tx)` as a block terminator, and G1 reads
> **448 of 448 (100%)**, never-exercised **0**. The section is kept in full, in its original tense,
> because the diagnosis is the valuable part and because it is a worked example of the rule this
> book keeps returning to: **a coverage number is an instrument reading before it is a fact about
> the suite.** What changed was the instrument.
>
> One figure moved in the uncomfortable direction, and it is the reason the repair mattered beyond
> the headline. Entrypoints with **no adversarial assertion** in any of their blocks went from 167
> to **170** — the newly-visible blocks brought three more operations into view whose neighbourhoods
> are asserted only positively. A blind spot does not only hide coverage; it hides gaps, and it
> hides them in the column that matters most for a security suite.

The single entrypoint the ledger reported as **never exercised** was `P|A_AddIMP`. It is worth the
space, because the honest answer is not "an admin entrypoint shipped untested" — it is "the tool that
owns G1 cannot see the test that covers it".

**What `P|A_AddIMP` is.** It appends a guard to the `m-policies` list that `P|UEV_IMC` checks, which
is the mechanism by which one Ouronet module is permitted to call into another — the inter-module
boundary itself. Every Talos module defines its own copy. `P|A_AddIMP` is one of three names, with
`P|A_Add` and `P|A_Define`, defined in **all eleven**, which is most of the gap between the 482
definitions and the 448 distinct names above. The ledger keys its rows by name, so eleven definitions
collapse into one row, and that row is covered the moment any one copy is driven.

**It is driven, twice, in a file the gate runs.** `REPL/modules/LAUNCHPAD.repl` carries the blocks
`LPAD-N7` (`:631-672`) and `LPAD-N7b` (`:676-702`). The first calls `TS02-CPAD.P|A_AddIMP` as a
stranger and asserts that the refusal names the **admin keyset** rather than the attacker's key —
which is what separates "the admin gate refused" from "that signature was rejected". The second calls
it as the admin and asserts the call completes, so the refusal above is the gate and not a function
that is broken outright. That is a bidirectional pin on an admin door, and `modules/LAUNCHPAD.repl`
is one of the 34 module testers in the gate's entrypoint list, so both run on every gate.

**Why the ledger cannot see them.** `_test_ledger.py` attributes invocations by transaction block,
and it finds blocks with the regular expression `\(begin-tx.*?\(commit-tx`. Both `LPAD-N7` blocks
end on `(rollback-tx)`, and `LAUNCHPAD.repl`'s **last** `(commit-tx)` is at `:441`. Everything after
that line — five blocks, `:447-702`, including both `P|A_AddIMP` call sites — matches no block at
all, so it is never scanned. Nothing about the test is wrong; the parser stops reading before it.

**[VERIFIED by command]** — applying the same rule across the suite, the blind spot is not confined
to one file:

| | |
|---|---:|
| non-`archive/` `.repl` files with `begin-tx` blocks after their final `(commit-tx)` | **46** |
| blocks in them the ledger never scans | **350** |
| `(expect…)` forms inside those blocks | **898** |

The error also runs the other way. A rollback-terminated block in the *middle* of a file is not
skipped — the lazy match runs past it to the next `(commit-tx)`, swallowing the following block, so
the two pool their assertion counts and every operation in either is credited with the union. So the
assertion columns are not merely the neighbourhood proxy the ledger honestly declares them to be:
they are a neighbourhood proxy computed over blocks whose boundaries are sometimes wrong in both
directions. And the invocation counts, which the ledger calls *exact*, are exact only over the part
of the corpus it reads.

**The irony is load-bearing.** `LPAD-N7`'s own header says it was written *because* an earlier
enumeration found this exact function at zero coverage — *"FOUND BY COUNTING THE POPULATION, not by
suspecting this function"* — and records why it had never been driven: both of its production call
sites are commented out and labelled "Needed on Mainnet". The test was written, it runs, it is
adversarial, it substantiates a claim `RedTeam/[RT-G]_HostileCitizen.repl:91` had only asserted in
prose. And the counter that motivated it still reads zero. **A coverage instrument that cannot see
the fix it caused will keep asking for the fix.**

This was a defect in `_test_ledger.py`, not in the suite. The repair is one line — accept
`(rollback-tx)` as a block terminator — and it was made on 2026-09-18, along with the tool's own
prose, which described its attribution rule as `(begin-tx … commit-tx)` and so documented the bug as
though it were the design.

**Why the blind spot fell where it did is the part worth keeping.** RULE 9 of this suite requires
that *an `expect-failure` on a state-mutating operation gets its own `(rollback-tx)`*, because
`expect-failure` does not roll back REPL writes. So the suite's own discipline guarantees that
adversarial tests on mutating operations are exactly the blocks that end on `rollback-tx` — which
were exactly the blocks the ledger could not see. The instrument was blind in precise
anti-correlation with where the evidence is densest, and it had been for as long as both rules
existed. Neither rule is wrong; nobody had put them side by side.

### Reading the 167

**Assertions are attributed by transaction block**, credited to every operation invoked in the same
`(begin-tx … commit-tx)`. So the columns measure how well an operation's *neighbourhood* is asserted,
not that an assertion targets it. The pattern the ledger exists to surface sits at the top of its own
gap table: **`P|A_Define`, invoked 58 times with zero positive and zero adversarial assertions in any
block that calls it** — the deploy-time registration every module tester runs and none of them
checks. Raw invocation counts hide exactly that.

<sub>CORRECTED 2026-09-18 — this paragraph named **`ATS|C_ColdRecovery`, invoked 273 times, with zero
adversarial assertions**. It is no longer in the gap table: it now stands at 277 invocations with 21
adversarial assertions in its blocks. The example was retired by the work it was written to demand,
which is the outcome the section wanted. The head of the table today is `P|A_Define` — the third
member of the same eleven-times-defined policy family as `P|A_AddIMP`, and the one the section above
does *not* let off: `P|A_AddIMP` has a bidirectional pin the instrument cannot see, and `P|A_Define`
has 58 invocations and no assertion of any kind.</sub>

---

## 6. What the round found

`DEFECT-LEDGER.md` compiles **131 contract defects** for the REPL round, counted separately from the
adversarial round for a stated reason: 131 is *compiled from project records*, while every red-team
entry was *measured exploit-first*. **Merging them would put two standards of evidence behind one
number.** The largest classes:

| class | n |
|---|---:|
| Guard reachability — mute, shadowed, dead | 36 |
| Pricing — preview versus charge | 17 |
| Client-facing diagnostics | 14 |
| Pricing — mispriced or unbilled operations | 13 |
| State machine, permanently-locked value | 12 |
| Arithmetic, lists, empty input | 10 |

The two largest classes are **pricing** and guard **reachability** — not guard **absence**. The
round's own summary of that distribution is the sentence worth carrying: *the guards in this system
are present and they hold; what fails is the arithmetic around them, and the order in which things
happen.*

Four findings illustrate what kind of testing produced them.

**A vault that stopped paying and could not be restarted from any entrypoint.**
`STOAICO::XI_CollectFor` minted an account's urSTOA unconditionally and guarded only the *delivery*
against a zero amount. A zero-amount mint is refused by `UEV_Amount`, and an account's entitlement is
zeroed by its own first collect — so from its **second** distribution round onward the transaction
aborted while real rewards were owed. All three exits share that core: self-collect aborted, the
admin flush shared the same function, and a new round could not open while the unclaimed count was
non-zero. The proof of the fix is 309.474016486404 wSTOA reaching a staker who could not previously
be paid.

**A defect no `.repl` could ever have caught.** `NOSFERATU::A_Fix01` addressed `Legendary 1 100`
where its twin addresses `1 70` — double-covering thirty positions and demanding a 100-row metadata
list from a ladder built entirely of ≤70 rungs, where 70 is the per-transaction gas budget. The mint
plan is **literals inside one-line wrappers**: a REPL can execute a rung but cannot read a literal,
and nothing executed that family at all. Static property, static instrument — `_ladder.py`, now fatal
in the gate.

**A total failure that deleted its own evidence.** `AOZ::UR_NonFungible` projected `"sf-asset"` — the
*SemiFungible* column — from the NonFungibles table. Pact does not reject an unknown projected
column; it returns `{}` and fails one call later as `Key "sf-asset" not found in object: {}`, which
reads like a missing **row**. Because it failed for every input, the function was never usable, so no
test was ever written against it: **the defect and the evidence for it disappeared together.** The
registry was write-only through its public interface. Swept afterwards: zero further instances, and
the sweep was mutation-tested against the known one before its zero was trusted.

**An operator instruction that was exactly backwards.** `GOV|MIGRATE` requires the Global
Administrative Pause to be **on**, and told the operator it must be **off**. One word; the logic was
always right; anyone following the message would disarm the pause and retry forever.

### Instruments built during the round

Each was built the moment a defect revealed a class, and **each was mutation-tested against the
defect that motivated it** — the bug is reintroduced, the tool must report it, the bug is reverted:

| tool | the class it makes impossible to reintroduce |
|---|---|
| `_ladder.py` | a minter batch ladder that mis-tiles its collection |
| `_colproj.py` | a projecting `read` naming a column its own table lacks |
| `_info_measured.py` | an `INFO_` preview *named* by a test but never *measured* against a charge |
| `_infostoa.py` | a preview claiming STOA-free whose execution tree reaches `STOA\|C_Collect` |

> *A clean report from an unverified scanner is indistinguishable from a broken scanner.*

---

## 7. Where the verification has holes

This is the section the chapter exists for.

### 7.1 The coverage instruments are snapshots, not gates

**[VERIFIED by command]**. Fifteen tools are run by the gate as fatal `--check` subprocesses
(§3(b)). The instruments that produce this chapter's *coverage numbers* are not among them, because
they have no `--check` to run:

| instrument | the number it owns | gate-enforced? |
|---|---|---|
| `_scale_report.py` | G6 function reach (84%, 699 unreached) | **no** |
| `_enforce_coverage.py` | G2 guard pinning (live unpinned = 0) | **no** |
| `_info_measured.py` | the Phase-1.2 headline ({{fig:previews_measured}} / {{fig:previews_client}}) | **no** |
| `_expectfail.py` | assertion strength (1,296 of 1,297 sites message-checked) | **no** |
| `_docclaims.py` | G5 documented claims | **no** |
| `_cheapseam.py` | the zero-fixture guard seam (exhausted) | **no** |
| `_test_ledger.py` | G1 (448 / 448; §5 for why it read 447 until 2026-09-18) | **no** |
| `_infostoa.py` | previews falsely claiming STOA-free (0) | **no** |

<sub>CORRECTED 2026-09-18. Five of these rows carried figures that have since moved — they read
**708 unreached**, **live unpinned = 1**, **401 / 401**, **1,190 message-checked** and **448 / 448**
— and the table's point survives every correction intact, because it is the correction: **not one of
these eight numbers is re-derived by the gate, so all five could drift without anything going red,
and all five did.** Re-checked at the same time and unchanged: none of the eight has gained a
`--check`, and `_gate.py` names none of them as a subprocess, so the answer column still reads "no"
eight times. `_test_ledger.py`'s figure moved for a reason the other four did not share — the tool
is now returning a wrong answer (§5), which is precisely the failure an un-gated instrument cannot
report about itself.</sub>

That is not an indictment — several of these print a census rather than assert a threshold, and there
is nothing obvious for them to fail on. But it means the project's own rule, written in the gate's
own comments, is **not satisfied for any of the six coverage gates**:

> *A number quoted in an audit document as evidence of a repair must be one the gate RE-DERIVES on
> every run. Otherwise it is a claim about the past, and the repair it certifies can be undone
> without anything going red.*

`_conformance.py` and `_heavy.py` were exactly here on 2026-09-13, and were wired in on 2026-09-14
once someone noticed their zeros were hand-measured. The same argument applies unchanged to the eight
above. **Deleting every `ignis-need` assertion from `launchpad-groundtruth.repl` tomorrow would turn
nothing red**, and the published figure would still read
{{fig:previews_measured}} / {{fig:previews_client}}.

### 7.2 `_figuresync` locks the narrative to the stats file, not to the tree

`_figuresync.py --check` is fatal and is a genuinely good control: it prevents the narrative audit
documents from carrying a figure the generated statistics do not support, deliberately scoped to
**labelled table rows** so that frozen historical figures written in prose are not rewritten.

But its source of truth is the **committed** `REPL_SUITE_STATS.md`, which is regenerated by hand
(`_suite_stats.py`, which the gate does not run). So a stale stats file propagates *consistently*,
and consistency is what the check measures.

**[VERIFIED by command]** — the same counting rule `_suite_stats.py` uses, applied at the commit
this chapter first measured and at the tree today:

| | |
|---|---:|
| distinct assertions at `1821d73` (2026-09-16, the stats commit this chapter measured) | **5,555** — exactly what the file published then |
| distinct assertions the stats file publishes now (`fb58cba`, 2026-09-18) | **{{fig:assertions_distinct}}** |
| distinct assertions counted from the tree now | **{{fig:assertions_distinct}}** |

<sub>CORRECTED 2026-09-18. This table stopped at two rows and the section concluded that **the
generated statistics are 261 assertions stale today, and nothing is red.** They are not stale today.
The file was regenerated on 2026-09-18 and its distinct count now reproduces from the tree exactly,
which is why the same macro can stand in both of the last two rows. The instance closed; the hazard
did not, and the hazard is what the section is about. Regenerating remains a manual act —
`_suite_stats.py` is still not run by the gate — so those two rows agree because somebody typed a
command, not because anything would have gone red if nobody had. The figure this chapter quotes is a
build-time macro read out of that same file, so the day it goes stale again, so does this
sentence.</sub>

The contrast with {{ch:pricing}}'s `_pricesync.py` is the whole point: `_pricesync` **re-runs its generators in memory and
diffs**, so its artefacts cannot go stale without the gate failing. `_figuresync` compares two
committed files. *Two controls with the same intent, one closed loop and one open one.*

### 7.3 Two generators rewrite a tracked artefact on a bare invocation

**[VERIFIED by reading]** — `_suite_stats.py:331` writes `ARCHITECTURE/REPL_SUITE_STATS.md` and
`_toolindex.py:46` writes `REPL/TOOLS.md`, in both cases with no `--apply`, `--write` or `--check`
flag to gate it. Running either "to see what it says" rewrites a tracked file.

A third belongs on this list and this chapter did not have it: **`_test_ledger.py` writes the
tracked `REPL/_test_ledger.json` on a bare invocation** (`:183-184`), with no flag either. Every
figure in §5 comes from running it, so re-deriving this chapter's own G1 numbers dirties the
worktree. That is how it was done, and the file was restored with `git checkout --` afterwards.

These are generators and regenerating is the intended action, so this is a much smaller hazard than
the five `_fvt*` tools that rewrote **hand-written contract source** at import and silently deleted
111 lines of schemas. But the repository's own standing rule — *"never run a tool to find out what it
does; read its docstring, or check the table in `REPL/TOOLS.md`"* — is weaker than it looks while two
of the tools it names write by default.

`REPL/TOOLS.md` itself: **[VERIFIED by command]** it indexes **50** scripts and `REPL/tools/` holds
**53** `_*.py` files.

<sub>CORRECTED 2026-09-18: the second figure read **51**, so the gap this sentence exists to point
at was reported as one tool and is three. **[VERIFIED by command]** the three `REPL/tools/_*.py`
absent from the index are `_auditbook.py`, `_booktables.py` and `_modref.py`. `_toolindex.py` globs
every `_*.py` in the directory and prints "(no docstring)" rather than skipping, so this is not
selective omission — it is simply that `TOOLS.md` has not been regenerated since those three landed,
which is the §7.2 open-loop shape again in a second artefact. What makes it worth a sentence rather
than a shrug: all three are gate-fatal `--check` tools (§3(b)), and `TOOLS.md` is the document
`CLAUDE.md` tells you to read *instead of* running a tool to find out what it does. The index that
replaced the dangerous behaviour does not list the newest checks. `_suite_stats.py:319` is corrected
to `:331` above; the write moved, the absence of a flag did not.</sub>

### 7.4 Phase 1.5's own steps, checked against the tree

| step, and what it asked for | measured position |
|---|---|
| **1.5.1.1** CI-gate the ground-truth harness; extend it to cover **every** INFO function | the harnesses exist and **are** gate entrypoints (`launchpad-groundtruth.repl`, `triplet-collect-golden.repl`, `modules/DEFPACT-BILLING.repl`, the `deb-staleness-*` drivers), and {{fig:previews_measured}} of {{fig:previews_client}} client-facing previews are measured, none unmeasured. **The coverage instrument that says so is still not gated** — re-checked 2026-09-18: `_info_measured.py` has no `--check` and `_gate.py` does not run it. The *denominator* half of this row has closed: the tool used to enumerate its subject from a hardcoded three-file list, which omitted 14 previews of which one was genuinely unmeasured; it now discovers every `ClientInfo`-returning `INFO_` preview across `1_SOVEREIGN/` and `2_CITIZEN/`, and that one preview is measured ({{ch:previews}} §6) |
| **1.5.1.2** repo-wide REPL coverage completion | **substantially done** — G1 at 448 of 448 entrypoints exercised, and since 2026-09-18 the ledger can demonstrate all 448 (§5); zero entrypoints reachable only from an ungated file; **G2's live unpinned worklist now at 0**; G5 closed. **G6 open at 84%, 699 functions unreached** |
| **1.5.1.3** single comprehensive run, one boot, all Pact code | **met by a different mechanism.** The one-boot runner carries 25% of the distinct assertions; the comprehensive run is the {{fig:entrypoints}}-way parallel gate |

<sub>CORRECTED 2026-09-18. Row 1.5.1.1 said *"401 previews are measured"* and that the tool's
denominator omitted fourteen; both halves are superseded, and the half that mattered — the
instrument is not gated — was re-checked and still holds. Row 1.5.1.2 said *"G1 at 448/448"* and
*"G2's live unpinned worklist at 1"* and *"G6 open at 84%, 708 unreached"*. The G2 worklist has
reached zero, which is the only one of the three that is a completed piece of work.</sub>

### 7.5 And the finding that qualifies every green assertion in this Part

It comes from the adversarial round, and Part III states it in full, but it belongs here because it
bounds what {{ch:suite}}'s numbers certify. Four red-team attacks were **refused by the wrong
guard** — `RT-E-001`, `RT-H-001`, `RT-C-001` and `RT-E-002` — and `RT-H-001` produced two of them,
so there are five rows:

| attack | the guard that ought to refuse | the guard that actually did |
|---|---|---|
| `RT-E-001` vault dust sweep | a claimant-set check | a `last-collected-round` stamp **in a different function** |
| `RT-H-001` swap a token for itself | `output-id NOT IN input-ids` | the **curve returning exactly zero** |
| `RT-H-001` duplicate swap input | a uniqueness check | a **stable-pool single-input rule** |
| `RT-C-001` treasury-debt wipe | `GOV\|DPTF_ADMIN` | a **solvency check one line above it** |
| `RT-E-002` continue a defpact you did not start | a continuation-authority check | the step **happening to move the starter's own tokens** |

Every one of them was green, and would have stayed green through the change that breaks it. The
first four have since been repaired. `RT-E-002` deliberately has not — giving the defpact layer a
continuation-authority check is a design decision about who may drive a multi-step operation, and it
would touch every `MTX|` pact — so it is recorded instead as a standing constraint: *if a step does
not move the starter's own assets, it has no caller authentication at all.*

<sub>CORRECTED 2026-09-18. This read **"Three of the red team's six clean refusals were by the wrong
guard"** above a table of four rows, a three-against-four mismatch inherited verbatim from
`RED-TEAM-REPORT.md:1657`. Both numbers were wrong in a different way. The denominator: the register
today records {{fig:attacks}} attacks, {{fig:attacks_refused}} of them refused, so "six" is the
programme's size at an earlier stage and not a live figure. The numerator: `RED-TEAM-REPORT.md:892`
records a **fourth** wrong-guard refusal, `RT-E-002`, found on 2026-09-15 and never added here — it
is the fifth row above, and the only one still open. The three-versus-four was never an error, only
an unexplained one: it counted attacks while the table listed findings, and `RT-H-001` yielded two.
Deliberately **not** written as "four of {{fig:attacks_refused}}": the register marks `RT-H-001`
FIXED rather than REFUSED, because the same attack also found a real defect, so the four are not a
subset of the refused count and quoting them as a fraction of it would be false.</sub>

> The suite's {{fig:assertions}} executed assertions — measured at build time; this book
> did not run the gate — establish that the system behaves as documented. They do
> not establish
> that it is defended for the reasons the documentation implies. Those are different claims, and only
> the first one has a number.

---

## 8. The methodology traps worth publishing

The round's report keeps a section for the mistakes made while measuring, and three transfer directly
to anyone auditing a system like this.

**A stale log answered for a run that never happened.** A gate launched as `cd REPL && … > log` from a
shell already inside `REPL/` never started; a previous session's log at that path ended in
`GATE GREEN`, and a trailing `; echo rc=$?` reported the *echo's* success. The stale green hid a real
failure for hours. The structural fix is one line, flushed first: the gate now prints
`GATE RUN STARTED <timestamp> (pid N)` before doing anything. **A log without that header was never
produced by a run.**

**An exclusion list with a wrong reason is where coverage hides.** One gate-excluded file was recorded
as failing deep inside a probe module. It actually dies on its **first `(load)`** from a path bug and
has never run at all — it was moved into `Kursan/` and its REPL-root-relative loads were never fixed.
The recorded reason would have sent the next person to debug something never reached. The exclusion
now names the real cause and states why the coverage is not lost.

**A worklist of "78 unreached `UEV_` guards" was carried across two sessions and was never real.** It
came from a tool measuring *static call-graph reachability*, whose own output says
`calls to a ref- binding this tool could not resolve: 89`. Any guard invoked only as
`(ref-M::UEV_X …)` appears unreached even when a negative test drives it to abort. The tool that owns
guard coverage reported live unpinned = 0 the whole time. **Two tools, two questions; the number that
was easier to quote answered the wrong one.**

> The general form, which the round states better than this book could: the danger is not only that a
> count may be wrong, but that **the wrong tool can be authoritative-looking about a question it does
> not answer.**

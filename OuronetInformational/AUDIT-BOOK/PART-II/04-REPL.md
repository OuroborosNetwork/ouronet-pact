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
| `.repl` files (excl. `archive/`) | 181 | — | — | 209 | — | 207 |
| `.repl` lines | 68,435 | — | — | 120,603 | — | 128,567 |
| distinct assertions | **1,604** | 1,663 | 2,431 | **5,262** | 5,555 | **5,867** |

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
| **G1** Surface | every Talos entrypoint invoked **inside its own module tester** | ~65% | **448 / 448 = 100%** |
| **G2** Adversarial | every `enforce` / defcap rejection has an `expect-failure` | 293 tests / 1,015 sites = 29% | **live unpinned = 1**; 707 pinned unambiguously, 763 including shared wording |
| **G3** Determinism | every test passes standalone **and** inside the full run | — | every module tester boots its own environment; the gate runs them as separate processes |
| **G4** Conformance | every rule the architecture *states* is proven to hold | 44 deviations / 4,919 defuns | **violations 0**, observations 114 |
| **G5** Doc claims | every `@doc` stating a RULE has a test proving it | 100 unverified | **0 left** — scoped at ~100, the real worklist was 19 |
| **G6** Function reach | every client-reachable function is exercised | 3,230 / 4,498 = 72% | **3,816 / 4,524 = 84%**, 708 never reached |

**G2's denominator, stated rather than assumed.** The "live unpinned = 1" figure is conditioned on
three exclusions that the generated statistics list beside it, so the subtraction is visible rather
than taken on trust: **24** guards in the dead `00_DPMF` module, **40** unreachable inside an
`enforce-one`, and **31** proven unreachable by hand and annotated. An excluded guard is not reported
as a gap — and the project's own rule for the third bucket is the thing that keeps it honest: *every
`;;UNREACHABLE` annotation is backed by a test that drives the route to whatever wall actually stops
it and reads the message that comes back.* That is what turns an annotation from a claim into a
regression trip-wire.

**G5 is the one most projects do not have, and it can fail in a way G2 cannot.** G2 asks whether the
guard we wrote works; G5 asks whether the guard we **promised** exists at all. Closing it found two
*vacuous existing proofs* — shared-graph equalities that short-circuited on OURO and never read the
graph argument they were written to test.

**G6 is the one that is not closed, and the round says so.** The target was ~93%; the measured
position is 84%, with **708 client-reachable functions never reached**, concentrated in per-field
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

### (b) Twelve static checks, every one fatal

**[VERIFIED by command]** — of the tools in `REPL/tools/`, exactly twelve implement a `--check` mode,
and **all twelve are run by the gate and are fatal**:

| check | what a failure means |
|---|---|
| `_stagez_variant --check` | the generated Stage-Z testing variant is stale against canonical — *"the STAGE-Z assertions are testing a stale copy and would still go green"* |
| `_ladder --check` | a citizen minter's batch ladder does not tile its collection — gap, overlap, or a rung over the per-transaction gas budget |
| `_colproj --check` | a projecting `read` names a column its own table's schema lacks |
| `_redteam --check` | a `RedTeam/` block has a malformed or duplicate attack header — *"a shrinking register looks exactly like a clean one"* |
| `_figuresync --check` | an audit document quotes a figure the generated statistics do not support |
| `_pricesync --check` | a generated pricing artefact does not match its generator (Chapter 2 §5) |
| `_toolpaths --check` | a tool hard-codes a path that no longer resolves |
| `_prefixsync --check` | a function prefix live in the tree is unknown to the tooling's vocabulary |
| `_modref --check` | a `(ref-X::member …)` call where `member` is defined **nowhere** in the implementing module |
| `_vacuous --check` | a positive assertion that **cannot fail** |
| `_conformance --check` | an architectural conformance **violation** (observations stay advisory) |
| `_heavy --check` | a single-prefixed `C_`/`A_` whose tree reaches a heavy scan |

Two of these deserve a sentence each. `_modref` exists because **Pact 5 resolves modref members
dynamically**, so a call to a member that does not exist loads and runs and only raises if that
branch is taken — invisible to every other check. And `_conformance` / `_heavy` were **added as gate
checks on 2026-09-14 after a verification pass found their "0" was a hand-measured figure**: the gate
byte-compiled them and ran one selftest, but never ran either tool, so re-introducing a defect that
had been *verified exploitable* before it was fixed would have left the gate green.

### (c) Tool integrity

Every `_*.py` in `REPL/tools/` is byte-compiled, and `--selftest` is run on the ten that have one.
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
| asserting `.repl` files in the suite (excl. `archive/`) | **148** |
| …inside `ZALL.repl`'s closure | **34** |
| distinct assertions in the suite | **5,747** |
| …inside `ZALL.repl`'s closure | **1,434 (25%)** |

<sub>The 5,747 here excludes `archive/`; §1's 5,867 is the project's own `_suite_stats.py` rule, which
walks all of `REPL/` including the 68 archived files. Same corpus, two denominators — quoted
separately rather than reconciled, because each is the right one for its own question.</sub>

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

The generated `REPL-TEST-LEDGER.md` reports:

| metric | value |
|---|---:|
| client entrypoints (the auditable contract) | **448** |
| exercised at least once | 448 (100%) |
| **exercised by a file the gate runs** | **448 (100%)** |
| exercised only in an ungated file | **0** |
| exercised but with **no adversarial assertion in any of its blocks** | **289** |

**[VERIFIED by command]** — parsing every `ENTITY|C_`/`CC_`/`A_`/`AA_`/`Cp_`/`CCp_` defun from the
eleven Talos modules gives **482 definitions and 448 distinct names**, with 7 names defined in more
than one Talos file. The ledger's denominator reproduces exactly.

The 289 figure is the one to read carefully, and the ledger tells you how: **assertions are
attributed by transaction block**, credited to every operation invoked in the same
`(begin-tx … commit-tx)`. So the columns measure how well an operation's *neighbourhood* is asserted,
not that an assertion targets it. Invocation counts are exact; assertion counts are a proxy. The
pattern the ledger exists to surface is at the top of its own gap table: **`ATS|C_ColdRecovery`,
invoked 273 times, with zero adversarial assertions** — heavily exercised, never actually probed.
Raw invocation counts hide that.

`REPL-TEST-LEDGER.md` was last regenerated on 2026-09-14 and is not re-derived by the gate.

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

**[VERIFIED by command]**. Twelve tools implement `--check` and all twelve are gate-fatal. The
instruments that produce this chapter's *coverage numbers* are not among them, because they have no
`--check` to run:

| instrument | the number it owns | gate-enforced? |
|---|---|---|
| `_scale_report.py` | G6 function reach (84%, 708 unreached) | **no** |
| `_enforce_coverage.py` | G2 guard pinning (live unpinned = 1) | **no** |
| `_info_measured.py` | the Phase-1.2 headline (401 / 401) | **no** |
| `_expectfail.py` | assertion strength (1,190 message-checked) | **no** |
| `_docclaims.py` | G5 documented claims | **no** |
| `_cheapseam.py` | the zero-fixture guard seam (exhausted) | **no** |
| `_test_ledger.py` | G1 (448 / 448) | **no** |
| `_infostoa.py` | previews falsely claiming STOA-free (0) | **no** |

That is not an indictment — several of these print a census rather than assert a threshold, and there
is nothing obvious for them to fail on. But it means the project's own rule, written in the gate's
own comments, is **not satisfied for any of the six coverage gates**:

> *A number quoted in an audit document as evidence of a repair must be one the gate RE-DERIVES on
> every run. Otherwise it is a claim about the past, and the repair it certifies can be undone
> without anything going red.*

`_conformance.py` and `_heavy.py` were exactly here on 2026-09-13, and were wired in on 2026-09-14
once someone noticed their zeros were hand-measured. The same argument applies unchanged to the eight
above. **Deleting every `ignis-need` assertion from `launchpad-groundtruth.repl` tomorrow would turn
nothing red**, and the published figure would still read 401 / 401.

### 7.2 `_figuresync` locks the narrative to the stats file, not to the tree

`_figuresync.py --check` is fatal and is a genuinely good control: it prevents the narrative audit
documents from carrying a figure the generated statistics do not support, deliberately scoped to
**labelled table rows** so that frozen historical figures written in prose are not rewritten.

But its source of truth is the **committed** `REPL_SUITE_STATS.md`, which is regenerated by hand
(`_suite_stats.py`, which the gate does not run). So a stale stats file propagates *consistently*,
and consistency is what the check measures.

**[VERIFIED by command]** — the same counting rule `_suite_stats.py` uses, applied at the commit that
last generated the stats file and at HEAD:

| | |
|---|---:|
| distinct assertions at `1821d73` (2026-09-16, the stats commit) | **5,555** — exactly what the file publishes |
| distinct assertions at HEAD (2026-09-17) | **5,867** |

The generated statistics are **261 assertions stale today**, and nothing is red. The contrast with
Chapter 2's `_pricesync.py` is the whole point: `_pricesync` **re-runs its generators in memory and
diffs**, so its artefacts cannot go stale without the gate failing. `_figuresync` compares two
committed files. *Two controls with the same intent, one closed loop and one open one.*

### 7.3 Two generators rewrite a tracked artefact on a bare invocation

**[VERIFIED by reading]** — `_suite_stats.py:319` writes `ARCHITECTURE/REPL_SUITE_STATS.md` and
`_toolindex.py:46` writes `REPL/TOOLS.md`, in both cases with no `--apply`, `--write` or `--check`
flag to gate it. Running either "to see what it says" rewrites a tracked file.

These are generators and regenerating is the intended action, so this is a much smaller hazard than
the five `_fvt*` tools that rewrote **hand-written contract source** at import and silently deleted
111 lines of schemas. But the repository's own standing rule — *"never run a tool to find out what it
does; read its docstring, or check the table in `REPL/TOOLS.md`"* — is weaker than it looks while two
of the tools it names write by default.

`REPL/TOOLS.md` itself: **[VERIFIED by command]** it indexes **50** scripts and `REPL/tools/` holds
**51** `_*.py` files.

### 7.4 Phase 1.5's own steps, checked against the tree

| step, and what it asked for | measured position |
|---|---|
| **1.5.1.1** CI-gate the ground-truth harness; extend it to cover **every** INFO function | the harnesses exist and **are** gate entrypoints (`launchpad-groundtruth.repl`, `triplet-collect-golden.repl`, `modules/DEFPACT-BILLING.repl`, the `deb-staleness-*` drivers), and 401 previews are measured. **The coverage instrument that says so is not gated**, and its denominator omits 14 previews of which one is genuinely unmeasured (Chapter 1 §6) |
| **1.5.1.2** repo-wide REPL coverage completion | **substantially done** — G1 at 448/448 with zero entrypoints reachable only from an ungated file; G2's live unpinned worklist at 1; G5 closed. **G6 open at 84%, 708 functions unreached** |
| **1.5.1.3** single comprehensive run, one boot, all Pact code | **met by a different mechanism.** The one-boot runner carries 25% of the distinct assertions; the comprehensive run is the 92-way parallel gate |

### 7.5 And the finding that qualifies every green assertion in this Part

It comes from the adversarial round, and Part III states it in full, but it belongs here because it
bounds what Chapter 4's numbers certify. **Three of the red team's six clean refusals were by the
wrong guard**:

| attack | the guard that ought to refuse | the guard that actually did |
|---|---|---|
| vault dust sweep | a claimant-set check | a `last-collected-round` stamp **in a different function** |
| swap a token for itself | `output-id NOT IN input-ids` | the **curve returning exactly zero** |
| duplicate swap input | a uniqueness check | a **stable-pool single-input rule** |
| treasury-debt wipe | `GOV\|DPTF_ADMIN` | a **solvency check one line above it** |

Each is green today and would **stay green through the change that breaks it.**

> The suite's 22,454 executed assertions — the last recorded green gate run, 2026-09-16; this book
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

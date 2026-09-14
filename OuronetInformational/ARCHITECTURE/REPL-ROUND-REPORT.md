# The Ouronet REPL Verification Round — comprehensive report

*Prepared 2026-09-14, immediately before the red-teaming phase. Audit-paper source material.*

This document states what the REPL verification round did to the Ouronet contract source: how large
the suite is, how much of it runs, what it covers, what it found, how it was executed in the time
available, and — the section that matters most for an external reader — **where its own numbers are
claims rather than measurements.**

Three companion files carry the detail this one summarises:

| file | what it holds | how it is produced |
|---|---|---|
| `REPL_SUITE_STATS.md` | every scale and coverage figure, plus all 5,438 per-function rows | **generated**: `cd REPL && python3 _suite_stats.py --gate` |
| `DEFECT-LEDGER.md` | the deduplicated defect register, with mechanism and provenance per entry | compiled from project records, **partially re-verified** — see its own header |
| `REPL_TEST_ARCHITECTURE.md` | how the suite is laid out and why | hand-maintained |

`REPL_SUITE_STATS.md` computes nothing itself: every figure is lifted from the tool that owns it,
with the producing command named beside each section. That is deliberate. A second implementation of
the same count drifts from the first, and both then look authoritative.

---

## 1. Scale

<sub>source: `python3 REPL/_scale_report.py`</sub>

| | |
|---|---:|
| `.repl` files | **210** |
| total lines | **121,768** |
| &nbsp;&nbsp;code | 95,412 |
| &nbsp;&nbsp;comment | **24,258** |
| &nbsp;&nbsp;blank | 2,098 |

**One fifth of the suite is prose, and that is a design decision, not slack.** The comment lines
carry the reasoning a bare assertion cannot: what the block proves, why that property matters, what
the naive version of the test would have reported instead, and — repeatedly — the mechanism of a
defect found at that exact line. Several defects in this round were found *while writing the
explanation*, because stating precisely what an assertion proved exposed that it proved nothing.

| area | lines |
|---|---:|
| `modules/` (per-module standalone testers) | 39,830 |
| `Stage_02/` | 38,450 |
| `Stage_01/` | 28,448 |
| `Kursan/` (scale + finding-verification harnesses) | 8,550 |
| root (runners, gate, tools) | 5,885 |
| `fixtures/` | 605 |

---

## 2. How much runs, and what it asserts

<sub>executed: live `python3 REPL/_gate.py` · distinct: counted from source</sub>

| | |
|---|---:|
| **distinct assertions written** | **5,349** |
| **assertions executed per full gate run** | **20,921** |
| &nbsp;&nbsp;positive (`expect`) | 17,048 |
| &nbsp;&nbsp;negative (`expect-failure`) | 3,873 |
| gate entrypoints | **77** |
| `.repl` files reachable from the gate | 306 |
| orphaned asserting files (written but never run) | **0** |

**Quote 5,349 for "how many tests exist" and 20,921 for "how much ran".** They differ ~4x because
shared suite files execute once per entrypoint that loads them, and conflating them overstates the
suite. Both are reported here for exactly that reason.

The orphan check is the load-bearing one. The gate computes the transitive closure of every
entrypoint and fails if any file containing an assertion is outside it — because a test file nobody
runs is worse than no test file: it reads as coverage.

### Assertion strength

A count of assertions is worthless without knowing whether they can fail.

<sub>source: `_expectfail.py`, `_vacuous.py`</sub>

| | |
|---|---:|
| negative assertions that check their **message** | **1,111** |
| negative assertions accepting **any** error | 35 — all in ungated scratch files |
| positive assertions that **cannot fail** | **0** |
| positive assertions on a trivially-satisfied bound | 12 — reviewed, legitimate |

An `expect-failure` that accepts any error passes when the code fails for the wrong reason — which
is precisely how a shadowed guard hides. 1,111 of 1,146 gated negative assertions name the message
they expect.

---

## 3. Coverage

<sub>source: `python3 REPL/_scale_report.py --functions`</sub>

Two denominators exist and mixing them is how coverage gets misreported. **All defined** includes
the dead `DPMF` module (kept deployed for provenance, called by nothing) and the `XI_`/`XB_`/`XE_`/
`W*_` families that are protected by construction and *cannot* be called by a test. **Client-reachable**
excludes both and is the honest denominator.

| | all defined | client-reachable |
|---|---:|---:|
| functions | 5,438 | **4,514** |
| named directly by a test | 2,357 | 2,333 |
| reached only *through* another function | 2,171 | 1,464 |
| **reached at all** | 4,528 | **3,797 — 84%** |
| never reached | 910 | 717 |

Total call sites across the suite, duplicates included: **15,911**.

### The dimensions that matter more than the percentage

| dimension | figure | tool |
|---|---:|---|
| `enforce` sites pinned by a negative test (unambiguous wording) | **696** | `_enforce_coverage.py` |
| pinned including wording shared across modules (upper bound) | 753 of 777 | `_enforce_coverage.py` |
| **live unpinned guards** | **0** — all 24 remaining are in dead `DPMF` | `_enforce_coverage.py` |
| unpinned guards reachable with plain arguments ("zero-fixture seam") | **0 — exhausted** | `_cheapseam.py` |
| `INFO_` cost previews **measured against a live charge** | **397 of 412** | `_info_measured.py` |
| previews named but not measured | **0** | `_info_measured.py` |
| conformance violations | **0** | `_conformance.py` |
| conformance observations (doc narrower than correct practice) | 114 | `_conformance.py` |

**The `INFO_` figure answers the owner's governing rule for this phase** — *"the INFO function must
output the exact same cost as the real execution function."* Reader-versus-reader assertions were
rejected outright; only a measured balance delta around a live execution counts. The 15 unmeasured
are structural, not gaps: 9 are internal constructors taking a pre-built cumulator, 3 are 3-step
defpacts (a `begin-tx` cannot contain `continue-pact`), 2 return a view object with no cost fields,
and 1 *credits* IGNIS rather than charging it, so there is no charge to difference.

---

## 4. Execution: why this was run in parallel

A full gate run is **77 entrypoints totalling 5,526 seconds of work — 1 hour 32 minutes serial.**
It completes in **~375 seconds wall on 16 workers**, a **14.7× speedup**.

That ratio is the difference between two development models, and the second one is what found most
of what this round found:

- **Serial**: ~1.5 hours per verification. The gate is run once a day, changes are batched, and a
  regression is attributed to one of twenty edits by bisection.
- **Parallel**: ~6 minutes. The gate runs after each coherent change, and a regression names itself.

The speedup is deliberately **sub-linear**, and the reason is worth stating because it bounds any
further investment: **wall time can never fall below the slowest single entrypoint.** `ZALL.repl`
alone takes ~354s of the ~375s total. Adding workers past 16 buys almost nothing; splitting `ZALL`
would be the only way to go faster.

Parallelism is used at a second level too. Independent investigative work — coverage for a module
family, compiling the defect register, sweeping a defect class across the codebase — is dispatched
to concurrent agents, each owning **exactly one file** so their edits cannot collide. Four ran
concurrently in the final session; three produced new coverage and the fourth produced
`DEFECT-LEDGER.md`. Two of the three found defects the task had not anticipated.

### The instrument suite

**43 static analysis tools** under `REPL/_*.py`, each owning one question. The gate runs the
structural ones as hard pre-checks, byte-compiles all 43, and executes `--selftest` on those that
have one.

That last part exists because of a specific failure: an edit to `_conformance.py` left an unescaped
quote in a rule string, and **the gate went green twice while the conformance checker could not
start.** A tool that cannot run is worse than a missing tool, because its silence reads as clean.

Tools added during this round, each built the moment a defect revealed a whole class:

| tool | the class it makes impossible to reintroduce |
|---|---|
| `_ladder.py` | a minter batch ladder that mis-tiles its collection (gap, overlap, or an over-budget rung) |
| `_colproj.py` | a projecting `read` naming a column its own table's schema lacks |
| `_info_measured.py` | an `INFO_` preview that is *named* by a test but never *measured* against a charge |
| `_infostoa.py` | a preview claiming STOA-free whose exec tree reaches `STOA\|C_Collect` |

Each was **mutation-tested against the defect that motivated it** before being trusted — the known
bug is reintroduced, the tool must report it, and the bug is reverted. A clean report from an
unverified scanner is indistinguishable from a broken scanner.

---

## 5. What the round did to the code

`DEFECT-LEDGER.md` holds the register. Its compiled total is **131 contract defects**; read its
verification-status header before citing that figure, and see §6 below.

The classes, largest first:

| class | n | why the class exists |
|---|---:|---|
| Guard reachability — mute, shadowed, dead | 36 | `let` binding groups are **eager** and `(fold (and) true [...])` does **not** short-circuit, so a guard cannot protect the expression computing its own operands. The caller gets a raw table error naming a row key instead of the rule. **Every positive path still works**, which is why review walks past it: the message is the one part of a guard no passing test executes. |
| Pricing — preview vs charge | 17 | A cost preview and its execution derive the same price twice, from two places. |
| Client-facing diagnostics | 14 | Refusals naming the wrong thing, or nothing. |
| Pricing — mispriced or unbilled ops | 13 | |
| State machine, permanently-locked value | 12 | |
| Arithmetic, lists, empty input | 10 | |
| Deployment / wiring / dead-on-arrival | 8 | |
| Missing validation | 7 | |
| Gas, performance, portability | 6 | |
| Authorisation & architecture | 5 | |
| Live defects in the **generated pricing artefacts** | 3 | The documents that feed the published Chapter-2 material. |

### Six representative findings, chosen for what they teach

**A vault deadlock that closed every exit at once.** `STOAICO::XI_CollectFor` minted an account's
urSTOA unconditionally and guarded only the *delivery* against a zero amount. A zero-amount mint is
refused (`UEV_Amount`), and an account's entitlement is zeroed by its own first collect — so from
its second distribution round onward the transaction aborted while real rewards were owed. Not a
nuisance but a **deadlock**, because all three exits share that core: self-collect aborted, the
admin flush shared the same function, and a new round could not open while the unclaimed count was
non-zero. **The vault stopped paying and could not be restarted from any entrypoint.** Fixed; the
proof is 309.474016486404 wSTOA reaching a staker who could not previously be paid.

**A revenue bug, not a quoting bug.** Every `VST::CreateSpecial*Link` was under-charged: the exec
never collected a deterrence that was designed in and documented. The preview and the exec were
wrong in *opposite* directions, which is why it sat unresolved as a recorded finding until the owner
ruled on the intended design. Both sides now read one shared source.

**A defect no `.repl` could ever have caught.** `NOSFERATU::A_Fix01` addressed `Legendary 1 100`
where its twin addresses `1 70` — double-covering thirty positions and demanding a 100-row metadata
list from a ladder built entirely of ≤70 rungs, where 70 is the per-transaction gas budget. The mint
plan is *literals inside one-line wrappers*; a REPL can execute a rung but cannot read a literal,
and nothing executed that family at all. Static bug, static instrument: `_ladder.py`.

**A total failure that deleted its own evidence.** `AOZ::UR_NonFungible` projected `"sf-asset"` — the
*SemiFungible* column — from the NonFungibles table. Pact does not reject an unknown projected
column; it returns `{}` and fails one call later as `Key "sf-asset" not found in object: {}`, which
reads like a missing **row**. Because it failed for every input, the function was never usable, so no
test was ever written against it: **the defect and the evidence for it disappeared together.** The
registry was write-only through the public interface. Swept the codebase for the class afterwards —
zero further instances, sweep mutation-tested against the known one.

**A dead outer gate hiding an entire authorization layer.** Two launchpad admin price-setters
forwarded to a sovereign function whose first statement is an inter-module caller gate. A capability
guard only passes while its capability is *in scope*, and neither acquired anything — so every call
died before reaching the admin check. The consequence is the interesting part: while the outer gate
refused everyone, an admin and a non-admin failed **identically, with the same message**, so
"non-admin is refused" was not merely untested but **untestable**. Both halves now exist.

**An operator instruction that was exactly backwards.** `GOV|MIGRATE` requires the Global
Administrative Pause to be **on** and told the operator it must be **off**. Anyone following the
message would disarm the pause and retry forever. One word; the logic was always right.

---

## 6. Where this round's own numbers are claims, not measurements

An audit paper is strengthened by stating this, and this round produced the cautionary example
itself.

**A worklist of "78 unreached `UEV_` guards" was carried across two sessions and was never real.**
It came from `_scale_report.py --untested`, which measures *static call-graph reachability* and
whose own output says `calls to a ref- binding this tool could not resolve: 89`. Any guard invoked
only as `(ref-M::UEV_X ...)` appears unreached even when a negative test drives it to abort. The
tool that owns guard coverage, `_enforce_coverage.py`, reports **live unpinned = 0**. Two tools, two
questions; the number that was easier to quote answered the wrong one.

The same correction applied to the `A_`/`C_` entrypoint figure: **51 became 33** once the dead
module was removed from the denominator.

**A false claim sat in the governing document.** `CLAUDE.md` and `IGNIS-PRICING.md` §8 both stated
that a green `Z.repl` "does not execute the assertions written to protect" pricing. It runs **106**
of them; what it skips is a different 75. The *rule* survives — those 75 are the **leg-level**
assertions, and on 2026-09-14 one of them was the only assertion in the entire suite to catch a
preview leg-split that every total-level assertion passed straight through. But an overstated rule
is one people stop believing. Both documents corrected.

**`DEFECT-LEDGER.md` was compiled from project records, and compilation is not verification.** Its
two largest claim-sets have since been checked, and the results differ in a way worth stating:

| claim-set | status |
|---|---|
| the **28 `open`** entries | all 28 re-verified against source, all confirmed open; eight factual corrections; one escalation REFUTED by measurement |
| the **56 `fixed`** entries | **56 FIX-CONFIRMED, 0 FIX-ABSENT, 0 FIX-PARTIAL**; every named pin still exists as a live `expect`; two mutation-tested by reverting the fix and watching the detector fire |

**The `fixed` sweep was run before revisiting the `open` backlog, and the ordering was deliberate.**
A false `fixed` is the most damaging error this document can contain — worse than an unverified
`open` — because it asserts a repair that may not exist. It came back clean, which is the strongest
single statement this report can make about the repair record.

It also produced two results that change what the numbers above mean:

**A new live defect, `GS-04`, of exactly the cross-route shape §8 describes.** `SWPI::URCi_Issue` was
repaired to equal the **single-tx** `C_Issue`; six previews share it and **three price the defpact
instead**, which bills 5506 in one leg against the preview's 6158 in four. The tell is a **dead
parameter** — `op-key` sits in the signature and is used nowhere, the term that consumed it having
been removed by the repair. Nothing caught it because every pin measures a single-tx issue and **a
defpact cannot be measured inside one `begin-tx`** — the same structural limit §3 gives as the reason
three previews are unmeasurable. *The gap in the instrument and the location of the defect are the
same place.*

**Two figures this report relied on were hand-measured, not gate-derived.** `_conformance.py`'s "0
violations" and `_heavy.py`'s "single-reaches-heavy = 0" appear in §3 as coverage evidence. The gate
byte-compiled both tools but never ran them, so re-introducing `X-02` — a defect *verified
exploitable* before it was fixed — would have left the gate green. Both are now `--check`-wired and
fatal on violations. The rule this produced is general enough to state on its own:

> **A number quoted as evidence of a repair must be one the gate re-derives on every run.**
> Otherwise it is a claim about the past, and the repair it certifies can be undone without
> anything going red. It also lists **21 internal contradictions** — places where two project documents
disagree and a published paper cannot carry both. Three are live defects in the generated pricing
artefacts that feed the Chapter-2 documentation.

### Methodology traps worth publishing

- **A stale log answered for a run that never happened.** A gate launched as `cd REPL && … > log`
  from a shell already in `REPL/` never started; a previous session's log at that path ended in
  `GATE GREEN`, and a trailing `; echo rc=$?` reported the echo's success. The stale green hid a
  real failure for hours. Fixed structurally: the gate now prints
  `GATE RUN STARTED <timestamp> (pid N)` as its first flushed line — **a log without that header was
  never produced by a run.**
- **A guard that cannot fire is not protection.** A cwd guard written during that same fix was
  deleted on discovering the gate already `chdir`s to its own directory. Unreachable code dressed as
  protection is the shadowed-guard pattern the suite has a tool to hunt.
- **Measuring gas on an op whose currency *is* the asset.** Add-liquidity moves IGNIS as principal
  through the same balance the meter reads, counterfeiting a 200-IGNIS under-quote in an otherwise
  exact preview. Only the operation's own data structure separates tax from fee.
- **An exclusion list with a wrong reason is where coverage hides.** One gate-excluded file was
  recorded as failing deep inside a probe module; it actually dies on its first `load` from a path
  bug and has never run at all. The recorded reason would have sent the next person to debug
  something never reached.

---

## 7. State at the close of the round

| | |
|---|---|
| gate | **GREEN** — 77 entrypoints, 20,921 assertions, 0 failures |
| live unpinned guards | **0** |
| `INFO_` previews named but unmeasured | **0** |
| conformance violations | **0** |
| orphaned asserting files | **0** |
| zero-fixture guard seam | **exhausted** |

Remaining, and deliberately not closed here: **717 client-reachable functions never reached** — the
honest residue, concentrated in per-field readers and internal constructors; the **open** entries in
`DEFECT-LEDGER.md`, pending the verification described in §6; and the contradictions in §5 of that
file, three of which are live defects in published pricing artefacts.

---

## 8. Red teaming — completed, and what it changed about this report

The suite described above is **constructive**: it asserts that documented behaviour holds and that
documented refusals fire. A separate adversarial programme followed it, asking the opposite
question — *what can someone do that nobody documented?* It is reported in full in
`RED-TEAM-REPORT.md`; only the parts that bear on the figures above are repeated here.

**Nine attacks across eight families: 2 succeeded, 1 succeeded-then-fixed, 6 refused.** Three found
a defect. They are counted in `REPL/RedTeam/` and in the machine-read attack register
(`python3 REPL/_redteam.py`), kept separate from the constructive suite precisely so the numbers in
§2 cannot silently absorb them.

### Two defects the constructive round could not have found

Both are worth naming here because they bound what §3's coverage figures actually mean.

**A deterrent that could be declined.** Adding standard liquidity is reachable through two live
Talos client paths. One charged the `lp-churn` deterrent (1,051 raw); the other a flat literal
(100). Same operation, same pool, **10.5×**, and the cheap door is the one the gas station
subsidises. This class is **invisible to preview-versus-charge testing** — and this project has 397
such measurements, every one of them passing. Each route was measured against *its own* preview and
each agreed with itself. The unasked question was *"do two routes to the same operation charge the
same?"*: a **cross-route** invariant, not a per-route one. Fixed.

**A fee taken before the validation that decides whether the operation can happen.**
`MTX|C_AddLiquidity` collects its whole deterrent in step 0 and checks in step 1 that the pool has
not moved. `PoolState` includes token supplies, so **any** stranger's ordinary swap permanently
invalidates an in-flight add, after the fee is paid, with no refund. Open, pending a ruling on when
money should move inside a defpact — and note it is a **second-order cost of the fix above**, which
raised the destroyable fee from 53.0 to 557.03. A repair with a second-order cost must be recorded
when it is made.

### The finding that qualifies every green test in this report

**Three of the red team's six refusals were by the wrong guard.** The system refused the attack, but
not for the reason a reader would assume:

| attack | the guard that ought to refuse | the guard that actually did |
|---|---|---|
| vault dust sweep | a claimant-set check | a `last-collected-round` stamp **in a different function** |
| swap a token for itself | `output-id NOT IN input-ids` | the **curve returning exactly zero** |
| duplicate swap input | a uniqueness check | a **stable-pool single-input rule** |
| treasury-debt wipe | `GOV\|DPTF_ADMIN` | a **solvency check one line above it** |

Each is green today and would **stay green through the change that breaks it**. This is the clearest
limit on what §2's 21,580 executed assertions certify: they establish that the system behaves as
documented, not that it is defended for the reasons the documentation implies.

### What it says about where the defects are

| surface | families | outcome |
|---|---|---|
| authorisation | admin impersonation, ownership bypass, hostile citizen module | 5 refusals, every one message-checked against the intended guard |
| economics & sequencing | arithmetic/value, griefing | 2 defects |
| architectural exception | permissionless reach | 1 confirmed bypass, owner ruling pending |

> **The guards in this system are present and they hold. What fails is the arithmetic around them,
> and the order in which things happen.**

That reproduces §5's distribution from the opposite direction: of the constructive round's 131
compiled defects, the two largest classes were pricing/billing and guard **reachability** — not
guard **absence**.

### One method rule the adversarial programme added

**In a codebase with compositional authorisation, one-level static scans systematically under-report
safety.** Three scans produced misleading numbers across the two programmes — "78 unreached
guards", "every `STOA|C_Collect` is a no-op", "31 of 42 `A_` with no admin guard" — and all three
were refuted by measurement, not by re-reading. Whole families of the red team were consequently
driven entirely by execution. This belongs beside §6's existing caution, and strengthens it: the
danger is not only that a count may be wrong, but that the *wrong tool* can be authoritative-looking
about a question it does not answer.

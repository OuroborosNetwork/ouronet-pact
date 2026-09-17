# Part II · Chapter 1 — The cost readers and the previews

Ouronet charges for almost everything a client does, in a virtual gas called IGNIS and sometimes in
native STOA. Before this round, an operation's price was computed **twice**: once inside the
execution path, and once again inside whatever free preview the UI called to quote it. Two
derivations of one number, edited by different hands at different times.

This chapter is about replacing that with one derivation, and about what the replacement exposed.

---

## 1. The two prefixes

**`URCi_`** — a pure, read-only cost reader. No `enforce`, no writes. It returns the cost of one
operation, and it is called from **two** places: the execution path, to bill; and the preview, to
quote. Registered in the project's prefix canon on 2026-08-30 (commit `02c9b79`) with its own
colour family.

**`INFO_`** — the free client-facing preview. It returns a `ClientInfo` object carrying
`ignis-need`, `stoa-need` and human-readable text, and in the intended shape its body is a thin
wrapper over the operation's `URCi_`.

The design decision is dated and recorded. **Option A, 2026-08-27**: leaves expose `URCi_`, the
executor composes as before, and the preview concatenates the same leaf readers. Option B — billing
*through* the composer — was rejected as a top-to-bottom rehaul. One rule came with it and is worth
quoting because Chapter 3 turns on it:

> A `URCi_` lives in the **same module as the function it prices**, never in a shared cost module.
> If a module gets too big, split the module — do not exile its cost functions.

There is one architectural exception, and the project named it itself: **DALOS deploys below
IGNIS**, so DALOS's nine client-op cost readers live *in* IGNIS under the scoped name
`DALOS|URCi_*`. **[VERIFIED by command]** — those nine are the only scoped `URCi_` names in the
tree, and they are why a naive `grep '(defun URCi_'` undercounts the surface by nine.

---

## 2. The census

**[VERIFIED by command]** — the parser in `PART-II/README.md`, which separates interface
declarations (before the `(module …)` form, in this codebase's co-located interface files) from
implementations (after it). This is the same rule `REPL/tools/_scale_report.py` uses, so the numbers
below agree with the project's own generated statistics.

### `URCi_` — 313 implementations

| | |
|---|---:|
| implementations, across **39** modules | **313** |
| distinct names | 260 |
| declared on an interface | **282** |

> **CORRECTED 2026-09-17.** This chapter first published **322 / 269 / 291 / 31 across 40 modules**.
> Re-derived: **595** `URCi_` defuns exist in total, partitioning exactly into **282** interface
> declarations and **313** module implementations, over **39** modules and **260** distinct names.
> The partition summing to the total is what makes it checkable — the superseded figures did not
> (291 + 31 = 322, but 322 is not what the tree holds).
>
> Method, so it can be re-derived: comments stripped; for each `(defun URCi_…`, compare the nearest
> preceding `^(interface` against the nearest preceding `^(module` and attribute it to whichever is
> closer. One file in the tree declares more than one module, which a simpler "everything after the
> first `(module`" rule mis-attributes.

The gap between 313 and 260 is real and correct: `URCi_UpgradeBranding` is defined independently in
DPTF, DPOF, ATS, SWP, BRD, DPDC and others, because each module prices its own branding upgrade.
Counting names rather than implementations is the mistake the roadmap's own correction notice makes.

The 291/31 split is the answer to an open roadmap decision. Item **1.1.1.1** — *"interface-richness
policy: rich (declare cross-module functions) vs marker-lean"* — is still an unticked `⚠ open
decision` on the board. The tree settled it: **[VERIFIED by command]** every one of the 31
in-module-only readers has **zero** cross-module `::` call sites, so the policy applied is "declare
what crosses a module boundary, keep the rest local", exactly as the walk's own instruction
(1.1.2.1) specified. The unticked box is a bookkeeping gap, not an unmade decision.

The 31 are concentrated where you would expect a composer to be local: VCT's eight batch
vacate/drain readers, RPS's six reward-flow readers, SWPU's four swap-core readers, VST's four
special-link legs, DSA's three royalty composers, and MTX-SWP's two liquidity legs.

Distribution across the tree, largest first — **[VERIFIED by command]**:

| module | `URCi_` | module | `URCi_` |
|---|---:|---|---:|
| `11_VST.pact` | 26 | `02_SCORE.pact` | 13 |
| `05_DPTF.pact` | 25 | `08_DSA.pact` | 12 |
| `08_ATS.pact` | 24 | `05_DPDC-R.pact` | 11 |
| `06_DPOF.pact` | 20 | `08_DPDC-S.pact` | 10 |
| `04_RPS.pact` | 20 | `02_IGNIS.pact` | 9 *(the DALOS nine)* |
| `09_TFT.pact` | 17 | `06_DPDC-MNG.pact` | 9 |
| `18_SWPLC.pact` | 15 | `03_AQP.pact` | 9 |
| `10_ATSU.pact` | 14 | …23 further modules | 1–8 each |
| `15_SWP.pact` | 13 | **citizen launchpad (5 modules)** | 1–2 each |

### `INFO_` — 426 implementations, in ten files

**[VERIFIED by command]**. The consolidation target of roadmap 1.2.2.1 — *"one INFO module per
stage, relocated to `Z_Reads/`, deployed last"* — is **substantially but not entirely** met:

| file | `INFO_` | |
|---|---:|---|
| `1_SOVEREIGN/STAGE_01/Z_Reads/02_INFO-ONE+.pact` | 180 | the Stage-1 preview module |
| `1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact` | 149 | the Stage-2 preview module |
| `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact` | **83** | **still in `2_Core/`, not `Z_Reads/`** |
| `21_CODEX.pact`, `22_PYTHIA.pact` | 4 + 4 | previews kept beside their own module |
| 5 citizen launchpad sale modules | 6 total | citizen previews, one per sale |

`01_INFO-ZERO.pact` survives in `STAGE_01/Z_Reads/` as an explicitly documented **tombstone**: an
empty module retained as a deploy-slot placeholder, with a header recording where each thing that
used to live in it went. **[VERIFIED by reading]** It defines no functions and implements no
interfaces. That is a defensible choice for a module that may already hold a namespace name on
chain, and the reason it is worth mentioning at all is that the alternative — deleting it — would
have been invisible in every count in this book.

### What is inside an `INFO_` body

A complete, exhaustive partition of all 426 — **[VERIFIED by command]**, a script that splits each
module body at top-level `(defun` boundaries and classifies the remainder of each block:

| shape | n | |
|---|---:|---|
| references a `URCi_` / `URCix_` reader | **346** | the intended shape |
| delegates to a sibling `INFO_` | **59** | the `INFO_DPNF\|*` / `INFO_DPSF\|*` wrappers over a shared `son`-discriminated `INFO_DPDC-*` body |
| declares the operation free | **20** | `OI\|UDC_NoIgnisCosts` / `NoStoaCosts` / `UC_EmptyOc` — the gas-station-subsidised hydra slices, ORBR, the DSA oracle toggles |
| a data view, not a cost preview | **1** | returns a `HibernatedNoncesView`, no cost fields |
| **total** | **426** | |

The 59 delegators are not a gap: `INFO_DPNF|Issue` is literally
`(INFO_DPDC-I|Issue patron owner-account collection-name false)`. They reach a `URCi_` one hop
further down. Counting them as unwrapped is a mistake the project made once and corrected —
`_info_measured.py` carries the note, and the reason it matters is stated well there: *"a coverage
report that cries wolf nine times is a coverage report nobody reads to the end."*

### The published figures this contradicts

| source | says | tree says |
|---|---|---|
| `POST-AUDIT-MAIN-ROADMAP.md` dashboard banner (2026-09-17) | 267 `URCi_`, 335 `INFO_` | **313** and **426** implementations; 260 and 425 distinct names. *(Both the banner AND this chapter's first pass were wrong — the banner low on `INFO_` by 85 and high on `URCi_`, this chapter high on `URCi_` by 9. The roadmap banner has since been corrected to the sovereign-only scope it states.)* |
| `IGNIS-PRICING.md` §5 | *"345 of 365 INFO implementations … 14 free … 4 data views"* | **346 / 426 / 20 / 1** |

The second is worth being fair about. **[VERIFIED by command]** — `git show 6b7a85b` (2026-09-06)
is the commit that produced 345/365/14/4, and it produced them by **auditing every INFO function
against the URCi-wrapper rule** and fixing the two that failed it. The figures were correct and
hard-won. They then sat in the document while the DPNF/DPSF preview family was built out, and
nothing re-derived them. *This is the same failure the pricing artefacts were given a gate check for
in Chapter 2 — and §5 is outside that check's scope.*

There is a third figure in the same paragraph worth flagging as **[INFERRED]**: §5 also says
*"395 of 401 Talos client ops have an INFO preview."* But 401 is exactly the number
`_info_measured.py` reports for **client-facing cost previews**, and the Talos client surface is
**448 distinct entrypoints** (§5 of Chapter 4, independently reproduced). A preview count appears to
be wearing an operation count's label. Not asserted as an error — but a reader should not take
"401 Talos client ops" as the size of the client surface, because it is not.

---

## 3. How the surface was built

**[VERIFIED by command]** — `git log --oneline --since=2026-08-30 --until=2026-09-03`. The walk went
in deploy order, one module per commit, and each commit's message states what was proven:

```
2026-08-30  DALOS-via-IGNIS (9)  ·  DPTF (23)  ·  DPOF (19)  ·  ATS (22)
            TFT (14, a cross-module rename of an existing cumulator family)
            ATSU, SWP, then the Stage-2 DPDC family
2026-08-31  the composition tier: ATSU (11 composers), VST (29), LIQUID, OUROBOROS,
            SWPI, SWPL, SWPLC, SWPU, MTX-SWP, DEMIPAD, EQUITY
            then AQP vacate/drain/FullVacate — the "final 17"
2026-09-01  the INFO rehaul, entity by entity: DPTF, DPOF, VST, ATS (42/42),
            SWP (37/37), LIQUID, ORBR, DEMIPAD, EQUITY, the DPDC family, AQP
```

Two facts about the trajectory are worth recording because they explain a discontinuity anyone
re-deriving these counts from git will hit. **[VERIFIED by command]**, counting `(defun …URCi_` and
`(defun …INFO_` at each commit:

| commit | date | `URCi_` sites | `INFO_` sites |
|---|---|---:|---:|
| `0ab7639` | 2026-08-30 | 0 | 143 |
| `a1eb868` | 2026-08-30 | 198 | 143 |
| `7ba53ac` | 2026-08-31 | 418 | 143 |
| `aea2e19` | 2026-09-01 | 455 | **40** |
| `1f714ec` | 2026-09-06 | 580 | **623** |
| `HEAD` | 2026-09-17 | 613 | 623 |

The `INFO_` count collapses to 40 and then jumps to 623 because the rehaul first renamed previews
into a `URC_<scope>|` interim form and the StoicSyntax canon sweep then renamed them back under a
unified `INFO_<scope>|` scheme (commits `1d31d5a`, `1d02de7`, 2026-09-01). **No previews were
deleted.** These raw counts include interface declarations, which is why they exceed the
implementation census in §2; they are given only to show the shape of the work.

---

## 4. What the surface was for, and how it is checked

The point of one reader with two callers is that the preview and the charge cannot disagree. The
project stated the specification as an owner rule:

> *"The `INFO_` function must output the exact same cost as the real execution function."*

**Three candidate tests for that rule were considered and two were rejected** — this is the most
transferable thing in the round, and it is recorded in `DEFECT-LEDGER.md` §1.1a:

| candidate | verdict |
|---|---|
| `INFO_X.ignis-need == <hardcoded expected>` | **rejected — already failed silently.** Four AQP anchor costs were pinned at `1000.0` while the real price moved to a computed `574.0`, and nothing went red |
| `INFO_X.ignis-need == URCi_X` | **rejected — tautological.** The preview is literally built from that reader |
| capture the patron's balance, run the real op through Talos, difference it, compare to the quote | **adopted** — the only one with an independent oracle |

Everything in §5 was found by the third.

---

## 5. What it found

`DEFECT-LEDGER.md` §1.1a lists **17 preview-versus-charge entries covering the project's running
count of 19 defects**; §1.1b lists **13 further mispriced or unbilled operations**. The full register
is there and this book does not reproduce it. What belongs here is the **shape**, because the shapes
recur and the counts do not.

### Three failure modes, and they are not the same problem

**(a) A literal zero for a currency the operation really charges.** The preview returned
`OI|UDC_NoStoaCosts` — rendered to a client as *"Operation is free of native Stoa"* — for operations
charging 918, 500, 432.5 and 76.5 STOA respectively (`INFO_EQUITY|IssueCompany`,
`INFO_ATS|ToggleParameterLock`, `INFO_SWP|ToggleFeeLock`, and all five
`INFO_VST|CreateSpecial*Link`). Nine previews, one shape. The remedy was not nine fixes but a
**detector**: `REPL/tools/_infostoa.py` reports any preview claiming STOA-free whose execution tree
reaches `STOA|C_Collect`. It reports 0 today, and it was mutation-tested against the known defect
before that 0 was trusted.

**(b) A missing leg in a multi-part cost.** The sharpest instance is `P-05`: four AQP inject
previews quoted `URCi_Inject` — the gas leg — while phase 1 of `XI_FvtInjectCore` is a custody
transfer carrying its own cumulator. Measured **276.13 quoted against 276.66 charged**. A 0.53
discrepancy is not a rounding artefact; it is a whole leg, and the size of the gap is a property of
the fixture, not of the defect. The same is true of `P-07`, where two citizen sale previews missed a
royalty payment made *out of the patron* before the sale's own collect: measured 89.002 against
89.004, *"0.1% here only because this fixture's royalty is small."*

**(c) The wrong source constant.** `P-06`: two issuance paths price a liquidity pool differently —
the single-transaction path at 500 STOA, the defpact path at 600 — and all six previews quoted the
second, so the three single-transaction previews over-quoted by 100 STOA each.

### The one that was wrong in both directions

`P-10` is the entry to read if you read only one. Seven `VST` special-link previews added a
`vst-link` deterrence of 279 raw IGNIS that the execution path **never charged**, while
simultaneously modelling a transfer-role toggle as a hand-made 4.0 leg against the execution's real
59.0. Quoted 719.74, charged 601.02.

The preview was wrong. The execution was **also** wrong — it had been under-collecting a designed-in
fee on *every special link ever created*. That is a revenue defect, not a quoting defect, and it is
why the entry was escalated to an owner ruling rather than repaired on sight: there was no way to
tell from the code which of the two numbers was the intended one.

### The invariant, and its documented escape hatch

`IGNIS-PRICING.md` §5 states the guarantee as *"it is called inside the execution path for billing
AND served to the UI for preview, so the two cannot drift."* The project's own defect ledger
(§5 item 18) records that this is **not architecturally true**, and names the exception:

> **SWPLC is *variant-B*** — the execution path builds its cumulator **inline**, and the `URCi_`
> reader is a **parallel reconstruction**. Both sides must always be edited together.

That escape hatch, plus an `INFO_` layer free to hard-code `NoStoaCosts`, **produced six of the
seventeen §1.1a defects.** The ledger's proposed wording is the honest one and this book adopts it:
*the two cannot drift **where the execution path calls the reader***.

### And a shape that survived a green pipeline

`B-01`, from the pricing walk rather than from measurement, because it is the clearest statement of
what a test suite does not do. `DPDC-MNG::URCi_Control` and `URCi_WipeNonce` were already branchy —
`(if son (BigCumulator) (BiggestCumulator))` — and the migration script replaced only the **first**
tier call it found. So `son=true` got the new price and `son=false` silently kept the old one.

> *"ZALL stayed green throughout: the code is syntactically valid and merely charges the wrong
> number, which no existing test asserted."*

The remedy was a detector with one rule — *flag any `URCi_*` whose body contains **both**
`UC_IgnisPrice` and a `UDC_*Cumulator`*, meaning it is half-rewritten — and a dedicated suite,
`REPL/Stage_02/[6.1.9]_PRICE-SWEEP.repl`, which exists specifically for this defect and asserts every
`son`-taking reader **twice**, once per fungibility side. **[VERIFIED by command]** it carries 64
assertions.

---

## 6. Coverage of the measurement — and what its denominator excludes

This is the section that matters, because the project's headline claim for this phase is a coverage
claim.

`REPL/tools/_info_measured.py` answers *"how many previews have been measured against a real
charge?"* Its proxy is stated in its own docstring and is deliberately generous in one direction: a
preview counts as measured when its name appears, uncommented, inside a `begin-tx` block that also
extracts `"ignis-need"` or `"stoa-need"`. **[VERIFIED by command]**, run today:

```
cost previews declared : 410   (ClientInfo-returning only)
  INFO-internal helpers:   9   (called by another preview; exercised transitively)
  CLIENT-FACING        : 401   <-- the denominator the owner's rule is about
MEASURED (cost proof)  : 401
named but NOT measured :   0
client-facing, NEVER named: 0
```

**401 of 401.** That is a real result and the instrument is unusually well-documented: it states its
proxy, states which direction the proxy is generous in, and tells the reader to treat the number as
an upper bound.

**But 401 is not the number of cost previews in the tree, and the tool cannot say so.**

**[VERIFIED by reading]** `_info_measured.py` enumerates its subject as a hardcoded three-file list:

```python
PREVIEW_SOURCES = [
    "../1_SOVEREIGN/STAGE_01/Z_Reads/02_INFO-ONE+.pact",
    "../1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact",
    "../1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact",
]
```

Those three hold 412 of the tree's 426 `INFO_` implementations. The other **14** live in CODEX (4),
PYTHIA (4) and the five citizen launchpad sale modules (6) — and **[VERIFIED by command]** every one
of the 14 returns `object{OuronetInfoV2.ClientInfo}`. They are cost previews by the tool's own
definition, and they are outside its denominator by construction.

So I applied the tool's own rule to the 14 by hand. **[VERIFIED by command]** — the same
`begin-tx` / `ignis-need` proxy, over the same non-archived `.repl` corpus:

| preview | named in a gated `.repl` | measured |
|---|---|---|
| the four `INFO_CODEX\|*` | yes | **yes** |
| the four `INFO_PYTHIA\|*` | yes | **yes** |
| `INFO_BuySparks`, `INFO_RedeemSparks` (SPARK) | yes | **yes** |
| `INFO_BuyStoicPay` (STOICPAY) | yes | **yes** |
| `INFO_Acquire` (SNAKES **and** CUSTODIANS, both measured in `launchpad-groundtruth.repl`) | yes | **yes** |
| **`INFO_Collect`** — `2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact:510` | **no** | **no** |

**Thirteen of the fourteen are measured anyway.** The result is therefore not that the project
overstated its coverage by much — it is that:

> **The honest figure is 414 of 415, not 401 of 401, and the single hole is in the one place the
> instrument is structurally unable to look.**

`STOAICO::INFO_Collect` appears in no `.repl` file in the suite, gated or otherwise. That is one
unmeasured cost preview on a live citizen sale, and it will stay unmeasured for as long as the
instrument's subject is a list rather than a search — because *a hardcoded list cannot report its
own incompleteness.* Part III, Chapter 4 records the same failure mode in `_toolpaths.py` and the
remedy that was applied there: make the checker **discover** its subject and report any directory
its list does not cover. The same remedy fits here, and has not been applied.

### The instrument is also not in the gate

**[VERIFIED by reading]** `REPL/tools/_gate.py` runs twelve static checks as fatal pre-checks. Every
tool in `REPL/tools/` that has a `--check` mode is one of them. **`_info_measured.py` has no
`--check` and no `--selftest`** — the gate byte-compiles it and moves on.

That is not an oversight in the same class as a missing check; there is nothing to check against,
because the tool prints a census rather than asserting a threshold. But it does mean the project's
own stated rule, written in `_gate.py`'s own comments, is not satisfied for its Phase-1.2 headline:

> *"A number quoted in an audit document as evidence of a repair must be one the gate RE-DERIVES on
> every run. Otherwise it is a claim about the past, and the repair it certifies can be undone
> without anything going red."*

**401/401 is a claim about 2026-09-15.** Deleting every `ignis-need` assertion from
`launchpad-groundtruth.repl` tomorrow would turn nothing red in the gate. Chapter 4 returns to this,
because the same is true of five other coverage instruments.

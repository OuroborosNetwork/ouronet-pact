# Part II · Chapter 3 — Splitting a module that could no longer be deployed

> Source records: `OuronetInformational/MODULE-SIZING.md` (the rule),
> `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/Audit/FVT-SPLIT-DESIGN.md` and `FVT-SPLIT-MANIFEST.md` (the
> design and the verified move-list), `OuronetInformational/DEPLOY-READY-GATE.md` (the measured
> outcome), and commits `43c0ea6` → `b37c08e` (2026-09-03).

This is the shortest phase in the round and the only one with a hard blocker behind it: one sovereign
module had grown past the point where any transaction containing it could be mined.

---

## 1. Why there is a ceiling at all

Chainweb charges a transaction for its size, and **the size charge grows as the seventh power** of
that size. `MODULE-SIZING.md` tabulates the consequence against StoaChain's 2,000,000-gas block
limit:

| lines | size charge | exec | total | % of block | size as % of its own cost |
|---:|---:|---:|---:|---:|---:|
| 2,000 | 1,569 | 101,463 | 103,032 | 5.2% | 1.5% |
| 3,500 | 20,944 | 177,560 | 198,503 | 9.9% | 10.6% |
| 4,500 | 112,188 | 228,291 | 340,479 | 17.0% | 33.0% |
| 5,500 | 449,422 | 279,022 | 728,444 | 36.4% | 61.7% |
| 6,635 | 1,669,856 | 336,805 | 2,006,661 | 100.3% | **CANNOT DEPLOY** |

Read the last column. At 6,000 lines, 73% of what you pay is *the mere fact of being large*.

Two properties turn that curve into a design rule rather than a curiosity:

- **Every Pact upgrade redeploys the whole module.** A one-character fix in a 6,477-line module costs
  1,733,784 gas — not once, every time, forever. A module's line count is a **permanent tax on every
  future change**.
- **You cannot split your way out afterwards**, because **Pact tables are module-scoped**.
  `(create-table FVT|T)` binds that table to that module and no other module can adopt it. Splitting
  a *deployed* module with live data means new tables plus a migration, and the old data stays where
  it is.

> The failure mode to design against is: **unable to upgrade, and unable to split your way out of
> being unable to upgrade.**

The bands, and they are the project's own:

| band | lines | action |
|---|---|---|
| Target | under 3,500 | fine |
| Acceptable | 3,500 – 4,000 | only **with a plan** |
| Warning | 4,000 – 4,500 | **start designing the split now** |
| Danger | above 4,500 | **split before deploying** |
| Impossible | ~6,635 | cannot be deployed at all, ever |

And the rule for *where* to cut, which the round followed and which is the reason this chapter is not
about line counts: **split by capability, never by line count.** Capabilities are module-scoped in
Pact — that scoping is a real security boundary, and it was the subject of a critical vulnerability
fixed at block 516,500, where `compose-capability` could reach across module boundaries without the
module guard. Anything sharing a `defcap` belongs in the same module; tables go with the module whose
capabilities guard writes to them; and that choice is **permanent**.

---

## 2. The blocker

**[VERIFIED by command]** — `git show <rev>:…/04_FVT.pact | wc -l`:

| when | lines |
|---|---:|
| 2026-08-27, when the rule was first applied | 6,694 — already **past** the ~6,635 cliff |
| 2026-08-30, start of this round | 6,781 |
| 2026-09-03, after the canon let-staircase pass added ~800 whitespace lines | 7,249 → **7,527** |
| immediately before the split (`5a453d8^`) | **7,527** |

FVT loads fine in the REPL, which does not enforce the block cap. It could not be deployed or
upgraded on chain. That is a pre-mainnet blocker of the worst kind, because it gets structurally
harder the moment the module holds live data.

---

## 3. The seam, and how it was chosen

The design (`FVT-SPLIT-DESIGN.md`) reads as an **accountant** and an **estate registrar**:

- **`RPS`** — the reward-per-share ledger and all the arithmetic that moves it. A pure leaf: inputs
  in, ledger writes out. Deploys **first**, carries **its own `SECURE`**.
- **`FVT`** — the farms/vaults/treasuries themselves, their ownership, configuration and topology,
  vacate/sweep, and **every client entrypoint**. Deploys second, keeps the name.

Three things about the method are worth extracting, because they generalise past this module:

**The seam was measured, not argued.** `REPL/tools/_fvtsplit.py` classified all 407 definitions by
which tables they transitively touch: **79 RPS-only, 164 FVT-only, 77 SEAM (touch both), 87 FREE (no
table)**. The manifest's key result is a single sentence: *"0 functions directly touch both domains"*
— so no atomic cross-domain write transaction had to be untangled, and all coupling was at the
call-graph level.

**The first cut was wrong and the measurement said so.** A ledger-only extraction left FVT at
6,435 lines and ~84% of the gas budget — deployable, with no headroom — because the reward-settlement
orchestration reads `ScoreEntityLink` throughout (36 functions). The revision moved the reward
*distribution topology* with the ledger. *The seam that looks right on a diagram is not necessarily
the one the call graph has.*

**A cycle was found before it was built, and resolved by moving data rather than code.** The
orchestration writes five aggregate fields that live on `FVT|T` — if it moved to RPS, those writes
would be RPS→FVT, a dependency cycle. The fix was a new RPS-owned table `FVT|T|RewardAggregate`
holding seven denormalised fields, so `FVT|T` keeps only identity and configuration and RPS stays a
clean leaf. That is a **permanent data-model decision taken because tables cannot move later** — the
right time to take it, and the design says so explicitly.

The resulting dependency graph is acyclic by construction: `RPS → {IGNIS, DALOS, DPTF, SCORE-reads}`,
`FVT → RPS::XE_`. RPS never reads an FVT table; the structure fields the arithmetic needs are
computed by FVT and **passed as arguments**. And the hot-path risk — cross-module calls cost gas per
call — is neutralised structurally: **loops live inside RPS**, so a settle/inject/collect pass
crosses the boundary once per *phase*, never once per *user*.

---

## 4. What shipped, against what was designed

**[VERIFIED by command]**. This is the part the design documents do not reconcile, and it is the
chapter's main finding.

| | designed | shipped (`b37c08e`, 2026-09-03) | today (HEAD) |
|---|---:|---:|---:|
| `RPS` | ~3,288 lines | **5,617** | **5,621** |
| `FVT` | ~2,765 lines | **3,878** | **3,977** |
| combined | ~6,053 | **9,495** | 9,598 |
| the monolith it replaced | 7,527 | 7,527 | — |

Two facts follow, and both are verifiable in one command:

**The split added 1,968 lines — 26% — to the codebase.** That is not waste; it is the price of a
module boundary, and the commit message itemises it: **33 `XE_` SECURE-granting writer wrappers** so
FVT can mutate the ledger through a guarded entrypoint, **53 facade re-exports** so every existing
reader call site and the entire test corpus stay byte-identical, and the policy plumbing (`P|T`,
`P|MT`, the IMC machinery) duplicated because it is per-module infrastructure rather than domain
data. **[VERIFIED by command]** — 53 FVT functions call `RPS.` directly in the tree today, matching
the facade count.

**`RPS` landed 71% larger than designed, in the project's own Danger band.** `MODULE-SIZING.md` §1
says of anything above 4,500 lines: *"split before deploying."* The design anticipated a risk here —
Risk 3, *"if FVT lands over ~3,900 lines, shift the `UC_` compute helpers"* — but it was written
against the wrong half, and the half that overran was RPS.

**The project recorded this honestly rather than rounding it away.** `DEPLOY-READY-GATE.md`, written
the next day, publishes the distribution with RPS labelled **`danger`** in its own table and reports
`(5617/6635)^7 × 2M ≈ 624K` gas against the 2M cap. The verdict it draws is *"deploy-ready"*, and
against the **cliff** that is correct: nothing is undeployable. Against the **band rule** in the same
project's sizing document, it is not — and against §5's guidance that *"if size is more than ~25% of
your total, the module is too big regardless of whether it fits"*, RPS at 5,621 lines sits at roughly
62% size share by the document's own table. **[INFERRED]**, by interpolation in that table; not
measured on chain.

### The band census today

**[VERIFIED by command]** — `find 1_SOVEREIGN 2_CITIZEN -name '*.pact' -not -path '*/Audit/*' |
xargs wc -l`, classified against `MODULE-SIZING.md` §1:

| band | n | modules |
|---|---:|---|
| **Impossible** (>6,635) | **0** | — |
| **Danger** (>4,500) | **1** | `04_RPS.pact` **5,621** |
| **Warning** (4,000–4,500) | **2** | `02_SCORE.pact` 4,283 · `02_INFO-ONE+.pact` 4,199 |
| **Acceptable** (3,500–4,000) | **3** | `05_FVT.pact` 3,977 · `06_VCT.pact` 3,508 · `03_AQP.pact` 3,507 |
| **Target** (<3,500) | **87** | |
| | **93** | |

Against the same census on 2026-09-04: `SCORE` 4,122 → 4,283, `FVT` 3,878 → 3,977, `AQP` 3,421 →
3,507 and `VCT` 3,377 → 3,508 — the last two crossing out of Target. `INFO-ONE+` shrank, 4,450 →
4,199. **Six modules are outside the Target band and the number is rising**, which is the expected
consequence of adding a cost reader and a preview to every operation.

---

## 5. What Phase 1.4 did not finish

The roadmap lists three steps. **[VERIFIED by reading]** the tree, one is done and two are not:

| step | status |
|---|---|
| **1.4.1.1** split `04_FVT.pact` along a capability seam | **done** — `04_RPS.pact` exists, the seam is a capability seam, the DAG is acyclic, the suite was green across the flip |
| **1.4.1.2** re-audit POOL/SCORE/ANK/VCT once their `URCi_`s are in; **split any in Warning/Danger** | **not done** — `SCORE` is in Warning and `RPS` is in Danger; no further split has been designed |
| **1.4.1.3** update `MODULE-SIZING.md`'s applicability table with post-`URCi` measurements | **not done** |

The third is the one with a trap in it. `MODULE-SIZING.md`'s applicability note still reads:

| module | lines | band |
|---|---|---|
| `…/03_AQP/04_FVT.pact` | **6,694** | **IMPOSSIBLE** |
| `…/03_AQP/05_VCT.pact` | 3,023 | Target |
| `…/03_AQP/08_AQP-INFO.pact` | 1,178 | Target |

**All three filenames are pre-renumber.** `04_FVT.pact` no longer exists; `05_VCT.pact` is now
`06_VCT.pact` at 3,508 lines; `08_AQP-INFO.pact` is now `09_AQP-INFO.pact`. So the document that
states the sizing rule still describes a blocker that was cleared two weeks ago, under paths that
resolve to nothing. A reader arriving at the rule is told the worst module is undeployable and
pointed at a file that is not there.

---

## 6. The second split, and a stale line it left in the governing document

The round performed a **second** split along a different axis, and it is worth recording because it
is a split for *authorisation* reasons rather than size ones.

The launchpad Talos orchestrator was one module doing two jobs: composing the per-asset citizen sales
(a citizen-role concern) and orchestrating the sovereign DEMIPAD launchpad rules. Commit `ae1f9b6`
(2026-08-31) cut it in two, and `git` records the move as a rename plus an addition:

```
R057  2_CITIZEN/6_Launchpad/99_TS02-DPAD.pact  ->  1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact
A     2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact
```

**[VERIFIED by command]** — both files exist at those paths today, and no
`2_CITIZEN/7_Launchpad/99_TS02-DPAD.pact` does.

`CLAUDE.md` describes the outcome **twice, and the two descriptions disagree**:

- Line 109 (the repository layout table) is **correct**: `99_TS02-CPAD.pact` is the *citizen*
  launchpad Talos; *"the **sovereign** launchpad Talos moved to
  `1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact`"*.
- Line 122 (the Sovereign-vs-citizen architecture section) still says
  *"`2_CITIZEN/7_Launchpad/99_TS02-DPAD.pact` is the **sovereign** Talos orchestrator … co-located
  with the launchpad for readability, but sovereign-role and deployed last."*

The second names a file that does not exist, and describes an arrangement — sovereign code living in
the citizen tree — that the split exists to have ended. A reader who takes line 122 at face value
concludes that the sovereign/citizen boundary is a labelling convention rather than a directory.

---

## 7. What the split cost in coupling, measured

**[VERIFIED by command]** — cross-module calls written as `MODULE.fn` dot-notation rather than as a
module reference `(ref-M::fn …)`, counted over `1_SOVEREIGN` + `2_CITIZEN` with comments and strings
stripped:

| | 2026-08-30 | today |
|---|---:|---:|
| cross-module dot-notation call sites | **38** | **275** |

Where the 237 new ones are: `06_VCT.pact` 0→85, `09_AQP-INFO.pact` 26→78, `05_FVT.pact` 0→53 (the
new shell), `08_DSA.pact` 0→25, `04_RPS.pact` 0→13, `07_MTX-AQP.pact` 0→8, `99_TS02-CPAD.pact` 0→1.
**262 of 275 are in the AQP family**, and the growth is the direct consequence of two things this
round did: splitting FVT (so VCT, DSA, MTX-AQP and the new FVT shell must now reach reward state in
another module) and building the preview layer (so AQP-INFO must reach every cost reader).

`CLAUDE.md`'s deployment section states the convention plainly:

> *Cross-module calls use **module references** with `::` (e.g. `(ref-M::some-fun …)`), not
> `module.function`, so only the used interface members matter for coupling.*

**[INFERRED]**, from the same document's own upgrade note rather than from an experiment this book
ran: `::` modref dispatch is live, so an in-place sovereign upgrade reaches every `::` caller with no
`bless`, while a `.` reference is a hash pin. On that basis the round added 237 hash-pinned
sovereign-internal dependencies. The consequence is bounded — these are all our own modules, and
re-deploying a caller is a normal operation — but it is a consequence, it is concentrated in the
largest and most-upgraded family in the codebase, and it is not recorded in any of the three split
documents.

It also had a measured cost inside the round itself. `_ignis_price_sheet.py` could not see
dot-notation calls at all, which is one of the four blind spots that left 18 live client entrypoints
with no published price while the generator's footer reported `0 unresolved` (Chapter 2, §5).
*A convention that a tool does not implement is a convention the tool is blind to.*

---

## 8. What this chapter does not establish

- **The deploy-gas figures are extrapolations, not chain measurements.** `RPS load-exec 362K / FVT
  250K` came from the REPL's `table` gas model, which measures runtime load execution, not
  Chainweb's size formula; `~624K` and `~47K` are `(lines/6635)^7 × 2M`. Both are stated as such in
  the source documents. Nothing has been deployed to a chain to check them.
- **No claim is made that the seam is optimal.** It is acyclic, it is capability-aligned, it is
  measured, and it works. Whether a different cut would have produced two Target-band modules instead
  of one Danger and one Acceptable is not something this book can answer, and the design's own
  measurement pass rejected the two obvious alternatives (ledger-only, and accessor-split) as
  unviable rather than as inferior.
- **The `FVT|T|RewardAggregate` denormalisation is permanent and untested against migration.** It was
  taken pre-mainnet precisely so that no migration is needed. If the module is ever deployed and the
  seven fields turn out to be on the wrong side, the remedy is a migration, not an edit.

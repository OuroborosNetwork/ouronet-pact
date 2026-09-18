# Part I — The Module Audits

> Six per-module audit rounds, run 2026-08 through 2026-09, before the main-work round of Part II.
> Source material: the `…/Audit/*` trees, **31,438 lines across 50 files** (31,346 in the 49 `.md`
> files). *Re-measured 2026-09-18; this read 31,225. Three commits on 2026-09-17 edited files inside
> those trees, one of them the AQP design-document correction described below.*
> **Every chapter carries a verification pass dated 2026-09-17** — each fix recorded as FIXED was
> re-checked against *current* source, not taken from the audit's own word.

| # | module | what it is | findings | source |
|---|---|---|---:|---|
| 1 | **DALOS** | accounts, guards, governance, the gas station | **88** | `Audit/module-audits/DALOS/` |
| 2 | **ATS** | autostake pools — staking, indices, recovery | **35** | `Audit/module-audits/ATS/` |
| 3 | **SWP** | the AMM — pools, routing, swaps, liquidity | **83** | `Audit/module-audits/SWP/` |
| 4 | **DPDC** | collectables — collections, nonces, sets, fragments | **58** | `Audit/module-audits/DPDC/` |
| 5 | **DEMIPAD** | the launchpad — asset sales, custody, the ICO vault | **17** | `Audit/module-audits/DEMIPAD/` |
| 6 | **AQP** | acquisition pools — anchors, scores, rewards, vaults | **33** | `Audit/module-audits/AQP/` |
|  |  | | **314** | |

## How these audits were run

All six followed the same shape, and the shape is worth stating because it determines what the
numbers in the table above mean.

**Scope was fixed in writing before the reading began.** Each audit opens by naming its modules, its
utilities, the Talos wiring that exposes them, and the interfaces involved. ATS, for instance, scoped
two core modules, two utility modules, four Talos modules and six interfaces. A finding outside that
scope was recorded but not counted, which is why the per-module totals are comparable to each other.

**Two rounds, with an owner decision between them.** Round I raised findings and stopped. It did not
fix anything. The output was a ranked issue list, which the owner reviewed and ruled on — the
`ROUND-01-OWNER-FEEDBACK.md` in each tree is that ruling. Round II then implemented the fixes the
owner accepted. The separation matters: an auditor who fixes as they read inevitably stops raising
the findings that are inconvenient to fix, and the ruling step forces every finding to be
adjudicated on the record rather than quietly dropped.

**A finding has one of four dispositions**, and all four are counted in the totals:

| disposition | meaning |
|---|---|
| **fixed and proven** | repaired, with a REPL regression test that goes red if the repair is reverted |
| **closed as not-a-bug** | investigated and found to be intentional design, with the reasoning recorded |
| **deferred** | confirmed real, deliberately not fixed now, with the reason and the trigger stated |
| **open** | none. Every audit closed with zero |

ATS is representative: 35 raised, 19 fixed and proven, 13 closed as intentional, 3 deferred — two to
a planned module rehaul and one tracked as a hard prerequisite for deployment. **A third of the
findings in these audits were not defects**, and reporting them anyway is deliberate. A finding
closed as intentional is a piece of design rationale that now exists in writing, and the next reader
who has the same suspicion can stop in one minute instead of one day.

**Severity is on the id, not in a column.** The id schemes differ by module — SWP writes `#65bL` and
`#32bM`, AQP writes `C1` / `H4` / `S4` — but in all of them the letter is the severity class, so a
finding cannot be referred to without its severity coming along. The inconsistency between schemes
is a real wart, and it is what makes the two count discrepancies below unresolvable by pattern
matching.

**Each audit named its priority target before starting.** ATS's was whether removing and re-adding a
reward token preserves accounting for stakers whose positions predate the change. It does not, in
three independently confirmed ways sharing one root cause. Naming the target in advance is what
separates an audit from a reading: it creates something the audit can *fail* to find, and therefore
something its silence would mean.

**Then, months later, every FIXED was re-checked.** That pass is the next section, and it is the
part of Part I with the most to say — because re-checking an audit's own word against current source
is not a formality, and this one found four different ways that word had become unreliable.

## Independent corroboration of the counts (2026-09-17)

The per-module totals above were re-derived from the audit trees by a **different method** than the
chapters used — counting distinct finding ids in the source `.md` files rather than reading the
trackers:

| module | chapter | independent count | |
|---|---:|---:|---|
| DALOS | 88 | **88** | exact |
| ATS | 35 | **35** | exact |
| DPDC | 58 | **58** | exact |
| DEMIPAD | 17 | **17** | exact |
| SWP | 83 | 82 | within 1 |
| AQP | 33 | 36 | differs by 3 |

**The two that differ are the two with irregular id schemes** — SWP uses letter-suffixed ids
(`#65bL`, `#32bM`) and AQP uses a bare class-letter form (`C1`, `H4`, `S4`) that a pattern also
matches in prose. **The independent method is cruder than the chapters', so the chapters' figures
stand**; this is corroboration, not a correction, and the two gaps are recorded rather than
reconciled away.

> An attempt to audit the chapters' findings *tables* row-by-row was abandoned: the six chapters use
> different table shapes, and a single regex produced obvious nonsense on three of them (0 rows where
> there are dozens). A measurement that cannot be trusted is not reported as a number — which is the
> book's third rule applied to the book's own audit.

`REPL/tools/_booktables.py` gates only what it can check **exactly**: that the two headline tables
sum to their own totals, and that Part III's total matches the attack register in the tree.

## What the verification pass found

### The headline is a positive one

**Of the hundreds of fixes recorded as FIXED, essentially all are present in current source** — and
that held through four intervening whole-tree rewrites: an interface version cascade, the Part II
pricing rehaul, a syntax-convention sweep, and a module split forced by the deploy-size ceiling.
Three fixes were briefly invisible to a search on the audit's own wording because they had been
**renamed, not deleted**.

The mechanism that made this checkable at all is a convention: fixes carry a source comment naming
the finding (`DPDC Audit #NN`). There are **51** such markers in DPDC — and **zero** in one module,
which is the one module where verification had to fall back to behaviour and where the single
unresolved question remains.

> **Corrected 2026-09-18.** This also said *"and 30 in AQP"*. The DPDC figure re-derives exactly;
> the AQP one does not, under any marker convention found in the tree — there is no `AQP Audit #NN`
> form, and a case-insensitive `audit` over `03_AQP/0*.pact` totals 25. The figure is withdrawn
> rather than replaced, because what it was counting is not recoverable. AQP's fixes *are* annotated
> (`audit finding #15M / M6`, `L7 #19`, and so on), just not to one pattern.

### One fix was genuinely gone

The SWP audit's `M14` archived two frozen historical interfaces. A later automated sweep deleted
them, because **zero references is the defining property of a deliberately-frozen archive** and the
tool's heuristic was "zero references means dead". Investigated in full and closed as **superseded,
not reopened**: a dated convention amendment had retired the frozen-copy practice the same day, and
a restored archive cannot be both loadable and historical under this codebase's cascade rule.

### Two verdicts rested on premises that had been retracted

- **SWP `M11`/`M12`** were closed as DESIGN on the grounds that a module family had *"zero client
  wiring — unreachable"*. That premise was retracted three weeks earlier and the verdicts were never
  revisited. Reopened during this work, proven **live by execution**, and fixed. {{ch:defects}}.
- **DALOS `H14`** fixed a constant chosen as *"mainnet's approximate KDA/USD price"*. After a
  protocol-wide rename that constant now serves as the **STOA**/USD price, unchanged. Nothing in the
  tree asserts the two coincide. Flagged, not fixed.

### And a class of fix that was present but unwitnessed

Eleven fixes — including **two** critical-ranked findings, ATS `C2` and DALOS `C3` — were present in
source with **nothing in the running suite that would go red if they were reverted**. Their proofs
were written into scratch harnesses that now sit in an archive directory the gate excludes by name.

> **Corrected 2026-09-18.** This said *"Around ten fixes — including one critical-ranked
> finding"*, while the table below lists eleven rows and marks two of them critical.

> SWP is the near-exception: eight of its nine proof tags survive, **because they were written into
> the canonical suite files rather than into scratch harnesses.** That is a filing decision, not a
> rigour one, and it is the single largest difference in durability between these six rounds. The
> ninth, `SWP|TX 015b`, is the counter-example — it lives in a canonical suite file that
> `_gate.py` excludes by name, so being filed well is necessary and not sufficient ({{ch:swp}}).

**All eleven are now closed**, as this book was assembled:

| finding | what the witness had to do |
|---|---|
| ATS `C2` (critical) | drive the **all-zero** object the removed gate *rejects*, and show it is reshaped anyway |
| ATS `#6H` | lock a pool, then show the **same owner** is refused on both setters |
| ATS `#32N` | drive a cull from an account that has a ledger row but nothing ripe — one with no row dies earlier, elsewhere |
| ATS `#5C` | none of the usual owner's pools has a Hot-RBT; the fixture that does is owned by a third account, which makes the refusal *more* legible |
| DALOS `C3` (critical) | hand a duplicated **nonce** list to all three capabilities — the message was already asserted, at other call sites |
| DALOS `H3` | two **distinct** smart-account interactors, or compression merges the legs and the fix's branch is never entered |
| DALOS `M5` | a batch whose first leg removes the collateral the second leg's overdraft depends on |
| DALOS `M6` | the return value cannot change, so the witness is **gas**: the reader must cost no more than its pure-read sibling |
| DALOS `M7` | the source said it was unreachable; measurement showed a **partial** shadow, and the guard was hoisted |
| DALOS `M1` | read the ledger table that no test had ever read |
| DALOS `N2` | drive the **Talos wrapper**, not the core — the existing test pinned a different guard entirely |

> Not one of them was closed by a straightforward test. Every case needed a specific input, fixture
> or measurement that distinguishes the fixed code from the reverted code — and in four of them a
> first attempt passed while proving nothing. That is the argument for the book's second rule:
> *every fix names the assertion that would go red if it were reverted.* Without it, a fix and a
> claim look identical six weeks later.

### Two audits' own arithmetic did not add up

One tracker states *"FIXED: 19"* and enumerates 18, with a compensating error elsewhere so that the
**total reconciles**. A total that reconciles is precisely why nobody re-counted the parts.

### And two design documents understate the shipped code

Both in the AQP tree. One declares an operational constraint — an anchor *"locked forever"* until an
unwind is built — that has not applied since the unwind shipped, through two client doors. **A reader
consulting it would plan around a permanent lock that does not exist.** Corrected, with the original
preserved.

> Checking each identifier **by exact name** mattered here: the first pass flagged four stale claims
> in those documents and only **two** survived, because two had been matched against similarly-named
> functions that do exist but are different mechanisms.

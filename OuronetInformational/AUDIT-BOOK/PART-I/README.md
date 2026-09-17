# Part I — The Module Audits

> Six per-module audit rounds, run 2026-08 through 2026-09, before the main-work round of Part II.
> Source material: the `…/Audit/*` trees, 31,225 lines.
> **Every chapter carries a verification pass dated 2026-09-17** — each fix recorded as FIXED was
> re-checked against *current* source, not taken from the audit's own word.

| # | module | what it is | findings | source |
|---|---|---|---:|---|
| 1 | **DALOS** | accounts, guards, governance, the gas station | **88** | `STAGE_01/2_Core/Audit/DALOS/` |
| 2 | **ATS** | autostake pools — staking, indices, recovery | **35** | `STAGE_01/2_Core/Audit/ATS/` |
| 3 | **SWP** | the AMM — pools, routing, swaps, liquidity | **83** | `STAGE_01/2_Core/Audit/SWP/` |
| 4 | **DPDC** | collectables — collections, nonces, sets, fragments | **58** | `STAGE_02/2_Core/01_DPDC/Audit/` |
| 5 | **DEMIPAD** | the launchpad — asset sales, custody, the ICO vault | **17** | `STAGE_02/2_Core/02_DEMIPAD/Audit/` |
| 6 | **AQP** | acquisition pools — anchors, scores, rewards, vaults | **33** | `STAGE_02/2_Core/03_AQP/Audit/` |
|  |  | | **314** | |

## What the verification pass found

### The headline is a positive one

**Of the hundreds of fixes recorded as FIXED, essentially all are present in current source** — and
that held through four intervening whole-tree rewrites: an interface version cascade, the Part II
pricing rehaul, a syntax-convention sweep, and a module split forced by the deploy-size ceiling.
Three fixes were briefly invisible to a search on the audit's own wording because they had been
**renamed, not deleted**.

The mechanism that made this checkable at all is a convention: fixes carry a source comment naming
the finding (`DPDC Audit #NN`). There are 51 such markers in DPDC and 30 in AQP — and **zero** in one
module, which is the one module where verification had to fall back to behaviour and where the single
unresolved question remains.

### One fix was genuinely gone

The SWP audit's `M14` archived two frozen historical interfaces. A later automated sweep deleted
them, because **zero references is the defining property of a deliberately-frozen archive** and the
tool's heuristic was "zero references means dead". Investigated in full and closed as **superseded,
not reopened**: a dated convention amendment had retired the frozen-copy practice the same day, and
a restored archive cannot be both loadable and historical under this codebase's cascade rule.

### Two verdicts rested on premises that had been retracted

- **SWP `M11`/`M12`** were closed as DESIGN on the grounds that a module family had *"zero client
  wiring — unreachable"*. That premise was retracted three weeks earlier and the verdicts were never
  revisited. Reopened during this work, proven **live by execution**, and fixed. Part III, Chapter 3.
- **DALOS `H14`** fixed a constant chosen as *"mainnet's approximate KDA/USD price"*. After a
  protocol-wide rename that constant now serves as the **STOA**/USD price, unchanged. Nothing in the
  tree asserts the two coincide. Flagged, not fixed.

### And a class of fix that was present but unwitnessed

Around ten fixes — including one **critical**-ranked finding — are present in source with **nothing
in the running suite that would go red if they were reverted**. Their proofs were written into
scratch harnesses that now sit in an archive directory the gate excludes by name.

> SWP is the exception: all nine of its proof tags survive, **because they were written into the
> canonical suite files rather than into scratch harnesses.** That is a filing decision, not a
> rigour one, and it is the single largest difference in durability between these six rounds.

The critical one is closed (Part III records how). The rest are being closed as this book is
assembled — which is the argument for the book's second rule: *every fix names the assertion that
would go red if it were reverted.* Without that rule, a fix and a claim look identical six weeks
later.

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

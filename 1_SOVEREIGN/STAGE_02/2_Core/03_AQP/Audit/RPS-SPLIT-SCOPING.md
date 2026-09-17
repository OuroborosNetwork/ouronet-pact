# `04_RPS.pact` — split scoping

> **Status: SCOPED, NOT DESIGNED. Needs an owner decision.**
> Written 2026-09-17 for roadmap subphase 1.4.1.2, which 1.7.2.1 (deploy-ready gate) depends on.
> Every figure below is measured from the tree; the method is stated with each.

## The problem

`MODULE-SIZING.md`'s bands are in **lines**, calibrated to **StoaChain's 2,000,000 block gas
limit** (not Kadena mainnet's 150,000 — different chain, different limit, different unit).

| band | threshold | modules |
|---|---|---|
| Danger — *"split before deploying"* | > 4,500 | **`04_RPS` 5,621** |
| Warning — *"start designing the split now"* | 4,000–4,500 | `02_SCORE` 4,284 · `02_INFO-ONE+` 4,200 |
| Acceptable | 3,500–4,000 | `05_FVT` 3,978 · `06_VCT` 3,509 · `03_AQP` 3,508 |
| Target | < 3,500 | the other 87 |

RPS is the module the FVT split *created*: `04_FVT.pact` was 7,527 lines and became RPS 5,621 +
FVT 3,978. **The split relieved FVT and left its larger half above the line.**

## Finding 1 — there is no table seam

Pact tables are **module-private**, so a split must partition the *tables*; functions cannot be
moved away from storage they use without exposing every table through an interface.

Measured over all 339 functions, with table reach computed **transitively** through intra-module
calls (a direct-reference count says 103 functions touch a table; transitively it is **284**, and
the direct figure would have produced a wrong design):

- The **15 substantive tables form ONE connected cluster** — for every pair, some function reaches
  both. There is no natural boundary.
- Exhaustive search of all 2-way partitions: the best cut peels off a single table
  (`FVT|T|ForcedFixCount`), relieving **47 lines** while **73 lines straddle**. Every other
  partition is worse. **The best available split makes the module bigger.**
- Only **55 functions (708 lines)** are genuinely table-free.

## Finding 2 — trimming prose does not reach the band either

RPS is **7% `;;` comment lines** (415 of 5,622). Stripping every comment leaves **5,207 lines** —
still 707 above the Danger threshold. There is no documentation-weight remedy.

## What this leaves

The mechanical options are exhausted, so the remaining ones are decisions rather than refactors:

1. **Split along a functional seam and pay the cross-module cost.** Requires choosing which
   capability RPS loses, exposing the tables it still needs via `XE_` entrypoints, and accepting the
   interface cascade. Not costed here — costing it needs the seam chosen first.
2. **Re-examine the band for this module.** The thresholds are calibrated to deploy gas; RPS's
   actual deploy gas has not been measured against the 2,000,000 limit, only its line count against
   a proxy for it. **That measurement does not exist and would settle whether this is urgent.**
3. **Accept it with a recorded rationale**, as `00_DPMF` is accepted under a different rule.

> **Recommendation was: measure option 2 before designing option 1.** MEASURED, same day — and it
> changes the answer.

## Finding 3 — the real constraint has 5.6x headroom

The band is a **proxy** for deploy gas. The limit is gas. The suite already measures it and nobody
had read the number:

| module | deploy gas | share of StoaChain's 2,000,000 block limit |
|---|---:|---:|
| **RPS** | **353,662** | **18%** |
| FVT | 252,470 | 13% |
| VCT | 243,157 | 12% |
| SCORE | 229,505 | 11% |
| AQP | 203,552 | 10% |

*(Method: `cd REPL && pact modules/AQP.repl`, which deploys the family and prints each module's gas.
The lines were already there.)*

**RPS is the largest module in the system and uses under a fifth of a block.** The Danger band says
*"split before deploying"*; the constraint it stands for is not close to binding.

So the honest position is **not** "RPS must be split". It is: *the line-count bands are mis-calibrated
against the limit they were derived from*, and RPS is the module that exposes it. A threshold of
4,500 lines maps to roughly 280,000 gas here — **14% of a block** — which is a conservative proxy by
a factor of five or so.

> **The question 1.4.1.2 should answer is no longer "how do we split RPS" but "are the bands right".**
> One of those is a large refactor with an interface cascade behind it; the other is a calibration
> check against a number the suite already prints. The refactor was scoped first because the band
> said Danger, and the band was never checked against the thing it approximates.

## What was checked and found not to apply

- **Split reads from writes** — impossible in Pact without exposing every table; the read side would
  need an `XE_` entrypoint per reader, which adds more code than it removes.
- **Split by table cluster** — the clusters do not exist (Finding 1).
- **Trim comments** — 707 lines short (Finding 2).

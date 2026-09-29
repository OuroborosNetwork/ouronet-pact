# Deploy order

Ouronet does not deploy as one transaction. It deploys as **24**, in a fixed order, and the order
is not a convenience — it is forced by the language.

---

## 1. Why order is forced

Pact resolves a cross-module call **at deploy time**. A module that calls into another cannot be
deployed until that other module exists on chain. So the deploy sequence is a topological sort of
the dependency graph, and the layer cake (`01-the-layer-cake.md`) *is* that sort: utilities before
core, core before Talos, Talos before the read modules that describe it.

Get the order wrong and the transaction does not produce a subtly broken module. It fails
outright, naming the unresolved reference. That is the one failure mode in this chapter that
announces itself.

## 2. What the constraint is NOT

> **CORRECTION, and it is worth stating plainly because the wrong version is written in a lot of
> places, including this repository's own instructions until 2026-09-21.**
>
> The constraint is often given as a "~150k deploy **size** cap". That conflates two different
> things and makes the figure read as a byte limit on the emitted transaction. It is neither a
> byte limit nor Ouronet's.

The real figures:

| | per-transaction gas |
|---|---|
| Kadena | ~150,000 |
| **StoaChain** (Pact 5) | **~2,000,000** |

150k is **Kadena's gas budget**, and Ouronet is not on Kadena. Measured on the emitted
`Deploy/1_Pure/01_deploy.pact` — **316.6 KB, 7,222 lines** — the cost was **686.7K of 2.00M gas**
(execution ~275.5K plus size ~411.1K). A third of a megabyte deploys with two thirds of the budget
to spare.

So **deploy order is driven by dependency, not by bytes.** Splitting exists because module A must
exist before module B can name it — not because the bytes would not fit.

## 3. What the real byte ceiling is — unknown, and treated as such

The same measurement reported room for only ~1,274 more lines, implying a ceiling near 8,500
lines. That cannot be the gas limit either: scaling 686.7K by 8,496/7,222 gives ~808K, not 2.00M.
**Something else binds first, and nobody here knows what.**

The response is a cap justified by evidence rather than by a specification:

```python
DEFAULT_BUDGET   = 1_700_000     # of a 2,000,000 block limit
DEFAULT_MAXBYTES =   320_000     # conservative; 04_RPS.pact is 304,738 bytes and deploys
HEADER_RESERVE   =     6_000
```

`320,000` is not derived from a rule. It is derived from **a file that is known to work**: the
largest emitted transaction today is 303,996 bytes and it deploys. That is an honest basis for a
limit when the true one is unknown, and the tool says so in its own source.

### The reserve exists because a proxy was checked only advisorily

`HEADER_RESERVE` is the subtler lesson. The planner budgets on the size of the module **sources**;
what actually ships is sources + the generated header − whatever `create-table` forms upgrade mode
strips. Measured across 22 files, that delta ran from **−3,380 to +4,857 bytes**.

When the header grew — to list interfaces, modules and tables instead of file paths — two
transactions went over the cap, and **the only thing that noticed was a line of output in a
passing run.** The planner now reserves 6,000 bytes, and an emitted file over the cap is **fatal**
rather than printed.

> A proxy that is checked against the real thing is fine. A proxy whose check is advisory is not a
> budget.

## 4. The round, and what it excludes

```bash
python3 REPL/tools/_deploybundle.py --check
# module-deploy transactions : 24
# excluded by the round, with reasons (26)
```

`Deploy/` is **generated** from the sovereign sources and diffed on every gate run. Until
2026-09-19 it was the one generated artefact nobody checked, and the failure mode was specific:
edit a module, gate green, ship a batch that no longer matches the module it claims to deploy. The
check caught real drift within the hour it was added — two batches stale from a function reorder.

Alongside the main round sit three hand-deployed batches: `2_Init/` (5), `3_Assets/` (16) and
`PureV2/` (22, the one-at-a-time module upgrades).

**Twenty-six exclusions, each with a written reason** — not a silent omission. The categories:

- **empty interface holders** — 0 code lines; interfaces now live in the files that implement them
- **a separate chain** — the explorer and DPL-UR deploy on their own sequence, deliberately last
- **citizen minters** — deployed when minting, not as part of the core chain
- **the bridge scaffold** — CADUCEUS, not ready
- **held back pending confirmation** — `OuronetIdsV1`, the entity-id registry, because every
  literal in it predates the last full redeploy and none had been confirmed against chain. *"A
  registry exists so nobody has to re-check it, and it earns that only by being right the first
  time."*

## 5. What is actually running

Measured from the chain, not from the plan:

| | |
|---|---|
| modules deployed | **96** |
| declared in the repo but not deployed | **2** — `CADUCEUS` (scaffold), `DPMF` (archive mode) |

```bash
python3 REPL/tools/_livemodules.py --probe    # asks describe-module, caches by module hash
```

96 exceeds the round's 80 because the hand-deployed batches added the rest over time. That gap is
exactly why this documentation reads the chain rather than the plan: **the plan says what was
intended, and the chain says what happened.**

---

## Where to go next

- `07-interfaces-and-versioning.md` — the cascade rule, which is the other thing that forces order
- `03-the-module-map.md` — every module, by layer
- `../MAINTAINING.md` §2a — why live is the authority here

## Sources

- Gas ceilings and the 686.7K measurement: `CLAUDE.md`, *"Deployment order and interface
  versioning"*, corrected 2026-09-21.
- `DEFAULT_BUDGET`, `DEFAULT_MAXBYTES`, `HEADER_RESERVE`: `REPL/tools/_deploybundle.py` lines
  453–494, read 2026-09-29.
- Transaction count and exclusions: `python3 REPL/tools/_deploybundle.py --check` and
  `Deploy/MANIFEST.md`.
- Deployed module count: `Deploy/LIVE-MODULES.json`, probed from mainnet 2026-09-29.

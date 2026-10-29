# Deploy/PureV17 — DEPLOY CARD

**Everything needed to send this round is in THIS folder. It is THREE transactions, in order.**
No init step, no backfill, no configuration transaction, nothing from `Deploy/1_Pure`, `2_Init`,
`3_Assets` or `MANIFEST.md`. Ignore the `see Deploy/MANIFEST.md` and `Steps 1-N must have run
first` lines inside the transaction headers — boilerplate the planner emits for the from-scratch
pipeline, which does not apply to an upgrade round. This round has **no** preceding steps.

## Send these three, in this order, and stop

| # | file | deploys | exec gas (REPL) | bytes | size gas (est.) | total (est.) | of 2M |
|---|---|---|---:|---:|---:|---:|---:|
| 1 | `01_deploy.pact` | `RPS` | 372,386 | 318,758 | ~374,300 | **~746,700** | 37% |
| 2 | `02_deploy.pact` | `AQP-FVT` | 285,724 | 289,056 | ~188,700 | **~474,500** | 24% |
| 3 | `03_deploy.pact` | `TS02-C3` | ≤203,088 | 155,159 | ~2,400 | **~205,500** | 10% |

**Exec gas is MEASURED** in the REPL gas model by `_deploybundle.py`. **Size gas is ESTIMATED**
from the fitted law in `CLAUDE.md`, `gas_size(S) ≈ 95,225 × (S_KB/256)^7` — the seventh power is
why file 1 costs more in size than in execution and file 3 costs almost nothing. Set a limit with
headroom; none of the three is close to the ceiling.

File 3's exec figure is an UPPER BOUND: 203,088 is what the generator measured for batch 21, which
packs TS02-C3 *and* AQP-INFO. TS02-C3 alone is less. It is quoted as a bound rather than guessed
down.

## Why the order matters

Follow it. `RPS` first and `AQP-FVT` second is the canonical chain order
(`[2.3]_EarningPools.repl` loads 04_RPS at line 118, 05_FVT at 140), and `TS02-C3` is a Talos
client that calls into both. Nothing here changes an interface, so no modref has to be re-bound —
but deploying a caller before its callee has no upside and the chain order is already the answer.

## What each file is, and where it came from

| file | provenance |
|---|---|
| `01_deploy.pact` | byte-for-byte copy of `Deploy/1_Pure/17_deploy.pact` |
| `02_deploy.pact` | byte-for-byte copy of `Deploy/1_Pure/18_deploy.pact` |
| `03_deploy.pact` | **SLICED** from `Deploy/1_Pure/21_deploy.pact` — see below |

All three are in **UPGRADE MODE**: their `create-table` forms are commented out, because the
tables already exist and `create-table` on an existing table ABORTS the whole transaction.

### Why file 3 is a slice and not a copy

Batch 21 packs two source files and emits the `TalosStageTwo_ClientThreeV5` **interface** ahead of
them, because `Deploy/1_Pure/` is the FROM-SCRATCH chain. Neither belongs in an upgrade round:

- **the interface is already live** — the deployed `TS02-C3` implements V5, and Pact cannot
  redeploy an interface. Including it would abort the transaction.
- **`09_AQP-INFO.pact` is UNCHANGED by this round.** Shipping it would redeploy identical code,
  and at the seventh power that carries ~180,000 gas for no effect.

So file 3 is lines 469–3431 of `21_deploy.pact` — the `TS02-C3` module and its two commented
`create-table` lines — taken **verbatim**, with a header and the namespace form in front. The
module segment was diffed against the generated batch and is byte-identical, so it cannot drift
from the sovereign source.

## Verify before sending

```bash
# 1 — the collect refusal (AQP-FVT)
grep -c 'Nothing to collect' Deploy/PureV17/02_deploy.pact        # => 1

# 2 — the receiver-correct cost mirrors (RPS)
grep -c 'URC_CollectXferIgnis:decimal (id:string collector:string' Deploy/PureV17/01_deploy.pact   # => 1
grep -c 'URC_CollectForcedFixIgnis:decimal'                        Deploy/PureV17/01_deploy.pact   # => 1

# 3 — the success message reads the executor (TS02-C3)
grep -c 'UR_AccountSupply reward-dptf-id executor' Deploy/PureV17/03_deploy.pact                   # => 2

# 4 — file 3 carries NO interface and NO second module
grep -c '^(interface' Deploy/PureV17/03_deploy.pact                # => 0
grep -c '^(module'    Deploy/PureV17/03_deploy.pact                # => 1
```

If any count is wrong the artefacts predate the fix. Regenerate with
`python3 REPL/tools/_deploybundle.py --write`, re-copy files 1–2, and re-slice file 3.

## After sending

```bash
python3 REPL/tools/_registrylive.py --record     # refresh the chain-confirmation sidecar
python3 REPL/tools/_livemodules.py  --probe      # refresh the deployed-source snapshot
```

`_livemodules.py --diff` should then report `AQP-FVT` and `TS02-C3` as differing **only** by
`REPL_BootstrapTreasury` / `REPL_BootstrapVault` — or by nothing at all, if the decision below
went the other way.

# Deploy/PureV27 — DEPLOY CARD

**Everything you send is in THIS folder, in filename order.** Ten transactions, all **chain 0**.

| | |
|---|---|
| what it ships | **`single-share-weight`** — a score-level flag deciding whether an EQUITY collection's RAW SHARE (nonce 1) carries weight |
| transactions | **10** — `01`–`09` then the repair |
| modules | **16** |
| interfaces bumped | **5** — `AcquisitionSchemasV4→V5` · `ScoresV6→V7` · `RewardPerShareV7→V8` · `VacateV5→V6` · `TalosStageTwo_ClientThreeV7→V8` |
| round gas | **4,475,219** across ten transactions; worst single **46%** of a block |
| verified | gate **GREEN**, 32,275 assertions (26,206 positive / 6,069 negative), 0 broken |

## Send order

| tx | modules | bytes | total gas | % of 2.0M |
|---|---|---:|---:|---:|
| 01 | `02_IGNIS` · `00_AQP-SCHEMAS` · `01_ANK` | 293,447 | 459,475 | 23.0% |
| 02 | `02_SCORE` | 330,403 | 751,051 | 37.6% |
| 03 | `03_AQP` | 253,466 | 318,160 | 15.9% |
| 04 | `04_RPS` | 340,256 | 919,796 | 46.0% |
| 05 | `04b_RPSC` | 46,674 | 130,215 | 6.5% |
| 06 | `05_FVT` | 315,382 | 657,026 | 32.9% |
| 07 | `06_VCT` · `07_MTX-AQP` · `08_DSA` | 288,911 | 607,382 | 30.4% |
| 08 | `08b_EVCT` · `04_TS02-C3` | 256,802 | 342,015 | 17.1% |
| 09 | `09_AQP-INFO` · `04_AQP-BOOT` · `03_DSP+` | 296,574 | 290,098 | 14.5% |
| **repair** | `09_deploy_THEN_fixup_single-share-weight.pact` | 4,100 | small | — |

**The repair goes last**, after `09`. It writes a column that does not exist in the deployed
schema until `02_SCORE` lands, and nothing earlier in the round depends on it.

## Why IGNIS is in this round

For one price row. `UC_IgnisComponents` **fails fast on an unknown op-key** — verified against the
live chain, where `AQP-SCR|C_SetSingleShareWeight` currently returns *"Key … not found in
object."* Without the IGNIS redeploy the new entrypoint's own cost preview aborts, so the feature
would deploy and be unusable.

That inclusion had a consequence worth recording: `02_IGNIS.pact` also declares **`IgnisCollectorV4`
and `OuronetInfoV3`**, both of which have been live for a long time. They came along with the file
and would have aborted transaction 01 — the *second* round running to die that way.
`REPL/tools/_liveinterfaces.py` reported both against the generated round before anything was
sent. They are now pinned and emitted as skip comments. That is the backlog in that tool's own
report becoming fatal, exactly as its docstring says it does.

## The repair transaction

```
all 15 scores            single-share-weight = true
DemiourgosSnakes-S2KM…   single-share-weight = FALSE
```

**Strictly, correctness does not need the `true` sweep.** The column is absent on all 15 live rows
and `UR_SCR|SingleShareWeight` is `contains`-guarded to **true** — which is exactly how every score
already behaves. The guard is what makes the deploy safe; the sweep makes the state **explicit**,
so the one score that differs says so on the row rather than by the absence of a value.

**The write that matters is DemiourgosSnakes.** It and DemiourgosShareholder employ scores over the
same equity collection and must weigh it differently — Shareholder counts raw shares, Snakes counts
only aggregated packages. That is the entire reason the field exists.

It is a **hard, forced repair**: a top-level block writing the table under `acquire-module-admin`,
not a module function (§7.24) and not routed through `C_SetSingleShareWeight`. That entrypoint
refuses unless the score is empty and charges IGNIS per call; this is an admin one-shot over every
row. **Both equity scores were confirmed vacated first** — `nzs-count = 0`, `drift-locked false`,
read from chain 2026-11-11 — so the forced path writes exactly what the gated path would have
allowed. Direct writes bypass the `SECURE`-gated `WU_` writer and inherit none of its invariants;
stated rather than left implied.

Idempotent — every value is SET, never toggled.

## Verify after the repair

```
(map (lambda (k:string) [k (ouronet-ns.AQP-SCORE.UR_SCR|SingleShareWeight k)])
     (keys ouronet-ns.AQP-SCORE.SCR|T|Score))
```
15 rows, every one `true` **except** `DemiourgosSnakes-S2KMEHRINZER` = `false`. And the column must
now be **present** rather than defaulted:
```
(contains "single-share-weight"
  (read ouronet-ns.AQP-SCORE.SCR|T|Score "DemiourgosSnakes-S2KMEHRINZER"))   ;; -> true
```

## Then, and only then

Re-open the Snakes pool and have holders restake. **This round does not re-value existing
positions** — there are none, because you vacated, which is precisely why the gate requires it.
Weights are computed at stake time and stored; the flag changes what the *next* stake computes.

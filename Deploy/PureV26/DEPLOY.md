# Deploy/PureV26 — DEPLOY CARD

> ## STATUS 2026-11-10 — ONE TRANSACTION LEFT: `10_deploy_rps-cleanup.pact`
>
> **Deployed and verified:** `00` (coin, all ten chains, vault healthy) · `01`–`09` (all eleven
> modules byte-identical to the tree) · `04_deploy_THEN_fixup_s1-counters.pact` (the S1 counter
> repair, all nine FVTs, every value matching the figure predicted from live state beforehand:
> earning-leg-count 9 · 15 · 7 · 13 · 25 · 7 · 4 · 59 · 13).
>
> **Still to send — `10_deploy_rps-cleanup.pact`, chain 0, RPS admin keyset.** A pure redeploy of
> RPS that deletes the one-shot S1 migration (`UM_FVT|BackfillS1Counters` + its capability,
> 9,049 B). It ran once; Pact can never remove a definition from a deployed module, so only a
> redeploy without it can. Simulated **OK against the live chain tip** — 327,720 B, exec 271,273
> + size 454,456 = **725,729 gas, 36% of a block**.
>
> Nothing else changes: no schema, no table, no behaviour. The repaired counters stay exactly as
> the migration wrote them.
>
> **01–09 in this folder have been REGENERATED since they were sent.** They now have their six
> interfaces stripped — `AcquisitionSchemasV4`, `ScoresV6`, `RewardPerShareV7`,
> `FarmsVaultsTreasuriesV7`, `VacateV5`, `RewardEvictionV2` all went live with this round, and
> Pact cannot upgrade an interface even to an identical body. So these files are now
> *re-sendable against current chain state* rather than a record of what was sent; git holds the
> record. All nine simulate OK against the live tip.
>
> **The lesson this round paid for twice:** a one-shot migration does not belong on a module.
> `00_deploy.pact` carries coin's vault repair as a top-level block with module admin, so there
> is nothing to clean up afterwards. RPS got a function instead, and transaction 10 is the cost
> of that. Future migrations go in the fixup transaction.

**Everything needed to send this round is in THIS folder, plus ONE file outside it** —
`Deploy/PureV26/04_deploy_THEN_fixup_s1-counters.pact`, which runs between `04` and `05`. Ignore the
`see Deploy/MANIFEST.md` and `Steps 1-0 must have run first` lines inside the transaction
headers — boilerplate the planner emits for the from-scratch pipeline.

| | |
|---|---|
| transactions | **11** — `00` (all 10 chains) → `01`–`04` → **S1 repair** → `05`–`09` (chain 0) |
| modules | **coin** + 15 sovereign/citizen |
| interfaces shipped | **6** — `AcquisitionSchemasV4` · `AcquisitionScoresV6` · `AcquisitionRewardPerShareV7` · `AcquisitionVacateV5` · `AcquisitionFarmsVaultsTreasuriesV7` · `AcquisitionRewardEvictionV2` |
| tables created | **0** — every `create-table` is commented by upgrade mode and **none** needs uncommenting |
| **fix transactions** | **1** — the S1 counter repair. The coin vault repair is **inside `00`**. |
| fixes carried | **13** — F6, F1, B2, F7, F2(inc 1), F3, F5(36/36), F8, **S1**, **F4**, the F5 cascade, the **absent-column** fix, and the **exact-dormant** fix |
| verified | gate **GREEN**, 32,244 assertions (26,175 positive / 6,069 negative), 0 broken |

## Send order and cost

Size charge from `CLAUDE.md`'s seventh-power law — `gas_size(S) ≈ 95,225 × (S_KB/256)^7`, which
reproduces the wallet's own ceiling (the size charge alone hits 2.00M at **404,983 B**).

| tx | contents | bytes | size gas | exec gas | total | % of 2.00M |
|---|---|---:|---:|---:|---:|---:|
| **00** | **`coin`** + the vault repair — **ALL TEN CHAINS** | 100,099 | 113 | — | **113** | 0.0% |
| 01 | `AcquisitionSchemasV4` + `AcquisitionAnchorsV3` + AQP-ANK | 202,576 | 15,671 | 171,765 | **187,436** | 9.4% |
| 02 | `AcquisitionScoresV6` + AQP-SCORE | 322,001 | 401,765 | 269,902 | **671,667** | 33.6% |
| 03 | AQP-POOL | 253,466 | 75,233 | 242,927 | **318,160** | 15.9% |
| 04 | `AcquisitionRewardPerShareV7` + RPS | 348,227 | 695,038 | 328,763 | **1,023,801** | 51.2% |
| **→** | **`Deploy/PureV26/04_deploy_THEN_fixup_s1-counters.pact`** — 9 FVTs, chain 0 | 11,900 | — | 1,172,703 reads + 52 writes | — | ~70-75% |
| 05 | `AcquisitionRewardCostsV1` + AQP-RPSC | 50,303 | 1 | 130,214 | **130,215** | 6.5% |
| 06 | `AcquisitionFarmsVaultsTreasuriesV7` + AQP-FVT | 332,987 | 508,116 | 309,626 | **817,742** | 40.9% |
| 07 | `AcquisitionVacateV5` + AQP-VCT + MTX-AQP + AQP-DSA | 288,911 | 188,070 | 419,312 | **607,382** | 30.4% |
| 08 | `AcquisitionRewardEvictionV2` + AQP-EVCT + TS02-C3 | 234,765 | 43,995 | 259,571 | **303,566** | 15.2% |
| 09 | AQP-INFO + AQP-BOOT + DSP | 295,499 | 220,223 | 64,205 | **284,428** | 14.2% |
| | **total** | | | | **4,344,510** | |

Worst transaction (`04`) uses **just over half a block**. `04` sits 1,773 bytes under the
350,000-byte cap — the tightest margin in the round, and that cap was raised **three times in two
days**, each time by one module outgrowing it. See `_deploybundle.py`'s `DEFAULT_MAXBYTES` note for
the measured cost (the last raise merged one transaction and cost ~390K gas on the from-scratch
round). 04_RPS is now the largest module in the tree at **86% of the 404,983-byte hard ceiling** and
needs splitting — an interface cascade, better planned than discovered.

## Order is not cosmetic

1. **`00` FIRST, and to ALL TEN CHAINS.** `coin` is per-chain and every chain must carry the same
   code, or a cross-chain transfer meets two different modules. The **vault** lives on chain 0
   only (`UEV_ChainZero`), so the *code* goes everywhere and the *repair* is a no-op on chains
   1–9 — which is exactly why it is safe to put the repair inside the transaction and send the
   same file ten times. `UM_URV|RepairVaultCounters` returns
   *"No UrStoa vault on this chain — counter repair not applicable"* on chains 1–9.
2. **The module hash is computed over the `(module …)` form, not the transaction.** That is what
   makes `00` atomic *and* cross-chain safe: appending the repair call changes no hash, so all ten
   chains still report an identical `describe-module` hash. Verified live on 2026-11-09 —
   `uKfumevdkztWP47DgaeP3A72atgE450avWy7uSaT71U` on all ten before this round.
3. **The S1 repair goes IMMEDIATELY AFTER `04`, not at the end.** `UM_FVT|BackfillS1Counters` and
   every function it calls — the `WU_` writers, the `URH_` scans, the `RPS|UM>BACKFILL-S1`
   capability — all live in RPS, which `04` deploys. Waiting until `09` buys nothing and leaves
   five more transactions' worth of blocks in which a user collect could read a not-yet-repaired
   counter.
4. **`09` LAST of the deploys.** `AQP-INFO` calls `TS02-C3.URCi_IssueGenericEarningVault` as a
   **direct** module reference, which resolves at **DEPLOY** time. A previous round anchored it
   before Talos and **died live** with *"Module TS02-C3 has no such member"*. The REPL loads Talos
   first, so no suite in the gate could catch it.
5. **Interfaces before their consumers** — `01` before everything (schemas), `04` before `06`/`07`/`08`.
6. **`06` before `08`.** AQP-EVCT calls four AQP-FVT members that are deliberately **module-only**
   (PureV25's precedent); an undeclared modref resolves at **call** time, so `08` would deploy
   happily against an old AQP-FVT and fail on the first bulked eviction.

## The absent column — read this before trusting any of the above

This round adds **five columns to schemas whose rows already exist**: one to `coin`'s
`UrStoaVaultSchema` and four to AQP's.

| schema | column | live rows without it |
|---|---|---:|
| `UrStoaVaultSchema` | `dormant-claim-count` | 1 |
| `FVT|RewardAggregate` | `earning-leg-count` | 9 |
| `FVT|ScoreEntityLink` | `earning-user-count` | 13 |
| `FVT|RPS|Global` | `dormant-claim-count` | 11 |
| `FVT|MemberVault` | `dormant-claim-count` | 19 |

**Nothing defaults an absent column, and three idioms that look like they do, do not.** All three
measured in `REPL/modules/S1-UNCLAIMED.repl` `<<TX-S1-COL>>`, not assumed:

- `with-default-read` defaults an absent **ROW**. The row exists; the **binding** is what raises.
- `(try 0 (at "f" row))` does **not** catch it — the error propagates straight through.
- `(try 0 (with-default-read …))` does not catch it either.

The only form that survives is reading the row as an **object** and testing `contains` before
`at`. `try` *does* catch a missing **row**, so `(try {} (read T k))` + `contains` covers both.

**This is not a hypothetical. It halted chain 0 for ~16 hours on 2026-11-09** — the coin vault's
`dormant-claim-count` was read on the `coinbase` path, every block's coinbase aborted, and because
a transaction needs a block the repair could not be submitted at all. Recovery was a fleet-wide
rollback.

**And the same round repeated it in AQP.** Four readers in `04_RPS.pact` were `(try 0 …)`-guarded
on the stated belief that `try` would default them, and two of the columns were **bound** inside
`UR_FVT-SEL|ScoreEntityLink` and `UR_FVT-RG|RpsGlobal` — the full-row readers every other
`UR_FVT-SEL|*` and `UR_FVT-RG|*` reader fans out of. The whole reward surface, *and the migration
meant to repair it*, would have aborted on landing. Fixed to `contains`-then-`at` at all six
sites. Two guards now prevent a recurrence, both negative-controlled:

- `REPL/tools/_coinbasesafety.py` — a new column read on the coinbase path (coin only).
- `REPL/tools/_newcolumnsafety.py` — a column newer than its rows read unguarded **anywhere**.
  Run against the pre-fix `04_RPS.pact` it reports **seven** sites and exits 1.

## Why the repair is still mandatory, and why order no longer risks money

The guarded readers default to **0**, which is the correct pre-migration value and also the
dangerous one. `unclaimed-count` is restored at each accrual from `earning + dormant`; with both
at 0 the count goes to 0, and the first collect on a lane sees a count below 1 while other legs
are still owed. The sweep guard (`own > 0`) refuses an account owed **nothing** — so the EMMA
class of theft stays closed — but it does **not** stop a legitimately-owed account taking the
**whole lane** when the count reads low.

**So both restore phases now refuse to write a 0 over a positive stored count**
(`XI_2|RestoreUnclaimedFromCounts` and `XI_2|RestoreMemberUnclaimedFromCounts`). Before the
repair runs, the stored over-count simply stays: the sweep **stalls**, dust is **retained** —
the reversible direction — and the figure corrects itself the moment the repair runs or any leg
stakes. The case this gives up is empty: `restored = 0` means no leg earns and no leg is owed, so
there is no claimant a low count could mis-pay.

Deploy order is therefore **no longer load-bearing for correctness, only for how long the dust
sits.** Run the repair promptly anyway — the dust is the point of the round.

### And the repair itself had to be corrected before it could do its job

An earlier cut seeded `dormant-claim-count` from the pre-migration `unclaimed-count`, calling it a
safe upper bound. It is self-defeating: `unclaimed-count` already counts the earning legs and the
restore is `earning + dormant`, so the seed counts every earning leg **twice**. Measured against
all eleven live lanes before sending, it moved every counter *further* from 1 than the value
already stored (OuroLpFarm 25 → 50, Subsidiary/AURYN 69 → 128), and on **seven of eleven** lanes
the true dormant count is 0, so no dormant leg existed whose collect could ever drain the
inflation — `= 1` was unreachable by construction and the sweep could never have fired.

It is now counted exactly, and cheaply: a dormant leg has zero weight by definition, and a zero
weight kills the projection term in `URC_LiveClaimable`, so its claimable **is** its stored
`pending`. Verified identical to the full projection on all eleven lanes at 1,066,656 gas against
2,514,666.

**This survived a green gate**, which is the part worth remembering. The migration's own test ran
against a lane the preceding transaction had already drained to zero, so the claimant count was 0,
the seed wrote 0, and the correct and incorrect implementations were indistinguishable. The test
now re-arms the lane and asserts the pre-migration count is non-zero *before* claiming anything
about dormant.

**Three lanes are still not fixed by the sweep, by design.** Bloodshed/AURYN, Bloodshed/WSTOA and
OuroLpFarm/OURO hold a balance with **zero** collectable legs while carrying 9, 9 and 25 earning
legs, so `earning + dormant` is 9, 9 and 25 and `= 1` remains unreachable there. Their residue is
the whole-aggregator **evict** path's job — which this round makes exact — not the sweep's.

## What `00` does to the vault, measured against the live rows

`00` ends with `(coin.UM_URV|RepairVaultCounters)`, which **recounts** all three counters from the
`URV|UrStoaVaultUser` rows — never increments, so a second run is harmless. Read from chain on
2026-11-09, six user rows:

| counter | stored | true | action |
|---|---:|---:|---|
| `nzs-count` | 5 | 5 | unchanged |
| `unclaimed-count` | 6 | **5** | **corrected** — `k:9ea9…` unstaked and collected but was never decremented |
| `dormant-claim-count` | *absent* | 0 | **created** |

Vault holds 82,913.9955 STOA against 82,913.9143 owed across the five claimants — solvent, with
0.0812 of dust. Verify after sending with `(coin.URC_URV|VaultCounterAudit)` on chain 0:
`healthy` must be `true`.

## The state these fix transactions read, and whether it can move under you

**GAP is on** — `DALOS.UR_GAP` reads `true` on chain (confirmed 2026-11-09). It is enforced in
every Talos gas-station gate, which is the only client path, so **no stake, inject or collect can
move the AQP inputs.** Every predicted figure in
`Deploy/PureV26/04_deploy_THEN_fixup_s1-counters.pact` was computed against that frozen state by
calling the very readers the migration calls, and will still hold when you send it.

**But GAP does not cover `coin`.** The coin module consults it nowhere — `C_URV|Stake`,
`C_URV|Unstake` and `C_URV|Collect` remain callable by any UrStoa holder while the pause is on, and
the `coinbase` keeps funding the vault every block regardless. So the vault's `current-rps` and
`stoa-supply` are moving right now.

**That does not matter, and the reason is structural rather than lucky.**
`UM_URV|RepairVaultCounters` **recounts all three counters from the user table and writes absolute
values** — it never increments and never reads its own prior output. It is therefore correct
whenever it runs, against whatever state it finds. The figures in the table below are what it
writes *if sent now*; if someone stakes first, it will write the then-correct figures instead.

The counters are in any case stable under block production alone: for a staker the owed amount only
grows, and for an unstaked account the accrual term is multiplied by a zero balance, so neither
`nzs-count`, `unclaimed-count` nor `dormant-claim-count` can change without a stake, unstake or
collect.

## Verify after each step

```
;; after 00, on EVERY chain -- all ten must be identical
(at "hash" (describe-module "coin"))
;; after 00, chain 0 only
(coin.URC_URV|VaultCounterAudit)            ;; healthy: true
;; after the S1 repair, chain 0 -- must answer with integers, not "no such field"
(map (lambda (k:string) (at "earning-leg-count" (read ouronet-ns.RPS.FVT|T|RewardAggregate k)))
     (keys ouronet-ns.RPS.FVT|T|RewardAggregate))
```

And confirm the cut is still climbing after `00` — `/chainweb/0.0/stoa/cut` — before sending `01`.
That is the check nobody ran last time.

# Deploy/PureV22 — DEPLOY CARD

**Everything needed to send this round is in THIS folder.** Nothing from `Deploy/1_Pure`,
`2_Init`, `3_Assets` or `MANIFEST.md`. Ignore the `see Deploy/MANIFEST.md` and `Steps 1-0 must
have run first` lines inside the transaction header — boilerplate the planner emits for the
from-scratch pipeline, which does not apply to an upgrade round. No preceding steps, no init step.

| | |
|---|---|
| transactions | **1** |
| modules | **1** — `AQP-VCT` |
| interfaces shipped | **0** — `AcquisitionVacateV4` is already live and is SKIPPED; see below |
| init steps | **0** |
| total size | **196,582 bytes** (3,716 lines), against a ~395 KB per-transaction ceiling |
| gas | 261,126 measured in the REPL gas model |
| verified | gate green, **30,192 assertions**; round replayed clean against real live chain content |
| post-deploy | `python3 REPL/tools/_registrylive.py --record` |

## Send it

| # | bytes | lines | carries |
|---|---|---|---|
| `01_deploy.pact` | 196,582 | 3,716 | `AQP-VCT` |

One transaction. Paste the whole file; it needs the Ouronet admin signature and sets the
`ouronet-ns` namespace on its first line.

## What it fixes

**A POOL WHERE ONE OWNER STAKED TO TWO BENEFICIARIES COULD NOT BE VACATED AT ALL.** Owner,
2026-11-06, from a live DHBloodshed vacate: `Unique Items Required, duplicate list item found:
<account>`.

The first reading was that the UI split engine had broken. It had not. **`CC_FullVacate` — which
takes no arrays from anywhere and scans the legs on chain — fails identically.** That is the
single fact that relocates the defect from the client to the contract.

**THE SHAPE MISMATCH.** A vacate leg is keyed on the PAIR `(owner, beneficiary)`, because the
unwind's score and rollup phases are per beneficiary. The bulk TRANSFER is addressed by
DESTINATION ACCOUNT, because it is handing custody back. One owner with two beneficiaries is two
legs and **one destination** — so the owner column carried that account twice, and `UEV_IzUnique`
correctly refused it.

## All three lanes, by three different routes

| lane | the list that repeated | the gate that refused it |
|---|---|---|
| collectable (DPSF/DPNF) | `owner-ids`, one per leg | `DPDC-T\|S>BULK-TRANSFER` |
| orto-fungible | `UC_VacateOrtoDestinations` — a per-element SUBSTITUTION, not a dedupe | `DPOF\|S>BULK-MOVE` |
| true-fungible | `UC_VacateTfLegsToTftBulkArrays`, one entry per leg | `DPTF\|C>X-BULK-TRANSFER` |

Plus the two fast-drain mirrors (`XI_DrainCollectableBatch`, `XI_DrainOrtoFungibleBatch`), which
carry the call byte-identically.

Each now merges by destination immediately before the transfer and **leaves the per-leg arrays
untouched for the unwind**, which still needs the beneficiary column.

## The uniqueness gate is NOT relaxed

Deliberate, and worth stating because the one-line alternative is obvious: `UEV_IzUnique` guards
**every token surface in the system** against a double credit — DPTF, DPOF, DPDC, every caller.
The duplicate was wrong at the CALL SITE. Owner ruling, 2026-11-06: *"we do not touch the bulk
transfer logic, we only mould the code to follow it."*

## No interface bump, and it is checked rather than assumed

The three new helpers (`UC_VacateBulkDestinations`, `UC_VacateMergeIntRowsByDestination`,
`UC_VacateMergeNonceRowsByDestination`) are **module-only**. Nine `UC_` helpers in this file
already are, including `UC_MergeVacateCollectableRowIntoLegs` — the function at the root of the
defect.

`AcquisitionVacateV4` occupies lines 2–117; the earliest edit lands at line 1,099. **The interface
block is byte-identical.** `_livemodules.py --diff` reports exactly one divergent pair for this
change: AQP-VCT's functions.

`AcquisitionVacateV4` is already in `_deploybundle.py`'s `LIVE_INTERFACES` and is replaced by a
skip marker in the emitted source — **Pact refuses to re-deploy an interface, identical bytes
included.** Verified in the emitted file rather than inferred from the mode line: 0 `(interface`
declarations, 1 `(module`, and all three `create-table` occurrences commented out.

## Why 29,536 green assertions said nothing about it

Every vacate fixture in the tree — `[6.2.5]_AQP-VCT.repl` and `Kursan/AQP-scale-vacate.repl`'s 50
legs — stakes each owner to its **own single beneficiary**. So `owner-ids` was unique BY
CONSTRUCTION and the failing shape was unreachable from any fixture.

Closed by a new gate entrypoint, `REPL/modules/VCT-DUPOWNER.repl`: 20 assertions, all three lanes,
both the on-chain-scan (`CC_FullVacate`) and stateless-batch (`CCp_BatchVacate*`) entry shapes.
**Mutation-checked** — against the unfixed module it reports 2 receivers instead of 1, the wrong
transfer amount, and then aborts with the customer's exact error.

It is its OWN entrypoint rather than a block in `[6.2.5]` because it must DRAIN pools to prove a
vacate completes, and `CC_FullVacate` is pool-wide: as a block inside that file it broke twelve
assertions in `modules/AQP.repl` which depend on those fixtures. A destructive test and a shared
fixture cannot share a process.

## Gas, measured

`Kursan/AQP-scale-vacate.repl` round 2, 15 TF legs: **837,374 before, 837,624 after — +250 gas,
+0.03%.** That fixture is the worst case and was chosen for it: 50 distinct owners, each its own
beneficiary, so the dedupe does every comparison and merges nothing.

It is quadratic, so scale it rather than trusting the headline: ~1.1 gas per comparison, so a
300-leg all-distinct batch pays ~100,000 gas, about 5% of the 2M ceiling. The UI prices batches by
simulating them, so its plan absorbs this without retuning.

## Generated by

```
python3 REPL/tools/_deploybundle.py --round 2026-11-v22-vacate-duplicate-owner --write
```

which emits into `Deploy/1_Pure/`; that file was copied here verbatim and `Deploy/1_Pure` was then
restored to the from-scratch pipeline with a plain `--write`, because the gate diffs it against
that.

Replayed before shipping with
`cd REPL && python3 tools/_chaintxsim.py --round ../Deploy/PureV22` — which fetches the real
declared source of every touched module from the chain and replays the round over it:
**"round replayed clean over real live content."**

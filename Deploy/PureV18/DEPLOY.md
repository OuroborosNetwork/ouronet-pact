# Deploy/PureV18 — DEPLOY CARD

**Everything needed to send this round is in THIS folder. It is THREE transactions, in order,
and there is no init step.** Nothing from `Deploy/1_Pure`, `2_Init`, `3_Assets` or `MANIFEST.md`.
Ignore the `see Deploy/MANIFEST.md` and `Steps 1-N must have run first` lines inside the
transaction headers — boilerplate the planner emits for the from-scratch pipeline, which does not
apply to an upgrade round. This round has **no** preceding steps.

## What it is

**A vacated pool stays shut**, and the variant that moves assets while *deferring* the score
becomes admin-only.

Owner ruling, 2026-10-30: *"The pool owner has to manually re allow stacking after a vacate
event"*, and on the two variants: *"I don't like this variants that decouples score update from
the movement of assets. Whatever asset moves, scores must be updated in same tx."*

### The module was disagreeing with itself

This is a correction, not a new rule. `XI_ClearVacateInProgress` — the **abort** exit — has always
ended:

> *"Stake stays disabled (ops re-enable via `C_EnablePoolStake`)"*

while the **success** exits re-enabled staking automatically. So a vacate that FAILED stayed
locked and one that SUCCEEDED sprang open — the opposite ordering of caution. Every exit now
leaves the pool shut and the owner reopens deliberately.

| | before | after |
|---|---|---|
| `XI_MaybeFinalizeVacate` | clears flag, **re-enables stake**, unfreezes FVTs | clears flag, unfreezes FVTs |
| `C_FinalizeVacate` | same | same |
| `CC_FullVacate` | **touched staking not at all** | ends with stake **disabled** |

`CC_FullVacate` sets **no vacate flag**. In a single transaction, setting and clearing it is
invisible to every observer and costs two writes; what is observable is that the pool is empty and
shut, and that is what it states. It does not freeze the FVTs either — the campaign does that
because a drain spanning blocks can be raced, and a single transaction cannot be.

### v2 to the admin band

`CCp_BatchDrain{TrueFungible,OrtoFungible,Collectable}` → `AAp_`, and `C_FinalizeVacate` →
`A_FinalizeVacate`, all on `P|ADMINISTRATIVE-SUMMONER` with the gasless patron. **The EVCT
pattern**, so the CORES keep their names and `AcquisitionVacateV4` does **not** bump. This family
authorises by SIGNER (`CAP_VctVacatePoolOwner` enforces tx-sender ownership), so no `executor`
argument is taken and the admin can drain only pools the administrator owns.

v2 is kept for observational comparison against v1 — which is why its INFO previews still quote a
real cost while the gasless path charges nothing. Both halves are asserted in
`[6.5.1]_AQP-INFO-GROUNDTRUTH.repl`.

## Send these three, in this order, and stop

| # | file | deploys | new interface | exec gas (REPL) | bytes | size gas (est.) | total (est.) | of 2M |
|---|---|---|---|---:|---:|---:|---:|---:|
| 1 | `01_deploy.pact` | AQP-VCT | — | 261,126 | 186,275 | ~8,700 | **~269,800** | 13% |
| 2 | `02_deploy.pact` | TS02-C3 + AQP-BOOT | `TalosStageTwo_ClientThreeV7` | 214,916 | 299,016 | ~239,200 | **~454,200** | 23% |
| 3 | `03_deploy.pact` | DSP+ | — | 64,205 | 63,555 | ~5 | **~64,200** | 3% |

Size charges use `gas_size(S) ≈ 95,225 × (S_KB/256)^7`. Transaction 2 is the only one where the
size charge dominates, and it is still under a quarter of a block.

**Order is load order, not preference.** TS02-C3 declares `TalosStageTwo_ClientThreeV7`; AQP-BOOT
binds it and rides the same transaction *after* it. DSP+ binds it too and goes last. AQP-VCT is
first because it is the behaviour being deployed — though strictly it could go anywhere, since
`AcquisitionVacateV4` is unchanged and TS02-C3's modref binds the old module just as well.

## Why four modules

| module | why it ships |
|---|---|
| `AQP-VCT` | **the change itself** — three function bodies rewritten. No signature moved, so no cascade can see it. |
| `TS02-C3` | declares the bumped interface; four wrappers renamed and re-gated. |
| `AQP-BOOT` | binds `module{TalosStageTwo_ClientThreeV7}` — 17 modrefs. Calls no renamed member. |
| `DSP+` | binds it too — 3 modrefs. Calls no renamed member. |

The two citizens ride the cascade **for their modrefs only**. A modref naming `V6` cannot bind to
a module implementing `V7`, which is why they must ship even though their own code is untouched.

## What it does NOT need

- **No init transaction.** No new module, no new table, no new IMP registration. A step that does
  nothing is a step someone later trusts.
- **No schema backfill.** No `defschema` gained a field, so no pre-existing row is missing one.
- **No `AcquisitionVacate` bump.** The cores kept their names; only Talos wrappers were renamed.

## After it lands

```
python3 REPL/tools/_registry.py --probe        # regenerate from the chain
python3 REPL/tools/_registrylive.py --record   # the post-deploy confirmation CLAUDE.md requires
python3 REPL/tools/_livemodules.py --probe     # refresh the shape cache
```
then republish `@ouronet/talos-registry`.

**This is overdue from V17, not new work for V18.** The owner confirmed on 2026-10-30 that the
V17 scripts were never run, which is why `INFO_AQP-FVT|Collect` still reads as five parameters in
the artefact while the chain takes six — the drift that broke OuronetUI's Master Collect and that
`_registry.py --check` now refuses to pass. One probe clears V17's debt and V18's together.

## Verification

- `ZALL.repl` green — the exhaustive runner, every suite.
- The gate is clean through every artefact check — pricing, audit book, docs figures, deploy
  bundle, Talos ABI, module pages — and stops only at the V17 registry drift above, which no
  offline run can clear.
- **Not chain-verified.** Nothing here has been simulated against StoaChain; `_chainsim.py` needs
  a network. The evidence is the REPL model, which is the same evidence every prior round shipped
  on, and it is not the same thing as a dry run.

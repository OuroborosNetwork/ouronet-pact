# Deploy/PureV23 — DEPLOY CARD

**Everything needed to send this round is in THIS folder.** Nothing from `Deploy/1_Pure`,
`2_Init`, `3_Assets` or `MANIFEST.md`. Ignore the `see Deploy/MANIFEST.md` and `Steps 1-0 must
have run first` lines inside each transaction header — boilerplate the planner emits for the
from-scratch pipeline, which does not apply to an upgrade round. No preceding steps, no init step.

| | |
|---|---|
| transactions | **4**, in the order below |
| modules | **10** |
| interfaces shipped | **2** — `EquityV5`, `TalosStageTwo_ClientOneV4`. Seven already-live ones are SKIPPED; see below |
| init steps | **0** |
| total size | **1,004,541 bytes** |
| verified | gate green, **96 entrypoints, 30,286 assertions**; round replayed clean against real live chain content |
| post-deploy | `python3 REPL/tools/_registrylive.py --record` |

## Send them in this order

| # | bytes | carries |
|---|---|---|
| `01_deploy.pact` | 197,477 | `DPDC-C`, `DPDC-MNG`, **`EquityV5`**, `EQUITY` |
| `02_deploy.pact` | 298,877 | `AQP-SCORE` |
| `03_deploy.pact` | 233,989 | `AQP-POOL` |
| `04_deploy.pact` | 274,198 | **`TalosStageTwo_ClientOneV4`**, `TS02-C1`, `TS02-C2`, `DEMIPAD-SNAKES`, `DEMIPAD-CUSTODIANS`, `INFO-TWO` |

Largest is 298,877 bytes against a ~395 KiB per-transaction ceiling. The size charge grows as the
**seventh power** of transaction size, so these must NOT be merged to reduce the count.

## What it is — a tokenised company its founder could not run

An `E|` collection is issued with `owner-account = <dpdc>`, the DPDC smart account. That is
deliberate: it is how the collection is automanaged and how its nonce set stays sealed. But DPDC
management and the AQP pool governor are both **owner-derived**, so they named a contract.

Measured: **27 DPDC operations and 12 AQP operations** were reachable only by the project
signature. The pool could not even be made functional — `C_AddScore` is owner-gated and
`C_EnablePoolStake` requires a score.

## Three parts

### 1 — The nonce set is sealed

`DPSF|C_IssueCompany`'s `@doc` has always claimed *"Only 8 Elements can exist in this Collection,
and no more can be added"*. **Nothing enforced it.** A probe drove the real call:

```
nonces-used BEFORE => 8
DPSF|C_Create 9th nonce => "Created ["1 <ninth>"] ... within the E|TSEQ-… DPSF Collection"
nonces-used AFTER  => 9
```

A ninth nonce has no tier, no share-equivalent, is invisible to `UR_TierSupplies` and to the 50%
packaging cap — and is indistinguishable from a real tier to a buyer.
`DPDC-C|C>REGISTER-NONCES` now refuses any `E|` id whose `nonces-used` is not 0, which admits the
issuing transaction (EQUITY populates all eight in one call while the count is still zero) and
refuses every later one, **for every caller including `<dpdc>`**.

### 2 — Shares get two doors, and the escrow settles with them

Make does **not** burn shares — it transfers them to `<dpdc>` and mints tier units against them.
So nonce 1's total supply is always the share count, and the collateral invariant is:

> **escrow = m × K**  ·  m = shares ÷ 1,000,000  ·  K = Σ(units × S_tier)

K is the packaged **percentage** and is invariant under supply changes. `EQUITY::C_IssueShares` /
`C_RetireShares` move whole millions and split each one pro-rata: **K to/from the escrow,
(1,000,000 − K) to/from the holder.**

Two consequences fall out: the 50% cap becomes `K ≤ 500,000` with no reference to m, so neither
door can breach it; and escrow is always a multiple of m, so every split is whole shares.

Raw `C_AddQuantity` / `C_BurnSFT` on **nonce 1** of an `E|` id are now refused. Tiers 2–8 are
untouched — Make, Break and Convert mint and burn package units and maintain the invariant by
construction.

### 3 — Company governance reaches the creator

`URC_AqpOwnerKontoFromClassAndAsset` returns the **creator** for an `E|` asset, which fixes all
twelve AQP operations in one line. Pause and branding are wrapped in EQUITY, which proves the
creator and then acts as `<dpdc>` through `P|EQUITY|REMOTE-GOV` — already registered as a DPDC
governor guard and never used until now.

Issuance flags change: `can-pause` **false → true** (it made a trading halt impossible for
everyone, creator and admin alike) and `can-transfer-nft-create-role` **true → false**.

**Everything not wrapped stays sealed BY CONSTRUCTION** — 21 DPDC operations including all seven
wipes, both forced repurposes, the six set-definition ops and fragmentation. Confiscating or
redefining shareholders' shares is not a directorial power, and the wrapper design makes that
structural rather than remembered.

## Two interfaces bump, both first-order

`EquityV4` → **`V5`** (five new client entrypoints plus the share-accounting surface) and
`TalosStageTwo_ClientOneV3` → **`V4`** (their wrappers). **Neither is named inside another
interface**, so neither cascade has a second wave: `INFO-TWO`, `AQP-SCORE`, `AQP-POOL`,
`DEMIPAD-SNAKES`, `DEMIPAD-CUSTODIANS` and `TS02-C2` rebind modrefs and change nothing else.

**`DpdcV3` is deliberately NOT bumped.** Routing the company operations through EQUITY instead of
re-gating six DPDC modules avoided rebinding **twenty-four**.

## Seven already-live interfaces are deliberately NOT shipped

Pact refuses to re-deploy an interface, identical bytes included. These are co-hosted in the files
the two bumps dragged in, and each is replaced by a skip marker in the emitted source:

`DpdcCreateV3`, `DpdcManagementV3`, `AcquisitionScoresV5`, `AcquisitionPoolsV3`,
`TalosStageTwo_ClientTwoV3`, `SaleSnakesV3`, `SaleCustodiansV3`.

Every one was confirmed **against the chain** — `(at "code" (describe-module "ouronet-ns.<name>"))`
on node2, compared to the block in the tree. All seven matched. Verified in the emitted files
rather than inferred: **2 `(interface` declarations, 10 `(module`, 0 live `create-table`.**

## Test coverage, where there was none

`REPL/modules/EQUITY-MANAGEMENT.repl` is new — **29 assertions**, its own gate entrypoint.
Before this round there was **not one assertion anywhere** exercising equity management from any
account.

It earned itself immediately: **it caught a real defect in this round's own first cut.** A
stranger issued shares successfully, because `CAP_EquityCreator` proved ownership of the *derived*
creator account and never bound the *declared* executor to it — authority proven, actor unnamed.
`UEV_ExecutorIzCompanyCreator` closes it, and the five entrypoints are registered in
`_executorenforced.py` with the route named in each `@doc`.

## Generated by

```
python3 REPL/tools/_deploybundle.py --round 2026-11-v23-equity-company-governance --write
```

which emits into `Deploy/1_Pure/`; those four files were copied here verbatim and `Deploy/1_Pure`
was then restored to the from-scratch pipeline with a plain `--write`, because the gate diffs it
against that.

Replayed before shipping with
`cd REPL && python3 tools/_chaintxsim.py --round ../Deploy/PureV23` — which fetches the real
declared source of every touched module from the chain and replays the round over it:
**"round replayed clean over real live content."**

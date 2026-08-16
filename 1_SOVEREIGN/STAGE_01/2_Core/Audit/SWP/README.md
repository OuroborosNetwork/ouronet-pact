# SWP (Swapper engine) Audit — cycle log & status tracker

Home for all audit data on the SWP-family modules. Goal: a **comprehensive, evidence-backed sign-off that the
live swap engine is correct** — swap math (forward/backward), slippage mechanics, symmetric/asymmetric liquidity
provisioning, the virtual-swap engine, and the BFS hop-routing — for every path, "if X and Y and Z happen, the
outcome is P, and P is correct." Same flow as the AQP audit (`STAGE_02/2_Core/03_AQP/Audit`).

## Modules in scope

| # | file | module (interface) | role |
|---|------|--------------------|------|
| 1 | `STAGE_01/2_Core/15_SWP.pact` | `SWP` (SwapperV3) | main swap engine — forward/backward swaps, slippage, swap math |
| 2 | `STAGE_01/2_Core/16_SWPI.pact` | `SWPI` (SwapperIssueV3) | pair / pool issuance |
| 3 | `STAGE_01/2_Core/17_SWPL.pact` | `SWPL` (SwapperLiquidityV1) | liquidity — symmetric + asymmetric LP, virtual swap |
| 4 | `STAGE_01/2_Core/18_SWPLC.pact` | `SWPLC` (SwapperLiquidityClientV1) | liquidity client layer |
| 5 | `STAGE_01/2_Core/19_SWPU.pact` | `SWPU` (SwapperUsageV2) | usage / branding |
| 6 | `STAGE_01/2_Core/14_SWPT.pact` | `SWPT` (SwapTracerV1) | swap tracer / BFS hop-routing |
| 7 | `STAGE_01/2_Core/20_MTX-SWP.pact` | `MTX-SWP` (SwapperMtxV3) | multi-tx swap / LP defpacts |
| — | `STAGE_01/1_Utilities/12_U_SWP.pact` | `U_SWP` | pure swap helpers |
| — | `STAGE_01/0_Interfaces/02_Core.pact` | `SwapperV2` (historical) | shared/legacy interface registry |

## ⚠️ Live-on-mainnet — repo vs live comparison

The SWP code is **live on mainnet** (`ouronet-ns.*`). The owner asked to compare the repository code against the
live code via dirty reads. **This audit environment has NO network access** (cannot reach a node), so the
comparison must be run by the owner — see `MAINNET-COMPARISON.md` for the exact commands. Until then, the audit
targets the **repository** code (the source of truth that is re-deployed after any fix).

## The cycle (append-only)

| Round | File | What it is |
|-------|------|------------|
| **I — Findings** | `ROUND-01-FINDINGS.md` | Everything discovered before any fix. Frozen once closed. |
| **I — Owner feedback** | `ROUND-01-OWNER-FEEDBACK.md` | Owner's verdict per finding. Frozen. |
| **II — Fixes** | `ROUND-02-FIXES.md` | One entry per fix, applied sequentially (owner green-lights each). |
| **III — Re-verify** | `ROUND-03-REVERIFY.md` | Re-read fixed code cold, prove correctness. New findings restart the cycle. |
| **IV+** | `ROUND-0N-*.md` | Repeat Fix → Re-verify until a re-verify round is clean. |
| **Final** | `SWP-AUDIT-REPORT.md` | Published sign-off once a re-verify round is clean. |

Round files are append-only / immutable once closed. Only this README's tracker is edited in place. Module `.pact`
source changes **only** during a Fixes round, one fix at a time.

## Status legend
`OPEN` awaiting verdict · `CONFIRMED` bug to fix · `PLAUSIBLE` needs verification · `DESIGN` needs a design
decision · `DOC-FIX` code right, doc wrong · `CONVENTION` not a bug → StoicSyntax note · `FIXING` · `FIXED`
(awaiting re-verify) · `VERIFIED` (re-audited clean) · `REFUTED` (verified not a bug).

## Status tracker (living)

| ID | Sev | Module | Short | Verify | Verdict / status |
|----|-----|--------|-------|--------|------------------|
| _(ROUND-01 in progress — findings land here)_ | | | | | |

## Method
Deep-read auditors per module (swap math, LP math, routing) → candidate findings with `file:line` + failure
scenario → each finding adversarially verified against the code before it is written CONFIRMED. Reward/loss-math
ground truth = constant-product / the swap model the modules implement; every "bug" must come with a concrete
input → wrong-output scenario.

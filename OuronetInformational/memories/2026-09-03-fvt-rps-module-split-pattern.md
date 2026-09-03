# 2026-09-03 — Splitting an over-cliff module (FVT → RPS + FVT), reusable pattern

`04_FVT.pact` (7,527 ln) exceeded the StoaChain deploy cliff (module-load gas ≈ 7th-power of tx
size; 2M cap ≈ 6,635 ln). Split into two deployable modules **along the reward-engine seam**, fully
behavior-preserving (full `REPL/Z.repl` green, 595 assertions, every reward/gas expected value
unchanged). Result: `04_RPS.pact` 5,617 ln (reward engine leaf, deploys first) + `05_FVT.pact`
3,878 ln (entity/config/client shell). See `03_AQP/Audit/FVT-SPLIT-{DESIGN,MANIFEST}.md`.

## The seam that made it a clean DAG (no cycle)
- RPS is a **pure leaf**: reads no FVT table. FVT's config that the reward engine needs was
  denormalized into a new table **`FVT|T|RewardAggregate`** that RPS *owns* — so RPS never calls
  back into FVT. (The original deadlock was orchestration writing FVT aggregates from reward code.)
- **Client entrypoints (`C_/CC_/CCp_/A_/AA_`) stay in FVT** — the public surface Talos/siblings call.
  Their internal orchestration moves to RPS behind `XE_` forward-entrypoints.

## Three mechanisms that closed the flip to green (all scripted → reproducible)
1. **"Needs a SECURE-granting `XE_` wrapper" = transitively contains `(require-capability (SECURE))`**
   — NOT the narrower "writes a table". That heuristic missed fund-transfer fns
   (`XI_TransferRewardDptfFromVault`) that require SECURE without a table write. Fixing the criterion
   jumped the green-run from 265 → 348 assertions.
2. **Facade re-export.** Readers of moved tables MUST live in RPS (can't read RPS's table from FVT).
   Every moved reader still called via `ref-FVT::X` (modref) or `AQP-FVT.X` (dot) is re-declared in
   FVT's inline interface + given a thin delegating `(defun X (…) (RPS.X …))`. 53 readers → the whole
   test corpus stays byte-identical, so the equivalence gate is trustworthy. All returned primitives
   (no `object{Schema}`) so the interface-object-return rule didn't bite.
3. **IMC cascade.** Every module that now calls `RPS::XE_` must register its guard on RPS's IMP:
   FVT (`ref-P|RPS::P|A_AddIMP dg`, SECURE), VCT (`dg`), DSA (`mg` = `P|DSA|CALLER`). AQP-BOOT Step0
   gains `(ref-P|RPS::P|A_Define)`. Gotcha: the generator copies FVT's `P|A_Define` into RPS with a
   `P|FVT|→P|RPS|` rename, so the FVT→RPS self-registration line had to be *stripped* from RPS's copy
   (otherwise RPS self-registers and the write hits "read-only/sys-only mode" via self-modref dispatch).

## Cross-module call idiom inside the split
- `ref-RPS::fn` (modref) for interface members; `RPS.fn` (dot) for sibling rewires (any exported
  defun; no interface/binding needed). Dot-syntax callers of readers need only the wrapper, not the
  interface decl — but adding the decl is harmless.

## Deploy-gas headroom (confirmed)
REPL `table` model measures runtime load-exec (RPS 362K / FVT 250K), not the chain size formula;
size-cliff extrapolation `(5617/6635)^7 × 2M ≈ 624K` (RPS) / `~47K` (FVT). Both deploy with margin.

## Tooling
Generators are scratch (`REPL/_fvt{gen,asm,flip,facade}.py`, driven by `REPL/_fvtrun.sh`,
tokenizer `REPL/_letfix.py`) — NOT committed; the committed artifacts are the two `.pact` files +
sibling/executor edits. Reproduce from `/tmp/FVT_full.pact` via `bash REPL/_fvtrun.sh`.

# URCi cost architecture — Option A (chosen) + implementation plan

Owner decision, 2026-08-27. This is the spec to implement when we resume after the audits.
Companion: `memories/2026-08-27-ignis-cost-rethink.md` (point A), `MODULE-SIZING.md` (point B),
`memories/2026-08-27-aqp-info-final17-costmap.md` (the proven AQP leg breakdowns = the spec source).

## 1. The problem
IGNIS cost is **emergent**: each cost-emitting leaf (`XE_`/`XI_`) does its write AND returns an
explicitly-constructed cumulator (`UDC_MediumCumulator`, `UDC_BiggestCumulator`,
`UDC_TransferCumulator`…); a `C_` composes sub-calls, their cumulators concat, one total falls out.
That skeleton runs down into Stage 1. Today the INFO/preview functions **re-derive** that cost in
parallel → they can drift from the execution on a structural change, and re-pricing is scattered.

## 2. The `URCi` convention (new prefix — register in StoicSyntax)
`URCi_*` = the **info/cost counterpart** of a cost-emitting function. A specialization of `URC`:
pure, read-only, **no `enforce`**, returns a cost cumulator (or cost object). It is called **inside
the execution path for billing AND served to the UI for preview** — one definition, two callers.

Two levels:
- **Leaf `URCi`** — one per cost-emitting `XE_`/`XI_`. Returns that leaf's cumulator. The leaf's
  write-fn does its `(update …)` then returns `(URCi_<leaf> …)`. Single source for that leaf's cost.
- **Composer `URCi`** — one per `C_`/`CC_`/`A_`. Concats the leaf `URCi`s → the op's total cumulator.
  **This is what the INFO function calls.**

### Placement rule (owner, 2026-08-27): `URCi` lives IN its module, never in a shared cost module
Each `URCi` sits in the **same module as the function it prices** — the exec leaf calls its own
`URCi` with no cross-module hop, and the composer `URCi` sits with its `C_`/flow and reaches leaf
`URCi`s by `ref` exactly where the flow already crosses module boundaries. This is correct, not just
convenient: an atomic leaf cost must not cross a module boundary (rule B §4c — minimise the `ref`
surface; every hop is a place the module-boundary guard does real work). The INFO module is the only
thing that reaches *across* to call composer `URCi`s.
**Do NOT exile cost functions into a dedicated cost module to dodge size** — the size fix is to
**split the module** (point B), keeping each `URCi` with its code.

## 3. Option A (CHOSEN) — leaves expose URCi, executor composes as today
- Each cost-emitting **leaf** exposes a `URCi_<leaf>` and returns it from its own body.
- The **executor keeps composing via the `XE_` returns** (control flow UNCHANGED — no rehaul).
- The **INFO composer** concats the SAME leaf `URCi`s.
- Result: every **value** re-price (UsagePrice) AND every **leaf-tier** change auto-applies to exec
  and info from one edit. The only thing not auto-shared is the **composition structure** (add/remove
  a leg needs both the executor concat and the composer updated) — and that residual is caught
  mechanically by the CI drift-gate (§5).
- Incremental: extract a leaf's `URCi` the day you touch it; NOT a big bang.

**Option B (NOT chosen, asymptote only):** executor bills THROUGH the composer `URCi` (leaves return
empty cumulators; the `C_` attaches one cumulator from `URCi_flow`). True single-source, but inverts
billing everywhere down to AQP + Stage 1 = top-to-bottom rehaul. Migrate toward it leaf-by-leaf only
if the purity is ever judged worth it; never a prerequisite.

## 4. INFO consolidation + placement (the big win)
Once INFO functions are **thin `URCi` callers** (call the composer `URCi` + wrap in `ClientInfo`
pre/post text), each shrinks to a few lines. Consequences:
- **Keep the INFO modules** (so the current UI keeps working — same `INFO_*` names/return shape),
  just gut the reconstruction bodies down to `URCi` calls.
- **Consolidate**: one INFO module **per stage** (Stage-1 INFO, Stage-2 INFO). Small line count
  makes one-module-per-stage feasible. (A single all-stages INFO is possible but must deploy
  dead-last, which breaks independent Stage-1 testing — prefer per-stage.)
- **Size-rule (B) synergy:** `INFO-ONE` is already terribly big because it re-derives cost inline;
  the `URCi` refactor shrinks it dramatically. A and B help each other here.

### Placement (owner, 2026-08-27): INFO modules are LAST, after `3_Talos`
INFO is a **pure read-only presentation layer** — it only *calls* core `URCi`s + reads state, and
**nothing references it via `module{}`** (leaf; never triggers the interface cascade rule). So each
stage's INFO module deploys **last in that stage's order, after `3_Talos`** — its own slot, e.g.
`1_SOVEREIGN/STAGE_0N/4_Info/` (paralleling `0_Interfaces / 1_Utilities / 2_Core / 3_Talos`). This
is the same "read-only goes last" architecture the slave `Stage_Z` modules already follow
(`2_SLAVE/Stage_Z/01_DPL-UR.pact`, EXPLORER) — those are purely read functions placed dead-last.
INFO stays **sovereign** (it's the official preview API), just positioned last. Deploying after
everything it references means zero forward-reference risk, and being a leaf means editing it
only ever redeploys the (small) INFO module.
- **Relocation:** the consolidated per-stage INFO moves out of `2_Core` (where `INFO-ONE` /
  `AQP-INFO` live today) into `4_Info/`, deployed after Talos.

## 5. CI drift-gate (makes "changes apply to both" true without Option B)
Promote the ground-truth harness (`REPL/aqp-info-groundtruth.repl` + `[6.5.1]`, pattern: preview
`ignis-need` == real IGNIS/GAS balance delta of the live execution) to a **CI gate**. Any cost change
not reflected in the composer `URCi` fails the build. This is the enforcement that lets Option A skip
the rehaul: exec↔info can never silently diverge.

## 6. Sequencing (owner-set, 2026-08-27)
1. **FIRST: finalize the audits → main** — SWP, DPDC, DPTF-DPOF (+ ATS). Do NOT build `URCi` on
   unaudited / in-flux cost logic; an audit that changes a leaf's cost would invalidate its `URCi`.
   Stabilize the base first. (SWP/ATS are separate out-of-scope chats.)
2. **Then module-by-module in DEPLOY ORDER, starting at Stage-1 module #1:** add leaf `URCi_*`,
   have each leaf return it, add composer `URCi_*` for each `C_`/`CC_`/`A_`.
3. **Consolidate INFO** into the per-stage INFO module (thin `URCi` callers), deployed last per stage.
4. **Re-price (point A):** value re-price via UsagePrice; heavy-read surcharge emitted by the
   `URH_/URHC_/URD_` readers (scaled to rows scanned) — localized at the transitive-heavy functions.
   Edits land on the `URCi` / UsagePrice → both exec and info move together.
5. **AQP splits (point B):** `URCi` code stays **in-module** (§2 placement rule), so adding it grows
   each module. Stage-1 modules were sized for Kadena's 150k cap (~2,900 lines) and have headroom
   under StoaChain's larger ceiling → room for their `URCi`s without splitting. **AQP is the
   exception:** FVT is already OVER the deploy ceiling (6,694 lines) and the others grow as `URCi`s
   land — so expect a **few capability-seam splits in AQP afterwards** (FVT certainly; re-audit
   POOL/SCORE/ANK/VCT line counts once their `URCi`s are in). A and B meet here: split to make room,
   don't relocate the cost functions.

## 7. State of the current AQP INFO work (transitional — keep)
The AQP stake/unstake INFO functions (TF/OF/SF/NF, all **ground-truth-proven cent-exact**) and
finalize/abort are **kept as working transitional code AND the verified spec** for the `URCi`
extraction (their leg breakdowns are proven correct). When the module-by-module pass reaches
AQP (VCT/FVT/SCORE/POOL/ANK), they get simplified to `URCi` callers.
**Do NOT build the 7 remaining vacate INFO as parallel reconstructions now** — they would be thrown
away. Build them as thin `URCi` callers when the refactor reaches VCT/AQP. The vacate cost breakdown
is fully mapped in the cost-map memory, ready to become `URCi_Vacate*`.

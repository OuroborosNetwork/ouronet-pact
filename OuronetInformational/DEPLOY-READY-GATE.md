# Deploy-ready gate (#83 / roadmap 1.7 deploy proof)

The frozen shape must (a) deploy fresh top-to-bottom in dependency order and (b) keep every module
under StoaChain's module-load gas ceiling (~2M gas; module-load gas grows ~7th-power of tx size, so
the practical cliff is ≈ 6,635 source lines). Both are demonstrated below. (The actual *mainnet*
redeploy is post-red-team; this is the REPL-provable readiness gate.)

## (a) Fresh top-to-bottom deploy — PROVEN
`cd REPL && pact ZALL.repl` deploys the entire stack in dependency order (Stage 00 sandboxes → Stage 01
utilities/DALOS/cores/Talos/Z_Reads/executor/citizens → Stage 02 DPDC/DemiPad/AQP/Talos/executor/
citizens → Stage ZZ DPL-UR/EXPLORER/DSP) and runs 787 assertions green. Deploy order is encoded in the
shared cores `REPL/deploy-stage00/01/02/zz.repl`.

## (b) Every module under the size/gas cliff — PROVEN
**0 modules over the ~6,635-line cliff.** Distribution: over-cliff **0** · danger(4500-6635) **1** ·
watch(3500-4500) **3** · ok(<3500) **89** · max **5,617** (RPS).

| lines | band | module |
|------:|------|--------|
| 5617 | danger | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_RPS.pact` |
| 4450 | watch | `1_SOVEREIGN/STAGE_01/Z_Reads/02_INFO-ONE+.pact` |
| 4122 | watch | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/02_SCORE.pact` |
| 3878 | watch | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_FVT.pact` |
| 3421 | ok | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/03_AQP.pact` |
| 3377 | ok | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/06_VCT.pact` |
| 3267 | ok | `1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact` |
| 3080 | ok | `1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact` |

(full list: `find 1_SOVEREIGN 2_CITIZEN -name '*.pact' | xargs wc -l | sort -rn`)

### Deploy-gas headroom for the biggest (RPS, 5,617 ln)
The REPL `table` gas model measures runtime load-exec, not the chain's size formula, but as a floor:
RPS load-exec **362K**, FVT **250K** (measured). On the size cliff itself: `(5617/6635)^7 × 2M ≈ 624K`
for RPS, `~47K` for FVT — both deploy with wide margin under the 2M cap.

## Verdict
**Deploy-ready.** No module exceeds the cliff; the full stack deploys fresh & green top-to-bottom.
The only open item before an actual redeploy is the **interface-version policy** for the never-live
AQP/RPS interfaces (V1 vs the current V2 baseline — see LIVE-INTERFACE-VERSIONS.md), a contained
suffix change that does not affect deployability.

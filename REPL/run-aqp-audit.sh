#!/usr/bin/env bash
#
# REPL/run-aqp-audit.sh — CONSOLIDATED AQP audit gate (one command).
#
# Runs every coherent AQP coverage suite. Each suite is a self-contained pact process:
# full deploy (Stage 00 sandboxes -> Stage 01 -> Stage 02) + population slaves + the FULL
# AQP-BOOT mainnet-sim provisioning (module + Steps 0-12: anchor classes, OURO-LP triplet,
# DPSF/DPNF pools, FVT entities, score+reward links, TripletFamily, farm wiring). They are
# separate processes because they are deep state-mutators (vacate drains pools; the DEB/MTX
# suite retires the AurynRain anchor) that cannot be linearly composed in one process without
# a full hermetic rewrite. This driver gives a single command + a single aggregate verdict.
#
# Scope: the six AQP audit modules only (01_ANK, 02_SCORE, 03_AQP/POOL, 04_FVT, 05_VCT,
# 06_MTX-AQP). Not Stage 1 or the rest of Stage 2.
#
# Usage:  bash REPL/run-aqp-audit.sh
# Exit:   0 if every suite is green (0 FAILURE, no Load failed), 1 otherwise.
#
set -uo pipefail
cd "$(dirname "$0")"
export PATH="$HOME/.local/bin:$PATH"

SUITES=(
  "AQP-comprehensive.repl|functional + full AQP-BOOT mainnet-sim + RPS/collect/DPNF/ANK-LP/triplet-diag/FVT-admin + [6.3] golden paths"
  "AQP-core-vct.repl|core [6.2.1-4] ANK/SCORE/POOL/FVT stake+unstake+inject+collect + [6.2.5] VCT vacate (all asset kinds)"
  "deb-staleness-proof.repl|deb-staleness conservation (M3 #12) + CC_Inject + MTX|2|C_Inject & MTX|2|C_SweepRevokeAnchor defpacts + sweep"
  "deb-staleness-sweep-cc.repl|sweep CC-batch (defun+gate) + self-service unstale — CC_SweepBegin/RecomputeChunk retire AurynRain to the SWEEP01 end-state; C_UnstaleMyScores non-penalized refresh"
  "deb-staleness-inject-cc.repl|enforced-fresh inject CC-batch (defun+gate) — CC_InjectFixChunk pages the stale set, CC_InjectFinalize gates on zero-stale then injects"
  "triplet-collect-golden.repl|farm multiplet triplet collect fairness + dual-stream vacate"
  "Kursan/AQP-stream-tests.repl|streamed inject (linear vesting): late-staker 180/60 + superposition (D4) + zero-weight->zombie (D9) + guard bounds + vault drip gas + farm (class-0) drip"
  "deb-staleness-unstale-all-cc.repl|owner mass deb-unstale (CC_UnstaleAll): owner-gate (non-owner refused) + penalized 2e tag + all-up-to-date idempotent no-op"
  "Kursan/dsa-model-tests.repl|DSA score-entity MODEL (17a): define 3 single models (Custodians -1/-2/-3) + combine triplet + guard rejections"
  "Kursan/dsa-agency-tests.repl|DSA Phase 2: A_DefineDelegationVault binds a class-0 FVT (owner-gated) + C_OpenAgency gate/fee/vault-active guards reject (Q=0 open gate)"
  "Kursan/dsa-capture-tests.repl|DSA Phase 3: Custodians fragment->stake, ATOMIC open (admit+operator-stake+terminal gate), delegated oracle capture math (node-cap + uptime), permissionless recompute (oracle-ts preserved)"
  "Kursan/dsa-fee-tests.repl|DSA Phase 5b: operator two-track fee at inject — multi-delegator split (operator own+fee vs delegators (1-fee)), independent operator collect, O(1) A_SetAgencyFee reprice"
  "Kursan/dsa-hetero-split-tests.repl|DSA Round B: heterogeneous quality-split matrix — HOMOGENEOUS default, owner-set HET matrix routing (all-to-OURO/all-to-Auryn), O(1) reprice, guard rejections (non-owner, bad row sum, non-multiplet reward)"
  "Kursan/dsa-grand-tour.repl|DSA GRAND TOUR (single process, one agency): create vault + define triplet + MULTIPLET_BASE reward + open + delegator stake + oracle + HETEROGENEOUS split + fee two-track + inject + independent collect + matrix reprice + O(1) fee reprice + global GOV oracle switches"
  "Kursan/aqp-info-tests.repl|AQP-INFO cost previews: each AQP-<MOD>|INFO_* fixed-cost function's reported ignis-full/kadena-full == the execution's exact GAS| constant / UsagePrice source (ANK/SCORE/POOL/FVT/DSA/MTX groups; stake/vacate reconstruction pending)"
)

echo "================================================================"
echo "AQP AUDIT — consolidated run  ($(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo now))"
echo "================================================================"

overall=0
declare -a rows
for entry in "${SUITES[@]}"; do
  file="${entry%%|*}"
  desc="${entry#*|}"
  if [ ! -f "$file" ]; then
    rows+=("MISSING  | $file — file not found")
    overall=1
    continue
  fi
  echo ""
  echo ">>> RUN  $file"
  echo "         $desc"
  err="/tmp/aqp-audit-$(echo "$file" | tr '/[]' '___').err"
  out=$(pact "$file" 2>"$err")
  fails=$(printf '%s\n' "$out" | grep -cE 'FAILURE')
  passes=$(printf '%s\n' "$out" | grep -cE 'Expect: success|Expect failure: Success')
  loadfail=$(grep -cE 'Load failed' "$err")
  # openFile / missing-file / fatal that pact reports on stderr WITHOUT the "Load failed" string
  filerr=$(grep -cE 'does not exist|openFile|No such file' "$err")
  # A suite that produced ZERO assertions never really ran — treat as FAIL, not a vacuous pass.
  if [ "$fails" -eq 0 ] && [ "$loadfail" -eq 0 ] && [ "$filerr" -eq 0 ] && [ "$passes" -gt 0 ]; then
    status="PASS"
  else
    status="FAIL"
    overall=1
  fi
  rows+=("$(printf '%-4s | %-26s | asserts=%-5s fails=%-3s load-fail=%s file-err=%s' "$status" "$file" "$passes" "$fails" "$loadfail" "$filerr")")
  echo "         => $status  (asserts=$passes, failures=$fails, load-fail=$loadfail, file-err=$filerr)"
  if [ "$status" = "FAIL" ]; then
    echo "         --- diagnostics ---"
    printf '%s\n' "$out" | grep -E 'FAILURE' | head -5 | sed 's/^/         /'
    grep -E 'Load failed|Fatal execution error|does not exist|openFile' "$err" | head -3 | sed 's/^/         /'
    [ "$passes" -eq 0 ] && echo "         (0 assertions — suite did not execute its test body)"
  fi
done

echo ""
echo "================================================================"
echo "AQP AUDIT — SUMMARY"
echo "================================================================"
for r in "${rows[@]}"; do echo "  $r"; done
echo "----------------------------------------------------------------"
if [ "$overall" -eq 0 ]; then
  echo "  RESULT: ALL GREEN ✓"
else
  echo "  RESULT: FAILURES PRESENT ✗"
fi
echo "================================================================"
exit "$overall"

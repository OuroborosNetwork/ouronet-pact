#!/usr/bin/env bash
# _fvtrun.sh — canonical FVT->RPS split pipeline (reproducible from /tmp/FVT_full.pact).
# restore full FVT source -> extract RPS bodies -> assemble 04_RPS.pact -> flip 05_FVT.pact -> facade re-export.
set -e
cd "$(dirname "$0")/.."
export LC_ALL=C.UTF-8
FVT=1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_FVT.pact
cp /tmp/FVT_full.pact "$FVT"
python3 REPL/_fvtgen.py    | tail -1
python3 REPL/_fvtasm.py    | grep -E 'wrote 04_RPS|MISSING'
python3 REPL/_fvtflip.py   | grep -E 'CUT|residual|new FVT'
python3 REPL/_fvtfacade.py | tail -1
echo "RPS=$(wc -l < 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_RPS.pact) FVT=$(wc -l < $FVT)"

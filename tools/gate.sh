#!/usr/bin/env bash
# StoicSyntax hard gate: repo must be GREEN and CANONICAL. Non-zero exit on either failure.
set -e
cd "$(dirname "$0")/.."
echo "== canon_check =="
python3 tools/canon_check.py || { echo "GATE FAIL: canon drift"; exit 1; }
echo "== green-gate (Z.repl) =="
out=$(cd REPL && ~/.local/bin/pact Z.repl 2>&1)
echo "$out" | grep -q 'Load successful' && ! echo "$out" | grep -q 'FAILURE:' \
  || { echo "GATE FAIL: not green"; exit 1; }
echo "GATE PASS: green + canonical"

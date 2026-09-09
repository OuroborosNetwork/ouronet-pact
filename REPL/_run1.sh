#!/usr/bin/env bash
# Run ONE .repl and report the gate's verdict for it.
#
# Why this exists: `pact x.repl | grep FAILURE` reports 0 for a file that aborted
# BEFORE reaching any assertion -- a broken file that looks green. The gate's real
# criterion is "Load successful" present AND "Load failed" absent, so use the same
# one here rather than a weaker proxy.
set -u
PACT="${PACT:-$(command -v pact || echo "$HOME/.local/bin/pact")}"
out=$("$PACT" "$1" 2>&1)
pos=$(grep -c "Expect: success" <<<"$out")
neg=$(grep -c "Expect failure: Success" <<<"$out")
fail=$(grep -c "FAILURE:" <<<"$out")
if grep -q "Load successful" <<<"$out" && ! grep -q "Load failed" <<<"$out"; then
    echo "OK      $1   +$pos -$neg   failures=$fail"
else
    echo "BROKEN  $1   +$pos -$neg   failures=$fail"
    grep -E "FAILURE:|Load failed" <<<"$out" | head -5
    grep -B2 "Load failed" <<<"$out" | head -4
    exit 1
fi

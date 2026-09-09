#!/usr/bin/env bash
# Run every RUNNABLE rescued audit-proof test in parallel. From REPL/:  ./regressions/run.sh
# Wall time = the slowest single file (RULE 1), not the sum.
cd "$(dirname "$0")/.." || exit 1
awk -F'`' '/^\| `/{print $2}' regressions/MANIFEST.md | head -n -0 > /tmp/_reg.txt
sed -n '/^## Runnable/,/^## Blocked/p' regressions/MANIFEST.md | awk -F'`' '/^\| `/{print $2}' > /tmp/_reg.txt
xargs -P "$(nproc)" -I{} bash -c 'f="$1"; if pact "$f" 2>&1 | grep -q "Load failed"; then echo "FAIL $f"; else echo "pass $f"; fi' _ {} < /tmp/_reg.txt | sort

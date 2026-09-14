#!/usr/bin/env bash
# REPL/_prerun.sh — run BEFORE every gate run. Two checks, both learned the hard way.
#
# 1] LEFTOVER PROBE BLOCKS. Iterating on a guard means appending a scratch block to a live suite,
#    running it, and restoring. Twice now the restore was missed: once a throwaway assertion that
#    I had ALREADY SEEN fail for the wrong reason got committed as if it passed (the gate caught
#    it), and once a harmless diagnostic was left in modules/LIQUID.repl. Only live suites are
#    checked — Kursan/ and archive/ hold finding-verification files that legitimately say PROBE.
#
# 2] LOST ASSERTIONS. Comparing raw diff lines is the wrong instrument (a modified line reads as
#    a deletion); comparing per-file `expect` COUNTS against HEAD answers the real question,
#    "did I lose a test".
set -u
fail=0

leftover=$(grep -rln 'begin-tx "PROBE' --include='*.repl' modules Stage_01 Stage_02 . 2>/dev/null \
           | grep -vE '^(\./)?(archive|Kursan)/' | sort -u)
if [ -n "$leftover" ]; then
    echo "LEFTOVER PROBE BLOCKS:"; echo "$leftover" | sed 's/^/    /'; fail=1
fi

cd ..
for f in $(git diff --name-only -- '*.repl'); do
    old=$(git show "HEAD:$f" 2>/dev/null | grep -c 'expect'); old=${old:-0}
    new=$(grep -c 'expect' "$f")
    if [ "$new" -lt "$old" ]; then echo "LOST ASSERTIONS: $f  $old -> $new"; fail=1; fi
done

# 3] REGRESSION AGAINST THE LAST GREEN GATE, not just against HEAD. Check 2 compares to HEAD, so
#    it cannot see work lost WITHIN a session: restoring a live suite from a STALE backup silently
#    dropped a finished block (AQP-G30) and the HEAD comparison still read as +1760 insertions.
#    `--snapshot` records per-file counts after a green gate; every later run compares to it.
SNAP="REPL/.prerun-snapshot"
if [ "${1:-}" = "--snapshot" ]; then
    : > "$SNAP"
    for f in $(git ls-files '*.repl'; git ls-files -o --exclude-standard '*.repl'); do
        printf '%s %s\n' "$(grep -c 'expect' "$f")" "$f" >> "$SNAP"
    done
    echo "SNAPSHOT WRITTEN ($(wc -l < "$SNAP") files)"
    exit 0
fi
if [ -f "$SNAP" ]; then
    while read -r cnt f; do
        if [ ! -f "$f" ]; then
            # MOVED, not lost. A file that was relocated still carries its assertions, so calling
            # that a regression is a false alarm -- and a ratchet that cries wolf is a ratchet
            # people learn to ignore, which is worse than not having one. This fired for real on
            # 2026-09-14 when 18 ungated probes were moved into archive/: eighteen "VANISHED"
            # lines for eighteen files that had not lost a single assertion.
            # So: look for the basename elsewhere in the tree first, and only call it a loss if
            # the assertions are genuinely gone.
            moved=$(find . -name "$(basename "$f")" -type f 2>/dev/null | head -1)
            if [ -n "$moved" ]; then
                oldc=$cnt; newc=$(grep -c 'expect' "$moved")
                if [ "$newc" -lt "$oldc" ]; then
                    echo "REGRESSION: $f moved to $moved and LOST assertions  $oldc -> $newc"; fail=1
                else
                    echo "note: moved $f -> $moved ($newc assertions intact)"
                fi
            else
                echo "FILE VANISHED since last green gate: $f"; fail=1
            fi
            continue
        fi
        now=$(grep -c 'expect' "$f")
        if [ "$now" -lt "$cnt" ]; then
            echo "REGRESSION vs last green gate: $f  $cnt -> $now"; fail=1
        fi
    done < "$SNAP"
else
    echo "note: no snapshot yet -- run ./_prerun.sh --snapshot after the next green gate"
fi

[ "$fail" -eq 0 ] && echo "PRERUN CLEAN" || echo "PRERUN FAILED -- fix before gating"
exit $fail

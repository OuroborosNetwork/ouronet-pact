#!/usr/bin/env python3
"""Which AQP-BOOT steps does any REPL actually EXECUTE?

WHY THIS EXISTS. `C_Step7_CreatePoolsAndScores` could never have run -- an eager `let` read seven
pool rows the same call creates -- and 26,815 green assertions said nothing about it. The suite
named `[6.2.9]_AQP-BOOT-FULL.repl` runs steps 1,2,3,6,8..12; the only calls to Step 7 anywhere are
three `expect-failure` cases on wrong-length arguments, and those guards sit ABOVE the `let`, so
no test ever reached the binding group.

A step with no successful execution is untested no matter how green the gate is. This prints that
as a fact rather than leaving it to be discovered on mainnet.
"""
import os, re, sys
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) if "--" not in sys.argv else "."
ROOT = "/home/ancientbox/ClaudeWS/OuroborosNetwork/_onchain/Ouronet"
BOOT = os.path.join(ROOT, "2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact")
# DEDUPED AND ORDERED. `(defun C_StepN` appears TWICE for each step -- once in the interface
# declaration block at the top of the file and once in the module body -- so a bare `findall`
# reported 28 steps where there are 14, and listed each one twice. A count that is exactly double
# is the easiest kind to publish without noticing.
_raw = re.findall(r"\(defun (C_Step(\d+)_\w+)", open(BOOT, encoding="utf-8").read())
steps = sorted({n for n, _ in _raw}, key=lambda n: int(re.search(r"C_Step(\d+)", n).group(1)))
hits = {s: {"ok": 0, "neg": 0} for s in steps}
for dirpath, _, files in os.walk(os.path.join(ROOT, "REPL")):
    for f in files:
        if not f.endswith(".repl"):
            continue
        src = open(os.path.join(dirpath, f), encoding="utf-8", errors="ignore").read()
        for line_no, line in enumerate(src.split("\n")):
            for s in steps:
                if s in line:
                    # An `expect-failure` block within ~6 lines above marks a negative case.
                    ctx = "\n".join(src.split("\n")[max(0, line_no - 6):line_no + 1])
                    hits[s]["neg" if "expect-failure" in ctx else "ok"] += 1
untested = [s for s, h in hits.items() if h["ok"] == 0]
for s in steps:
    h = hits[s]
    mark = "OK   " if h["ok"] else ("NEG  " if h["neg"] else "NONE ")
    print(f"  {mark} {s:38} executed={h['ok']}  negative-only={h['neg']}")
print(f"\n{len(steps)} steps, {len(steps)-len(untested)} executed by a test, "
      f"{len(untested)} NEVER executed")
if untested:
    print("NEVER EXECUTED: " + ", ".join(untested))
sys.exit(0)

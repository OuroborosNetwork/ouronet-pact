#!/usr/bin/env python3
"""Remaining unpinned guards that sit in a PLAIN callable defun (UEV_/URCv_/UCv_/UC_/URC_).

No capability machinery, no Talos shell: a REPL can call these directly. Ranked by how many
enforces sit ABOVE the target inside the same function (its predecessors) -- 0 means the guard
is the first thing the function does, which is the cheapest possible case.
"""
import re, glob, os, subprocess, sys
import sys

# RUN FROM THE REPO ROOT, not from REPL/ -- the subprocess path and the site paths below are both
# root-relative. Run from the wrong place and subprocess.run returns empty stdout with rc=1, `sites`
# parses to zero, and this script cheerfully reports "0 unpinned guards" when there are 51. That is
# a silently wrong answer, so it is now checked rather than assumed.
_cp = subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                 '_enforce_coverage.py'), '--list'],
                     capture_output=True, text=True)
if _cp.returncode != 0 or not _cp.stdout.strip():
    sys.exit("_cheapseam.py: could not run REPL/_enforce_coverage.py -- run this from the REPO ROOT "
             "(cd to the directory containing REPL/), not from inside REPL/.")
out = _cp.stdout
# the per-site listing: "  <path>:<line>  <owner>" then an indented message line
sites = []
lines = out.split('\n')
for i, ln in enumerate(lines):
    m = re.match(r'^  (1_SOVEREIGN/\S+|2_CITIZEN/\S+):(\d+)\s+(\S+)', ln)
    if m and i + 1 < len(lines):
        sites.append((m.group(1), int(m.group(2)), m.group(3), lines[i+1].strip()))

PLAIN = re.compile(r'^(UEV_|URCv_|UCv_|URC_|UC_|UR_)')
rows = []
for path, line, owner, msg in sites:
    name = owner.split(':')[0]
    if not PLAIN.match(name):
        continue
    src = open(path, encoding='utf8', errors='ignore').read().split('\n')
    # find the defun start
    start = None
    for j in range(line - 1, -1, -1):
        if re.match(r'\s*\(defun\s+' + re.escape(name) + r'\b', src[j]):
            start = j; break
    if start is None:
        continue
    above = sum(1 for k in range(start, line - 1) if '(enforce' in src[k])
    # ZERO-FIXTURE: nothing between the defun header and the guard that needs chain state or a
    # signature -- no table read, and no CAP_/UEV_ call either. Those guards are reachable by
    # calling the function with plain arguments, which is the difference between a five-minute
    # pin and an hour of fixture archaeology. Measured: only 3 of the 37 non-dead candidates
    # qualify, so the ratio is worth knowing BEFORE picking a target.
    # (CAP_ matters as much as a read: ATS::UEV_IssueData's interesting guard sits behind two
    # CAP_Owner calls, and a reads-only filter wrongly called it free.)
    # ALREADY-ANNOTATED guards. _enforce_coverage.py's convention is that a `;;UNREACHABLE` or
    # `;;UNTESTABLE-EXTERNALLY` comment claims exactly the ONE enforce on the next line below it.
    # This tool ignored them and kept listing those sites, which sent work at guards somebody had
    # already PROVEN dead -- OUROBOROS::UEV_Exchange carries a full write-up plus a pointer to
    # where it is pinned as-it-behaves, and was still showing up as a candidate.
    # Match _enforce_coverage.py's convention EXACTLY -- a marker claims the next enforce within
    # 12 lines, not merely the line below it. These comments routinely run to two or three lines of
    # explanation, so an immediately-above check finds the CONTINUATION and reports a clean 0.
    # (It did, over a site carrying a full write-up.) Two tools disagreeing about what counts as
    # annotated is worse than either rule alone.
    annotated = any(re.match(r'\s*;+\s*(UNREACHABLE|UNTESTABLE-EXTERNALLY)\b', src[k])
                    for k in range(max(0, line - 13), line - 1))
    head = '\n'.join(src[start:line - 1])
    needs = re.search(r'\b(UR_|URC_|URH_|read |with-read|with-default-read|CAP_|UEV_)', head)
    rows.append((above, os.path.basename(path), line, name, msg[:72], not needs, annotated))

rows.sort()
# The dead module is excluded from the recommendation, not just counted: it once made up the
# ONLY remaining zero-fixture candidate, and "START HERE" pointing at a module nothing calls is
# worse than pointing nowhere.
zero = [r for r in rows if r[5] and "00_DPMF" not in r[1] and not r[6]]
annot = [r for r in rows if r[6]]
dead = [r for r in rows if "00_DPMF" in r[1]]
print(f"unpinned guards in PLAIN callable functions: {len(rows)}")
print(f"  in the DEAD module 00_DPMF (pinning these tests NOTHING): {len(dead)}")
print(f"  already annotated ;;UNREACHABLE / ;;UNTESTABLE-EXTERNALLY (proven, not pending): {len(annot)}")
print(f"  ZERO-FIXTURE -- reachable with plain arguments, no state, no signature: {len(zero)}\n")
if zero:
    print("START HERE (dead-module sites excluded):")
    for above, mod, line, name, msg, _z, _a in zero:
        print(f"   {mod:<20} {line:>5}  {name}\n                              {msg}")
    print()
else:
    print("START HERE: nothing -- the zero-fixture seam is exhausted. Everything left needs state")
    print("            or a signature built first; budget accordingly.\n")
print(" preds  module                 line  function / message   (* = zero-fixture, ! = annotated)")
for above, mod, line, name, msg, z, a in rows:
    print(f"   {above:<4}{'*' if z else ('!' if a else ' ')} {mod:<20} {line:>5}  {name}")
    print(f"                                     {msg}")

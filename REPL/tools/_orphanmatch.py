#!/usr/bin/env python3
"""Which ORPHAN assertions actually correspond to a real source guard?

An orphan is an expect-failure whose expected text matches no guard. Most are raw Pact errors
("No value found in table", "Keyset failure") -- genuinely not guards. But some are REAL guard
tests whose expected string was written with an INTERPOLATED value spliced into the middle
("...for making a Tier 2 Share Packge"). The coverage tool splits the source format string on {}
holes and needs ONE WHOLE run to match, so a string straddling a hole matches nothing: the test
passes, exercises the guard, and gets no credit.

Matching by longest-run containment finds nothing, because the orphan is a FRAGMENT of a RENDERED
message while the runs are fragments of the TEMPLATE -- neither contains the other. So compare
word sequences instead and report the longest run of consecutive shared words.

TWO BUGS THIS SCANNER HAD FIRST, both worth remembering:
  1] it matched string literals inside COMMENTS (a `"` in prose opens a bogus literal), which
     produced three confident false positives pointing at a comment I had written myself. Third
     tool this session to need comment-stripping.
  2] it required the LONGEST run to appear, which is the one thing an interpolated string is least
     likely to contain.
"""
import re, glob, os, subprocess, sys
import sys

ROOT = '.'

# Comment stripper copied VERBATIM from REPL/_enforce_coverage.py rather than re-derived.
# My own version tracked quote state PER LINE -- but Pact @doc strings span many lines, so a `;`
# inside one looked like a comment, its closing `"` was deleted, and every string literal after
# that point misaligned. The EQUITY guard vanished entirely. Carrying string state across newlines
# is the whole difficulty. (Importing the function instead is not an option: importing that module
# runs its main() and exits.)
def strip_comments(src):
    out, i, n, in_str, esc = [], 0, len(src), False, False
    while i < n:
        c = src[i]
        if in_str:
            out.append(c)
            if esc: esc = False
            elif c == '\\': esc = True
            elif c == '"': in_str = False
            i += 1
        elif c == '"': in_str = True; out.append(c); i += 1
        elif c == ';':
            while i < n and src[i] != '\n': out.append(' '); i += 1
        else: out.append(c); i += 1
    return ''.join(out)

files = [f for f in sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                           + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
         if "/Audit/" not in f]

WORD = re.compile(r"[A-Za-z|_][A-Za-z0-9|_'-]*")
guards = []
for f in files:
    raw = open(f, encoding='utf8', errors='ignore').read()
    src = strip_comments(raw)
    # re.S matters: Pact @doc strings use the `\`-newline continuation idiom, and without DOTALL
    # the `\\.` alternative cannot step over `\`+newline. The regex then stops mid-file and every
    # literal after the first continued doc string is missed -- which is why the EQUITY guard, 500
    # lines below one, was invisible.
    for m in re.finditer(r'"((?:[^"\\]|\\.){16,})"', src, re.S):
        msg = m.group(1).replace('\\"', '"')
        words = WORD.findall(msg.replace('{}', ' '))
        if len(words) >= 4:
            guards.append((os.path.relpath(f, ROOT), src[:m.start()].count('\n') + 1, msg, words))

out = subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                 '_enforce_coverage.py'), '--orphans'],
                     capture_output=True, text=True).stdout
orphans, cur = [], None
for ln in out.split('\n'):
    m = re.match(r"^    (\S+\.repl):(\d+)$", ln)
    if m: cur = (m.group(1), int(m.group(2))); continue
    m2 = re.match(r"^        '(.*)'$", ln)
    if m2 and cur: orphans.append((cur[0], cur[1], m2.group(1))); cur = None

def longest_common_run(a, b):
    best = 0
    for i in range(len(a)):
        for j in range(len(b)):
            k = 0
            while i + k < len(a) and j + k < len(b) and a[i+k] == b[j+k]: k += 1
            best = max(best, k)
    return best

print(f"orphans examined: {len(orphans)}   guard messages: {len(guards)}\n")
rows = []
for f, line, txt in orphans:
    ow = WORD.findall(txt)
    if len(ow) < 4: continue
    best = (0, None)
    for gf, gl, gmsg, gw in guards:
        n = longest_common_run(ow, gw)
        if n > best[0]: best = (n, (gf, gl, gmsg))
    if best[0] >= 5:
        rows.append((best[0], f, line, txt, best[1]))

rows.sort(reverse=True)
print(f"ORPHANS THAT DO MATCH A REAL GUARD (uncredited coverage): {len(rows)}\n")
for n, f, line, txt, (gf, gl, gmsg) in rows:
    print(f"  [{n} shared words]  {f}:{line}")
    print(f"      expects : {txt!r}")
    print(f"      guard   : {os.path.basename(gf)}:{gl}")
    print(f"      source  : {gmsg[:100]!r}")

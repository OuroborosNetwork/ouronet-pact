#!/usr/bin/env python3
"""Which PINNED guards sit AFTER a persisting write inside the same function body?

`expect-failure` does NOT roll back DB writes (verified empirically: an FVT row
inserted before the failing enforce survives both the expect-failure and the
commit-tx). So a negative test pinning such a guard silently mutates the shared
fixture for every later block in the file. `try` is the opposite -- it forces
read-only mode and the write itself errors.
"""
import re, glob, os, sys

ROOT = "."
WRITE = re.compile(r'\((?:insert|update|write)\s|\(WI_[A-Za-z]|::XE_WI_[A-Za-z]|\(XI_[A-Za-z]|::XE_[A-Z]')

def top_forms(src):
    """yield (start, end, header) for each top-level (def... ) inside a module."""
    out = []
    for m in re.finditer(r'^(    )?\((defun|defcap|defpact)\s+([^\s\(\)]+)', src, re.M):
        depth, i, n, in_str, esc = 0, m.start(), len(src), False, False
        while i < n:
            c = src[i]
            if in_str:
                if esc: esc = False
                elif c == '\\': esc = True
                elif c == '"': in_str = False
            elif c == '"': in_str = True
            elif c == '(': depth += 1
            elif c == ')':
                depth -= 1
                if depth == 0: break
            i += 1
        out.append((m.start(), i + 1, m.group(2), m.group(3)))
    return out

files = [f for f in sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                           + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
         if "/Audit/" not in f]

# every expected-message pinned by a negative test (reuse the simple text form; we only
# need to know WHICH messages are driven, not exact attribution)
pinned = set()
for f in glob.glob("REPL/**/*.repl", recursive=True) + glob.glob("REPL/*.repl"):
    src = open(f, encoding='utf8', errors='ignore').read()
    for m in re.finditer(r'\(expect-failure\b', src):
        depth, i, n, strs, cur, in_str, esc = 0, m.start(), len(src), [], None, False, False
        while i < n:
            c = src[i]
            if in_str:
                if esc: esc = False
                elif c == '\\': esc = True
                elif c == '"':
                    in_str = False
                    if depth == 1: strs.append(cur)
                    cur = None
                if in_str and cur is not None: cur += c
            elif c == '"': in_str = True; cur = ''
            elif c == '(': depth += 1
            elif c == ')':
                depth -= 1
                if depth == 0: break
            i += 1
        if len(strs) >= 2 and len(strs[1]) >= 8:
            pinned.add(strs[1].replace('\\"', '"').replace('\\\\', '\\'))

hits = []
for f in files:
    src = open(f, encoding='utf8', errors='ignore').read()
    for (s, e, kind, name) in top_forms(src):
        if kind != "defun":            # defcaps run before the body's writes
            continue
        body = src[s:e]
        # position of the first persisting write in this function
        wm = WRITE.search(body)
        if not wm:
            continue
        # every enforce whose message is pinned AND which sits after that write
        for em in re.finditer(r'\(enforce(?:-one)?\b', body):
            if em.start() < wm.start():
                continue
            seg = body[em.start():em.start() + 1400]
            for msg in re.findall(r'"((?:[^"\\]|\\.){12,})"', seg):
                msg = msg.replace('\\"', '"').replace('\\\\', '\\')
                if msg in pinned:
                    hits.append((os.path.relpath(f, ROOT),
                                 src[:s + em.start()].count('\n') + 1, name, msg[:70]))
                    break

print(f"PINNED guards sitting AFTER a persisting write in the same defun: {len(hits)}")
print("(each such negative test leaks that write into the shared fixture)\n")
seen = set()
for f, ln, name, msg in hits:
    k = (f, ln)
    if k in seen: continue
    seen.add(k)
    print(f"  {f}:{ln}  {name}")
    print(f"        {msg}")

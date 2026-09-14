#!/usr/bin/env python3
"""CROSS-MODULE version of the leak audit.

A negative test leaks when: it calls F, F performs a persisting write, and F THEN
calls G whose cap/body holds the pinned enforce. The intra-function detector cannot
see this -- the write and the guard live in different modules. (This is exactly the
shape of SCR|XE>CREATE-FVT-LINK reached through FVT's REPL_BootstrapVault.)
"""
import re, glob, os
src0 = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '_leakaudit.py')).read().split('hits = []')[0]
exec(src0.replace('print(', '#print('))

# 1. map each pinned message -> the def it lives in
owner = {}
for f in files:
    s = open(f, encoding='utf8', errors='ignore').read()
    for (a, b, kind, name) in top_forms(s):
        for msg in re.findall(r'"((?:[^"\\]|\\.){12,})"', s[a:b]):
            msg = msg.replace('\\"', '"').replace('\\\\', '\\')
            if msg in pinned:
                owner.setdefault(msg, []).append((os.path.relpath(f, '.'), name, kind))

# 2. for every defun, find calls that occur AFTER the first persisting write
CALL = re.compile(r'\(\s*(?:ref-[A-Za-z0-9|_-]+::)?([A-Za-z][A-Za-z0-9|_>-]*)')
after_write_calls = {}   # callee-name -> [(file, caller)]
for f in files:
    s = open(f, encoding='utf8', errors='ignore').read()
    for (a, b, kind, name) in top_forms(s):
        if kind != "defun": continue
        body = s[a:b]
        wm = WRITE.search(body)
        if not wm: continue
        for cm in CALL.finditer(body, wm.end()):
            after_write_calls.setdefault(cm.group(1), []).append((os.path.relpath(f, '.'), name))

# 3. a pinned guard is AT RISK if its owning def (or the XE_ that acquires its cap)
#    is called after a write somewhere
risk = []
for msg, locs in owner.items():
    for (f, name, kind) in locs:
        cands = [name]
        if kind == "defcap" and ">" in name:          # SCR|XE>CREATE-FVT-LINK -> XE_CreateFvtLink
            tail = name.split(">")[-1]                # CREATE-FVT-LINK
            camel = "".join(w.capitalize() for w in tail.split("-"))
            cands.append("XE_" + camel); cands.append("XI_" + camel); cands.append("XB_" + camel)
        for c in cands:
            for (cf, caller) in after_write_calls.get(c, []):
                risk.append((msg[:62], f, name, cf, caller))

print(f"pinned messages total: {len(owner)}")
print(f"AT-RISK (pinned guard reached after a write in a caller): {len(set(r[0] for r in risk))}\n")
for r in sorted(set(risk))[:25]:
    print(f"  guard: {r[0]}")
    print(f"     in {r[1]}  {r[2]}")
    print(f"     reached after a write in {r[3]}  {r[4]}")

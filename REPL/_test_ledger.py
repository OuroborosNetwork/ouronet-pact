#!/usr/bin/env python3
"""REPL TEST LEDGER — every client function, how often it is tested, where, and how.

Run from the repo root:
    python3 REPL/_test_ledger.py > OuronetInformational/ARCHITECTURE/REPL-TEST-LEDGER.md

Purpose: give a later audit/documentation agent a single machine-generated inventory of what
has been tested, how many times, positively and adversarially, and from which testers -- so the
audit paper is written from evidence rather than from someone's memory of what got covered.

ATTRIBUTION IS BY TRANSACTION BLOCK, and that is a deliberate, stated approximation. An assertion
is credited to every client function invoked in the same (begin-tx ... commit-tx) block. A block
that calls three ops and asserts once credits that assertion to all three. So the assertion
columns measure "how well is this op's neighbourhood asserted", not a proof that the assertion
tests that op specifically. Invocation counts are exact.
"""
import re, glob, os, json, collections

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

# ---- the auditable contract: every Talos client/admin entrypoint -----------------------------
TALOS = (glob.glob('1_SOVEREIGN/STAGE_01/3_Talos/*.pact')
         + glob.glob('1_SOVEREIGN/STAGE_02/3_Talos/*.pact')
         + glob.glob('2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact'))
ENTRY = {}                                   # "ENTITY|FN" -> defining talos file
for f in TALOS:
    src = open(f).read()
    body = src[src.find('\n(module '):]      # skip the interface half (declares the same names)
    for m in re.finditer(r'^    \(defun\s+([A-Za-z0-9|_+-]+)', body, re.M):
        n = m.group(1)
        if '|' in n and re.match(r'^(C{1,2}p?_|A{1,2}p?_)', n.split('|')[-1]):
            ENTRY.setdefault(n, f)

# ---- walk every repl, block by block ----------------------------------------------------------
BLOCK = re.compile(r'\(begin-tx.*?\(commit-tx', re.S)
inv   = collections.Counter()                       # op -> invocations
pos   = collections.Counter()                       # op -> positive assertions in its blocks
neg   = collections.Counter()                       # op -> expect-failure in its blocks
where = collections.defaultdict(set)                # op -> files
ops_sorted = sorted(ENTRY)

for p in sorted(glob.glob('REPL/**/*.repl', recursive=True)):
    if '/archive/' in p: continue
    txt = open(p, errors='ignore').read()
    for blk in BLOCK.findall(txt) or [txt]:
        hits = [o for o in ops_sorted
                if re.search(r'(?:::|\.)' + re.escape(o) + r'[\s\)]', blk)]
        if not hits: continue
        nneg = len(re.findall(r'\(expect-failure', blk))
        npos = len(re.findall(r'\(expect\s', blk))
        for o in hits:
            inv[o]  += len(re.findall(r'(?:::|\.)' + re.escape(o) + r'[\s\)]', blk))
            pos[o]  += npos
            neg[o]  += nneg
            where[o].add(p)

tested   = [o for o in ops_sorted if inv[o]]
untested = [o for o in ops_sorted if not inv[o]]
no_neg   = [o for o in tested if not neg[o]]

# ---- report ------------------------------------------------------------------------------------
print("# REPL TEST LEDGER — what is tested, how often, and how\n")
print("**GENERATED — do not edit.** `python3 REPL/_test_ledger.py > "
      "OuronetInformational/ARCHITECTURE/REPL-TEST-LEDGER.md`\n")
print("This is the evidence base for the audit and documentation papers: every client entrypoint "
      "Ouronet exposes, how many times each is exercised, how many positive and adversarial "
      "assertions surround it, and which test files touch it.\n")
print("> **How to read the assertion columns.** Assertions are attributed by TRANSACTION BLOCK: "
      "an assertion is credited to every op invoked in the same `(begin-tx … commit-tx)`. A block "
      "that calls three ops and asserts once credits all three. So `+asserts` / `-asserts` measure "
      "how well an op's *neighbourhood* is asserted — they are NOT proof that an assertion targets "
      "that op. **Invocation counts are exact.** Treat a high invocation count with zero "
      "`-asserts` as an op that is exercised but never adversarially probed.\n")

print("## Summary\n")
print(f"| metric | value |\n|---|---:|")
print(f"| client entrypoints (the auditable contract) | {len(ENTRY)} |")
print(f"| exercised at least once | {len(tested)} ({100*len(tested)//len(ENTRY)}%) |")
print(f"| **never exercised** | **{len(untested)}** |")
print(f"| exercised but with NO adversarial assertion in any of its blocks | **{len(no_neg)}** |")
print(f"| total invocations across the suite | {sum(inv.values())} |")

if untested:
    print("\n## Never exercised — G1 gap\n")
    print("These entrypoints are reachable by a client and no test calls them.\n")
    for o in untested: print(f"* `{o.replace('|','&#124;')}`")

print("\n## Exercised but never adversarially probed — G2 gap\n")
print("Called by at least one test, but no `expect-failure` appears in any block that calls them. "
      "Every one of these needs a rejection test per RULE 3.\n")
print("| entrypoint | invocations | +asserts |\n|---|---:|---:|")
for o in sorted(no_neg, key=lambda x: -inv[x]):
    print(f"| <code>{o.replace('|','&#124;')}</code> | {inv[o]} | {pos[o]} |")

print("\n## Full ledger\n")
print("| entrypoint | invocations | +asserts | -asserts | test files |\n|---|---:|---:|---:|---|")
for o in sorted(ops_sorted, key=lambda x: (x.split('|')[0], x)):
    fs = sorted(where[o])
    shown = ', '.join('`%s`' % os.path.basename(x) for x in fs[:3])
    if len(fs) > 3: shown += f' +{len(fs)-3}'
    print(f"| <code>{o.replace('|','&#124;')}</code> | {inv[o]} | {pos[o]} | {neg[o]} | {shown or '—'} |")

json.dump({o: dict(invocations=inv[o], pos=pos[o], neg=neg[o], files=sorted(where[o]))
           for o in ops_sorted}, open('REPL/_test_ledger.json', 'w'), indent=1)

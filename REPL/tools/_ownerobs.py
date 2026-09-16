#!/usr/bin/env python3
"""OWNER GATES WITH NO WITNESS -- which `CAP_*` ownership checks has a test ever reached?

    python3 REPL/tools/_ownerobs.py [--all]

CLAUDE.md's "authorisation precedes validation" ruling is a PROXY for testability: a gate placed
after a business `enforce` may be unreachable in the normal state, so a red-team test can report a
refusal while proving nothing. The thing the proxy stands for is measurable DIRECTLY, and that is
what this does: for every `defcap` carrying a `CAP_*` ownership check, is there an `expect-failure`
anywhere in the suite whose refusal is attributable to THAT gate?

"Never observed" means exactly one thing: **deleting the gate would turn nothing red.** It is NOT a
claim that the gate is wrong, missing, or bypassable -- see RT-D-003, where the defcap really is
missing the line and the tree is still safe because the check lives one layer down in
`DPTF|C>DEBIT`. Treat a hit as "write the attack and find out", not as a defect.

THREE DEFECTS FOUND BY VALIDATING IT, all before its first number was believed. Ground truth: three
non-owner tests added to `[6.2.10]` on 2026-09-16 must flip EXACTLY three entries.

  1. It matched the bare core name `C_Control` -- which SEVEN modules define -- so a keyset test on
     DPTF's op credited SCORE's gate. A name unique inside its module is not unique in the tree.
     Fixed by resolving `ref-X::fn` through the `(ref-X:module{Iface} MODULE)` bindings of the
     enclosing Talos defun.
  2. It read a fixed 900 characters after each `expect-failure` instead of the balanced form, so one
     keyset test credited every op in the same `map print` list. This is verbatim the defect fixed in
     `_eagerlet.py` the same day, reintroduced in the instrument written to audit that class.
  3. `Keyset failure` is the `CAP_*` signature, but a defcap may check ownership by hand with its
     own wording -- `DSA|C>DEFINE-VAULT` is driven by a non-owner in `Kursan/dsa-agency-tests.repl`
     and was reported unobserved. Fixed by also collecting each defcap's ownership-worded `enforce`
     messages.

KNOWN LIMIT, deliberately not papered over: the denominator is a FLOOR. A cap is only counted when a
Talos wrapper calls, on a ref bound to the owning module, a function that acquires it.
`DPTF|C>X-TRANSFER` is reached through class caps rather than directly, so it reads `observed=None`
while RT-D-001 plainly exercises it. Under-counting observation is the safe direction for this
question; over-counting would manufacture false comfort.
"""
import re, glob, os, sys, collections

# PATHS RESOLVED FROM __file__, NOT THE CURRENT DIRECTORY. `_toolindex.py`'s docstring records what
# the other choice costs: after the 2026-09-14 move its cwd-relative glob matched an empty directory
# and it did not error -- it wrote a file with ZERO rows and reported success. A scanner whose input
# silently becomes empty publishes a reassuring zero, which for THIS tool would read as "every owner
# gate is witnessed".
HERE = os.path.dirname(os.path.abspath(__file__))          # REPL/tools
ROOT = os.path.dirname(os.path.dirname(HERE))              # repo root
sys.path.insert(0, HERE)
from _pactlex import strip_comments, balanced

def R(pattern):
    hits = glob.glob(os.path.join(ROOT, pattern), recursive=True)
    return hits

CAP = re.compile(r'CAP_[A-Za-z]')

def module_of(path):
    """The MODULE name a .pact file defines (files also contain interfaces above the module)."""
    m = re.search(r'\(module\s+([A-Za-z0-9_|\-]+)', strip_comments(open(path).read()))
    return m.group(1) if m else None

def refmap(body):
    """ref-NAME -> MODULE, from `(ref-X:module{Iface} MODULE)` let-bindings in a Talos defun."""
    return {m.group(1): m.group(2) for m in
            re.finditer(r'\((ref-[A-Za-z0-9_|\-]+):module\{[^}]*\}\s+([A-Za-z0-9_|\-]+)\)', body)}
ENF = re.compile(r'\(enforce(?!-guard|-one|-keyset)\s')

# ---- 1. every defcap that enforces account ownership, and whether an enforce precedes it
gated = {}
for f in R('1_SOVEREIGN/**/*.pact') + R('2_CITIZEN/**/*.pact'):
    src = strip_comments(open(f).read())
    for m in re.finditer(r'\(defcap\s+([A-Za-z0-9_|>\-]+)', src):
        s = m.start(); e = balanced(src, s)
        if e is None: continue
        body = src[s:e+1]
        c = CAP.search(body)
        if not c: continue
        n = ENF.search(body)
        # DEFECT 3 FIX: `Keyset failure` is the CAP_ signature, but a defcap may ALSO check
        # ownership by hand with its own wording (DSA|C>DEFINE-VAULT: "Only the FVT owner may
        # define the delegation vault"). Collect those messages too, or a genuinely-tested
        # gate is reported as never observed.
        own_msgs = [q for q in re.findall(r'"([^"]{12,})"', body)
                    if re.search(r'owner|ownership', q, re.I)]
        gated[m.group(1)] = (os.path.basename(f), bool(n and n.start() < c.start()), own_msgs)

# ---- 2. core functions that acquire each gated defcap
users = collections.defaultdict(set)
for f in R('1_SOVEREIGN/**/*.pact') + R('2_CITIZEN/**/*.pact'):
    src = strip_comments(open(f).read())
    for m in re.finditer(r'\(def(?:un|pact)\s+([A-Za-z0-9_|>\-]+)', src):
        s = m.start(); e = balanced(src, s)
        if e is None: continue
        body = src[s:e+1]
        for w in re.finditer(r'with-capability\s*\(\s*([A-Za-z0-9_|>\-]+)', body):
            if w.group(1) in gated:
                users[w.group(1)].add((module_of(f), m.group(1)))

# ---- 3. Talos wrappers that call those core functions
talos_src = {}
for f in R('1_SOVEREIGN/**/3_Talos/*.pact') + R('2_CITIZEN/**/*TS02*.pact'):
    talos_src[f] = strip_comments(open(f).read())
wrappers = collections.defaultdict(set)
for cap, funs in users.items():
    for f, src in talos_src.items():
        for m in re.finditer(r'\(defun\s+([A-Za-z0-9_|>\-]+)', src):
            s = m.start(); e = balanced(src, s)
            if e is None: continue
            body = src[s:e+1]
            if len(body.split('\n')) < 4: continue          # interface stub, not the impl
            rm = refmap(body)
            for mod, fn in funs:
                # `::C_Control` alone is NOT enough -- seven modules define one. Require the
                # call to sit on a ref bound to the module that actually owns the gated cap.
                for cm in re.finditer(r'(ref-[A-Za-z0-9_|\-]+)::' + re.escape(fn)
                                      + r'(?![A-Za-z0-9_|\-])', body):
                    if rm.get(cm.group(1)) == mod:
                        wrappers[cap].add(m.group(1))

# ---- 4. which wrappers are driven by a test pinning a Keyset failure
repls = {f: open(f, errors='ignore').read()
         for f in R('REPL/**/*.repl') if '/archive/' not in f}
def observed(names, own_msgs):
    for f, txt in repls.items():
        for em in re.finditer(r'\(expect-failure\b', txt):
            # BALANCED extent, not a fixed window. A 900-char window spans the NEIGHBOURING
            # assertions of the same `map print` list, so one keyset test credited every op
            # that happened to follow it. Identical defect to _eagerlet.py's fixed 300-char
            # windows, fixed 2026-09-16 -- and it survived into the instrument written to
            # audit that very class.
            end = balanced(txt, em.start())
            if end is None: continue
            seg = txt[em.start():end + 1]
            if not ('Keyset failure' in seg or any(m[:40] in seg for m in own_msgs)):
                continue
            for nm in names:
                if re.search(re.escape(nm) + r'(?![A-Za-z0-9_|\-])', seg):
                    return f.split('/')[-1]
    return None

rows = []
for cap, (fil, shadowed, own_msgs) in sorted(gated.items()):
    # ONLY module-qualified Talos wrapper names. The bare core names (`C_Control`, `C_Issue`…)
    # are NOT unique -- `C_Control` is defined in SEVEN modules -- so searching for them
    # credits a keyset test on DPTF's op to SCORE's gate. Same defect as matching a Pact
    # identifier with `\\b`: a name that is unique inside its module is not unique in the tree.
    names = {n for n in wrappers.get(cap, set()) if '|' in n}
    if not names: continue
    rows.append((cap, fil, shadowed, observed(names, own_msgs)))

tot = len(rows); obs = sum(1 for r in rows if r[3])
print(f"owner-gated defcaps reachable from a named op : {tot}")
print(f"  observed refusing somebody (Keyset failure) : {obs}")
print(f"  NEVER observed                              : {tot-obs}")
sh = [r for r in rows if r[2]]
print(f"\nof the {len(sh)} whose ownership gate sits AFTER a business enforce:")
print(f"  observed     : {sum(1 for r in sh if r[3])}")
print(f"  NEVER observed: {sum(1 for r in sh if not r[3])}")
print("\n--- shadowed AND never observed (the actionable set) ---")
for cap, fil, _, _ in [r for r in sh if not r[3]]:
    print(f"   {fil:22} {cap}")

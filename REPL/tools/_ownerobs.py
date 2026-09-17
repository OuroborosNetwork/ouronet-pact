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

REACHABILITY IS TRANSITIVE (2026-09-17), AND THAT CHANGES WHAT THE NUMBERS MEAN. Read both:

  · The DENOMINATOR is now nearly complete. Following core->core calls AND capability composition
    took it from 112 of 185 caps to 167, i.e. from a third of the tree excluded to 18 -- and the
    excluded third was not a random third. It contained the DEBIT layer (`DPTF|C>DEBIT`,
    `DPOF|C>DEBIT`, `DPDC-C|C>SINGLE-DEBIT`) and `DPTF|C>X-TRANSFER`: the gates that actually stop
    a stranger moving someone else's tokens, and the one RT-D-003 was written to witness. An
    excluded cap is absent from the ratio, which reads as neither witnessed nor unwitnessed.

  · "OBSERVED" IS NOW AN UPPER BOUND. A test that drives op A and gets an ownership refusal credits
    every gated cap transitively reachable from A, though only one of them actually refused.
    Attribution along a path is by REACHABILITY, not proof.

  · "NEVER OBSERVED" IS THEREFORE A LOWER BOUND on the gap, which is the safe direction: everything
    on the actionable list is genuinely unreached by any test, so it is sound but incomplete. Act on
    that list; do not read the observed count as a coverage score.
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

# BOTH BRANCHES of DALOS::CAP_EnforceAccountOwnership, which is an `if` on account type:
#   UR_AccountType -> UEV_SmartAccOwn    -> "Smart DALOS Account {} Ownership could not be verified!"
#                  -> UEV_StandardAccOwn -> a raw keyset failure
# Only the standard branch was recognised until 2026-09-17, so every gate on a SMART-account-owned
# entity read as unobserved even where a test drove it -- DPTF's special-role trio is owned by a
# `Σ.` account and refuses in those words. Same class as defect 3 below, found the same way: by
# running an attack and reading what actually came back instead of what was expected to.
OWNERSHIP_SIGNATURES = ("Keyset failure", "Ownership could not be verified")

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

# ---- 2. the CORE CALL GRAPH, and which caps each core function acquires.
# TRANSITIVE, since 2026-09-17. The first version followed ONE hop -- a Talos wrapper calling a
# function that acquires the cap -- and that excluded 73 of the tree's 185 CAP_*-bearing defcaps
# from its own denominator, including the entire DEBIT layer: `DPTF|C>DEBIT`, `DPOF|C>DEBIT`,
# `DPDC-C|C>SINGLE-DEBIT`, `DPTF|C>X-TRANSFER`. Those are reached THROUGH a core function
# (`C_MultiTransfer` -> `ref-DPTF::XB_DebitTrueFungible` -> `DPTF|C>DEBIT`), never directly from
# Talos. `DPTF|C>DEBIT` is the gate RT-D-003 was written to witness, so the tool could not see the
# thing its own test proves. Excluding a cap is not neutral: it is absent from the ratio entirely,
# which reads as neither witnessed nor unwitnessed.
fn_body, fn_caps, fn_names = {}, collections.defaultdict(set), collections.defaultdict(set)
for f in R('1_SOVEREIGN/**/*.pact') + R('2_CITIZEN/**/*.pact'):
    src = strip_comments(open(f).read())
    mod = module_of(f)
    for m in re.finditer(r'\(def(?:un|pact)\s+([A-Za-z0-9_|>\-]+)', src):
        s0 = m.start(); e0 = balanced(src, s0)
        if e0 is None: continue
        body = src[s0:e0+1]
        if len(body.split('\n')) < 3: continue              # interface stub
        key = (mod, m.group(1))
        fn_body[key] = body
        fn_names[mod].add(m.group(1))
        # EVERY acquired capability, gated or not. Filtering to gated ones here broke the chain at
        # any NON-gated intermediary: `C_Transfer` acquires `DPTF|C>CLASS-1-TRANSFER`, which carries
        # no CAP_ of its own and merely composes `DPTF|C>X-TRANSFER`, which carries the sender
        # ownership check. Recording only gated caps made that entire transfer family invisible.
        # Gating is applied at the END, after the composition closure.
        for w in re.finditer(r'with-capability\s*\(\s*([A-Za-z0-9_|>\-]+)', body):
            fn_caps[key].add(w.group(1))

def callees(key):
    """Core functions this one calls: qualified via its own refmap, plus same-module bare calls."""
    mod, _ = key
    body = fn_body.get(key, "")
    out = set()
    rm = refmap(body)
    for cm in re.finditer(r'(ref-[A-Za-z0-9_|\-]+)::([A-Za-z0-9_|>\-]+)', body):
        tgt = rm.get(cm.group(1))
        if tgt and (tgt, cm.group(2)) in fn_body:
            out.add((tgt, cm.group(2)))
    for cm in re.finditer(r'\(([A-Za-z0-9_|>\-]+)', body):
        n = cm.group(1)
        if n in fn_names[mod] and (mod, n) != key:
            out.add((mod, n))
    return out

_callee_cache = {}
def reach(seed):
    """Every core function transitively reachable from <seed>, seed included."""
    seen, stack = set(), [seed]
    while stack:
        k = stack.pop()
        if k in seen or k not in fn_body: continue
        seen.add(k)
        if k not in _callee_cache: _callee_cache[k] = callees(k)
        stack.extend(_callee_cache[k] - seen)
    return seen

# CAP -> CAP edges. A capability is not only ACQUIRED by a function; it is also COMPOSED by another
# capability, and that is a second way to reach a gate. `DPTF|C>X-TRANSFER` -- the sender-ownership
# check RT-D-001 attacks -- is composed by `DPTF|C>CLASS-1-TRANSFER` and friends and is acquired
# directly by nothing, so following only `with-capability` left it invisible. Closing over
# `compose-capability` as well is what makes the DEBIT/TRANSFER layer assessable at all.
composes = collections.defaultdict(set)
for f in R('1_SOVEREIGN/**/*.pact') + R('2_CITIZEN/**/*.pact'):
    src = strip_comments(open(f).read())
    for m in re.finditer(r'\(defcap\s+([A-Za-z0-9_|>\-]+)', src):
        s0 = m.start(); e0 = balanced(src, s0)
        if e0 is None: continue
        body = src[s0:e0+1]
        for cm in re.finditer(r'compose-capability\s*\(\s*([A-Za-z0-9_|>\-]+)', body):
            composes[m.group(1)].add(cm.group(1))

def cap_closure(cap):
    seen, stack = set(), [cap]
    while stack:
        c = stack.pop()
        if c in seen: continue
        seen.add(c)
        stack.extend(composes.get(c, set()) - seen)
    return seen

users = collections.defaultdict(set)
for key, caps in fn_caps.items():
    for c in caps:
        for c2 in cap_closure(c):
            if c2 in gated:
                users[c2].add(key)

# ---- 3. Talos wrappers, mapped through the transitive closure of what they call
talos_src = {}
for f in R('1_SOVEREIGN/**/3_Talos/*.pact') + R('2_CITIZEN/**/*TS02*.pact'):
    talos_src[f] = strip_comments(open(f).read())
wrappers = collections.defaultdict(set)
cap_depth = {}
for f, src in talos_src.items():
    for m in re.finditer(r'\(defun\s+([A-Za-z0-9_|>\-]+)', src):
        s0 = m.start(); e0 = balanced(src, s0)
        if e0 is None: continue
        body = src[s0:e0+1]
        if len(body.split('\n')) < 4: continue              # interface stub, not the impl
        wname = m.group(1)
        rm = refmap(body)
        seeds = set()
        for cm in re.finditer(r'(ref-[A-Za-z0-9_|\-]+)::([A-Za-z0-9_|>\-]+)', body):
            tgt = rm.get(cm.group(1))
            if tgt and (tgt, cm.group(2)) in fn_body:
                seeds.add((tgt, cm.group(2)))
        # DEPTH, not just reachability. The cap acquired by the op the test actually CALLS is the
        # one a refusal is attributable to; anything reached further down the chain is merely on the
        # path. `SWP|C>ENABLE-FROZEN` is the defcap of `SWP|C_EnableFrozenLP` (depth 0) and its
        # non-owner test at `[6.3]_SWP.repl:3180` genuinely pins it; `DPTF|C>ISSUE` sits ten hops
        # downstream of the same call and is credited by the same refusal, which proves nothing
        # about DPTF issuance. Dilution counted how many caps shared a credit; depth says which one
        # earned it.
        seen_depth = {}
        frontier, d = set(seeds), 0
        while frontier:
            nxt = set()
            for k in frontier:
                if k in seen_depth: continue
                seen_depth[k] = d
                if k not in _callee_cache: _callee_cache[k] = callees(k)
                nxt |= _callee_cache[k] - set(seen_depth)
            frontier, d = nxt, d + 1
        for k, kd in seen_depth.items():
            for c in fn_caps.get(k, ()):
                for c2 in cap_closure(c):
                    if c2 in gated:
                        wrappers[c2].add(wname)
                        prev = cap_depth.get((c2, wname))
                        if prev is None or kd < prev:
                            cap_depth[(c2, wname)] = kd

# ---- 4. which wrappers are driven by a test pinning a Keyset failure
repls = {f: open(f, errors='ignore').read()
         for f in R('REPL/**/*.repl') if '/archive/' not in f}
def observed(names, own_msgs, cap_for_attr):
    hits = []
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
            if not (any(sig in seg for sig in OWNERSHIP_SIGNATURES)
                    or any(m[:40] in seg for m in own_msgs)):
                continue
            for nm in names:
                if re.search(re.escape(nm) + r'(?![A-Za-z0-9_|\-])', seg):
                    hits.append((f.split('/')[-1], nm))
    # BEST credit, not the FIRST one found. Returning the first match made attribution depend on
    # file iteration order: `DPTF|C>DEBIT` was reported at depth 3 via `ORBR|C_WithdrawFees` while
    # RT-D-003 -- the test written specifically to witness it -- credits it far closer. A metric
    # that ranks evidence must not pick its evidence arbitrarily.
    if not hits: return None
    return min(hits, key=lambda h: cap_depth.get((cap_for_attr, h[1]), 99))

# --census: the tool's OWN denominator. Every figure this script prints is conditioned on a cap
# being reachable from a qualified Talos wrapper, and a reader who is not told how many caps fail
# that condition cannot tell "39 of 112 witnessed" from "39 of everything". A scanner that reports a
# ratio without its exclusions is the shape section 7.2g of the DEFECT-LEDGER is about.
if "--census" in sys.argv:
    _all = set(gated)
    _mapped = {c for c in gated if {n for n in wrappers.get(c, set()) if "|" in n}}
    _users = {c for c in gated if users.get(c)}
    print(f"CAP_*-bearing defcaps in the tree        : {len(_all)}")
    print(f"  ...acquired by some core fn            : {len(_users)}")
    print(f"  ...AND reached by a Talos wrapper      : {len(_mapped)}   <- the denominator used below")
    print(f"  EXCLUDED, i.e. invisible to this tool  : {len(_all) - len(_mapped)}")
    _c = collections.Counter(gated[c][0] for c in _all - _mapped)
    print("  excluded, by file:")
    for k, v in _c.most_common(12):
        print(f"     {v:3}  {k}")
    # Exclusion is not automatically a gap. A cap with no Talos wrapper may be legitimately
    # unreachable -- a protected XI_/XE_/S> band cap, or a member of the LEGACY DPMF module -- so
    # the names are printed alongside the count. A bare "73 excluded" invites both over- and
    # under-reaction; the split below is the thing worth acting on.
    _band = collections.Counter()
    for c in sorted(_all - _mapped):
        seg = c.split("|")[-1]
        _band["client C>" if seg.startswith("C>") else
              "special S>" if seg.startswith("S>") else
              "internal X" if seg[:1] == "X" else
              "admin/other"] += 1
    print("  excluded, by band:")
    for k, v in _band.most_common():
        print(f"     {v:3}  {k}")
    if "--names" in sys.argv:
        print("  excluded names:")
        for c in sorted(_all - _mapped):
            print(f"     {gated[c][0]:22} {c}")
    print()

rows = []
for cap, (fil, shadowed, own_msgs) in sorted(gated.items()):
    # ONLY module-qualified Talos wrapper names. The bare core names (`C_Control`, `C_Issue`…)
    # are NOT unique -- `C_Control` is defined in SEVEN modules -- so searching for them
    # credits a keyset test on DPTF's op to SCORE's gate. Same defect as matching a Pact
    # identifier with `\\b`: a name that is unique inside its module is not unique in the tree.
    names = {n for n in wrappers.get(cap, set()) if '|' in n}
    if not names: continue
    rows.append((cap, fil, shadowed, observed(names, own_msgs, cap)))

# ATTRIBUTION. "Reached by a test" is not "refused by this gate". A wrapper that reaches N gated caps
# credits all N from one refusal, though exactly one of them raised it. Where N == 1 the refusal IS
# attributable; where N > 1 the credit is a guess that happens to be recorded as a fact.
# MEASURED INSTANCE: `DPOF|C>TRANSFER` sat in the observed column before any test drove a non-owner
# ortofungible transfer. Writing that attack (DPOF-G13) moved no count, because the gate was already
# credited. The gap was real and the tool said it was covered.
reach_count = collections.Counter()
for c, ws in wrappers.items():
    for w in ws:
        reach_count[w] += 1

tot = len(rows); obs = sum(1 for r in rows if r[3])
attributed = sum(1 for r in rows if r[3] and reach_count[r[3][1]] == 1)
ambiguous  = obs - attributed
print(f"owner-gated defcaps reachable from a named op : {tot}")
print(f"  observed (UPPER bound -- reachability, not proof): {obs}")
# DILUTION, not a binary. The first cut of this reported "attributable" only when the crediting op
# reached exactly ONE gate, which scored 1 of 63 and read as "the observed column is worthless".
# The distribution says otherwise: half the credits come from ops reaching two gates, which is decent
# evidence, while a fifth come from ops reaching ten or more, which is nearly none. A binary hid both.
_dep = [cap_depth.get((r[0], r[3][1]), 99) for r in rows if r[3]]
print(f"     ATTRIBUTED  (depth 0 -- the called op's own gate)  : {sum(1 for d in _dep if d == 0)}")
print(f"     circumstantial (depth 1)                          : {sum(1 for d in _dep if d == 1)}")
print(f"     on the path only (depth 2+)                       : {sum(1 for d in _dep if d >= 2)}")
if "--weak" in sys.argv:
    # Caps whose ONLY evidence is a refusal from an op that reaches many gates. They sit in the
    # observed column and are therefore absent from the actionable list, but the credit is close to
    # worthless -- these are gaps that LOOK covered, which is strictly worse than gaps that look open.
    print("\n--- credited ONLY from depth 2+: in the observed column, but nothing proves it ---")
    for cap, fil, shd, ob in sorted(rows, key=lambda r: r[0]):
        if ob and cap_depth.get((cap, ob[1]), 99) >= 2:
            print(f"   {fil:22} {cap:34} via {ob[1]} (depth {cap_depth[(cap, ob[1])]})")
    print()

if "--dilution" in sys.argv:
    _d = collections.Counter(reach_count[r[3][1]] for r in rows if r[3])
    print("     dilution of the crediting op (gates it reaches -> how many caps it credits):")
    for k in sorted(_d):
        print(f"        reaches {k:3} gate(s) : {_d[k]:3} cap(s) credited")
print(f"  NEVER observed (LOWER bound on the real gap): {tot-obs}")
sh = [r for r in rows if r[2]]
print(f"\nof the {len(sh)} whose ownership gate sits AFTER a business enforce:")
print(f"  observed     : {sum(1 for r in sh if r[3])}")
print(f"  NEVER observed: {sum(1 for r in sh if not r[3])}")
print("\n--- shadowed AND never observed (the actionable set) ---")
for cap, fil, _, _ in [r for r in sh if not r[3]]:
    print(f"   {fil:22} {cap}")

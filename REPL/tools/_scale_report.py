#!/usr/bin/env python3
"""SCALE OF THE REPL TEST SUITE — size, reach, and per-function exercise counts.

Run from REPL/:   python3 _scale_report.py            (summary)
                  python3 _scale_report.py --functions (+ every function and its call count)
                  python3 _scale_report.py --untested  (+ only the functions nothing calls)

WHAT IS COUNTED, and what each number does NOT mean.

  REPL LINES      every .repl under REPL/ except archive/. Split into code / comment / blank so
                  the headline is not inflated by the commentary, which in this suite is
                  substantial and deliberate.

  MODULE FUNCTIONS  every (defun ...) in 1_SOVEREIGN + 2_CITIZEN, excluding /Audit/. Interface
                  DECLARATIONS are excluded: a name appears twice (declaration + implementation)
                  and counting both would double the denominator. Kept by (file, name) so two
                  modules may legitimately share a function name.

  CALLS           a call site is (ref-X::fn ...) or (MODULE.fn ...) inside a .repl. `ref-X` is
                  resolved through the file's own (ref-X:module{I} M) bindings, so attribution is
                  by MODULE, not by bare name -- without that, DPTF/DPOF/DPMF/DPDC share so many
                  function names that counts would be meaningless.

  "TESTED"        means CALLED from a .repl, not asserted about. A function invoked once inside a
                  deploy fixture counts the same as one with twenty expect-failures against it.
                  This measures REACH; guard-level rigour is what _enforce_coverage.py measures.
                  Read the two together.
"""
import re, glob, os, sys, collections

ROOT = ".."
ARGS = set(sys.argv[1:])

# ---------- 1. REPL size -----------------------------------------------------------------------
repl_files = [f for f in sorted(glob.glob("**/*.repl", recursive=True))
              if not f.startswith("archive" + os.sep)]
code = comment = blank = 0
per_dir = collections.Counter()
for f in repl_files:
    for ln in open(f, encoding='utf8', errors='ignore'):
        s = ln.strip()
        if not s: blank += 1
        elif s.startswith(';'): comment += 1
        else: code += 1
    per_dir[f.split(os.sep)[0] if os.sep in f else "(root)"] += sum(1 for _ in open(f, encoding='utf8', errors='ignore'))

# ---------- 2. module functions ----------------------------------------------------------------
def strip_c(src):
    o=[];i=0;n=len(src);ins=False;esc=False
    while i<n:
        c=src[i]
        if ins:
            o.append(c)
            if esc: esc=False
            elif c=='\\': esc=True
            elif c=='"': ins=False
            i+=1
        elif c=='"': ins=True;o.append(c);i+=1
        elif c==';':
            while i<n and src[i]!='\n': o.append(' ');i+=1
        else: o.append(c);i+=1
    return ''.join(o)

pact_files = [f for f in sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                                + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
              if "/Audit/" not in f]
MODFILE = {}                      # module name -> basename
funcs = {}                        # (module, fname) -> prefix
for f in pact_files:
    src = strip_c(open(f, encoding='utf8', errors='ignore').read())
    mods = re.findall(r'^\(module\s+([A-Za-z0-9|_-]+)', src, re.M)
    for m in mods: MODFILE[m] = os.path.basename(f)
    if not mods: continue
    mod = mods[0]
    # only bodies AFTER the (module ...) line -- everything before is interface declaration
    body = src[src.index("(module " + mod):]
    for fm in re.finditer(r'\(defun\s+([A-Za-z0-9|_>-]+)', body):
        nm = fm.group(1)
        pfx = re.match(r'^(?:[A-Za-z0-9|_-]+\|)?([A-Z]+[a-z]?)_', nm)
        funcs[(mod, nm)] = pfx.group(1) if pfx else "other"

# ---------- 3. call sites ----------------------------------------------------------------------
REFBIND = re.compile(r'\((ref-[A-Za-z0-9|_-]+):module\{[A-Za-z0-9|_-]+\}\s+([A-Za-z][A-Za-z0-9|_.-]*)\)')
CALL_REF = re.compile(r'\(\s*(ref-[A-Za-z0-9|_-]+)::([A-Za-z0-9|_>-]+)')
CALL_MOD = re.compile(r'\(\s*([A-Z][A-Za-z0-9|_-]*)\.([A-Za-z0-9|_>-]+)')
calls = collections.Counter()
unresolved = 0
for f in repl_files:
    src = open(f, encoding='utf8', errors='ignore').read()
    local = {v: m for v, m in REFBIND.findall(src)}
    for ref, fn in CALL_REF.findall(src):
        mod = local.get(ref)
        if mod: calls[(mod, fn)] += 1
        else: unresolved += 1
    for mod, fn in CALL_MOD.findall(src):
        if mod in MODFILE: calls[(mod, fn)] += 1

# ---------- 3b. TRANSITIVE REACH ---------------------------------------------------------------
# DIRECT CALLS UNDERSTATE EXERCISE, and badly. A UR_ reader is almost never called from a .repl --
# it is called by its own module's C_ while that C_ runs under test. Counting only direct calls
# reports those readers as untouched when every test in the suite runs them.
#
# So: build the intra/inter-module call graph from the .pact sources and propagate reachability
# from the directly-called set. A function is REACHED if a test calls it, or calls something that
# (transitively) calls it.
#
# LIMITS, stated because they bound the number: the graph is built from source text, so a bare
# (UR_Foo ...) is attributed to the ENCLOSING module and a (ref-X::UR_Foo ...) through that file's
# ref bindings -- the same resolution the call counter uses. Dynamic dispatch through a modref
# passed as an argument is invisible. Reached means EXECUTED, not ASSERTED ABOUT.
callees = collections.defaultdict(set)
for f in pact_files:
    src = strip_c(open(f, encoding='utf8', errors='ignore').read())
    mods = re.findall(r'^\(module\s+([A-Za-z0-9|_-]+)', src, re.M)
    if not mods: continue
    mod = mods[0]
    body = src[src.index("(module " + mod):]
    local = {v: m for v, m in REFBIND.findall(body)}
    own = {nm for (m, nm) in funcs if m == mod}
    for fm in re.finditer(r'\(defun\s+([A-Za-z0-9|_>-]+)', body):
        nm = fm.group(1)
        i = fm.start(); d = 0; j = i
        while j < len(body):
            if body[j] == '(': d += 1
            elif body[j] == ')':
                d -= 1
                if d == 0: break
            j += 1
        blk = body[i:j+1]
        for ref, fn in CALL_REF.findall(blk):
            tgt = local.get(ref)
            if tgt: callees[(mod, nm)].add((tgt, fn))
        for bare in re.findall(r'\(\s*([A-Z][A-Za-z0-9|_>-]*)[\s)]', blk):
            if bare in own and bare != nm: callees[(mod, nm)].add((mod, bare))
reached = set(k for k in funcs if calls.get(k, 0) > 0)
frontier = list(reached)
while frontier:
    cur = frontier.pop()
    for nxt in callees.get(cur, ()):
        if nxt in funcs and nxt not in reached:
            reached.add(nxt); frontier.append(nxt)

# ---------- 4. report --------------------------------------------------------------------------
tested = {k for k in funcs if calls.get(k, 0) > 0}
total_calls = sum(v for k, v in calls.items() if k in funcs)
# THE DENOMINATOR MATTERS. A flat "x% of functions are called" is misleading here, because whole
# prefix families CANNOT be called from a REPL by design (CLAUDE.md § prefixes):
#   XI_/XIv_/XB_/XBv_  protected, require-capability inside their own module
#   XE_/XEv_           forward-module entrypoints, gated by UEV_IMC -- only another MODULE may call
#   W*_ (WI/WW/WU)     raw table writers, internal
#   UCk_/UCx_/UDCx_/AU_ internal helpers
# Counting those in the denominator would report a low number and blame the test suite for a
# design decision. So the headline splits CLIENT-REACHABLE surface from INTERNAL-ONLY.
INTERNAL = {"XI","XIv","XB","XBv","XE","XEv","WI","WW","WU","UCk","UCx","UDCx","AU","W"}
ext  = {k for k in funcs if funcs[k] not in INTERNAL}
inte = {k for k in funcs if funcs[k] in INTERNAL}
ext_t = {k for k in ext if calls.get(k,0) > 0}
int_t = {k for k in inte if calls.get(k,0) > 0}
# DEAD MODULES are excluded from the reachable denominator for the same reason
# _enforce_coverage.py excludes them: DPMF is deployed for provenance and never called.
dead = {k for k in ext if MODFILE.get(k[0],"") == "00_DPMF.pact"}
ext_live = ext - dead
ext_live_t = ext_t - dead

print("REPL TEST SUITE — SCALE\n")
print(f"  .repl files                     : {len(repl_files)}")
print(f"  total lines                     : {code+comment+blank}")
print(f"     code                         : {code}")
print(f"     comment                      : {comment}")
print(f"     blank                        : {blank}")
print()
print(f"  module functions (defun, impl)  : {len(funcs)}")
print(f"     CLIENT-REACHABLE (live modules): {len(ext_live)}")
print(f"        called at least once         : {len(ext_live_t)} ({100*len(ext_live_t)//max(len(ext_live),1)}%)")
print(f"        never called                 : {len(ext_live)-len(ext_live_t)}")
print(f"     in the DEAD module (00_DPMF)   : {len(dead)}  (deployed for provenance, never called)")
print(f"     INTERNAL-ONLY by design        : {len(inte)}  (XI/XB/XE/W*/UCk/UCx/UDCx/AU)")
print(f"        incidentally called anyway   : {len(int_t)}  (a REPL may reach XE_ only via a module)")
print()
print(f"  REACHED TRANSITIVELY (a test calls it, or calls something that does):")
_rl = reached & ext_live
print(f"     of client-reachable live functions: {len(_rl)} of {len(ext_live)} ({100*len(_rl)//max(len(ext_live),1)}%)")
print(f"     never reached at all             : {len(ext_live)-len(_rl)}")
print()
print(f"  TOTAL call sites (duplicates included): {total_calls}")
print(f"  calls to a ref- binding this tool could not resolve: {unresolved}")
print()
print("  by prefix:")
bypfx = collections.Counter(v for v in funcs.values())
bypfx_t = collections.Counter(funcs[k] for k in tested)
bypfx_c = collections.Counter()
for k, n in calls.items():
    if k in funcs: bypfx_c[funcs[k]] += n
for p, n in bypfx.most_common():
    print(f"    {p:6} {bypfx_t.get(p,0):5}/{n:<5} called   {bypfx_c.get(p,0):7} call sites")
print()
print("  modules with the most UNCALLED client-reachable functions:")
_un = collections.Counter(MODFILE.get(k[0],"?") for k in (ext_live - ext_live_t))
_tot = collections.Counter(MODFILE.get(k[0],"?") for k in ext_live)
# DETERMINISTIC ORDER (2026-09-14). Counter.most_common breaks ties by insertion order, and the
# insertion order here comes from iterating a SET DIFFERENCE of strings -- which Python varies
# between runs via hash randomisation. Two runs of this tool on an unchanged tree produced
# different output. That is corrosive in a project whose method is "regenerate and diff": it makes
# a spurious change appear in a generated audit artefact, and teaches the reader to ignore diffs.
for _m, _n in sorted(_un.items(), key=lambda kv: (-kv[1], kv[0]))[:10]:
    print(f"    {_m:26} {_n:5} of {_tot[_m]:<5} uncalled")
print()
print("  .repl lines by area:")
for d, n in per_dir.most_common(8):
    print(f"    {d:28} {n:7}")

if "--functions" in ARGS or "--untested" in ARGS:
    print("\n" + ("=" * 78))
    rows = sorted(funcs, key=lambda k: (-calls.get(k, 0), k[0], k[1]))
    if "--untested" in ARGS:
        rows = [k for k in rows if calls.get(k, 0) == 0]
        print(f"FUNCTIONS NEVER CALLED FROM ANY .repl — {len(rows)}\n")
    else:
        print(f"EVERY FUNCTION AND ITS CALL COUNT — {len(rows)}\n")
    print("  calls  reach  file                     module         function")
    print("  -----  -----  ----                     ------         --------")
    for k in rows:
        # reach: DIRECT = a .repl names it; VIA = only executed through another function; none.
        r = "DIRECT" if calls.get(k,0) > 0 else ("VIA" if k in reached else "-")
        print(f"  {calls.get(k,0):6}  {r:5}  {MODFILE.get(k[0],'?'):24} {k[0]:14} {k[1]}")

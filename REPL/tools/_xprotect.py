#!/usr/bin/env python3
"""X_ PROTECTION CLASSES — derive, verify and emit the `;;Protection:` line.

    cd REPL && python3 _xprotect.py            # report the class census
    cd REPL && python3 _xprotect.py --verify   # declared vs derived; non-zero on mismatch
    cd REPL && python3 _xprotect.py --write    # generate/refresh every annotation

THE CANON (owner ruling, 2026-09-10). A `W_` function is a SECURE-protected direct writer --
all of them, without exception. An `X_` function AGGREGATES writes with custom logic and is
called by `C_`/`A_`. Every `X_` must therefore be protected, and exactly one of five ways:

    Class 1  innate    — protected by something it composes; NAME the 1-hop protectors
    Class 2  SECURE    — require/with-capability (SECURE)
    Class 3  custom    — a purpose-built capability
    Class 4  IMC       — P|UEV_IMC (which itself composes SECURE, so it can be called from within)
    Class 5  IMC+custom— P|UEV_IMC followed by (with-capability (CUSTOM) ...)

CLASS 1 IS A LINKED LIST, NOT A CLAIM. The annotation names only the ONE-HOP protectors. An
auditor reading it walks to that function and reads ITS line, and so on; the chain terminates at
a Class 2-5. This is why Class 1 may legitimately name another Class 1 -- the walk continues.
What must hold, and what --verify checks, is that the chain TERMINATES and does not cycle.

Measured 2026-09-10 across 459 X_ implementations: 62/122/103/37/135 by class, ZERO unprotected.

INSTRUMENTATION NOTES, each of which produced a wrong answer before it was fixed:
  * Pact has TWO call forms -- `(ref-RPS::XE_Foo …)` and `(RPS.XE_Foo …)`. Handling only the
    modref left XI_SweepRecomputeWindow looking unprotected when its protection is exactly the
    dotted call it makes.
  * Interface stubs declare the same names with NO body, and a stub's body runs to the next
    `(defun`, swallowing the module header -- so it measures LONGER than the implementation and
    wins a naive dedup. Only members inside `(module …)` are implementations.
  * Innate protection is TRANSITIVE (up to 3 hops observed). One hop finds 12 of 22.
  * `W_` is SECURE by definition; without that axiom six functions read as unprotected.
"""
import argparse, collections, glob, os, re, sys

os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ROOT = ".."

def strip_comments(src):
    out, i, n, ins, esc = [], 0, len(src), False, False
    while i < n:
        c = src[i]
        if ins:
            out.append(c)
            if esc: esc = False
            elif c == '\\': esc = True
            elif c == '"': ins = False
            i += 1
        elif c == '"': ins = True; out.append(c); i += 1
        elif c == ';':
            while i < n and src[i] != '\n': out.append(' '); i += 1
        else: out.append(c); i += 1
    return ''.join(out)

FILES = [f for f in sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                           + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
         if "/Audit/" not in f]

GATE = re.compile(r'\b(?:ref-[A-Za-z0-9|_-]+::)?(?:P\|)?UEV_IMC\b')
# Three call forms, and all three had to be handled before the census stopped lying:
#   (ref-DALOS::XE_UpdateElite …)   modref, the dominant form
#   (DALOS.XE_UpdateElite …)        dotted
#   (XI_Local …)                    unqualified, resolves inside the defining module first
CALL = re.compile(r'\((?:(ref-[A-Za-z0-9|_-]+)::|([A-Z][A-Za-z0-9|_-]*)\.)?([A-Za-z][A-Za-z0-9|_-]*)')
# `(ref-ANK:module{AcquisitionAnchorsV2} AQP-ANK)` -- the ref VARIABLE is not the module name
# (ref-ANK->AQP-ANK, ref-AQP->AQP-POOL, ref-B|ATS->ATS), so the binding must be read, not guessed.
REFBIND = re.compile(r'\((ref-[A-Za-z0-9|_-]+):module\{[A-Za-z0-9|_-]+\}\s+([A-Za-z][A-Za-z0-9|_.-]*)\)')
MODDECL = re.compile(r'^\(module\s+([A-Za-z0-9|_-]+)', re.M)
# A Pact name is pipe-segmented and the prefix can sit in ANY segment -- at the front
# (`XE_U|Rnaq`, `XI_1|ApplyOneFlushEntry`, `XB_W|AccountRoles`) or behind a module qualifier
# (`AQP-POOL|XB_VacateTrueFungible`). Testing only `split('|')[-1]` dropped 124 real X_
# functions from the population and let 4 non-X names in. Test every segment.
# `\d*v?` so the §7.20 `v` variants (XIv_/XBv_/XEv_) stay IN the protection population.
# They are still protected X_ functions; the `v` only declares a justified enforce.
IS_X = re.compile(r'^(XI|XE|XB)\d*v?_')
IS_W = re.compile(r'^(WW|WI|WU|W)\d*_')
def has_prefix(name, rx): return any(rx.match(seg) for seg in name.split('|'))

def index():
    """(path, name) -> (line, body, kind). Implementations only; interface stubs are skipped.

    KEYED BY FILE **AND** NAME, and that is not pedantry: 28 X_ names are defined in more than
    one module (XI_Control 7x, XI_ChangeOwnership 5x, XI_Issue 5x …) covering 77 of the 508
    definitions. A name-only key silently classified 49 functions from ANOTHER module's body --
    which would have written 49 annotations that lie, the exact failure this whole scheme is
    meant to prevent. Caught by the dry run.
    """
    mem = {}
    for f in FILES:
        src = strip_comments(open(f, encoding='utf8', errors='ignore').read())
        L = src.split('\n')
        inmod, idx = False, []
        for i, l in enumerate(L):
            if re.match(r'^\(module\s', l): inmod = True
            elif re.match(r'^\(interface\s', l): inmod = False
            if inmod and re.match(r'^\s{1,8}\((defun|defcap)\s', l): idx.append(i)
        idx.append(len(L))
        for a, b in zip(idx, idx[1:]):
            m = re.match(r'^\s{1,8}\((defun|defcap)\s+([^\s():]+)', L[a])
            if m: mem[(f, m.group(2))] = (a + 1, '\n'.join(L[a:b]), m.group(1))
    return mem

MODFILE, REF_F, REF_G = {}, {}, {}
for _f in FILES:
    _src = strip_comments(open(_f, encoding='utf8', errors='ignore').read())
    for _m in MODDECL.findall(_src): MODFILE.setdefault(_m, _f)
    for _v, _mod in REFBIND.findall(_src):
        REF_F.setdefault((_f, _v), _mod); REF_G.setdefault(_v, _mod)

MEM = index()
BY_NAME = collections.defaultdict(list)
for (_f, _n) in MEM: BY_NAME[_n].append(_f)

def resolve(caller_file, refvar, dotted, callee):
    """Point a call site at the ONE definition it actually reaches.

    Getting this wrong is not a rounding error. Keyed by name alone, `XI_Issue` in DPTF read
    SCORE's body. Keyed by file but ignoring the qualifier, `ref-DALOS::XE_UpdateElite` failed to
    resolve at all (the name is defined in several files) and XI_DirectUpdateEliteAccount --
    which is protected by precisely that call -- reported as UNPROTECTED.
    """
    mod = None
    if refvar:   mod = REF_F.get((caller_file, refvar)) or REF_G.get(refvar)
    elif dotted: mod = dotted
    if mod:
        f = MODFILE.get(mod)
        return (f, callee) if f and (f, callee) in MEM else None
    # Unqualified: Pact looks inside the defining module first.
    if (caller_file, callee) in MEM: return (caller_file, callee)
    fs = BY_NAME.get(callee)
    return (fs[0], callee) if fs and len(fs) == 1 else None

def direct_class(key):
    """Class 2-5 if the function protects itself; (None, []) otherwise. key = (file, name)."""
    if key not in MEM: return None, []
    body = MEM[key][1]
    if has_prefix(key[1], IS_W): return 2, ["SECURE"]
    req = sorted(set(re.findall(r'\(require-capability\s+\(([^\s()]+)', body)))
    wit = sorted(set(re.findall(r'\(with-capability\s+\(([^\s()]+)', body)))
    imc = bool(GATE.search(body))
    if imc and wit: return 5, ["P|UEV_IMC"] + wit
    if imc:         return 4, ["P|UEV_IMC"]
    for s in (req, wit):
        if s: return (2, ["SECURE"]) if any("SECURE" in x for x in s) else (3, s)
    return None, []

def one_hop_protectors(key):
    """Every DIRECT callee that is itself protected, or is an X_ that is (transitively) —
    the canon says list the one-hop protectors and let the auditor walk."""
    # A one-hop protector is ANY direct callee that is itself protected -- directly (Class 2-5)
    # or innately (its own chain terminates). Restricting this to X_/W_ callees was wrong and
    # left three RPS functions reading as unprotected: XI_BookCollectUnclaimed reaches
    # WU_RpsGlobal|UnclaimedCount at 3 hops THROUGH a plain helper, which the narrow version
    # refused to walk. The owner's rule is the broad one -- "if any of the composing functions
    # is also protected, the function is protected innately".
    f, name = key
    direct_hits, transitive_hits = [], []
    for rv, dt, c in dict.fromkeys(CALL.findall(MEM[key][1])):
        ck = resolve(f, rv, dt, c)
        if not ck or ck == key: continue
        if direct_class(ck)[0]:
            if c not in direct_hits: direct_hits.append(c)
        elif chain_terminates(ck):
            if c not in transitive_hits: transitive_hits.append(c)
    # Prefer naming callees protected IN THEMSELVES -- a shorter walk for the auditor.
    return direct_hits or transitive_hits

def chain_terminates(key, seen=None, depth=0):
    if seen is None: seen = set()
    if key in seen or depth > 8 or key not in MEM: return False
    seen.add(key)
    if direct_class(key)[0]: return True
    for rv, dt, c in dict.fromkeys(CALL.findall(MEM[key][1])):
        ck = resolve(key[0], rv, dt, c)
        if ck and ck != key and chain_terminates(ck, seen, depth + 1): return True
    return False

def classify(key):
    k, why = direct_class(key)
    if k: return k, why
    hops = one_hop_protectors(key)
    return (1, hops) if hops else (None, [])

WIDTH = 92

def line_for(k, why):
    """The single logical annotation string (unwrapped). `verify` compares against THIS."""
    if k == 1: return f";;Protection: Class 1 — Innate protection offered by {', '.join(why)}"
    if k == 2: return  ";;Protection: Class 2 — SECURE"
    if k == 3: return f";;Protection: Class 3 — Custom: {', '.join(why)}"
    if k == 4: return  ";;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)"
    if k == 5: return f";;Protection: Class 5 — IMC + Custom: {', '.join(why[1:])}"
    return ";;Protection: !! UNCLASSIFIED — no protection found"


def block_for(k, why, indent):
    """Wrap to CLAUDE.md's ~92-char budget. 41 of 632 overflow, one at 556 chars.

    EVERY physical line carries the `;;Protection:` prefix, continuations included. That is
    deliberate: reassembly is then unambiguous (strip prefix, join, squeeze spaces) and the
    writer's safety invariant -- it may only ever touch a line starting `;;Protection:` -- keeps
    holding for multi-line blocks without needing to recognise a separate continuation syntax.
    """
    text, tag, cont = line_for(k, why), ";;Protection:", ' ' * 10
    # Budget differs per line: the first carries one space after the tag, continuations carry ten.
    # Assuming one space for both is what left 11 lines at 95-101 chars on the first pass.
    def budget(first): return WIDTH - len(indent) - len(tag) - (1 if first else len(cont))
    out, cur = [], None
    for word in text[len(tag):].strip().split(' '):
        if cur is None: cur = word
        elif len(cur) + 1 + len(word) <= budget(not out): cur += ' ' + word
        else: out.append(cur); cur = word
    out.append(cur or "")
    return [f"{indent}{tag} {out[0]}"] + [f"{indent}{tag}{cont}{c}" for c in out[1:]]


def read_block(lines, i):
    """The consecutive `;;Protection:` lines immediately above index i -> (start, logical text)."""
    j = i
    while j > 0 and lines[j-1].strip().startswith(";;Protection:"): j -= 1
    if j == i: return i, None
    joined = ' '.join(l.strip()[len(";;Protection:"):].strip() for l in lines[j:i])
    return j, ";;Protection: " + re.sub(r'\s+', ' ', joined).strip()


def write_annotations(dry=True):
    """Insert/refresh the `;;Protection:` line above every X_ implementation.

    SAFETY, and it is not decorative -- a paren-scanning edit destroyed 1.7M lines in this repo
    once and 624 lines another time. This writer therefore:
      * works PURELY line-based (never parses parens),
      * only ever INSERTS a line or REPLACES an existing `;;Protection:` line,
      * never touches any other line, and
      * asserts the resulting line count equals old + inserted, per file, before writing.
    Placed ABOVE the `(defun`, not inside it: CLAUDE.md requires `@doc` to sit immediately after
    the parameter list, so anything inserted inside the body would break that rule.
    """
    xs = x_functions()
    per_file = collections.defaultdict(list)
    for (f, n), (l, _b, _k) in xs.items():
        per_file[f].append((l, n, classify((f, n))))
    total_ins = total_upd = 0
    for f, items in sorted(per_file.items()):
        L = open(f, encoding='utf8').read().split('\n')
        out = list(L)
        ins = upd = 0
        for l, n, (k, why) in sorted(items, reverse=True):   # bottom-up: indices stay valid
            i = l - 1
            indent = re.match(r'^(\s*)', out[i]).group(1)
            want = line_for(k, why)
            start, have = read_block(out, i)
            blk = block_for(k, why, indent)
            # Compare the RENDERED block, not just the logical text: re-wrapping changes the
            # physical lines while the reassembled string stays equal, and a logical-only
            # comparison silently declined to fix 11 over-long lines.
            if out[start:i] == blk: continue
            out[start:i] = blk
            if have is None: ins += 1
            else:            upd += 1
        # THE invariant: strip every `;;Protection:` line from before and after -- what remains
        # must be byte-identical. Nothing else in the file can have moved or changed.
        strip = lambda xs_: [x for x in xs_ if not x.strip().startswith(";;Protection:")]
        assert strip(L) == strip(out), f"non-annotation line changed in {f}"
        total_ins += ins; total_upd += upd
        if not dry and (ins or upd):
            open(f, 'w', encoding='utf8').write('\n'.join(out))
    return total_ins, total_upd

def x_functions():
    return {k: v for k, v in MEM.items()
            if v[2] == 'defun' and has_prefix(k[1], IS_X)}

def verify():
    """Compare the DECLARED `;;Protection:` line against what the source actually does.

    The point of the annotation is that an auditor can trust it at a glance. A line that has
    drifted from the code is worse than no line, because it reads as verified. So: missing is a
    failure, and disagreeing is a failure.
    """
    xs = x_functions()
    missing, mismatch = [], []
    for (f, n), (l, _b, _k) in sorted(xs.items()):
        want = line_for(*classify((f, n)))
        _, have = read_block(open(f, encoding='utf8').read().split('\n'), l - 1)
        if have is None:      missing.append((f, l, n))
        elif have != want:    mismatch.append((f, l, n, have, want))
    print(f"[x-protection-declared] {len(xs)} X_ functions: "
          f"{len(missing)} missing, {len(mismatch)} disagreeing with source")
    for f, l, n in missing[:20]:  print(f"   MISSING  {os.path.basename(f)}:{l} {n}")
    for f, l, n, got, want in mismatch[:20]:
        print(f"   DRIFT    {os.path.basename(f)}:{l} {n}\n      declared: {got}\n      derived : {want}")
    return 1 if (missing or mismatch) else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--verify", action="store_true")
    ap.add_argument("--write", nargs="?", const="go", choices=["dry","go"])
    a = ap.parse_args()
    if a.verify: return verify()
    if a.write is not None:
        ins, upd = write_annotations(dry=(a.write == "dry"))
        print(f"{'DRY RUN — ' if a.write == 'dry' else ''}{ins} inserted, {upd} refreshed")
        if a.write == "dry": return 0
    xs = x_functions()
    cnt, bad, cycles = collections.Counter(), [], []
    for (f, n), (l, _body, _kind) in sorted(xs.items()):
        k, why = classify((f, n))
        cnt[k if k else "UNCLASSIFIED"] += 1
        if not k: bad.append((f, l, n))
        elif k == 1 and not chain_terminates((f, n)): cycles.append((f, l, n))
    print(f"X_ PROTECTION — {len(xs)} implementations\n")
    for k in (1, 2, 3, 4, 5):
        print(f"  Class {k}  {cnt[k]:5d}")
    print(f"  UNCLASSIFIED {cnt['UNCLASSIFIED']:4d}")
    if cycles:
        print(f"\n!! {len(cycles)} Class-1 chain(s) that do NOT terminate at a Class 2-5:")
        for f, l, n in cycles: print(f"   {os.path.basename(f)}:{l} {n}")
    if bad:
        print(f"\n!! {len(bad)} UNPROTECTED:")
        for f, l, n in bad: print(f"   {os.path.basename(f)}:{l} {n}")
    return 1 if (bad or cycles) else 0

if __name__ == "__main__":
    sys.exit(main())

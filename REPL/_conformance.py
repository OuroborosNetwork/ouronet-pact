#!/usr/bin/env python3
"""STATIC CONFORMANCE LINTER — does the code obey the prefix contracts it claims?

    cd REPL && python3 _conformance.py [--show N] [--rule R]

This is G4, and it is NOT G2. G2 asks "is the guard we wrote working?" and is derived from the
`enforce` statements. G4 asks "does the code obey its own stated design?" — derived from
CLAUDE.md / StoicSyntax / MODULE_ARCHITECTURE — and the guard may not exist at all. A violated
architectural rule is a CLASS of vulnerability, not one bug: if `URC_` may `enforce`, then
validation lives outside the defcaps and "all authorisation is in the defcap" is false everywhere
at once.

FUNCTION BOUNDARIES ARE LINE-BASED, DELIBERATELY. A paren-depth scan of this codebase once
reported 932 violations of which the first three sampled were all false positives — because
Pact's `let` blocks, modrefs and multi-line arg lists defeat naive depth tracking. Here a member
runs from its `(defun …` line to the line before the next top-level-in-module `(def…` line. That
is coarse, and it is honest: it never claims to know more than it does.

Every rule below cites the sentence it enforces. A finding this tool cannot cite is not a finding.
"""
import argparse, glob, os, re, sys, collections

os.chdir(os.path.dirname(os.path.abspath(__file__)))
ROOT = ".."

# --- lexing -------------------------------------------------------------------------------------
def strip(src):
    """Blank out ;; comments and "string" bodies, PRESERVING line structure so line numbers hold."""
    out, i, n, in_str, esc = [], 0, len(src), False, False
    while i < n:
        c = src[i]
        if in_str:
            if esc: esc = False
            elif c == '\\': esc = True
            elif c == '"': in_str = False
            out.append('\n' if c == '\n' else ' ')
        elif c == '"':
            in_str = True; out.append(' ')
        elif c == ';':
            while i < n and src[i] != '\n': out.append(' '); i += 1
            continue
        else:
            out.append(c)
        i += 1
    return ''.join(out)

MEMBER = re.compile(r'^\s{1,8}\((defun|defcap|defpact|defconst|deftable|defschema)\s+([^\s()]+)')
MODULE = re.compile(r'^\(module\s')
IFACE  = re.compile(r'^\(interface\s')

def members(path):
    """Yield (kind, name, start_line, [body lines]) for every member of a MODULE (not interface)."""
    raw = open(path, encoding='utf8', errors='ignore').read()
    lines = strip(raw).splitlines()
    inmod, cur = False, None
    for idx, ln in enumerate(lines):
        if MODULE.match(ln): inmod, cur = True, None
        elif IFACE.match(ln): inmod, cur = False, None
        if not inmod: continue
        m = MEMBER.match(ln)
        if m:
            if cur: yield cur
            cur = [m.group(1), m.group(2), idx + 1, [ln]]
        elif cur:
            cur[3].append(ln)
    if cur and inmod: yield cur

# --- the contracts ------------------------------------------------------------------------------
# Each rule: (id, applies-to predicate, detector, the sentence it enforces)
READ_PRIM  = re.compile(r'\((read|with-read|with-default-read|select|keys|fold-db|txlog|txids)\s')
ENFORCE    = re.compile(r'\((enforce|enforce-one|enforce-guard|enforce-keyset)\s')
UEV_CALL   = re.compile(r'\(\s*(?:ref-[A-Za-z0-9|_-]+::)?(UEV_|CAP_)[A-Za-z0-9|_-]*\s')
WRITE_PRIM = re.compile(r'\((insert|update|write)\s')

STATE_CALL = re.compile(r'\(\s*(?:ref-[A-Za-z0-9|_-]+::)?(?:UR_|URC_|URH_)[A-Za-z0-9|_-]*\s')

def state_dependent(body):
    """Does this member reach chain state at all -- a table primitive, or a UR_/URC_/URH_ call?

    This is the axis that decides how much an `enforce` in an unprotected reader COSTS. An
    enforce over the function's own arguments is deterministic and caller-controllable: the
    caller can always avoid it by passing valid input. An enforce over STATE is a validation
    that lives outside the defcap, which is precisely the guarantee the prefix system sells.
    DEMIPAD's UR_Funds is the worked example: it enforces the same predicate C>WITHDRAW's
    capability does, runs FIRST, and thereby makes the capability's own check dead code."""
    return any(READ_PRIM.search(l) or STATE_CALL.search(l) for l in body)

def pfx(name, p):
    """Prefix match on the LOCAL part: 'DPTF|UR_Foo' and 'UR_Foo' both count as UR_."""
    return name.split('|')[-1].startswith(p)

RULES = []
def rule(rid, doc):
    def deco(fn): RULES.append((rid, doc, fn)); return fn
    return deco

@rule("UC-no-read", "`UC_*` — Pure compute on arguments only: NO TABLE READS. (CLAUDE.md)")
def _(kind, name, body):
    if kind != "defun" or not pfx(name, "UC_"): return
    for i, ln in enumerate(body):
        if READ_PRIM.search(ln): return i

@rule("UC-no-enforce", "`UC_*` — Pure compute on arguments only: NO `enforce`. (CLAUDE.md)")
def _(kind, name, body):
    if kind != "defun" or not pfx(name, "UC_"): return
    for i, ln in enumerate(body):
        if ENFORCE.search(ln): return i

@rule("UR-no-enforce", "`UR_*` — Table reads. Validation belongs in `UEV_*`/defcap. (CLAUDE.md)")
def _(kind, name, body):
    if kind != "defun" or not pfx(name, "UR_"): return
    for i, ln in enumerate(body):
        if ENFORCE.search(ln): return i

@rule("URC-no-enforce", "`URC_*` — Read + derive. **No `enforce`** (validation lives in "
                        "`UEV_*` / defcap). (CLAUDE.md)")
def _(kind, name, body):
    if kind != "defun" or not pfx(name, "URC_"): return
    for i, ln in enumerate(body):
        if ENFORCE.search(ln): return i

@rule("XE-starts-UEV_IMC", "`XE_*` — forward-module entrypoint. START with `UEV_IMC`. (CLAUDE.md)")
def _(kind, name, body):
    if kind != "defun" or not pfx(name, "XE_"): return
    if not any("UEV_IMC" in ln for ln in body): return 0

@rule("XI-no-enforce", "`XI_*`/`XB_*` — must NOT `enforce` or call `UEV_*`; every check belongs "
                       "in the defcap. (CLAUDE.md)")
def _(kind, name, body):
    if kind != "defun" or not (pfx(name, "XI_") or pfx(name, "XB_")): return
    for i, ln in enumerate(body):
        if ENFORCE.search(ln) or UEV_CALL.search(ln): return i

@rule("XI-no-trailing-true", "`XI_*` — body ends on `insert`/`update`/`write`; NO trailing "
                             "`true`. (CLAUDE.md)")
def _(kind, name, body):
    """A GRATUITOUS trailing `true` only. `(if cond (do …) true)` ends the body with a line
    reading `true`, but that is an IF-ARM, not a returned constant -- flagging it was the first
    false positive this linter produced. An arm is always indented deeper than the defun's own
    statement level, so compare indentation with the `(defun` line rather than reading the last
    line in isolation."""
    if kind != "defun" or not pfx(name, "XI_"): return
    head_indent = len(body[0]) - len(body[0].lstrip())
    for i in reversed(range(len(body))):
        t = body[i].strip().rstrip(')').strip()
        if not t: continue
        if t == "true":
            ind = len(body[i]) - len(body[i].lstrip())
            return i if ind <= head_indent + 4 else None
        return

# --- run ----------------------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--show", type=int, default=4, help="examples to print per rule")
    ap.add_argument("--rule", help="only this rule id")
    a = ap.parse_args()

    files = sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                   + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
    files = [f for f in files if "/Audit/" not in f]
    hits = collections.defaultdict(list)
    scanned = 0
    for f in files:
        for kind, name, start, body in members(f):
            scanned += 1
            for rid, doc, fn in RULES:
                if a.rule and rid != a.rule: continue
                off = fn(kind, name, body)
                if off is not None:
                    hits[rid].append((f, start + off, name, body[off].strip()[:96],
                                      state_dependent(body)))

    print(f"CONFORMANCE — {len(files)} modules, {scanned} members scanned\n")
    total = 0
    for rid, doc, _fn in RULES:
        if a.rule and rid != a.rule: continue
        h = hits[rid]; total += len(h)
        st = [x for x in h if x[4]]
        print(f"[{rid}] {len(h)} violation(s)   —   {len(st)} STATE-DEPENDENT, "
              f"{len(h)-len(st)} argument-domain")
        print(f"    RULE: {doc}")
        for f, line, name, txt, sd in sorted(h, key=lambda x: not x[4])[:a.show]:
            print(f"    {'STATE' if sd else '  arg'}  "
                  f"{f.replace(ROOT + '/', ''):56s}:{line:<5d} {name}")
            print(f"           {txt}")
        if len(h) > a.show: print(f"    … and {len(h)-a.show} more")
        print()
    allh = [x for r in hits.values() for x in r]
    print(f"TOTAL: {total}   ({sum(1 for x in allh if x[4])} state-dependent, "
          f"{sum(1 for x in allh if not x[4])} argument-domain)")
    return 0

sys.exit(main())

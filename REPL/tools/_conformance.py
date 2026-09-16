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
import argparse, itertools, os, glob, os, re, sys, collections

os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
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

def _bare(name):
    """Drop the return-type annotation. `UR_RewardTokens:[object{AutostakeV3.ATS|RewardTokenSchemaV2}]`
    -> `UR_RewardTokens`. Splitting on `|` BEFORE doing this is why every prefix rule silently
    skipped any function whose RETURN TYPE contains a pipe -- the split landed inside the type and
    yielded `RewardTokenSchemaV2}]`, which starts with no known prefix. Found 2026-09-10 when
    [UR-no-write] caught 7 of 8 known-bad ATS readers and missed UR_RewardTokens."""
    return name.split(':')[0]

def local_name(name): return _bare(name).split('|')[-1]

def pfx(name, p):
    """Prefix match on ANY pipe segment of the bare name.

    Both placements are canonical (§7.17): scope-first `DPTF|UR_Foo`, and a table qualifier after
    the prefix `UR_STOA-PID|Price`. Testing only `split('|')[-1]` matches the first and misses the
    second -- the same defect that dropped 124 X_ functions from the protection census."""
    return any(seg.startswith(p) for seg in _bare(name).split('|'))

ENFORCE_FALSE = re.compile(r'\(enforce\s+false[\s)]')

def in_branch_default(body, i):
    """Is body[i] the DEFAULT arm of a `cond`, rather than a free-standing `(enforce false)`?

    Signature of the default arm: a `cond` opened above it, and the arms directly above are
    `((...) (...))` branch pairs at a DEEPER-or-equal indent. Worked example: DPDC-C's
    XI_CreditOrDebitCollectables -- 16 `require-capability` branches then this backstop."""
    if not any(re.search(r'\(cond\b', l) for l in body[:i]): return False
    ind = len(re.match(r'^(\s*)', body[i]).group(1))
    for l in reversed(body[:i]):
        if not l.strip(): continue
        return l.strip().startswith("((") or l.strip().startswith(";;") or \
               len(re.match(r'^(\s*)', l).group(1)) >= ind
    return False

REPL_SRC = {f: open(f, encoding='utf8', errors='ignore').read()
            for f in glob.glob("*.repl") + glob.glob("**/*.repl", recursive=True)}

RULES = []
def rule(rid, doc):
    def deco(fn): RULES.append((rid, doc, fn)); return fn
    return deco

@rule("UC-no-read", "`UC_*` — Pure compute on arguments only: NO TABLE READS. (CLAUDE.md)")
def _(kind, name, body):
    if kind != "defun" or not pfx(name, "UC_"): return
    for i, ln in enumerate(body):
        if READ_PRIM.search(ln): return i

# StoicSyntax-Prefixes.md §1: the lowercase `v` role. `UCv_`/`URCv_`/`URDCv_` are the SANCTIONED
# spellings for a function whose `enforce` is intrinsic to its own computation -- a shape/domain
# guard on the computation itself, not business validation. So a `UC_` that enforces is not a
# design violation; it is a MIS-SPELLED `UCv_`. (Owner ruling, 2026-09-09.)
#
# Plus the documented carve-out (StoicSyntax.md §6.1, v1.9.0): U|LST's bounds-guard helpers
# UC_ReplaceAt / UC_RemoveItemAt / UC_LE / UC_FE -- and any UC_* calling them -- stay UC_*.
LST_EXEMPT = {"UC_ReplaceAt", "UC_RemoveItemAt", "UC_LE", "UC_FE"}

@rule("UC-should-be-UCv", "`UC_*` that `enforce`s should be spelled **`UCv_`** — the `v` role, "
                          "\"enforce intrinsic to its own computation\". "
                          "(StoicSyntax-Prefixes.md §1)")
def _(kind, name, body):
    if kind != "defun" or not pfx(name, "UC_") or pfx(name, "UCv_"): return
    if local_name(name) in LST_EXEMPT: return
    for i, ln in enumerate(body):
        if ENFORCE.search(ln):
            # UC_Try wraps enforce-guard in `try` precisely so it CANNOT abort -- a guard TESTER,
            # not a guard. Nothing downstream can observe an abort from it.
            if "(try " in ln: continue
            return i

@rule("UR-no-enforce", "`UR_*` — Table reads. Validation belongs in `UEV_*`/defcap. (CLAUDE.md)")
def _(kind, name, body):
    if kind != "defun" or not pfx(name, "UR_"): return
    for i, ln in enumerate(body):
        if ENFORCE.search(ln): return i

# The read/write separation. Found 2026-09-10: eight ATS `UR_*` readers performed a live table
# `update` to backfill a missing field -- an UNGATED write behind a reader's name, invisible to
# the X_ protection sweep (which only classifies `X*_`), at the caller's own gas expense, and
# fatal under the codebase's own `(try false (UR_X key))` row-existence probe because Pact bans
# DB writes inside `try`. DPTF #30M and SWP #50L were the same defect, fixed earlier.
# `UM_*` (Utility Migrate) is the SANCTIONED prefix for a reader that must persist a migration.
@rule("UR-no-write", "`UR_*`/`URC_*`/`UC_*` must not WRITE. A reader that persists is an ungated "
                     "write behind a reader's name — unprotected, gas-charged to the caller, and "
                     "fatal inside `try` (Pact bans DB writes there). If a migration genuinely "
                     "must persist, spell it **`UM_*`** (StoicSyntax-Prefixes.md §7.19).")
def _(kind, name, body):
    if kind != "defun": return
    if not (pfx(name, "UR_") or pfx(name, "URC_") or pfx(name, "UC_")): return
    if pfx(name, "UM_"): return
    for i, ln in enumerate(body):
        if WRITE_PRIM.search(ln): return i

# Found 2026-09-10: 282 module-ref bindings were bound and never used with `::`. Each is a
# resolved module reference that nothing reads -- dead weight in the let, and noise for anyone
# tracing a function's real dependencies. Removed in two sweeps (229 plain, then 53 that were the
# SOLE binding of their let and took the now-pointless let wrapper with them). This rule exists so
# they cannot regrow: a binding added "for consistency" and left unused is caught on the next run.
@rule("dead-modref-binding", "A `(ref-X:module{I} M)` let-binding that is never used with `X::` "
                             "in the same member. Dead weight: the module reference is resolved "
                             "and then read by nothing.")
def _(kind, name, body):
    if kind not in ("defun", "defcap"): return
    txt = '\n'.join(body)
    for i, ln in enumerate(body):
        m = re.match(r'^\s*\((ref-[A-Za-z0-9|_-]+):module\{[A-Za-z0-9|_-]+\}\s+[A-Za-z][A-Za-z0-9|_.-]*\)\s*$', ln)
        if m and not re.search(re.escape(m.group(1)) + r'::', txt): return i

@rule("no-modref-parameter",
      "No member may take a `module{...}` as a PARAMETER. A modref is CODE, so a parameter of that "
      "type is an entrypoint that executes caller-supplied code inside the sovereign's own scope — "
      "and, for anything reached under `with-capability`, inside its capability. Every modref in "
      "this codebase is instead bound internally, `(ref-X:module{I} CONCRETE-MODULE)`, naming the "
      "module at the call site. That is what bounds the hostile-citizen threat model (RedTeam "
      "family G): a module deployed in the open `user` namespace has no way in. The property held "
      "at 0 across 7,630 members when this rule was written; it is gated so it stays an invariant "
      "rather than an accident.")
def _(kind, name, body):
    if kind not in ("defun", "defcap", "defpact"): return
    txt = '\n'.join(body)
    m = re.search(r'\((?:defun|defcap|defpact)\s+' + re.escape(name) + r'(?::[^\s(]+)?', txt)
    if not m: return
    i = txt.find('(', m.end())
    if i < 0: return
    depth, j = 0, i
    while j < len(txt):                      # balance the PARAMETER LIST only: a `let` further
        if txt[j] == '(': depth += 1         # down legitimately binds modrefs and must not count
        elif txt[j] == ')':
            depth -= 1
            if depth == 0: break
        j += 1
    params = txt[i:j + 1]
    if 'module{' in params:
        return txt[:i].count('\n')

@rule("URC-should-be-URCv", "`URC_*` that `enforce`s should be spelled **`URCv_`** — same `v` "
                            "role. (StoicSyntax-Prefixes.md §1)")
def _(kind, name, body):
    if kind != "defun" or not pfx(name, "URC_") or pfx(name, "URCv_"): return
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
    # §7.20: an `Xv_` variant has DECLARED that its enforce could not be optimally relocated, and
    # carries a `;;Enforce:` line saying why. It is not an undeclared deviation.
    if pfx(name, "XIv_") or pfx(name, "XBv_") or pfx(name, "XEv_"): return
    for i, ln in enumerate(body):
        # §7.20 exemption: `(enforce false …)` as the DEFAULT ARM of an exhaustive branch chain is
        # not a validation -- it asserts the branch table is exhaustive, which no defcap can
        # express because it does not know which branch ran. Narrow by design: default arm only,
        # detected by a preceding `cond`/branch-list context, so it cannot become an escape hatch.
        if ENFORCE_FALSE.search(ln) and in_branch_default(body, i): continue
        if ENFORCE.search(ln) or UEV_CALL.search(ln): return i

@rule("x-enforce-declared", "Every `XIv_`/`XBv_`/`XEv_` carries a `;;Enforce:` line saying WHY its "
                            "check could not be relocated (StoicSyntax-Prefixes §7.20). The `v` "
                            "claims the enforce was optimally placed; the line is the evidence.")
def _(kind, name, body):
    if kind != "defun": return
    if not (pfx(name, "XIv_") or pfx(name, "XBv_") or pfx(name, "XEv_")): return
    return None   # presence is checked against the FILE, above the defun -- see x_enforce_rules

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

# --- whole-module rules -------------------------------------------------------------------------
# The rules above are per-member. These two are claims about a MODULE as a whole, so they get the
# full member list and the file path. Both are stated in CLAUDE.md as things that cannot happen;
# the point of checking is that "cannot" is an architectural claim, not a language guarantee.

SELF_C = re.compile(r'\(\s*(C_[A-Za-z0-9|_-]+)[\s)]')
FWD_X  = re.compile(r'\(\s*ref-[A-Za-z0-9|_-]+::(X[IEB]_[A-Za-z0-9|_-]+)[\s)]')

def module_rules(path, mems):
    """Yield (rule-id, line, name, text) for the two module-scope contracts."""
    own_c = {n for k, n, _s, _b in mems if k == "defun" and n.split('|')[-1].startswith("C_")}
    for kind, name, start, body in mems:
        # (a) a core C_ invoked from inside its OWN module
        #     "C_ is blocked from being invoked inside its own module by design." (CLAUDE.md)
        #     A bare (C_Foo …) call resolves to THIS module; (ref-X::C_Foo …) does not and is
        #     excluded by the regex requiring no `::` before the name.
        if name.split('|')[-1].startswith("C_"):
            pass                      # a C_ calling itself recursively is caught below too
        for i, ln in enumerate(body):
            for m in SELF_C.finditer(ln):
                callee = m.group(1)
                if callee in own_c and callee != name and '::' not in ln[:m.start()+2]:
                    # Split by ROLE. In the citizen minters this is a deliberate, uniform batch
                    # pattern (A_Step01..A_StepNN each call the module's own C_Spawn over a
                    # different range) -- 64 of the first 78 hits were exactly that, and calling
                    # them 64 violations would drown the 2 patterns that actually matter.
                    rid = ("self-C-call-citizen" if "/2_CITIZEN/" in path else "self-C-call")
                    yield (rid, start + i, f"{name} -> {callee}", ln.strip()[:96])
        # (b) a CITIZEN module reaching a protected X* on a sovereign module
        #     "Citizen modules call ONLY into sovereign public APIs." (CLAUDE.md)
        if "/2_CITIZEN/" in path:
            for i, ln in enumerate(body):
                for m in FWD_X.finditer(ln):
                    yield ("citizen-calls-X", start + i, f"{name} -> {m.group(1)}",
                           ln.strip()[:96])

CUMULATOR = re.compile(r'OutputCumulator|URCi_|UDC_ConstructOutputCumulator')


# --- [v-role-justified] : the owner's ruling, 2026-09-10 -------------------------------------
# A `v` variant (UCv_/URv_/URCv_/URDCv_) exists because the enforce was judged OPTIMALLY placed
# inline. StoicSyntax-Prefixes §1 makes that judgement mechanical:
#
#     relocating the check is "complicated" EXACTLY when it results in MORE CODE.
#
# The measurable proxy is the REAL CALLER COUNT. One call site: relocating adds one check and
# removes one, so the v is unjustified. Many: relocating duplicates the identical check N times,
# so it stays. Zero: the function is dead and the question is moot -- reported on its own line
# rather than counted, because deleting dead code is not a prefix decision.
#
# This is an ACTIVE check by design. The owner's point is that the justification is not a
# one-time blessing: a function that earned its `v` at 11 callers stops deserving it if the call
# graph collapses to 1, and nothing else in the toolchain would notice.

def member_body(src, line):
    lines = src.split('\n')
    a = line - 1
    b = a + 1
    while b < len(lines) and not re.match(r'^\s{1,8}\((defun|defcap)\s', lines[b]): b += 1
    return '\n'.join(lines[a:b])

def enforces_on_derived(body):
    """True when any `enforce` reads a name bound by this function's own `let` — i.e. a value it
    DERIVED. Relocating such a check duplicates the derivation, which is more code."""
    bound = set(re.findall(r'\(([a-z][a-z0-9-]*)\s*:[^\s()]+\s', body))
    args = set(re.findall(r'^\s{1,8}\(defun[^\n]*?\(([^)]*)\)', body, re.S))
    argnames = set(re.findall(r'([a-z][a-z0-9-]*):', args.pop())) if args else set()
    derived = bound - argnames
    for m in re.finditer(r'\(enforce(?![-\w])(.{0,240}?)"', body, re.S):
        if derived & set(re.findall(r'[a-z][a-z0-9-]*', m.group(1))): return True
    return False

V_PREFIXES = ("UCv_", "URv_", "URCv_", "URDCv_")

def guards_own_dispatch(body):
    """True when an `enforce` is the DOMAIN GUARD on this function's own `cond` dispatch.

    Third justification category, alongside `enforces_on_derived`. Shape:

        (enforce (contains type [1 2 3]) "Invalid Read Type")
        (cond ((= type 1) …) ((= type 2) …) ((= type 3) …) 0.0)

    The `cond` has a FALL-THROUGH DEFAULT, so deleting the enforce does not raise -- it silently
    returns 0.0 for an out-of-domain input. The guard is what makes the dispatch total, which is
    precisely "intrinsic to its own computation" (§1). Relocating it to the single caller leaves
    the function silently wrong for every future caller, so this is not the cheap-move case the
    caller-count heuristic assumes. Worked examples: DEMIPAD's URv_TotalRaised / URv_Funds twins
    and DPDC's URv_GetVerumChain."""
    if not re.search(r'\(cond\b', body): return False
    switched = set(re.findall(r'\(\(\s*=\s*([A-Za-z][A-Za-z0-9|_-]*)\s', body))
    if not switched: return False
    for m in re.finditer(r'\(enforce\s+(.{0,200}?)"', body, re.S):
        if switched & set(re.findall(r'[A-Za-z][A-Za-z0-9|_-]*', m.group(1))): return True
    return False


def v_role_rules(files_src):
    """Yield (rule, path, line, name, note) for every v-variant that cannot justify its v."""
    defs = {}
    for f, src in files_src.items():
        for m in re.finditer(r'^\s{1,8}\(defun\s+([^\s():]+)', src, re.M):
            n = m.group(1)
            if not n.split('|')[-1].startswith(V_PREFIXES): continue
            ln = src[:m.start()].count('\n') + 1
            body = member_body(src, ln)
            # Interfaces declare `(defun UCv_X:[decimal] (args))` with NO body and load FIRST, so
            # a setdefault bound every v-variant to its own stub -- which has no `let`, so every
            # derived-value check came back false and legitimate `v`s were flagged. Keep the
            # LONGEST body: the implementation always beats the declaration. (Same trap that made
            # _shadowed.py resolve nothing; second time, so it is worth the comment.)
            if n not in defs or len(body) > len(defs[n][2]):
                defs[n] = (f, ln, body)
    for name, (f, line, body) in sorted(defs.items()):
        short = name.split('|')[-1]
        callers = 0
        # REPL SUITES COUNT. UCv_Percent had zero .pact callers and was reported dead -- but
        # REPL/modules/UTILITIES.repl calls it twice and asserts both its value and its failure
        # message. Deleting it would have removed tested behaviour and broken the gate. A
        # function under test is not dead; measure the whole repo, not just the modules.
        for g, src in {**files_src, **REPL_SRC}.items():
            for m in re.finditer(r'\((?:ref-[A-Za-z0-9|_-]+::)?' + re.escape(short) + r'[\s)]', src):
                ln = src[:m.start()].count('\n') + 1
                if re.match(r'^\s{1,8}\(defun\s', src.split('\n')[ln - 1]): continue
                callers += 1
        # CALLER COUNT IS ONLY HALF THE TEST, and the first version of this rule shipped with
        # only that half and mislabelled a legitimate `v`. U|ATS::UCv_SplitBalanceWithBooleans has
        # ONE caller, so by count alone it looked unjustified -- but three of its four enforces
        # read LET-BOUND INTERMEDIATES (`split`, `big-chunk`, `last-split`). Relocating those to a
        # UEV_ means RECOMPUTING THE ENTIRE SPLIT inside the validator, which is unambiguously
        # more code. The `v` is earned.
        #
        # So: an enforce over the function's own ARGUMENTS is relocatable at the cost of moving
        # it. An enforce over a value the function DERIVED is not -- moving it duplicates the
        # derivation. A `v` is unjustified only when EVERY enforce is argument-only AND there is
        # at most one caller.
        derived = enforces_on_derived(body) or guards_own_dispatch(body)
        if callers == 0:
            yield ("v-role-dead", f, line, name, "0 callers — dead; delete rather than re-prefix")
        elif callers == 1 and not derived:
            yield ("v-role-justified", f, line, name,
                   "1 caller and every enforce is over its own ARGUMENTS — relocating is not more "
                   "code, so the `v` is unearned: move the enforce out")


def x_protection_rules(files_src):
    """[x-protection-declared] — every `X_` carries a `;;Protection:` line, and it tells the truth.

    Canon: StoicSyntax-Prefixes §7.18 (owner ruling 2026-09-10). Delegates to `_xprotect.py`,
    which is the single derivation of the five classes; duplicating that logic here would be a
    second source of truth and the two would drift.

    Two failures, and the second matters more than the first. MISSING is an un-audited function.
    DRIFT is worse: a stale line reads as verified and an auditor stops there.
    """
    try:
        import importlib.util
        # SIBLING, resolved from __file__ rather than from the cwd. This was "_xprotect.py",
        # which worked only because the tools sat in REPL/ and _conformance chdir's to REPL/.
        # After the move to REPL/tools/ it resolved to REPL/_xprotect.py and failed -- loudly,
        # because the except below turns it into a reported violation, but still wrongly.
        _xp = os.path.join(os.path.dirname(os.path.abspath(__file__)), "_xprotect.py")
        spec = importlib.util.spec_from_file_location("_xprotect", _xp)
        xp = importlib.util.module_from_spec(spec); spec.loader.exec_module(xp)
    except Exception as e:
        yield ("x-protection-declared", __file__, 0, "<loader>", f"could not load _xprotect.py: {e}")
        return
    for (f, n), (l, _b, _k) in sorted(xp.x_functions().items()):
        want = xp.line_for(*xp.classify((f, n)))
        _, have = xp.read_block(files_src.get(f, open(f, encoding='utf8').read()).split('\n'), l - 1)
        if have is None:
            yield ("x-protection-declared", f, l, n, "no `;;Protection:` line — un-audited")
        elif have != have if False else (have != want):
            yield ("x-protection-declared", f, l, n,
                   f"DRIFT — declared {have.split(':', 1)[1].strip()!r}, "
                   f"source says {want.split(':', 1)[1].strip()!r}")


def admin_gate_rules(files_src):
    """[admin-gate-terminal] — an `A_*` gated only by an always-true cap AND delegating nowhere.

    Found the hard way. TS01-A's ORBR|A_Fuel was written `(with-capability (SECURE) ...)`, and
    SECURE in that module is `(defcap SECURE () true)` -- a C1 trivial cap that grants itself. Its
    own @doc said "As Stand-Alone Function, can only be used by the Admin"; nothing enforced that,
    so any signer could fire it. It was found by probing Talos admin entrypoints with a non-admin
    key during an unrelated coverage sweep, which is not a repeatable way to find the next one.

    The rule has to be narrower than "an A_ gated by a trivial cap", because that shape is CORRECT
    for a Talos wrapper: P|TS merely marks "this arrived through Talos" and the real admin gate
    lives in the core module it delegates to (DALOS|A_ToggleGAP -> DALOS::A_ToggleGAP ->
    GOV|DALOS_ADMIN, pinned by CONFORMANCE <<CONF-04>>). Nineteen entrypoints match that shape and
    all nineteen are fine.

    What made ORBR|A_Fuel different is that it called a module-LOCAL XI_ and never crossed a
    modref -- so there was no downstream module left to hold the gate. Trivial cap AND no
    delegation is the defect; either alone is not.

    DO NOT EXTEND THIS TO `C_` -- tested 2026-09-11, produces false positives. Widening the prefix
    filter to (A|AA|Ap|AAp|C|CC|Cp|CCp)_ yields 8 hits, and the two checked by hand are both
    correctly gated:
      * SWP::C_ModifyWeights -- `P|UEV_IMC` + bare SECURE, but calls the in-module XB_ModifyWeights,
        whose SWP|S>WEIGHTS cap composes CAP_Owner. Ownership IS enforced.
      * DEMIPAD::C_TransmitSemiFungibles / _TransmitNonFungibles -- same shape via XI_TransmitCollectables.
    The reason is structural, which is why the A_-only scope was right: an `A_` delegates ACROSS a
    modref, so "no modref" really does mean "no downstream gate". A `C_` delegates to an IN-MODULE
    `XI_`/`XB_` that carries its own capability, and this rule's delegation test only looks for
    `ref-X::`. Extending it properly means following in-module X* calls and inspecting THEIR caps --
    real work, and there is no evidence of a defect there to justify it.
    """
    for f, src in files_src.items():
        body_src = strip(src)
        trivial, caps = set(), {}
        for m in re.finditer(r'\(defcap\s+([A-Za-z0-9|_>-]+)', body_src):
            i = m.start(); d = 0; j = i
            while j < len(body_src):
                if body_src[j] == '(': d += 1
                elif body_src[j] == ')':
                    d -= 1
                    if d == 0: caps[m.group(1)] = body_src[i:j+1]; break
                j += 1
        for nm, cb in caps.items():
            rest = cb[cb.find(')')+1:-1]
            rest = re.sub(r'@doc\s*"(?:[^"\\]|\\.)*"', '', rest)
            rest = re.sub(r'@(event|managed)[^\n]*', '', rest)
            if rest.strip() == 'true': trivial.add(nm)
        for _ in range(4):                       # transitively trivial
            for nm, cb in caps.items():
                if nm in trivial: continue
                rest = cb[cb.find(')')+1:-1]
                rest = re.sub(r'@doc\s*"(?:[^"\\]|\\.)*"', '', rest)
                rest = re.sub(r'@(event|managed)[^\n]*', '', rest)
                comps = re.findall(r'\(compose-capability\s+\(([A-Za-z0-9|_>-]+)', rest)
                left = re.sub(r'\(compose-capability\s+\([^)]*\)\s*\)', '', rest).strip()
                if comps and left in ('', 'true') and all(c in trivial for c in comps):
                    trivial.add(nm)
        # a name resolves TWICE (interface declaration, then implementation) -- keep the longest
        best = {}
        for m in re.finditer(r'\(defun\s+([A-Za-z0-9|_>-]+)', body_src):
            i = m.start(); d = 0; j = i
            while j < len(body_src):
                if body_src[j] == '(': d += 1
                elif body_src[j] == ')':
                    d -= 1
                    if d == 0:
                        blk = body_src[i:j+1]
                        if m.group(1) not in best or len(blk) > len(best[m.group(1)]):
                            best[m.group(1)] = blk
                        break
                j += 1
        for nm, fb in best.items():
            if not re.match(r'^([A-Za-z0-9|_-]+\|)?(A|AA|Ap|AAp)_', nm): continue
            gates = (re.findall(r'\(with-capability\s+\(([A-Za-z0-9|_>-]+)', fb)
                     + re.findall(r'\(require-capability\s+\(([A-Za-z0-9|_>-]+)', fb))
            if not gates or not all(g in trivial for g in gates): continue
            if re.search(r'\(\s*ref-[A-Za-z0-9|_-]+::', fb): continue    # delegates: gate is downstream
            line = body_src[:body_src.find(fb)].count('\n') + 1
            yield ("admin-gate-terminal", f, line, nm,
                   f"gated only by {'+'.join(sorted(set(gates)))} (always true) and delegates to no module")


def shadowed_binding_rules(files_src):
    """[shadowed-let-binding] — a `let` group binding the same name twice.

    The later binding wins, so the earlier one's computation is DEAD: it runs, costs gas, reads
    tables, and its value is then discarded unread. Reported as an OBSERVATION, not a violation:
    all three current sites were checked by execution and the two blocks are EQUIVALENT, so
    nothing computes a wrong answer today. It is waste and a readability trap, not a bug.

    Kept because of how it reads in review. In `DPL-UR::URC_PrimordialPrices` the first block
    derives ids positionally from `URC_PrimordialIDs` (`(at 4 p-ids)` -> wstoa) and the second
    re-reads the same ids by name from DALOS. That LOOKS like one of them must be wrong, and the
    positional one looks like the suspect. It is not -- `UR_WrappedStoaID` really is index 4. The
    equivalence is now pinned by STAGEZ-10 so the redundancy can be deleted safely instead of
    being left alone forever because nobody could tell which half was authoritative.
    """
    from _pactlex import balanced as _bal, split_top as _split
    for f, src in files_src.items():
        body_src = strip(src)
        for m in re.finditer(r'\(let\*?\s*\(', body_src):
            g = m.end() - 1
            e = _bal(body_src, g)
            if e < 0:
                continue
            names = []
            for b in _split(body_src[g + 1:e]):
                nm = re.match(r'\(\s*([A-Za-z0-9|_*>-]+)', b)
                if nm:
                    names.append(nm.group(1).split(':')[0])
            dup = sorted(n for n, c in collections.Counter(names).items() if c > 1)
            if dup:
                line = body_src[:m.start()].count('\n') + 1
                yield ("shadowed-let-binding", f, line, f"let({len(names)} bindings)",
                       f"rebinds {', '.join(dup)} — the earlier computation is dead")


def enforce_message_rules(files_src):
    """[enforce-msg-not-format] — an `enforce` whose MESSAGE is a bare `("..." [args])`.

    `format` omitted. Pact then tries to APPLY the string literal to the argument list and raises
    `Cannot apply value to non-closure` -- so the caller gets an internal evaluation error where a
    written, human-readable explanation was intended.

    `enforce` is LAZY in its message (verified: `(enforce (= 1 1) ("m {}" [1]))` returns true), so
    this is invisible until the condition FAILS -- which is precisely the moment the message exists
    to serve. The guard still blocks, so it fails safe; what is lost is the diagnosis, and the
    string is dead text that can never be printed.

    Found in SWP's `SWP|S>RT_OWN`: changing an SWPair's ownership to an account whose Elite tier is
    too low for the pair's special-fee-target count answers "Cannot apply value to non-closure"
    instead of "Insufficient Major Elite Tier for NewOwner ...". One occurrence codebase-wide, which
    is why this rule is cheap to keep at zero.
    """
    from _pactlex import balanced as _bal, split_top as _split
    for f, src in files_src.items():
        body_src = strip(src)
        for m in re.finditer(r'\(enforce(?:-one)?\s', body_src):
            e = _bal(body_src, m.start())
            if e < 0:
                continue
            # NOTE: this module's `strip` BLANKS string bodies, so by here the literal is spaces.
            # ("msg {}" [x]) has become (        [x]) -- an application with an empty head. Matching
            # on a quote (as the standalone version of this scan did) finds NOTHING here, which is
            # exactly how this rule first shipped reporting a clean 0 against a known defect.
            for part in _split(body_src[m.end():e]):
                if re.match(r'\(\s+\[', part):
                    yield ("enforce-msg-not-format", f,
                           body_src[:m.start()].count('\n') + 1, "enforce",
                           "message is a bare (\"...\" [args]) -- `format` omitted, so Pact applies "
                           "the string and raises 'Cannot apply value to non-closure'")
                    break


def bare_template_message_rules(files_src):
    """[enforce-msg-bare-template] — an `enforce` message that is a BARE string containing `{}`.

    No `format` call at all, so the placeholders reach the caller verbatim: *"Brumate requires
    hibernation for {} set to off and for {} set to ON"*. The guard works, the message arrives, and the
    two ids it was written to name are simply absent.

    THE THIRD VARIANT OF ONE FAMILY, and the quietest. All three are message-construction defects:

        ("…{}" [args])   `format` missing entirely   -> "Cannot apply value to non-closure"
                                                        [enforce-msg-not-format], 1 site, fixed
        (format "…")     argument list missing       -> "Expected Pact Value, got closure"
                                                        [format-no-arglist], 5 sites, fixed
        "…{}…"           bare template, no call      -> braces printed literally
                                                        THIS RULE, 1 site, fixed 2026-09-12

    The first two ABORT -- loudly, if you ever reach them. This one fails safe and silent, which is why
    it survived longest: nothing breaks, the sentence is just incomplete.

    THE SCAN TOOK TWO TRIES, and the first returned a clean 0 on an instance already reproduced by hand.
    Cause: `_pactlex.split_top` splits on top-level FORMS and drops bare string tokens, so the message
    was never in the argument list it was being looked for in. Fixed with a depth-aware literal scan
    (`_depth1_literals`). **A scan that returns 0 on a class you have already reproduced is wrong, not
    reassuring** -- the same trap `enforce-msg-not-format` fell into, for a different reason.

    PRECISE AND FALSE-POSITIVE-FREE: a `{}` in a string that is never formatted is never intentional.
    REGRESSION DETECTOR, must stay at 0.
    """
    from _pactlex import balanced as _bal
    for f, src in files_src.items():
        for m in re.finditer(r'\(enforce\s', src):
            e = _bal(src, m.start())
            if e < 0:
                continue
            lits = _depth1_literals(src[m.end():e])
            if lits and "{}" in lits[-1]:
                line = src[:m.start()].count('\n') + 1
                yield ("enforce-msg-bare-template", f, line, "enforce",
                       f"message is a bare template -- the braces print literally: {lits[-1][:60]}")


def _depth1_literals(body):
    """String literals at the TOP level of <body>. `split_top` cannot be used here: it splits on forms
    and discards bare string tokens, which is exactly the thing being looked for."""
    out, d, i, n = [], 0, 0, len(body)
    while i < n:
        c = body[i]
        if c == '"':
            j = i + 1
            while j < n and not (body[j] == '"' and body[j - 1] != '\\'):
                j += 1
            if d == 0:
                out.append(body[i:j + 1])
            i = j + 1
            continue
        if c in '([':
            d += 1
        elif c in ')]':
            d -= 1
        i += 1
    return out


def format_without_args_rules(files_src):
    """[format-no-arglist] — `(format "...")` with a template and NO argument list.

    Pact's `format` takes a template AND a list. Given one argument it is an arity error that
    resolves to a CLOSURE, and the caller dies with `Expected Pact Value, got closure or table
    reference` -- a message that says nothing about what went wrong.

    THE MIRROR OF `enforce-msg-not-format`, and strictly worse. That rule catches a missing `format`,
    which `enforce`'s lazy message hides until the guard fires. This one also fires on SUCCESS paths,
    where there is no laziness to hide behind: three of the five original sites were plain return
    values, so the function did not merely lose a message -- it ABORTED.

        08_ATS.pact:883        enforce message on ATS|C>ADD-HOT-RBT
        12_LIQUID.pact:125    enforce message on the migration gate
        03_DSP+.pact:360      SUCCESS path -- "nothing to mint" return value
        01_DPL-UR.pact:2430   SUCCESS path -- UI stage text once the sale has concluded
        02_INFO-ONE+.pact:2465 SUCCESS path -- broke INFO_ATS|Cull outright

    All five fixed 2026-09-12 (owner-authorised, same class as the missing `format` at
    15_SWP.pact:466). None of the templates had a `{}`, so the repair is to drop `format` -- a plain
    string literal was what every one of them wanted.

    PRECISE AND FALSE-POSITIVE-FREE: a one-argument `format` is never correct. Kept as a REGRESSION
    DETECTOR and must stay at 0. Pinned from the REPL side by `modules/ATS.repl <<ATS-G15>>`.

    THE TWO DEAD-MODULE HITS ARE A DIFFERENT, WORSE SHAPE, and deliberately NOT fixed:
    `00_DPMF.pact:641` and `:645` carry a `{}` placeholder AND no argument list, so dropping `format`
    would print the brace literally -- the repair needs the argument somebody forgot, and guessing it
    in a module that is never called is churn with a chance of being wrong. DPMF is superseded by
    DPOF and deployed for provenance only; the dead-module bucket is where these belong. Recorded so
    the next reader does not re-derive it. (Their live DPTF/SWP twins do pass `[main-dptf]`.)

    A NOTE ON THE SCAN, because it beat a grep: `strip` blanks string literals with SPACES, which
    preserves offsets, so "did anything follow the template?" is just `inner.strip()` on the stripped
    source. A line-based grep for `(format "...")` missed both DPMF sites because their templates use
    backslash-continuation across lines. Structure beats regex whenever the matched thing can wrap.
    """
    from _pactlex import balanced as _bal
    for f, src in files_src.items():
        # `strip` blanks string literals by overwriting them with SPACES, so offsets line up with the
        # raw source. That is what makes this rule easy: after stripping, a `(format "…")` with no
        # argument list has NOTHING left inside it, while `(format "…" [x])` still shows its `[x]`.
        # The literal is then recovered from the raw source at the same offsets for the report.
        body = strip(src)
        for m in re.finditer(r'\(format[\s)]', body):
            e = _bal(body, m.start())
            if e < 0:
                continue
            inner = body[m.start() + len("(format"):e]
            if inner.strip():
                continue                      # something followed the template -- an arg list
            raw = re.sub(r'\s+', ' ', src[m.start():e + 1]).strip()
            if '"' not in raw:
                continue                      # not a literal template; leave it alone
            line = body[:m.start()].count('\n') + 1
            yield ("format-no-arglist", f, line, "format",
                   f"one-argument format -- arity error, dies with "
                   f"'Expected Pact Value, got closure': {raw[:70]}")


def cross_module_scan_rules(files_src):
    """[cross-module-scan] — OBSERVATION: a table scan reaching into ANOTHER module's table, which
    makes the enclosing function LOCAL-ONLY (callable via /local, never inside a transaction).

    CORRECTED 2026-09-12, owner ruling: "keys can be called freely, there is no admin gating on
    this." I had this filed as a runtime-fatal defect -- "six Stage-Z UI readers uncallable on any
    chain" -- and that was WRONG.

    What I measured was real but mis-attributed. In TRANSACTIONAL mode Pact does require the owning
    module's admin for `keys`/`select`/`fold-db`, which is why these abort in a REPL (a REPL
    executes transactionally). Chainweb nodes run with `--allowReadsInLocal` -- verified on this
    machine's own nodes -- so reads are unrestricted in `/local` queries, which is how UI readers
    are actually invoked. The REPL could not model it: `FlagAllowReadInLocal` is a node-level exec
    flag, not settable from the REPL.

    Checked before withdrawing: all six readers have ZERO callers in Pact code. Nothing
    transactional reaches them, so the constraint never bites in production.

    KEPT AS AN OBSERVATION because the property is still worth knowing: a function containing a
    cross-module scan CANNOT be called from a transaction. If one of these is ever invoked from a
    `C_`/`A_` path it becomes a real defect at that moment -- so the list is a watch list, not a
    worklist. The legal in-module form (`DALOS::URH_AccountCounter`) remains the right shape if a
    transactional caller is ever needed.

    LESSON: an error reproduced in a REPL is an error in a REPL. Before calling it a production
    defect, establish that the production execution mode is the same one the test used.
    """
    SCANS = ("keys", "select", "fold-db", "txlog", "txids", "keylog")
    flagged = set()                                    # (file, fn) carrying a cross-module scan
    for f, src in files_src.items():
        body_src = strip(src)
        mm = re.search(r'\(module\s+([A-Za-z0-9|_-]+)', body_src)
        if not mm:
            continue
        owner = mm.group(1)
        defs = [(m.start(), m.group(1))
                for m in re.finditer(r'\(defun\s+([A-Za-z0-9|_>-]+)', body_src)]
        for m in re.finditer(r'\((%s)\s+([A-Za-z0-9|_.-]+)' % "|".join(SCANS), body_src):
            tbl = m.group(2)
            if "." not in tbl:
                continue                       # in-module: legal, admin is held
            mod = tbl.rsplit(".", 1)[0].split(".")[-1]
            if mod == owner:
                continue                       # self-qualified: still in-module
            prev = [d for d in defs if d[0] <= m.start()]
            fn = prev[-1][1] if prev else "<top level>"
            line = body_src[:m.start()].count("\n") + 1
            flagged.add((f, fn))
            yield ("cross-module-scan", f, line, fn,
                   f"({m.group(1)} {tbl}) — needs {mod}'s module admin, which no caller can hold")

    # ENFORCED WATCH CONDITION (added 2026-09-13). The ruling above rests entirely on these
    # functions having ZERO Pact callers -- nothing transactional reaches them, so the local-only
    # constraint never bites. That was verified by hand and then left as prose, which is exactly
    # the kind of premise that silently stops being true. Check it every run instead: if a scan
    # function ever acquires a Pact caller it becomes a real defect AT THAT MOMENT, and this
    # yields a VIOLATION rather than an observation.
    for f, fn in sorted(flagged):
        for g, gsrc in files_src.items():
            gbody = strip(gsrc)                       # comments/strings blanked: no false hits
            for m in re.finditer(r'(?<![A-Za-z0-9|_>-])' + re.escape(fn) + r'(?![A-Za-z0-9|_>-])',
                                 gbody):
                seg = gbody[max(0, m.start() - 80):m.start()]
                if re.search(r'\(defun\s+$', seg):   # its own definition
                    continue
                line = gbody[:m.start()].count("\n") + 1
                yield ("cross-module-scan-called", g, line, fn,
                       f"{fn} contains a cross-module scan and is LOCAL-ONLY, but is referenced "
                       f"here — a transactional caller would abort on module admin")


def uncreated_table_rules(files_src):
    """[table-never-created] — a module declares `(deftable X)` and never `(create-table X)`.

    Found the hard way, and it was worse than a style slip. CADUCEUS declared
    CADUCEUS|ConfigTable and CADUCEUS|SignalTable and created NEITHER. A `deftable` is only a
    declaration: the module compiles, loads and DEPLOYS cleanly without the matching
    `create-table`. Every runtime path then dies on
    `Table ouronet-ns.CADUCEUS_CADUCEUS|ConfigTable not found`. Since every function in that
    module reads or writes the config row, the whole bridge was non-functional -- and nothing
    caught it because CADUCEUS had ZERO REPL coverage: the only thing that had ever touched it
    was a LOAD-ONLY compile check, and a load is exactly what this defect survives.

    That is the lesson worth encoding: "it compiles and deploys" does not imply "a table exists",
    so a compile check cannot substitute for one live call. This rule is the mechanical version
    of that one live call.

    Checked against the raw file because `create-table` sits OUTSIDE the module body, after the
    closing paren, which is where the convention puts it (AOZ+ 8/8, 99_TS02-CPAD 2/2, 03_DSP+ 2/2).

    DPMF is exempt: it is the superseded MetaFungible module, deployed for provenance and never
    called (CLAUDE.md "Historical note: DPMF -> DPOF"), and its tables are uncreated consistently
    with that. Exempting it is a deliberate, narrow carve-out -- if DPMF is ever revived, this
    rule should fire on it.
    """
    EXEMPT = {"00_DPMF.pact"}
    for f, src in files_src.items():
        if os.path.basename(f) in EXEMPT: continue
        # Comments MUST be stripped first. The first version did not, and the very comment
        # documenting the CADUCEUS fix contains the literal text "(deftable ...)" -- which the
        # rule then read as a table named "..." and reported as a permanent phantom violation.
        # A lint rule that fires on prose about itself is worse than no rule.
        bare = '\n'.join(re.sub(r';.*$', '', l) for l in src.split('\n'))
        declared = re.findall(r'\(deftable\s+([A-Za-z][A-Za-z0-9|_-]*)', bare)
        created  = set(re.findall(r'\(create-table\s+([A-Za-z][A-Za-z0-9|_-]*)', bare))
        for t in declared:
            if t not in created:
                line = bare[:bare.find(f"(deftable {t}")].count('\n') + 1
                yield ("table-never-created", f, line, t,
                       "declared with (deftable) and never created -- module deploys, "
                       "every runtime path on this table fails with 'Table not found'")


def x_enforce_rules(files_src):
    """[x-enforce-declared] — the `;;Enforce:` line must exist above every `Xv_` defun.

    Checked against the raw file rather than the member body because the line sits ABOVE the
    `(defun`, outside what `members()` collects."""
    for f, src in files_src.items():
        L = src.split('\n')
        inmod = False
        for i, l in enumerate(L):
            # Interfaces declare the same name with NO body and carry no annotations -- the
            # third time this trap has cost a wrong count, so track the context explicitly.
            if MODULE.match(l): inmod = True
            elif IFACE.match(l): inmod = False
            if not inmod: continue
            m = re.match(r'^\s*\(defun\s+((?:XI|XE|XB)\d*v_[^\s():]*)', l)
            if not m: continue
            j = i
            while j > 0 and L[j-1].strip().startswith(';;Protection:'): j -= 1
            has = j > 0 and (L[j-1].strip().startswith(';;Enforce:') or
                             L[j-1].strip().startswith(';;'))
            block = any(L[k].strip().startswith(';;Enforce:') for k in range(max(0, j-8), j))
            if not block:
                yield ("x-enforce-declared", f, i + 1, m.group(1),
                       "no `;;Enforce:` line — the `v` is claimed but not justified")


def cumulator_rules(path, mems):
    """A core `C_*` that never touches an OutputCumulator is not a client entrypoint.

    CLAUDE.md: "`C_*` — Client entry for citizen modules. Builds IGNIS cumulators and returns
    OutputCumulator." A `C_` with no cumulator anywhere in signature or body is IMC-gated,
    returns a plain value and is called internally -- which is the `XB_` contract wearing the
    `C_` prefix. That mis-prefix is what makes the "C_ is never called from its own module"
    rule look violated: the callers are right, the NAME is wrong."""
    if "/2_Core/" not in path or "/1_SOVEREIGN/" not in path: return
    for kind, name, start, body in mems:
        if kind != "defun" or not name.split('|')[-1].startswith("C_"): continue
        if not any(CUMULATOR.search(l) for l in body):
            yield ("C-without-cumulator", start, name, body[0].strip()[:96])

# Rules whose hits are OBSERVATIONS, not violations: the measurement is sound, but what it
# reveals is that the DOCUMENTED rule is narrower than the code's actual (correct) practice.
# Reporting these in the violation count would make the report lie.
OBSERVATION = {"C-without-cumulator", "self-C-call-citizen", "v-role-dead",
               "shadowed-let-binding", "cross-module-scan"}

MODULE_DOC = {
    "shadowed-let-binding":
        "A `let` group that binds the same name twice. The later wins, so the earlier's "
        "computation runs, costs gas, reads tables, and is then discarded unread. "
        "ALL THREE SITES FIXED 2026-09-13 — this rule should now stay at 0 and stands as a "
        "REGRESSION DETECTOR. They were left alone for a long time because each reads as though "
        "one half MUST be wrong and nobody could tell which was authoritative; the answer was to "
        "pin the equivalence by execution first (STAGEZ-10) and only then delete. What was removed: "
        "(1) `01_DPL-UR.pact` `URC_PrimordialPrices` — a `p-ids` destructure whose six names were "
        "all dead (five shadowed, `ignis` never read), costing a helper call plus six table reads "
        "per invocation; (2) `01_DPL-UR.pact` `URC_0027a_AccountSelectorSingle` — a `public-key` "
        "re-read identical to the `try`-guarded binding above it; (3) `17_SWPL.pact` — a duplicate "
        "`UR_IgnisID` read on the asymmetric-collection swap path, which is TRANSACTIONAL, so it "
        "was real user gas rather than a reader's. Behaviour is unchanged in all three: the "
        "surviving binding is the one that already won the shadowing.",
    "enforce-msg-not-format":
        "An `enforce` whose message is a bare `(\"...\" [args])` -- `format` omitted, so Pact "
        "applies the string to the list and raises `Cannot apply value to non-closure`. `enforce` "
        "is LAZY in its message, so this stays invisible until the condition FAILS, which is "
        "exactly when the message was needed. Fails safe (the guard still blocks) but the written "
        "explanation is dead text. One occurrence when added: SWP|S>RT_OWN -- FIXED 2026-09-12, "
        "owner-authorised (\"if an enforce is missing its string (format outputs a string), you "
        "should just add it\"). This rule now stands as a REGRESSION DETECTOR and should stay at "
        "0; `SWP-G21` pins the repaired message from the REPL side.",
    "enforce-msg-bare-template":
        "An `enforce` message that is a BARE string containing `{}` -- no `format` call at all, so the "
        "placeholders reach the caller verbatim. The THIRD variant of one family: `(\"…{}\" [args])` "
        "aborts with 'Cannot apply value to non-closure', `(format \"…\")` aborts with 'Expected Pact "
        "Value, got closure', and this one fails SAFE AND SILENT -- the guard works and the sentence is "
        "merely incomplete, which is why it survived longest. One site (11_VST.pact:659, ATSU|C>BRUMATE), "
        "fixed 2026-09-12. A `{}` in a string that is never formatted is never intentional, so this is "
        "false-positive-free and stands as a REGRESSION DETECTOR that must stay at 0.",
    "format-no-arglist":
        "`(format \"...\")` with NO argument list. Pact's `format` takes a template AND a list; given "
        "one argument it is an arity error that resolves to a closure, and the caller dies with "
        "`Expected Pact Value, got closure or table reference`. The MIRROR of enforce-msg-not-format "
        "and strictly worse: it also fires on SUCCESS paths, where three of the five original sites "
        "sat, so the function ABORTED rather than merely losing its message. All five fixed "
        "2026-09-12, owner-authorised; none of the templates had a `{}`, so the repair is to drop "
        "`format`. A one-argument format is never correct, so this is false-positive-free and stands "
        "as a REGRESSION DETECTOR that must stay at 0.",
    "cross-module-scan-called":
        "VIOLATION. A function containing a cross-module `keys`/`select`/`fold-db` is LOCAL-ONLY — "
        "it aborts in transactional mode. The whole `cross-module-scan` ruling rests on those "
        "functions having ZERO Pact callers, which was verified by hand on 2026-09-12 and then left "
        "as prose. This rule checks it on every run instead, because a premise nobody re-checks is "
        "a premise that quietly stops being true. A hit means a transactional path now reaches a "
        "local-only reader and will abort with `Module admin necessary for operation`. The fix is "
        "to move the scan into the OWNING module as a `URH_*` and reach it through a modref. "
        "Verified to fire: injecting a `C_` that calls `DPL-UR::URC_0001_HeaderV3` raises "
        "VIOLATIONS 0 -> 1; comment-only mentions do not trip it (the scanner blanks comments).",
    "cross-module-scan":
        "OBSERVATION (was a violation until 2026-09-12; owner ruling: keys is not admin-gated for "
        "the way these are called). A cross-module `keys`/`select`/`fold-db` makes its function "
        "LOCAL-ONLY: it aborts in transactional mode, which is what a REPL provides, but nodes run "
        "`--allowReadsInLocal` so `/local` queries are unrestricted. All six current sites are UI "
        "readers with ZERO Pact callers, so nothing transactional reaches them. A watch list: if one "
        "is ever called from a `C_`/`A_` path it becomes a real defect then. Old text follows. "
        "A `keys`/`select`/`fold-db` on a table owned by a DIFFERENT module. Pact admin-gates "
        "those on the owning module, so the call aborts with `Module admin necessary for "
        "operation but has not been acquired` for every caller on every chain -- there is no "
        "signer who can satisfy it. Added after six Stage-Z UI readers were found uncallable on "
        "mainnet, having been mis-recorded as merely untested; the two worst also hardcode "
        "mainnet ids in an eager `let`, so the id error fired first and hid this one. The legal "
        "form is a `URH_*` in the owning module reached through a modref.",
    "table-never-created":
        "A `(deftable X)` with no matching `(create-table X)`. The module still compiles, loads "
        "and deploys -- `deftable` is only a declaration -- so this survives every load-only "
        "check and then fails at runtime with `Table ... not found` on every path that touches "
        "it. Added after CADUCEUS was found with BOTH of its tables uncreated, which made the "
        "entire bridge non-functional; it had zero REPL coverage, and its only prior check was a "
        "compile/load check, which is precisely what this defect survives. DPMF is exempt "
        "(superseded, deployed for provenance, never called).",
    "admin-gate-terminal":
        "An `A_*` gated ONLY by an always-true cap AND delegating to no other module — so the "
        "gate stops there and nothing enforces the admin key. A trivial gate ALONE is fine on a "
        "Talos wrapper (`P|TS` marks the Talos path; the real gate lives in the core module it "
        "calls). It is the combination that is the defect. Added after TS01-A's `ORBR|A_Fuel` "
        "was found open by hand: its `@doc` said admin-only and `(with-capability (SECURE) …)` "
        "enforced nothing, because that module's `SECURE` is `(defcap SECURE () true)`.",
    "x-protection-declared":
        "Every `X_` function carries a `;;Protection:` line naming its class (StoicSyntax-"
        "Prefixes §7.18, owner ruling 2026-09-10), and that line must agree with what the source "
        "actually does. Generated by `_xprotect.py --write`, never hand-written: a hand-edited "
        "line that drifts is worse than no line, because it reads as verified.",
    "v-role-justified":
        "A `v` variant's `enforce` must be OPTIMALLY placed inline — relocating it is "
        "\"complicated\" EXACTLY when it results in MORE CODE (StoicSyntax-Prefixes §1, owner "
        "ruling 2026-09-10). One caller means relocating is not more code, so the `v` is not "
        "earned. Re-checked every run: a `v` justified at 11 callers stops deserving it if the "
        "call graph collapses to 1.",
    "v-role-dead":
        "A `v` variant with NO callers. The prefix question is moot — this is dead code, and "
        "deleting it is not a prefix decision. Reported, not counted.",
    "self-C-call":
        "`C_*` — **Cannot be invoked from its own module**; clients reach it via Talos. "
        "(CLAUDE.md) — CROSS-CHECKED: every sovereign hit targets `C_DeployAccount` or "
        "`C_TransferDalosFuel`, and BOTH are cumulator-free (see C-without-cumulator). So the "
        "true, sharper statement is: **no BILLING client `C_` is ever invoked from inside its "
        "own module.** The rule holds where it matters; these two carry the `C_` prefix without "
        "the `C_` contract.",
    "self-C-call-citizen":
        "RESOLVED 2026-09-13 — OBSERVATION, not a violation, and the reason is that THE DIRECTION "
        "IS INVERTED relative to the sovereign rule. CLAUDE.md blocks a sovereign `C_` from "
        "self-calling because it builds an IGNIS OutputCumulator that only Talos may collect, so a "
        "self-call could drop or double it. These citizen `C_`s return a **string** — the `format` "
        "output of the Talos wrapper, which has ALREADY collected — so there is no cumulator at "
        "this level to mishandle. They sit UPSTREAM of billing, not downstream. "
        "BOUND: exactly 64 sites, 3 families, 2 files — NOSFERATU `A_FixNN->C_Fix` (24) and "
        "`A_StepNN->C_Spawn` (24), KBunnies `A_StepNN->C_Spawn` (16). A hit in any OTHER citizen "
        "file, or in a citizen `C_` that returns an OutputCumulator, is NOT covered by this ruling. "
        "The one way the shape could still have been wrong — two of the steps split a 70-element "
        "mint across two `C_Spawn` calls, so two Talos collects instead of one — is settled by "
        "execution in `Stage_02/[5.1]_PopulateNosferatu.repl` <<NSFR-G2>>: "
        "`URCi_RegisterCollectablesPrice` is `(* smallest (sum amounts))` with no fixed per-call "
        "component, so 30+40 costs exactly what 70 costs. That test also pins the ONE branch that "
        "would break linearity — the `(and (= ft \"E|\") son (= nu 0))` first-nonce discount — as "
        "out of reach for a DPNF.",
    "citizen-calls-X":
        "Citizen modules call **only** into sovereign public APIs — never a protected `X*`. "
        "(CLAUDE.md) — ACCEPTED EXCEPTION (owner ruling, 2026-09-09): `TS02-CPAD` is a CITIZEN "
        "module AUTHORED BY THE ADMIN, deliberately in between the two roles. It is the sole "
        "gas-funded launchpad path, so its wrappers must reach `TS01-A::XB_DynamicFuelSTOA` to "
        "refuel the station. The four hits are that call and are expected; a FIFTH hit, or the "
        "same call from any other citizen module, is not.",
    "C-without-cumulator":
        "OBSERVATION, not a violation. RE-AUDITED IN FULL 2026-09-13, all 38 traced to their Talos "
        "wrapper. The old note below claimed TWO billing shapes; there are SIX, and the extra four "
        "are why a hit here is almost never a defect: "
        "(C) STOA-PRICED — the wrapper calls `STOA|C_Collect*`, no IGNIS at all; "
        "(D) BILLED-IN-CORE — the core `C_` itself ends on `STOA|C_CollectWT` (SWPLC, DPOF, DPDC "
        "branding); "
        "(E) DEFPACT-STEP — the `C_` is only a starter and billing sits in a later step (all 8 "
        "MTX-SWP pool/liquidity ops); "
        "(F) NESTED-TALOS — the core calls another Talos client (`TS01-C1::DPTF|C_Transfer patron`) "
        "which collects (all 3 DEMIPAD transmit/withdraw); plus "
        "(G) PRIMITIVE — `IGNIS::C_TransferDalosFuel` and the `STOA|C_Collect*` family ARE the "
        "collectors and cannot collect from themselves. "
        "ONE genuinely unbilled op was found and RULED NOT A DEFECT: `TS01-C4::PYTHIA|C_Link` takes "
        "no `patron` and collects nothing, while its three siblings all charge. It is deliberate "
        "(both @docs say \"(no fee)\") and, more to the point, economically bounded: linking needs "
        "two already-deployed Apollo halves at 500 native STOA each, `UEV_DualPairForLink` refuses "
        "a half whose counterpart is set, and counterparts are NEVER cleared (revoke only "
        "deactivates). So it is ONE-SHOT PER PAIR, FOREVER. That bound lived in a different function "
        "and was untested; it is now pinned by `modules/PYTHIA.repl` <<PYTHIA-LINK-ECON>>, which "
        "drives the pair through the full revoke/re-activate cycle and shows the free entry point "
        "stays closed, including against a fresh partner half. "
        "IF THAT BOUND EVER WEAKENS — counterparts become clearable, or a second wrapper for "
        "`C_LinkDualApiKey` appears — this stops being an observation. "
        "Old (incomplete) text follows. CLAUDE.md says `C_*` \"builds IGNIS cumulators and "
        "returns OutputCumulator\" — but TWO billing shapes are in use and both are correct: "
        "(A) the core `C_` returns a cumulator and Talos passes it to `IGNIS::C_Collect`; "
        "(B) the core `C_` returns a plain value and the TALOS WRAPPER builds the cumulator from "
        "a `URCi_` and collects (e.g. DALOS::C_RotateGuard -> TS01-C1). The doc describes only "
        "shape A. These are the shape-B ops plus the STOA-priced ones, which bill no IGNIS at "
        "all.",
}

# --- run ----------------------------------------------------------------------------------------

# --- DISPOSITIONS (P2.5.4) -------------------------------------------------------------------
# P2.5 closes when every deviation is either FIXED or consciously ACCEPTED with a written reason.
# These are the accepted ones. Each is BOUNDED: the tool re-checks the exception still matches
# what was ruled on, so an accepted exception cannot quietly grow into a habit.

DEAD_MODULES = {
    "00_DPMF.pact": "superseded by DPOF; deployed by [2.2]_Core for migration provenance, but the "
                    "only call anywhere in the tree is P|A_Define, the policy boilerplate every "
                    "module carries. Owner's standing instruction: leave DPMF alone.",
}

# rule id -> a predicate over the hit, plus the ruling. Binding on a PREDICATE beats binding on
# a count wherever the reason for accepting is itself checkable: a count only notices that
# something changed, whereas a predicate notices WHAT changed and re-opens on the right grounds.
ACCEPTED_BY_TARGET = {
    "self-C-call": (
        {"C_DeployAccount", "C_TransferDalosFuel"},
        "cross-checked, not asserted: every sovereign hit targets one of these two, and BOTH are "
        "cumulator-free (they appear in C-without-cumulator). So the sharper TRUE statement is "
        "'no BILLING client C_ is ever invoked from inside its own module' -- the rule holds "
        "where it matters, and these two carry the C_ prefix without the C_ contract. The "
        "acceptance is bound to that CUMULATOR-FREE fact and is re-verified below every run: if "
        "either function ever gains an OutputCumulator it becomes a real billing client, the "
        "cross-check fails, and this re-opens on its own."),
}

# rule id -> (exact expected count, where it is allowed, the ruling)
ACCEPTED = {
    "citizen-calls-X": (
        4, "2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact",
        "owner ruling 2026-09-09: TS02-CPAD is a CITIZEN module AUTHORED BY THE ADMIN and is the "
        "sole gas-funded launchpad path, so its wrappers must reach TS01-A::XB_DynamicFuelSTOA. "
        "The bound is the point: exactly these four, from this file only."),
}

CUMULATOR_FREE = set()      # filled by main() from the C-without-cumulator observations

def disposition(rid, h):
    """Split a rule's hits into (open, dead, accepted, broken-acceptance)."""
    dead = [x for x in h if os.path.basename(x[0]) in DEAD_MODULES]
    rest = [x for x in h if x not in dead]
    if rid in ACCEPTED_BY_TARGET:
        targets, _ = ACCEPTED_BY_TARGET[rid]
        ok, bad = [], []
        for x in rest:
            tgt = x[2].split("->")[-1].strip()
            # accepted only while the REASON still holds: the target is one of the ruled-on
            # functions AND is still cumulator-free.
            (ok if (tgt in targets and tgt in CUMULATOR_FREE) else bad).append(x)
        return bad, dead, ok, [x for x in ok if False] if not bad else ok
    if rid in ACCEPTED:
        n, where, _ = ACCEPTED[rid]
        inside = [x for x in rest if where in x[0]]
        outside = [x for x in rest if where not in x[0]]
        # the acceptance holds only if it is EXACTLY what was ruled on
        if len(inside) == n and not outside:
            return [], dead, inside, []
        # The bound is the whole value of an accepted exception, so a break must COUNT, not just
        # print. Returning `inside` as open too is deliberate: a 5th call means the ruling no
        # longer describes the code, and every hit under it needs re-reading, not just the new
        # one. (Caught by self-test: the first version reported the break and still said
        # VIOLATIONS: 0, which would have let an accepted exception grow silently.)
        return outside + inside, dead, [], inside
    return rest, dead, [], []


# SELF-TEST for the two rules added during this work, run with --selftest.
#
# It feeds each rule a SYNTHETIC module rather than checking a count against the live codebase.
# That distinction matters: a canary keyed on "cross-module-scan must find 10" would false-alarm
# the day somebody FIXES those ten, which is precisely when the tool should stay quiet. A synthetic
# input tests the RULE, independent of the codebase's current defect state.
#
# Both rules needed this. `enforce-msg-not-format` first shipped reporting a clean 0 over a defect
# already reproduced by hand, because this module's `strip` blanks string bodies and the regex was
# keyed on a quote that no longer existed by then.
SELFTEST_CASES = [
    ("enforce-msg-not-format",
     '(module M G (defun f () (enforce (> 1 0) ("msg {}" [1]))))', 1),
    ("enforce-msg-not-format",
     '(module M G (defun f () (enforce (> 1 0) (format "msg {}" [1]))))', 0),
    ("cross-module-scan",
     '(module M G (defun f () (keys OTHER.OTHER|Tbl)))', 1),
    ("cross-module-scan",
     '(module M G (defun f () (keys M|Own)))', 0),
    # [format-no-arglist] — a one-argument format is never correct; the repaired form has a list.
    ("format-no-arglist", '(defun f () (enforce x (format "plain message")))', 1),
    ("format-no-arglist", '(defun f () (enforce x (format "has {} hole" [y])))', 0),
    ("format-no-arglist", '(defun f () (enforce x "plain message"))', 0),
    # [enforce-msg-bare-template] — a `{}` in a message that is never formatted.
    ("enforce-msg-bare-template", '(defun f () (enforce x "needs {} here"))', 1),
    ("enforce-msg-bare-template", '(defun f () (enforce x (format "needs {} here" [y])))', 0),
    ("enforce-msg-bare-template", '(defun f () (enforce x "no placeholder"))', 0),
]


def run_selftest():
    bad = []
    for rid, src, want in SELFTEST_CASES:
        fake = {"/tmp/_selftest.pact": src}
        gen = {"enforce-msg-not-format": enforce_message_rules,
               "format-no-arglist": format_without_args_rules,
               "enforce-msg-bare-template": bare_template_message_rules}.get(rid, cross_module_scan_rules)
        got = len([h for h in gen(fake) if h[0] == rid])
        status = "ok " if got == want else "BAD"
        if got != want:
            bad.append(f"{rid}: expected {want} hit(s), got {got} on {src[:50]}…")
        print(f"  {status} {rid:26} want={want} got={got}")
    if bad:
        sys.exit("CONFORMANCE SELF-TEST FAILED:\n  " + "\n  ".join(bad) +
                 "\n  The rule is broken, not the codebase.")
    print("\nconformance self-test: OK")
    return 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--show", type=int, default=4, help="examples to print per rule")
    ap.add_argument("--rule", help="only this rule id")
    ap.add_argument("--selftest", action="store_true",
                    help="run the added rules against synthetic inputs and exit")
    ap.add_argument("--check", action="store_true",
                    help="exit 1 on VIOLATIONS (never on observations) -- gate mode")
    a = ap.parse_args()
    if a.selftest:
        return run_selftest()

    files = sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                   + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
    files = [f for f in files if "/Audit/" not in f]
    hits = collections.defaultdict(list)
    files_src = {f: open(f, encoding='utf8', errors='ignore').read() for f in files}
    for rid, f, line, name, note in itertools.chain(v_role_rules(files_src),
                                                    x_protection_rules(files_src),
                                                    x_enforce_rules(files_src),
                                                    admin_gate_rules(files_src),
                                                    uncreated_table_rules(files_src),
                                                    cross_module_scan_rules(files_src),
                                                    enforce_message_rules(files_src),
                                                    format_without_args_rules(files_src),
                                                    bare_template_message_rules(files_src),
                                                    shadowed_binding_rules(files_src)):
        if a.rule and rid != a.rule: continue
        hits[rid].append((f, line, name, note, False))
    scanned = 0
    for f in files:
        mems = list(members(f))
        for rid, line, name, txt in list(module_rules(f, mems)) + list(cumulator_rules(f, mems)):
            if a.rule and rid != a.rule: continue
            hits[rid].append((f, line, name, txt, False))
        for kind, name, start, body in mems:
            scanned += 1
            for rid, doc, fn in RULES:
                if a.rule and rid != a.rule: continue
                off = fn(kind, name, body)
                if off is not None:
                    hits[rid].append((f, start + off, name, body[off].strip()[:96],
                                      state_dependent(body)))

    # the cumulator-free set the self-C-call acceptance is bound to
    CUMULATOR_FREE.update(x[2].split(':')[0] for x in hits["C-without-cumulator"])

    print(f"CONFORMANCE — {len(files)} modules, {scanned} members scanned\n")
    total = 0
    for rid, doc, _fn in RULES + [(k, v, None) for k, v in MODULE_DOC.items()]:
        if a.rule and rid != a.rule: continue
        h_all = hits[rid]
        h, dead, accepted, broke = disposition(rid, h_all)
        if rid not in OBSERVATION: total += len(h)
        st = [x for x in h if x[4]]
        tag = "observation(s)" if rid in OBSERVATION else "violation(s)"
        print(f"[{rid}] {len(h)} {tag}   —   {len(st)} STATE-DEPENDENT, "
              f"{len(h)-len(st)} argument-domain")
        print(f"    RULE: {doc}")
        if dead:
            print(f"    DEAD-MODULE (not a worklist item): {len(dead)} in "
                  f"{', '.join(sorted({os.path.basename(x[0]) for x in dead}))}")
        if accepted:
            why = (ACCEPTED_BY_TARGET[rid][1] if rid in ACCEPTED_BY_TARGET else ACCEPTED[rid][2])
            print(f"    ACCEPTED x{len(accepted)} (bound holds): {why}")
        if broke and rid in ACCEPTED:
            print(f"    !! ACCEPTED BOUND BROKEN: ruled {ACCEPTED[rid][0]}, found {len(broke)} "
                  f"— re-open and re-rule before this passes")
        for f, line, name, txt, sd in sorted(h, key=lambda x: not x[4])[:a.show]:
            print(f"    {'STATE' if sd else '  arg'}  "
                  f"{f.replace(ROOT + '/', ''):56s}:{line:<5d} {name}")
            print(f"           {txt}")
        if len(h) > a.show: print(f"    … and {len(h)-a.show} more")
        print()
    viol = [x for r, h in hits.items() if r not in OBSERVATION
            for x in disposition(r, h)[0]]
    obs  = sum(len(h) for r, h in hits.items() if r in OBSERVATION)
    print(f"VIOLATIONS: {len(viol)}   ({sum(1 for x in viol if x[4])} state-dependent, "
          f"{sum(1 for x in viol if not x[4])} argument-domain)")
    print(f"OBSERVATIONS: {obs}   (the doc is narrower than the code's correct practice)")

    # --check: fail on VIOLATIONS only, never on OBSERVATIONS.
    # ADDED 2026-09-14. A fix-verification pass found this tool's "0 violations" was a
    # HAND-MEASURED figure: the gate byte-compiled this file and ran its selftest, but never ran
    # the tool, so re-introducing the X-02 defect (`ORBR|A_Fuel` gated only by a self-granting
    # SECURE) would have left the gate GREEN -- and that defect was VERIFIED EXPLOITABLE before it
    # was fixed. A number quoted in an audit document as evidence of a repair has to be one the
    # gate re-derives on every run, or it is a claim about the past.
    # Observations are deliberately NOT fatal: there are 114 of them, they record where the
    # documentation is narrower than correct practice, and failing on them would make this
    # unusable and therefore ignored.
    if "--check" in sys.argv and viol:
        print(f"\nCHECK FAILED: {len(viol)} conformance violation(s).")
        return 1
    return 0

sys.exit(main())

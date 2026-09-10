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
import argparse, os, glob, os, re, sys, collections

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

def local_name(name): return name.split('|')[-1].split(':')[0]

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
        for g, src in files_src.items():
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
        derived = enforces_on_derived(body)
        if callers == 0:
            yield ("v-role-dead", f, line, name, "0 callers — dead; delete rather than re-prefix")
        elif callers == 1 and not derived:
            yield ("v-role-justified", f, line, name,
                   "1 caller and every enforce is over its own ARGUMENTS — relocating is not more "
                   "code, so the `v` is unearned: move the enforce out")


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
OBSERVATION = {"C-without-cumulator", "self-C-call-citizen", "v-role-dead"}

MODULE_DOC = {
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
        "Same rule, in CITIZEN modules — where the minters' `A_StepNN -> C_Spawn` batch pattern "
        "makes it a deliberate, uniform design rather than a slip.",
    "citizen-calls-X":
        "Citizen modules call **only** into sovereign public APIs — never a protected `X*`. "
        "(CLAUDE.md) — ACCEPTED EXCEPTION (owner ruling, 2026-09-09): `TS02-CPAD` is a CITIZEN "
        "module AUTHORED BY THE ADMIN, deliberately in between the two roles. It is the sole "
        "gas-funded launchpad path, so its wrappers must reach `TS01-A::XB_DynamicFuelSTOA` to "
        "refuel the station. The four hits are that call and are expected; a FIFTH hit, or the "
        "same call from any other citizen module, is not.",
    "C-without-cumulator":
        "OBSERVATION, not a violation. CLAUDE.md says `C_*` \"builds IGNIS cumulators and "
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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--show", type=int, default=4, help="examples to print per rule")
    ap.add_argument("--rule", help="only this rule id")
    a = ap.parse_args()

    files = sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                   + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
    files = [f for f in files if "/Audit/" not in f]
    hits = collections.defaultdict(list)
    files_src = {f: open(f, encoding='utf8', errors='ignore').read() for f in files}
    for rid, f, line, name, note in v_role_rules(files_src):
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
    return 0

sys.exit(main())

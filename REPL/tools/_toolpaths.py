#!/usr/bin/env python3
"""_toolpaths.py -- every hard-coded path a tool opens at IMPORT TIME must exist.

WHY (2026-09-15)
----------------
The 2026-09-14 tools move (`REPL/*.py` -> `REPL/tools/*.py`) silently killed ELEVEN tools. Each
resolved a sibling by a hard-coded old path:

    spec = spec_from_file_location('lf', 'REPL/_letfix.py')      # now REPL/tools/_letfix.py

and raised FileNotFoundError at MODULE LEVEL -- before argv was read, so dead whatever the
arguments. The move was "verified by output diffing", which is true of the tools that RAN. A dead
tool produces no output to diff, so the verification could not see the failure it caused.

Three were noticed over the following day, by accident, one at a time. The other eight were found
only when a fourth symptom (a stale price sheet) forced someone to run a generator. Two GENERATED
audit artefacts had drifted for a full day underneath, and were hand-edited while dead.

This check is the generalisation, and it is deliberately STATIC -- it never executes a tool, because
several of them rewrite source files at module level. It parses the AST, finds path literals passed
to open()/spec_from_file_location()/Path() OUTSIDE any function or class, and resolves them.

  in-repo path that does not exist  -> FAILURE (this is the tools-move bug)
  absolute or /tmp path             -> warning  (scratch input; inherently ephemeral)

VALIDATED AGAINST THE REAL INCIDENT, not just a synthetic selftest: run against a worktree of
commit 6ab8fe6 (the tree as it stood before the repair) this check reports **11 of 11** dead
paths -- the nine `REPL/_letfix.py` siblings, `_ignis_price_sheet.py`'s worksheet import, and
`_tighten.py`'s deferred `'_gate.py'`. Against the current tree it reports clean. A checker
that has only ever been shown passing is not evidence.

`--check`     exit 1 if any tool references a missing in-repo path
`--selftest`  prove the checker catches a reintroduced stale sibling path
"""
import ast, os, sys, glob as _glob

HERE = os.path.dirname(os.path.abspath(__file__))          # REPL/tools
REPL = os.path.dirname(HERE)                               # REPL
ROOT = os.path.dirname(REPL)                               # repo root

# THREE tool directories exist, and this checker originally scanned one (2026-09-15).
# `REPL/TOOLS.md` states "All 44 analysis scripts live in REPL/tools/" -- which is false: there are
# seven more in `tools/` (including a `gate.sh` that StoicSyntax-Prefixes.md calls "the hard gate")
# and a module-index generator in `OuronetInformational/tools/`. A checker that covers one of three
# directories reports clean about the two it never opened -- the same shape as the `skipped` counter
# that hid 18 unpriced entrypoints. Enumerate the directories instead of naming one.
# CORRECTED 2026-09-17: there are FOUR, not three. `scripts/` holds `embed-module-interfaces.py`,
# which rewrites `.pact` sources and -- until today -- WROTE BY DEFAULT, the exact inversion of
# CLAUDE.md's `--apply` rule, while being invisible to this checker. The comment above committed the
# same error it was written to warn about: it enumerated the directories it knew and then asserted
# that was all of them. Enumerating is not the fix; DISCOVERING is. See `_orphan_tool_dirs` below.
TOOL_DIRS = [HERE,
             os.path.join(ROOT, 'tools'),
             os.path.join(ROOT, 'OuronetInformational', 'tools'),
             os.path.join(ROOT, 'scripts')]

PATHISH_EXT = ('.py', '.repl', '.pact', '.md', '.json', '.txt', '.csv')
OPENERS = {'open', 'spec_from_file_location', 'Path', 'read_text'}

# SUBPROCESS IS THE OTHER WAY A TOOL RESOLVES A SIBLING, and it was the gap that let the
# 2026-09-14 move keep three casualties a further two days (found 2026-09-16). This checker was
# written from the import-time incident, so it modelled open()/spec_from_file_location()/Path()
# and never looked inside `subprocess.run([sys.executable, 'REPL/_thing.py', ...])`.
#
# The three survivors, and note that they failed in THREE different ways -- only one of them
# loudly:
#   _cheapseam.py    exited with a message BLAMING THE USER'S WORKING DIRECTORY, which is why it
#                    survived: the diagnosis was wrong, so following it never helped.
#   _orphanmatch.py  ran to completion on EMPTY stdout and reported "orphans examined: 0 ...
#                    uncredited coverage: 0" -- a dead tool publishing a reassuring zero. The real
#                    figure is 120 orphans examined.
#   _p33_classify.py printed nothing at all.
SUBPROC = {'run', 'check_output', 'check_call', 'call', 'Popen'}


def _is_pathish(s):
    if not s or '*' in s or '?' in s or '\n' in s or len(s) > 300:
        return False
    return s.endswith(PATHISH_EXT) or ('/' in s and not s.startswith('http'))


def _module_level_calls(tree):
    """Yield Call nodes reachable WITHOUT entering a FunctionDef/ClassDef.

    Import-time death is the failure mode; a path inside a function only bites when that
    function is called, which is a different (and much louder) problem.
    """
    def walk(node):
        for child in ast.iter_child_nodes(node):
            if isinstance(child, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
                continue
            if isinstance(child, ast.Call):
                yield child
            yield from walk(child)
    yield from walk(tree)


def _is_write(call):
    """open(p, 'w') creates its target -- absence is not a defect."""
    if not (isinstance(call.func, ast.Name) and call.func.id == 'open'):
        return False
    for a in list(call.args[1:]) + [k.value for k in call.keywords if k.arg == 'mode']:
        if isinstance(a, ast.Constant) and isinstance(a.value, str) and \
           any(c in a.value for c in 'wax'):
            return True
    return False


def _chdir_base(tree):
    """If the module chdirs at import, cwd-relative literals resolve against THAT, not the repo.

    Without this the checker is too permissive and misses a real case: `_tighten.py` chdirs to
    `REPL/` and then does spec_from_file_location('_gate', '_gate.py'). The literal DOES exist
    beside the tool (REPL/tools/_gate.py), so an any-of-these-bases resolver passes it -- while at
    runtime it resolves to REPL/_gate.py, which does not exist. Model the chdir instead: count the
    dirname() wrappers around abspath(__file__) and walk up that many levels from REPL/tools.
    """
    for call in _module_level_calls(tree):
        fn = call.func
        if not (isinstance(fn, ast.Attribute) and fn.attr == 'chdir' and call.args):
            continue
        depth, node = 0, call.args[0]
        while (isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute)
               and node.func.attr == 'dirname' and node.args):
            depth += 1
            node = node.args[0]
        # OFF BY ONE until 2026-09-16. The dirname wrappers are applied to `abspath(__file__)`,
        # a FILE path, so the FIRST one yields the tool's own directory and only the rest walk up.
        # Counting `depth` levels from HERE (already a directory) therefore lands one level too
        # high: `_gate.py`'s two dirnames target REPL/, and this returned the repo root.
        # It went unnoticed because the one case it was validated against -- `_tighten.py`'s stale
        # `'_gate.py'` -- is flagged either way: that literal exists at neither base. The error only
        # surfaces for a literal that IS valid at the true chdir target, which is exactly what
        # `_gate.py`'s own `tools/_*.py` subprocess arguments are. Model the file, not the dir.
        base = os.path.join(HERE, '_x.py')
        for _ in range(depth):
            base = os.path.dirname(base)
        return base
    return None


def scan_one(path):
    fails, warns = [], []
    try:
        tree = ast.parse(open(path, encoding='utf8').read(), filename=path)
    except SyntaxError as e:
        return [(os.path.basename(path), f"does not parse: {e}")], []
    cwd_base = _chdir_base(tree)
    # When the module chdirs, a BARE literal is cwd-relative -- full stop. Keeping the tool's
    # own directory as a fallback here is what let `_tighten.py`'s stale '_gate.py' pass: the
    # file does exist beside the tool, and does not exist where the tool actually looks.
    # Siblings that are meant to be siblings are built with os.path.join(dirname(__file__),..),
    # which is a Call, not a literal, so nothing legitimate depends on that fallback.
    _own = os.path.dirname(os.path.abspath(path))
    bases = (cwd_base,) if cwd_base else (ROOT, REPL, _own)
    # Two classes, both real, reported distinctly. IMPORT dies the moment anything loads the tool
    # -- that is the tools-move bug. DEFERRED dies only when the owning function runs, which is
    # how `_tighten.py` kept a stale '_gate.py' (it chdirs to REPL/, so the literal resolved to
    # REPL/_gate.py) through the same move. Scanning only module level found 10 of the 11.
    # Covering both costs nothing: the deferred scan reports ZERO on a clean tree.
    _ml = {id(c) for c in _module_level_calls(tree)}
    _all = [c for c in ast.walk(tree) if isinstance(c, ast.Call)]
    for call in _all:
        fn = call.func
        name = fn.id if isinstance(fn, ast.Name) else (fn.attr if isinstance(fn, ast.Attribute) else None)
        if name in SUBPROC and call.args and isinstance(call.args[0], ast.List):
            # argv form: the path is a string element of the list, alongside sys.executable
            # (a Name, skipped) and flags like '--list' (not path-ish).
            cand = [e for e in call.args[0].elts
                    if isinstance(e, ast.Constant) and isinstance(e.value, str)]
        elif name in OPENERS and not _is_write(call):
            cand = call.args
        else:
            continue
        for arg in cand:
            if not (isinstance(arg, ast.Constant) and isinstance(arg.value, str)):
                continue
            lit = arg.value
            if not _is_pathish(lit):
                continue
            if os.path.isabs(lit) or lit.startswith('/tmp'):
                if not os.path.exists(lit):
                    warns.append((os.path.basename(path), call.lineno, lit,
                                  "absolute/scratch path, not present"))
                continue
            # a repo-relative literal may be meant from the repo root, from REPL/, or beside the tool
            if any(os.path.exists(os.path.join(b, lit)) for b in bases):
                continue
            where = (f"module chdirs to {os.path.relpath(cwd_base, ROOT)}/ -- resolves from "
                     f"neither there nor the tool's own directory") if cwd_base else \
                    "resolves from neither repo root, REPL/, nor the tool's own directory"
            klass = "IMPORT" if id(call) in _ml else "DEFERRED"
            fails.append((os.path.basename(path), call.lineno, lit, f"[{klass}] {where}"))
    return fails, warns


# ---------------------------------------------------------------------------------------------
# MODULE-LEVEL PATH CONSTANTS. Added 2026-09-18, after this tool reported
#     "clean -- every module-level path literal resolves"
# while `_redteam.py`'s LEDGER constant pointed at a file that had been moved that hour. The
# constant is an `os.path.join(...)` Call assigned to a name; it is only ever opened later, INSIDE
# a function, via a variable. The scan below looks at literals passed to open()/subprocess(), so it
# never saw either end of it -- and `_redteam.py --check` is gate-fatal, so the breakage would have
# surfaced as a red gate with a confusing message rather than as the path error it was.
#
# The success message was wrong in the specific way this project keeps finding: it described a
# larger population than it checked, so its "clean" read as a stronger claim than it was.
#
# This resolves the common idioms only -- dirname/abspath/join over __file__, string constants, and
# names already resolved in the same module. Anything it cannot evaluate is SKIPPED rather than
# guessed, and the count of skipped names is reported so the coverage gap is visible.
# ---------------------------------------------------------------------------------------------
def _const_eval(node, names, selfpath):
    """Best-effort static evaluation of a path expression. Returns str or None."""
    if isinstance(node, ast.Constant) and isinstance(node.value, str):
        return node.value
    if isinstance(node, ast.Name):
        return names.get(node.id)
    if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute):
        parts = []
        f = node.func
        while isinstance(f, ast.Attribute):
            parts.append(f.attr); f = f.value
        if not isinstance(f, ast.Name):
            return None
        parts.append(f.id)
        fname = ".".join(reversed(parts))
        args = [_const_eval(a, names, selfpath) for a in node.args]
        if fname in ("os.path.join",) and args and all(a is not None for a in args):
            return os.path.join(*args)
        if fname in ("os.path.dirname",) and len(args) == 1 and args[0] is not None:
            return os.path.dirname(args[0])
        if fname in ("os.path.abspath", "os.path.realpath", "os.path.normpath") \
                and len(args) == 1 and args[0] is not None:
            return getattr(os.path, fname.split(".")[-1])(args[0])
        if fname == "os.path.expanduser" and len(args) == 1 and args[0] is not None:
            return os.path.expanduser(args[0])
    return None


def scan_constants(path):
    """Module-level NAME = <path expression> assignments whose target does not exist."""
    try:
        tree = ast.parse(open(path, encoding="utf-8", errors="replace").read())
    except SyntaxError:
        return [], 0
    names = {"__file__": path}
    bad, skipped = [], 0
    for node in tree.body:
        if not isinstance(node, ast.Assign) or len(node.targets) != 1:
            continue
        tgt = node.targets[0]
        if not isinstance(tgt, ast.Name):
            continue
        val = _const_eval(node.value, names, path)
        if val is None:
            # only count it as a gap if it LOOKED like a path expression
            if isinstance(node.value, ast.Call):
                src = ast.dump(node.value)
                if "os" in src and "path" in src:
                    skipped += 1
            continue
        names[tgt.id] = val
        # Only CONSTRUCTED paths. A bare string constant ending in an extension is usually a
        # basename used for matching, not a file to open -- `_modref.py`'s
        # `LEGACY = "00_DPMF.pact"` is compared with `in`, never opened, and the first version of
        # this check flagged it. Requiring both a Call on the right-hand side and a separator in
        # the result keeps the check to things that are genuinely addressing a location on disk.
        if not isinstance(node.value, ast.Call) or os.sep not in val:
            continue
        if not val.endswith(PATHISH_EXT):
            continue
        if not os.path.exists(val):
            bad.append((os.path.basename(path), node.lineno, tgt.id,
                        os.path.relpath(val, ROOT) if val.startswith(ROOT) else val))
    return bad, skipped


def _orphan_tool_dirs():
    """Directories holding .py files that TOOL_DIRS does not cover.

    The 2026-09-17 miss was not "we forgot scripts/" -- it was that a hardcoded list cannot report
    its own incompleteness, so the checker said `clean` about a directory it had never opened. That
    is the same shape as the `skipped` counter that hid 18 unpriced entrypoints, and as the owner-gate
    denominator that excluded a third of the tree. The remedy for an enumeration that can go stale is
    a DISCOVERY pass that makes staleness loud. Skips vendored/virtual trees and the sandboxes, which
    hold third-party sources rather than repo tooling.
    """
    skip = {'.git', 'node_modules', '__pycache__', '.venv', 'venv', 'archive',
            '00_KadenaSandbox', '00_StoaSandbox', '.bee', '.wasp'}
    known = {os.path.realpath(d) for d in TOOL_DIRS}
    found = {}
    for dp, dns, fns in os.walk(ROOT):
        dns[:] = [d for d in dns if d not in skip and not d.startswith('.')]
        if os.path.realpath(dp) in known:
            continue
        pys = [f for f in fns if f.endswith('.py')]
        if pys:
            found[os.path.relpath(dp, ROOT)] = sorted(pys)
    return found


def check(quiet=False):
    allf, allw, allc = [], [], []
    skipped = 0
    tools = sorted(t for d in TOOL_DIRS for t in _glob.glob(os.path.join(d, '*.py')))
    for t in tools:
        f, w = scan_one(t)
        allf += f; allw += w
        c, sk = scan_constants(t)
        allc += c; skipped += sk
    if not quiet:
        print(f"tool path integrity: {len(tools)} tools scanned (statically -- nothing executed)")
        for tool, ln, lit, why in allw:
            print(f"  warn  {tool}:{ln}  {lit!r} -- {why}")
    if allf:
        print(f"\n{len(allf)} DEAD PATH(S) -- [IMPORT] dies when the tool is loaded at all,"
              f" [DEFERRED] when the owning function runs:")
        for item in allf:
            if len(item) == 2:
                print(f"  {item[0]}: {item[1]}")
            else:
                tool, ln, lit, why = item
                print(f"  {tool}:{ln}  {lit!r}\n        {why}")
        print("\nA tool that dies on import produces no output, so output-diffing cannot see it.")
    elif not quiet:
        print("  clean -- every module-level path literal resolves")
    if allc:
        print(f"\n{len(allc)} MODULE-LEVEL PATH CONSTANT(S) POINT AT NOTHING:")
        for tool, ln, name, val in allc:
            print(f"  {tool}:{ln}  {name} -> {val}")
        print("\nThese are assigned at import and opened later inside a function, so neither the\n"
              "literal scan above nor an output diff can see them. A moved file leaves the tool\n"
              "importable and failing at use.")
    elif not quiet:
        print(f"  clean -- every module-level path CONSTANT resolves "
              f"({skipped} path expression(s) too dynamic to evaluate, not checked)")
    orph = _orphan_tool_dirs()
    if orph and not quiet:
        print(f"\n  NOTE: {len(orph)} directory(ies) hold .py files outside TOOL_DIRS and are NOT")
        print("  path-checked. If any of these rewrite source, they are exactly the class this")
        print("  checker exists for -- add them to TOOL_DIRS or confirm they are not tooling:")
        for d, fs in sorted(orph.items()):
            print(f"     {d}/  ({', '.join(fs[:4])}{' ...' if len(fs) > 4 else ''})")
    return len(allf) + len(allc)


def selftest():
    """Reintroduce the exact bug the tools move caused, in a scratch file, and catch it."""
    scratch = os.path.join(HERE, '_selftest_toolpaths_tmp.py')
    ok = True
    try:
        if check(quiet=True) != 0:
            print("SELFTEST FAIL: clean tree already reports dead paths"); ok = False
        else:
            print("  selftest 1/2: clean tree passes                        OK")
        open(scratch, 'w').write(
            "import importlib.util\n"
            "spec = importlib.util.spec_from_file_location('lf', 'REPL/_letfix.py')\n")
        n = check(quiet=True)
        if n == 0:
            print("SELFTEST FAIL: the reintroduced stale sibling path was NOT caught"); ok = False
        else:
            print("  selftest 2/2: reintroduced 'REPL/_letfix.py' is caught  OK")
    finally:
        if os.path.exists(scratch):
            os.remove(scratch)
    return 0 if ok else 1


if __name__ == '__main__':
    if '--selftest' in sys.argv:
        sys.exit(selftest())
    sys.exit(1 if check() else 0)

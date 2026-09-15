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
TOOL_DIRS = [HERE,
             os.path.join(ROOT, 'tools'),
             os.path.join(ROOT, 'OuronetInformational', 'tools')]

PATHISH_EXT = ('.py', '.repl', '.pact', '.md', '.json', '.txt', '.csv')
OPENERS = {'open', 'spec_from_file_location', 'Path', 'read_text'}


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
        base = HERE
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
        if name not in OPENERS or _is_write(call):
            continue
        for arg in call.args:
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


def check(quiet=False):
    allf, allw = [], []
    tools = sorted(t for d in TOOL_DIRS for t in _glob.glob(os.path.join(d, '*.py')))
    for t in tools:
        f, w = scan_one(t)
        allf += f; allw += w
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
    return len(allf)


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

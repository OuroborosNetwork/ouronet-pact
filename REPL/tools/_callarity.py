#!/usr/bin/env python3
"""Check CALL-SITE ARITY across the whole tree, statically.

WHY THIS EXISTS, and why a green gate does not replace it.

**Pact does not check modref call arity when a module LOADS.** It checks at RUNTIME. Measured
2026-09-21: `05_DPTF.pact` had its entrypoints re-signed and every sovereign module compiled
clean while 69 nested `ref-DPTF::C_*` call sites were passing the old argument count. Nothing
complained until a test happened to execute one.

That is the exact hole this sweep can fall into. Each module's turn changes signatures, and the
forward refactor has to reach EVERY caller -- but a caller no test exercises is invisible to the
25,621-assertion gate. `git grep` is not a substitute either: the call forms are multi-line, and
a line-oriented match silently skips them (the same failure `_executormigrate.py` records).

So: parse the signatures, parse the call sites, compare the counts. Offline, exhaustive, and it
does not care whether a test covers the line.

USAGE
    python3 REPL/tools/_callarity.py                 check every module's entrypoints
    python3 REPL/tools/_callarity.py --module DALOS  check one module's functions only
    python3 REPL/tools/_callarity.py --fn C_Mint     check one function everywhere

WHAT IT CANNOT SEE, stated so the green is honest:
  * UNQUALIFIED intra-module calls -- `(C_Mint ouro treasury amt false)` inside DPTF itself.
    The pattern below matches `ref-X::fn` and `MOD.fn`; a bare `(fn ...)` is indistinguishable
    from a local binding without resolving scope. This is not hypothetical: 05_DPTF's two
    treasury wipes self-call C_Mint, they kept the old arity through the whole sweep, and this
    tool reported CLEAN while the suite failed with "argument is decimal, but expected type
    string". The compiler does not catch it either (modref arity is a RUNTIME check), so the
    only detector is running the suite. Sovereign modules are supposed to have ZERO self-C-calls
    (CLAUDE.md), which is what would make this blind spot harmless -- these two are a known
    deviation, recorded in the sweep handoff.
  * partial application -- `(map (ref-X::fn) xs)` is a legitimate 0-arg call site, reported
    separately rather than as a mismatch;
  * a function name that exists on MORE THAN ONE module (`XE_Issue` is on BRD and SWP). Those
    are ambiguous without resolving the modref binding, so they are counted and listed as
    UNCHECKED rather than guessed at. Guessing is what put a `patron` on BRD's XE_Issue.
"""
import os, re, sys, glob, collections

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "REPL", "tools"))
from _executormigrate import split_form, in_string

DEFUN_RE = re.compile(r'\n    \(def(?:un|pact) ([A-Za-z0-9|_\-]+)(?::[A-Za-z0-9{}\.\[\]|_\-]+)?\s*\(')
MODULE_RE = re.compile(r'^\(module\s+([^\s()]+)', re.M)


def _params(src, open_paren):
    """Top-level parameter count of the param list whose '(' is at open_paren."""
    args, _ = split_form(src, open_paren)
    # split_form treats the '(' as a form; its "arguments" are the params, minus the head.
    # Params have no head, so re-split without dropping one.
    return len(args)


def signatures():
    """{module: {fn: arity}} from the MODULE body (not the interface declaration)."""
    sigs = collections.defaultdict(dict)
    owners = collections.defaultdict(set)      # fn -> {modules that define it}
    for top in ("1_SOVEREIGN", "2_CITIZEN"):
        for d, _, fs in os.walk(os.path.join(ROOT, top)):
            if os.sep + "Audit" in d + os.sep:
                continue
            for f in sorted(fs):
                if not f.endswith(".pact"):
                    continue
                src = open(os.path.join(d, f), encoding="utf8", errors="replace").read()
                mm = list(MODULE_RE.finditer(src))
                if not mm:
                    continue
                for i, m in enumerate(mm):
                    mod = m.group(1)
                    end = mm[i + 1].start() if i + 1 < len(mm) else len(src)
                    body = src[m.start():end]
                    for dm in DEFUN_RE.finditer(body):
                        fn = dm.group(1)
                        sigs[mod][fn] = _params(body, dm.end() - 1)
                        owners[fn].add(mod)
    return sigs, owners


# `ouronet-ns.DPTF.C_Mint` is a NAMESPACE-qualified call and the old pattern missed it: the
# `MOD.` alternative consumed `ouronet-ns.` and captured `DPTF` as the function name. The
# hostile-citizen red team calls that way -- from a module in the open `user` namespace, which
# is the whole point of the test -- so its stale C_Mint arity went unreported while the suite
# failed with a typecheck error instead of the guard refusal it asserts.
CALL_PAT = re.compile(r'\(\s*(?:ref-[A-Za-z0-9|_\-]+::|(?:[A-Za-z0-9|_\-]+\.)+)([A-Za-z0-9|_\-]+)[\s\)]')


ALIAS_RE = re.compile(r'\(\s*(ref-[A-Za-z0-9|_\-]+)\s*:module\{[^}]*\}\s+([A-Za-z0-9|_\-\.]+)\s*\)')


def alias_map(src):
    """{alias -> module} from this file's own `(ref-X:module{Iface} MODULE)` bindings.

    THE ALIAS IS NOT ALWAYS THE MODULE NAME. `(ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)`
    binds `SCR` to `AQP-SCORE`; `ref-FVT` to `AQP-FVT`. Assuming alias == module resolved most
    calls and quietly parked the abbreviated ones in UNCHECKED -- including call sites of
    functions a sweep had just re-signed. Reading the binding is exact where the convention is
    a guess, and it is what the compiler itself does.
    """
    out = {}
    for m in ALIAS_RE.finditer(src):
        out[m.group(1)] = m.group(2).split(".")[-1]
    return out


def scan(paths, sigs, owners, want_fns):
    hits, mismatches, unchecked, partial = 0, [], collections.Counter(), 0
    for p in paths:
        src = open(p, encoding="utf8", errors="replace").read()
        amap = alias_map(src)
        for m in CALL_PAT.finditer(src):
            fn = m.group(1)
            if fn not in want_fns:
                continue
            if in_string(src, m.start(1)):
                continue
            mods = owners.get(fn, set())
            if not mods:
                continue
            # RESOLVE THROUGH THE ALIAS FIRST. `(ref-ATSU::C_Fuel ...)` names its module right
            # there in the prefix, and the binding convention in this tree is
            # `(ref-<MODULE>:module{Iface} <MODULE>)` -- the alias IS the module name. Ignoring
            # it sent every multi-module name to UNCHECKED, and `C_Fuel` lives on three modules
            # with three different arities (ATSU 4, OUROBOROS 1, SWPLC 5). A bare-name threading
            # pass gave all three's call sites a patron; only OUROBOROS's could take one, and
            # this tool reported clean while four suites broke on
            # "Attempted to apply a closure to too many arguments".
            alias = None
            am = re.match(r'\(\s*(ref-[A-Za-z0-9|_\-]+)::', src[m.start():m.start() + 60])
            if am:
                # the file's own binding first (exact), then alias-as-module-name (convention)
                cand = amap.get(am.group(1)) or am.group(1)[4:]
                if cand in sigs and fn in sigs[cand]:
                    alias = cand
            # A name on several modules is still checkable when EVERY definition agrees on
            # arity -- which is the case for the `P|` policy boilerplate each of the 59 modules
            # carries. That collapsed 607 "unchecked" sites to the handful that genuinely differ.
            # Only a name whose arity DIFFERS between modules needs the modref binding resolved,
            # and those are left unchecked rather than guessed: guessing which module owned
            # `XE_Issue` (BRD or SWP) is what put a stray argument on the wrong one.
            if alias:
                want = sigs[alias][fn]
            else:
                arities = {sigs[mm][fn] for mm in mods}
                if len(arities) != 1:
                    unchecked[fn] += 1
                    continue
                want = next(iter(arities))
            op = m.start()
            args, _ = split_form(src, op)
            got = len(args) - 1
            hits += 1
            if got == 0 and want > 0:
                # PARTIAL APPLICATION ONLY INSIDE A HIGHER-ORDER FORM. `(map (ref-X::fn) xs)` is
                # legitimate; a BARE `(ref-X::fn)` in statement position is a short call, and
                # Pact answers it by returning a CLOSURE rather than raising -- which an
                # `expect-failure` then swallows. Treating every 0-arg call as partial
                # application hid four real ones in DPTF-G6 and RT-C: the suite reported
                # "Expected Pact Value, got closure or table reference" while this tool said
                # clean. The enclosing form's head is the discriminator.
                outer = src.rfind("(", 0, op)
                head = ""
                if outer >= 0:
                    head = src[outer + 1:op].strip().split()[0] if src[outer + 1:op].strip() else ""
                if head in ("map", "fold", "filter", "zip", "and?", "or?", "not?", "select"):
                    partial += 1
                    continue
            if got != want:
                line = src[:op].count("\n") + 1
                mismatches.append((os.path.relpath(p, ROOT), line, fn, want, got,
                                   src[op:op + 90].split("\n")[0]))
    return hits, mismatches, unchecked, partial


def main():
    sigs, owners = signatures()
    only_mod = only_fn = None
    if "--module" in sys.argv:
        only_mod = sys.argv[sys.argv.index("--module") + 1]
    if "--fn" in sys.argv:
        only_fn = sys.argv[sys.argv.index("--fn") + 1]

    if only_fn:
        want_fns = {only_fn}
    elif only_mod:
        want_fns = set(sigs.get(only_mod, {}))
        if not want_fns:
            print(f"no module {only_mod!r}; known: {', '.join(sorted(sigs)[:12])} ...")
            return 1
    else:
        # EVERY function, not just the A_/C_ entrypoint surface. The original filter kept
        # `A_`/`C_`/`CC_` and anything carrying a `|`, which silently excluded the whole `X_`
        # band -- and a signature change propagates through `X_` exactly as readily. RPS's
        # XE_WithdrawRoyalty / XE_BurnRoyalty / XE_FuelRoyalty gained a patron, their three
        # callers in 08_DSA did not, and this tool reported CLEAN on the default scope while
        # `--fn XE_WithdrawRoyalty` found the mismatch immediately. Arity is arity; there is no
        # band for which a wrong call count is acceptable.
        want_fns = {f for m in sigs for f in sigs[m]}

    paths = (glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True)
             + glob.glob(os.path.join(ROOT, "2_CITIZEN", "**", "*.pact"), recursive=True)
             + glob.glob(os.path.join(ROOT, "REPL", "**", "*.repl"), recursive=True))
    paths = [p for p in paths if os.sep + "Audit" + os.sep not in p]

    hits, mism, unchecked, partial = scan(paths, sigs, owners, want_fns)
    scope = only_fn or only_mod or "all entrypoints"
    print(f"call-arity -- scope: {scope}")
    print(f"  {len(want_fns)} function(s), {hits} resolved call site(s) in {len(paths)} file(s)")
    if partial:
        print(f"  {partial} partial application(s) -- (map (ref-X::fn) xs), not a mismatch")
    if unchecked:
        tot = sum(unchecked.values())
        print(f"  {tot} call site(s) UNCHECKED -- name defined on >1 module:")
        for fn, n in unchecked.most_common(8):
            print(f"     {fn:34s} {n:4d}  (on {', '.join(sorted(owners[fn]))})")
    if mism:
        print(f"\n  ARITY MISMATCHES: {len(mism)}")
        for rel, line, fn, want, got, txt in mism:
            print(f"     {rel}:{line}\n         {fn}  wants {want}, got {got}   {txt.strip()}")
        return 1
    print("\n  no arity mismatches.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

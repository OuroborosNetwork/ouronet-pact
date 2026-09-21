#!/usr/bin/env python3
"""Is a module's sweep turn ACTUALLY finished? One command, PASS/FAIL per obligation.

WHY THIS EXISTS. HANDOFF 4.2 lists what processing a module means -- core, interface, Talos,
every downstream caller, every REPL test, the deploy bundle, the gate. Checking that list by
hand is how items get missed, and "I believe it is done" is not a result anyone can audit.
Worse, the individual tools each answer a NARROWER question than they appear to:

  * `_callarity` reports "no arity mismatches" -- but a call site it could not RESOLVE is not a
    mismatch, it is silence. Four call sites of functions freshly re-signed sat in its UNCHECKED
    bucket and the tool still said clean. CHECK 3 below closes exactly that: for THIS module,
    unresolved is a FAILURE, not a shrug.
  * the compiler never checks modref arity (runtime), so "it compiles" proves very little.
  * an interface declaration and its module defun are two separate texts that must agree, and
    nothing in Pact enforces that they agree on PARAMETER NAMES or ORDER -- only on arity and
    types. CHECK 2 compares them literally.

USAGE
    python3 REPL/tools/_modulecomplete.py <MODULE>        e.g. ATS, DPTF, 08_ATS.pact
"""
import os, re, sys, glob, subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "REPL", "tools"))
import _callarity as CA
from _executormigrate import split_form, in_string

# USE .search, NOT .match. `re.match` anchors the WHOLE pattern at position 0, so the
# `\|(A|AA|C|CC)_` alternative can only fire on a name that STARTS with a bar -- which no name
# does. Every `ENTITY|C_Fn` Talos entrypoint becomes invisible. This is verbatim the
# `_bandplan.py` defect recorded in HANDOFF 3: it reported 89 entrypoints against an actual 482,
# and the first day of this refactor was scoped against that number. Reproduced here on the
# first write of a NEW tool, which is why the handoff keeps it.
ENTRY = re.compile(r'^(A|AA|C|CC|Cp|CCp|Ap|AAp)_|\|(A|AA|C|CC)_')


def is_entry(name):
    return ENTRY.search(name) is not None


def module_file(mod):
    for p in glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True):
        src = open(p, encoding="utf8", errors="replace").read()
        if re.search(r'^\(module\s+' + re.escape(mod) + r'\s', src, re.M):
            return p
    return None


def sig_pairs(path, mod):
    """[(fn, interface-params, module-params)] for everything declared in BOTH halves."""
    src = open(path, encoding="utf8", errors="replace").read()
    mstart = src.index("\n(module ")
    out = []
    rx = re.compile(r'\n    \(defun ([A-Za-z0-9|_\-]+)(?::[A-Za-z0-9{}\.\[\]|_\-]+)?\s*\n?\s*\(([^)]*)\)')
    # NORMALISE THE SAME-INTERFACE SCHEMA QUALIFIER before comparing. StoicSyntax requires a
    # schema defined in THIS interface to be written UNQUALIFIED inside it -- `object{Schema}` --
    # while the module must write `object{BrandingV2.Schema}`. Those two texts are CORRECTLY
    # different, and a raw comparison called six IGNIS and seven BRD declarations "drifted".
    # A check that fires on the house style is worse than no check: it trains you to ignore it.
    ifn = re.findall(r'^\(interface\s+([A-Za-z0-9_]+)', src[:mstart], re.M)
    def norm(t):
        for n in ifn:
            t = t.replace("object{" + n + ".", "object{").replace(":[object{" + n + ".", ":[object{")
        return " ".join(t.split())
    iface = {m.group(1): norm(m.group(2)) for m in rx.finditer(src[:mstart])}
    body  = {m.group(1): norm(m.group(2)) for m in rx.finditer(src[mstart:])}
    for fn in sorted(set(iface) & set(body)):
        out.append((fn, iface[fn], body[fn]))
    return out, body


def main():
    if len(sys.argv) < 2:
        print(__doc__); return 1
    mod = sys.argv[1].replace(".pact", "")
    mod = re.sub(r'^\d+_', '', mod)
    path = module_file(mod)
    if not path:
        print(f"no module named {mod!r} found"); return 1
    rel = os.path.relpath(path, ROOT)
    print(f"module completion -- {mod}  ({rel})\n")
    fails = []

    # 1] every entrypoint classified DONE by the plan
    r = subprocess.run([sys.executable, os.path.join(ROOT, "REPL/tools/_executorplan.py"),
                        "--module", os.path.basename(path)], capture_output=True, text=True, cwd=ROOT)
    undone = [l for l in r.stdout.splitlines() if l.strip() and not l.strip().startswith("DONE")]
    undone = [l for l in undone if re.match(r'\s+(PATRON|ADD|RENAME)\b', l)]
    print(f"  [{'PASS' if not undone else 'FAIL'}] 1. every entrypoint DONE in _executorplan  "
          f"({len(undone)} outstanding)")
    for l in undone[:8]:
        print("        " + l.strip())
    if undone: fails.append("entrypoints not converted")

    # 2] interface declaration and module defun agree, TEXT for text
    pairs, body = sig_pairs(path, mod)
    drift = [(f, i, b) for f, i, b in pairs if i != b]
    print(f"  [{'PASS' if not drift else 'FAIL'}] 2. interface declarations match their module "
          f"defuns  ({len(pairs)} compared, {len(drift)} drifted)")
    for f, i, b in drift[:8]:
        print(f"        {f}\n          iface : ({i})\n          module: ({b})")
    if drift: fails.append("interface/module signature drift")

    # 3] EVERY call site of THIS module's entrypoints is resolved AND correct
    sigs, owners = CA.signatures()
    if mod not in sigs:
        print(f"  [FAIL] 3. module {mod} not in the signature table"); return 1
    # THIS MODULE'S ENTRYPOINTS *AND* ITS TALOS WRAPPERS. The wrappers are defined on the Talos
    # module but they are this module's public face -- every REPL test reaches the core through
    # `TS01-C2.ATS|C_Foo`, never `ref-ATS::C_Foo`. Scoping check 3 to the core alone verified 22
    # call sites for ATS and left ~140 REPL sites unexamined, which is precisely the kind of
    # "PASS" that means nothing.
    ents = {f for f in sigs[mod] if is_entry(f)}
    wrappers = {f for m in sigs for f in sigs[m] if f.startswith(mod + "|") and is_entry(f)}
    ents |= wrappers
    paths = (glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True)
             + glob.glob(os.path.join(ROOT, "2_CITIZEN", "**", "*.pact"), recursive=True)
             + glob.glob(os.path.join(ROOT, "REPL", "**", "*.repl"), recursive=True))
    unresolved, wrong, seen, foreign = [], [], 0, 0
    for p in paths:
        src = open(p, encoding="utf8", errors="replace").read()
        amap = CA.alias_map(src)
        for m in CA.CALL_PAT.finditer(src):
            fn = m.group(1)
            if fn not in ents or in_string(src, m.start(1)):
                continue
            am = re.match(r'\(\s*(ref-[A-Za-z0-9|_\-]+)::', src[m.start():m.start() + 60])
            owner = None
            # A DOTTED call names its module too: `(DPTF.C_ToggleBurnRole ...)`, and in a REPL
            # also `(ouronet-ns.DPTF.C_Mint ...)`. Resolving only `ref-X::` left these unchecked,
            # which hid a stale 3-arg call to a 5-arg DPTF entrypoint sitting inside an
            # `expect-failure` -- green, for the wrong reason.
            dm = re.match(r'\(\s*(?:[A-Za-z0-9\-]+\.)?([A-Za-z0-9|_\-]+)\.', src[m.start():m.start() + 60])
            if dm and dm.group(1) in sigs and fn in sigs[dm.group(1)]:
                owner = dm.group(1)
            if owner is None and am:
                cand = amap.get(am.group(1)) or am.group(1)[4:]
                owner = cand if cand in sigs and fn in sigs[cand] else None
            elif len(owners.get(fn, ())) == 1:
                owner = next(iter(owners[fn]))
            if owner is None and fn in owners:
                # Defined on several modules but ALL AGREEING on arity -- the `P|` policy
                # boilerplate every module carries. Resolvable exactly, so resolve it rather
                # than reporting a false gap. (`P|` is also canon-exempt, but agreement is the
                # stronger reason: the check stays honest instead of being silenced.)
                ar = {sigs[mm][fn] for mm in owners[fn]}
                if len(ar) == 1:
                    owner = next(iter(owners[fn]))
            line = src[:m.start()].count("\n") + 1
            rp = os.path.relpath(p, ROOT)
            if owner is None and dm and dm.group(1) not in sigs:
                # a DOTTED call whose prefix names a module OUTSIDE this tree --
                # `(coin.C_BulkTransfer ...)` is the Stoa sandbox's coin, not DPOF's entrypoint
                # of the same name. We do not analyse foreign modules, so counting these as
                # "unresolved" would be a standing false alarm. Counted, not hidden.
                foreign += 1; continue
            if owner is None:
                unresolved.append(f"{rp}:{line}  {fn}"); continue
            if fn not in sigs.get(owner, {}):
                continue
            want = sigs[owner][fn]
            seen += 1
            args, _ = split_form(src, m.start())
            got = len(args) - 1
            if got != want and not (got == 0 and want > 0):
                wrong.append(f"{rp}:{line}  {fn} wants {want}, got {got}")
    ok3 = not unresolved and not wrong
    print(f"  [{'PASS' if ok3 else 'FAIL'}] 3. all call sites resolved AND correct  "
          f"({seen} verified, {len(unresolved)} unresolved, {len(wrong)} wrong, "
          f"{foreign} foreign-module)")
    for x in (unresolved + wrong)[:8]:
        print("        " + x)
    if not ok3: fails.append("call sites unresolved or wrong")

    # 4] conformance, 5] auth surface, 6] deploy freshness -- whole-tree, but a module's turn
    #    cannot be called done while any of them is red
    for n, (label, cmd) in enumerate([
            ("conformance clean", ["REPL/tools/_conformance.py", "--check"]),
            ("auth surface -- nothing weakened", ["REPL/tools/_authsurface.py", "--check"]),
            ("Deploy/ regenerated from source", ["REPL/tools/_deploybundle.py", "--check"])], start=4):
        rr = subprocess.run([sys.executable] + [os.path.join(ROOT, cmd[0])] + cmd[1:],
                            capture_output=True, text=True, cwd=ROOT)
        ok = rr.returncode == 0
        print(f"  [{'PASS' if ok else 'FAIL'}] {n}. {label}")
        if not ok:
            fails.append(label)
            for l in (rr.stdout + rr.stderr).splitlines()[-4:]:
                print("        " + l)

    print()
    if fails:
        print(f"  MODULE NOT COMPLETE -- {len(fails)} obligation(s) unmet: {', '.join(fails)}")
        print("  (the full gate is still required after these pass)")
        return 1
    print("  all static obligations met. RUN THE FULL GATE before ticking the worklist.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

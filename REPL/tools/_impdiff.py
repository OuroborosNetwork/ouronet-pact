#!/usr/bin/env python3
"""_impdiff.py -- what the IMC policy tables SHOULD hold, vs what a live chain DOES hold.

WHY THIS EXISTS, and it is not a convenience.

`P|A_AddIMP` ends in `UC_AppL` = `(+ in [item])`. It is a BLIND APPEND with no dedupe -- measured
2026-09-20: re-running ONE module's `P|A_Define` took IGNIS' IMP from 16 entries to 17. And
`P|UEV_IMC` -> `U|G::UEV_Any` maps `UC_Try` over the WHOLE list, so a duplicate is not inert: it
costs gas on EVERY IMC-gated call on the chain, forever, and nothing anywhere reports it.

That makes "just re-run `P|A_Define` after an upgrade" a permanent, compounding gas regression
dressed up as an idempotent setup step. On a live chain the only safe operation is the DELTA:
work out which (target, registrar) pairs the source now expects, subtract the ones already on
chain, and add exactly the difference.

Two measured facts make the delta expressible as a plain transaction:

  * `(= guard-a guard-b)` on two CapabilityGuards works, so the diff is decidable.
  * `(create-capability-guard (OTHER-MODULE.P|X|CALLER))` succeeds from OUTSIDE that module, so a
    targeted `TARGET.P|A_AddIMP` call can be written without going through `P|A_Define` at all.

USAGE
  python3 REPL/tools/_impdiff.py                 intended composition, grouped by target
  python3 REPL/tools/_impdiff.py --live SNAP     diff against a snapshot; report what is MISSING
                                                 (and what is EXTRA or DUPLICATED on chain)
  python3 REPL/tools/_impdiff.py --live SNAP --emit    the delta, as Pact forms to sign and send
  python3 REPL/tools/_impdiff.py --repl OUT.repl       write a probe that DUMPS a snapshot, in the
                                                 exact format --live reads back

SNAPSHOT FORMAT -- one registration per line, `#` comments and blanks ignored:

    IGNIS   ouronet-ns.DPTF.P|DPTF|CALLER
    IGNIS   ouronet-ns.MTX-SWP.P|MTX-SWP|CALLER

which is what `(MODULE.P|UR_IMP)` prints, one CapabilityGuard name per entry. A snapshot taken
from mainnet is the ONLY authority on what is live; this tool never guesses at it.
"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TOPS = ("1_SOVEREIGN", "2_CITIZEN")
NS = "ouronet-ns"

# The default guard every IMP list is seeded with by `with-default-read` in P|A_AddIMP itself.
SEED = "SECURE"


def _pact_files():
    for top in TOPS:
        for d, _, fs in os.walk(os.path.join(ROOT, top)):
            if os.sep + "Audit" in d + os.sep:
                continue
            for f in sorted(fs):
                if f.endswith(".pact"):
                    yield os.path.join(d, f)


def _module_name(text):
    m = re.search(r'^\(module\s+([^\s()]+)', text, re.M)
    return m.group(1) if m else None


def _define_block(text):
    """The body of `(defun P|A_Define () ... )`, paren-balanced rather than indentation-guessed."""
    i = text.find("(defun P|A_Define ")
    if i < 0:
        return None
    d, j, instr = 0, i, False
    while j < len(text):
        c = text[j]
        if instr:
            if c == '\\':
                j += 2
                continue
            if c == '"':
                instr = False
        elif c == '"':
            instr = True
        elif c == ';' and text[j:j + 2] == ';;':
            j = text.find('\n', j)
            if j < 0:
                break
            continue
        elif c in '([':
            d += 1
        elif c in ')]':
            d -= 1
            if d == 0:
                return text[i:j + 1]
        j += 1
    return None


def strip_comments(text):
    """Blank out `;`-comments, honouring strings. NOT optional, and not cosmetic.

    Pact comments start at a SINGLE `;`, and the tree uses that form to PARK registrations --
    `12_LIQUID.pact` carries `;(ref-P|DPOF::P|A_AddIMP mg)` next to its live siblings. The first
    version of this tool only skipped `;;`, so it read six parked DPOF registrations as real and
    reported them MISSING from a chain that was never supposed to have them. A diff tool that
    invents work is worse than no diff tool.
    """
    out, i, instr = [], 0, False
    while i < len(text):
        c = text[i]
        if instr:
            if c == '\\':
                out.append(text[i:i + 2]); i += 2; continue
            if c == '"':
                instr = False
        elif c == '"':
            instr = True
        elif c == ';':
            j = text.find('\n', i)
            if j < 0:
                break
            out.append('\n'); i = j + 1; continue
        out.append(c); i += 1
    return ''.join(out)


def intended():
    """(target_module, registrar_module, cap) for every IMP registration in the tree."""
    out = []
    for path in _pact_files():
        text = open(path, encoding="utf8", errors="replace").read()
        mod = _module_name(text)
        blk = _define_block(text)
        if not mod or not blk:
            continue
        blk = strip_comments(blk)
        # alias -> the concrete module it is bound to, e.g. (ref-P|IGNIS:module{...} IGNIS)
        alias = dict(re.findall(r'\((ref-[^\s:]+):module\{[^}]+\}\s+([^\s()]+)\)', blk))
        # guard-variable -> capability, e.g. (mg:guard (create-capability-guard (P|DPTF|CALLER)))
        gvar = dict((v, c) for v, c in re.findall(
            r'\(([A-Za-z][\w-]*):guard\s+\(create-capability-guard\s+\(([^\s()]+)', blk))
        for ref, g in re.findall(r'\((ref-[^\s:]+)::P\|A_AddIMP\s+([^\s()]+)\)', blk):
            tgt = alias.get(ref)
            cap = gvar.get(g)
            if tgt and cap:
                out.append((tgt, mod, cap))
            else:                       # never silently drop a registration we could not resolve
                out.append((tgt or f"?{ref}", mod, cap or f"?{g}"))
    return sorted(set(out))


def _guard_name(registrar, cap):
    return f"{NS}.{registrar}.{cap}"


def read_snapshot(path):
    """-> {target: [guard-name, ...]} preserving multiplicity, so duplicates stay visible."""
    live = {}
    for raw in open(path, encoding="utf8"):
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        # Accept both the bare name and the full struct a chain read prints verbatim --
        # `CapabilityGuard {name: ouronet-ns.X.CAP,args: [],pactId: }`. Requiring the bare form
        # would mean hand-editing the snapshot, and a hand-edited snapshot is not evidence.
        tgt, rest = line.split(None, 1)
        m = re.search(r'name:\s*([^\s,}]+)', rest)
        name = m.group(1) if m else rest.strip()
        if not name or " " in name:
            sys.exit(f"{path}: cannot parse {raw.strip()!r} -- expected `TARGET  guard-name` "
                     f"or `TARGET  CapabilityGuard {{name: ...}}`")
        live.setdefault(tgt, []).append(name)
    return live


def write_probe(out):
    rows = intended()
    targets = sorted({t for t, _, _ in rows})
    L = [";;GENERATED by REPL/tools/_impdiff.py --repl -- do not edit by hand.",
         ";;Dumps every IMC policy table in the snapshot format `_impdiff.py --live` reads back.",
         ";;Run it against a chain state (or the REPL genesis) and keep the output as the baseline.",
         ";;",
         '(begin-tx "IMP SNAPSHOT")',
         '(namespace "ouronet-ns")']
    for t in targets:
        L.append(f'(map (lambda (g) (print (format "{t}\\t{{}}" [g]))) ({t}.P|UR_IMP))')
    L += ["(commit-tx)", ""]
    open(out, "w").write("\n".join(L))
    print(f"wrote {out} -- dumps {len(targets)} policy table(s)")


def main():
    rows = intended()
    if "--repl" in sys.argv:
        return write_probe(sys.argv[sys.argv.index("--repl") + 1])

    if "--live" not in sys.argv:
        by = {}
        for t, r, c in rows:
            by.setdefault(t, []).append((r, c))
        print(f"INTENDED IMC COMPOSITION -- {len(rows)} registration(s) across "
              f"{len(by)} policy table(s)\n")
        for t in sorted(by):
            print(f"  {t}  ({len(by[t])})")
            for r, c in sorted(by[t]):
                print(f"      {_guard_name(r, c)}")
        print("\nNo live snapshot given, so nothing is claimed about what is ON CHAIN.")
        print("Take one with:  python3 REPL/tools/_impdiff.py --repl REPL/_imp_snapshot.repl")
        return 0

    live = read_snapshot(sys.argv[sys.argv.index("--live") + 1])
    missing, extra, dupes = [], [], []
    want = {}
    for t, r, c in rows:
        want.setdefault(t, set()).add(_guard_name(r, c))
    for t, names in sorted(want.items()):
        have = live.get(t, [])
        seen = set()
        for n in have:
            if n in seen:
                dupes.append((t, n))
            seen.add(n)
        for n in sorted(names - seen):
            missing.append((t, n))
        for n in sorted(seen - names):
            # The `with-default-read` seed inside P|A_AddIMP is the TARGET's OWN SECURE, and it
            # is not a registration. Other modules' SECURE guards ARE registrations (AQP-VCT and
            # RPS register theirs), so the exclusion has to be target-specific or it hides them.
            if n != f"{NS}.{t}.{SEED}":
                extra.append((t, n))

    if "--emit" in sys.argv:
        if not missing:
            print(";;IMP delta is EMPTY -- the live snapshot already carries every registration\n"
                  ";;the current source expects. Nothing to send.")
            return 0
        print(";;IMP DELTA -- generated by REPL/tools/_impdiff.py --emit.")
        print(";;ONLY the registrations the source expects and the snapshot does not have.")
        print(";;Each needs the TARGET module's admin signature (P|A_AddIMP composes GOV|*_ADMIN).")
        print('(namespace "ouronet-ns")')
        for t, n in missing:
            cap = n.split(".", 1)[1]            # drop the namespace, keep MODULE.CAP
            print(f"({t}.P|A_AddIMP (create-capability-guard ({cap})))")
        return 0

    print(f"IMP DIFF -- source expects {len(rows)}, snapshot holds "
          f"{sum(len(v) for v in live.values())}\n")
    for label, rowset in (("MISSING (add these)", missing),
                          ("EXTRA on chain (source no longer registers)", extra),
                          ("DUPLICATED on chain (costs gas on every IMC call)", dupes)):
        print(f"  {label}: {len(rowset)}")
        for t, n in rowset:
            print(f"      {t}  <-  {n}")
    return 1 if (missing or dupes) else 0


if __name__ == "__main__":
    sys.exit(main())

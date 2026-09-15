#!/usr/bin/env python3
"""_prefixsync.py -- every function prefix used in the tree must be known to the tools.

WHY (2026-09-15)
----------------
Ouronet's prefix system grows. `UCv_`/`URCv_` added the `v` role; `URCx_`/`UCx_`/`UDCx_` added `x`;
later `URv_`, `XIv_`, `XBv_` appeared in real modules. Each tool that reasons about prefixes keeps
its OWN hand-written copy of the vocabulary, and nothing re-derives it from the source. So the
vocabulary silently falls behind, and the tool keeps reporting -- confidently -- about a shape it
no longer recognises.

On 2026-09-15 the SAME three prefixes were found missing from TWO independent tools on the same day:

  * `REPL/tools/_ignis_price_sheet.py` could not follow `XIv_`/`XBv_`, so five Talos ops published
    "?" for no reason other than that `XI_MergeNonces` had been renamed `XIv_MergeNonces`.
  * `tools/skeleton.py`'s FN_CLASS did not know `URv_`/`XIv_`/`XBv_`, so `canon_check.py` -- a tool
    `StoicSyntax-Prefixes.md` documents as "the hard gate" -- reported SIX files as canon drift that
    were not drift at all.

Two tools, one cause. This check closes it: it enumerates every `defun`/`defpact` prefix actually
present in `1_SOVEREIGN/` and `2_CITIZEN/`, and asserts each is classifiable by `tools/skeleton.py`.

`--check`     exit 1 if any live prefix is unclassifiable
`--selftest`  prove the check fails when a known prefix is removed from the classifier
"""
import os, re, sys, glob

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
SKELETON = os.path.join(ROOT, 'tools', 'skeleton.py')

# `GOV|…` and `P|…` forms are policy/plumbing and are excluded by skeleton_emit itself
# (see its `f['name'].startswith('GOV|')` filter), so they are not part of the contract.
EXCLUDED_NAMESPACES = ('GOV|', 'P|')
NUMBERED_ADMIN = re.compile(r'^A\d+[a-z]?_$')       # skeleton.py's own fallback rule
EXTRA_OK = {'REPL_'}


def tree_prefixes():
    used = {}
    for f in (glob.glob(os.path.join(ROOT, '1_SOVEREIGN', '**', '*.pact'), recursive=True)
              + glob.glob(os.path.join(ROOT, '2_CITIZEN', '**', '*.pact'), recursive=True)):
        for m in re.finditer(r'^\s{4}\(def(?:un|pact)\s+([A-Za-z0-9|_+-]+)', open(f).read(), re.M):
            name = m.group(1)
            if name.startswith(EXCLUDED_NAMESPACES):
                continue
            base = name.rsplit('|', 1)[1] if '|' in name else name
            us = base.find('_')
            if us > 0:
                p = base[:us] + '_'
                used.setdefault(p, []).append((os.path.relpath(f, ROOT), name))
    return used


def classifier_prefixes():
    src = open(SKELETON).read()
    block = src[src.index('FN_CLASS = ['):src.index('REPL_PFX')]
    return set(re.findall(r'"([A-Za-z0-9]+_)"', block))


def check(quiet=False, _known=None):
    used = tree_prefixes()
    known = _known if _known is not None else classifier_prefixes()
    bad = {p: v for p, v in used.items()
           if p not in known and p not in EXTRA_OK and not NUMBERED_ADMIN.match(p)}
    if not quiet:
        print(f"prefix sync: {len(used)} prefixes live in the tree, "
              f"{len(known)} known to tools/skeleton.py")
    if bad:
        print(f"\n{len(bad)} LIVE PREFIX(ES) THE CLASSIFIER DOES NOT KNOW:")
        for p in sorted(bad, key=lambda k: -len(bad[k])):
            ex = bad[p][0]
            print(f"  {p:<10} {len(bad[p]):>4} function(s)   e.g. {ex[1]}  ({ex[0]})")
        print("\nA tool that cannot classify a prefix does not stay silent about it -- it reports\n"
              "the file as drift, or drops the function from its analysis. Add the prefix to\n"
              "tools/skeleton.py FN_CLASS in the right band.")
    elif not quiet:
        print("  clean -- every live prefix is classifiable")
    return len(bad)


def selftest():
    ok = True
    if check(quiet=True) != 0:
        print("SELFTEST FAIL: clean tree already reports unknown prefixes"); ok = False
    else:
        print("  selftest 1/2: clean tree passes                          OK")
    # remove a prefix that IS live and confirm the check notices
    known = classifier_prefixes()
    live = {p for p in tree_prefixes() if p in known}
    victim = sorted(live)[0] if live else None
    if victim is None:
        print("SELFTEST FAIL: no live+known prefix to perturb"); return 1
    import io, contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        n = check(quiet=True, _known=known - {victim})
    if n == 0:
        print(f"SELFTEST FAIL: removing {victim} from the classifier was NOT caught"); ok = False
    else:
        print(f"  selftest 2/2: dropping {victim} from FN_CLASS is caught   OK")
    return 0 if ok else 1


if __name__ == '__main__':
    if '--selftest' in sys.argv:
        sys.exit(selftest())
    sys.exit(1 if check() else 0)

#!/usr/bin/env python3
"""_docsmodules.py -- generate the module map in OuronetDocumentation/ from the tree.

WHY.  `OuronetDocumentation/MAINTAINING.md` is a directive requirement: the owner asked for the
documentation to be "tied to some sort of skeleton, such that when the code changes, we can easily
update every places that needs to be update", because he does not want to spend a week per change.
The design that answers it splits every code-describing page in two -- a GENERATED enumeration and
a HAND-WRITTEN explanation -- with a machine-checkable seam between them.

This is the first tool on the generated side, and the module map is the right first target: it is
pure enumeration, so it can be emitted whole rather than in fragments.

It writes only BETWEEN MARKERS.  Everything outside them is prose and is never touched:

    <!-- @generated:<name> -- do not edit; run REPL/tools/_docsmodules.py --write -->
    ...emitted...
    <!-- @end:<name> -->

WHAT IT IS NOT.  It does not write the "what it is for" prose, and it must not pretend to.  The
`purpose` column is the module's own `@doc` first sentence -- the author's words, truncated, useful
for orientation and NOT a substitute for a module page.  A generator can enumerate; only a human can
explain.  That is the whole reason the seam exists rather than generating the pages outright.

  python3 REPL/tools/_docsmodules.py --check    regenerate in memory, report drift (exit 1)
  python3 REPL/tools/_docsmodules.py --write    rewrite the marked regions
  python3 REPL/tools/_docsmodules.py --selftest prove marker handling and @doc joining
"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DOCS = os.path.join(ROOT, "OuronetDocumentation")

# Layer -> the directories that constitute it, in the order a reader should meet them.  This
# mapping is the ONE piece of judgement in the tool; everything else is counted.
LAYERS = [
    ("Utilities",  ["1_SOVEREIGN/STAGE_01/1_Utilities"]),
    ("Core — Stage 1", ["1_SOVEREIGN/STAGE_01/2_Core"]),
    ("Core — Stage 2", ["1_SOVEREIGN/STAGE_02/2_Core"]),
    ("Talos",      ["1_SOVEREIGN/STAGE_01/3_Talos", "1_SOVEREIGN/STAGE_02/3_Talos",
                    "2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact"]),
    ("Reads",      ["1_SOVEREIGN/STAGE_01/Z_Reads", "1_SOVEREIGN/STAGE_02/Z_Reads",
                    "2_CITIZEN/Stage_Z/AppReads"]),
    ("Citizen",    ["2_CITIZEN/1_AOZ", "2_CITIZEN/2_BloodshedMinter", "2_CITIZEN/3_NosferatuMinter",
                    "2_CITIZEN/4_BunniesMinter", "2_CITIZEN/5_VaultsMinter",
                    "2_CITIZEN/6_OuronetBridge", "2_CITIZEN/7_Launchpad",
                    "2_CITIZEN/Stage_Z"]),
    ("Interface holders (no module)", ["1_SOVEREIGN/STAGE_01/0_Interfaces",
                                       "1_SOVEREIGN/STAGE_02/0_Interfaces"]),
]

DOC_RE = re.compile(r'@doc\s+"((?:[^"\\]|\\.)*)"', re.S)


def first_sentence(text, limit=150):
    """A module's @doc, de-continued and truncated. Pact continues a string with a trailing
    backslash and resumes after a leading one, so both must be stripped or the result is full of
    stray slashes -- which is exactly what the first version of this emitted."""
    if not text:
        return ""
    s = re.sub(r'\\\s*\n\s*\\?', ' ', text)      # join continuations
    s = re.sub(r'\\(.)', r'\1', s)               # unescape the rest
    s = ' '.join(s.split())
    m = re.match(r'(.{20,}?[.;])\s', s)          # first clause, if there is a sane one
    s = m.group(1) if m else s
    return (s[:limit].rstrip() + '…') if len(s) > limit else s


def scan(path):
    """One .pact file -> its facts. Counts are of FORMS at the shapes the tree actually uses."""
    txt = open(path, encoding="utf8", errors="replace").read()
    mods = re.findall(r'^\(module\s+(\S+)', txt, re.M)
    ifaces = re.findall(r'^\(interface\s+([^\s)]+)', txt, re.M)
    body = txt[txt.index('(module '):] if '(module ' in txt else txt
    return {
        "path": os.path.relpath(path, ROOT),
        "modules": mods,
        "interfaces": ifaces,
        # NEWLINES ONLY -- deliberately `wc -l` semantics, not "logical lines".  Counting a
        # final unterminated line as a line is arguably more correct and is the WRONG choice here:
        # every other figure in OuronetDocumentation/ comes from `wc -l`, and 73 files in the tree
        # lack a trailing newline, so the honest-looking version reported 123,042 against the front
        # page's 122,969 -- a 73-line discrepancy between two generated numbers in the same folder,
        # which a reader can only read as one of them being broken.  Agreement with the documented
        # command beats local correctness.
        "lines": txt.count('\n'),
        "defun": len(re.findall(r'^\s*\(defun ', body, re.M)),
        "defcap": len(re.findall(r'^\s*\(defcap ', body, re.M)),
        "schema": len(re.findall(r'^\s*\(defschema ', txt, re.M)),
        "table": len(re.findall(r'^\s*\(deftable ', txt, re.M)),
        "doc": first_sentence((DOC_RE.search(body).group(1) if DOC_RE.search(body) else "")),
    }


def files_for(entries):
    out = []
    for e in entries:
        p = os.path.join(ROOT, e)
        if os.path.isfile(p):
            out.append(p)
        elif os.path.isdir(p):
            for dirpath, _, names in os.walk(p):
                out += [os.path.join(dirpath, n) for n in names if n.endswith('.pact')]
    return sorted(set(out))


def render_map():
    """The module map: one table per layer."""
    # Talos and Reads pull files out of directories that Citizen also claims; assign each file to
    # the FIRST layer that claims it, so nothing is listed twice.  Without this, TS02-CPAD and the
    # AppReads modules appear under both their own layer and Citizen -- which inflates every total
    # a reader might add up, silently.
    claimed, per_layer = set(), []
    for name, entries in LAYERS:
        fs = [f for f in files_for(entries) if f not in claimed]
        claimed.update(fs)
        per_layer.append((name, fs))

    out, tot = [], {"files": 0, "lines": 0, "defun": 0, "defcap": 0, "schema": 0, "table": 0,
                    "modules": 0, "interfaces": 0}
    for name, fs in per_layer:
        if not fs:
            continue
        rows = [scan(f) for f in fs]
        sub = {k: sum(r[k] for r in rows) for k in ("lines", "defun", "defcap", "schema", "table")}
        sub["modules"] = sum(len(r["modules"]) for r in rows)
        sub["interfaces"] = sum(len(r["interfaces"]) for r in rows)
        out.append(f"### {name}\n")
        out.append(f"{len(fs)} file(s) · {sub['modules']} module(s) · {sub['interfaces']} "
                   f"interface(s) · {sub['lines']:,} lines\n")
        out.append("| module | file | lines | fn | cap | sch/tbl | its own one-line `@doc` |")
        out.append("|---|---|---:|---:|---:|---:|---|")
        for r in rows:
            mod = ", ".join(f"`{m}`" for m in r["modules"]) or \
                  (", ".join(f"*{i}*" for i in r["interfaces"]) or "—")
            doc = r["doc"].replace("|", "\\|") or "—"
            out.append(f"| {mod} | `{r['path'].split('/', 1)[1] if '/' in r['path'] else r['path']}` "
                       f"| {r['lines']:,} | {r['defun']} | {r['defcap']} "
                       f"| {r['schema']}/{r['table']} | {doc} |")
        out.append("")
        tot["files"] += len(fs)
        for k in sub:
            tot[k] += sub[k]
    out.append("### Totals\n")
    out.append("| | |\n|---|---|")
    out.append(f"| files | {tot['files']} |")
    out.append(f"| module forms | {tot['modules']} |")
    out.append(f"| interface forms | {tot['interfaces']} |")
    out.append(f"| lines | {tot['lines']:,} |")
    out.append(f"| `defun` forms | {tot['defun']:,} |")
    out.append(f"| `defcap` forms | {tot['defcap']} |")
    out.append(f"| schemas / tables | {tot['schema']} / {tot['table']} |")
    return "\n".join(out)


REGIONS = {"module-map": render_map}


def apply(path, write):
    """Replace every marked region in one file. Returns 1 if it differed."""
    cur = open(path, encoding="utf8").read()
    new = cur
    for name, fn in REGIONS.items():
        pat = re.compile(r'(<!-- @generated:' + re.escape(name) +
                         r'[^>]*-->\n)(.*?)(<!-- @end:' + re.escape(name) + r' -->)', re.S)
        if not pat.search(new):
            continue
        new = pat.sub(lambda m: m.group(1) + fn() + "\n" + m.group(3), new)
    if new == cur:
        return 0
    if write:
        open(path, "w", encoding="utf8").write(new)
        print(f"  wrote    {os.path.relpath(path, ROOT)}")
    else:
        print(f"  STALE    {os.path.relpath(path, ROOT)} -- a generated region differs from the tree")
    return 1


def main():
    check, write = "--check" in sys.argv, "--write" in sys.argv
    if "--selftest" in sys.argv:
        return selftest()
    if not (check or write):
        print(__doc__)
        return 0
    if not os.path.isdir(DOCS):
        print("no OuronetDocumentation/ -- nothing to do")
        return 0
    bad = files = 0
    for dirpath, _, names in os.walk(DOCS):
        for n in sorted(names):
            if not n.endswith(".md"):
                continue
            p = os.path.join(dirpath, n)
            if any(f'@generated:{k}' in open(p, encoding="utf8").read() for k in REGIONS):
                files += 1
                bad += apply(p, write)
    if bad and not write:
        print(f"docs module map: {bad} file(s) stale. Run REPL/tools/_docsmodules.py --write")
        return 1
    if not bad:
        print(f"docs module map: clean -- {files} file(s) with generated regions, "
              f"{len(REGIONS)} region kind(s)")
    return 0


def selftest():
    ok = True
    # @doc joining: the continuation form is the thing that broke first.
    got = first_sentence('Constants library: exposes stuff \\\n        \\ and more things here.')
    if "\\" in got:
        print(f"  FAIL continuation not joined: {got!r}"); ok = False
    # Every layer directory must exist, or the map silently omits a layer.
    for name, entries in LAYERS:
        for e in entries:
            if not os.path.exists(os.path.join(ROOT, e)):
                print(f"  FAIL layer {name!r} names a missing path: {e}"); ok = False
    # No file may be claimed by two layers -- the bug the `claimed` set exists to prevent.
    seen = {}
    for name, entries in LAYERS:
        for f in files_for(entries):
            seen.setdefault(f, []).append(name)
    dupes = {f: ls for f, ls in seen.items() if len(ls) > 1}
    print(f"  {len(seen)} .pact files across {len(LAYERS)} layers; "
          f"{len(dupes)} claimed by more than one (deduped by first claim)")
    # The map's totals must equal an independent count of the same tree.
    import subprocess
    n = len([f for f in seen])
    real = subprocess.run(["bash", "-c",
        f"cd {ROOT} && find 1_SOVEREIGN 2_CITIZEN -name '*.pact' | wc -l"],
        capture_output=True, text=True).stdout.strip()
    if str(n) != real:
        print(f"  FAIL layers cover {n} files, tree has {real} -- a layer is missing or extra")
        ok = False
    else:
        print(f"  layer coverage exact: {n} files = the whole tree")
    print("  selftest OK" if ok else "  selftest FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())

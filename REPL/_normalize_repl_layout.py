#!/usr/bin/env python3
"""Normalize Ouronet REPL/*.repl to canonical layout. Skips 6.2.1 ANK and 6.2.2 SCORE."""
from __future__ import annotations

import re
import sys
from pathlib import Path

SKIP = {"Stage_02/[6.2.1]_AQP-ANK.repl", "Stage_02/[6.2.2]_AQP-SCORE.repl"}

NEXT_BLOCK = (
    ";;||>>>>>>>>>>>>>>>>>>>>>>>>>\n"
    ";;|| NEXT                   >\n"
    ";;||>>>>>>>>>>>>>>>>>>>>>>>>>"
)

# Legacy thick separator: ;; newline ;;>>>>... newline ;; newline
LEGACY_SEP = re.compile(r"\n;;\s*\n;;>{20,}\s*\n;;\s*\n")


def rel_posix(p: Path, root: Path) -> str:
    return p.relative_to(root).as_posix()


def has_file_banner(t: str) -> bool:
    return "FILE  REPL/" in t[:12000]


def preamble(rel: str) -> str:
    return f""";;
;; REPL/{rel} — canonical integration layout (OuronetInformational/ARCHITECTURE/REPL_AND_TESTS.md)
;;   Inter-tx:   ;;|| NEXT >  (same three lines as REPL/Stage_01/[2.2]_Core.repl)
;;   Intra-tx:   ;;==== <TX label> · mm · <slug> ====  + next-line (print "--- [<label> · mm · …] ---"); mm = 01.. within each (begin-tx …) (see OuronetInformational/ARCHITECTURE/REPL_AND_TESTS.md).
;;   format "{{}}": Talos / module echoes and (env-gas) — document additional prefixes in this file's (print …) lines as needed.
;;
(print "")
(print "================================================================")
(print "FILE  REPL/{rel}")
(print "================================================================")
(print "Legend (terminal observability): see ;; preface; echoes use <(…)> where helpful.")
(print "Source: ;;|| NEXT > between txs; ;;==== … · mm · … ==== + banner before each begin-tx.")
(print "")
"""


def replace_legacy_seps(t: str) -> str:
    return LEGACY_SEP.sub("\n" + NEXT_BLOCK + '\n(print "")\n', t)


# (commit-tx) ... (begin-tx — ensure ;;|| NEXT in gap (only if gap has no ;;||)
COMMIT_BEGIN = re.compile(
    r"\(commit-tx\)\s*((?:(?!\(begin-tx).)*?)\(begin-tx",
    re.DOTALL,
)


def ensure_next_between_commit_begin(t: str) -> str:

    def repl(m: re.Match[str]) -> str:
        gap = m.group(1)
        if ";;|| NEXT" in gap:
            return m.group(0)
        g = gap.rstrip("\n")
        if g.strip() == "":
            inner = '\n(print "")\n'
        else:
            inner = "\n" + g + "\n"
        return "(commit-tx)\n" + NEXT_BLOCK + '\n(print "")' + inner + "(begin-tx"

    return COMMIT_BEGIN.sub(repl, t)


def _subdivide_text(t: str) -> str:
    import importlib.util

    spath = Path(__file__).resolve().parent / "_subdivide_repl.py"
    spec = importlib.util.spec_from_file_location("_subdivide_repl", spath)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.subdivide_text(t)


def add_preamble(t: str, rel: str) -> str:
    if has_file_banner(t):
        return t
    return preamble(rel) + t


def process(path: Path, root: Path) -> bool:
    rel = rel_posix(path, root)
    if rel in SKIP:
        return False
    raw = path.read_text(encoding="utf-8")
    t = raw
    t = replace_legacy_seps(t)
    t = ensure_next_between_commit_begin(t)
    t = add_preamble(t, rel)
    t = _subdivide_text(t)
    if t != raw:
        path.write_text(t, encoding="utf-8")
        return True
    return False


def main() -> None:
    root = Path(__file__).resolve().parent
    n = 0
    for p in sorted(root.rglob("*.repl")):
        if p.name.startswith("_"):
            continue
        if process(p, root):
            print("updated", p.relative_to(root))
            n += 1
    print("changed files:", n)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Subdivide each (begin-tx "TITLE") ... (commit-tx) block with internal ;;==== TITLE · mm · slug ====
and (print "--- [TITLE · mm · slug] ---").

Removes mechanical pre-(begin-tx) pair (··01··(group)·· + print ·01·start) before (begin-tx …).

Skips Stage_02/[6.2.1]_AQP-ANK.repl and Stage_02/[6.2.2]_AQP-SCORE.repl.
"""
from __future__ import annotations

import re
from pathlib import Path

SKIP = {"Stage_02/[6.2.1]_AQP-ANK.repl", "Stage_02/[6.2.2]_AQP-SCORE.repl"}

PRE_BEGIN = re.compile(
    r"(?:^[ \t]*;;====[^\n]*?·\s*01\s*·\s*\(group\)[^\n]*\n)"
    r'(?:^[ \t]*\(print[^\n]*?·\s*01\s*·\s*start[^\n]*\)\s*\n)'
    r'(?=[ \t]*\(begin-tx)',
    re.MULTILINE,
)


def _find_commit_line(lines: list[str], start: int) -> int:
    for k in range(start, len(lines)):
        if lines[k].strip() == "(commit-tx)":
            return k
    return -1


def _first_index(body: list[str], pred) -> int:
    for i, ln in enumerate(body):
        if pred(ln):
            return i
    return -1


def _anchors(_title: str, body: list[str]) -> list[tuple[int, int, str]]:
    idx_chain = _first_index(body, lambda ln: ln.lstrip().startswith("(env-chain-data"))
    idx_ns = _first_index(body, lambda ln: ln.lstrip().startswith('(namespace "'))
    idx_gas = _first_index(body, lambda ln: ln.lstrip().startswith("(env-gasmodel"))
    idx_sigs = _first_index(body, lambda ln: ln.lstrip().startswith("(env-sigs"))
    idx_let = _first_index(body, lambda ln: bool(re.match(r"^\s*\(let\s", ln)))
    idx_load = _first_index(body, lambda ln: ln.lstrip().startswith("(load "))
    idx_fmt = _first_index(body, lambda ln: bool(re.match(r'^\s*\(format\s+"<<<<<<<', ln)))

    cands: list[tuple[int, str]] = []

    if idx_sigs != -1:
        cands.append((idx_sigs, "env-sigs (caps)"))
    else:
        for ix, slug in ((idx_chain, "env-chain-data"), (idx_ns, "namespace"), (idx_gas, "env-gasmodel")):
            if ix != -1:
                cands.append((ix, slug))
                break

    if idx_let != -1 and idx_load != -1:
        if idx_let <= idx_load:
            cands.append((idx_let, "let / invocation"))
            if idx_load != idx_let:
                cands.append((idx_load, "load module"))
        else:
            cands.append((idx_load, "load module"))
            cands.append((idx_let, "let / invocation"))
    elif idx_let != -1:
        cands.append((idx_let, "let / invocation"))
    elif idx_load != -1:
        cands.append((idx_load, "load module"))

    if idx_fmt != -1 and not any(ix == idx_fmt for ix, _ in cands):
        cands.append((idx_fmt, "gas echo"))

    cands.sort(key=lambda x: x[0])
    out: list[tuple[int, int, str]] = []
    seen: set[int] = set()
    mm = 1
    for ix, slug in cands:
        if ix in seen:
            continue
        seen.add(ix)
        out.append((ix, mm, slug))
        mm += 1
    return out


def _insert_markers_into_body(body: list[str], title: str) -> list[str]:
    inserts = _anchors(title, body)
    if not inserts:
        return body
    inserts.sort(key=lambda x: -x[0])
    out = list(body)
    for ix, mm, slug in inserts:
        if ix < 0 or ix > len(out):
            continue
        if ix > 0 and ";;====" in out[ix - 1] and title[: min(10, len(title))] in out[ix - 1]:
            continue
        mm_s = f"{mm:02d}"
        pad = "=" * max(0, 80 - len(title) - len(mm_s) - len(slug))
        hdr = f";;==== {title} · {mm_s} · {slug} ==== {pad}\n"
        ban = f'(print "--- [{title} · {mm_s} · {slug}] ---")\n'
        out[ix:ix] = [hdr, ban]
    return out


def subdivide_text(text: str) -> str:
    text = PRE_BEGIN.sub("", text)
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    i = 0
    while i < len(lines):
        m = re.match(r"^\s*\(begin-tx\s+\"([^\"]*)\"\s*\)\s*$", lines[i])
        if not m:
            out.append(lines[i])
            i += 1
            continue
        title = m.group(1)
        out.append(lines[i])
        i += 1
        c = _find_commit_line(lines, i)
        if c == -1:
            out.extend(lines[i:])
            break
        body = lines[i:c]
        out.extend(_insert_markers_into_body(body, title))
        out.append(lines[c])
        i = c + 1
    return "".join(out)


def process(path: Path, root: Path) -> bool:
    rel = path.relative_to(root).as_posix()
    if rel in SKIP:
        return False
    raw = path.read_text(encoding="utf-8")
    new = subdivide_text(raw)
    if new != raw:
        path.write_text(new, encoding="utf-8")
        return True
    return False


def main() -> None:
    root = Path(__file__).resolve().parent
    n = 0
    for p in sorted(root.rglob("*.repl")):
        if p.name.startswith("_"):
            continue
        if process(p, root):
            print("subdivided", p.relative_to(root))
            n += 1
    print("files changed:", n)


if __name__ == "__main__":
    main()

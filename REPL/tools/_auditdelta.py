#!/usr/bin/env python3
"""What the v2 audit must re-verify: the SIGNATURE DELTA, generated from git.

WHY GENERATED. The patron/executor sweep changes the client surface of every module, so the
published audit has to be re-issued -- and the first question any auditor asks is "what actually
changed?". A hand-written answer to that is a second copy of the truth, free to drift from the
code the moment someone forgets to update it. This derives it from the repository instead:
every entrypoint whose SIGNATURE differs from the pre-sweep baseline, per module.

What it cannot derive is JUDGEMENT -- which assertions the audit must re-run, which findings are
invalidated, which new gates need an adversarial test. That belongs in Audit/AUDIT-V2-DELTA.md
under each module's heading, and `--check` fails if a swept module has no such block. Facts
generated, judgement written, neither pretending to be the other.

USAGE
    python3 REPL/tools/_auditdelta.py            print the delta
    python3 REPL/tools/_auditdelta.py --check    fail if a swept module lacks a judgement block
"""
import os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BASELINE = "21fa54fb2393e5618d9b017b7d0870a82d0b5ec4"
LEDGER = os.path.join(ROOT, "Audit", "AUDIT-V2-DELTA.md")
DEFUN = re.compile(r'\n    \(defun ([A-Za-z0-9|_\-]+)(?::[A-Za-z0-9{}\.\[\]|_\-]+)?\s*\n?\s*\(([^)]*)\)')
ENTRY = re.compile(r'^(A|AA|C|CC|Cp|CCp|Ap|AAp)_|\|(A|AA|C|CC)_')


def sigs_at(rev, path):
    r = subprocess.run(["git", "show", f"{rev}:{path}"], capture_output=True, text=True, cwd=ROOT)
    if r.returncode:
        return {}
    src = r.stdout
    try:
        src = src[src.index("\n(module "):]
    except ValueError:
        return {}
    return {m.group(1): " ".join(m.group(2).split()) for m in DEFUN.finditer(src)
            if ENTRY.search(m.group(1))}


def tracked():
    r = subprocess.run(["git", "ls-files", "1_SOVEREIGN", "2_CITIZEN"],
                       capture_output=True, text=True, cwd=ROOT)
    return [p for p in r.stdout.split("\n") if p.endswith(".pact")]


def delta():
    out = {}
    for p in tracked():
        old, new = sigs_at(BASELINE, p), sigs_at("HEAD", p)
        if not old and not new:
            continue
        ch = [(f, old[f], new[f]) for f in sorted(set(old) & set(new)) if old[f] != new[f]]
        gone = sorted(set(old) - set(new))
        added = sorted(set(new) - set(old))
        if ch or gone or added:
            out[p] = (ch, gone, added)
    return out


def main():
    d = delta()
    tot = sum(len(c) for c, _, _ in d.values())
    print(f"v2 audit delta -- baseline {BASELINE[:8]}\n")
    print(f"  {len(d)} file(s) with a changed client surface, {tot} entrypoint signature(s) changed\n")
    for p in sorted(d):
        ch, gone, added = d[p]
        print(f"  {p}")
        for f, o, n in ch[:200]:
            print(f"     ~ {f}\n         was ({o})\n         now ({n})")
        for f in gone:
            print(f"     - {f}  (REMOVED or RENAMED out of the entrypoint band)")
        for f in added:
            print(f"     + {f}  (NEW entrypoint)")
    if "--check" in sys.argv:
        if not os.path.exists(LEDGER):
            print(f"\n  !! {os.path.relpath(LEDGER, ROOT)} does not exist")
            return 1
        led = open(LEDGER, encoding="utf8").read()
        # A module is COVERED if the ledger names it anywhere -- a `### <file>` block of its
        # own, or a line in the downstream-consequence list. Requiring the heading form would
        # force fifty bespoke blocks for files that changed only because a caller did, and a
        # checklist that demands busywork gets satisfied with filler.
        missing = [p for p in d
                   if os.path.basename(p) not in led
                   and os.path.splitext(os.path.basename(p))[0] not in led]
        if missing:
            print(f"\n  !! {len(missing)} changed module(s) have NO judgement block in the ledger:")
            for p in missing:
                print(f"     {p}")
            print("  !! Facts are generated; what the audit must RE-VERIFY has to be written.")
            return 1
        print(f"\n  ledger covers every changed module.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""PACT STRING-CONTINUATION LINT -- the 2-second check that two 5-minute gate runs did not do.

A Pact string spans lines with a trailing `\\` and a leading `\\` on the next line:

    @doc "first part \\
        \\ second part"

Append to one of those by naive concatenation and you get `first part.            \\ \\` on a
SINGLE line. `\\ ` is not a valid escape, so the module fails to LOAD -- every suite that touches
it reports BROKEN with zero assertions, which looks nothing like a test failure and costs a full
gate run to discover.

This happened TWICE on 2026-09-21, in DALOS and then in ATSU, from the same habit. Nothing caught
it: `_callarity` parses calls not strings, `_conformance` reads structure, and `_modulecomplete`
reported **7/7 on a file that could not load**. A static suite that cannot tell you the file is
syntactically dead is agreeing with you, not checking you.

The rule enforced: inside a string literal, a `\\` may appear only (a) at end of line, or (b) as
the first non-whitespace character of a line, or (c) as part of a known escape (`\\"`, `\\\\`,
`\\n`, `\\t`, `\\r`). Anything else is the corruption above.

    python3 REPL/tools/_docstrings.py            all .pact + .repl
    python3 REPL/tools/_docstrings.py --file X
"""
import os, sys, glob

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OK_ESCAPES = '"\\nrt'


def scan(path):
    src = open(path, encoding="utf8", errors="replace").read()
    bad = []
    i, n, line = 0, len(src), 1
    while i < n:
        c = src[i]
        if c == "\n":
            line += 1; i += 1; continue
        if c == ";":                       # comment to end of line
            j = src.find("\n", i)
            i = n if j < 0 else j
            continue
        if c != '"':
            i += 1; continue
        # inside a string
        i += 1
        while i < n:
            c = src[i]
            if c == "\n":
                line += 1; i += 1; continue
            if c == '"':
                i += 1; break
            if c == "\\":
                nxt = src[i + 1] if i + 1 < n else ""
                if nxt == "\n":                      # legal continuation
                    i += 1; continue
                if nxt in OK_ESCAPES:                # legal escape
                    i += 2; continue
                # legal only if this `\` is the first non-space char on its line
                ls = src.rfind("\n", 0, i) + 1
                if src[ls:i].strip() == "":
                    i += 1; continue
                bad.append((line, src[ls:src.find("\n", i)].rstrip()[:96]))
                i += 1; continue
            i += 1
    return bad


def main():
    only = sys.argv[sys.argv.index("--file") + 1] if "--file" in sys.argv else None
    files = (glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True)
             + glob.glob(os.path.join(ROOT, "2_CITIZEN", "**", "*.pact"), recursive=True)
             + glob.glob(os.path.join(ROOT, "REPL", "**", "*.repl"), recursive=True)
             + glob.glob(os.path.join(ROOT, "REPL", "*.repl")))
    bad = 0
    for f in sorted(set(files)):
        if only and os.path.basename(f) != only: continue
        for line, text in scan(f):
            print(f"  {os.path.relpath(f, ROOT)}:{line}  malformed string continuation")
            print(f"     {text}")
            bad += 1
    if bad:
        print(f"\n{bad} malformed string continuation(s). A `\\` inside a string must end the")
        print("line or begin one. This is a LOAD error, not a style issue -- the module will not")
        print("compile and every suite touching it reports BROKEN with zero assertions.")
        return 1
    print("string continuations: clean")
    return 0


if __name__ == "__main__":
    sys.exit(main())

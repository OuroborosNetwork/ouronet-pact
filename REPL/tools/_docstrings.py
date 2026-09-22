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


def scan_doc_close(path):
    """AN UNESCAPED `"` INSIDE AN @doc CLOSES THE STRING, AND THAT IS LEGAL PACT.

    scan() above cannot see it -- there is no malformed escape to find. The string simply ends
    early and the remaining prose is parsed as CODE, which is how a line reading
    `... output as "this account was refreshed", never as \\` became
    `Cannot find module: ouronet-ns.this` and took a whole gate run down. This file reported
    "clean" on it.

    THE DETECTABLE INVARIANT: in this codebase an @doc string always ends at the END of its line,
    optionally followed by the `)`s that close the enclosing form. If prose follows the closing
    quote on the same line, that quote was meant to be escaped.

    IT HAS TO WALK, NOT GREP. The first version searched for the literal `@doc` and reported 54
    hits, nearly all inside `;;` comments that merely MENTION @doc -- and comments about doc
    strings are exactly what a codebase this heavily annotated is full of. So this tracks string
    and comment state left to right and only fires on an @doc that is real code.
    """
    src = open(path, encoding="utf8", errors="replace").read()
    bad, i, n = [], 0, len(src)
    while i < n:
        c = src[i]
        if c == ";":                                  # comment to end of line
            j = src.find("\n", i)
            i = n if j < 0 else j
            continue
        if c == '"':                                  # a string that is NOT an @doc: skip it
            i += 1
            while i < n:
                if src[i] == "\\": i += 2; continue
                if src[i] == '"': i += 1; break
                i += 1
            continue
        if src.startswith("@doc", i):
            q = i + 4
            while q < n and src[q] in " \t\n": q += 1
            if q >= n or src[q] != '"':
                i += 4; continue
            j = q + 1
            while j < n:                              # walk to the string's REAL close
                if src[j] == "\\": j += 2; continue
                if src[j] == '"': break
                j += 1
            eol = src.find("\n", j)
            tail = src[j + 1: n if eol < 0 else eol].rstrip()
            # THE TELL IS THE TRAILING BACKSLASH, not merely "something follows the quote".
            # `(defun a () @doc "plain doc" true)` is legal one-line Pact and the first version
            # of this flagged it -- caught by the selftest below, which is the entire reason the
            # selftest carries decoys. What cannot be legal is a line that CLOSES the doc string
            # and then ends in a continuation `\`: the author believed they were still inside
            # the string, and everything between the two is now code.
            if tail.endswith("\\") and tail.strip("\\").strip() != "":
                bad.append((src.count("\n", 0, j) + 1,
                            src[src.rfind("\n", 0, j) + 1: n if eol < 0 else eol].rstrip()[:96]))
            i = j + 1
            continue
        i += 1
    return bad


def selftest():
    """Both detectors, on a fixture carrying one instance of each bug and two decoys.

    The decoys matter as much as the bugs. The first version of scan_doc_close() grepped for
    `@doc` and fired 54 times on COMMENTS that merely mention doc strings -- in a codebase this
    heavily annotated, a detector that cannot tell code from commentary about code is unusable.
    """
    import tempfile, os as _os
    src = (
        '(module X G\n'
        '    ;; a comment mentioning @doc "not a real one" -- DECOY, must be ignored\n'
        '    (defun a () @doc "plain doc" true)\n'
        '    (defun b ()\n'
        '        @doc "good, closes at end of line \\\n'
        '            \\ second line."\n'
        '        true)\n'
        '    (defun c ()\n'
        '        @doc "bad: output as "this was refreshed", never as \\\n'
        '            \\ more."\n'
        '        true)\n'
        '    (defun d ()\n'
        '        @doc "tail \\ mid-line backslash is a continuation error"\n'
        '        true)\n'
        ')\n')
    fd, path = tempfile.mkstemp(suffix=".pact"); _os.write(fd, src.encode()); _os.close(fd)
    try:
        closes = scan_doc_close(path)
        conts = scan(path)
    finally:
        _os.unlink(path)
    bad = []
    if len(closes) != 1:
        bad.append(f"   scan_doc_close found {len(closes)} (expected exactly 1): {closes}")
    if not conts:
        bad.append("   scan found 0 malformed continuations (expected the mid-line `\\`)")
    if bad:
        print("SELFTEST FAILED -- _docstrings\n" + "\n".join(bad))
        return 1
    print("  _docstrings selftest: both detectors fire once, the comment decoy is ignored")
    return 0


def main():
    if "--selftest" in sys.argv:
        return selftest()
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
        for line, text in scan_doc_close(f):
            print(f"  {os.path.relpath(f, ROOT)}:{line}  @doc closes mid-line -- an unescaped "
                  f'`"` ends the string and the rest is parsed as CODE')
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

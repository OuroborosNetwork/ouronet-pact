#!/usr/bin/env python3
"""EXPECT-FAILURE STRENGTH (plan step 3.1) — how many negative tests accept ANY error?

    cd REPL && python3 _expectfail.py [--list] [--fix-hint]

Pact's `expect-failure` has two forms:

    (expect-failure "doc" expr)                 <- WEAK: passes on ANY abort
    (expect-failure "doc" "expected msg" expr)  <- STRONG: passes only on THAT abort

A weak one proves the transaction failed, not that it failed FOR THE REASON UNDER TEST. It stays
green when the setup breaks, when a guard fires earlier than intended, when a typo makes the call
unresolvable. Several times this session a weak-looking probe turned out to be passing for the
wrong reason -- the STOAICO deadlock was found precisely because the message was checked.

WHY A REGEX IS NOT ENOUGH, and why the baseline figure of 137 is not trustworthy: the doc string
and the expected-message string are frequently on separate lines, so `expect-failure "…"$`
matches the 3-arg form too. This counts TOP-LEVEL ARGUMENTS with real paren matching over
comment- and string-stripped source, so the two forms cannot be confused.
"""
import argparse, glob, os, re, sys, collections

os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def lex(src):
    """Blank comments, keep strings as single-char tokens so arg counting sees them as atoms."""
    out, i, n, in_str, esc = [], 0, len(src), False, False
    for i, c in enumerate(src):
        if in_str:
            if esc: esc = False
            elif c == '\\': esc = True
            elif c == '"': in_str = False
            out.append('\x00' if c != '\n' else '\n')   # string body -> opaque
        elif c == '"':
            in_str = True; out.append('\x01')           # string OPEN marker
        else:
            out.append(c)
    # second pass to blank ;; comments (strings already neutralised)
    res, i, n = [], 0, len(out)
    while i < n:
        if out[i] == ';':
            while i < n and out[i] != '\n': res.append(' '); i += 1
        else:
            res.append(out[i]); i += 1
    return ''.join(res)

def args_of(s, start):
    """Given index of '(' opening an expect-failure form, return its top-level arg count."""
    depth, i, n, args, in_arg = 0, start, len(s), 0, False
    while i < n:
        c = s[i]
        if c == '(':
            depth += 1
            if depth == 2 and not in_arg: args += 1; in_arg = True
        elif c == ')':
            depth -= 1
            if depth == 1: in_arg = False
            if depth == 0: return args
        elif depth == 1:
            if c in ' \t\n':
                in_arg = False
            elif not in_arg:
                # a bare atom (string marker, symbol, number) is one argument
                if not (i == start + 1):
                    args += 1; in_arg = True
        i += 1
    return args

EF = re.compile(r'\(expect-failure[\s\n]')

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--list", action="store_true", help="print every weak site")
    a = ap.parse_args()
    weak, strong = [], 0
    per = collections.Counter()
    for f in sorted(glob.glob("**/*.repl", recursive=True)):
        if f.startswith("archive" + os.sep): continue
        raw = open(f, encoding='utf8', errors='ignore').read()
        s = lex(raw)
        for m in EF.finditer(s):
            # count the FORM's args: name + doc [+ msg] + expr
            n = args_of(s, m.start())
            line = raw[:m.start()].count('\n') + 1
            if n <= 3: weak.append((f, line)); per[f] += 1     # (name doc expr)
            else: strong += 1                                   # (name doc msg expr)
    print(f"expect-failure sites: {len(weak) + strong}")
    print(f"  STRONG (3-arg, message checked): {strong}")
    print(f"  WEAK   (2-arg, ANY error passes): {len(weak)}")
    if weak:
        print("\nweak sites by file:")
        for f, c in per.most_common(20):
            print(f"  {c:4d}  {f}")
        if a.list:
            print("\nevery weak site:")
            for f, l in weak: print(f"  {f}:{l}")
    return 0

sys.exit(main())

#!/usr/bin/env python3
"""Shared Pact lexing helpers for the analysis scripts.

Extracted after THREE separate scanners shipped with bugs in re-derived copies of this logic:
  * a `strip_comments` that tracked quote state PER LINE -- Pact @doc strings span lines via the
    `\\`-newline continuation, so a `;` inside one deleted a closing `"` and misaligned every
    string literal after it;
  * a string-literal regex without re.S, which cannot step over that same `\\`+newline and so goes
    blind from the first continued @doc onward;
  * a conformance rule that read `(deftable ...)` out of its own explanatory COMMENT.

One copy, used by everything. Import this; do not re-derive it.
"""
import re

def strip_comments(src):
    """Remove `;` comments, honouring string literals ACROSS newlines."""
    out, i, n, in_str, esc = [], 0, len(src), False, False
    while i < n:
        c = src[i]
        if in_str:
            out.append(c)
            if esc: esc = False
            elif c == '\\': esc = True
            elif c == '"': in_str = False
            i += 1
        elif c == '"': in_str = True; out.append(c); i += 1
        elif c == ';':
            while i < n and src[i] != '\n': out.append(' '); i += 1
        else: out.append(c); i += 1
    return ''.join(out)

def balanced(src, start, open_ch='(', close_ch=')'):
    """Index of the delimiter closing the one at <start>, string-aware. -1 if unbalanced."""
    d, i, n, in_str, esc = 0, start, len(src), False, False
    while i < n:
        c = src[i]
        if in_str:
            if esc: esc = False
            elif c == '\\': esc = True
            elif c == '"': in_str = False
        elif c == '"': in_str = True
        elif c == open_ch: d += 1
        elif c == close_ch:
            d -= 1
            if d == 0: return i
        i += 1
    return -1

def split_top(body):
    """Top-level parenthesised forms inside a list/binding-group body."""
    out, i, n = [], 0, len(body)
    while i < n:
        if body[i] == '(':
            j = balanced(body, i)
            if j < 0: break
            out.append(body[i:j+1]); i = j + 1
        else: i += 1
    return out

# A literal string, DOTALL so it can cross Pact's `\`-newline @doc continuation.
STRLIT = re.compile(r'"((?:[^"\\]|\\.)*)"', re.S)

UR_CALL = re.compile(r'\(\s*(?:ref-[A-Za-z0-9|_-]+::)?(UR_[A-Za-z][A-Za-z0-9|_-]*)\b')

def reader_kinds(files):
    """Set of UR_* readers that bottom out in a bare `read` (can ABORT on a missing row).

    A `with-default-read` ANSWERS for an absent row instead of raising, so it is safe to evaluate
    eagerly. Reader kind propagates through delegation: a reader calling a hard reader is hard.
    Distinguishing the two is what makes these scanners usable rather than noise.
    """
    body, delegates = {}, {}
    for f in files:
        src = strip_comments(open(f, encoding='utf8', errors='ignore').read())
        for m in re.finditer(r'\(defun\s+(UR_[A-Za-z][A-Za-z0-9|_-]*)', src):
            nm = m.group(1)
            end = balanced(src, m.start() - 0 if src[m.start()] == '(' else m.start())
            b = src[m.start():end if end > m.start() else m.start() + 400]
            if nm in body and len(b) <= len(body[nm]):
                continue                       # keep the implementation, not the interface stub
            body[nm] = b
            delegates[nm] = set(UR_CALL.findall(b)) - {nm}
    hard = {nm for nm, b in body.items()
            if re.search(r'\(\s*read\s+', b) and 'with-default-read' not in b}
    for _ in range(8):
        for nm, ds in delegates.items():
            if nm not in hard and (ds & hard): hard.add(nm)
    return hard

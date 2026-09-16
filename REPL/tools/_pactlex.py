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
import os, re

def ident_re(name):
    """A word-boundary regex for a PACT identifier. Use this instead of `\\b...\\b`.

    `\\b` is a boundary between a word and a NON-word character, and `-` is a non-word character
    -- so `\\bc-rbt\\b` matches INSIDE `c-rbt-amount`, and `\\bid\\b` matches inside `pool-id`.
    Pact identifiers use `-` and `|` freely, so `\\b` silently turns a hyphenated name into a
    prefix match against every longer name containing it.

    MEASURED 2026-09-16. This made `_eagerlet.py --produced` report `08_ATS.pact:1790`: an
    `enforce` on `c-rbt-amount`, reported as an enforce on `c-rbt`. That site was triaged by
    hand as a judgement call before the boundary was suspected -- the tool sent a human to
    read the wrong line. The same `\\b` appeared in EIGHT places across FIVE tools, including
    `reader_kinds`'s own hardness test, where it over-marks readers as hard (a read whose key
    is `pool-id` "mentions" a parameter named `id`).

    Over-matching is the safe direction for a checker, but this suite's stated rule is that a
    scanner should rather miss than cry wolf: a tool that cries wolf gets ignored, and a tool
    that is ignored may as well not run.

    `|` IS NOT AN IDENTIFIER CHARACTER HERE, and the first version of this helper said it was.
    Pact uses `|` as a SEGMENT SEPARATOR inside qualified names -- `ATS|HOT-RBT|C_Repurpose` --
    so treating it as part of the identifier makes the left boundary reject a genuine mention:
    every standalone `C_Repurpose` in the REPL corpus is preceded by `|`. That mistake turned
    `_docclaims.py` from 1 unverified doc claim to 25, all 24 of them false, and it would have
    been reported as a find. `.` and `:` behave the same way and are excluded for the same reason.
    """
    return re.compile(r'(?<![A-Za-z0-9_-])' + re.escape(name) + r'(?![A-Za-z0-9_-])')

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

def reader_kinds(files, with_ambiguous=False):
    """Set of UR_* readers that bottom out in a bare `read` (can ABORT on a missing row).

    A `with-default-read` ANSWERS for an absent row instead of raising, so it is safe to evaluate
    eagerly. Reader kind propagates through delegation: a reader calling a hard reader is hard.
    Distinguishing the two is what makes these scanners usable rather than noise.

    TWO CORRECTIONS, 2026-09-16, both found while adding _eagerlet.py's --produced mode:

    1] AMBIGUOUS NAMES ARE WITHHELD. This keyed by BARE NAME and kept whichever body was LONGEST, so
       for a reader defined in several modules the verdict was one module's answer applied to all.
       Measured: 650 UR_ readers with a real body, 79 defined in MORE THAN ONE MODULE, 33 of those
       DISAGREEING on hard/soft. `UR_AccountSupply` alone has five definitions, four soft and one
       hard. A bare name is not an identity in a module system; where a name disagrees with itself
       the honest answer is "unknown", so it is withheld from `hard` and returned separately when
       <with_ambiguous> -- conservative, and visible rather than silent.

    2] HARD NOW MEANS "CAN RAISE FOR THE SUBJECT", not "contains a raising read somewhere". A bare
       `read` whose KEY is a constant is a singleton config row that always exists --
       `(read DALOS|PropertiesTable DALOS|INFO ...)` -- and cannot abort for a caller-supplied id.
       Counting those, then propagating through delegation, marked `UR_AccountRoleBurn` hard although
       every branch of it is a `with-default-read`: it merely consults `UR_OuroborosID` to choose a
       table. Propagation now also requires the caller to hand one of its OWN parameters to the hard
       callee. Verified by hand on that reader.
    """
    body, delegates, per_name = {}, {}, {}
    for f in files:
        src = strip_comments(open(f, encoding='utf8', errors='ignore').read())
        mm = re.search(r'\(module\s+([A-Za-z][A-Za-z0-9|_-]*)', src)
        mod = mm.group(1) if mm else os.path.basename(f)
        for m in re.finditer(r'\(defun\s+(UR_[A-Za-z][A-Za-z0-9|_-]*)', src):
            nm = m.group(1)
            end = balanced(src, m.start() - 0 if src[m.start()] == '(' else m.start())
            b = src[m.start():end if end > m.start() else m.start() + 400]
            if len(b) >= 60:
                raw_hard = bool(re.search(r'\(\s*read\s+', b)) and 'with-default-read' not in b
                per_name.setdefault(nm, set()).add((mod, raw_hard))
            if nm in body and len(b) <= len(body[nm]):
                continue                       # keep the implementation, not the interface stub
            body[nm] = b
            delegates[nm] = set(UR_CALL.findall(b)) - {nm}

    ambiguous = {nm for nm, v in per_name.items()
                 if len({m for m, _ in v}) > 1 and len({h for _, h in v}) > 1}

    def params_of(b):
        m = re.match(r'\(defun\s+[^\s(]+[^(]*?\(([^)]*)\)', b)
        return re.findall(r'([A-Za-z][A-Za-z0-9|_-]*)\s*:', m.group(1)) if m else []

    def mentions_any(text, names):
        return any(ident_re(n).search(text) for n in names)

    def raises_for_subject(b):
        """A bare `read` whose KEY derives from a parameter can abort for a caller's input; one
        whose key is a constant is a singleton config row that always exists."""
        names = params_of(b)
        for rm in re.finditer(r'\(\s*read\s+[^\s)]+\s+([^\s)\]]+)', b):
            if mentions_any(rm.group(1), names):
                return True
        return False

    hard = {nm for nm, b in body.items()
            if re.search(r'\(\s*read\s+', b) and 'with-default-read' not in b
            and raises_for_subject(b)}
    for _ in range(8):
        for nm, ds in delegates.items():
            if nm in hard:
                continue
            names = params_of(body[nm])
            for d in (ds & hard):
                call = re.search(r'\((?:[A-Za-z0-9|_-]+::)?' + re.escape(d) + r'([^()]*)\)',
                                 body[nm])
                if call and mentions_any(call.group(1), names):
                    hard.add(nm)
                    break
    hard -= ambiguous
    return (hard, ambiguous) if with_ambiguous else hard

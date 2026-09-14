#!/usr/bin/env python3
"""
_audit_modref_calls.py — static audit for DEAD module-reference calls.

WHY THIS EXISTS
---------------
Pact resolves `ref-X::member` calls — both the member name AND its arity — at RUNTIME, not at
load time (proved empirically 2026-09-06; see OuronetInformational/memories/
2026-09-06-modref-dead-call-audit.md). A misspelled member or a wrong argument count therefore:

    * compiles,
    * deploys cleanly,
    * passes the whole REPL pipeline,

and fails only the first time a real user takes that branch. Two Talos client entrypoints
(DALOS|C_UpdateEliteAccount / ...Squared) sat dead in this repo for exactly that reason.

A green ZALL proves nothing about call sites no test exercises. This script covers that gap.

USAGE
-----
    python3 REPL/_audit_modref_calls.py            # from the repo root
    python3 REPL/_audit_modref_calls.py --quiet    # findings only

Exit code 1 when findings exist, so it can gate a pre-deploy check.

THREE TRAPS this script exists to avoid (each produced garbage findings while it was written —
411 -> 150 -> 56 -> 13 hits before the output was trustworthy):

 1. UNTYPED PARAMS.   `(defun UC_AppL:list (in:list item))` — counting only `name:type` tokens
                      undercounts the arity. Count top-level tokens instead.
 2. COMMENTS/DOCS.    `@doc` text and `;;` comments mention functions in call-like shapes. Strip
                      them, but PRESERVE newlines and collapse each string to ONE token, or both
                      the arg counts and the reported line numbers go wrong.
 3. REF-NAME SCOPING. `r` / `ref-DALOS` are rebound dozens of times per file. A file-level
                      name->module map attributes every call to the LAST binding — that alone
                      manufactured 22 fake findings. Resolve to the NEAREST PRECEDING binding.

Rule of thumb: if this returns hundreds of hits, the scanner is broken, not the codebase.
Hand-verify a sample before reporting anything.
"""
import re, sys, glob, bisect, collections

ROOTS = ("1_SOVEREIGN/**/*.pact", "2_CITIZEN/**/*.pact")
DEFS  = r'\((?:defun|defcap|defpact|defconst|defschema) ([\w|+\-]+)'


def strip_noise(src):
    """Remove ;; comments and string bodies. Newlines preserved (line numbers stay true);
    each string collapses to a single token (arg counting stays true). See trap 2."""
    out, i, n = [], 0, len(src)
    while i < n:
        c = src[i]
        if c == ';':
            j = src.find("\n", i)
            j = n if j < 0 else j
            out.append(" " * (j - i)); i = j
        elif c == '"':
            j = i + 1
            while j < n:
                if src[j] == '\\':
                    j += 2; continue
                if src[j] == '"':
                    break
                j += 1
            out.append('"' + "".join('\n' if ch == '\n' else 'S' for ch in src[i + 1:j]) + '"')
            i = j + 1
        else:
            out.append(c); i += 1
    return "".join(out)


def count_tokens(text):
    """Top-level token count — handles untyped params and nested [] {} types. See trap 1."""
    n, cur, depth = 0, "", 0
    for c in text:
        if c in "[{(":
            depth += 1; cur += c
        elif c in "]})":
            depth -= 1; cur += c
        elif depth == 0 and c in " \n\t":
            if cur.strip():
                n += 1
            cur = ""
        else:
            cur += c
    return n + (1 if cur.strip() else 0)


def count_call_args(rest):
    """Top-level arg count of a call, paren-balanced across lines. Safe now that comments and
    string bodies are stripped — an unstripped source makes this count runaway garbage."""
    depth, args, cur = 0, 0, ""
    for c in rest:
        if c in "([{":
            depth += 1; cur += c
        elif c in ")]}":
            if depth == 0:
                return args + (1 if cur.strip() else 0)
            depth -= 1; cur += c
        elif depth == 0 and c in " \t":
            if cur.strip():
                args += 1
            cur = ""
        else:
            cur += c
    return None


HIGHER_ORDER = {"map", "fold", "filter", "zip", "select", "where", "compose", "and?", "or?", "not?"}


def is_partial_application(src, match, got):
    """`(map (ref-X::fn) xs)` passes fn as a value — a legitimate 0-arg call site, not a bug."""
    if got != 0:
        return False
    i = match.start() - 1
    while i >= 0 and src[i] in " \n\t":
        i -= 1
    end = i + 1
    while i >= 0 and src[i] not in " \n\t()":
        i -= 1
    return src[i + 1:end] in HIGHER_ORDER


def load_sources():
    files = []
    for pat in ROOTS:
        files.extend(glob.glob(pat, recursive=True))
    return {f: strip_noise(open(f).read()) for f in sorted(files)}


def module_members(srcs):
    """module name -> set of member names (module bodies only, not the interfaces beside them)."""
    mem = collections.defaultdict(set)
    for src in srcs.values():
        spans = [(m.start(), m.group(1), m.group(2))
                 for m in re.finditer(r'(?m)^\((module|interface) ([\w\-|]+)', src)]
        for i, (pos, kind, name) in enumerate(spans):
            if kind != "module":
                continue
            end = spans[i + 1][0] if i + 1 < len(spans) else len(src)
            for d in re.finditer(DEFS, src[pos:end]):
                mem[name].add(d.group(1))
    return mem


def declared_arity(srcs):
    """function name -> set of declared arities (only names with ONE consistent arity are used)."""
    ar = collections.defaultdict(set)
    for src in srcs.values():
        for m in re.finditer(r'\(defun ([A-Za-z][\w|+\-]*)(?::[^\s(]+)?\s*\n?\s*\(([^()]*)\)', src):
            ar[m.group(1)].add(count_tokens(m.group(2)))
    return ar


def audit(srcs, members, arities):
    dead, arity_bad = [], []
    for f, src in srcs.items():
        binds = collections.defaultdict(list)
        for m in re.finditer(r'\(([\w\-|]+):module\{([\w\-|]+)\}\s+([\w\-|]+)\)', src):
            binds[m.group(1)].append((m.start(), m.group(3)))
        for m in re.finditer(r'\(?([\w\-|]+)::([\w|+\-]+)', src):
            ref, fn = m.group(1), m.group(2)
            line = src[:m.start()].count("\n") + 1
            scope = binds.get(ref)
            if scope:                                   # trap 3: nearest preceding binding
                idx = bisect.bisect_right([p for p, _ in scope], m.start()) - 1
                if idx >= 0:
                    mod = scope[idx][1]
                    if mod in members and fn not in members[mod]:
                        dead.append((f, line, ref, mod, fn))
                        continue
            if fn in arities and len(arities[fn]) == 1:
                rest = src[m.end():]
                if rest[:1] in (' ', '\n', ')'):
                    got = count_call_args(rest)
                    want = next(iter(arities[fn]))
                    if got is not None and got != want and not is_partial_application(src, m, got):
                        arity_bad.append((f, line, fn, got, want))
    return dead, arity_bad


def main():
    quiet = "--quiet" in sys.argv
    srcs = load_sources()
    members, arities = module_members(srcs), declared_arity(srcs)
    dead, arity_bad = audit(srcs, members, arities)
    if not quiet:
        print(f"scanned {len(srcs)} .pact files, {len(members)} modules\n")
    print(f"DEAD CALLS (member not on the nearest-bound module): {len(dead)}")
    for f, line, ref, mod, fn in dead:
        print(f"  {f}:{line}  {ref} -> {mod}::{fn}")
    print(f"\nARITY MISMATCHES: {len(arity_bad)}")
    for f, line, fn, got, want in arity_bad:
        print(f"  {f}:{line}  {fn}: called with {got}, declared {want}")
    if not quiet:
        print("\nNOTE: `(map (ref-X::fn) xs)` partial application is a legitimate 0-arg call site "
              "and may show up as an arity finding — verify before acting.")
    return 1 if (dead or arity_bad) else 0


if __name__ == "__main__":
    sys.exit(main())

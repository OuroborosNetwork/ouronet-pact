#!/usr/bin/env python3
"""DEAD-GUARD PRE-PASS (plan step 3.4, run BEFORE 3.3) — which `enforce`s can never fire?

    cd REPL && python3 _deadguard.py

Step 3.4 says an `enforce` for which no failing test can be written is DEAD and should be
deleted. Discovering that one site at a time costs a test each. This finds the cheap class
statically, from the shape that produced the one already known:

    DEMIPAD::C_Withdraw  reads UR_Funds  (a READER that enforces P) in its let-bindings,
                         THEN opens (with-capability (DEMIPAD|C>WITHDRAW …)),
                         and that capability enforces P AGAIN.

Pact evaluates `let` bindings before the body, so the reader runs FIRST. Any input that would
trip the capability's copy has already died inside the reader. The capability's `enforce` is
unreachable for every input -- provably, not probably.

MATCHING IS ON THE ENFORCE MESSAGE, exactly. Two guards that share a message string are the same
guard duplicated; two that merely look similar are not, and guessing would put dead-code claims
in front of a reviewer that do not survive contact with the source. Every hit here still needs
reading before it is believed -- the tool narrows 777 sites to a handful worth looking at.
"""
import collections, glob, os, re, sys

os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ROOT = ".."

def strip_comments(src):
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

MEMBER = re.compile(r'^\s{1,8}\((defun|defcap|defpact)\s+([^\s()]+)', re.M)
# the enforce's CONDITION, not its message. Two forms: a parenthesised expression, or a bare
# identifier that a `let` bound earlier in the same body.
ENF_EXPR = re.compile(r'\(enforce\s+(\((?:[^()]|\([^()]*\))*\)|[A-Za-z][\w|-]*)')
BIND     = re.compile(r'\(([A-Za-z][\w|-]*)\s*:\s*bool\s+(\((?:[^()]|\([^()]*\))*\))\)')

def predicates(body):
    """Normalised enforce CONDITIONS for one member, with let-bound booleans resolved.

    Matching on the MESSAGE was the first attempt and it found nothing -- the known dead guard
    pairs `UR_Funds`'s "Invalid Read Type" with `C>WITHDRAW`'s "Invalid Withdrawal type" while
    both enforce the identical `(contains type [1 2 3])`. Duplicated guards are rewritten
    messages far more often than they are copied ones, so the CONDITION is the only reliable key.
    """
    binds = {m.group(1): m.group(2) for m in BIND.finditer(body)}
    out = set()
    for m in ENF_EXPR.finditer(body):
        e = m.group(1)
        if not e.startswith('('):
            e = binds.get(e)
            if not e: continue
        e = re.sub(r'\s+', ' ', e).strip()
        if len(e) >= 10: out.add(e)
    return out

def bare(n):
    """`UR_Funds:decimal` -> `UR_Funds`. Member names carry their RETURN TYPE in the source and
    call sites do not. Forgetting that has now silently emptied three different analyses in this
    codebase -- the heavy-prefix call graph and both attempts here -- each time producing a
    confident ZERO rather than an error, which is the worst possible failure mode for a tool
    whose job is to report an absence."""
    return n.split(':')[0]

def members(src):
    ms = [(m.start(), m.group(1), bare(m.group(2))) for m in MEMBER.finditer(src)]
    for i, (off, kind, name) in enumerate(ms):
        end = ms[i + 1][0] if i + 1 < len(ms) else len(src)
        yield kind, name, off, src[off:end]

def main():
    files = [f for f in sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                               + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
             if "/Audit/" not in f]
    hits = []
    for f in files:
        src = strip_comments(open(f, encoding='utf8', errors='ignore').read())
        mem = list(members(src))
        # predicate -> members that enforce it, split by kind
        by_msg = collections.defaultdict(lambda: {"defun": [], "defcap": []})
        for kind, name, off, body in mem:
            for pred in predicates(body):
                if kind in by_msg[pred]:
                    by_msg[pred][kind].append((name, src[:off].count('\n') + 1))
        for msg, d in by_msg.items():
            readers = [(n, l) for n, l in d["defun"]
                       if n.split('|')[-1].startswith(("UR_", "URC_", "URCv_", "URH_"))]
            caps = d["defcap"]
            if not (readers and caps): continue
            # a client that calls the reader in a BINDING position and then opens the cap
            for kind, name, off, body in mem:
                if kind != "defun": continue
                for rname, _rl in readers:
                    for cname, cline in caps:
                        # reader appears before with-capability(cap) in the SAME body
                        ri = body.find("(" + rname.split('|')[-1])
                        ci = body.find("(with-capability (" + cname)
                        if ri != -1 and ci != -1 and ri < ci:
                            hits.append((os.path.relpath(f, ROOT), name, rname, cname,
                                         cline, msg[:74]))
    seen, out = set(), []
    for h in hits:
        k = (h[0], h[3], h[5])
        if k in seen: continue
        seen.add(k); out.append(h)
    print(f"DEAD-GUARD CANDIDATES — {len(out)}\n")
    print("Each: a client evaluates a READER that enforces the predicate, then opens a CAPABILITY")
    print("that enforces the SAME predicate. The capability's copy cannot fire.\n")
    for f, client, reader, cap, line, msg in out:
        print(f"  {f}:{line}")
        print(f"      client   {client}")
        print(f"      reader   {reader}   (runs first, in a binding)")
        print(f"      capability {cap}   <- its enforce is unreachable")
        print(f"      predicate {msg}\n")
    return 0

sys.exit(main())

#!/usr/bin/env python3
"""TIGHTEN weak `expect-failure`s to the 3-arg form, by HARVESTING the real message.

    cd REPL && python3 _tighten.py <file.repl> [--apply]

A 2-arg `(expect-failure "doc" expr)` passes on ANY abort. The 3-arg form pins the reason. The
message cannot be guessed and Pact does not print it when the 2-arg form PASSES -- so this tool
gets it the same way a human does, just without the tedium:

  1. rewrite every weak site with a deliberately-wrong sentinel expected-message;
  2. run the file ONCE -- expect-failure catches rather than aborts, so every site reports;
  3. read the real text out of `expected error message 'SENTINEL', got '<actual>'`;
  4. substitute, and re-run to confirm the file is green.

It NEVER invents a message, and a site whose real message it cannot harvest is left weak and
listed. Messages are trimmed to a discriminating prefix that stops before Ouronet's giant unicode
account strings, which are unstable across runs and would make the assertion brittle.
"""
import argparse, os, re, subprocess, sys

os.chdir(os.path.dirname(os.path.abspath(__file__)))
PACT = os.environ.get("PACT") or os.path.expanduser("~/.local/bin/pact")
SENT = "@@TIGHTEN@@"

def lex(src):
    out, in_str, esc = [], False, False
    for c in src:
        if in_str:
            if esc: esc = False
            elif c == '\\': esc = True
            elif c == '"': in_str = False
            out.append('\x00' if c != '\n' else '\n')
        elif c == '"': in_str = True; out.append('\x01')
        else: out.append(c)
    res, i, n, s = [], 0, len(out), out
    while i < n:
        if s[i] == ';':
            while i < n and s[i] != '\n': res.append(' '); i += 1
        else: res.append(s[i]); i += 1
    return ''.join(res)

def form(s, start):
    """-> (arg_count, end_offset_of_arg2) for the form whose '(' is at <start>."""
    depth, i, n, args, in_arg, end2 = 0, start, len(s), 0, False, None
    while i < n:
        c = s[i]
        if c == '(':
            depth += 1
            if depth == 2 and not in_arg: args += 1; in_arg = True
        elif c == ')':
            depth -= 1
            if depth == 1:
                in_arg = False
                if args == 2 and end2 is None: end2 = i + 1
            if depth == 0: return args, end2
        elif depth == 1:
            if c in ' \t\n':
                if in_arg and args == 2 and end2 is None: end2 = i
                in_arg = False
            elif not in_arg and i != start + 1:
                args += 1; in_arg = True
        i += 1
    return args, end2

def weak_sites(src):
    s = lex(src)
    out = []
    for m in re.finditer(r'\(expect-failure[\s\n]', s):
        n, end2 = form(s, m.start())
        if n <= 3 and end2: out.append((m.start(), end2))
    return out

def trim(msg):
    """A discriminating RAW prefix of the real message (not yet escaped for Pact).

    Two failed attempts are worth recording, because both produced assertions that looked fine:
      1. blanking `"` kept the Pact literal well-formed and CORRUPTED the text --
         `Key "no-such-tier" not found` became `Key  no-such-tier  not found`, matching nothing.
         The gate caught it across 29 entrypoints.
      2. cutting at the first `"` was a valid substring but threw the message away: every
         `Key "..." not found` collapsed to the useless prefix `Key`.
    Quotes are DATA here, so they are kept and escaped at write time by lit(). What is dropped is
    only the unicode account blobs, which differ per run and would make the assertion brittle.
    """
    cut = re.split(r'[Ͱ-῿Ⰰ-퟿₰-₿]', msg)[0].strip()
    if len(cut) < 8: cut = msg[:70].strip()
    cut = cut[:70]
    if len(cut) == 70 and ' ' in cut[40:]:      # never end mid-word: it reads like a bug
        cut = cut[:cut.rindex(' ')]
    return cut.rstrip('\\').strip()            # a trailing lone backslash would escape our quote

def lit(t):
    """The raw prefix as a Pact string literal."""
    return '"' + t.replace('\\', '\\\\').replace('"', '\\"') + '"'

def owning_entrypoint(path):
    """The gate entrypoint that LOADS this file, cheapest first.

    Most suites are mid-chain: `pact Stage_02/[6.1.1]_EQUITY.repl` dies immediately because the
    chain is not booted. So the probe has to run through whatever tester loads it, and the
    harvest matches FAILURE lines back by FILE AND LINE -- which works because the sentinel is
    inserted inline, leaving line numbers unchanged."""
    import glob as _g, importlib.util, sys as _sys
    spec = importlib.util.spec_from_file_location('_gate', '_gate.py')
    m = importlib.util.module_from_spec(spec)
    argv, _sys.argv = _sys.argv, ['_gate', '--audit-only']
    try: spec.loader.exec_module(m)
    except SystemExit: pass
    finally: _sys.argv = argv
    want = os.path.normpath(path)
    hits = [e for e in m.GATE if want in {os.path.normpath(x) for x in m.closure(e)}]
    # prefer a focused tester over the mega-suites
    hits.sort(key=lambda e: (e in ("ZALL.repl", "AQP-FULL.repl"), len(m.closure(e))))
    return hits[0] if hits else None

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("path"); ap.add_argument("--apply", action="store_true")
    ap.add_argument("--via", help="entrypoint to run (default: auto-detect from the gate)")
    a = ap.parse_args()
    src = open(a.path, encoding='utf8').read()
    sites = weak_sites(src)
    print(f"{a.path}: {len(sites)} weak site(s)")
    if not sites: return 0

    via = a.via or owning_entrypoint(a.path)
    if not via:
        print("  no gate entrypoint loads this file -- cannot harvest"); return 1
    print(f"  probing via {via}")

    probe = src
    for off, end2 in sorted(sites, reverse=True):
        probe = probe[:end2] + f' "{SENT}"' + probe[end2:]   # INLINE: line numbers unchanged
    bak = src
    open(a.path, 'w', encoding='utf8').write(probe)
    try:
        out = subprocess.run([PACT, via], capture_output=True, text=True)
        blob = out.stdout + out.stderr
    finally:
        open(a.path, 'w', encoding='utf8').write(bak)

    base = os.path.basename(a.path)
    # Pact prefixes the failure with `<path>:<line>:<col>-…:FAILURE: …`, and reports the line the
    # FORM starts on -- which can be one off from the offset of `(expect-failure` when the form
    # is split across lines. Tolerate +/-1 rather than pretending to know which.
    pat = re.compile(re.escape(base) + r":(\d+):[^\n]*?expected error message '"
                     + re.escape(SENT) + r"', got '(.*)$", re.M)
    byline = {int(l): g.rstrip("'\"") for l, g in pat.findall(blob)}
    lines = {off: src[:off].count(chr(10)) + 1 for off, _ in sites}
    # Pact reports the line the FORM starts on, which is consistently offset from the offset of
    # `(expect-failure` for a given file -- but NOT necessarily by zero. The first version tried
    # each site at n, n-1, n+1 independently. That is unsound when two forms sit close together:
    # in [6.2+3]_DPTF-SWP the +/-1 slop let one site claim its NEIGHBOUR's message, and the two
    # assertions ended up shifted by one. It passed every check the tool had, and only the gate
    # caught it -- across 26 entrypoints, from two bad lines in one file.
    #
    # So: find the ONE offset that explains the most sites, then require every site to match at
    # exactly that offset. A file where they do not all agree is left alone rather than guessed.
    def offset_score(d):
        return sum(1 for off, _ in sites if lines[off] + d in byline)
    best = max((-1, 0, 1), key=offset_score)
    if offset_score(best) != len(sites):
        print(f"  line offsets do not agree ({offset_score(best)}/{len(sites)} at {best:+d}) "
              f"-- refusing to guess; file left unchanged")
        return 1
    hit = [(off, end2, byline[lines[off] + best]) for off, end2 in sites]

    if not hit:
        seq = re.findall(r"expected error message '" + re.escape(SENT) + r"', got '(.*)$",
                         blob, re.M)
        if len(seq) == len(sites):
            print(f"  (no path:line prefixes in output -- attributing {len(seq)} by source order)")
            hit = [(off, end2, g) for (off, end2), g in zip(sorted(sites), seq)]
    print(f"  harvested {len(hit)} of {len(sites)} real messages")
    for off, _e, g in hit[:6]:
        print(f"    line {lines[off]:5d}  {trim(g)!r}")
    if not hit:
        print("  nothing harvested -- file left unchanged"); return 1
    if not a.apply:
        print("  (dry run; pass --apply)"); return 0
    # SAFETY NET, not a habit: whatever trim() returns must be a genuine SUBSTRING of the real
    # message, or the assertion cannot possibly match. The first trim() blanked quotes instead of
    # cutting at them and produced 169 messages that matched nothing; the gate caught it across
    # 29 entrypoints. Checking the invariant here makes that class of bug impossible rather than
    # fixed once.
    bad = [(lines[off], trim(g)) for off, _e, g in hit if trim(g) not in g or len(trim(g)) < 8]
    if bad:
        print("  REFUSING to apply -- trimmed message is not a substring of the real one:")
        for l, t in bad[:5]: print(f"    line {l}: {t!r}")
        return 1
    new = src
    for off, end2, g in sorted(hit, key=lambda x: -x[0]):
        new = new[:end2] + f'\n{" " * 16}{lit(trim(g))}' + new[end2:]
    open(a.path, 'w', encoding='utf8').write(new)
    print("  APPLIED")
    return 0

sys.exit(main())

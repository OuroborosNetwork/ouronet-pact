#!/usr/bin/env python3
"""ENFORCE COVERAGE (plan step 3.2) — which guards has a test actually PINNED?

    cd REPL && python3 _enforce_coverage.py [--module M] [--list]

G2 asks "is the guard we wrote working?" and is enumerable from the `enforce` statements. The
ledger cannot answer it: it credits assertions by TRANSACTION BLOCK, so an `expect-failure`
anywhere in a block counts for every op called in that block. That measures a neighbourhood, not
a guard.

This measures the guard directly, and it only became possible after 3.1: now that negative tests
carry the REAL message, an `enforce`'s own message text is the join key. If some
`expect-failure`'s expected-message is a substring of an `enforce`'s message, that test pins THAT
enforce and no other.

MATCHING AGAINST `(format …)` MESSAGES: the template's literal segments are fixed and its `{}`
holes are not, so only the literal runs can be matched. The longest literal segment of >= 12
characters is used; a template with no such segment is reported as UNMATCHABLE rather than
counted either way -- an honest third category instead of a guess.
"""
import argparse, collections, glob, os, re, sys

os.chdir(os.path.dirname(os.path.abspath(__file__)))
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

MEMBER  = re.compile(r'^\s{1,8}\((defun|defcap|defpact)\s+([^\s()]+)', re.M)
# An enforce plus the first string literal that follows it, within a bounded window.
#
# THE LOOKAHEAD IS LFAD-BEARING. `\b` after `enforce` matches inside `enforce-guard` too --
# `-` is a non-word character, so the boundary is right there. That silently pulled all 136
# `(enforce-guard g)` sites into the denominator and handed each one whatever string literal
# happened to follow within 900 characters, which is a MIS-ATTRIBUTED message: enforce-guard
# takes no message at all, Pact generates the keyset-failure text itself. Some of those
# borrowed strings then matched a real test's expected-message and were counted as PINNED.
# `(?![-\w])` keeps `enforce` and `enforce-one` and excludes every hyphenated relative.
ENF_HEAD = re.compile(r'\((enforce|enforce-one)(?![-\w])')


def _args(src, i):
    """Top-level argument slices of the form starting at src[i] == '(' .

    Handles the three argument shapes Pact actually uses here: a bare string, a bracketed group
    ( ) or [ ], and a bare atom. The first cut checked `c == '"'` in the string-skip branch
    BEFORE the atom branch, so a bare `"message"` argument was consumed as noise and never
    emitted -- which is why the rewrite initially found 284 sites instead of 866.
    """
    n, j, out = len(src), i + 1, []
    while j < n:
        c = src[j]
        if c.isspace(): j += 1; continue
        if c == ')': return out, j
        start = j
        if c == '"':
            j += 1
            while j < n and src[j] != '"': j += 2 if src[j] == '\\' else 1
            j += 1
        elif c in '([':
            d, ins, esc = 0, False, False
            while j < n:
                ch = src[j]
                if ins:
                    if esc: esc = False
                    elif ch == '\\': esc = True
                    elif ch == '"': ins = False
                elif ch == '"': ins = True
                elif ch in '([': d += 1
                elif ch in ')]':
                    d -= 1
                    if d == 0: j += 1; break
                j += 1
        else:
            while j < n and not src[j].isspace() and src[j] not in '()[]"': j += 1
        out.append(src[start:j])
    return out, n



_STR = re.compile(r'"((?:[^"\\]|\\.)*)"', re.S)


def enforce_sites(src):
    """(start_offset, kind, message) for every enforce / enforce-one.

    Takes the MESSAGE ARGUMENT by position instead of the first quoted run after the head:
    `enforce` -> arg[1], `enforce-one` -> arg[0]. The old regex grabbed the first string it saw,
    so any enforce whose PREDICATE contains a string literal -- 28 of them, e.g.
    `(enforce (not (contains ftc ["R|" "F|"])) (format "..." [...]))` -- had its message read as
    `']))\n (format '`. Those sites could never match a test's expected message, so they were
    permanently counted as unpinned no matter what any test asserted.
    """
    for m in ENF_HEAD.finditer(src):
        args, _end = _args(src, m.start())
        args = args[1:]          # drop the operator symbol itself ('enforce' / 'enforce-one')
        want = args[0] if m.group(1) == "enforce-one" else (args[1] if len(args) > 1 else None)
        if not want: continue
        sm = _STR.search(want)                 # bare "msg" or the format string inside (format "msg" [..])
        if sm and len(sm.group(1)) >= 4: yield m.start(), m.group(1), sm.group(1)

def enforce_one_spans(src):
    """(start, end) of every (enforce-one …) form, balanced, string-aware."""
    spans = []
    for m in re.finditer(r'\(enforce-one\b', src):
        i, d, j, instr, esc = m.start(), 0, m.start(), False, False
        while j < len(src):
            c = src[j]
            if instr:
                if esc: esc = False
                elif c == '\\': esc = True
                elif c == '"': instr = False
            elif c == '"': instr = True
            elif c == '(': d += 1
            elif c == ')':
                d -= 1
                if d == 0: break
            j += 1
        spans.append((i, j))
    return spans

def _seg_match(txt, seg):
    """Does an expected-message match this literal segment of a guard's format string?

    Segments come from splitting on `{}` holes, so they carry the surrounding whitespace:
    "{} {} must be set to {} for exec" yields " must be set to ". A test expecting
    "must be set to true for exec" contains neither that segment nor is contained by it, and the
    raw two-way substring test therefore missed it. Compare on the STRIPPED segment, and keep a
    length floor so short connectives cannot match everything.
    """
    seg = seg.strip()
    if len(seg) < 4: return False
    return seg in txt or txt in seg


def literal_segments(msg):
    """The fixed runs of a (format …) template: everything between the {} holes."""
    return [p for p in re.split(r'\{\}', msg) if len(p.strip()) >= 12]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--module"); ap.add_argument("--list", action="store_true")
    ap.add_argument("--orphans", action="store_true",
                    help="negative-test assertions that match NO source guard (matcher audit)")
    ap.add_argument("--ambiguous", action="store_true",
                    help="list every TEST assertion whose expected message matches sites in >1 module")
    a = ap.parse_args()

    files = [f for f in sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                               + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
             if "/Audit/" not in f]
    # ATTRIBUTION BY MODULE REFERENCE, not by message text alone.
    # 90 sites had NO module-unique wording -- DPOF/DPMF/DPTF/DPDC are four implementations of the
    # same token contract and their guard messages are copy-pasted. No expected-string can single
    # one out, so text matching credited all four for any one test. But the TEST already names its
    # module: `(ref-DPTF::UEV_CanWipeON b)`. Reading that ref makes attribution exact without
    # touching a single source message, which would have been the tail wagging the dog.
    MODFILE = {}
    for _f in files:
        for _m in re.findall(r'^\(module\s+([A-Za-z0-9|_-]+)', open(_f, encoding='utf8', errors='ignore').read(), re.M):
            MODFILE.setdefault(_m, os.path.basename(_f))
    REFBIND = re.compile(r'\((ref-[A-Za-z0-9|_-]+):module\{[A-Za-z0-9|_-]+\}\s+([A-Za-z][A-Za-z0-9|_.-]*)\)')
    USEREF  = re.compile(r'\(\s*(ref-[A-Za-z0-9|_-]+)::|\(\s*([A-Z][A-Za-z0-9|_-]*)\.[A-Za-z]')

    # --- every expected-message a negative test pins -------------------------------------------
    # The first version required the message to sit on its OWN line (`"…"` followed by a
    # newline). Nine assertions written inline -- `"cannot be wiped" (ref-DPTF::UEV_CanWipeON b))`
    # -- were invisible to it, so a real coverage gain read as almost none and nearly got the
    # whole guard-family approach discarded. Extract the THIRD ARGUMENT structurally instead of
    # pattern-matching the layout.
    pinned, pinned_src = [], []
    for f in glob.glob("**/*.repl", recursive=True):
        if f.startswith("archive" + os.sep): continue
        src = open(f, encoding='utf8', errors='ignore').read()
        _local = {v: mod for v, mod in REFBIND.findall(src)}
        for m in re.finditer(r'\(expect-failure[\s\n]', src):
            # walk the form; collect top-level string literals. arg2 = doc, arg3 = expected msg.
            depth, i, n, strs, cur, in_str, esc = 0, m.start(), len(src), [], None, False, False
            while i < n:
                c = src[i]
                if in_str:
                    if esc: esc = False
                    elif c == '\\': esc = True
                    elif c == '"':
                        in_str = False
                        if depth == 1: strs.append(cur)
                        cur = None
                    if in_str and cur is not None: cur += c
                elif c == '"': in_str = True; cur = ''
                elif c == '(': depth += 1
                elif c == ')':
                    depth -= 1
                    if depth == 0: break
                i += 1
            _form = src[m.start():i+1]
            _mods = set()
            for _rv, _dot in USEREF.findall(_form):
                _mod = _local.get(_rv) if _rv else _dot
                if _mod and _mod in MODFILE: _mods.add(MODFILE[_mod])
            if len(strs) >= 2:
                _p = strs[1].replace('\\"', '"').replace('\\\\', '\\')
                pinned.append((_p, frozenset(_mods)))
                pinned_src.append((f, src[:m.start()].count('\n') + 1, _p, frozenset(_mods)))
    pinned = [x for x in pinned if len(x[0]) >= 8]
    pinned_src = [x for x in pinned_src if len(x[2]) >= 8]

    # Module refs DISAMBIGUATE among text matches; they do not hard-filter. A first cut used them
    # as a filter and coverage fell 333 -> 173, because a test driven through Talos names
    # `ref-TS02-C3::`, not the core module whose guard actually fires -- so every Talos-mediated
    # pin lost its attribution. The rule that works: if a test DIRECTLY references one or more of
    # the modules its text matches, believe that and drop the rest; if it references none of them
    # (the Talos case), fall back to plain text matching.
    _txtmods = {}                       # built lazily: `sites` does not exist yet at this point

    def _scope(t, mods):
        """Modules this expected-string may be credited to."""
        if not _txtmods:
            for _r in sites:
                for _k in set(pinned):
                    if any(_seg_match(_k[0], sg) for sg in literal_segments(_r[3])):
                        _txtmods.setdefault(_k, set()).add(os.path.basename(_r[0]))
            _txtmods.setdefault(("", frozenset()), set())     # ensure non-empty sentinel
        cand = _txtmods.get((t, mods), set())
        direct = cand & mods
        return direct if direct else cand

    def _hits(rec):
        segs = literal_segments(rec[3]); base = os.path.basename(rec[0])
        return [(t, mo) for t, mo in set(pinned)
                if any(_seg_match(t, sg) for sg in segs) and base in _scope(t, mo)]

    # --- every enforce site --------------------------------------------------------------------
    # DEAD MODULES — counted, reported, but kept OUT of the P3.3 worklist. Pinning a guard that
    # no caller can reach is not coverage, it is ceremony. Each entry needs a reason and a check
    # that the reason still holds; this is not a place to park anything merely inconvenient.
    #
    #   00_DPMF  the original MetaFungible, superseded by DPOF (CLAUDE.md § "Historical note").
    #            It IS deployed by [2.2]_Core -- it has to be, for migration provenance -- but
    #            grep finds exactly ONE call anywhere in the tree: P|A_Define, the policy
    #            boilerplate every module carries. No business function is reached by any module
    #            or any test. Owner's standing instruction: leave DPMF alone, it is dead code.
    DEAD = {"00_DPMF.pact": "superseded by DPOF; deployed for provenance, never called"}


    # UNREACHABLE BY CONSTRUCTION, third kind: an enforce inside a defcap that is NEVER ACQUIRED
    # anywhere in its own module. A Pact capability is module-scoped -- `(with-capability (X ...))`
    # binds the X defined in the CALLING module -- so a defcap no one in that module acquires can
    # never run, and neither can its guards. AQP-RPS carries nine FVT|C>* defcaps (281 lines, 19
    # enforce sites) that were left behind when those caps moved to AQP-FVT; FVT defines and
    # acquires its own copies. Counting them as "unpinned" put 19 impossible items on the P3.3
    # worklist -- the same distortion the {}-hole and enforce-one categories exist to prevent.
    def _strip_str(t):
        out, i, n, ins, esc = [], 0, len(t), False, False
        while i < n:
            c = t[i]
            if ins:
                if esc: esc = False
                elif c == '\\': esc = True
                elif c == '"': ins = False
                out.append(' ')
            elif c == '"': ins = True; out.append(' ')
            else: out.append(c)
            i += 1
        return ''.join(out)

    DEAD_CAPS = {}
    for _f in files:
        _src = open(_f, encoding='utf8', errors='ignore').read()
        _body = _strip_str(_src)
        _gov = set(re.findall(r'^\(module\s+[A-Za-z0-9|_-]+\s+([A-Za-z0-9|_-]+)', _src, re.M))
        for _c in re.findall(r'^\s{1,8}\(defcap\s+([A-Za-z0-9|_>()-]+)', _src, re.M):
            if _c in _gov: continue
            if re.search(r'\((?:with|require|compose)-capability\s+\(\s*' + re.escape(_c) + r'[\s)]', _body):
                continue
            DEAD_CAPS.setdefault(os.path.relpath(_f, ROOT), set()).add(_c)

    sites, covered, unmatchable, nested, deadcap, annotated, untestable = [], [], [], [], [], [], []
    for f in files:
        raw = open(f, encoding='utf8', errors='ignore').read()
        # UNREACHABLE BY CONSTRUCTION, fourth kind: PROVEN BY HAND and annotated at the site.
        # The three kinds above are structural -- the tool can see an enforce-one span or a
        # never-acquired defcap on its own. This kind cannot be derived from the source: it takes
        # reading two callers and noticing that a stricter guard upstream already answered, or
        # that two writes are atomic so their disagreement is unconstructible.
        #
        # Trusting a COMMENT is obviously abusable -- a line of prose could otherwise delete work
        # from the worklist -- so this category is deliberately NEVER folded into PINNED. It is
        # reported on its own line and subtracted only from the WORKLIST, which is the number
        # that answers "what is left to write". Coverage percentages are unaffected. Each marker
        # claims exactly ONE enforce (the next one below it), so an annotation cannot silently
        # spread across a family.
        _unreach = [i + 1 for i, ln in enumerate(raw.split('\n'))
                    if re.match(r'\s*;+\s*UNREACHABLE\b', ln)]
        # SECOND, DISTINCT category. ;;UNTESTABLE-EXTERNALLY is NOT ;;UNREACHABLE and the two must
        # never be merged. UNREACHABLE means NO INPUT can trip the guard -- it is dead in
        # production. UNTESTABLE-EXTERNALLY means the guard is LIVE and does real work in
        # production, but a REPL cannot reach it: the body sits behind (require-capability SECURE)
        # and SECURE cannot be acquired from outside its own module. Counting those as dead would
        # claim guards are pointless when they are simply out of a test harness's reach.
        _untest = [i + 1 for i, ln in enumerate(raw.split('\n'))
                   if re.match(r'\s*;+\s*UNTESTABLE-EXTERNALLY\b', ln)]
        src = strip_comments(raw)
        owners = [(m.start(), m.group(2)) for m in MEMBER.finditer(src)]
        eo = enforce_one_spans(src)
        for _off, _kind, msg in enforce_sites(src):
            owner = next((n for off, n in reversed(owners) if off < _off), "?")
            line = src[:_off].count('\n') + 1
            # FULL message, not msg[:70]. The truncation was for display, but MATCHING used the
            # same field -- so any guard whose message runs past 70 characters could only be
            # pinned by an expectation lying inside that prefix. Two SCORE validators had passing
            # negative tests that the tool refused to credit for exactly this reason. Truncation
            # now happens only where it is printed.
            rec = (os.path.relpath(f, ROOT), line, owner, msg)
            # UNREACHABLE BY CONSTRUCTION: an enforce nested inside an enforce-one branch list.
            # Pact tries each branch and, when every one fails, raises the enforce-one's OWN
            # message -- the inner messages are never surfaced. Verified rather than assumed:
            #
            #   (enforce-one "OUTER" [(enforce false "INNER-ONE") (enforce false "INNER-TWO")])
            #   => expected error message 'INNER-ONE', got 'OUTER-MESSAGE'
            #
            # So these messages document intent inside the branch list and nothing more. No
            # caller can see them and no test can pin them. Counting them as "unpinned" inflates
            # the worklist with work that cannot be done -- the same reason the {}-holes category
            # exists. The enforce-one's own message IS matchable and is counted normally.
            # ...and the same is true of a nested enforce-one's OWN message. Only the
            # OUTERMOST enforce-one in a nest can ever surface. Verified the same way:
            #
            #   (enforce-one "OUTER-MSG" [(enforce-one "INNER-MSG" [(enforce false "deep")])])
            #   => expected error message 'SHOW-ME', got 'OUTER-MSG'
            #
            # DALOS GAS_PAYER is the live case: "First form must be coin.C_, ouronet-ns.TS, or
            # ouronet-ns.DSP" is an enforce-one sitting inside the "Payable Modules / form count
            # not satisfied" enforce-one, and DALOS-G2c proves the outer message is what a caller
            # sees. The original condition tested `_kind == "enforce"` only, so nested
            # enforce-ones stayed on the worklist as unreachable busywork.
            # A span does not contain ITSELF here (comparison is strict), so a top-level
            # enforce-one is still counted normally.
            if any(a < _off < b for a, b in eo):
                nested.append(rec); continue
            if owner in DEAD_CAPS.get(os.path.relpath(f, ROOT), ()):
                deadcap.append(rec); continue
            # the nearest marker ABOVE this enforce, WITHIN 12 LINES and with no other enforce
            # between them. The distance cap is the important half: without it a marker could
            # claim an enforce a thousand lines below it if nothing matchable sat in between,
            # which is exactly the accident that would let one annotation quietly retire an
            # unrelated guard. 12 lines is enough for a marker + a @doc + a signature.
            _m = [c for c in _unreach if c < line <= c + 12]
            if _m and not any(_m[-1] < l2 < line for _f2, l2, _o2, _g2 in sites
                              if _f2 == os.path.relpath(f, ROOT)):
                annotated.append(rec); _unreach.remove(_m[-1]); continue
            _mu = [c for c in _untest if c < line <= c + 12]
            if _mu and not any(_mu[-1] < l2 < line for _f2, l2, _o2, _g2 in sites
                               if _f2 == os.path.relpath(f, ROOT)):
                untestable.append(rec); _untest.remove(_mu[-1]); continue
            segs = literal_segments(msg)
            if not segs:
                unmatchable.append(rec); continue
            sites.append(rec)

    # SECOND PASS. `covered` cannot be computed inside the collection loop: attribution needs the
    # COMPLETE site list to know which modules a given expected-string could match, and computing
    # it mid-loop scoped every string against a partially-built list (coverage read as 1).
    covered = [r for r in sites if _hits(r)]

    # A site is only honestly pinned when at least ONE assertion covering it is UNIQUE to its
    # module. A site covered solely by a 7-module substring ("must be set to" matches 37 sites in
    # 7 modules from one assertion) is not evidence that THIS module's guard was ever exercised.
    # Computed unconditionally and printed in the headline: the flattering number must not be the
    # easy one to quote. Reported 40% for several passes before this was measured; it is 24%.
    _strmods = {k: _scope(*k) for k in set(pinned)}
    honest = sum(1 for r in sites
                 for _ms in [_hits(r)]
                 if _ms and not all(len(_strmods[k]) > 1 for k in _ms))

    # WITHIN-MODULE SHARING. `honest` above disambiguates wording shared ACROSS modules -- it
    # asks whether some covering assertion is unique to this site's module. It says nothing about
    # N sites INSIDE one module that carry identical text: one assertion credits all N, and N-1 of
    # those credits are nominal. Found while pinning FVT, where "pool stake disabled or has no
    # employed scores" sits at three sites (one per stake flow) and only one is ever driven.
    #
    # Reported as its own line rather than folded into the headline. Folding it in would need a
    # site-level attribution the tool does not have (the expected string is all it can match on),
    # so the number below is an UPPER BOUND on the over-count, not a corrected figure.
    # The bound must COUNT ASSERTIONS, not just sites. N sites sharing one message inside a module
    # are over-credited only to the extent that fewer than N distinct assertions match them: three
    # sites driven by three separate assertions are all genuinely exercised, even though the tool
    # cannot say which assertion hit which site. Counting sites alone made the number GROW as the
    # duplicates got properly driven, which is exactly backwards.
    _bymod = collections.defaultdict(list)
    for r in sites:
        if _hits(r): _bymod[(r[0], r[3])].append(r)
    # Count DISTINCT ASSERTIONS from pinned_src (file+line), not distinct expected-STRINGS.
    # _hits keys on the expected text, so three separate assertions written with the same wording
    # collapse to one entry there -- and driving all three sites properly would not move the bound
    # at all. Assertion identity is what makes the work visible.
    _dupcredit = 0
    for (_f, _msg), v in _bymod.items():
        if len(v) < 2: continue
        _segs = literal_segments(_msg)
        _base = os.path.basename(_f)
        _asserts = {(tf, tl) for tf, tl, txt, tmods in pinned_src
                    if any(_seg_match(txt, sg) for sg in _segs) and _base in _scope(txt, frozenset(tmods))}
        _dupcredit += max(0, len(v) - len(_asserts))

    tot = len(sites)
    print(f"ENFORCE COVERAGE — {len(files)} modules\n")
    print(f"  enforce sites with a matchable message : {tot}")
    print(f"  PINNED by a negative test              : {len(covered)} "
          f"({100*len(covered)//max(tot,1)}%)")
    print(f"  ...UNAMBIGUOUSLY (a module-unique message): {honest} "
          f"({100*honest//max(tot,1)}%)   <- the honest figure; see --ambiguous")
    print(f"  ...of those, credited via text shared WITHIN one module: {_dupcredit} "
          f"(upper bound on over-count; see the note in the source)")
    print(f"  not pinned                             : {tot - len(covered)}")
    print(f"  message is all {{}} holes (unmatchable) : {len(unmatchable)}")
    print(f"  nested in an enforce-one (UNREACHABLE)  : {len(nested)}")
    print(f"  inside a NEVER-ACQUIRED defcap (UNREACHABLE): {len(deadcap)}")
    print(f"  LIVE but UNTESTABLE from a REPL (protected body): {len(untestable)}"
          f"   <- real guards behind require-capability; not dead, just out of reach")
    for _r in untestable:
        print(f"      {_r[0]}:{_r[1]}  {_r[2]}  — {_r[3][:52]}")
    print(f"  PROVEN unreachable by hand + annotated  : {len(annotated)}"
          f"   <- NOT counted as pinned; removed from the worklist only")
    for _r in annotated:
        print(f"      {_r[0]}:{_r[1]}  {_r[2]}  — {_r[3][:52]}")
    print(f"  distinct expected-messages in the suite: {len(set(t for t, _ in pinned))}")

    # PRECISION CAVEAT, measured rather than asserted. Attribution is by MESSAGE TEXT, and some
    # messages are worded identically in several modules -- "must be set to" appears in 7,
    # "cannot be wiped" in 4. Pinning one module's copy therefore credits every module's copy,
    # so PINNED is an upper bound for those. Quoting the headline without this number is the
    # same mistake as quoting coverage without its gated companion (RULE 11).
    allsegs = collections.defaultdict(set)
    for f in files:
        s2 = strip_comments(open(f, encoding='utf8', errors='ignore').read())
        for _off, _k2, _msg in enforce_sites(s2):
            for seg in literal_segments(_msg):
                allsegs[seg.strip()].add(os.path.basename(f))
    shared = sum(1 for v in allsegs.values() if len(v) > 1)
    amb = len(covered) - honest
    if a.orphans:
        # MATCHER AUDIT. Every expect-failure in the suites asserts a message the code is supposed
        # to produce. If an assertion matches NO source guard, exactly one of two things is true:
        # the message drifted (a stale test that still passes because the NEW message also fails),
        # or the matcher is dropping it -- which is how the msg[:70] truncation bug hid two SCORE
        # guards. Either way it is worth knowing; a passing test proves nothing about WHICH guard.
        print("\n  ORPHAN ASSERTIONS — expect-failure text matching no guard in the source:\n")
        orph = [(tf, tl, txt) for tf, tl, txt, _m in pinned_src
                if not any(_seg_match(txt, sg)
                           for r in sites for sg in literal_segments(r[3]))]
        for tf, tl, txt in sorted(orph):
            print(f"    {tf}:{tl}\n        {txt[:80]!r}")
        print(f"\n    {len(orph)} of {len(pinned_src)} assertions match no source guard.")
        return 0
    if a.ambiguous:
        # WHICH assertion is ambiguous, not just how many. The aggregate count told me 112 sites
        # were credited via shared wording but not which of MY tests caused it -- and I shipped
        # one ("distinct new owner-konto", matching both SCORE's and FVT's rotate guard) before
        # noticing. This is that check, made runnable.
        print("\n  AMBIGUOUS TEST ASSERTIONS — one expected-message, sites in several modules:\n")
        rows = []
        for tf, tl, txt, tmods in pinned_src:
            hit = collections.defaultdict(list)
            _sc = _scope(txt, tmods)
            for rec in sites:
                b = os.path.basename(rec[0])
                if b not in _sc: continue
                if any(_seg_match(txt, seg) for seg in literal_segments(rec[3])):
                    hit[b].append(rec[1])
            if len(hit) > 1: rows.append((len(hit), tf, tl, txt, dict(hit)))
        for n_mod, tf, tl, txt, hit in sorted(rows, reverse=True):
            print(f"    {tf}:{tl}")
            print(f"        expects  {txt[:78]!r}")
            print(f"        matches  {n_mod} modules: " +
                  ", ".join(f"{k}({len(v)})" for k, v in sorted(hit.items())))
        print(f"\n    {len(rows)} of {len(pinned_src)} assertions are ambiguous.")

        # THE NUMBER THAT MATTERS: a site is only honestly pinned if at least ONE assertion that
        # covers it is unique to its module. A site covered solely by a 7-module substring like
        # "must be set to" is not evidence that THIS module's guard was exercised.
        # Can a BETTER TEST fix it, or is the message itself indistinguishable? A site is
        # pinnable-by-message only if some literal segment of its template appears in NO other
        # module. Where every segment is shared with a sibling, no expected-string can single it
        # out -- that is a property of the SOURCE wording, not of the test, and it belongs in the
        # same bucket as {}-holes and enforce-one nesting rather than on the worklist.
        segmods = collections.defaultdict(set)
        for r in sites:
            for sg in literal_segments(r[3]):
                if len(sg.strip()) >= 4: segmods[sg.strip()].add(os.path.basename(r[0]))
        fixable = hopeless = 0
        hope_by_mod = collections.Counter()
        for r in sites:
            ms = _hits(r)
            if not ms or not all(len(_strmods[k]) > 1 for k in ms): continue   # honestly pinned
            uniq = any(len(segmods.get(sg.strip(), ())) == 1
                       for sg in literal_segments(r[3]) if len(sg.strip()) >= 4)
            if uniq: fixable += 1
            else:
                hopeless += 1; hope_by_mod[os.path.basename(r[0])] += 1
        print(f"\n    of the falsely-pinned sites:")
        print(f"      a TIGHTER TEST could pin them (module-unique wording exists) : {fixable}")
        print(f"      NO module-unique wording -- unpinnable BY MESSAGE            : {hopeless}")
        for m, c in hope_by_mod.most_common(8): print(f"          {c:3d}  {m}")
        print(f"\n    sites counted as PINNED                 : {len(covered)}")
        print(f"    ...pinned ONLY by an ambiguous assertion: {len(covered)-honest}")
        print(f"    UNAMBIGUOUSLY pinned                    : {honest} "
              f"({100*honest//max(len(sites),1)}% of {len(sites)}) <- the honest figure")
        return 0
    print(f"  ...of which pinned only via wording SHARED across modules: {amb} "
          f"({shared}/{len(allsegs)} segments are non-unique) -- PINNED is an upper bound\n")

    cov = {(f, l) for f, l, _, _ in covered}
    gaps = [r for r in sites if (r[0], r[1]) not in cov]
    per = collections.Counter(r[0].split('/')[-1] for r in gaps)
    dead_n = sum(c for f, c in per.items() if f in DEAD)
    if dead_n:
        print(f"\n  of the unpinned, {dead_n} sit in DEAD modules and are NOT worklist items:")
        for f, why in DEAD.items():
            if per.get(f): print(f"    {per[f]:4d}  {f}  — {why}")
        print(f"  LIVE unpinned (the real worklist total): {sum(per.values()) - dead_n}")

    print("\nunpinned enforce sites by module (the P3.3 worklist):")
    for f, c in per.most_common(20 if not a.list else 999):
        if f in DEAD: continue
        print(f"  {c:4d}  {f}")
    if a.list:
        print()
        for f, l, o, msg in gaps:
            if a.module and a.module not in f: continue
            print(f"  {f}:{l}  {o}\n        {msg}")
    return 0

sys.exit(main())

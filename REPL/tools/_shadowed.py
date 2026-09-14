#!/usr/bin/env python3
"""SHADOWED GUARDS — enforces that can never fire because a hard read runs first.

    cd REPL && python3 _shadowed.py [--list]

THE SHAPE (found 7x during P2/P3 before it was ever looked for):

    (defun UEV_SetClass (id:string son:bool set-class:integer)
        (let ((sc:integer (UR_SetClass id son set-class)))   ;; HARD read, eager, runs FIRST
          (enforce (> set-class 0) "Invalid Set-Class Value")
          (enforce (= set-class sc) "Invalid DPDC Set Data")))

A `let` binding is eager and UR_SetClass bottoms out in a plain `read`, so every input the two
guards were written to reject has ALREADY aborted inside the table read. When the row exists,
both pass trivially. Neither can ever fire, and the caller gets
`No value found in table ... for key: TSFS-...|0` -- the row key, not the rule.

TWO CONDITIONS, and the second is what makes this worth automating.

  1. THE VALIDATED ARGUMENT IS ALSO A READ KEY. Not merely "a read happens first": 252
     members read before their first enforce, and almost all are benign. UEV_CanChangeOwnerON
     reads the TOKEN's flag and enforces on the RESULT -- the guard's reject domain (flag is
     off) is disjoint from the read's failure domain (token absent). It is only dangerous when
     the argument being VALIDATED is itself part of the key being READ, because then an
     invalid argument makes the read fail before the guard sees it. That test alone: 252 -> 25.

  2. THE READER MUST BE HARD. A `with-default-read` returns a default and the guard fires
     normally. DPTF|S>SET_FEE-TARGET reads DALOS::UR_AccountType on the target it is about to
     validate -- condition 1 -- but UR_AccountProperties underneath is a with-default-read, so
     a non-existent target flows through to UEV_EnforceAccountExists and gets the right
     message. A real false positive, correctly dropped by this check.

Resolution is TRANSITIVE: UR_NonceValue -> UR_NonceElement -> (read ...) is hard;
UR_AccountType -> UR_AccountProperties -> (with-default-read ...) is soft. Readers that cannot
be resolved are reported separately rather than guessed at.

Still a CANDIDATE list, not a defect count. TWO known false-positive shapes, both requiring a
human to close:

  DISJOINT REJECT DOMAIN. The guard survives when what it rejects is not what the read fails
  on. UEV_StandardAccOwn is flagged -- it reads the account row and validates <account> -- but
  it rejects a SMART account, which EXISTS, so the read never fails for the case the guard is
  actually for.

  DIFFERENT TABLE, SAME KEY. This matcher works on ARGUMENT NAMES, not tables. FVT|C>TOGGLE-
  REWARD-LINK reads UR_FVT|OwnerKonto on <fvt-id> and then guards "Reward link row must exist"
  -- but that is a DIFFERENT table also keyed by <fvt-id>. The FVT existing and the link
  existing are independent, so the guard is perfectly reachable. Every FVT|/RPS row in the
  output is likely this shape.

  The rows that matter are the ones where the read and the guard concern the SAME ROW -- the
  guard's message asserts the existence or shape of the very entity the read just fetched.
  All three confirmed-dead cases are that shape:

      DPDC-S::UEV_SetClass   reads SetsTable[id|set-class], guards that set-class
      DPDC::UEV_Nonce        reads the nonce row,           guards that nonce
      DEMIPAD|C>WITHDRAW     reads UR_Funds[asset|type],    guards that type

KNOWN BLIND SPOTS — stated because "14 candidates" must not be read as "14 problems, found
exhaustively". This tool finds a SUBSET.

  CROSS-MEMBER. It works per-member, and Ouronet's own architecture puts the read and the guard
  in DIFFERENT members: a C_ binds a reader, then opens a capability whose defcap holds all the
  validation (CLAUDE.md, "Client flow shape"). A separate scan for that shape finds 6 more
  (02_SCORE x2, 05_FVT x3, 06_VCT x1).

  LET-BOUND ALIASES IN THE CONDITION. The guard's predicate is frequently a bound boolean, not
  the argument itself -- `(enforce iz-type "Invalid Withdrawal type")` where
  `iz-type = (contains type [1 2 3])`. The argument match then fails.

  THOSE TWO TOGETHER MISS A CONFIRMED CASE. DEMIPAD::C_Withdraw reads UR_Funds on <asset-id,
  type> and then opens DEMIPAD|C>WITHDRAW, whose type enforce is provably dead -- and this tool
  does not report it, because the read is in the defun, the guard is in the defcap, and the
  condition is the alias iz-type. It was found by hand. Treat the output as a lead list.

  So: 3 confirmed dead, of which this tool independently predicts 2.

  Teaching the matcher to resolve aliases and to follow with-capability into the defcap would
  close both. Until then the point is to hand a human 14 rows instead of 889.
"""
import argparse, collections, glob, os, re, sys

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

FILES = [f for f in sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                           + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
         if "/Audit/" not in f]
SRC = {f: strip_comments(open(f, encoding='utf8', errors='ignore').read()) for f in FILES}

MEMBER = re.compile(r'^\s{1,8}\((defun|defcap)\s+([^\s()]+)', re.M)

def members(src):
    lines = src.split('\n')
    idx = [i for i, l in enumerate(lines) if re.match(r'^\s{1,8}\((defun|defcap)\s', l)]
    idx.append(len(lines))
    for a, b in zip(idx, idx[1:]):
        m = re.match(r'^\s{1,8}\((defun|defcap)\s+([^\s():]+)', lines[a])
        # NOTE the ':' in the character class -- a signature is `(defun UR_NonceValue:integer …)`
        # and keeping the return type made every reader name miss its own body, which reported
        # all 25 candidates as "unresolved" instead of resolving any of them.
        yield m.group(2), a, '\n'.join(lines[a:b])

# ---- reader hardness, resolved transitively ---------------------------------------------------
BODIES = {}
for f in FILES:
    for name, _, body in members(SRC[f]):
        # Interfaces declare `(defun UR_X:integer (args))` with NO body, and they load first, so
        # a plain "first wins" bound every reader to its own stub and resolved nothing. Keep the
        # LONGEST body seen for a name -- the implementation always beats the declaration.
        if name.startswith(('UR_', 'URC_', 'URCv_', 'URCx_')) and len(body) > len(BODIES.get(name, '')):
            BODIES[name] = body

def hardness(name, seen=None):
    """'hard' | 'soft' | 'unknown' — does this reader bottom out in a bare (read …)?"""
    if seen is None: seen = set()
    if name in seen: return 'unknown'
    seen.add(name)
    body = BODIES.get(name)
    if body is None: return 'unknown'
    if re.search(r'\(\s*with-default-read\s', body): return 'soft'
    if re.search(r'\(\s*read\s', body): return 'hard'
    inner = [n for n in re.findall(r'\bUR_[A-Za-z][A-Za-z0-9|_-]*', body) if n != name]
    verdicts = {hardness(n, seen) for n in inner}
    if 'hard' in verdicts: return 'hard'
    if 'soft' in verdicts: return 'soft'
    return 'unknown'

TABLE_READ = re.compile(r'\(\s*(?:with-default-read|with-read|read)\s+([A-Za-z0-9|_-]+)')

def tables(name, seen=None):
    """Which table(s) does this reader ultimately touch? Resolved transitively."""
    if seen is None: seen = set()
    if name in seen: return set()
    seen.add(name)
    body = BODIES.get(name)
    if body is None: return set()
    out = set(TABLE_READ.findall(body))
    for n in re.findall(r'\b(?:UR|URC|URCv|URCx)_[A-Za-z][A-Za-z0-9|_-]*', body):
        if n != name: out |= tables(n, seen)
    return out


CALL = re.compile(r'\((?:ref-[A-Za-z0-9|_-]+::)?(UR_[A-Za-z][A-Za-z0-9|_-]*)\s([^()]*)\)')

def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--list', action='store_true')
    ap.add_argument('--triaged', action='store_true', help='show the hand-triaged verdicts')
    a = ap.parse_args()
    # EVIDENCE BEATS INFERENCE. A guard with a PASSING negative test cannot be dead -- the test
    # is a live demonstration that some input reaches it. Three DALOS candidates
    # (UEV_StandardAccOwn / UEV_SmartAccOwn, "Incompatible Sovereign detected") were flagged as
    # possibly-dead while modules/DALOS-ADMIN.repl has been tripping both of them, green, all
    # along. Cross-referencing the suites removes them automatically instead of costing another
    # manual read each time this runs.
    # ...but message text alone is NOT enough evidence. Sibling modules carry byte-identical
    # guard wording ("Reward link row must exist" lives in RPS and FVT), so a substring match
    # would mark seven guards proven on the strength of one test. Same defect that inflated
    # _enforce_coverage.py from 24% to a claimed 40%. So the test must ALSO name the module:
    # `(ref-FVT::...)` or `(AQP-FVT....)`. Tests that name no module prove nothing here.
    MODFILE = {}
    for _f in FILES:
        for _m in re.findall(r'^\(module\s+([A-Za-z0-9|_-]+)', SRC[_f], re.M):
            MODFILE.setdefault(_m, os.path.basename(_f))
    REFB = re.compile(r'\((ref-[A-Za-z0-9|_-]+):module\{[A-Za-z0-9|_-]+\}\s+([A-Za-z][A-Za-z0-9|_.-]*)\)')
    USEREF = re.compile(r'\(\s*(ref-[A-Za-z0-9|_-]+)::|\(\s*([A-Z][A-Za-z0-9|_-]*)\.[A-Za-z]')

    pinned_msgs = []
    for rf in glob.glob("**/*.repl", recursive=True):
        if rf.startswith("archive" + os.sep): continue
        rsrc = open(rf, encoding='utf8', errors='ignore').read()
        _local = {v: mod for v, mod in REFB.findall(rsrc)}
        for mm in re.finditer(r'\(expect-failure[\s\n]', rsrc):
            d, i2, n2, strs, cur, ins, esc = 0, mm.start(), len(rsrc), [], None, False, False
            while i2 < n2:
                c = rsrc[i2]
                if ins:
                    if esc: esc = False
                    elif c == '\\': esc = True
                    elif c == '"':
                        ins = False
                        if d == 1: strs.append(cur)
                        cur = None
                    if ins and cur is not None: cur += c
                elif c == '"': ins = True; cur = ''
                elif c == '(': d += 1
                elif c == ')':
                    d -= 1
                    if d == 0: break
                i2 += 1
            _form = rsrc[mm.start():i2+1]
            _mods = {MODFILE[m] for rv, dt in USEREF.findall(_form)
                     for m in [(_local.get(rv) if rv else dt)] if m in MODFILE}
            if len(strs) >= 2 and len(strs[1]) >= 8:
                pinned_msgs.append((strs[1], frozenset(_mods)))

    def is_proven(msg, base):
        """Proven only when the wording matches AND the test names this very module."""
        return any((pm in msg or msg in pm) and base in mods for pm, mods in pinned_msgs)

    # BY-HAND VERDICTS, recorded so they are not re-derived every pass. Each was read in full
    # and found REACHABLE: the guard tests a FIELD of a row that exists, not whether the row
    # exists, so the shadowing read never covers its reject domain. That is the discriminator the
    # detector cannot yet see -- an EXISTENCE check under a hard read is dead (both confirmed
    # dead guards were of that kind); a FIELD check is reachable and merely needs a test.
    # Remove an entry to force a re-check if the function changes.
    TRIAGED = {
        ('02_SCORE.pact', 'SCR|C>ENABLE-DEB-BOOST-SCORE'):
            'field check: deb-boost already true, or nzs-count > 0 -- both need an EXISTING score',
        ('02_SCORE.pact', 'SCR|C>CREATE-BOOST-CLASS-LINK-SCORE'):
            'boost-class-id is a separate argument, not the read key -- BAR trips it directly',
        ('02_SCORE.pact', 'UEV_LpStakeScoreContext'):
            'property fold over existing entities (class, aqpool-link, lp-denominator)',
        ('02_SCORE.pact', 'SCR|XI>X_ISSUE-NF-SCORE-DEFINITION'):
            'class-4 conjunct is live; the (= score-row-id score-id) conjunct is a tautology and '
            'is documented in place as a data-integrity assertion',
        ('06_VCT.pact', 'VCT|C>FINALIZE-VACATE'):
            'field check: no vacate in progress / pool not drained -- pool row exists either way',
        ('22_PYTHIA.pact', 'UEV_DualPairReadyForActivate'):
            'field check: an EXISTING apollo key whose counterpart does not match',
        ('04_RPS.pact', 'FVT|C>SET-SPLIT-MODE'):
            'split-mode is pure argument-domain; the class-0 half needs a non-farm FVT',
        ('05_FVT.pact', 'FVT|C>SET-SPLIT-MODE'):
            'split-mode is pure argument-domain; the class-0 half needs a non-farm FVT',
        ('05_FVT.pact', 'UEV_SetMosaicContext'):
            'PINNED 2026-09-10 in [6.4]_AQP-EXHAUSTIVE-FVT-ADMIN (member-link-count > 0)',
        ('04_RPS.pact', 'XIv_FvtAddStream'):
            'derived-in-flight: the slot count is checked AFTER this function drips and prunes '
            'finished streams, so the value does not exist before the call -- see its ;;Enforce: line',
        ('05_FVT.pact', 'UEV_SetCommonDenominatorContext'):
            'field check: an EXISTING farm FVT that already has ScoreEntityLink rows',
        ('08_DPDC-S.pact', 'UEV_SetClass'):
            'the domain guard was hoisted 2026-09-10; what remains is the deliberate '
            '(= set-class sc) data-integrity assertion, documented in place',
    }

    hard, soft, unknown, other_table, proven, triaged = [], [], [], [], [], []
    for f in FILES:
        for name, off, body in members(SRC[f]):
            sig = '\n'.join(body.split('\n')[:8])
            args = set(re.findall(r'([a-z][a-z0-9-]*):(?:string|integer|bool|decimal|guard|time)', sig))
            if not args: continue
            # EVERY enforce in the member, not just the first. These validators carry five to
            # eight guards each and the original `re.search` only ever examined guard 1 -- which
            # is why UEV_CollectContext's "ScoreEntityLink row must exist" (its FIFTH) was invisible
            # even after the partial-shadow category was added. Guard 1's condition usually names
            # only let-bound values, so it fails the argument test and the whole member was
            # abandoned before the interesting guards were reached.
            for m in re.finditer(r'\(enforce(?![-\w])(.{0,300}?)"((?:[^"\\]|\\.){4,})"', body, re.S):
                before, cond, msg = body[:m.start()], m.group(1), m.group(2)
                if '(let' not in before: continue
                keyed = {}
                for mm in CALL.finditer(before):
                    for w in re.findall(r'[a-z][a-z0-9-]*', mm.group(2) or ''):
                        if w in args: keyed.setdefault(w, mm.group(1))
                # KNOWN GAP, triaged 2026-09-11 -- do not re-derive. This test requires the
                # ENFORCE CONDITION to name an argument. It therefore misses the shape where the
                # condition tests the READ RESULT instead: DPOF::UEV_NoncesCirculating guards
                # `(!= nonce-supply -1.0)` where nonce-supply came from a hard UR_NonceSupply keyed
                # by the argument. Checked by hand, that guard is a PARTIAL shadow, not a dead one:
                # unreachable for a nonce that never existed (the read aborts first), but reachable
                # for a WIPED nonce, since 06_DPOF.pact:2498 writes supply -1.0 on decommission.
                # Closing the gap means resolving let-bound names back to their reader's key before
                # the argument test -- worth doing only if a second site of this shape appears.
                condargs = {w for w in re.findall(r'[a-z][a-z0-9-]*', cond) if w in args}
                both = sorted(set(keyed) & condargs)
                if not both: continue
                # EVERY matching argument, not just the alphabetically-first. UEV_CollectContext
                # matches on both <fvt-id> and <score-entity-id>; `both[0]` picked fvt-id, whose
                # reader is SOFT, so the member was filed as "not shadowed" -- while the HARD read
                # on score-entity-id, the one that actually narrows the guard, was never examined.
                # One guard can be shadowed by more than one of its arguments.
                for _arg in both:
                  reader = keyed[_arg]

                  # SAME ROW or DIFFERENT TABLE? The argument match alone cannot tell them apart, and
                  # that was the tool's biggest false-positive class: FVT|C>TOGGLE-REWARD-LINK reads
                  # UR_FVT|OwnerKonto on <fvt-id> and then guards "Reward link row must exist" -- a
                  # DIFFERENT table, also keyed by <fvt-id>. The FVT existing and the link existing are
                  # independent, so that guard is perfectly reachable.
                  #
                  # Resolve it by asking what the GUARD is actually reading. Map each let-bound name to
                  # the reader that produced it, look up the names the enforce condition uses, and
                  # compare their tables against the key-matched reader's. Same table -> the guard is
                  # about the very row the read just fetched, which is the shape all three confirmed
                  # dead cases have. Different table -> reachable, and dropped here.
                  binds = dict(re.findall(
                      r'\(([a-z][a-z0-9-]*)\s*:[^\s()]+\s+\((?:ref-[A-Za-z0-9|_-]+::)?(UR_[A-Za-z][A-Za-z0-9|_-]*)', before))
                  cond_readers = {binds[w] for w in re.findall(r'[a-z][a-z0-9-]*', cond) if w in binds}
                  cond_readers |= set(re.findall(r'\b(?:UR|URC|URCv|URCx)_[A-Za-z][A-Za-z0-9|_-]*', cond))
                  rt = tables(reader)
                  ct = set().union(*(tables(r) for r in cond_readers)) if cond_readers else set()
                  same_row = (not ct) or bool(rt & ct)

                  rec = (os.path.relpath(f, ROOT), off + before.count('\n') + 1, name, _arg, reader,
                         msg[:52], sorted(rt)[:1])
                  # THREE outcomes, not two. The different-table case was previously dropped as
                  # "reachable" and that dismissal cost a failed test: UEV_CollectContext reads
                  # SCR|T|Score keyed by <score-entity-id> and then guards "ScoreEntityLink row must
                  # exist" on a DIFFERENT table. The guard is reachable -- but NOT by the obvious input.
                  # A score that does not exist dies in the reader; only a score that EXISTS and is
                  # unlinked reaches the enforce. The reject domain is NARROWED, and a test author who
                  # is not told that writes the obvious probe and watches it fail.
                  if hardness(reader) != 'hard':
                      soft.append(rec)
                  elif (os.path.basename(f), name) in TRIAGED:
                      triaged.append((rec, TRIAGED[(os.path.basename(f), name)]))
                  elif is_proven(msg, os.path.basename(f)):
                      proven.append(rec)          # a passing negative test already reaches it
                  elif same_row:
                      hard.append(rec)
                  else:
                      other_table.append(rec)

    print("SHADOWED GUARD CANDIDATES — the validated argument is also a read key\n")
    print(f"  reader is a HARD read      : {len(hard):3d}   <- the candidate list")
    print(f"  reader is with-default-read: {len(soft):3d}   (guard fires normally; not shadowed)")
    print(f"  reader unresolved          : {len(unknown):3d}   (reported, not guessed)")
    print(f"  guard reads a DIFFERENT table: {len(other_table):3d}   (PARTIAL shadow -- see below)")
    print(f"  PROVEN REACHABLE by a passing test: {len(proven):3d}   (dropped: evidence beats inference)")
    print(f"  TRIAGED by hand as reachable      : {len(set(t[1] for t in triaged)):3d}   "
          f"({len(triaged)} sites; see --triaged)\n")
    if hard:
        print("CANDIDATES (each still needs the reject-domain check by hand):")
        for r in sorted(hard):
            print(f"  {r[0]}:{r[1]}\n      {r[2]}  validates <{r[3]}>, read by {r[4]} (hard)\n"
                  f"      guard says: {r[5]!r}   [table {r[6][0] if r[6] else '?'}]")
    if a.triaged and triaged:
        print("HAND-TRIAGED — read in full and found reachable:\n")
        seen = set()
        for rec, why in sorted(triaged):
            k = (os.path.basename(rec[0]), rec[2])
            if k in seen: continue
            seen.add(k)
            print(f"  {os.path.basename(rec[0])}  {rec[2]}\n      {why}")
        print()
    if other_table:
        print("\nPARTIAL SHADOWS — the guard IS reachable, but NOT by a missing entity.")
        print("The reader aborts first for any id whose row is absent, so a test must use an")
        print("entity that EXISTS and merely fails the guard's own condition:\n")
        for r in sorted(other_table):
            print(f"  {r[0]}:{r[1]}\n      {r[2]}  validates <{r[3]}>, shadowed for missing rows by {r[4]}\n"
                  f"      guard says: {r[5]!r}\n"
                  f"      test input: an existing <{r[3]}> that still fails this guard")
    if a.list and unknown:
        print("\nUNRESOLVED readers:")
        for r in sorted(unknown): print(f"  {r[0]}:{r[1]}  {r[2]}  via {r[4]}")
    return 0

if __name__ == '__main__':
    sys.exit(main())

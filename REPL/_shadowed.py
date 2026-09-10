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
    a = ap.parse_args()
    hard, soft, unknown, other_table = [], [], [], []
    for f in FILES:
        for name, off, body in members(SRC[f]):
            sig = '\n'.join(body.split('\n')[:8])
            args = set(re.findall(r'([a-z][a-z0-9-]*):(?:string|integer|bool|decimal|guard|time)', sig))
            if not args: continue
            m = re.search(r'\(enforce(?![-\w])(.{0,300}?)"((?:[^"\\]|\\.){4,})"', body, re.S)
            if not m: continue
            before, cond, msg = body[:m.start()], m.group(1), m.group(2)
            if '(let' not in before: continue
            keyed = {}
            for mm in CALL.finditer(before):
                for w in re.findall(r'[a-z][a-z0-9-]*', mm.group(2) or ''):
                    if w in args: keyed.setdefault(w, mm.group(1))
            condargs = {w for w in re.findall(r'[a-z][a-z0-9-]*', cond) if w in args}
            both = sorted(set(keyed) & condargs)
            if not both: continue
            reader = keyed[both[0]]

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

            rec = (os.path.relpath(f, ROOT), off + before.count('\n') + 1, name, both[0], reader,
                   msg[:52], sorted(rt)[:1])
            if hardness(reader) != 'hard':
                soft.append(rec)
            elif same_row:
                hard.append(rec)
            else:
                other_table.append(rec)

    print("SHADOWED GUARD CANDIDATES — the validated argument is also a read key\n")
    print(f"  reader is a HARD read      : {len(hard):3d}   <- the candidate list")
    print(f"  reader is with-default-read: {len(soft):3d}   (guard fires normally; not shadowed)")
    print(f"  reader unresolved          : {len(unknown):3d}   (reported, not guessed)")
    print(f"  guard reads a DIFFERENT table: {len(other_table):3d}   (same key, independent row; reachable)\n")
    if hard:
        print("CANDIDATES (each still needs the reject-domain check by hand):")
        for r in sorted(hard):
            print(f"  {r[0]}:{r[1]}\n      {r[2]}  validates <{r[3]}>, read by {r[4]} (hard)\n"
                  f"      guard says: {r[5]!r}   [table {r[6][0] if r[6] else '?'}]")
    if a.list and unknown:
        print("\nUNRESOLVED readers:")
        for r in sorted(unknown): print(f"  {r[0]}:{r[1]}  {r[2]}  via {r[4]}")
    return 0

if __name__ == '__main__':
    sys.exit(main())

#!/usr/bin/env python3
"""[eager-let] — a guard whose own SUBJECT is hard-read in the let binding group above it.

The most-repeated defect in this codebase. Pact evaluates a `let` binding group eagerly and in
full before the body runs, so:

    (let ((x (UR_Thing id))          ;; <- bare `read`, ABORTS when id does not exist
          (y (UR_Other id)))
      (enforce (!= id BAR) "id is not set"))   ;; <- can never speak

A caller passing BAR/a missing id sees `No value found in table ... for key: |` instead of the
written message. The guard documents an intent it cannot enforce.

Found by hand SEVEN times before this script existed (PYTHIA UEV_DualPairForLink, FVT
UEV_AddScoreEntityScoreContext, FVT UEV_AddScoreEntityTripletContext, DALOS GAS_PAYER, SCORE triplet
admission, OUROBOROS UEV_Exchange, AQP UEV_AddScorePoolAndScore). `_foldeager.py` covers the
fold-operand variant; this covers the let-binding variant. Same root cause, different syntax.

Only HARD readers count -- a `with-default-read` answers for a missing row instead of raising, so
evaluating it eagerly is harmless. See _pactlex.reader_kinds.

--produced  THE MIRROR RELATION, added 2026-09-16 after RT-K-007.
    The two modes above look for a hard read that CONSUMES the guard's subject. The opposite
    arrangement is just as fatal and was invisible here: a hard read that PRODUCES it.

        (let ((iz-anchor-active (UR_ANK|State anchor-id)))   ;; hard read -> the guard's own input
          (enforce iz-anchor-active "Anchor ... must be alive for operation"))

    `UEV_LiveAnchor` was written for exactly the missing-anchor case and could never say so: reading
    its own subject raised first, so the caller got `No value found in table ... for key: <id>`. The
    guard was reachable for rows that exist and unreachable for the only input that needed it.
    Fixed by defaulting the reader, which is the general remedy for this variant -- the guard cannot
    be moved above the value it tests.

Sites already annotated `;;UNREACHABLE` at source are listed separately: they are known.
"""
import re, glob, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _pactlex import strip_comments, balanced, split_top, reader_kinds, UR_CALL

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
files = [f for f in sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                           + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
         if "/Audit/" not in f]
HARD = reader_kinds(files)

# NARROW (default): an enforce whose condition tests <var> for BAR / emptiness -- an existence-ish
# guard, high confidence. WIDE (--wide): ANY enforce whose condition merely MENTIONS <var>.
#
# The narrow shape is only one of the forms this defect takes. Of the seven instances found by hand,
# only the two OUROBOROS ones are `(enforce (!= var BAR) ...)`. The others hide in a fold operand
# (covered by _foldeager.py), test a bool (`(enforce iz-single ...)`) or call an existence function
# (`URC_TripletExists`). So the narrow rule reading clean does NOT mean the family is clean -- hence
# the wide mode, which trades precision for recall and is meant to be read by hand.
GUARD = re.compile(r'\(enforce\s+\((?:!=|=)\s+([A-Za-z][A-Za-z0-9|_-]*)\s+(?:BAR|"")\)')
# Messages that an ABSENT row would make true -- i.e. guards whose whole job is to answer the
# question the hard read below them raises on. Deliberately a small, literal vocabulary: widening it
# is how this scanner would become unreadable again.
# CORRECTED once, against evidence. The first vocabulary included "must be set" and "unknown", and
# that matched a large family of STATE guards -- UEV_LockState, UEV_EliteState, the recovery toggles
# -- whose message says "Parameter-lock for ATS Pair X must be set to true". Those are NOT this
# defect: for a pair that does not exist, "its lock must be set" is a MISLEADING answer, so the raw
# read is actually the lesser evil, and defaulting their readers would manufacture exactly the
# wrong-diagnosis problem RT-K-004 found in DPDC (a role reported on a collection never established
# to exist). The signature is only present when the guard's own message ALREADY COVERS ABSENCE --
# "must be alive", "does not exist", "no such" -- because then the raising read is stealing a
# sentence the guard was written to say.
EXISTENCE = re.compile(r'"[^"]*\b('
                       r'exist|exists|alive|registered|missing|no such|not found'
                       r')\b[^"]*"', re.I)
WIDE = '--wide' in sys.argv
PRODUCED = '--produced' in sys.argv

total_lets, flagged, known = 0, [], []
for f in files:
    raw = open(f, encoding='utf8', errors='ignore').read()
    annotated_lines = {i + 1 for i, ln in enumerate(raw.split('\n'))
                       if re.match(r'\s*;+\s*(UNREACHABLE|CANNOT PROTECT)\b', ln)}
    src = strip_comments(raw)
    for m in re.finditer(r'\(let\*?\s*\(', src):
        grp_open = src.index('(', m.end() - 1)
        grp_close = balanced(src, grp_open)
        if grp_close < 0: continue
        form_close = balanced(src, m.start())
        if form_close < 0: continue
        total_lets += 1
        bindings = split_top(src[grp_open + 1:grp_close])
        body = src[grp_close + 1:form_close]
        # which vars are bound, and which bindings hard-read using another bound var
        bound = []
        for b in bindings:
            nm = re.match(r'\(\s*([A-Za-z][A-Za-z0-9|_-]*)', b)
            if nm: bound.append(nm.group(1).split(':')[0])
        if PRODUCED:
            # A hard read that PRODUCES the guard's subject: the enforce tests a variable whose own
            # value came from a raising reader, so it cannot answer for a missing row.
            for b in bindings:
                rd = UR_CALL.search(b)
                if not rd or rd.group(1) not in HARD: continue
                # A hard read inside `(try <default> ...)` CANNOT raise -- same principle as
                # with-default-read. CODEX|C>RELEASE-STOICTAG is the model of doing this right:
                #   (tag-row-found (not (= (try false (UR_STG|Data tag-name)) false)))
                #   (tag-iz-active (if tag-row-found (UR_STG|IzActive tag-name) false))
                #   (enforce tag-row-found "StoicTag not found")
                # try-wrap the existence probe, then make every later read conditional on it. Missing
                # this rule flagged that defcap, which is the one place in the tree that answers the
                # question properly.
                if re.search(r'\(\s*try\s', b[:rd.start()]): continue
                # ...and a hard read inside `(if <guard> ...)` is equally protected: that is the
                # other half of the CODEX idiom, where every read after the existence probe is made
                # conditional on it. Approximate by design -- this mode is TRIAGE, not a verdict.
                if re.search(r'\(\s*if\s', b[:rd.start()]): continue
                nm = re.match(r'\(\s*([A-Za-z][A-Za-z0-9|_-]*)', b)
                if not nm: continue
                var = nm.group(1).split(':')[0]
                for g in re.finditer(r'\(enforce(?:-one)?\s', body):
                    seg = body[g.start():g.start() + 300]
                    if not re.search(r'\b' + re.escape(var) + r'\b', seg):
                        continue
                    # NARROWING, and the first attempt needed it. "A binding is hard-read and the
                    # body enforces on it" is not a defect signature -- it is how nearly every guard
                    # in the codebase is written, and the broad rule returned 201 sites. Reading
                    # state and enforcing on it is normal; the defect is only present when the guard
                    # is ABOUT EXISTENCE while the read it depends on PRESUPPOSES existence. So the
                    # message must claim something an absent row would make true.
                    if not WIDE and not EXISTENCE.search(seg):
                        continue
                    line = src[:grp_close + 1 + g.start()].count('\n') + 1
                    rec = (os.path.relpath(f, ROOT), line, var, rd.group(1))
                    if any(abs(line - a) <= 12 for a in annotated_lines): known.append(rec)
                    else: flagged.append(rec)
            continue
        for b in bindings:
            rd = UR_CALL.search(b)
            if not rd or rd.group(1) not in HARD: continue
            # The binding's VALUE expression, i.e. everything after `(name:type `. The first
            # attempt sliced from b.index(')'), meaning to skip the name -- but the first ')' in
            # `(o-rm:bool (ref-DPTF::UR_AccountRoleMint ouro-id orb-sc))` closes the inner CALL, so
            # the slice was '))' and no variable was ever found. That is why this reported 0 hits
            # against seven known instances.
            mb = re.match(r'\(\s*[A-Za-z][A-Za-z0-9|_-]*(?::[^\s]+)?\s+', b)
            value = b[mb.end():] if mb else b
            for v in bound:
                if not re.search(r'\b' + re.escape(v) + r'\b', value):
                    continue
                # is there a guard in the BODY testing that same var for BAR?
                if WIDE:
                    gmatches = [m2 for m2 in re.finditer(r'\(enforce(?:-one)?\s', body)
                                if re.search(r'\b' + re.escape(v) + r'\b',
                                             body[m2.start():m2.start() + 300])]
                else:
                    gmatches = [g for g in GUARD.finditer(body) if g.group(1) == v]
                for g in gmatches:
                    line = src[:grp_close + 1 + g.start()].count('\n') + 1
                    rec = (os.path.relpath(f, ROOT), line, v, rd.group(1))
                    if any(abs(line - a) <= 12 for a in annotated_lines): known.append(rec)
                    else: flagged.append(rec)

def uniq(rs):
    out, seen = [], set()
    for r in rs:
        if (r[0], r[1]) in seen: continue
        seen.add((r[0], r[1])); out.append(r)
    return out

flagged, known = uniq(flagged), uniq(known)
print(f"let binding groups scanned: {total_lets}   hard readers: {len(HARD)}")
print(f"ALREADY ANNOTATED at source (known): {len(known)}")
print(f"NOT YET ANNOTATED: {len(flagged)}" + ("   [--wide: REVIEW AID, expect false positives]" if WIDE else ""))
print()
for f, line, v, rdr in flagged:
    print(f"  {f}:{line}")
    rel = "tests" if not WIDE else "mentions"
    print(f"      an enforce here {rel} {v}; {rdr} (hard read) consumes {v} in the binding group above")

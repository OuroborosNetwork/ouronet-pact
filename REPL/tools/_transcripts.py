#!/usr/bin/env python3
"""_transcripts.py -- mine the session transcripts for owner decisions and measured findings.

WHY THIS EXISTS
---------------
The Pact tree answers WHAT the code does.  `MODULE-INDEX.md` is generated and answers WHERE
everything is.  Neither answers WHY -- why a rule exists, which owner ruling settled a design
question, what was measured before a number was written down.  That material exists in exactly
one place: the session transcripts under `~/.claude/projects/`, 1.6 GB of them.

`OuronetDocumentation/` needs the WHY for every one of its 118 files, and the failure mode
without this tool is specific and has already happened repeatedly in this project: writing a
confident sentence from RECOLLECTION, where the recollection is a summary of a summary.  Every
figure in the documentation is supposed to be read rather than remembered
(`90-reference/03-how-these-figures-were-obtained.md`); this is the same discipline applied to
prose.  A ruling is quoted from the message that made it, or it is not called a ruling.

WHAT IT CAN AND CANNOT DO
-------------------------
It extracts what the OWNER TYPED.  That is authoritative for intent and for rulings.  It is NOT
authoritative for figures -- the owner's messages contain plenty of numbers that were later
corrected, and several that were wrong when written.  Use it to find the DECISION and its date;
use the tree, the gate or the chain for the NUMBER.

THE SIDECHAIN TRAP, and it is why this tool nearly shipped lying.  A subagent prompt -- prose
*I* wrote to brief an Agent -- is recorded with `"type": "user"`, identical in every field a
naive reader checks, including `userType: external`.  The only discriminator is `isSidechain`.
The first version of this tool ignored it, and the contamination is 297 of 4,172 rows: 7%, which
sounds tolerable and is not.  It is CONCENTRATED exactly where the tool is used -- a subagent
brief is long descriptive prose about architecture, which is the same shape as a design ruling.
The first `--rulings` run returned 11 hits of which **10 were my own agent prompts**, each one
confidently describing Ouronet as "a virtual blockchain written in Pact" -- a sentence that would
then have been quoted into the documentation as though the owner had said it.  Filtered by
default; reachable with `--agents`, because what was asked of an agent is real evidence of what
was believed at the time, just not evidence of intent.

Measured on the corpus, 2026-09-27: 956 transcript files, 473,277 lines, 7,263 user-role messages
outside the harness noise, of which 4,172 are in the Ouronet repositories and 3,875 of those are
the owner rather than a subagent brief.  The length distribution
matters and is why `--typed` and `--pasted` are separate modes:

    median 218 chars   p90 2,977   p99 29,088   max 350,557

The median message is two sentences -- a decision.  The mean (2,021) is six times the median
because a handful of messages are pasted logs, contract output and whole files.  Both are
useful; they are not the same kind of evidence, and a search that mixes them returns a paste
for every ruling.

DELIBERATELY NOT IN THE GATE.  The gate must be reproducible from the repository, and this
reads a corpus that lives outside it, is per-machine, and grows every session.  A check that
cannot fail the same way twice does not belong in a gate.  It is a research tool, run by hand.

  python3 REPL/tools/_transcripts.py --stats               corpus shape; verifies the figures above
  python3 REPL/tools/_transcripts.py --grep 'PATTERN'      search typed messages (regex, -i)
  python3 REPL/tools/_transcripts.py --grep P --pasted     search pasted evidence instead
  python3 REPL/tools/_transcripts.py --grep P --all        both, and every project not just Ouronet
  python3 REPL/tools/_transcripts.py --grep P --agents     search MY subagent briefs instead
  python3 REPL/tools/_transcripts.py --rulings             candidate owner rulings, newest first
  python3 REPL/tools/_transcripts.py --on 2026-09-14       everything typed on one date
  python3 REPL/tools/_transcripts.py --selftest            prove the noise filter and split work
"""
import json, os, re, sys, glob, statistics

# Resolved inside a function, never at import: the corpus is outside the repo and
# `_toolpaths.py` is right to treat an absolute literal as ephemeral rather than as structure.
def corpus_root():
    return os.path.join(os.path.expanduser("~"), ".claude", "projects")

# A transcript `user` record is one of two very different things: something the owner typed, or a
# tool result / hook output / system reminder that the harness attributes to the user role.  The
# second outnumbers the first 11:1 (80,095 vs 6,498 measured), so this filter is not a tidy-up --
# without it the signal is 8% of the output.
NOISE = re.compile(r'<system-reminder|<command-name>|<local-command|Caveat: The messages|'
                   r'^\s*<user-prompt-submit-hook|SessionStart:|^\[Request interrupted|'
                   r'^<bash-input>|^<bash-stdout|^API Error|tool_use_error', re.I)

# The split point between a typed instruction and pasted evidence.  Chosen from the measured
# distribution: p90 is 2,977, so 3,000 keeps ~90% of messages in `typed` while moving the
# pastes out.  It is a HEURISTIC and mislabels a genuinely long instruction as a paste -- which
# is why `--all` exists and why both halves are searchable rather than one being discarded.
PASTE_CHARS = 3000

OURONET = ('Ouronet', 'ouronet', 'StoaChain', 'DALOS')

RULING = re.compile(r'\b(owner ruling|i rule|my ruling|the rule is|from now on|never again|'
                    r'always use|must always|must never|going forward|final answer|'
                    r'i decide|decision is|lets make it|we will use|dont ever)\b', re.I)


def load(ouronet_only=True, agents=False):
    """Yield (date, project, session, kind, text) per message.

    `agents=False` drops sidechain records -- subagent briefs, which are MY prose, not the
    owner's.  See THE SIDECHAIN TRAP in the module docstring; this default is the whole
    difference between quoting the owner and quoting myself back at him."""
    root = corpus_root()
    if not os.path.isdir(root):
        print(f"no corpus at {root}", file=sys.stderr)
        return
    for path in sorted(glob.glob(os.path.join(root, '**', '*.jsonl'), recursive=True)):
        proj = os.path.relpath(path, root).split(os.sep)[0]
        if ouronet_only and not any(k in proj for k in OURONET):
            continue
        try:
            fh = open(path, encoding='utf8', errors='replace')
        except OSError:
            continue
        with fh:
            for line in fh:
                try:
                    d = json.loads(line)
                except Exception:
                    continue
                if d.get('type') != 'user':
                    continue
                if bool(d.get('isSidechain')) != agents:
                    continue
                m = d.get('message')
                if not isinstance(m, dict):
                    continue
                c = m.get('content')
                if isinstance(c, str):
                    txt = c
                elif isinstance(c, list):
                    txt = ' '.join(b.get('text', '') for b in c
                                   if isinstance(b, dict) and b.get('type') == 'text')
                else:
                    continue
                txt = (txt or '').strip()
                if not txt or NOISE.search(txt):
                    continue
                kind = 'pasted' if len(txt) > PASTE_CHARS else 'typed'
                yield (d.get('timestamp', '')[:10], proj, os.path.basename(path)[:8], kind, txt)


def _short(proj):
    return proj.replace('-home-ancientbox-ClaudeWS-', '').replace('OuroborosNetwork-', '')


def show(rows, width=900):
    for date, proj, sess, kind, txt in rows:
        body = ' '.join(txt.split())
        if len(body) > width:
            body = body[:width] + f'  …[+{len(txt)-width:,} chars]'
        print(f"\n\033[36m{date}\033[0m  {_short(proj)}  {sess}  ({kind}, {len(txt):,}c)")
        print(f"  {body}")


def main():
    a = sys.argv[1:]
    if not a:
        print(__doc__)
        return 0
    everything = '--all' in a
    agents = '--agents' in a
    want = 'pasted' if '--pasted' in a else ('both' if everything else 'typed')

    if '--selftest' in a:
        return selftest()

    rows = list(load(ouronet_only=not everything, agents=agents))

    if '--stats' in a:
        typed = [r for r in rows if r[3] == 'typed']
        pasted = [r for r in rows if r[3] == 'pasted']
        allrows = list(load(ouronet_only=False))
        sidechain = list(load(ouronet_only=True, agents=True))
        lens = sorted(len(r[4]) for r in rows)
        print(f"corpus            {corpus_root()}")
        print(f"files             {len(glob.glob(os.path.join(corpus_root(),'**','*.jsonl'),recursive=True)):,}")
        print(f"typed, all repos  {len(allrows):,}")
        print(f"owner, Ouronet    {len(rows):,}   ({len(typed):,} typed + {len(pasted):,} pasted)")
        print(f"subagent briefs   {len(sidechain):,}   (excluded unless --agents)")
        if lens:
            print(f"length            median {statistics.median(lens):,.0f}  mean "
                  f"{statistics.mean(lens):,.0f}  p90 {lens[int(.9*len(lens))]:,}  max {lens[-1]:,}")
        dates = sorted({r[0] for r in rows if r[0]})
        if dates:
            print(f"span              {dates[0]} .. {dates[-1]}  ({len(dates)} active days)")
        return 0

    sel = [r for r in rows if want == 'both' or r[3] == want]

    if '--rulings' in a:
        hits = [r for r in sel if RULING.search(r[4])]
        print(f"# {len(hits)} candidate rulings (pattern match -- READ each, the pattern cannot "
              f"tell a ruling from a description of one)")
        show(sorted(hits, reverse=True), width=700)
        return 0

    if '--on' in a:
        day = a[a.index('--on') + 1]
        show([r for r in sel if r[0] == day])
        return 0

    if '--grep' in a:
        pat = re.compile(a[a.index('--grep') + 1], re.I)
        hits = [r for r in sel if pat.search(r[4])]
        print(f"# {len(hits)} of {len(sel):,} {want} messages match")
        show(hits)
        return 0

    print(__doc__)
    return 0


def selftest():
    """The two claims worth proving: the noise filter drops harness traffic, and the
    typed/pasted split lands where the docstring says it does."""
    ok = True
    for s in ('<system-reminder>foo</system-reminder>', 'SessionStart:compact hook success',
              '<command-name>/loop</command-name>', 'API Error: 500'):
        if not NOISE.search(s):
            print(f"  FAIL noise filter missed: {s[:40]}"); ok = False
    for s in ('okay lets deploy it', 'fix the ATS bug'):
        if NOISE.search(s):
            print(f"  FAIL noise filter ate a real message: {s}"); ok = False
    rows = list(load())
    side = list(load(agents=True))
    if not rows:
        print("  SKIP no corpus on this machine"); return 0
    # The trap this tool shipped with once: sidechain briefs read as owner prose.  Assert the
    # partition is real (non-empty both sides, disjoint) rather than that a flag was passed.
    if not side:
        print("  FAIL no sidechain rows found -- the isSidechain filter is not discriminating"); ok = False
    if set(id(r) for r in rows) & set(id(r) for r in side):
        print("  FAIL owner and subagent sets overlap"); ok = False
    vb = [r for r in side if 'virtual blockchain' in r[4].lower()]
    if not vb:
        print("  WARN no subagent brief says 'virtual blockchain' -- the documented case is gone")
    else:
        print(f"  {len(vb)} subagent brief(s) describe Ouronet as a 'virtual blockchain' -- "
              f"correctly excluded from owner quotes")
    typed = [r for r in rows if r[3] == 'typed']
    pasted = [r for r in rows if r[3] == 'pasted']
    frac = len(typed) / len(rows)
    if not (0.80 <= frac <= 0.95):
        print(f"  FAIL typed fraction {frac:.0%} outside the 80-95% the docstring claims"); ok = False
    if pasted and min(len(r[4]) for r in pasted) <= PASTE_CHARS:
        print("  FAIL a 'pasted' row is under the threshold"); ok = False
    print(f"  {len(rows):,} owner rows: {len(typed):,} typed ({frac:.0%}), {len(pasted):,} pasted; "
          f"{len(side):,} subagent briefs excluded")
    print("  selftest OK" if ok else "  selftest FAILED")
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())

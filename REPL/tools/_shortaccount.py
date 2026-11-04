#!/usr/bin/env python3
"""
NO CLIENT-FACING STRING CARRIES A FULL OURONET ACCOUNT.

    python3 REPL/tools/_shortaccount.py            # report, exit 1 on any violation
    python3 REPL/tools/_shortaccount.py --list     # also print the derived account vocabulary

------------------------------------------------------------------------------------------------
THE RULING
------------------------------------------------------------------------------------------------
Owner, 2026-11-04, looking at an unstake result that ran off the edge of the Papyrus panel:

    "You know how talos modules, all the time drop an output string describing the state of end
     result of the trasnction. Sometimes that end result string carries the whole string of an
     ouroent account which is the case here. However, we should set up a rule, and never use the
     full Ouronet Account string in such end result strings the talos modules outputs. We have a
     way to print instead a shortened versioned of it."

The way already exists -- `IGNIS::OI|UC_ShortAccount`, `(take 5) + "..." + (take -3)` -- and
eighteen files already use it. What did not exist was anything that noticed the ones that do not.

------------------------------------------------------------------------------------------------
WHY THIS IS A TOOL AND NOT A SWEEP
------------------------------------------------------------------------------------------------
A hand-swept rule in a 237-file Pact tree is a rule that holds until the next `C_` is written.
This repository already learned that twice over and wrote it down in CLAUDE.md: *"Never
hand-maintain a list of what to read -- that list stops being complete the first time someone
forgets a line, and the symptom is not an error, it is an agent that never learns the rule."*
The symptom here is the same shape: nothing fails, the string is simply unreadable, and it is
only ever caught by a human squinting at a modal.

------------------------------------------------------------------------------------------------
HOW AN ACCOUNT IS RECOGNISED -- DERIVED, NOT DECLARED
------------------------------------------------------------------------------------------------
The vocabulary is read out of the tree: every identifier ever passed to `UC_ShortAccount`
anywhere IS, by the existing code's own testimony, an account. That is 42 names today and it
extends itself as the sweep lands -- a hand-kept list would start drifting immediately.

SEED exists only because derivation cannot bootstrap: a parameter that is an account and has
NEVER been shortened anywhere would not appear in its own evidence. Each seed entry is a name
the 2026-11-04 census found in client output and nowhere else.

------------------------------------------------------------------------------------------------
WHAT IS AND IS NOT IN SCOPE
------------------------------------------------------------------------------------------------
IN:  `format` forms that produce CLIENT OUTPUT -- `UDC_ClientInfo` result lines, Talos `C_`/`A_`
     return strings, anything a user reads.
OUT: `format` inside `enforce` / `enforce-one`. Those are failure diagnostics, read by whoever
     is debugging a refusal, and truncating an account there removes the one thing that
     identifies which account was refused. The owner's ruling is about RESULT strings and this
     keeps to it rather than generalising past it.
OUT: `format` inside a protected `XI_` / `XE_` / `XB_` function. Those are INTER-MODULE
     entrypoints: their return value goes to another module, which composes its own result, so
     nothing a user reads is involved. Caught by the owner reading the deploy round and asking
     why a core module was in it -- `ANK::XE_RecomputeUserBoostAggregates` is called by
     `RPS.pact:3999` as a bare statement whose value is DISCARDED, so the first sweep shortened a
     string that reaches nobody and put a whole module (and a whole deploy transaction) into a
     live-chain round for it. The rule says "what a user reads"; this is what keeps it to that.
OUT: `format` whose literal contains NO LETTER. `(format "{}{}{}" [id BAR account])` is
     `UC_IdAccount` / `UC_AtspairAccount` building a composite TABLE KEY, and three of them sit
     in this tree. Shortening an account inside a key derivation would silently change every
     key the system computes — the single most destructive edit this rule could have demanded,
     and the first draft demanded it. A message has words; a key builder is placeholders and a
     separator.
"""
import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TREES = ["1_SOVEREIGN", "2_CITIZEN"]

#: Account-shaped parameter names found in client output and never shortened anywhere, so the
#: derivation below cannot see them. Census of 2026-11-04.
SEED = {"culler", "operator", "holder", "spender", "staker", "unstaker", "collector"}

#: Identifiers that LOOK like the vocabulary but are not accounts. Kept tiny on purpose: a long
#: exclusion list is how a checker stops checking.
NOT_ACCOUNTS = {"target"}  # `target` is also a DPTF id in several SWP paths

SHORTENER = "UC_ShortAccount"


def pact_files():
    for tree in TREES:
        yield from sorted((ROOT / tree).rglob("*.pact"))


def strip_noise(src: str) -> str:
    """Blank out string literals and `;` comments, preserving length and newlines.

    Length preservation is what lets every offset computed on the blanked text be reported
    against the real one -- the alternative is a second, drifting index.
    """
    out = list(src)
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c == ";":
            while i < n and src[i] != "\n":
                out[i] = " "
                i += 1
        elif c == '"':
            out[i] = " "
            i += 1
            while i < n:
                if src[i] == "\\" and i + 1 < n:
                    out[i] = out[i + 1] = " "
                    i += 2
                    continue
                if src[i] == '"':
                    out[i] = " "
                    i += 1
                    break
                if src[i] != "\n":
                    out[i] = " "
                i += 1
        else:
            i += 1
    return "".join(out)


HEAD = re.compile(r"[^\s()\[\]{}]+")


def forms(blank: str):
    """Yield `(head, open_idx, close_idx, ancestor_heads)` for every parenthesised form."""
    stack = []
    for i, c in enumerate(blank):
        if c == "(":
            m = HEAD.match(blank, i + 1)
            stack.append((m.group(0) if m else "", i))
        elif c == ")" and stack:
            head, start = stack.pop()
            yield head, start, i, tuple(h for h, _ in stack)


def account_vocabulary() -> set:
    """Every identifier the tree itself passes to the shortener. See the header."""
    found = set()
    pat = re.compile(rf"{SHORTENER}\s+([a-z][a-z0-9-]*)")
    for f in pact_files():
        found.update(pat.findall(f.read_text(encoding="utf8")))
    # LAMBDA BINDERS ARE NOT VOCABULARY. `(lambda (a:string) (ref::OI|UC_ShortAccount a))` in
    # `12_O-UI-TWELVE.pact` is a real shortening call whose argument is a throwaway name, and
    # admitting `a` to the vocabulary would flag every `format` that happens to pass a variable
    # called `a`. The shortest genuine parameter name in the set is `atbw`.
    found = {n for n in found if len(n) >= 3}
    return (found | SEED) - NOT_ACCOUNTS


VECTOR = re.compile(r"\[([^\[\]]*)\]", re.S)
BARE = re.compile(r"(?<![\w|:-])([a-z][a-z0-9-]*)(?![\w|-])")


def top_level_only(vec: str) -> str:
    """Blank every nested `( ... )` inside a format's argument vector.

    WITHOUT THIS THE CHECKER FLAGS ITS OWN FIX. `[(ref::OI|UC_ShortAccount executor)]` contains
    the identifier `executor`, so a flat scan reports the one shape the rule is asking for —
    caught by the tool's own negative test, which is the only reason it is not in the census.

    The rule it leaves behind is also the honest one: a BARE identifier at the top level of the
    vector is an account going out whole. Anything wrapped in a call has been passed through
    something, and a checker cannot know what that something did.
    """
    out, depth = [], 0
    for c in vec:
        if c == "(":
            depth += 1
        if depth == 0:
            out.append(c)
        else:
            out.append(" ")
        if c == ")":
            depth = max(0, depth - 1)
    return "".join(out)


def violations(vocab: set):
    """Every client-output `format` passing a bare account identifier."""
    for path in pact_files():
        src = path.read_text(encoding="utf8")
        blank = strip_noise(src)
        defuns = [(s, e, (blank[s + 1:e].split() or ["?", "?"])[1])
                  for h, s, e, _ in forms(blank) if h == "defun"]
        for head, start, close, ancestors in forms(blank):
            if head != "format":
                continue
            # A failure diagnostic, not a result string -- see the header.
            if any(a in ("enforce", "enforce-one") for a in ancestors):
                continue
            # Inter-module, not user-read -- see the header.
            d = _enclosing_defun(blank, defuns, start, close)
            if d and re.match(r"(?:[A-Za-z0-9|-]+\|)?X[IEB]_", d):
                continue
            span = blank[start:close]
            # A KEY BUILDER IS NOT A MESSAGE — read from the REAL source, since `strip_noise`
            # has blanked the literal by this point. See the header.
            lit = re.search(r'"((?:[^"\\]|\\.)*)"', src[start:close])
            if not lit or not re.search(r"[A-Za-z]", re.sub(r"\{\}", "", lit.group(1))):
                continue
            m = VECTOR.search(span)
            if not m:
                continue
            hits = sorted({w for w in BARE.findall(top_level_only(m.group(1))) if w in vocab})
            if hits:
                yield path.relative_to(ROOT), src[:start].count("\n") + 1, hits


def _enclosing_defun(blank, defuns, start, close):
    """Name of the innermost `defun` containing this form, or None."""
    inner = [d for d in defuns if d[0] < start and d[1] > close]
    return min(inner, key=lambda d: d[1] - d[0])[2] if inner else None


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--list", action="store_true", help="print the derived account vocabulary")
    args = ap.parse_args()

    vocab = account_vocabulary()
    if args.list:
        print(f"account vocabulary ({len(vocab)} names, derived from {SHORTENER} call sites):")
        for name in sorted(vocab):
            print(f"    {name}")
        print()

    bad = list(violations(vocab))
    if not bad:
        print(f"no client-output string carries a full Ouronet account "
              f"({len(vocab)} account names checked).")
        return 0

    by_file = {}
    for rel, line, hits in bad:
        by_file.setdefault(str(rel), []).append((line, hits))

    print(f"!! {len(bad)} client-output format(s) carry a FULL Ouronet account, "
          f"across {len(by_file)} file(s):\n")
    for rel in sorted(by_file):
        print(f"  {rel}")
        for line, hits in by_file[rel]:
            print(f"      :{line:<6} {', '.join(hits)}")
    print(f"\n   Bind the shortened form in the enclosing `let` and use that instead:")
    print(f"       (sa:string (ref-I|OURONET::OI|{SHORTENER} <account>))")
    print(f"   An account is ~60 characters and runs off the edge of every panel that shows it.")
    print(f"   `enforce` messages are deliberately exempt -- there the full account is the point.")
    return 1


if __name__ == "__main__":
    sys.exit(main())

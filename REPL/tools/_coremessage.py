#!/usr/bin/env python3
"""
A CORE `C_` DOES NOT COMPOSE THE RESULT STRING -- StoicSyntax-Prefixes.md 7.23.

    python3 REPL/tools/_coremessage.py          # report, exit 1 on any violation

------------------------------------------------------------------------------------------------
THE RULING
------------------------------------------------------------------------------------------------
Owner, 2026-11-04, on finding a CORE module inside a round he expected to be Talos-only:

    "C_ function in core modules must [not] output the end string, thats Talos module job. the
     core functions just supply the execution. Historically the talos module supplied the end
     result string."

The precedent is already live: `DALOS::C_ControlSmartAccount` is declared with NO return type and
`TS01-C1` composes the sentence itself. 598 of 622 sovereign core entrypoints already follow it.

------------------------------------------------------------------------------------------------
WHY A TOOL
------------------------------------------------------------------------------------------------
This is the rule 7.22 could not express. That checker asks "is this string client-facing?" and
answers it with a text heuristic; it cannot ask "is this LAYER allowed to be speaking?" -- which
is architecture, and was never written down. The consequence was concrete: the account-shortening
sweep had to edit `CODEX`, a core module, because the sentence a user reads is built there, and a
whole module went into a live-chain deploy round for it.

------------------------------------------------------------------------------------------------
WHAT COUNTS
------------------------------------------------------------------------------------------------
A violation is a SOVEREIGN, NON-TALOS `C_`/`CC_` whose RETURN VALUE -- the last top-level form of
its body -- is a `format`, or a `let` whose body ends in one.

OUT: Talos (`/3_Talos/`), where composing the sentence is the job.
OUT: citizen modules. Owner ruling 2026-09-26: "citizen modules are free to construct functions
     as they please." `2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact` alone has 19 such functions and
     every one of them is allowed.
OUT: a `format` anywhere EXCEPT the return position. A core may build a string for an event, a
     key, or a nested call; what it may not do is hand one back as the result.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENTRY = re.compile(r"(?:[A-Za-z0-9|-]+\|)?CC?_")


def pact_files():
    yield from sorted((ROOT / "1_SOVEREIGN").rglob("*.pact"))


def strip_noise(src: str) -> str:
    """Blank string literals and `;` comments, preserving length."""
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
    stack = []
    for i, c in enumerate(blank):
        if c == "(":
            m = HEAD.match(blank, i + 1)
            stack.append((m.group(0) if m else "", i))
        elif c == ")" and stack:
            head, start = stack.pop()
            yield head, start, i


def _last_form(body: str):
    """Span of the last form nested one level inside `body`, or None."""
    depth, last = 0, None
    for i, c in enumerate(body):
        if c == "(":
            if depth == 1:
                last = i
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 1 and last is not None:
                end = i
    return (last, end) if last is not None else None


def returns_a_message(body: str, _depth: int = 0) -> bool:
    """Is the RETURN VALUE of this form a `format`?

    RECURSES THROUGH `let` / `let*` / `with-capability` RATHER THAN SEARCHING THEM. The first
    cut asked `"(format" in body[last:]`, which is a substring test, and it reported
    `OUROBOROS::C_WithdrawFees` -- a function DECLARED
    `:object{IgnisCollectorV4.OutputCumulator}`, which could not return a string and still load.
    A `format` built midway through a `let` and handed to something else is not a return value,
    and the same mistake (searching where the rule says `is`) had already produced 39 false
    positives in 7.22's checker one day earlier.
    """
    if _depth > 24:
        return False
    span = _last_form(body)
    if span is None:
        return False
    inner = body[span[0]:span[1] + 1]
    head = HEAD.match(inner, 1)
    head = head.group(0) if head else ""
    if head == "format":
        return True
    if head == "if":
        # BOTH BRANCHES, and the first cut checked only one. `_last_form` returns the LAST
        # nested form, which for an `if` is the ELSE branch -- so a message in the THEN branch
        # was invisible. That under-reported the census AND, worse, let the strip remove one of
        # two paired messages: `DEMIPAD::C_TransmitTrueFungible` was left returning a sentence
        # when fuelling and a transfer result when retrieving, and the checker then called the
        # file clean. Caught by reading the stripped output, not by the tool.
        return any(returns_a_message_at(inner, i, _depth + 1) for i in _branches(inner))
    if head in ("let", "let*", "with-capability", "with-read", "with-default-read"):
        return returns_a_message(inner, _depth + 1)
    return False


def _branches(form: str):
    """Spans of the `if`'s two branch forms (skipping the condition)."""
    depth, spans, start = 0, [], None
    for i, c in enumerate(form):
        if c == "(":
            if depth == 1 and start is None:
                start = i
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 1 and start is not None:
                spans.append((start, i))
                start = None
    return spans[-2:] if len(spans) >= 2 else spans


def returns_a_message_at(form: str, span, _depth: int) -> bool:
    inner = form[span[0]:span[1] + 1]
    head = HEAD.match(inner, 1)
    head = head.group(0) if head else ""
    if head == "format":
        return True
    if head in ("let", "let*", "with-capability", "with-read", "with-default-read", "if"):
        return returns_a_message(inner, _depth + 1)
    return False


def violations():
    for path in pact_files():
        rel = str(path.relative_to(ROOT))
        if "/3_Talos/" in "/" + rel:          # Talos composes; that is the point
            continue
        src = path.read_text(encoding="utf8")
        blank = strip_noise(src)
        for head, start, close in forms(blank):
            if head != "defun":
                continue
            sig = blank[start + 1:start + 200].split()
            if len(sig) < 2:
                continue
            name = sig[1]
            if not ENTRY.match(name.split(":")[0]):
                continue
            if returns_a_message(blank[start:close]):
                yield rel, src[:start].count("\n") + 1, name.split(":")[0]


def main() -> int:
    bad = list(violations())
    if not bad:
        print("no sovereign core C_/CC_ composes its own result string.")
        return 0
    by_file = {}
    for rel, line, name in bad:
        by_file.setdefault(rel, []).append((line, name))
    print(f"!! {len(bad)} sovereign core entrypoint(s) compose the result string, "
          f"across {len(by_file)} file(s):\n")
    for rel in sorted(by_file):
        print(f"  {rel}")
        for line, name in by_file[rel]:
            print(f"      :{line:<6} {name}")
    print("\n   The core executes; the Talos wrapper narrates -- StoicSyntax-Prefixes.md 7.23.")
    print("   Drop the trailing message AND the `:string` return (interface declaration AND")
    print("   implementation), and compose the sentence in the Talos wrapper instead. A return")
    print("   type is part of the signature, so the interface BUMPS and consumers cascade.")
    return 1


if __name__ == "__main__":
    sys.exit(main())

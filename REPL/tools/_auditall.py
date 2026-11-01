#!/usr/bin/env python3
"""_auditall.py -- ONE command to rebuild the whole Audit Book after a code change.

    python3 REPL/tools/_auditall.py --check     # is anything stale?  (offline, gate-safe)
    python3 REPL/tools/_auditall.py --write     # rebuild every artefact, in order
    python3 REPL/tools/_auditall.py --write --docx   # ...and convert the book to .docx

WHY THIS EXISTS, and it is the same reason `_docsall.py` does.

Four generators feed `Audit/`, and before this you had to remember all four, in the right
order, and know which of them only validates. `_gate.py` already runs every one of them with
`--check` and is fatal on a stale artefact -- so the repository could always TELL you the book
was out of date, and could not rebuild it for you. "Remember four commands in order" is not a
maintenance story; it is the shape of the failure the Audit Book exists to document.

THE ORDER IS LOAD-BEARING:

  1. _booktables.py       the headline tables add up, and agree with the tools beneath them
  2. _chapterfigures.py   the Integration chapter's 15 registry-derived figures
  3. _auditbook.py        assembles the 28 chapters into the versioned .md (and .docx)
  4. _auditdelta.py       the signature delta a re-audit must re-verify

3 must follow 1 and 2: it assembles the chapters those two have just corrected, so running it
first publishes the previous state and then reports clean about work that has not happened.
4 is last because it is about the book that now exists.

WHAT IT DELIBERATELY DOES NOT DO. It never touches the network. The audit artefacts are built
from the tree and from `Deploy/OURONET-REGISTRY.json`, and that snapshot's freshness is a
separate question with a separate tool (`_registrylive.py --record`). A build step that
silently reached the chain would turn a failed rebuild into a network diagnosis -- and would
make the gate, which must run offline, unable to call this.

NOTE ON `_auditbook.py`: it writes on a BARE invocation, including `--help`. That is the trap
`CLAUDE.md` warns about under "never run a tool to find out what it does", and it was fallen
into on 2026-11-01 while surveying these generators -- harmlessly, because the only change was
the build-commit stamp, but harmless by luck rather than by design. It is called here only
under `--write`.
"""
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "REPL" / "tools"

#: (script, args-for-check, args-for-write, what it is)
#:
#: `args-for-write` is a LIST OF INVOCATIONS, not one, because for `_auditdelta` writing and
#: enforcing are different runs — see the note on STEP 4 below.
STEPS = [
    ("_booktables.py",     [["--check"]], [["--check"]],
     "the book's headline tables add up"),
    ("_chapterfigures.py", [["--check"]], [["--check"]],
     "the Integration chapter's registry figures"),
    ("_auditbook.py",      [["--check"]], [[]],
     "assemble the 28 chapters into the versioned book"),
    # ─────────────────────────────────────────────────────────────────────────────────────
    # STEP 4 RUNS TWICE UNDER --write, AND THE SECOND RUN IS THE POINT.
    #
    # `_auditdelta --write` regenerates the FACTS (every entrypoint whose signature differs
    # from the pre-sweep baseline) and exits 0 whether or not the judgement blocks exist.
    # Only `--check` enforces them. The first version of this file ran `--write` alone and
    # its own docstring claimed "a missing block fails the build on purpose" — which was
    # true of `--check`, the mode nobody presses, and false of `--write`, the mode the admin
    # button runs. Measured 2026-11-01: `--write` exit 0, `--check` exit 1, same tree.
    #
    # A GUARD THAT ONLY RUNS IN THE MODE NOBODY USES IS NOT A GUARD. Write, then check.
    # ─────────────────────────────────────────────────────────────────────────────────────
    ("_auditdelta.py",     [["--check"]], [["--write"], ["--check"]],
     "the signature delta a re-audit must re-verify"),
]


def run(script: str, args: list[str]) -> int:
    """Run one generator from the REPL directory, streaming its output."""
    proc = subprocess.run([sys.executable, str(TOOLS / script), *args],
                          cwd=ROOT / "REPL")
    return proc.returncode


def main() -> int:
    write = "--write" in sys.argv
    docx = "--docx" in sys.argv
    if not write and "--check" not in sys.argv:
        print(__doc__)
        return 0

    # TWO OF THE FOUR ONLY VALIDATE, and that is not an oversight to fix here.
    # `_booktables` and `_chapterfigures` compare prose against recomputed figures; the prose
    # is written by a person and the tool's job is to say when it has gone stale. Giving them
    # a `--write` would mean a script editing an auditor's sentences, which is the one thing
    # an audit artefact must not have happen to it. Under `--write` they still run, still as
    # checks, so the rebuild stops rather than assembling a book around a figure known wrong.
    failed: list[str] = []
    for script, check_runs, write_runs, what in STEPS:
        stop = False
        for args in (write_runs if write else check_runs):
            if write and docx and script == "_auditbook.py":
                args = [*args, "--docx"]
            # FLUSHED. Python buffers its own stdout while a subprocess writes straight to
            # the terminal, so without this every header appeared AFTER the output it
            # introduces — which makes a four-step build unreadable at the moment one fails.
            print(f"\n=== {script} {' '.join(args) or '(build)'} -- {what}", flush=True)
            if run(script, args) != 0:
                failed.append(f"{script} {' '.join(args)}".strip())
                stop = True
                break
        # STOP AT THE FIRST FAILURE under --write. Step 3 assembles what steps 1 and 2 have
        # just validated; assembling around a known-stale figure publishes it.
        if stop and write:
            break

    if failed:
        print(f"\nFAILED: {', '.join(failed)}")
        if not write:
            print("run: python3 REPL/tools/_auditall.py --write")
        return 1
    print("\nAudit artefacts " + ("rebuilt" if write else "in sync") + ".")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""_publishprep.py -- rebuild EVERYTHING a publication draws from, in one command.

    python3 REPL/tools/_publishprep.py --check   # is anything stale?  (offline)
    python3 REPL/tools/_publishprep.py --write   # rebuild the audit book and the docs
    python3 REPL/tools/_publishprep.py --write --docx   # ...and the .docx of the book

WHY THIS EXISTS. Two publications are cut from this repository -- the Audit Book (Stoic
Digest, and the Ouronet website) and OuronetDocumentation/ (the website's Pact reference).
Both are GENERATED, both were already gate-enforced against staleness, and neither had a
rebuild command that covered the other. So "regenerate before publishing" meant remembering
two orchestrators, and before `_auditall.py` existed, five separate scripts.

    _auditall.py   4 generators -> Audit/
    _docsall.py    5 generators -> OuronetDocumentation/

STALENESS WAS NEVER THE RISK -- `_gate.py` is fatal on every one of these artefacts being
out of date, and has been. The risk was the opposite: knowing the book is stale and having
to reconstruct how to fix it, at the moment you want to publish. That is when a remembered
sequence is most likely to be got wrong and least likely to be checked.

ORDER. Audit first, documentation second, and the reason is one-directional: the docs cite
the audit's figures, never the other way round. Rebuilding docs against a stale book would
propagate the stale number into the second publication and make both agree -- which is the
exact failure mode the Audit Book's own third rule is written about.

THE NETWORK IS NOT TOUCHED. Both orchestrators build from the tree and from the committed
`Deploy/OURONET-REGISTRY.json`. Whether that SNAPSHOT matches the chain is a different
question with its own tool: run `python3 REPL/tools/_registrylive.py --record` after a
deploy, and `_registry.py --check` will tell you when it was last confirmed. A publication
built from an unconfirmed snapshot is accurate about the repository and silent about the
chain, and it should say which -- not guess.

WHAT IT CANNOT DO, and this is deliberate. `_auditdelta.py` reports which changed modules
have no JUDGEMENT block in `Audit/AUDIT-V2-DELTA.md` -- which assertions a re-audit must
re-run, which findings are invalidated. No generator can write those. This surfaces them as
a blocking list; filling them is the author's work, and the audit must not be re-published
with modules whose re-verification nobody has decided on.
"""
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "REPL" / "tools"

STEPS = [
    ("_auditall.py", "the Audit Book, its tables, figures and signature delta"),
    ("_docsall.py",  "OuronetDocumentation: module map, 96 pages, catalogue, links, figures"),
]


def main() -> int:
    write = "--write" in sys.argv
    if not write and "--check" not in sys.argv:
        print(__doc__)
        return 0
    mode = "--write" if write else "--check"
    extra = ["--docx"] if (write and "--docx" in sys.argv) else []

    failed: list[str] = []
    for script, what in STEPS:
        print(f"\n{'=' * 78}\n== {script} {mode} -- {what}\n{'=' * 78}", flush=True)
        args = [mode, *extra] if script == "_auditall.py" else [mode]
        if subprocess.run([sys.executable, str(TOOLS / script), *args],
                          cwd=ROOT / "REPL").returncode != 0:
            failed.append(script)

    print(f"\n{'=' * 78}")
    if failed:
        print(f"PUBLISH PREP INCOMPLETE: {', '.join(failed)}")
        print("Read the output above. A failure in `_auditdelta` is usually not a stale")
        print("artefact but a MISSING JUDGEMENT BLOCK -- a changed module whose re-audit")
        print("nobody has decided on yet. That is written by hand, in")
        print("Audit/AUDIT-V2-DELTA.md, and it blocks publication on purpose.")
        return 1
    print("PUBLISH PREP COMPLETE -- audit and documentation both rebuilt from the tree.")
    print("")
    print("Before publishing, confirm the snapshot the figures came from:")
    print("  python3 REPL/tools/_registry.py --check    # when was it last confirmed?")
    print("  python3 REPL/tools/_registrylive.py --record   # ask the chain (network)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

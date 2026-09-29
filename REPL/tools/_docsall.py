#!/usr/bin/env python3
"""_docsall.py -- ONE command to regenerate the whole documentation after a code change.

    python3 REPL/tools/_docsall.py --check          # is anything stale?  (offline)
    python3 REPL/tools/_docsall.py --write          # regenerate, from the committed snapshot
    python3 REPL/tools/_docsall.py --write --probe  # ask the CHAIN first, then regenerate

WHY THIS EXISTS. Five generators feed OuronetDocumentation/, and before this you had to
remember all five, in order, and know that one of them needs the network. "Remember five
commands in order" is not a maintenance story -- it is the shape of the failure this
folder was built to avoid. The predecessor whitepaper was code-accurate when written and
had 55 of its 58 signatures wrong after one refactor, because regenerating it was
somebody's job rather than one command.

THE ORDER IS LOAD-BEARING, which is the other reason this file exists:

  0. _livemodules.py --probe   asks the chain.  ONLY with --probe.  Network.
  1. _docsmodules.py           the module map      <- reads the tree
  2. _docspages.py             96 module pages + the index   <- reads the SNAPSHOT
  3. _docsref.py               catalogue, glossary, source map <- reads snapshot + registry
  4. _docslinks.py             references and section directories  <- reads 1-3's output
  5. _docsfigures.py           prose figures vs the tree           <- reads 1-3's output

4 and 5 must run last: they check the output of the others, so running them first
validates the previous state and reports clean about work that has not happened yet.

WHAT IT DELIBERATELY DOES NOT DO. It does not probe the chain unless asked. The gate must
run offline, and a generator that silently reaches the network turns a failed build into
a network diagnosis. Without --probe everything regenerates from the committed snapshot,
and `_docspages` states each module's live-vs-repo difference from that snapshot rather
than pretending to fresh knowledge.

AFTER A DEPLOY the honest sequence is `--write --probe`, then commit the snapshot with
the documentation it produced. Anything else documents the previous surface.
"""
import os, subprocess, sys

TOOLS = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(TOOLS))

STEPS = [
    ("_docsmodules.py", "the module map"),
    ("_docspages.py", "96 module pages and the index"),
    ("_docsref.py", "entrypoint catalogue, glossary, source map"),
    ("_docslinks.py", "references and section directories"),
    ("_docsfigures.py", "prose figures against the tree"),
]


def run(tool, args):
    r = subprocess.run([sys.executable, os.path.join(TOOLS, tool)] + args,
                       capture_output=True, text=True, cwd=ROOT)
    return r.returncode, (r.stdout + r.stderr).rstrip()


def main():
    write = "--write" in sys.argv
    check = "--check" in sys.argv or not write
    if "--selftest" in sys.argv:
        ok = True
        for t, _ in STEPS:
            if not os.path.exists(os.path.join(TOOLS, t)):
                print(f"  selftest: missing {t}"); ok = False
        # The order claim in the docstring must match the list, or the docstring lies.
        if [t for t, _ in STEPS][-2:] != ["_docslinks.py", "_docsfigures.py"]:
            print("  selftest: the two CHECK-ONLY tools are not last"); ok = False
        print("  selftest OK" if ok else "  selftest FAILED")
        return 0 if ok else 1

    if "--probe" in sys.argv:
        if not write:
            print("--probe only makes sense with --write; refusing to reach the network "
                  "for a check.")
            return 2
        print("[0/5] asking the chain (--probe) ...")
        rc, out = run("_livemodules.py", ["--probe"])
        print("      " + (out.splitlines() or [""])[-1])
        if rc != 0:
            print("\nFAILED at the probe. Nothing regenerated -- deliberately: regenerating "
                  "from a half-refreshed snapshot would document neither surface.")
            return rc

    failed = []
    for i, (tool, what) in enumerate(STEPS, 1):
        # The last two only ever check; they have no --write.
        args = ["--check"] if (check or tool in ("_docslinks.py", "_docsfigures.py")) else ["--write"]
        if write and tool not in ("_docslinks.py", "_docsfigures.py"):
            args = ["--write"]
        rc, out = run(tool, args)
        tail = (out.splitlines() or [""])[-1]
        print(f"[{i}/5] {what:44s} {'ok ' if rc == 0 else 'FAIL'} {tail}")
        if rc != 0:
            failed.append((tool, out))

    if failed:
        print()
        for tool, out in failed:
            print(f"--- {tool} ---\n{out}\n")
        print("STALE." if check else "FAILED.")
        if check:
            print("Run: python3 REPL/tools/_docsall.py --write   "
                  "(add --probe if the chain has moved)")
        return 1
    print("\ndocumentation: " + ("regenerated, all five steps clean"
                                 if write else "clean -- nothing stale"))
    return 0


if __name__ == "__main__":
    sys.exit(main())

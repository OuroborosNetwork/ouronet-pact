#!/usr/bin/env python3
"""Unit tests for `_livesandbox.py`'s SCANNING, which is where every wrong answer came from.

    python3 REPL/tools/_livesandbox_test.py

WHY THESE AND NOT A REPLAY TEST. The replay needs a chain and the `pact` binary; it is exercised
by running the tool. What cannot be exercised that way -- because it fails SILENTLY and plausibly
-- is the three pure functions that decide load order and read failures. On 2026-10-24 each of
them produced a confident, wrong, chain-level conclusion:

  deps_of        omitted direct qualified calls, so AQP-INFO sorted BEFORE AQP-SCORE and the load
                 failed with "Module AQP-SCORE has no such member: URCi_RotateOwnership" -- which
                 reads as a missing function. It was a missing EDGE. Live AQP-SCORE defines it.
  strip_noise    was a regex and mis-paired quotes across Pact's `\\` doc-string continuation, so
                 prose counted as code. One false AQP-ANK -> AQP-POOL edge made the graph cyclic
                 and nearly produced a design built around "cycles are inherent in live state".
  error_origin   did not exist: a bare search for `_chain.pact:\\d+` matched STACK FRAMES, so a
                 failure in the round's own file was blamed on a live module, excluded, blamed on
                 the next frame, and so on -- 20+ modules reported "broken on chain" from one
                 round-level error.

Every case below is one of those, reduced.
"""
import importlib.util, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
_sp = importlib.util.spec_from_file_location("_livesandbox", os.path.join(HERE, "_livesandbox.py"))
LS = importlib.util.module_from_spec(_sp)
sys.modules["_livesandbox"] = LS
_sp.loader.exec_module(LS)

FAILED = []


def check(name, got, want):
    if got == want:
        print(f"  ok   {name}")
    else:
        print(f"  FAIL {name}\n         got:  {got!r}\n         want: {want!r}")
        FAILED.append(name)


# ---- strip_noise ---------------------------------------------------------------------------
print("strip_noise")

check("drops a `;` comment",
      LS.strip_noise("(defun f ()) ;; calls AQP-POOL.foo\n").strip(),
      "(defun f ())")

check("collapses a plain string",
      LS.strip_noise('(enforce x "mentions AQP-POOL.foo")'),
      '(enforce x "")')

# THE REGRESSION. This is the repo's @doc convention, and the regex version mis-paired these
# quotes and left the prose behind -- manufacturing the one edge that made the graph cyclic.
CONTINUED = '''(defun f ()
    @doc "first clause \\
         \\ second clause via AQP-POOL.something \\
         \\ third clause"
    (+ 1 2)
)'''
check("a `\\`-continued @doc leaks NOTHING (the false-cycle regression)",
      "AQP-POOL" in LS.strip_noise(CONTINUED),
      False)

check("...while real code around it survives",
      "(+ 1 2)" in LS.strip_noise(CONTINUED),
      True)

check("an escaped quote inside a string does not end it",
      "SECRET" in LS.strip_noise('(x "a \\" SECRET b") (y)'),
      False)


# ---- deps_of -------------------------------------------------------------------------------
print("deps_of")

UNI = {"AQP-SCORE", "AQP-POOL", "DALOS", "BRD", "OuronetDalosV3", "BrandingV3"}
IFACES = {"OuronetDalosV3", "BrandingV3"}

check("`implements` is an edge",
      LS.deps_of("(implements OuronetDalosV3)", UNI, IFACES),
      {"OuronetDalosV3"})

check("a modref needs BOTH the interface and the bound module",
      LS.deps_of("(ref-DALOS:module{OuronetDalosV3} DALOS)", UNI, IFACES),
      {"OuronetDalosV3", "DALOS"})

# THE REGRESSION that produced the "no such member" misdiagnosis.
check("a DIRECT QUALIFIED CALL is an edge (the AQP-INFO -> AQP-SCORE regression)",
      LS.deps_of("(AQP-SCORE.URCi_RotateOwnership score-id)", UNI, IFACES),
      {"AQP-SCORE"})

check("a qualified mention in PROSE is not an edge",
      LS.deps_of(';; Executes via AQP-SCORE.URCi_RotateOwnership.\n(+ 1 2)', UNI, IFACES),
      set())

check("a qualified mention in a @doc STRING is not an edge",
      LS.deps_of('@doc "Executes via AQP-POOL.foo."', UNI, IFACES),
      set())

check("names outside the live universe are ignored",
      LS.deps_of("(SomeThingElse.fn x)", UNI, IFACES),
      set())

check("a decimal literal is never mistaken for a qualified call",
      LS.deps_of("(enforce (>= amount 1.0) \"\")", UNI, IFACES),
      set())


# ---- error_origin --------------------------------------------------------------------------
print("error_origin")

# THE REGRESSION. The origin is the round's file; the `at(...)` frame names `_chain.pact`. A bare
# search for `_chain.pact:\d+` matched the FRAME and blamed a live module for the round's error.
TRACE = (
    '/x/Deploy/PureV13/04_deploy.pact:325:16: Error during database operation: Table X not found\n'
    ' 325 |                 (keys FVT|T|RPS|Global)\n'
    '  at(ouronet-ns.RPS.AA_MigrateMinInject.{h}):/x/Deploy/.livesandbox/_chain.pact:54235:1-9\n'
    'Load failed\n'
)
org = LS.error_origin(TRACE)
check("attributes to the ORIGIN file, not to a stack frame",
      os.path.basename(org[0]), "04_deploy.pact")
check("...and recovers the origin's line", org[1], 325)
check("...and the message", org[2].startswith("Error during database operation"), True)

check("a genuine in-chain failure IS attributed to _chain.pact",
      os.path.basename(LS.error_origin(
          '/x/_chain.pact:54235:109: Module AQP-SCORE has no such member: URCi_RotateOwnership\n'
      )[0]),
      "_chain.pact")

check("no Pact error at all -> None", LS.error_origin("all good\n"), None)


# ---- module_at_line ------------------------------------------------------------------------
print("module_at_line")
SPANS = [(1, 50, "DALOS"), (51, 120, "BRD"), (121, 200, "IGNIS")]
check("maps a line to its owning module", LS.module_at_line(SPANS, 60), "BRD")
check("boundary line belongs to its span", LS.module_at_line(SPANS, 121), "IGNIS")
check("a line past the end maps to nothing", LS.module_at_line(SPANS, 9999), None)


print()
if FAILED:
    print(f"{len(FAILED)} FAILED: " + ", ".join(FAILED))
    sys.exit(1)
print("all _livesandbox scan tests pass")

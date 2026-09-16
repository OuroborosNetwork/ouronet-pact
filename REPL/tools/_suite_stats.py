#!/usr/bin/env python3
"""SUITE STATS -> one Markdown report. Composes the other tools; computes nothing itself.

    cd REPL && python3 _suite_stats.py [--gate]

Writes OuronetInformational/ARCHITECTURE/REPL_SUITE_STATS.md.

WHY IT ONLY COMPOSES. Every number here already has an owning tool -- _scale_report for size and
reach, _gate for what executed, _expectfail/_vacuous for assertion strength, _enforce_coverage for
guard pinning, _docclaims for doc claims, _conformance for lint. Recomputing any of them here would
create a second answer that drifts from the first, and the drift would be invisible because both
would look authoritative. So this shells out and quotes, and every section names the command that
produced it so a reader can re-derive it independently.

--gate re-runs the full suite (~3.5 min) for a live assertion count. Without it, the last gate
output is reused and the report says so -- it never presents a stale number as fresh.
"""
import collections, os, re, subprocess, sys, time
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "..", "OuronetInformational", "ARCHITECTURE", "REPL_SUITE_STATS.md")
def _newest_gate():
    """Most recent gate output. Hardcoding one path meant the report silently quoted a stale run
    after the next gate wrote to a different file."""
    import glob as _g
    # Both extensions, because the convention is `.log` in practice and `.out` was what this
    # globbed (2026-09-15). The mismatch cost two headline rows: with no match this returns None,
    # the `if ex_tot:` block below is skipped, and the report is written WITHOUT "assertions
    # executed per full gate run" or "gate entrypoints" -- silently. _figuresync then reported
    # "clean" while no longer checking either figure, because its canonical source had stopped
    # containing them. A generator that degrades quietly takes its checker down with it.
    outs = [f for f in (_g.glob("/tmp/gate*.out") + _g.glob("/tmp/gate*.log"))
            if "GATE GREEN" in open(f, errors="ignore").read()]
    return max(outs, key=os.path.getmtime) if outs else None


def run(cmd, timeout=1800):
    r = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True, timeout=timeout)
    # THE SWALLOW, CLOSED (2026-09-16). The comment above TOOL() already described this exact
    # chain -- "run() swallows that into empty output, grab() returns None, and the first f-string
    # formatting a None is where it finally surfaces, five steps from the cause" -- and GS-14 fixed
    # the PATH that triggered it while leaving the swallow in place. A generator that degrades
    # quietly takes its checker with it, and this one feeds `_figuresync --check`.
    if r.returncode != 0:
        raise SystemExit(f"_suite_stats.py: sub-tool failed (rc={r.returncode}): {' '.join(map(str, cmd))}\n"
                         f"REFUSING to generate statistics from a failed run.\n{r.stderr.strip()[:400]}")
    return r.stdout


# SIBLING TOOLS, resolved from __file__ (2026-09-14). These were bare names -- "_gate.py" --
# which worked only while every tool sat in REPL/ and this script chdir'd there. After the move to
# REPL/tools/ the cwd is still REPL/, so a bare name resolves to REPL/_gate.py and the subprocess
# dies; `run()` swallows that into empty output, `grab()` returns None, and the first f-string
# formatting a None is where it finally surfaces -- five steps from the cause.
def TOOL(name):
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), name)

def grab(text, pattern, cast=int, default=None):
    m = re.search(pattern, text)
    return cast(m.group(1).replace(",", "")) if m else default


def main():
    t0 = time.time()
    print("running _scale_report.py --functions ...")
    scale = run([sys.executable, TOOL("_scale_report.py"), "--functions"])
    print("running _expectfail.py / _vacuous.py / _docclaims.py / _conformance.py ...")
    expfail = run([sys.executable, TOOL("_expectfail.py")])
    vac = run([sys.executable, TOOL("_vacuous.py")])
    docs = run([sys.executable, TOOL("_docclaims.py"), "--all"])
    conf = run([sys.executable, TOOL("_conformance.py")])
    print("running _enforce_coverage.py ...")
    cov = run([sys.executable, TOOL("_enforce_coverage.py")])

    if "--gate" in sys.argv:
        print("running _gate.py (full suite, ~3.5 min) ...")
        gate = run([sys.executable, TOOL("_gate.py")], timeout=5400)
        gate_src = "live run of `python3 _gate.py`"
    else:
        _c = _newest_gate()
        gate = open(_c, errors="ignore").read() if _c else ""
        gate_src = (f"most recent green gate output (`{_c}`) — re-run with `--gate` for a live count"
                    if _c else "no gate output found — run with `--gate`")

    # ---- headline numbers, each lifted from its owning tool's output -------------------------
    files   = grab(scale, r"\.repl files\s*:\s*(\d+)")
    lines   = grab(scale, r"total lines\s*:\s*(\d+)")
    code    = grab(scale, r"code\s*:\s*(\d+)")
    comment = grab(scale, r"comment\s*:\s*(\d+)")
    blank   = grab(scale, r"blank\s*:\s*(\d+)")
    funcs   = grab(scale, r"module functions \(defun, impl\)\s*:\s*(\d+)")
    reach_n = grab(scale, r"client-reachable live functions:\s*(\d+) of")
    reach_d = grab(scale, r"client-reachable live functions:\s*\d+ of (\d+)")
    direct  = grab(scale, r"called at least once\s*:\s*(\d+)")
    callsit = grab(scale, r"TOTAL call sites \(duplicates included\):\s*(\d+)")

    ex_tot  = grab(gate, r"executed (\d+) assertions")
    ex_pos  = grab(gate, r"assertions \((\d+) positive")
    ex_neg  = grab(gate, r"(\d+) negative\)")
    entries = grab(gate, r"GATE: (\d+) entrypoints")

    ef_str  = grab(expfail, r"STRONG \(3-arg, message checked\):\s*(\d+)")
    ef_weak = grab(expfail, r"WEAK\s+\(2-arg, ANY error passes\):\s*(\d+)")
    va_vac  = grab(vac, r"VACUOUS \(cannot fail\)\s*:\s*(\d+)")
    va_weak = grab(vac, r"WEAK\s+\(bound the domain guarantees\):\s*(\d+)")

    g_pin   = grab(cov, r"\.\.\.UNAMBIGUOUSLY \(a module-unique message\):\s*(\d+)")
    g_tot   = grab(cov, r"PINNED by a negative test\s*:\s*(\d+)")
    g_den   = grab(cov, r"enforce sites with a matchable message\s*:\s*(\d+)")
    g_live  = grab(cov, r"LIVE unpinned \(the real worklist total\):\s*(\d+)")
    g_dead  = grab(cov, r"of the unpinned, (\d+) sit in DEAD modules")
    g_unrch = grab(cov, r"nested in an enforce-one \(UNREACHABLE\)\s*:\s*(\d+)")
    g_annot = grab(cov, r"PROVEN unreachable by hand \+ annotated\s*:\s*(\d+)")

    # distinct assertions, counted from source -- the number to quote for "how many tests"
    distinct = 0
    for dirpath, _dirs, fnames in os.walk(ROOT):
        for fn in fnames:
            if fn.endswith(".repl"):
                distinct += len(re.findall(r"\(expect(?:-failure)?\b",
                                           open(os.path.join(dirpath, fn), encoding="utf8",
                                                errors="ignore").read()))

    # ---- the per-function table -------------------------------------------------------------
    rows = []
    body = scale.split("EVERY FUNCTION AND ITS CALL COUNT")[-1]
    for ln in body.splitlines():
        m = re.match(r"\s*(\d+)\s+(DIRECT|VIA|-)\s+(\S+)\s+(\S+)\s+(.+?)\s*$", ln)
        if m:
            rows.append((int(m.group(1)), m.group(2), m.group(3), m.group(4), m.group(5)))

    tested = [r for r in rows if r[0] > 0]
    via    = [r for r in rows if r[0] == 0 and r[1] == "VIA"]
    never  = [r for r in rows if r[0] == 0 and r[1] == "-"]
    total_invocations = sum(r[0] for r in rows)

    buckets = collections.Counter()
    for r in tested:
        c = r[0]
        b = ("1" if c == 1 else "2-5" if c <= 5 else "6-20" if c <= 20
             else "21-100" if c <= 100 else "101-500" if c <= 500 else "500+")
        buckets[b] += 1

    per_area = re.search(r"\.repl lines by area:\n((?:\s+\S+\s+\d+\n)+)", scale)
    areas = re.findall(r"\s+(\S+)\s+(\d+)", per_area.group(1)) if per_area else []

    prefix_rows = re.findall(r"\s+([A-Za-z]+)\s+(\d+)/(\d+)\s+called\s+(\d+) call sites", scale)

    d_auth = grab(docs, r"\[AUTHORITY\] (\d+)")
    d_imm  = grab(docs, r"\[IMMUTABLE\] (\d+)")
    d_bnd  = grab(docs, r"\[BOUND\] (\d+)")
    d_inv  = grab(docs, r"\[INVARIANT\] (\d+)")
    c_viol = grab(conf, r"VIOLATIONS: (\d+)")
    c_obs  = grab(conf, r"OBSERVATIONS: (\d+)")

    # ---- emit --------------------------------------------------------------------------------
    w = []
    A = w.append
    A("# Ouronet REPL Test Suite — Scale & Coverage")
    A("")
    A(f"Generated by `cd REPL && python3 _suite_stats.py --gate` on "
      f"{time.strftime('%Y-%m-%d')}.")
    A("")
    A("**This file computes nothing.** Every figure is lifted from the tool that owns it, named "
      "beside each section, so any number here can be re-derived independently. A second "
      "implementation would drift from the first and both would look authoritative.")
    A("")
    A("---")
    A("")
    A("## 1. How big is the suite")
    A("")
    A("<sub>source: `python3 _scale_report.py`</sub>")
    A("")
    A("| | |")
    A("|---|---:|")
    A(f"| `.repl` files | **{files:,}** |")
    A(f"| total lines | **{lines:,}** |")
    A(f"| &nbsp;&nbsp;code | {code:,} |")
    A(f"| &nbsp;&nbsp;comment | {comment:,} |")
    A(f"| &nbsp;&nbsp;blank | {blank:,} |")
    A("")
    if areas:
        A("**Lines by area**")
        A("")
        A("| area | lines |")
        A("|---|---:|")
        for a, n in areas:
            A(f"| `{a}` | {int(n):,} |")
        A("")
    A("---")
    A("")
    A("## 2. How many assertions")
    A("")
    A(f"<sub>executed: {gate_src} · distinct: counted from source</sub>")
    A("")
    A("Two different questions, two different numbers — quoting the wrong one overstates the suite "
      "by ~5x.")
    A("")
    A("| | |")
    A("|---|---:|")
    A(f"| **distinct assertions written** | **{distinct:,}** |")
    if not ex_tot:
        sys.exit("_suite_stats: REFUSING to write a report with no gate figures.\n"
                 "  No green gate output found in /tmp/gate*.{out,log}.\n"
                 "  Run `python3 REPL/tools/_gate.py` first, or re-run this with --gate.\n"
                 "  (Writing the report anyway silently drops 'assertions executed per full gate\n"
                 "   run' and 'gate entrypoints', and _figuresync then stops checking them.)")
    if ex_tot:
        A(f"| assertions **executed** per full gate run | **{ex_tot:,}** |")
        A(f"| &nbsp;&nbsp;positive (`expect`) | {ex_pos:,} |")
        A(f"| &nbsp;&nbsp;negative (`expect-failure`) | {ex_neg:,} |")
        A(f"| gate entrypoints | {entries} |")
    # PER-FUNCTION ROWS. Emitted as a LABELLED FIGURE, not just printed to stdout, because
    # REPL-ROUND-REPORT.md cites it ("plus all N per-function rows") and nothing could check that
    # cell: _figuresync only knows figures that appear in this table. It had drifted to the
    # "distinct assertions written" value and stayed wrong across several rounds, because a human
    # syncing figures by hand reaches for the nearest number of the right magnitude.
    A(f"| per-function rows | {len(rows):,} |")
    A("")
    A("*Executed* exceeds *distinct* because shared files run once per entrypoint that loads them. "
      "**Quote the distinct figure for \"how many tests exist\"**; the executed figure answers "
      "\"how much ran\".")
    A("")
    A("### Assertion strength")
    A("")
    A("<sub>source: `python3 _expectfail.py`, `python3 _vacuous.py`</sub>")
    A("")
    A("| | |")
    A("|---|---:|")
    A(f"| negative assertions checking their message | **{ef_str:,}** |")
    A(f"| negative assertions accepting ANY error | {ef_weak} *(all in ungated scratch files)* |")
    A(f"| positive assertions that **cannot fail** | **{va_vac}** |")
    A(f"| positive assertions on a trivially-satisfied bound | {va_weak} *(reviewed, legitimate)* |")
    A("")
    A("---")
    A("")
    A("## 3. How many module functions are tested")
    A("")
    A("<sub>source: `python3 _scale_report.py --functions`</sub>")
    A("")
    A("Two denominators, and mixing them is how this gets misreported. **All defined functions** "
      "includes the dead DPMF module and the internal-only `XI_`/`XB_`/`XE_`/`W*_` families that no "
      "test can call by design. **Client-reachable** excludes both, and is the honest denominator "
      "for a coverage percentage.")
    A("")
    A("| | all defined | client-reachable |")
    A("|---|---:|---:|")
    A(f"| functions | **{funcs:,}** | **{reach_d:,}** |")
    A(f"| named directly by a test | {len(tested):,} | {direct:,} |")
    A(f"| reached only *through* another function | {len(via):,} | {reach_n - direct:,} |")
    A(f"| **reached at all** | {len(tested)+len(via):,} | "
      f"**{reach_n:,} ({round(100*reach_n/reach_d)}%)** |")
    A(f"| never reached | {len(never):,} | {reach_d - reach_n:,} |")
    A("")
    A(f"**Total function invocations across the suite, duplicates included: "
      f"{total_invocations:,}.** That is every call site in every `.repl`, so a function called in "
      f"20 files counts 20 times — it answers \"how much testing happens\", not \"how much is "
      f"covered\".")
    A("")
    A("### How often a tested function is tested")
    A("")
    A("| times called | functions |")
    A("|---|---:|")
    for b in ("1", "2-5", "6-20", "21-100", "101-500", "500+"):
        if buckets.get(b):
            A(f"| {b} | {buckets[b]:,} |")
    A("")
    if prefix_rows:
        A("### By prefix")
        A("")
        A("| prefix | called / defined | call sites |")
        A("|---|---:|---:|")
        for p, c, n, s in prefix_rows:
            A(f"| `{p}_` | {int(c):,} / {int(n):,} | {int(s):,} |")
        A("")
    A("---")
    A("")
    A("## 4. Other coverage dimensions")
    A("")
    A("The **live worklist** is the figure to size remaining work by. It is NOT "
      "`_cheapseam.py`'s count, which covers only guards in plain callable functions and is about "
      "six times smaller. The excluded rows below are already outside the denominator -- they are "
      "listed so the subtraction is visible rather than taken on trust.")
    A("")
    A("| dimension | figure | tool |")
    A("|---|---:|---|")
    if g_pin:
        A(f"| guards pinned by a negative test (unambiguous) | {g_pin:,} | `_enforce_coverage.py` |")
    if g_tot:
        A(f"| guards pinned (upper bound, incl. shared wording) | {g_tot:,} | `_enforce_coverage.py` |")
    if g_live:
        A(f"| **guards still to pin (live worklist)** | **{g_live:,}** | `_enforce_coverage.py` |")
        A(f"| &nbsp;&nbsp;excluded: in the DEAD `00_DPMF` module | {g_dead} | |")
        A(f"| &nbsp;&nbsp;excluded: unreachable inside an `enforce-one` | {g_unrch} | |")
        A(f"| &nbsp;&nbsp;excluded: proven unreachable and annotated | {g_annot} | |")
    A(f"| `@doc` AUTHORITY claims | {d_auth} | `_docclaims.py` |")
    A(f"| `@doc` IMMUTABLE claims | {d_imm} | `_docclaims.py` |")
    A(f"| `@doc` BOUND claims | {d_bnd} | `_docclaims.py` |")
    A(f"| `@doc` INVARIANT claims | {d_inv} | `_docclaims.py` |")
    A(f"| conformance violations | {c_viol} | `_conformance.py` |")
    A(f"| conformance observations | {c_obs} | `_conformance.py` |")
    A("")
    A("---")
    A("")
    A("## 5. Every function and how many times it is tested")
    A("")
    A("`calls` = times a `.repl` names it directly. `reach` = **DIRECT** (named by a test), "
      "**VIA** (only executed through another function), **-** (never reached). "
      f"All {len(rows):,} rows, most-tested first.")
    A("")
    A("| calls | reach | file | module | function |")
    A("|---:|---|---|---|---|")
    for c, r, f, m, fn in rows:
        A(f"| {c} | {r} | `{f}` | `{m}` | `{fn}` |")
    A("")

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf8") as fh:
        fh.write("\n".join(w))
    print(f"wrote {os.path.relpath(OUT, ROOT)}  "
          f"({len(w):,} lines, {len(rows):,} function rows)  in {time.time()-t0:.0f}s")


main()

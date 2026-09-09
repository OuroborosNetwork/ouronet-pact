#!/usr/bin/env python3
"""THE GATE — the one runner that decides whether the REPL suite is green.

    cd REPL && python3 _gate.py [-j N]

Two jobs, and the second is the one that matters:

  1. RUN every gate entrypoint in parallel and report assertions executed / failures.
     Wall time is the slowest single entrypoint, not the sum: a `pact` run opens no
     file for writing, so runs are independent OS processes with their own in-memory
     DB (verified with strace). See REPL_TEST_ARCHITECTURE.md Rule 1.

  2. PROVE no asserting file is orphaned. An assertion that nothing executes is not
     coverage -- it is decoration that reads as coverage to a ledger and to a human.
     Every .repl carrying assertions must be reachable from a gate entrypoint or be
     explicitly, justifiably excluded below. Anything else fails the gate.

Job 2 exists because job 2 was missing. In P1 the four deb-staleness-* drivers were
archived on an "assertion-free" heuristic -- true of the drivers themselves, false of
what they LOAD. They were the only path to [6.2.7]_AQP-DEB-MTX and the [6.2.8*]
family, and moving them also broke their relative (load "Stage00_Sanboxes.repl")
paths, so they could not have run even in place. ~125 assertions silently left the
suite and the ledger never noticed, because the ledger counts files, not execution.
"""
import argparse, collections, glob, os, re, subprocess, sys, time

os.chdir(os.path.dirname(os.path.abspath(__file__)))

# --- the gate ------------------------------------------------------------------------------
GATE = (["ZALL.repl", "AQP-FULL.repl", "AQP-core-vct.repl", "triplet-collect-golden.repl"]
        + sorted(glob.glob("deb-staleness-*.repl"))
        + sorted(glob.glob("modules/*.repl")))

# --- what is deliberately NOT gated, and why ------------------------------------------------
# Each entry must carry a reason. "It is slow" is not a reason; "it is an alternative path to
# something already gated" is. Reviewing this list IS reviewing the suite's honesty.
EXCLUDED = [
    ("archive/",       "retired probes; kept for provenance, not run"),
    ("Kursan/",        "one-off finding-verification harnesses, each re-booting the full chain"),
    ("fixtures/",      "loaded BY testers, never standalone"),
    ("regressions/",   "rescued audit proofs with their own runner (regressions/run.sh)"),
    ("_scratch_",      "single-question scratch probes"),
    ("_probe",         "single-question scratch probes"),
    ("_audit_",        "one-off audit baselines"),
    ("_cov_draft",     "coverage tooling draft"),
    ("Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl",
                       "ALTERNATIVE to [6.2]+[6.3], both of which ZALL runs"),
    ("Stage00b_",      "Stoa bulk/gas benchmarks, not correctness suites"),
    ("Stage_02/[6.2.6]_AQP-VCT-GAS.repl",
                       "gas-ladder BENCHMARK (3 fits-in-2M assertions, not correctness). Its only "
                       "loader VCT-gas-sweep.repl was archived on the assertion-free heuristic; "
                       "restored 2026-09-09 with paths repaired, but it still fails INSIDE its own "
                       "VCTGAS probe module (XI_ProbeDpsf -> XI_MeasureVacateChunk). Excluded with "
                       "that breakage NAMED rather than hidden -- see VCT-gas-sweep.repl"),
    ("VCT-gas-sweep.repl",
                       "driver for the above; same known breakage"),
    ("AQP-comprehensive.repl",
                       "byte-identical LOAD SET to AQP-FULL.repl, which IS gated -- one of the "
                       "two is redundant and should be deleted"),
    ("launchpad-groundtruth.repl",
                       "gas-measurement driver over suites ZALL already runs"),
    ("vst-harness.repl", "exploratory VST harness superseded by modules/VST.repl"),
    ("Stage_01/[6.10]_PYTHIA-flush-gas-probe.repl", "gas probe, not a correctness suite"),
    ("Stage_02/OF-stake-smoke.repl", "smoke driver over gated suites"),
]

LOAD = re.compile(r'^\s*\(load\s+"([^"]+)"', re.M)
ASSERT = re.compile(r'\(expect\s|\(expect-failure')

def strip_comments(src):
    out, in_str, esc, i, n = [], False, False, 0, len(src)
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

def read(p):
    try: return strip_comments(open(p, errors='ignore').read())
    except OSError: return ""

def closure(root):
    seen, stack = set(), [os.path.normpath(root)]
    while stack:
        p = stack.pop()
        if p in seen or not os.path.exists(p): continue
        seen.add(p)
        for m in LOAD.finditer(read(p)):
            stack.append(os.path.normpath(os.path.join(os.path.dirname(p), m.group(1))))
    return seen

def excluded(p):
    return next((why for frag, why in EXCLUDED if frag in p), None)

def run_one(path):
    t0 = time.time()
    r = subprocess.run(["pact", path], capture_output=True, text=True)
    out = r.stdout + r.stderr
    return {"path": path, "secs": time.time() - t0,
            "pos": out.count("Expect: success"),
            "neg": out.count("Expect failure: Success"),
            "fail": out.count("FAILURE:"),
            "ok": "Load successful" in out and "Load failed" not in out,
            "tail": "\n".join(l for l in out.splitlines() if "FAILURE:" in l)[:2000]}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-j", type=int, default=os.cpu_count())
    ap.add_argument("--audit-only", action="store_true", help="orphan check only, run nothing")
    a = ap.parse_args()

    reachable = set()
    for g in GATE: reachable |= closure(g)

    orphans = []
    for p in sorted(glob.glob("**/*.repl", recursive=True)):
        p = os.path.normpath(p)
        if not ASSERT.search(read(p)): continue
        if p in reachable or excluded(p): continue
        n = len(ASSERT.findall(read(p)))
        orphans.append((n, p))

    print(f"GATE: {len(GATE)} entrypoints, {len(reachable)} files reachable")
    if orphans:
        print(f"\n!! {len(orphans)} ORPHANED asserting file(s) -- written, passing, executed by NOTHING:")
        for n, p in sorted(orphans, reverse=True): print(f"   {n:5d} assertions   {p}")
    else:
        print("orphan check: clean -- every asserting file is reachable from the gate")

    if a.audit_only: return 1 if orphans else 0

    from concurrent.futures import ThreadPoolExecutor
    print(f"\nrunning {len(GATE)} entrypoints on {a.j} workers ...\n")
    t0 = time.time()
    with ThreadPoolExecutor(max_workers=a.j) as ex:
        results = list(ex.map(run_one, GATE))
    results.sort(key=lambda r: -r["secs"])

    pos = sum(r["pos"] for r in results); neg = sum(r["neg"] for r in results)
    bad = [r for r in results if not r["ok"] or r["fail"]]
    print(f"{'secs':>7} {'+':>6} {'-':>5} {'fail':>5}  entrypoint")
    for r in results:
        print(f"{r['secs']:7.1f} {r['pos']:6d} {r['neg']:5d} {r['fail']:5d}  "
              f"{'' if r['ok'] and not r['fail'] else 'BROKEN '}{r['path']}")
    print(f"\nwall {time.time()-t0:.1f}s   executed {pos+neg} assertions ({pos} positive, {neg} negative)")
    for r in bad:
        print(f"\n--- {r['path']} ---\n{r['tail']}")
    print(("\nGATE FAILED" if bad or orphans else "\nGATE GREEN"))
    return 1 if (bad or orphans) else 0

if __name__ == "__main__":
    sys.exit(main())

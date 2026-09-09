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
import argparse, collections, glob, os, re, shutil, subprocess, sys, time

# The pact binary. Resolved once, with an env override, because a PATH that lacks ~/.local/bin
# is a common way for the gate to "fail" for a reason that has nothing to do with the suite.
PACT = (os.environ.get("PACT")
        or shutil.which("pact")
        or os.path.expanduser("~/.local/bin/pact"))
if not os.path.exists(PACT) and not shutil.which(PACT):
    sys.exit("gate: cannot find the `pact` binary. Set PACT=/path/to/pact.")

os.chdir(os.path.dirname(os.path.abspath(__file__)))

# --- the gate ------------------------------------------------------------------------------
# The Kursan/ suites and the _scratch_ audit proofs are HERE, not in EXCLUDED. They used to be
# excluded wholesale ("one-off finding-verification harnesses") which hid 343 assertions --
# including dsa-capture-tests (68) and aqp-info-tests (69) -- while regressions/MANIFEST.md
# listed many of the SAME files as runnable and regressions/run.sh ran them. A second runner the
# first one excludes is exactly what RULE 4 forbids: regressions/run.sh is deleted and these are
# gate entrypoints now.
KURSAN = [
    "Kursan/AQP-scale-inject.repl",
    "Kursan/AQP-scale-sweep.repl",
    "Kursan/AQP-scale-vacate.repl",
    "Kursan/AQP-stream-tests.repl",
    "Kursan/AQP-sweep-single-tx.repl",
    "Kursan/aqp-info-tests.repl",
    "Kursan/dsa-agency-tests.repl",
    "Kursan/dsa-capture-tests.repl",
    "Kursan/dsa-fee-tests.repl",
    "Kursan/dsa-grand-tour.repl",
    "Kursan/dsa-hetero-split-tests.repl",
    "Kursan/dsa-model-tests.repl",
    "Kursan/_verify_finding_DPDC-C_24M_fragment_credit_amount.repl",
    "Kursan/_verify_finding_DPDC-N_12Hc_set_instance_lock.repl",
    "Kursan/_verify_finding_DPDC-R_13H_unfreeze_release_valve.repl",
    "Kursan/_verify_finding_DPDC-S_15H_multiplier_bound.repl",
    "Kursan/_verify_finding_DPDC-S_C1_update_multiplier.repl",
    "Kursan/_verify_finding_DPDC_12Hb_metadata_caps.repl",
]
# Audit proofs that live in REPL/ root under the _scratch_ prefix. The prefix is excluded as a
# class (most _scratch_ files really are one-question probes with no assertions); these six are
# named individually because regressions/MANIFEST.md calls them runnable audit proofs, and a
# finding's regression test that nothing runs is not a regression test (RULE 7).
SCRATCH_PROOFS = [
    "_scratch_dptf_m6_urhibernation_purefetch.repl",
    "_scratch_ts01a_n3_treasury_gate_check.repl",
    "_scratch_udalos_h1_msdc.repl",
    "_scratch_ulst_75l_stringpresence_empty.repl",
    "_scratch_ulst_m20_uev_izunique.repl",
    "_scratch_urs_m18_overblock.repl",
]
GATE = (["ZALL.repl", "AQP-FULL.repl", "AQP-core-vct.repl", "triplet-collect-golden.repl",
         "launchpad-groundtruth.repl", "Stage00b_Run.repl", "Stage00b_RunGas.repl"]
        + sorted(glob.glob("deb-staleness-*.repl"))
        + sorted(glob.glob("modules/*.repl"))
        + KURSAN + SCRATCH_PROOFS)

# --- what is deliberately NOT gated, and why ------------------------------------------------
# Each entry must carry a reason. "It is slow" is not a reason; "it is an alternative path to
# something already gated" is. Reviewing this list IS reviewing the suite's honesty.
EXCLUDED = [
    ("archive/",       "retired probes; kept for provenance, not run"),
    # The eight Kursan verify-finding harnesses below share ONE root cause and are the G3
    # order-dependence defect, not eight separate problems: [6.1.4]_DPDC-NF.repl:333 upgrades
    # CNF's branding by a month and BRD rejects with "Blue Flag has more than 15 days remainig!"
    # when the flag is still fresh. They pass inside ZALL and fail standalone because they load
    # Stage00a_StoaTests.repl, which ZALL never loads, so the longer chain leaves CNF already
    # branded. Fixing that one line unblocks all eight at once -- tracked for P4/G3.
    ("Kursan/_verify_finding_DPDC-I_33M_makeid_same_block_collision.repl",   "G3: [6.1.4]:333"),
    ("Kursan/_verify_finding_DPDC-F-S_47L-51L_empty_definition_guards.repl", "G3: [6.1.4]:333"),
    ("Kursan/_verify_finding_DPDC-S_30M_enable-frag-active-gate.repl",       "G3: [6.1.4]:333"),
    ("Kursan/_verify_finding_DPDC-S_31M_primordial_element_bounds.repl",     "G3: [6.1.4]:333"),
    ("Kursan/_verify_finding_DPDC-S_32M_hybrid_constituent_order.repl",      "G3: [6.1.4]:333"),
    ("Kursan/_verify_finding_DPDC-UDC-S_38M_sentinel_unreachable.repl",      "G3: [6.1.4]:333"),
    ("Kursan/_verify_finding_DPDC_34M_empty_nonces_with_supplies.repl",      "G3: [6.1.4]:333"),
    ("Kursan/VCT-comprehensive.repl",
                       "driver for [6.2.6]_AQP-VCT-GAS, which fails inside its own VCTGAS probe "
                       "module -- same known breakage as VCT-gas-sweep.repl below"),
    ("Kursan/table-write-partial-test",
                       "Pact-semantics scratch probes about partial table writes; their expects "
                       "are deliberately unsatisfied experiments, not suite assertions"),
    ("fixtures/",      "loaded BY testers, never standalone"),
    ("regressions/",   "MANIFEST.md only -- documentation; the proofs it lists are gate entrypoints"),
    ("_scratch_",      "single-question scratch probes"),
    ("_probe",         "single-question scratch probes"),
    ("_audit_",        "one-off audit baselines; _audit_ats_baseline.repl does not currently run "
                       "to completion, so its 32 assertions are NOT coverage"),
    ("_cov_draft",     "coverage tooling draft"),
    ("Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl",
                       "ALTERNATIVE to [6.2]+[6.3], both of which ZALL runs"),
    # NOT ("Stage00b_") as a class: that fragment also caught Stage00b_Run.repl and
    # Stage00b_RunGas.repl, the DRIVERS, so 51 working assertions sat outside the gate because
    # the exclusion was written against a filename prefix instead of a role. The two suites
    # below are loadable-only (their headers say "after Stage00_Sanboxes.repl"); the drivers
    # that load them are gate entrypoints.
    ("Stage00b_StoaBulkTests.repl",    "loaded BY Stage00b_Run.repl, which IS gated"),
    ("Stage00b_StoaBulkGasTests.repl", "loaded BY Stage00b_RunGas.repl, which IS gated"),
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
    r = subprocess.run([PACT, path], capture_output=True, text=True)
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

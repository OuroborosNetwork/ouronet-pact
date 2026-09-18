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

os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# --- the gate ------------------------------------------------------------------------------
# The Kursan/ suites and the _scratch_ audit proofs are HERE, not in EXCLUDED. They used to be
# excluded wholesale ("one-off finding-verification harnesses") which hid 343 assertions --
# including dsa-capture-tests (68) and aqp-info-tests (69) -- while regressions/MANIFEST.md
# listed many of the SAME files as runnable and regressions/run.sh ran them. A second runner the
# first one excludes is exactly what RULE 4 forbids: regressions/run.sh is deleted and these are
# gate entrypoints now.
KURSAN = [
    # The seven verify-finding harnesses, re-included 2026-09-11 after the two G3 causes were fixed
    # (see the note in EXCLUDED below). Each verified to load standalone before being added here.
    "Kursan/_verify_finding_DPDC-F-S_47L-51L_empty_definition_guards.repl",
    "Kursan/_verify_finding_DPDC-I_33M_makeid_same_block_collision.repl",
    "Kursan/_verify_finding_DPDC-S_30M_enable-frag-active-gate.repl",
    "Kursan/_verify_finding_DPDC-S_31M_primordial_element_bounds.repl",
    "Kursan/_verify_finding_DPDC-S_32M_hybrid_constituent_order.repl",
    "Kursan/_verify_finding_DPDC-UDC-S_38M_sentinel_unreachable.repl",
    "Kursan/_verify_finding_DPDC_34M_empty_nonces_with_supplies.repl",
    # Open finding (2026-09-11): TFT multi-transfer dies on an EMPTY leg list, reachable via
    # ATSU royalty withdrawal on a pool with nothing accrued. Loads Stage-1 deploys only.
    "Kursan/_verify_finding_EMPTY-LIST_01_index_iterating_cumulators.repl",
    # Security claim (2026-09-11): TS01-C2 ORBR|C_WithdrawFees' @doc says "Only the Token Owner
    # can withdraw these fees" -- true, and previously untested. Needs the [6.2]_DPTF chain,
    # the only one that produces a token with ACCRUED fees. Found by _docclaims.py.
    "Kursan/_verify_finding_ORBR-FEE_01_withdraw_ownership.repl",
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
        # RED TEAM. Globbed like modules/, so a new attack file is gated the moment it exists and
        # cannot sit outside the suite unnoticed -- which for adversarial work matters more than
        # for constructive work: an attack nobody runs is indistinguishable from an attack that
        # was refused. Underscore-prefixed files here are scratch and are rejected by the same
        # guard that policies modules/ (see the scratch check in main()).
        + sorted(f for f in glob.glob("RedTeam/*.repl")
                 if not os.path.basename(f).startswith("_"))
        + KURSAN + SCRATCH_PROOFS)

# --- what is deliberately NOT gated, and why ------------------------------------------------
# Each entry must carry a reason. "It is slow" is not a reason; "it is an alternative path to
# something already gated" is. Reviewing this list IS reviewing the suite's honesty.
EXCLUDED = [
    ("archive/",       "retired probes; kept for provenance, not run"),
    # G3 order-dependence — RESOLVED 2026-09-11, all seven harnesses re-included.
    #
    # They failed standalone for TWO independent reasons, not the one this note used to name:
    #
    #   1  BRANDING TIME. BRD allows an upgrade only under 15 days of remaining premium
    #      (04_BRD.pact:258). THREE suites called it unconditionally -- [6.1.4]_DPDC-NF:333,
    #      [6.1.6]_DPOF:73, [6.1.7]_DPSF-UPDATES:97 -- and each aborted its whole file wherever the
    #      flag was still fresh. All three now ask BRD's own question and skip when the upgrade is
    #      not yet permitted. Each is a print-only smoke step; verified no-ops in the gated chains.
    #
    #   2  CREATE-ROLE OWNERSHIP. DPSF set definitions reach DPDC-C|C>REGISTER-NONCES, which enforces
    #      ownership of the collection's NFT CREATE-ROLE account (DPDC-C.pact:288, UR_Verum5) -- not
    #      the collection owner. DHCD is owned by ANHD but its create role sits with EMMA, so two
    #      harnesses signing only as the patron failed a gate unrelated to the patron. Both now sign
    #      as both.
    #
    # A third harness (_DPDC-I_33M) also asserted an outcome the code does not produce: it expected a
    # same-ticker NFT issuance to SUCCEED because DPNF and DPSF have separate properties tables. It
    # aborts instead, in BRD|BrandingTable -- which is keyed on the bare id and SHARED across every
    # collection type, so per-type separation does not give cross-type id independence. Now pinned as
    # the behaviour it actually has.
    # REASON CORRECTED 2026-09-14. It previously read "fails inside its own VCTGAS probe module --
    # same known breakage as VCT-gas-sweep.repl", which is not what happens and was never checked.
    # The file dies at its FIRST load, before any Ouronet code runs:
    #     pact: Kursan/Stage00_Sanboxes.repl: openFile: does not exist
    # Its loads are written relative to the REPL root (`(load "Stage00_Sanboxes.repl")`) while it
    # lives in Kursan/, where every working sibling uses `../`. It was moved into Kursan/ and its
    # paths were never fixed, so it has never run from here at all. A wrong exclusion reason is
    # worse than no reason: it sends the next person to debug a probe module that is never reached.
    # NOT repaired, because nothing is lost by leaving it: [6.2.6]_AQP-VCT-GAS.repl is loaded by
    # three LIVE gate entrypoints (Kursan/AQP-scale-{inject,vacate,sweep}.repl), so its coverage is
    # in the gate regardless. Repair it only if the comprehensive driver is wanted for its own sake.
    ("Kursan/VCT-comprehensive.repl",
                       "load paths are relative to the REPL root but the file lives in Kursan/, so "
                       "it aborts on its first (load) -- verified 2026-09-14; its [6.2.6] coverage "
                       "is already in the gate via the three Kursan/AQP-scale-*.repl entrypoints"),
    ("Kursan/table-write-partial-test",
                       "Pact-semantics scratch probes about partial table writes; their expects "
                       "are deliberately unsatisfied experiments, not suite assertions"),
    ("fixtures/",      "loaded BY testers, never standalone"),
    ("regressions/",   "MANIFEST.md only -- documentation; the proofs it lists are gate entrypoints"),
    ("_scratch_",      "single-question scratch probes"),
    ("_probe",         "single-question scratch probes"),
    # 2026-09-14: the 18 UNGATED probes that used to sit at the REPL root were moved into
    # archive/, which is excluded for the same reason ("retired probes, kept for provenance").
    # The SIX gated ones in SCRATCH_PROOFS above stay at the root, because they ARE coverage and
    # a reader should not have to know that one archive/ file is live and seventeen are not.
    ("_audit_",        "one-off audit baselines; archive/_audit_ats_baseline.repl does not run "
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

    # FRESHNESS HEADER, flushed before any work. This exists because of a real incident on
    # 2026-09-14: the gate was launched as `cd REPL && ... python3 _gate.py > /tmp/gateN.log`
    # from a shell ALREADY inside REPL/. The `cd` failed, `&&` short-circuited, _gate.py never
    # ran -- and a log from a PREVIOUS session was still sitting at that path, ending in
    # "GATE GREEN". The trailing `; echo rc=$?` reported success for the echo. A stale green was
    # read as a fresh green and a genuine failure ([6.1] TX-IGC-008) stayed hidden for hours.
    #
    # Two properties fix that, and both are needed. This line is written FIRST and flushed, so a
    # log that lacks it never started; and it carries a wall-clock stamp, so a log that is merely
    # OLD is visible as old without having to stat the file. Anything reading a gate log -- human
    # or otherwise -- should check this line before believing the verdict at the bottom.
    # (No cwd guard here: line 35 already chdirs to this file's own directory, so the gate is
    # cwd-INDEPENDENT -- `python3 REPL/_gate.py` works from anywhere and the `cd REPL &&` that
    # caused the incident was never needed in the first place. A guard on cwd would be unreachable
    # code dressed as protection, which is the same shadowed-guard pattern _shadowed.py exists to
    # find. The header below is the whole defence, and it is sufficient: no header, no run.)
    print(f"GATE RUN STARTED {time.strftime('%Y-%m-%d %H:%M:%S')} "
          f"(pid {os.getpid()})", flush=True)

    # Scratch probes. Iterating on this suite means dropping a throwaway loader in modules/ to see
    # what a function does; modules/*.repl is GLOBBED into the gate, so a forgotten one runs as a
    # real entrypoint. That happened -- a probe full of deliberately-wrong expected messages failed
    # the gate 200 seconds in. Failing here instead costs nothing and names the file. Convention:
    # anything in modules/ starting with `_` is scratch and must be deleted before a gate run.
    # `Kursan/` is globbed too, and on 2026-09-12 a probe landed there instead of in modules/ --
    # outside this guard's reach. Kursan's own underscore files follow one convention,
    # `_verify_finding_*`, so anything else starting with `_` there is scratch by the same rule.
    # (The orphan check later would also catch an asserting leftover, but only AFTER the orphan scan
    # and with a message about reachability rather than "you forgot to delete this".)
    _scratch = (sorted(glob.glob("modules/_*.repl"))
                + sorted(glob.glob("RedTeam/_*.repl"))
                + sorted(f for f in glob.glob("Kursan/_*.repl")
                         if not os.path.basename(f).startswith("_verify_finding_")))
    if _scratch:
        sys.exit("GATE FAILED: leftover scratch loader(s) -- delete before running:\n"
                 + "\n".join(f"   {x}" for x in _scratch))

    # The Stage-Z testing variant is GENERATED from canonical (see _stagez_variant.py). If canonical
    # moved and the variant was not regenerated, the STAGE-Z assertions are testing a stale copy and
    # would still go green -- so this must fail the gate, not warn.
    _sv = subprocess.run([sys.executable, "tools/_stagez_variant.py", "--check"],
                         capture_output=True, text=True)
    if _sv.returncode != 0:
        print(_sv.stdout + _sv.stderr)
        sys.exit("GATE FAILED: Stage-Z testing variant is stale vs canonical.")

    # BATCH LADDER TILING. The citizen minters encode their mint plan as literals inside one-line
    # A_StepNN / A_FixNN wrappers, and no .repl can read a literal -- it can only execute a rung.
    # So a mis-tiled ladder (gap, overlap, or an over-budget rung that cannot fit in a transaction)
    # is invisible to the suite no matter how green it is. Found exactly that on 2026-09-14:
    # NOSFERATU A_Fix01 read `Legendary 1 100` against its twin A_Step01's `1 70`, double-covering
    # thirty positions. Static property, static check, and it fails the gate rather than warning.
    _ld = subprocess.run([sys.executable, "tools/_ladder.py", "--check"], capture_output=True, text=True)
    if _ld.returncode != 0:
        print(_ld.stdout + _ld.stderr)
        sys.exit("GATE FAILED: a citizen minter batch ladder does not tile its collection.")

    # WRONG-COLUMN PROJECTIONS. A projecting `read` naming a column its table's schema lacks is
    # not an error in Pact -- it returns {} and fails one call later as `Key "x" not found in
    # object: {}`, which reads like a missing ROW. Found exactly that in AOZ (UR_NonFungible
    # projected the SemiFungible column), where it made a registry write-only through the public
    # interface. Total failures delete their own evidence: a function that never works is never
    # called, so no test is left to notice. Static shape, static check.
    _cp = subprocess.run([sys.executable, "tools/_colproj.py", "--check"], capture_output=True, text=True)
    if _cp.returncode != 0:
        print(_cp.stdout + _cp.stderr)
        sys.exit("GATE FAILED: a projecting read names a column its table does not have.")

    # RED-TEAM HEADER INTEGRITY. Every block in RedTeam/ must carry a parsable FAMILY/STATUS
    # header, because the attack register is built from those and an attack that is not counted
    # may as well not have been run. This fails the gate rather than warning: a malformed header
    # silently shrinks the register, and a shrinking register looks exactly like a clean one.
    _rt = subprocess.run([sys.executable, "tools/_redteam.py", "--check"], capture_output=True, text=True)
    if _rt.returncode != 0:
        print(_rt.stdout + _rt.stderr)
        sys.exit("GATE FAILED: a RedTeam/ block has a malformed or duplicate attack header.")

    # FIGURE SYNC. The narrative audit documents restate REPL_SUITE_STATS.md's headline numbers
    # inline, because a published paper wants the figure on the page rather than a cross-reference.
    # Those two copies drifted apart FOUR TIMES during 2026-09-14/15, and on the fourth the stale
    # copy was `gate entrypoints | 77` sitting in the round report's HEADLINE TABLE -- a number from
    # before the RedTeam suites existed, in a document that said 86 three other times. Each earlier
    # reconciliation had grepped for the specific stale values already known about, which finds the
    # drift you suspect and not the drift you do not. Fatal, because a stale figure reads exactly as
    # authoritative as a fresh one, and this is the project's own rule about quoted numbers.
    _fs = subprocess.run([sys.executable, "tools/_figuresync.py", "--check"], capture_output=True, text=True)
    if _fs.returncode != 0:
        print(_fs.stdout + _fs.stderr)
        sys.exit("GATE FAILED: an audit document quotes a figure the generated stats do not support.")

    # PRICE SYNC -- the GENERATED pricing artefacts must equal what their generators emit.
    # _figuresync guards ARCHITECTURE/*.md against the suite stats; it does not look at
    # IGNIS-PRICING/, and that is exactly where the worst rot was found on 2026-09-15: both
    # generators had been DEAD since the tools move, the artefacts were stale by the X-04 rename,
    # and their `Regenerate:` lines had been hand-corrected to name a command that crashed.
    _ps = subprocess.run([sys.executable, "tools/_pricesync.py", "--check"],
                         capture_output=True, text=True)
    if _ps.returncode != 0:
        print(_ps.stdout + _ps.stderr)
        sys.exit("GATE FAILED: a generated pricing artefact does not match its generator.")

    # TOOL PATH INTEGRITY -- static, executes nothing (several tools rewrite source at import).
    # The 2026-09-14 tools move killed ELEVEN tools by leaving hard-coded sibling paths behind;
    # they died at module level, so "verified by output diffing" could not see them -- a dead tool
    # produces no output to diff. Two generated audit artefacts drifted underneath for a full day.
    # Validated by running it against a worktree of the pre-repair commit: 11 of 11 caught.
    _tp = subprocess.run([sys.executable, "tools/_toolpaths.py", "--check"],
                         capture_output=True, text=True)
    if _tp.returncode != 0:
        print(_tp.stdout + _tp.stderr)
        sys.exit("GATE FAILED: a tool references a path that does not exist.")

    # PREFIX SYNC -- every function prefix live in the tree must be classifiable by the tool that
    # reasons about prefixes. The vocabulary is hand-maintained in each tool and nothing re-derived
    # it from the source, so on 2026-09-15 the SAME three prefixes (URv_/XIv_/XBv_) were missing
    # from two independent tools: the price-sheet walker dropped five ops, and canon_check reported
    # six files as drift that were not drift.
    _px = subprocess.run([sys.executable, "tools/_prefixsync.py", "--check"],
                         capture_output=True, text=True)
    if _px.returncode != 0:
        print(_px.stdout + _px.stderr)
        sys.exit("GATE FAILED: a live function prefix is unknown to tools/skeleton.py.")

    # EAGER-LET SHADOWS -- an `enforce` that cannot fire because a hard read in the same binding
    # group consumes its subject first. This is the dominant failure mode of the 2026-09 audit:
    # locating the real first raiser by READING rather than executing reached a wrong conclusion in
    # four separate investigations, two of which were repairs to guards that could never speak.
    # Gated on the NOT-YET-ANNOTATED count, not on existence: a shadow is sometimes deliberate, so
    # the requirement is that every instance has been LOOKED AT. See the limitation note in the tool
    # -- its alarm path is not self-demonstrated, and that is stated there rather than assumed away.
    _el = subprocess.run([sys.executable, "tools/_eagerlet.py", "--check"],
                         capture_output=True, text=True)
    if _el.returncode != 0:
        print(_el.stdout + _el.stderr)
        sys.exit("GATE FAILED: an enforce is shadowed by an eager hard read, unannotated.")

    # AUDIT BOOK TABLES -- the book's headline tables must sum to their own totals, and Part III's
    # must match the attack register in the tree. Added 2026-09-17 after Part I's verification pass
    # found an audit tracker that said "FIXED: 19" while enumerating 18, with a compensating
    # off-by-one elsewhere so the TOTAL RECONCILED -- which is exactly why nobody re-counted the
    # parts. A book whose third stated rule is about counts should not contain a table that does not
    # add up, and it is the sort of thing no reviewer checks because it looks like it must be right.
    _bt = subprocess.run([sys.executable, "tools/_booktables.py", "--check"],
                         capture_output=True, text=True)
    if _bt.returncode != 0:
        print(_bt.stdout + _bt.stderr)
        sys.exit("GATE FAILED: an Audit Book table does not add up.")

    # AUDIT BOOK ASSEMBLY -- the single-file book is a GENERATED artefact, and this is the same
    # closed loop `_pricesync` enforces for the price sheet. Without it, the published .md silently
    # becomes a snapshot of chapter sources that have since moved -- and since it is the artefact a
    # reader actually receives, that drift is invisible to everyone except the person who rebuilds.
    # It also fails on a stale CROSS-REFERENCE: chapter sources may not write "Chapter 17" literally,
    # because consolidating per-part numbering into one volume already invalidated 45 of them once.
    _ab = subprocess.run([sys.executable, "tools/_auditbook.py", "--check"],
                         capture_output=True, text=True)
    if _ab.returncode != 0:
        print(_ab.stdout + _ab.stderr)
        sys.exit("GATE FAILED: the assembled Audit Book is stale against its chapter sources.")

    # DOCX REFERENCE -- the Audit Book's .docx page geometry, running header and page-number
    # footer live in Audit/book/reference.docx, because pandoc has no flags for any of them. It is
    # a 10 KB zip of XML: invisible to review, and `git diff` says only "Binary files differ". If
    # it goes missing or is hand-edited, the next --docx build silently produces a document with
    # pandoc's default geometry and NO page numbers, and nothing else would notice.
    _dx = subprocess.run([sys.executable, "tools/_docxref.py", "--check"],
                         capture_output=True, text=True)
    if _dx.returncode != 0:
        print(_dx.stdout + _dx.stderr)
        sys.exit("GATE FAILED: the Audit Book's docx reference is missing or has drifted.")

    # TOOL INDEX -- TOOLS.md must list every tool on disk. It had drifted to 50 rows against 53
    # tools, and the three missing were _auditbook, _booktables and _modref: all GATE-FATAL. The
    # working agreement says to read TOOLS.md rather than run a tool to find out what it does, so a
    # missing row does not merely omit information -- it routes the reader into the hazard the rule
    # exists to prevent.
    _ti = subprocess.run([sys.executable, "tools/_toolindex.py", "--check"],
                         capture_output=True, text=True)
    if _ti.returncode != 0:
        print(_ti.stdout + _ti.stderr)
        sys.exit("GATE FAILED: TOOLS.md does not index every tool on disk.")

    # MODREF MEMBERS -- fatal only on LIVE class-B: a `(ref-X::member ...)` call where `member` is
    # defined NOWHERE in the module implementing X. Pact 5 resolves modref members DYNAMICALLY, so
    # such a call loads and runs, and only raises if that branch is ever taken -- invisible to every
    # other check here. Measured at introduction (2026-09-17): 13, ALL inside the legacy 00_DPMF,
    # which CLAUDE.md marks KEEP AS IS. Live code: ZERO. That zero is what this gates.
    # Deliberately NOT gated: the 165 live calls to members that exist but are not DECLARED on the
    # interface. A reviewer filed one of those as a coupling defect; measuring the population showed
    # it is the convention CLAUDE.md describes ("interfaces carry nearly the full public API"), and
    # fixing the single instance would have made the tree less consistent, not more.
    _mr = subprocess.run([sys.executable, "tools/_modref.py", "--check"],
                         capture_output=True, text=True)
    if _mr.returncode != 0:
        print(_mr.stdout + _mr.stderr)
        sys.exit("GATE FAILED: a modref calls a member that does not exist in the implementer.")

    # VACUOUS ASSERTIONS -- fatal on VACUOUS only; WEAK stays advisory.
    # An assertion that cannot fail is a green light wired to nothing, and it is indistinguishable
    # from a real one in every summary the gate prints: it counts toward the 21,519, it shows in the
    # `+` column, and it never goes red. Measured 2026-09-15 across 4,219 positive `expect` sites:
    # 0 vacuous, 12 weak. Gating it keeps that 0 a fact rather than a memory.
    _vc = subprocess.run([sys.executable, "tools/_vacuous.py", "--check"],
                         capture_output=True, text=True)
    if _vc.returncode != 0:
        print(_vc.stdout + _vc.stderr)
        sys.exit("GATE FAILED: a positive assertion cannot fail (vacuous).")

    # CONFORMANCE and HEAVY-PREFIX, both fatal on VIOLATIONS only.
    # ADDED 2026-09-14, after a fix-verification pass found that both tools' "0" was a
    # HAND-MEASURED figure. The gate byte-compiled them and ran conformance's selftest, but never
    # ran either tool -- so re-introducing X-02 (`ORBR|A_Fuel` gated only by a self-granting
    # `SECURE`, VERIFIED EXPLOITABLE before it was fixed) or X-04 (a single-prefixed `C_`/`A_`
    # whose tree reaches a heavy `URH_` scan) would have left the gate GREEN.
    #
    # The principle, and it generalises past these two: a number quoted in an audit document as
    # evidence of a repair must be one the gate RE-DERIVES on every run. Otherwise it is a claim
    # about the past, and the repair it certifies can be undone without anything going red.
    #
    # Both are deliberately fatal on VIOLATIONS ONLY. Conformance carries 114 OBSERVATIONS (where
    # the documentation is narrower than correct practice) and _heavy also reports an over-budget
    # inventory; failing on those would make the check unusable and therefore ignored.
    for _tool, _why in (("_conformance.py", "conformance violation(s)"),
                        ("_heavy.py", "a single-prefixed C_/A_ reaching a heavy read")):
        _r = subprocess.run([sys.executable, "tools/" + _tool, "--check"],
                            capture_output=True, text=True)
        if _r.returncode != 0:
            print(_r.stdout + _r.stderr)
            sys.exit(f"GATE FAILED: {_why} -- see {_tool}.")

    # TOOL INTEGRITY. Every analysis tool lives in `tools/` as a `_*.py`; none of them is imported
    # by the gate, so a syntax error in one is INVISIBLE here. That is not hypothetical -- on
    # 2026-09-12 an edit to `_conformance.py`'s rule text left an unescaped quote inside a string,
    # and the gate went GREEN TWICE before anyone ran the tool. A green gate was reporting on a
    # suite whose conformance checker could not start.
    #
    # So: byte-compile every tool, and run `--selftest` on the ones that have it. Compiling is the
    # part that catches the failure above; the selftests are the part that catches a rule quietly
    # matching nothing. Both are seconds. A tool that cannot run is worse than a missing tool,
    # because its silence reads as "clean".
    _tools = sorted(t for t in glob.glob("tools/_*.py")
               if os.path.basename(t) != os.path.basename(__file__))
    _broken = []
    for t in _tools:
        r = subprocess.run([sys.executable, "-m", "py_compile", t], capture_output=True, text=True)
        if r.returncode != 0:
            _broken.append(f"   {t}: will not compile\n{r.stderr.strip()}")
    if _broken:
        sys.exit("GATE FAILED: analysis tool(s) are broken -- their silence would read as clean:\n"
                 + "\n".join(_broken))
    _st_failed = []
    for t in _tools:
        if "--selftest" not in read(t):
            continue
        r = subprocess.run([sys.executable, t, "--selftest"], capture_output=True, text=True)
        if r.returncode != 0:
            _st_failed.append(f"   {t} --selftest exited {r.returncode}\n{(r.stdout + r.stderr).strip()}")
    if _st_failed:
        sys.exit("GATE FAILED: analysis tool selftest(s) failed:\n" + "\n".join(_st_failed))

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

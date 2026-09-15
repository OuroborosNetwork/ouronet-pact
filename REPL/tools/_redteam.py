#!/usr/bin/env python3
"""
REPL/_redteam.py -- the ATTACK REGISTER: what was attempted, and what happened.

WHY THIS EXISTS. "We red-teamed it" is unfalsifiable on its own, and an adversarial suite is
uniquely bad at self-reporting: an attack that was never written and an attack that was refused
both show up as a green gate. The only honest summary is a register of attempts, so this parses
the structured header every block in RedTeam/ is required to carry and counts them by family and
outcome. A block with no header is NOT counted, and is reported as an error -- an uncounted attack
may as well not have been run.

Header shape (see RedTeam/README.md):

    ;;<<RT-A-001>> FAMILY: A | STATUS: FIXED
    ;;HYPOTHESIS: ...
    ;;METHOD:     ...
    ;;RESULT:     ...

    python3 REPL/_redteam.py             # the register
    python3 REPL/_redteam.py --md        # Markdown, for the audit report
    python3 REPL/_redteam.py --check     # exit 1 on a malformed or duplicate header
    python3 REPL/_redteam.py --selftest
"""
import glob, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FAMILIES = {
    "A": "Arithmetic & value",
    "B": "Permissionless reach",
    "C": "Admin impersonation",
    "D": "Ownership bypass",
    "E": "Sequencing & state",
    "F": "Griefing / denial of service",
    "G": "Hostile citizen module",
    "H": "Input domain",
    "I": "Gas station payable surface",
    "J": "Ledger conservation",
    "K": "Preview/exec divergence",
}
STATUSES = ["SUCCEEDED", "FIXED", "REFUSED", "ACCEPTED", "UNREACHABLE"]
# A-Z, not A-H (2026-09-15). The range was hard-coded to the families that existed when the
# tool was written, and BOTH the header regex and the malformed-header scan below used it.
# So adding family I produced NOTHING: not a row, not an error, not a warning -- the register
# reported 9 attacks and said nothing about the 10th. Same shape as the price sheet's
# write-only `skipped` counter and canon_check's `diff[:8]`: a checker silently narrowing to
# the region it was told about. An unknown family is now an ERROR, which is the only way a
# hard-coded list can fail safely.
HDR = re.compile(
    r';;<<(RT-([A-Z])-\d{3})>>\s*FAMILY:\s*([A-Z])\s*\|\s*STATUS:\s*([A-Z]+)\s*\n'
    r'\s*;;HYPOTHESIS:\s*(.+?)\n(?=\s*;;METHOD:)', re.S)

def scan_text(src, where="<mem>"):
    out, errs = [], []
    for m in HDR.finditer(src):
        tag, tagfam, fam, status, hyp = m.groups()
        if tagfam != fam:
            errs.append(f"{where}: {tag} says FAMILY {fam} but its id encodes {tagfam}")
        if status not in STATUSES:
            errs.append(f"{where}: {tag} has STATUS {status}, not one of {STATUSES}")
        if fam not in FAMILIES:
            errs.append(f"{where}: {tag} has unknown FAMILY {fam}")
        out.append({"tag": tag, "family": fam, "status": status,
                    "hypothesis": " ".join(hyp.replace(";;", " ").split()), "file": where})
    # a block tagged <<RT-...>> with no parsable header is the failure mode that matters
    for m in re.finditer(r';;<<(RT-[A-Z]-\d{3})>>', src):
        if not any(r["tag"] == m.group(1) for r in out):
            errs.append(f"{where}: {m.group(1)} has no parsable FAMILY/STATUS/HYPOTHESIS header")
    return out, errs

def collect():
    rows, errs = [], []
    for p in sorted(glob.glob(os.path.join(ROOT, "RedTeam", "*.repl"))):
        r, e = scan_text(open(p, errors="ignore").read(), os.path.relpath(p, ROOT))
        rows += r; errs += e
    seen = {}
    for r in rows:
        if r["tag"] in seen:
            errs.append(f"duplicate attack id {r['tag']} ({seen[r['tag']]} and {r['file']})")
        seen[r["tag"]] = r["file"]
    return rows, errs

def selftest():
    good = (';;<<RT-A-001>> FAMILY: A | STATUS: FIXED\n;;HYPOTHESIS: a thing\n;;METHOD: x\n')
    r, e = scan_text(good)
    if len(r) != 1 or e:
        print(f"SELFTEST FAILED: a well-formed header did not parse cleanly: {r} {e}"); return 1
    r, e = scan_text(';;<<RT-A-002>> FAMILY: B | STATUS: FIXED\n;;HYPOTHESIS: y\n;;METHOD: x\n')
    if not any("encodes" in x for x in e):
        print("SELFTEST FAILED: family/id mismatch not detected"); return 1
    r, e = scan_text(';;<<RT-A-003>> FAMILY: A | STATUS: BOGUS\n;;HYPOTHESIS: y\n;;METHOD: x\n')
    if not any("STATUS" in x for x in e):
        print("SELFTEST FAILED: bad STATUS not detected"); return 1
    r, e = scan_text(';;<<RT-A-004>> some block with no header at all\n')
    if not any("no parsable" in x for x in e):
        print("SELFTEST FAILED: a tagged block with no header was not reported"); return 1
    print("selftest ok -- parses a good header, rejects family mismatch, bad status, missing header")
    return 0

# ---------------------------------------------------------------------------------------------
# REGISTER SYNC. RED-TEAM-REPORT.md restates this register as a table, because a published report
# wants the figure on the page rather than a cross-reference. That hand-typed copy said
# "total 9 attacks" on 2026-09-15 when the tool said 14 -- it had drifted five attacks, silently,
# because NOTHING compared the two. `_figuresync.py` guards ARCHITECTURE/*.md against the suite
# stats; it has no opinion about the attack register. So the register is now GENERATED into the
# report between markers, and `--check` diffs it, exactly like the pricing artefacts.
#
# A MISSING marker is an ERROR, not a pass. That is the _figuresync lesson: a checker whose
# coverage silently drops to zero reports "clean" about the thing it just stopped looking at.
# ---------------------------------------------------------------------------------------------
REPORT = os.path.join(ROOT, "..", "OuronetInformational", "ARCHITECTURE", "RED-TEAM-REPORT.md")
BEGIN = "<!-- REGISTER:BEGIN (generated by REPL/tools/_redteam.py --sync; do not hand-edit) -->"
END = "<!-- REGISTER:END -->"

def build_register_md(rows):
    by_fam = {}
    for r in rows:
        by_fam.setdefault(r["family"], []).append(r)
    out = ["| family | attempted | succeeded | fixed | refused |",
           "|---|---:|---:|---:|---:|"]
    tot = {s: 0 for s in STATUSES}
    for f in sorted(FAMILIES):
        g = by_fam.get(f, [])
        if not g:
            continue
        c = {s: sum(1 for x in g if x["status"] == s) for s in STATUSES}
        for s in STATUSES:
            tot[s] += c[s]
        cell = lambda n: (str(n) if n else "")
        out.append(f"| {f} \u2014 {FAMILIES[f]} | {len(g)} | {cell(c['SUCCEEDED'])} | "
                   f"{cell(c['FIXED'])} | {cell(c['REFUSED'])} |")
    out.append(f"| **total** | **{len(rows)}** | **{tot['SUCCEEDED']}** | "
               f"**{tot['FIXED']}** | **{tot['REFUSED']}** |")
    return "\n".join(out)

def sync_report(rows, write):
    """Return (ok, message). Rewrites or verifies the register table inside RED-TEAM-REPORT.md."""
    path = os.path.normpath(REPORT)
    if not os.path.exists(path):
        return False, f"register sync: {path} does not exist"
    src = open(path, encoding="utf-8").read()
    if BEGIN not in src or END not in src:
        return False, ("register sync: RED-TEAM-REPORT.md is missing the REGISTER markers -- "
                       "the register table is UNCHECKED. Re-insert both markers around it.")
    head, rest = src.split(BEGIN, 1)
    _, tail = rest.split(END, 1)
    want = BEGIN + "\n" + build_register_md(rows) + "\n" + END
    have = BEGIN + rest.split(END, 1)[0] + END
    if want == have:
        return True, "register sync: ok"
    if write:
        open(path, "w", encoding="utf-8").write(head + want + tail)
        return True, "register sync: wrote RED-TEAM-REPORT.md"
    return False, ("register sync: RED-TEAM-REPORT.md's register table does not match the "
                   "attack register. Regenerate with: python3 REPL/tools/_redteam.py --sync")


if __name__ == "__main__":
    if "--selftest" in sys.argv:
        sys.exit(selftest())
    rows, errs = collect()
    md = "--md" in sys.argv
    by_fam = {}
    for r in rows:
        by_fam.setdefault(r["family"], []).append(r)
    if md:
        print("| family | attempted | succeeded | fixed | refused | accepted | unreachable |")
        print("|---|---:|---:|---:|---:|---:|---:|")
    else:
        print("ATTACK REGISTER")
    for f in sorted(FAMILIES):
        g = by_fam.get(f, [])
        c = {s: sum(1 for x in g if x["status"] == s) for s in STATUSES}
        line = (f"| {f} — {FAMILIES[f]} | {len(g)} | {c['SUCCEEDED']} | {c['FIXED']} | "
                f"{c['REFUSED']} | {c['ACCEPTED']} | {c['UNREACHABLE']} |") if md else \
               (f"  {f}  {FAMILIES[f]:<32} attempted {len(g):>3}   "
                + "  ".join(f"{s.lower()} {c[s]}" for s in STATUSES if c[s]))
        print(line)
    if not md:
        print(f"\n  TOTAL ATTACKS ATTEMPTED: {len(rows)}")
        print(f"  of which found a defect (succeeded + fixed): "
              f"{sum(1 for r in rows if r['status'] in ('SUCCEEDED','FIXED'))}")
        for r in sorted(rows, key=lambda x: x["tag"]):
            print(f"\n  {r['tag']}  [{r['status']}]  {r['file']}")
            print(f"      {r['hypothesis'][:150]}")
    if errs:
        print("\nHEADER ERRORS:")
        for e in errs:
            print("   " + e)
    bad = bool(errs)
    if "--check" in sys.argv or "--sync" in sys.argv:
        ok, msg = sync_report(rows, write=("--sync" in sys.argv))
        print("\n" + msg)
        if not ok:
            bad = True
    if errs:
        pass
    sys.exit(1 if (bad and ("--check" in sys.argv or "--sync" in sys.argv)) else 0)

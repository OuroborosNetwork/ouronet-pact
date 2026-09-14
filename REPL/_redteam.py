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

ROOT = os.path.dirname(os.path.abspath(__file__))
FAMILIES = {
    "A": "Arithmetic & value",
    "B": "Permissionless reach",
    "C": "Admin impersonation",
    "D": "Ownership bypass",
    "E": "Sequencing & state",
    "F": "Griefing / denial of service",
    "G": "Hostile citizen module",
    "H": "Input domain",
}
STATUSES = ["SUCCEEDED", "FIXED", "REFUSED", "ACCEPTED", "UNREACHABLE"]
HDR = re.compile(
    r';;<<(RT-([A-H])-\d{3})>>\s*FAMILY:\s*([A-H])\s*\|\s*STATUS:\s*([A-Z]+)\s*\n'
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
    for m in re.finditer(r';;<<(RT-[A-H]-\d{3})>>', src):
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
    sys.exit(1 if (errs and "--check" in sys.argv) else 0)

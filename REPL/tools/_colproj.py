#!/usr/bin/env python3
"""
REPL/_colproj.py -- a projecting `read` must ask for a column its own table actually has.

THE BUG THIS EXISTS FOR, found 2026-09-14 in 2_CITIZEN/1_AOZ/01_AOZ+.pact:

    (defun UR_NonFungible:string (position:integer)
        (at "sf-asset" (read AOZ|T|NonFungibles (UC_Str position) ["sf-asset"])))

The table's schema field is `nf-asset`, and its writer writes `nf-asset`. The reader asked for
`sf-asset` -- the SemiFungible column, copy-pasted from the line directly above.

WHY PACT DOES NOT CATCH THIS, and why it is therefore worth a tool. A projecting read with an
unknown column is NOT a type error and NOT a runtime error at the read: Pact returns the EMPTY
object, and the failure only surfaces one call later as

    Key "sf-asset" not found in object: {}

which reads like a missing ROW, not a wrong COLUMN. So the symptom points away from the cause. And
because the failure is total -- every key, every time -- the function is simply never usable, which
means any test that happened to call it would have been deleted or never written. The defect and
the evidence for it disappear together. That is the profile of a bug that survives review
indefinitely, and it did: nothing in the suite called either half of the registry.

Both halves of the check are needed:
  * `deftable NAME:{SCHEMA}` gives table -> schema;
  * `defschema SCHEMA` gives schema -> field set.
A projection naming a column outside that field set is always wrong -- there is no dynamic case,
because the schema is static.

SCOPE, stated honestly. This only sees LITERAL projection lists on a literal table name. A read
whose column list is computed, or whose table is chosen by a helper (the `UC_*Table discriminator`
dispatch pattern this codebase uses), is invisible to it. It is a cheap sweep for one exact
copy-paste class, not a type checker.

    python3 REPL/_colproj.py             # report
    python3 REPL/_colproj.py --check     # exit 1 on any hit (gate mode)
    python3 REPL/_colproj.py --selftest  # prove the check still detects a known-bad projection
"""
import glob, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def sources():
    return (sorted(glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True))
            + sorted(glob.glob(os.path.join(ROOT, "2_CITIZEN", "**", "*.pact"), recursive=True)))

def scan_text(src):
    """[(line, table, column, known_fields)] for every literal projection naming an unknown column."""
    src = re.sub(r';;[^\n]*', '', src)          # comments never contain a real read
    schemas = {}
    for m in re.finditer(r'\(defschema\s+([\w|\-]+)((?:[^()]|\([^()]*\))*?)\)\s*(?=\(def)', src):
        schemas[m.group(1)] = set(re.findall(r'^\s*([\w\-|]+)\s*:', m.group(2), re.M))
    tables = {m.group(1): m.group(2) for m in
              re.finditer(r'\(deftable\s+([\w|\-]+)\s*:\s*\{\s*([\w|\-]+)\s*\}', src)}
    out = []
    for m in re.finditer(r'\(read\s+([\w|\-]+)\s+[^\[\]]*?\[\s*((?:"[\w\-|]+"\s*)+)\]', src):
        table = m.group(1)
        schema = tables.get(table)
        fields = schemas.get(schema) if schema else None
        if not fields:                           # table or schema not local to this file -- skip
            continue
        for col in re.findall(r'"([\w\-|]+)"', m.group(2)):
            if col not in fields:
                out.append((src[:m.start()].count("\n") + 1, table, col, sorted(fields)))
    return out

def selftest():
    """The tool's own silence is the thing that would mislead, so prove it still speaks."""
    good = ('(defschema s a-col:string)\n(deftable t:{s})\n'
            '(defun r () (at "a-col" (read t "k" ["a-col"])))\n(defun z () 1)')
    bad = good.replace('["a-col"]', '["b-col"]')
    if scan_text(good):
        print("SELFTEST FAILED: a correct projection was reported as a violation"); return 1
    hits = scan_text(bad)
    if not hits:
        print("SELFTEST FAILED: a projection naming a column outside the schema was NOT detected")
        return 1
    if hits[0][2] != "b-col":
        print(f"SELFTEST FAILED: detected the wrong column: {hits[0]}"); return 1
    print("selftest ok -- detects an unknown projected column, accepts a correct one")
    return 0

if __name__ == "__main__":
    if "--selftest" in sys.argv:
        sys.exit(selftest())
    hits = []
    for p in sources():
        for ln, table, col, fields in scan_text(open(p, errors="ignore").read()):
            hits.append((os.path.relpath(p, ROOT), ln, table, col, fields))
    print("PROJECTING READS WHOSE COLUMN IS NOT IN THE TABLE'S SCHEMA")
    if not hits:
        print("  0 -- clean. (Literal projections on literal table names only; see the module docstring.)")
    for rel, ln, table, col, fields in hits:
        print(f"  {rel}:{ln}  {table} projects {col!r}, schema has {fields}")
    sys.exit(1 if (hits and "--check" in sys.argv) else 0)

#!/usr/bin/env python3
"""An OBJECT-typed ghost value must match the defschema its type names, field for field.

WHY THIS EXISTS, and it is a hole rather than a nicety.

`Deploy/OURONET-REGISTRY.ghosts.json` is hand-authored on purpose: a contract says a parameter is
a `decimal`, not that 1.0 is a sensible one to show. Every scalar entry there is validated --
`_registry.py`'s `ghost_fits` checks a string is a string and an integer is not a bool, and the
package's build-every-ghost test caught 23 name-hits that did not fit their declared type.

OBJECT ENTRIES ARE NOT VALIDATED. `ghost_fits` ends at `isinstance(v, dict)` for anything
matching `object{...}`, which is the whole of its opinion. So an entry authored for
`object{AcquisitionSchemasV3.VCT|VacateTfLeg}` may carry any keys at all -- including the keys
that schema had before somebody renamed a field. The failure mode is the worst available: the
ghost still RENDERS (the generator formats whatever dict it is given), so the preview looks
healthy, and the call fails on chain against a field the contract does not have. A preview whose
entire claim is "a correct render proves correct wiring" cannot have a layer that renders
incorrect wiring.

So this compares each object-typed ghost against the `defschema` its type names: every field
present, no field invented, and each field's VALUE shaped for the field's declared TYPE.

TWO SCHEMAS IN THIS TREE SHARE A NAME AND DIFFER IN TYPE -- `DpofUdcV2.RemovableNonces` has
`r-amounts:[decimal]` and `DpdcManagementV3.RemovableNonces` has `r-amounts:[integer]`. That is
exactly the hazard the registry's own partition note records for `URHC_WipePure`, and it is why
the lookup here resolves the INTERFACE QUALIFIER rather than the bare schema name: an
unqualified match would accept either value for either type and silently render a decimal into
an integer slot.

    python3 REPL/tools/_ghostshape.py            report every object-typed entry and its verdict
    python3 REPL/tools/_ghostshape.py --check    fatal on a mismatch (runs inside _gate.py)
"""
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
GHOSTS = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.ghosts.json")
TOPS = ("1_SOVEREIGN", "2_CITIZEN")

OBJ = re.compile(r'object\{([A-Za-z0-9._|-]+)\}')


def _pact_sources():
    for top in TOPS:
        for d, _, fs in os.walk(os.path.join(ROOT, top)):
            for f in sorted(fs):
                if f.endswith(".pact"):
                    yield os.path.join(d, f)


def _strip_comments(src):
    """Drop `;;` comments WITHOUT touching string contents.

    A naive `;;.*` wipe eats half of any @doc that contains a semicolon pair, and a defschema
    sitting after one then reads as empty -- which would make this tool report "schema not found"
    for a schema that is right there.
    """
    out, i, n, instr = [], 0, len(src), False
    while i < n:
        c = src[i]
        if instr:
            out.append(c)
            if c == "\\" and i + 1 < n:
                out.append(src[i + 1]); i += 2; continue
            if c == '"':
                instr = False
            i += 1; continue
        if c == '"':
            instr = True; out.append(c); i += 1; continue
        if c == ";":
            while i < n and src[i] != "\n":
                i += 1
            continue
        out.append(c); i += 1
    return "".join(out)


FIELD = re.compile(r'^\s*([A-Za-z0-9|_-]+)\s*:\s*(\[?(?:object\{[^}]*\}|[a-z]+)\]?)\s*$', re.M)


def schemas():
    """{(interface_or_module, schema): [(field, type)]} for every defschema in the tree.

    Keyed by the OWNER as well as the name, because two owners declare `RemovableNonces` with
    different field types. An interface and its implementing module both declare the shape; both
    keys are recorded and they must agree, which is itself worth knowing if they ever stop.
    """
    out = {}
    for path in _pact_sources():
        src = _strip_comments(io.open(path, encoding="utf8", errors="replace").read())
        owner = None
        for m in re.finditer(
                r'^\((?:interface|module)\s+([A-Za-z0-9|_-]+)|^\s*\(defschema\s+([A-Za-z0-9|_-]+)',
                src, re.M):
            if m.group(1):
                owner = m.group(1)
                continue
            name = m.group(2)
            # the schema body runs to the next top-level-ish form; field lines are the only thing
            # that matches FIELD, so over-reading the slice is harmless and under-reading is not
            tail = src[m.end():m.end() + 4000]
            cut = tail.find("\n    (def")
            body = tail[:cut] if cut > 0 else tail
            out[(owner, name)] = FIELD.findall(body)
    return out


def shaped(v, t):
    """Is `v` shaped for the DECLARED type `t`? Scalars by kind, objects by recursion."""
    t = t.strip()
    if t.startswith("[") and t.endswith("]"):
        return isinstance(v, list) and all(shaped(x, t[1:-1]) for x in v)
    if t == "string":
        return isinstance(v, str)
    if t == "integer":
        return isinstance(v, int) and not isinstance(v, bool)
    if t == "decimal":
        # A DECIMAL SLOT ACCEPTS AN int IN JSON and the renderer formats it as `1.0`, so this is
        # not a hole -- `_registry.py`'s own ghost_fits makes the same allowance for the same
        # reason. The reverse is NOT allowed above: a float in an integer slot does not coerce.
        return isinstance(v, (int, float)) and not isinstance(v, bool)
    if t == "bool":
        return isinstance(v, bool)
    if t == "time":
        return isinstance(v, str)
    if t.startswith("object{") or t == "object" or t == "guard":
        return isinstance(v, dict)
    return True


def check(verbose):
    gh = json.load(io.open(GHOSTS, encoding="utf8"))
    sch = schemas()
    rows, bad = [], []

    def resolve(qual):
        """`Owner.Schema` -> the field list, by OWNER first and only then by bare name."""
        if "." in qual:
            owner, name = qual.rsplit(".", 1)
            if (owner, name) in sch:
                return (owner, name), sch[(owner, name)]
            # the owner may be the INTERFACE while only the module declares it, or vice versa
            hits = [k for k in sch if k[1] == name]
            if len(hits) == 1:
                return hits[0], sch[hits[0]]
            return None, None
        hits = [k for k in sch if k[1] == qual]
        return (hits[0], sch[hits[0]]) if len(hits) == 1 else (None, None)

    for table in ("byParam", "byType"):
        for key, entry in sorted(gh.get(table, {}).items()):
            if not isinstance(entry, dict) or "v" not in entry:
                continue
            quals = OBJ.findall(key)
            if not quals:
                continue
            qual = quals[0]
            found, fields = resolve(qual)
            if fields is None:
                bad.append(f"{table}[{key}]: no defschema resolves {qual!r} "
                           f"(renamed, moved, or the qualifier is wrong)")
                continue
            if not fields:
                bad.append(f"{table}[{key}]: {found[0]}.{found[1]} parsed as having NO fields -- "
                           f"this tool's reader is wrong, not the ghost")
                continue
            objs = entry["v"] if isinstance(entry["v"], list) else [entry["v"]]
            for i, obj in enumerate(objs):
                if not isinstance(obj, dict):
                    bad.append(f"{table}[{key}][{i}]: not an object")
                    continue
                want = {f: t for f, t in fields}
                missing = [f for f in want if f not in obj]
                extra = [f for f in obj if f not in want]
                wrong = [f"{f}={obj[f]!r} is not {want[f]}" for f in obj
                         if f in want and not shaped(obj[f], want[f])]
                if missing:
                    bad.append(f"{table}[{key}][{i}]: MISSING field(s) {missing} "
                               f"declared by {found[0]}.{found[1]}")
                if extra:
                    bad.append(f"{table}[{key}][{i}]: field(s) {extra} are not in "
                               f"{found[0]}.{found[1]} -- renamed, or a typo")
                for w in wrong:
                    bad.append(f"{table}[{key}][{i}]: {w}")
            rows.append((table, key, f"{found[0]}.{found[1]}", len(fields)))

    if verbose:
        for table, key, owner, n in rows:
            print(f"  ok  {table}[{key}]  <- {owner} ({n} field(s))")
    if bad:
        print(f"ghost shape: {len(bad)} object-typed ghost(s) disagree with their defschema:")
        for b in bad:
            print(f"    {b}")
        print("  Fix the GHOST to match the schema, never the other way round -- the contract is")
        print("  the authority and this file is the example.")
        return 1
    print(f"ghost shape: clean -- {len(rows)} object-typed ghost(s) match their defschema "
          f"field for field")
    return 0


if __name__ == "__main__":
    sys.exit(check("--check" not in sys.argv))

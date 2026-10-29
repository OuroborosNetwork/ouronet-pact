#!/usr/bin/env python3
"""Does the CONSUMER's `PartitionMeta` declare every partition key this repo authors?

WHY THIS EXISTS, and it is a defect rather than a hypothetical.

`Deploy/OURONET-REGISTRY.authored.json` is where a human writes "may this call be split, and
along which parameter". Consumers do not read that file: they read `partitionOf(key)` from
`@ouronet/papyrus`, which casts `execution.partition` to a TypeScript interface called
`PartitionMeta`. A key this repo authors and that interface does not declare is therefore
PUBLISHED AND INVISIBLE -- present at runtime, absent from the type, and silently dropped by
every consumer that destructures it.

That happened. `groupBy` -- the boundary a cut may not fall inside -- was authored on the three
`AQP-POOL|CCp_BatchVacate*` entrypoints, validated by `_registry.py --check`, and shipped in the
artefact. `PartitionMeta` never declared it. A client splitter written from that interface would
have honoured `axis` and `lockstep`, cut wherever it liked, and run the vacate's UNGATED
per-beneficiary unwind once per SLICE instead of once per beneficiary. OuronetUI's own changelog
had already written down what was at stake -- *"without it the splitter would cut exactly where
the vacate is unsound"* -- so the knowledge existed in one repo, the enforcement in another, and
the type between them had neither.

`_registry.py` now rejects an UNKNOWN authored key, which closes the typo half locally. This is
the other half: the key may be spelled correctly, validated correctly, and still unreadable.

WHY A WARNING AND NOT A FAILURE -- the same reason `_pkgsync.py` warns. The consumer lives in a
SEPARATE repository (`_libs/ouronet-libs`) which may legitimately be absent: a fresh clone of the
Pact repo alone, or CI that checks out one tree. Failing on absence would make this gate depend on
another repo being present, which it is not. A MISMATCH, when the package IS present, is reported
loudly; an absent package is reported and skipped.

  python3 REPL/tools/_partitiontype.py --check
"""
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
AUTHORED = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.authored.json")
PKG = os.path.abspath(os.path.join(
    ROOT, "..", "..", "_libs", "ouronet-libs", "packages", "papyrus"))
SRC = os.path.join(PKG, "src", "partition.ts")

# The interface's own declaration, read rather than listed. A hand-kept copy of a field list is
# the thing this tool exists to catch one level down.
IFACE = re.compile(r'export\s+interface\s+PartitionMeta\s*\{(.*?)\n\}', re.S)
FIELD = re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\??\s*:', re.M)


def declared_fields(src):
    """Field names on `PartitionMeta`, with comments stripped so prose cannot look like a field."""
    m = IFACE.search(src)
    if not m:
        return None
    body = re.sub(r'/\*.*?\*/', '', m.group(1), flags=re.S)
    body = re.sub(r'^\s*//.*$', '', body, flags=re.M)
    return set(FIELD.findall(body))


def main():
    if "--check" not in sys.argv:
        print(__doc__)
        return 0
    if not os.path.exists(AUTHORED):
        print("partitiontype: no authored registry layer -- nothing to compare")
        return 0
    authored = json.load(io.open(AUTHORED, encoding="utf8")).get("partition", {})
    used = set()
    for blk in authored.values():
        used |= set(blk)
        inner = blk.get("inner")
        if isinstance(inner, dict):
            # `inner` is itself a shape a consumer destructures, so its keys count too.
            used |= {f"inner.{k}" for k in inner}

    if not os.path.isdir(PKG):
        print(f"partitiontype: skipped -- @ouronet/papyrus is not checked out at {PKG}")
        return 0
    if not os.path.exists(SRC):
        print(f"partitiontype: skipped -- {os.path.relpath(SRC, PKG)} is absent; the interface "
              f"may have moved, in which case this tool's path needs updating")
        return 0

    fields = declared_fields(io.open(SRC, encoding="utf8").read())
    if fields is None:
        print("partitiontype: could not find `export interface PartitionMeta` -- it was renamed "
              "or restructured, and this comparison is now vacuous rather than passing")
        return 1

    flat = {k for k in used if "." not in k}
    missing = sorted(flat - fields)
    # The reverse is NOT an error. A field the interface declares and no block uses is a judgement
    # nobody has had to make yet -- `rounds` is exactly that, and declaring it ahead of a
    # reduction-shaped operation is how the vocabulary stays complete.
    unused = sorted(fields - flat)

    print(f"partitiontype: {len(authored)} authored block(s) use {len(flat)} key(s); "
          f"PartitionMeta declares {len(fields)}")
    if unused:
        print(f"  declared but unused (fine -- vocabulary ahead of need): {', '.join(unused)}")
    if missing:
        print(f"\n  !! {len(missing)} authored key(s) are NOT declared by PartitionMeta:")
        for k in missing:
            who = sorted(e for e, b in authored.items() if k in b)
            print(f"     {k}  -- on {len(who)} entrypoint(s), e.g. {who[0]}")
        print("  !! A consumer reads these through that interface, so an undeclared key is")
        print("  !! PUBLISHED AND INVISIBLE: present at runtime, dropped by every destructure.")
        print("  !! Declare it in @ouronet/papyrus `src/partition.ts` and release the package.")
        return 1
    print("partitiontype: clean -- every authored partition key is declared by the consumer type")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""_coinbasesafety.py -- does any NEW schema field get read on the COINBASE path?

    python3 REPL/tools/_coinbasesafety.py --check     (offline, fatal in the gate)

WHY THIS EXISTS, and it is not a hypothetical. On 2026-11-09 a `coin` upgrade added
`dormant-claim-count` to `UrStoaVaultSchema` and read it from `XI_URV|RestoreUnclaimedCount`,
which chain 0's `coinbase` calls on EVERY BLOCK. Rows written before the field existed do not
carry it, the read aborted, the coinbase aborted, chain 0 stopped producing blocks -- and since a
transaction needs a block, the repair could no longer be submitted AT ALL. The braid froze for
~16h and recovery took a fleet-wide rollback.

THE COINBASE IS THE ONE PATH WITH NO ERROR TOLERANCE. Anywhere else an abort fails one
transaction; here it stops the chain, and takes with it the ability to fix itself. So a read
there is not "a bug if wrong" -- it is a liveness dependency.

WHAT IT COMPARES. The CURRENT schema against the PRE-UPGRADE module pinned at
`00_StoaSandbox/_canary/coin-pre-upgrade.pact` (fetched from the chain with `describe-module`,
not from git -- the repo copy had drifted). Any field present in the new schema and absent from
the old one is NEW; if a function reachable from `coinbase` names it, that is fatal.

TWO IDIOMS DO **NOT** MAKE SUCH A READ SAFE, both measured by the canary rather than assumed:
  - `with-default-read` defaults an absent ROW, not an absent COLUMN. The row exists; the
    binding is what raises. This is precisely what halted the chain.
  - `(try 0 ...)` does not catch it either -- the error propagates straight through.
The idiom that works is to read the row as an object and test `contains` before `at`, so the
missing key is never bound or indexed.

This cannot be a REPL test alone: every ordinary fixture builds rows with the new module already
loaded, and `insert` always supplies every field, so a fresh row can never be missing one. The
companion `REPL/CANARY-coin-upgrade.repl` constructs the old-row/new-code state for real; this
tool is the cheap static guard that runs on every gate.
"""
import os, re, sys, io

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NEW  = os.path.join(ROOT, "00_StoaSandbox", "coin.pact")
OLD  = os.path.join(ROOT, "00_StoaSandbox", "_canary", "coin-pre-upgrade.pact")
ENTRY = "coinbase"

def schema_fields(src):
    """field name -> schema it belongs to, for every defschema in the module."""
    out = {}
    for m in re.finditer(r'\(defschema\s+([A-Za-z0-9|_\-]+)(.*?)\n\s*\)\n', src, re.S):
        name, body = m.group(1), m.group(2)
        for f in re.findall(r'\n\s*([a-z][a-z0-9\-]*):(?:string|decimal|integer|bool|time|guard)', body):
            out[f] = name
    return out

def functions(src):
    """defun/defcap name -> source text."""
    marks = [(m.start(), m.group(1)) for m in
             re.finditer(r'\n\s*\(def(?:un|cap)\s+([A-Za-z0-9|_\-]+)', src)]
    out = {}
    for i, (pos, name) in enumerate(marks):
        end = marks[i+1][0] if i+1 < len(marks) else len(src)
        out[name] = src[pos:end]
    return out

def reachable(fns, entry):
    seen, stack = set(), [entry]
    while stack:
        f = stack.pop()
        if f in seen or f not in fns:
            continue
        seen.add(f)
        for c in set(re.findall(r'\(([A-Za-z][A-Za-z0-9|_\-]*)', fns[f])):
            if c in fns and c not in seen:
                stack.append(c)
    return seen

def main():
    if not os.path.exists(OLD):
        print("coinbase safety: NO PRE-UPGRADE FIXTURE at", os.path.relpath(OLD, ROOT))
        print("  Refresh it from the chain -- see 00_StoaSandbox/_canary/README.md.")
        print("  Without it this check cannot tell a NEW field from an old one.")
        return 1
    new_src = io.open(NEW, encoding="utf8").read()
    old_src = io.open(OLD, encoding="utf8").read()
    new_f, old_f = schema_fields(new_src), schema_fields(old_src)
    added = {f: s for f, s in new_f.items() if f not in old_f}
    fns = functions(new_src)
    path = reachable(fns, ENTRY)

    if ENTRY not in fns:
        print(f"coinbase safety: `{ENTRY}` not found in {os.path.relpath(NEW, ROOT)} -- check the entry name.")
        return 1

    print(f"coinbase safety: {len(path)} function(s) reachable from `{ENTRY}`; "
          f"{len(added)} field(s) added since the deployed module")
    if not added:
        print("coinbase safety: clean -- this upgrade adds no schema field.")
        return 0
    for f, s in sorted(added.items()):
        print(f"   NEW FIELD  {f}  (schema {s})")

    hits = []
    for fn in sorted(path):
        for f in added:
            if re.search(r'"' + re.escape(f) + r'"', fns[fn]):
                hits.append((fn, f))
    if not hits:
        print("coinbase safety: clean -- no newly-added field is read on the coinbase path.")
        return 0

    print()
    for fn, f in hits:
        safe = re.search(r'\(contains\s+"' + re.escape(f) + r'"', fns[fn])
        status = "guarded by `contains`" if safe else "*** UNGUARDED ***"
        print(f"   {fn}  reads NEW field `{f}`  -- {status}")
    bad = [h for h in hits if not re.search(r'\(contains\s+"' + re.escape(h[1]) + r'"', fns[h[0]])]
    if bad:
        print()
        print("   A newly-added field is read on the COINBASE path without a `contains` guard.")
        print("   Pre-upgrade rows do not carry it, so the coinbase will ABORT on every block and")
        print("   the chain will HALT -- and no transaction can then be sent to repair it.")
        print("   `with-default-read` does NOT fix this (it defaults an absent ROW, not an absent")
        print("   COLUMN) and neither does `try`. Read the row and test `contains` before `at`.")
        print("   Then prove it with REPL/CANARY-coin-upgrade.repl.")
        return 1
    print("coinbase safety: clean -- every new field on the path is `contains`-guarded.")
    return 0

if __name__ == "__main__":
    sys.exit(main())

# How these figures were obtained

Every number in this documentation was computed, not remembered. This file carries the command
behind each one so any figure can be re-derived rather than trusted.

The rule exists for a specific reason: three separate rounds of this project found published
figures that had gone stale while **every document agreed with every other one**. Internal
consistency is not evidence. Re-running a command is.

Measured 2026-09-27 against the deployed tree.

---

## The size of the system

Run from the Pact repo root.

```bash
# modules
find 1_SOVEREIGN 2_CITIZEN -name "*.pact" | wc -l                          # 105

# lines
find 1_SOVEREIGN 2_CITIZEN -name "*.pact" | xargs wc -l | tail -1          # 122,969

# definitions, by kind
for k in defun defcap defschema deftable; do
  printf "%-10s %s\n" "$k" \
    "$(grep -rhoE "^\s*\($k " --include=*.pact 1_SOVEREIGN 2_CITIZEN | wc -l)"
done
# defun 8848 · defcap 988 · defschema 206 · deftable 231

# interfaces
grep -rloE "^\(interface " --include=*.pact 1_SOVEREIGN | wc -l            # 68
```

**A caveat on `defun` 8,848.** Pact declares a function in the interface AND defines it in the
implementing module, so that count includes both. It is the number of `defun` FORMS in the tree,
which is what the command measures and what this documentation claims — not the number of
distinct callable functions. Where the distinct figure matters, the registry's 423 client
entrypoints is the honest one.

## The client surface

```bash
python3 -c "import json; r=json.load(open('Deploy/OURONET-REGISTRY.json')); \
  print(len(r['entrypoints']), 'entrypoints;', len(r['previews']), 'previews;', r['surfaceHash'])"
# 423 entrypoints; 428 previews; 7c2b70c6118d6db2
```

`Deploy/OURONET-REGISTRY.json` is GENERATED from the deployed contracts, not from the repo. It
is the authority for what is callable.

## Is that snapshot still true of the chain?

```bash
python3 REPL/tools/_registrylive.py          # 12 modules, 12 current, 0 drifted
```

This matters more than it looks. The registry's other guards compare the artefact to a **copy of
itself**; only this one asks the chain. A Pact module hash changes on any redeploy, so twelve
`describe-module` calls are a complete answer rather than a sample.

## The test suite

```bash
python3 REPL/tools/_gate.py                  # 26,128 assertions, GATE GREEN
```

The gate is the authority on the assertion count. `OuronetInformational/ARCHITECTURE/
REPL_SUITE_STATS.md` is generated from it and is diffed by the gate itself, so a figure quoted
from that file cannot silently drift.

## Per-module facts

`OuronetInformational/MODULE-INDEX.md` is generated from the tree and carries each module's
path, tables, functions and one-line purpose. Regenerate with the tool named in its own header
rather than editing it.

## Figures read from the chain

Anything describing live state — which pools exist, which recovery variants a pool offers, what
an operation costs — was read with an unsigned `/local` call at the time of writing. Those are
marked in place with the date, because unlike the figures above **they can change without anyone
editing a file.**

Example, the shape used throughout:

```
(ouronet-ns.ATS.UR_ToggleColdRecovery "SilverStoaPillar-O136CBn22ncY")   -> true
```

## If a figure here disagrees with the code

The code is right and this file is stale. Re-run the command, fix the number, and say in the
commit that it had drifted — a silently corrected figure teaches nobody how long it was wrong.

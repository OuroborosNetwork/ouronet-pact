# How these figures were obtained

Every number in this documentation was computed, not remembered. This file carries the command
behind each one so any figure can be re-derived rather than trusted.

The rule exists for a specific reason: three separate rounds of this project found published
figures that had gone stale while **every document agreed with every other one**. Internal
consistency is not evidence. Re-running a command is.

Measured 2026-09-27 against the deployed tree.

---

## The size of the system

Run from the Pact repo root. **Scope is `1_SOVEREIGN` + `2_CITIZEN`** — the sandboxes
(`0_Stoa/`, `00_KadenaSandbox/`, `00_StoaSandbox/`) and `0_Sample/` are excluded, which is why
these figures are smaller than `OuronetInformational/MODULE-INDEX.md`'s. That file counts the
whole tree and reports 152 modules, 433 schemas and 423 tables. Both are correct at their own
scope; quoting one with the other's label is the mistake to avoid.

> Note the near-collision waiting to trap someone: MODULE-INDEX reports **423 tables** and the
> registry reports **423 client entrypoints**. Unrelated quantities, equal today.

```bash
# source files -- NOT modules; a file may hold an interface and a module together
find 1_SOVEREIGN 2_CITIZEN -name "*.pact" | wc -l                            # 105

# lines
find 1_SOVEREIGN 2_CITIZEN -name "*.pact" -exec cat {} + | wc -l             # 123,058

# definitions, by kind
for k in defun defcap defschema deftable defpact; do
  printf "%-10s %s\n" "$k" \
    "$(grep -rhoE "^\s*\($k " --include=*.pact 1_SOVEREIGN 2_CITIZEN | wc -l)"
done
# defun 8849 · defcap 988 · defschema 206 · deftable 231 · defpact 6

# modules and interfaces -- count the FORMS, at column 0
grep -rhoE '^\(module [^ ]+'    --include=*.pact 1_SOVEREIGN 2_CITIZEN | wc -l          # 99
grep -rhoE '^\(module [^ ]+'    --include=*.pact 1_SOVEREIGN 2_CITIZEN \
  | awk '{print $2}' | sort -u | wc -l                                       # 98 distinct
grep -rhoE '^\(interface [^ )]+' --include=*.pact 1_SOVEREIGN 2_CITIZEN | wc -l         # 98
```

**Why 99 module forms but 98 names.** `2_CITIZEN/6_OuronetBridge/03_CADUCEUS.pact` declares
`(module CADUCEUS GOV` twice at column 0 — an abandoned section skeleton at line 1, the real
module at line 83. No live consequence: the file is a scaffold, excluded from the deploy round
with that reason recorded in `Deploy/MANIFEST.md`. It is mentioned because a figure that differs
from its neighbour by one invites the assumption of a miscount.

**CORRECTED 2026-09-27 — this file previously reported 68 interfaces, and the command printed
right beside the figure is what proves it wrong:**

```bash
grep -rloE "^\(interface " --include=*.pact 1_SOVEREIGN | wc -l             # 68
```

`-l` counts **files that contain a match**, not matches, and the scope omits `2_CITIZEN`. So 68
was "files in the sovereign tree holding at least one interface" wearing the label "interfaces".
The real figure is **98**. It reached the front page of the documentation.

This is the failure this whole file was written to prevent, and it happened anyway — inside the
file, one line below the rule. The lesson is not "be careful": it is that **a command sitting
next to a figure is not the same as a command that produced it.** Which is why the figures that
matter are now regenerated and diffed by a tool rather than transcribed — see `../MAINTAINING.md`.

**A caveat on `defun` 8,849.** Pact declares a function in the interface AND defines it in the
implementing module, so that count includes both. It is the number of `defun` FORMS in the tree,
which is what the command measures and what this documentation claims — not the number of
distinct callable functions. Where the distinct figure matters, the registry's 423 client
entrypoints is the honest one.

## The deploy round

```bash
ls Deploy/1_Pure/*.pact | wc -l                                              # 25 files
python3 REPL/tools/_deploybundle.py --check | grep 'module-deploy'            # 24 transactions
grep -hoE '^\(module [^ ]+'    Deploy/1_Pure/*.pact | awk '{print $2}' | sort -u | wc -l   # 80
grep -hoE '^\(interface [^ )]+' Deploy/1_Pure/*.pact | awk '{print $2}' | sort -u | wc -l   # 85
```

25 files, 24 transactions: one file in the deploy chain is not part of the current round, which
`_deploybundle.py` reports explicitly rather than silently. The round deploys 80 of the tree's 98
modules; every exclusion is listed with a reason under *"Modules in the tree that this plan does
NOT deploy"* in `Deploy/MANIFEST.md`.

Hand-deployed batches live alongside: `Deploy/2_Init/` (5), `Deploy/3_Assets/` (16) and
`Deploy/PureV2/` (22, the one-at-a-time AppReads and upgrade transactions).

## The client surface

```bash
python3 -c "import json; r=json.load(open('Deploy/OURONET-REGISTRY.json')); \
  print(len(r['entrypoints']), 'entrypoints;', len(r['previews']), 'previews;', r['surfaceHash'])"
# 423 entrypoints; 428 previews; <a 16-hex surface hash>
```

**`surfaceHash` is deliberately NOT quoted as a figure in this documentation**, and the reason is
worth more than the value would be.

It is a sha256 over the whole `entrypoints` + `previews` body — which includes each entrypoint's
GHOST block, not just its callable signature. So it moves when an *example value* changes, with no
contract change at all. It moved **twice on 2026-09-27** — once for the ghost `use` tags, once for
fifteen added example values — with zero entrypoints changed and zero divergences reported in
either run. A figure that volatile, printed in prose, is stale within the day and teaches a reader
to distrust the neighbouring figures that are not.

Treat a moved `surfaceHash` as *"something in this artefact changed"*, never as *"the callable
surface changed"*. The **divergence count** answers that second question, and that is the number
worth reading:

```bash
python3 REPL/tools/_registry.py --probe | grep divergence     # 0 deployed/repo divergence(s)
```

The rule this illustrates generalises: **quote a figure only if it is stable enough to be worth
checking.** Everything else gets its command.

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

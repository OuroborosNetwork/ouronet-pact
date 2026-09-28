# Resume here

Live state of the Chapter A documentation job. **Read this first, then `BUILD-PLAN.md` §6.**
Written 2026-09-27. Update it when you stop working; a stale resume note is worse than none.

## Where it stands

**13 of 132 files written.** Updated 2026-09-28. Tree clean.

| section | files | written |
|---|---|---|
| root (`README`, `BUILD-PLAN`, `MAINTAINING`) | 3 | **3** |
| `00-orientation` | 4 | **4** |
| `10-architecture` | 8 | **3** (01, 02, 03) |
| `60-methodology` | 4 | **1** (01 StoicSyntax) |
| `90-reference` | 5 | **2** (03, 04) |
| everything else | 108 | 0 |

## The next action, exactly

`60-methodology/01-stoicsyntax.md` is **DONE**. Next is `10-architecture/` 04–08, then the rest of
`60-methodology/` (02 semi-self-auditing, 03 the gate, 04 what-went-wrong).

`02-semi-self-auditing.md` is the directive's headline chapter and the material for it is already
measured: `_conformance.py` reports **26 rules, 0 violations, 106 observations** across 122,969
lines, and its closing line — *"the doc is narrower than the code's correct practice"* — is the
honest framing to build the chapter around. 01 sets it up and deliberately stops short of it.

Material gathered for 01, kept because 02 needs the same sources:

- Canon: `OuronetInformational/StoicSyntax-Prefixes.md` (1,568 lines). Keystone sections: **§1** the
  composition rule (UPPERCASE = operation class, lowercase = specialization role, `|` = scope),
  **§2** the prefix registry, **§2.15** the five protection classes, **§7.19** `UM_` as the only
  reader allowed to write.
- **The prefix census — USE THESE, the earlier ones were wrong.** Exact `^\(defun PREFIX_`
  matches, verified 2026-09-28: `UR_` 1406, `INFO_` 625, `C_` 604, `URCi_` 597, `P|` 538,
  `UEV_` 523, `UC_` 430, `XI_` 388, `XE_` 328, `UDC_` 310, `A_` 190, `URH_` 128, `W` 117,
  `XB_` 62, `CAP_` 33, `URC_` 755.
  The figures in the first draft came from a census that collapsed role variants (`UCv_` into
  `UC_`) and scoped forms (`DPTF|C_` into `C_`), and eleven of them were too high. **A count is
  meaningless without its matching rule**, and the rule is what gets lost when a number is quoted
  onward. These rows do NOT sum to 8,848 — scoped forms match none of them.
- **The `W` family is canon and `CLAUDE.md` omits it.** `WI_` (insert) 20, `WU_` (update) 62, `WW_`
  (upsert) 28 = 110 functions across 8 files (the AQP family plus DPTF and PYTHIA). Documented in
  `StoicSyntax-Prefixes.md` §2 lines 202-208. Worth stating as a gap in the project instructions.
- Two quotable findings from §2.15: applying the precise definition of "protected" **reclassified 50
  functions** from Class 5 to Class 4 — none lost protection, they never had the second lock the
  annotation claimed. And: *"The codebase was sound; the vocabulary was not."*
- Keep `02-semi-self-auditing.md` distinct: **01 is the system, 02 is the payoff.**

## Then

`10-architecture/` 04–08, the five unwritten ones. Four research agents were running on exactly
these when the session ended and their output did not survive — cheap to redo, but **do not assume
their results exist**. Topics, one agent each:

| file | research target |
|---|---|
| `04-deploy-order.md` + `07-interfaces-and-versioning.md` | `ARCHITECTURE/INTERFACE_VERSIONING.md`, `Deploy/MANIFEST.md`, `REPL/tools/_deploybundle.py` |
| `05-accounts-and-identity.md` | `2_Core/01_DALOS.pact`, `1_Utilities/08_U_DALOS.pact` |
| `06-ignis-and-the-gas-station.md` | `2_Core/02_IGNIS.pact`, `3_Talos/*`, `IGNIS-PRICING/IGNIS-PRICING.md` |
| `08-the-read-layer.md` | `Z_Reads/*`, `AppReads/*`, `HANDOFF-read-layer-split.md` |

## Tools built for this job

| tool | what it does | gate? |
|---|---|---|
| `REPL/tools/_transcripts.py` | mines `~/.claude/projects/` for what the owner typed. `--stats --grep --rulings --on --agents --selftest` | **no**, deliberately — per-machine corpus outside the repo |
| `REPL/tools/_docsmodules.py` | generates the module map between `<!-- @generated:… -->` markers. `--check --write --selftest` | not yet — joins when `30-modules/` is complete |

**Read `_transcripts.py`'s docstring before using it.** The sidechain trap: a subagent brief is
stored as a user message, identical in every field including `userType`; only `isSidechain`
distinguishes them. Unfiltered, the first `--rulings` run returned 11 hits of which **10 were my own
agent prompts**, each describing Ouronet with the designation the owner had just retired.

## Standing rules for this folder, learned the hard way

1. **Count, do not recall.** Four published figures were wrong in the first pass: 68 interfaces
   (really 98), "105 modules" (105 *files*), read layer 12 (really 14), and the interface-only core
   file (`00_AQP-SCHEMAS.pact`, not Demipad).
2. **Never write the verification from the claim.** The arithmetic check for the layer diagram
   agreed with a wrong figure because it was written from the page instead of the tree.
3. **Quote intent, never paraphrase it.** `90-reference/04-the-owner-directive.md` is verbatim for
   this reason — the derived summary had lost two requirements and inverted one term.
4. **Every figure carries its scope.** `MODULE-INDEX.md` reports 423 *tables* for the whole tree;
   the registry reports 423 *client entrypoints*. Equal today, unrelated forever.
5. **`git add <paths>`, never `-A`.** Commit `30055e2` swept in four foreign `pact-query-cache`
   files after three warnings about exactly that.

## Open, owner-blocked

- **Web edition vs PDF.** Asked 2026-09-23, never answered. Markdown-bricks-to-website-agent implies
  web-first, but whether a PDF cut exists and what it contains is unsettled. Nothing currently
  depends on it; a PDF would. Recorded in `90-reference/04-the-owner-directive.md` §7.
- **Commit `30055e2`** still contains the four foreign `pact-query-cache` files. Split them out or
  leave them — not decided.

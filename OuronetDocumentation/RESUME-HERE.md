# Resume here

Live state of the Chapter A documentation job. **Read this first, then `BUILD-PLAN.md` §6.**
Written 2026-09-27. Update it when you stop working; a stale resume note is worse than none.

## Where it stands

**31 of 132 files written**, plus one module exemplar. Updated 2026-09-29. Tree clean.

| section | files | written |
|---|---|---|
| root (`README`, `BUILD-PLAN`, `MAINTAINING`) | 3 | **3** |
| `00-orientation` | 4 | **4** |
| `10-architecture` | 8 | **8 — COMPLETE** |
| `60-methodology` | 4 | **4 — COMPLETE** |
| `90-reference` | 5 | **2** (03, 04) |
| everything else | 105 | 0 |

## The next action, exactly

**The generator is built and proven.** `_livemodules.py --probe` caches the deployed source of
all 96 live modules by module hash (re-probe: 0 fetched, 96 hits), and `_docsblocks.py` renders a
per-module block from it with a live-vs-repo comparison. See
`30-modules/00-EXEMPLAR-OUROBOROS.md` for the shape.

**`10-architecture/` AND `60-methodology/` are both COMPLETE.** Everything remaining is either
(a) the module section, blocked on the entity-vs-module decision, or (b) the six prose sections
that need their own research passes: `20-assets` (8), `25-defi` (5), `40-journeys` (5),
`50-economics` (4), `70-comparison` (3), `80-cryptography` (4).

**`20-assets/` is COMPLETE.** Recommended next: **`25-defi/`** (5 files) — the three pool families.
`20-assets/07-pool-positions.md` already establishes what a position IS, so 25-defi covers only the
mechanics. Much of the research is in this session's briefs; re-run if the session is new.

**`80-cryptography/` needs material from ANOTHER REPO** — the 162-char glyph generator is not in
this tree (established writing `10-architecture/05`; nothing here derives an account from a public
key, and there is no on-chain binding between an account's stored public key and its identifier).
Budget a cross-repo research pass, and do not start that chapter assuming the material is local.

**STILL AWAITING AN OWNER DECISION, and it is the biggest lever left:** entity chapters (~13
subsystems) or per-module pages (79)? The June whitepaper used entities and reads better for it.
The generator serves both — a page may carry one `module:<NAME>` block or several — so nothing is
blocked, but the answer roughly halves or doubles the remaining module work. The PDF question
(same content or condensed cut) is also still open from 2026-09-23.

**The gate figures are now MEASURED, 2026-09-29** — run `-j 16`, wall **312.8s**:

```
executed 26128 assertions (20952 positive, 5176 negative)
GATE GREEN
```

So the remembered 26,128 was right and the audit-book's 25,885 is stale. Written into
`60-methodology/02` §6b. **`03-the-gate.md` does not need another full run.**

Two corrections for 03, both measured rather than recalled:
- the gate invokes **29** static checks (not the 19 this note used to say) and carries **34**
  distinct fatal exits. `grep -oE 'tools/_[a-z0-9]+\.py' REPL/tools/_gate.py | sort -u`
- **`_gate.py --audit-only` is the CHEAP HALF** — the orphan proof, running no tests, seconds not
  minutes. Reports **93 entrypoints, 334 files reachable**. Use it freely.

**AND IT CAUGHT A REAL FAILURE THE FIRST TIME IT WAS ASKED.** The gate was RED — `TOOLS.md`
indexed 79 tools against 83 on disk, and all four missing were written for THIS job
(`_transcripts`, `_docsmodules`, `_livemodules`, `_docsblocks`) across three sessions. Fixed in
`6c7c26f0`. **Run `--audit-only` after adding any tool**; the rule is in TOOLS.md's own header and
was broken four times running because nothing was asking.

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

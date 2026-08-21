# Planned StoicSyntax refactor will require a docs-sync pass afterward (2026-08-22)

**Owner's stated sequencing** (verbatim intent, #34 session): finish the SWP audit → audit all
other currently-unaudited modules the same way → **only then** do one large pass bringing the
entire codebase to the latest StoicSyntax conventions (naming, section order, prefix discipline,
etc.) — described as "a huge refactor." Function/module names are **not** to be second-guessed
against StoicSyntax during the audits themselves; that's explicitly deferred.

**The consequence that must not be lost:** every doc written *during* the audits — findings,
fix logs, HANDOFF/architecture docs — necessarily references the **pre-refactor** names (e.g.
`SWPU::C_SmartSwap`, `SWPT::URC_ComputeAllRoutes`, `SWPI::URC_HopperExhaustive`, every prefix and
function cited throughout `OuronetInformational/HANDOFF-swp-exhaustive-path-search.md` and
`OuronetInformational/HANDOFF-swp-smartswap-bundle-architecture.md`, every `Audit/*/README.md` /
`ISSUES-RANKED.md` / `ROUND-0N-*.md` fix entry across every module). Once the StoicSyntax
refactor renames things, **all of this documentation goes stale** — code examples, function
references, and cross-links will point at names that no longer exist.

**Action required, when the refactor actually happens (not now):**
1. After the StoicSyntax refactor lands (and its own regression is green), run a dedicated
   doc-sync pass across `OuronetInformational/` (all HANDOFF/architecture docs) **and** every
   module's `Audit/*/` tracking docs — find every reference to a renamed function/module/prefix
   and update it to the new name.
2. This is a **distinct, later task** from the refactor itself — the refactor's own commit(s)
   should not silently leave documentation inconsistent; either the refactor PR does the doc sync
   as part of the same change, or this file stands as the reminder that it's still owed.
3. Do **not** attempt to pre-emptively rename things in docs before the refactor actually happens
   — that would just create a second stale state (doc says post-refactor name, code still has
   pre-refactor name). Sync only after the code change is real and merged.

**Why written down now:** flagged by the owner while closing out #34's Phase 13 (final SWP
audit-trail cleanup) — the exact moment several new, detailed docs (two HANDOFF files, updated
`ROUND-02-FIXES.md` fix entries, etc.) were being finalized, all full of function names that this
refactor will eventually change. Cross-referenced from
`1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/README.md`'s status tracker so a future reader lands here
before assuming the audit docs are permanently accurate.

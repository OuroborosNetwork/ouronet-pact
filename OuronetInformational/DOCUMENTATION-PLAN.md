# Ouronet Comprehensive Documentation — capstone workstream #3

Owner directive, 2026-08-27. The THIRD capstone deliverable (after #1 the post-audit Pact work,
#2 the UI incorporation). A **full, proper written documentation of everything the Ouronet code
does** — published on the Ouronet Website alongside the Audit Book, in a **Documentation + Audit
region** of the site.

## Why it must wait for the final shape (and why every prior attempt failed)
The owner has repeatedly tried "let's document this module, then the next" — but new code kept
arriving and it never finished; what exists is throwaway because the code shape wasn't settled.
This documentation can only be written **once the final shape of Stage 1 + Stage 2 is known and
redeployed** (roadmap Phase 7). Doing it on shifting code is wasted effort — that is the whole
lesson. So it is a **capstone**, gated on Phase 7, same as the UI.

## What it is (scope — a "capture-all" comprehensive document)
A proper writing that depicts the ENTIRE system in detail, for a brand-new reader who needs to
understand "what the fuck it is we built." It must cover:
- **Purpose / vision** — what Ouronet strives to achieve (its own virtual blockchain entity on
  StoaChain; true fungibles / ortofungibles / collectables; DeFi primitives — ATS, SWP, AQP,
  DemiPad, DSA; users creating tokens, pools, pairs, and their own modules on Ouronet token logic).
- **Architecture** — the layer cake (Utilities → Core → Talos → `Z_Reads`), sovereign vs slave,
  the module map, deploy order, the IGNIS virtual-gas + gas-station model.
- **Every module, every function, every shape** — the role of each function, what it does, HOW it
  does it, WHY it does it, what purpose it serves. Every schema/table shape. The 7 asset types.
- **What a client/user can achieve** — concrete capabilities and journeys per role/asset.
- **Why it's so complex / why it costs so much** — honestly explained: the on-chain virtual-chain
  design, heavy reads, the IGNIS cost model (tie to the re-price work + the transitive-heavy rule),
  the module-size seventh-power reality.
- **Advantages vs industry standards** — how Ouronet's token/DeFi design compares to and exceeds
  existing standards; why the complexity buys something real.
- **The StoicSyntax methodology** — describe how the StoicSyntax prefix discipline
  (`UC/UR/URC/UEV/UDC/CAP/A_/C_/X*/URCi/...` + the transitive-heavy naming) STRUCTURES the whole
  codebase and made it **semi-self-auditing** — "how its definition helped us do half-audited code."
  This is a first-class chapter: the naming *is* part of the design, and it's why the audits were
  tractable. Source: `StoicSyntax.md` / `StoicSyntax-Prefixes.md`.

## Publication
Together with the **Audit Book** (Parts I/II/III, `AUDIT-BOOK.md`), published on the Ouronet
Website in a comprehensive **Documentation + Audit region**.

## The website (observe what exists — it's incomplete)
The Ouronet website lives in the Claude workspace at
`d:\_Claude\OuroborosNetwork\websites\ouronetwork-website\` (separate repo from this Pact repo).
The doc agent must **first observe what's already been built there** to see, on its own, how
incomplete it is relative to how comprehensive this documentation must be — then do the real,
final-shape version. Do NOT trust the current partial docs; they predate the settled code shape.

## Derivation (how the agent builds it — like the UI, from the final code)
Walk the final codebase module by module (deploy order): for each module, document its purpose,
its schemas/tables, and every function's role — grouped for a reader, not dumped. Cross-reference
the entrypoint-surface catalog (from Phase 2.3, also the UI substrate) so nothing built is left
undocumented. The INFO/`URCi` layer gives the per-op cost story (feeds "why it costs so much").
The Audit Book gives the "how we made it sound" story.

## Status
DEFERRED — capstone, gated on Phase 7 (final shape redeployed). Captured now so it stops being an
endless piecemeal effort. Roadmap Phase 9.

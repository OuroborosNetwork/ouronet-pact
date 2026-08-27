# Ouronet UI incorporation — the capstone (workstream #2)

Owner directive, 2026-08-27. This is the **second** major thing to do (workstream #1 is the
post-audit Pact plan in `POST-AUDIT-MAIN-ROADMAP.md`). It is the CAPSTONE: a **document of
incorporation** that an AI agent (the "OuronetUI agent") follows to implement the **entire**
Ouronet functionality onto the web UI — every client/admin function, for every asset type, for
every user role — derived from the **final shape** of the Pact code, not built by hand.

## The problem this solves
Ouronet's Pact surface is enormous: hundreds of client (`C_`/`CC_`) and admin (`A_`/`AA_`)
functions across DALOS, the token families, ATS, SWP, AQP, DemiPad, DSA, and the 7 asset types.
The owner has been building the UI **manually — one page, one button, one wired function at a
time**, writing the INFO (cost-preview) wiring per function as they go. At Ouronet's scale that is
a **multi-year** job even with step-by-step AI help, and a decade-plus solo. It is not humanly
tractable to hold the whole surface in one head and place it button-by-button.

But it IS tractable for an AI agent working from a **written incorporation plan** that maps the
finalized Pact surface → UI. That plan is this document's deliverable.

## Why it must come AFTER workstream #1 (hard dependency)
The incorporation doc is derived from the **final shape** of the code. It requires (roadmap Phases 1-7):
1. All Pact fixes finalized (audits in; URCi; **complete INFO coverage**; re-price; module splits).
2. The **red-team attack** + fixes done (Phase 6) and the **Audit Book** assembled (Parts I/II/III).
3. A **fresh top-to-bottom redeploy** of Stage 1 + Stage 2 (Phase 7) — the final entrypoint set.
Only then is the client/admin/INFO surface stable and total — which is what the UI enumerates.

## The KEY synergy — workstream #1 IS the bridge to the UI
This is the crucial insight: **the completed INFO surface + the repo-wide entrypoint catalog
(Phase 2.3 + `aqp-entrypoint-surface.md` extended) are a machine-readable spec of "every action a
user can take, what it costs, and what state to show."** That is *already* 80% of a UI spec:
- every client `C_`/`CC_` → a **button** (an action the user can take);
- its **INFO** function → the **cost/preview** shown before they commit (IGNIS + STOA);
- the module's `UR_*`/`URC_*` readers → the **metrics/state** displayed on the page;
- the Talos wrapper signature → the **input form** (args) + validation.
So finishing INFO-completeness (workstream #1, Phase 2.3) is not just for the current UI — it is
the **raw material** the incorporation doc turns into pages and buttons. The two workstreams are
one arc: make the code's action surface complete + self-describing (INFO), then derive the UI from it.

## What the incorporation document will contain (the shape to write)
Organized on three axes — **role × asset-type × domain** — then rendered as pages:
1. **Roles:** asset owner · asset user (staker/holder/trader) · management & ownership transfer ·
   admin/governance · general/explorer (read-only browse).
2. **Asset types (7):** the token families (True-Fungible / Orto-Fungible / Semi-Fungible /
   Non-Fungible collectables) + the DeFi-primitive asset types (autostake / swap-pair / acquisition).
   The doc enumerates the exact set from the final code.
3. **Domains/modules:** DALOS accounts, TFT/DPOF/DPDC tokens, ATS, SWP, AQP (+ DSA/DemiPad), IGNIS.

For **each page**, the doc specifies:
- **Displayed metrics** and which reader (`UR_*`/`URC_*`) feeds each.
- **Buttons** = which client/admin function each fires.
- **Per button:** the execution function (Talos entrypoint) + its **INFO** function (cost preview) +
  required inputs (from the wrapper signature) + validation/enable-conditions.
- **Navigation/menu** architecture tying the pages together per role.
- **Mobile-first** responsive guidance (the owner already got one page mobile-friendly — build on it).

## Derivation method (how the agent builds it from the code)
Walk the **Talos** client surface (the only supported client path) module by module: for each
`C_`/`CC_`/`A_`/`AA_` entrypoint → identify role + asset type + domain → assign it to a page +
button → attach its INFO + readers + input form. The transitive-heavy (`CC_`/`AA_`) naming tells
the UI which actions are expensive/slow (progress UI, batching). The result is a complete,
deterministic page/button map — reviewable before a line of frontend is written.
**But that map is the SUBSTRATE, not the design** — see the next section.

## ⚠ This is an INTELLIGENT blueprint, NOT a button listing (owner, 2026-08-27)
The enumeration above is necessary but NOT sufficient. The document must apply **UX intelligence**
to determine how this monster of a codebase is *best* presented — grouped by **user intent and
journey**, not mechanically one-button-per-function. Concretely:

- **Role-based control panels.** A DPTF issuer gets a **token control panel**: tweak the token,
  grant/revoke roles, freeze / wipe / unfreeze accounts, mint / burn, manage supply — all the
  owner-surface for *that* token, coherently on one panel, not scattered as loose buttons.
- **Role-grant-driven UI (permission-aware rendering).** An account that has been *granted* a
  specific role must get the UI to *act on* that role — the interface renders per the caller's
  actual granted capabilities, so each user sees exactly the actions they can perform. This needs
  its own integration (read the account's roles → surface the matching control surfaces).
- **Workflow / journey flows**, not isolated calls. Autostake, e.g.: browse/list pools →
  participate → coil / curl → combine with vesting → create special tokens — presented as a guided
  flow with the state and previews (INFO) inline, because that's how a user actually *does* the
  thing. Same pattern for SWP (pairs, routes, LP), AQP (anchors/scores/pools/FVT), DemiPad, DSA.
- **Progressive disclosure + dashboards.** Summary/landing dashboards per role/asset that drill into
  the control panels and flows; hide advanced/rare admin surfaces behind clear affordances.
- **Miss nothing.** The intelligence is in the *structure*, but coverage must remain total — every
  built capability has a home in some panel/flow. The entrypoint catalog (substrate) is the
  checklist that guarantees nothing built is left unexposed.

So the deliverable is a **designed information+interaction architecture** over the code's full
capability set — the best way to present everything — with the enumeration underneath as the
completeness guarantee. Some scaffolding already exists (the owner's partial UI, incl. a
mobile-friendly page) — build on it, don't discard it.

## Scope + stakes (why this is worth doing right)
Full implementation opens Ouronet to users: create tokens of any kind, open autostake pools, make
swap pairs, do DeFi, and build their own modules on Ouronet token logic — the initial dream of
Ouronet as its own blockchain entity, made usable. Manual: 10-20 yrs solo / 2-4 yrs human-with-AI.
Scoped to an AI agent following this incorporation plan (once the final code shape exists): **weeks**.

## Status
DEFERRED — capstone, starts after workstream #1 finalizes and the final Pact shape is redeployed.
Captured now so it is not lost. See `POST-AUDIT-MAIN-ROADMAP.md` Phase 6.

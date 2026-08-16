# 2026-08-17 — layered capability composition: unevented core + named `@event` leaves

**Context:** fixing ATS audit finding C5 (`C_HOT-RBT|UpdatePendingBranding`/`UpgradeBranding` missing an
ownership check). First pass created ONE new capability (`ATS|C>HOT-RBT-BRD`) shared, `@event`-tagged,
directly `with-capability`'d by both functions. Owner corrected this.

## What was wrong

Sharing a single `@event` capability across two semantically distinct client actions (update vs upgrade)
collapses their on-chain events into one indistinguishable signature — an indexer/listener can no longer
tell which action happened from the event log alone. The instinct to avoid duplicating the validation body
was right; sharing the *event* to do it was wrong.

## What's correct — and already live in this exact file

`08_ATS.pact` already had the right pattern, unrecognized until pointed out:
`ATS|S>CONTROL-RECOVERY` (no `@event`) holds `(CAP_Owner atspair) (UEV_ParameterLockState atspair
false)`; `ATS|C>CONTROL-COLD-RECOVERY` / `ATS|C>CONTROL-HOT-RECOVERY` (also no `@event`) each add one more
check and `compose-capability` the core; five real `@event` leaves (`ATS|C>SET_COLD_FEES`,
`ATS|C>CONTROL-COLD-FEES`, `ATS|C>SET_COLD-DURATION`, `ATS|C>TOGGLE_ELITE`, `ATS|C>CONTROL-HOT-FEE`,
`ATS|C>SET_HOT_FEES`) sit on top, each `compose-capability`-ing the appropriate mid-tier cap.

Fixed C5 to match: `ATS|C>HOT-RBT-BRD` (core, no `@event`, holds the real `CAP_Owner`
+ `compose-capability (ATS|GOV)` body) with two thin `@event` leaves,
`ATS|C>HOT-RBT-UPDATE-BRD` / `ATS|C>HOT-RBT-UPGRADE-BRD`, each just
`(compose-capability (ATS|C>HOT-RBT-BRD entity-id))`.

## Durable rule

When two or more client-facing actions need identical/near-identical authorization but must stay
distinguishable as separate events: **one unevented core `defcap` holding the shared body, N thin
`@event` leaves that only compose it.** Never duplicate a validation body across sibling `@event` caps
just to get separate event names — that's precisely what drifts the moment one copy is patched and the
other isn't. Chains can nest more than two levels (core → mid-tier adds a check → leaf) when an action
needs the shared body plus something extra of its own.

Folded into `StoicSyntax.md` as new **§ 14.7** (existing §§ 14.7–14.8 renumbered to 14.8–14.9; one
cross-reference at line ~417 updated), plus a `§ 16` migration-checklist bullet and a `§ 17` cheat-sheet
row, since this pattern had zero documentation anywhere despite being in live use.

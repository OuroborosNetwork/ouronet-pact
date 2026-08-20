# DPDC Audit — cycle log & status tracker

Home for all audit data on the DPDC (Digital Property/Deed Collectable — Ouronet's NFT/SFT stack:
Semi-Fungibles `DPSF` + Non-Fungibles `DPNF`, plus the `EQUITY` shareholder-collection layer built on
top of DPSF) module family — sibling in rigor, structure, and cycle discipline to
`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/Audit/` and `1_SOVEREIGN/STAGE_01/2_Core/Audit/{ATS,SWP}/`. Goal: a
**comprehensive, evidence-backed sign-off that the code we ship is correct** — for every path, "if X and
Y and Z happen, the outcome is P, and P is correct."

## Scope — the entire DPDC surface (11 modules, enumerated from `MODULE-INDEX.md` + direct source reads,
not guessed)

| Module | File | Interface(s) | Role |
|---|---|---|---|
| `DPDC-UDC` | `2_Core/01_DPDC/01_DPDC-UDC.pact` | `DpdcUdcV1` (`0_Interfaces/02_Core.pact`) | Data-construction helpers — `AllowedClassForSetPosition`/`AllowedNonceForSetPosition` and friends. No tables. |
| `DPDC` | `2_Core/01_DPDC/02_DPDC.pact` | `DpdcV1` (self-hosted), `BrandingUsageTertiaryV1` | Core account/collection layer — `Properties`, `Nonces`, `VerumRoles`, `Account`, `AccountSupplies` tables for **both** `DPSF` and `DPNF`; account/collection deploy, spec + collection-element readers. |
| `DPDC-C` | `2_Core/01_DPDC/03_DPDC-C.pact` | `DpdcCreateV1` | Nonce/fragment-nonce creation + credit/debit variants (SFT and NFT). |
| `DPDC-I` | `2_Core/01_DPDC/04_DPDC-I.pact` | `DpdcIssueV1` | Account deploy + digital-collection issuance client entrypoints. |
| `DPDC-R` | `2_Core/01_DPDC/05_DPDC-R.pact` | `DpdcRolesV1` | Role toggles — add-quantity, freeze, exemption, burn, update, modify-creator, modify-royalties, transfer; role moves (create/recreate/set-uri). |
| `DPDC-MNG` | `2_Core/01_DPDC/06_DPDC-MNG.pact` | `DpdcManagementV1` | Control/pause, add-quantity, respawn, burn (SFT/NFT), and the `Wipe*` family (slim/heavy/pure/clean/dirty). |
| `DPDC-T` | `2_Core/01_DPDC/07_DPDC-T.pact` | `DpdcTransferV1`, `DpdcTransferV2` | Transfer, repurpose-collectable, IGNIS royalty collection, bulk transfer. |
| `DPDC-S` | `2_Core/01_DPDC/08_DPDC-S.pact` | `DpdcSetsV1` | Set mechanics — make/break SF & NF sets, primordial/composite/hybrid set definitions, class fragmentation, multiplier, rename/toggle. |
| `DPDC-F` | `2_Core/01_DPDC/09_DPDC-F.pact` | `DpdcFragmentsV1` | Fragmentation — repurpose fragments, make/merge fragments, enable nonce fragmentation. |
| `DPDC-N` | `2_Core/01_DPDC/10_DPDC-N.pact` | `DpdcNonceV1` | Per-nonce metadata mutation — royalty, IGNIS royalty, name, description, score, metadata, URI. |
| `EQUITY` | `2_Core/01_DPDC/11_EQUITY+.pact` | `EquityV1` | Shareholder-collection issuance + package-share morph/make/break on top of DPSF. |

Note on interfaces: unlike AQP/SWP, DPDC interfaces are **self-hosted** — each module file (except
`DPDC-UDC`, whose interface lives centrally in `0_Interfaces/02_Core.pact` since `DpdcUdcV1` types are
shared across all DPDC slices) declares its own `(interface DpdcXxxV1 ...)` at the top of the same file,
ahead of its `(module ...)` form. `DPDC-T` carries two interface generations (`DpdcTransferV1` +
`DpdcTransferV2`) live side-by-side — cascade/versioning history worth tracing during the audit.

Baseline REPL coverage: `REPL/Stage_02/[2.1]_DpdcCore.repl` (402 lines — deploy-order sandbox for the
family), `REPL/Stage_02/[6.1]_DPDC.repl` (1444 lines — scenario suite). `cd REPL && pact
Stage02_Tester.repl` / `cd REPL && pact Z.repl` are the full-pipeline baselines.

## The cycle (append-only)

| Round | File | What it is |
|-------|------|------------|
| **I — Findings** | `ROUND-01-FINDINGS.md` | Everything discovered before any fix. Frozen. |
| **I — Owner feedback** | `ROUND-01-OWNER-FEEDBACK.md` | Owner's verdict per finding + new StoicSyntax rules. Living. |
| **II — Fixes** | `ROUND-02-FIXES.md` | One entry per fix, applied **sequentially** (owner green-lights each). |
| **III — Re-verify** | `ROUND-03-REVERIFY.md` | Re-read fixed code cold, enumerate every path, prove correctness. *(not yet created)* |

Round files are **append-only / immutable once closed**. Only this README's tracker is edited in place.
Module `.pact` source changes **only** during a Fixes round, one fix at a time. **Round I is
audit-and-document only — no code is changed until the owner green-lights individual fixes.**

## Status legend
`OPEN` awaiting verdict · `CONFIRMED` bug to fix · `DESIGN` confirmed, needs a design decision first ·
`DOC-FIX` code right, doc wrong · `CONVENTION` not a bug → becomes a StoicSyntax rule/refactor ·
`FIXING` · `FIXED` (awaiting re-verify) · `VERIFIED` (re-audited clean).

## HARD RULE — no finding is "settled" until it's written down here

Mirrors the SWP audit's hard rule verbatim (that rule exists because findings silently skipped mid-session
went uncaught until an owner-requested audit-of-the-audit). A finding is presented **one at a time**, in
`ISSUES-RANKED.md` order. The moment a verdict is reached on it — REFUTED, DESIGN, DOC-FIX, CONVENTION, or
FIXED — **before moving on to the next finding**, the same turn must:

1. Append the verdict + reasoning to `ROUND-01-OWNER-FEEDBACK.md` (append-only, never edit past entries).
2. Update this file's tracker row (status column) and the cycle-log summary line.
3. Annotate `ISSUES-RANKED.md` for that finding (strike-through / status note).
4. If code changed: add a numbered entry to `ROUND-02-FIXES.md` with the diff and the REPL proof (pre-fix
   repro + post-fix pass, adversarially reverted and reconfirmed where feasible).

A finding that was only discussed in chat and never landed in these files **is not closed**, no matter how
thoroughly it was reasoned through, and must be treated as still-open until it is written down.

## Status tracker (living)

Round I is complete: 11/11 module passes landed in `ROUND-01-FINDINGS.md` (frozen), ranked #1C-#8C/
#9H-#22H/#23M-#38M/#39L-#55L in `ISSUES-RANKED.md` (56 findings total: 8 CRITICAL, 14 HIGH, 16 MEDIUM,
17 LOW numbered + 1 unnumbered doc-only LOW note). Every row below is `OPEN` awaiting owner verdict — per the HARD RULE above, findings are presented
one at a time in `ISSUES-RANKED.md` order and this table is updated in place as verdicts land.

| ID | Sev | Module | Short | Status |
|----|-----|--------|-------|--------|
| C1 | CRIT | DPDC-C | Unsigned `amount` on Credit/Debit → mint supply from nothing | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #1)** — live-reproduced pre-fix; single-chokepoint fix (new `DPDC-C::UEV_Amount`, called from `CreditOrDebitDPDC`, the sole write path for every SFT/fragment credit+debit across all 11 peer modules); post-fix exploit rejected as a real uncaught tx (nothing commits) + legit transfer still works + Z.repl green |
| C2 | CRIT | DPDC-T | `C_IgnisRoyaltyCollector` — no auth check, drains any smart-account patron | **REFUTED, HARDENED ANYWAY (`ROUND-02-FIXES.md` Fix #2)** — "any smart account" shape was never reachable (`IGNIS|C>DEBIT` already rejects smart-account patrons); narrowed to standard accounts, then shown royalty-nonzero and ownership-check-skipped can never coincide (same toggle gates both); owner requested a local `CAP_EnforceAccountOwnership` anyway so the debit doesn't depend on that external invariant — live-proven: legit patron still collects a real 500.0 IGNIS royalty, illegitimate patron hard-rejected at the new line |
| C3 | CRIT | DPDC-F | Unsigned `amount` on Make/Merge → inverted credit/debit | **ALREADY CLOSED BY FIX #1 — LIVE-PROVEN 2026-08-20** — `C_MakeFragments`/`C_MergeFragments` route through the exact same `CreditOrDebitDPDC`/`UEV_Amount` chokepoint; no new code needed. Negative-amount attempt rejected with a full stack trace landing on `03_DPDC-C.pact:436`; legit fragmentation (100 units → 100,000 fragment units) still works |
| C4 | CRIT | DPDC-F | `C_RepurposeCollectableFragments` — no consent/freeze/wipe gate | OPEN |
| C5 | CRIT | DPDC-MNG | Burn/wipe orphans fragment collateral held in `dpdc` escrow | OPEN |
| C6 | CRIT | DPDC-S | Composite set `allowed-sclass=0` — Make succeeds, Break permanently fails | OPEN |
| C7 | CRIT | DPDC-S | `C_UpdateSetMultiplier` — `let` type bug crashes every call | OPEN |
| C8 | CRIT | DPDC-S/DPDC-C | `how-many-sets` unbounded (entry-point gap; terminal impact unconfirmed) | OPEN |
| H1 | HIGH | DPDC | Talos SFT branding-update arity bug — feature 100% broken | OPEN |
| H2 | HIGH | DPDC-I | NFT issuance billed at SFT price — 20% silent revenue shortfall | OPEN |
| H3 | HIGH | DPDC-I | NFT genesis owner==creator denied royalty/exemption/creator roles | OPEN |
| H4 | HIGH | DPDC | Shared `XE_*` write surface — zero value-level validation | OPEN |
| H5 | HIGH | DPDC-R | Freeze/unfreeze gated on mutable `can-freeze` — brick risk | OPEN |
| H6 | HIGH | DPDC-MNG | Pause doesn't gate any mutating entrypoint in this module | OPEN |
| H7 | HIGH | DPDC-S | Set-class multiplier — no bound, retroactive instant re-pricing | OPEN |
| H8 | HIGH | DPDC-T | `UEV_TransferRoles` — receiver-role check is dead code | OPEN |
| H9 | HIGH | DPDC-T | `C_RepurposeCollectable` skips frozen/transfer-role gates | OPEN |
| H10 | HIGH | DPDC-C | Native NFT Credit — no existing-holder check | OPEN |
| H11 | HIGH | DPDC-UDC/DPDC-S | `UR_N|Score` fails to clamp unscored sentinel in 3/4 branches | OPEN |
| H12 | HIGH | DPDC-N | `C_UpdateNonceIgnisRoyalty` — no upper bound at all | OPEN |
| H13 | HIGH | DPDC-S | `score-multiplier` unvalidated at Define, checked at Update | OPEN |
| H14 | HIGH | EQUITY | Zero REPL/test coverage for the entire financial-instrument module | OPEN |
| M1-M16 | MED | various | See `ISSUES-RANKED.md` #23M-#38M | OPEN |
| L1-L17 | LOW | various | See `ISSUES-RANKED.md` #39L-#55L (+1 unnumbered doc-only note) | OPEN |

## Method (Round I)

One deep-read auditor per module (11 parallel passes covering all 11 files), matching the AQP/SWP audits'
method — each auditor loaded `StoicSyntax.md` first, worked read-only, and was told to assume nothing is
correct despite being live-adjacent code. Cross-module composition (`DPDC` core tables ↔ `DPDC-C`/`-I`/
`-R`/`-MNG`/`-T`/`-S`/`-F`/`-N` mutators, `EQUITY` → `DPDC-S`/`DPDC` composition) was traced explicitly
since DPDC's decomposition (one shared table set, many thin client modules) is the widest fan-out of any
audited family so far.

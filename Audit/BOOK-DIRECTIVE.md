# The Ouronet Audit Book — structure (owner directive, 2026-08-27)

A single consolidated, publishable document (expected **hundreds of pages**) telling the whole
security + engineering story of Ouronet, assembled just before the final redeploy. Three parts.

## Part I — Initial module audits
The per-module audits already done, from their `…/Audit/<MODULE>/` trees:
- **ATS** (`Audit/module-audits/ATS/`) — merged to main.
- **SWP** (`…/Audit/SWP/`), **DPDC** (`…/Audit/DPDC*`), **DPTF-DPOF** — in worktrees, merging.
- **AQP** (`Audit/module-audits/AQP/`).
- **DEMIPAD** (`1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/` — done on main, the last unaudited module).
Each: findings (ranked), owner verdicts, ROUND-02 fixes with diffs + proofs. Frozen historical record.

## Part II — The main-work round (Phases 1-5)
Everything the post-audit main work modifies/fixes, documented **audit-style as it lands**:
URCi cost architecture, the total INFO rehaul + completion, the IGNIS re-price, the AQP/FVT
capability splits, and the REPL coverage-completion + single-run refactor. Each change gets the
same treatment as a fix in Part I (location stated up front, diff, proof, rationale).
→ **Implication:** document main-work continuously — don't leave Part II as a retro write-up.

### Part II findings register — REPL coverage completion (P2/G1, closed 2026-09-09)
Six defects found by nothing more adversarial than *invoking every client entrypoint once and
asserting on the observable outcome*. Each has a pinning test in the suite; none are fixed yet.
Full write-up, with mechanism and reproduction, in
[`memories/2026-09-09-p2-g1-complete-and-its-findings.md`](memories/2026-09-09-p2-g1-complete-and-its-findings.md).

| # | where | defect | severity |
|---|---|---|---|
| 1 | `05_STOAICO.pact:496` | unguarded zero-amount urSTOA mint **deadlocks the distribution vault from round 2** — self-collect, admin flush and new-round inject all blocked | **severe** |
| 2 | `11_VST.pact` `XI_MergeNonces` | `C_Merge`/`C_Slumber` do not validate the dpof against their `vzh-tag`. The wrong-kind merge REPORTS SUCCESS and mints the wrong metadata shape — after which `C_Unsleep`, the only release path, fails a runtime typecheck. **The position and its value are permanently unrecoverable.** | **severe** |
| 3 | 5 sites, incl. `INFO-ONE+.pact:2465` | `(format "literal")` with no argument list — arity error; **`INFO_ATS\|Cull` is broken on every call** | high |
| 4 | `12_LIQUID.pact:125`, `01_DALOS.pact:489` | migration guard message says "offline" while `enforce gap` requires the pause **ON** | low |
| 5 | `16_SWPI.pact` / `UC_SlippageMinMax` | slippage bound is measured in **fee-less** tokens; delivered came in 8.2× the chosen tolerance below the floor, and a breach returns a string instead of reverting | design/UI |
| 6 | `DEMIPAD\|C>WITHDRAW` | provably dead `enforce` — `UR_Funds` enforces the identical predicate first | dead code |

### Part II findings register — architectural conformance (P2.5, 2026-09-09)

Derived from the STATED design rules rather than from the `enforce` statements, so the guard may
not exist at all. `REPL/tools/_conformance.py` (static) + `REPL/modules/CONFORMANCE.repl` (dynamic).

| # | where | defect | severity |
|---|---|---|---|
| 7 | `Stage_01/[2.1]_Dalos.repl:220` | the **master keyset is registered as a DALOS inter-module policy**, so `P|UEV_IMC` passes for any holder of it. "Talos is the only supported client path" therefore has an undocumented admin exception, and admin ops on that path are **unbilled**. The collector itself is NOT operable this way — `C_Collect` enforces the payer's own ownership. | medium / doc |
| 8 | 29 sites across `UR_`/`URC_`/`XI_` | **state-dependent `enforce` in unprotected readers and writers** — validation living outside the defcap. One has already caused a defect: `DEMIPAD::UR_Funds` is why `C>WITHDRAW`'s own `enforce` is dead code (finding #6). | medium |
| 9 | `02_DPDC.pact:1361` | `XE_DeployAccountWNE` has no `P|UEV_IMC`, unlike its immediate neighbour `XE_U|Rnaq`. | low |
| 10 ✅ **RULED** | `99_TS02-CPAD.pact` ×4 | calls `TS01-A::XB_DynamicFuelSTOA`, a protected `X*` on a sovereign module. **Owner ruling: CPAD is a citizen module AUTHORED BY THE ADMIN — deliberately in between the two roles.** It is the sole gas-funded launchpad path, so its wrappers must reach the refuel. Accepted, and bounded: those four calls are expected, a fifth is not. | accepted |

| 11 ✅ **FIXED** | 14 ops in 4 families | **single `C_`/`A_` prefix on ops that reach a heavy `URH_*`/`URHC_*` scan** — the prefix promises bounded gas, the tree does not deliver it. `DPOF::C_WipeHeavy`'s own docstring says it uses "expensive functions like `select` or `keys` (that arent meant to be used in transactional context)"; `ATSU::C_RemoveSecondary`'s says it derives the complete account list via `URH_ExistingAutostakePairs`. **The prefix contradicts the docstring inside the same function.** Renamed to `CC_`/`AA_` on the owner's ruling — 126 replacements across 30 files, since the names are also IGNIS price-table keys. `single-reaches-heavy` is now 0. | medium |

| 12 | `05_DPTF.pact:1939` | **`UEV_ReservationState`'s two messages are INVERTED.** `(if state (enforce x "…already open…") (enforce (not x) "…already closed…"))` — the first arm fires when reservations are CLOSED and reports "already open"; the second fires when they are OPEN and reports "already closed". The guard is correct; both messages state the opposite of the condition that produced them. Same class as finding #4. | low |

Two further results are **documentation gaps, not defects**, and are recorded as such: 24 `UC_`
functions `enforce` over their own arguments (with `UC-no-read` at **0**, so the purity half of
the contract is obeyed exactly), and 40 core `C_`s build no cumulator because a second, equally
correct billing shape exists that CLAUDE.md does not describe.

**The methodological point for Part III:** all six were reachable without a red team. Whatever the
adversarial phase costs, it should not be spent re-finding what a first invocation would have.

## Part III — Red-team attack audit (Phase 6.1)
The comprehensive multi-agent adversarial attack on ALL modules, in final shape, before redeploy.
Attack surfaces: capability/auth bypass (module-boundary guard, composed caps), arithmetic/rounding/
precision, economic & MEV (front-run, sandwich, ratio extremes), ordering/reentrancy-like,
cross-module boundary abuse, defpact/Hydra-slice races, gas-station exploitation, sentinel/collision.
Method: fan out attackers → synthesize candidate findings → **adversarially verify** each against
code (CONFIRMED/REFUTED/STYLISTIC) → fix → re-test → document. Vulnerabilities sought, found, fixed.

## Assembly + timing
Assembled at **Phase 6.2**, after the red team completes and before the **Phase 7 redeploy**.
Consolidate the three parts into one book (index, per-module chapters, cross-references, the
StoicSyntax/architecture rules that came out of the audits). Publishable alongside the deployed code.
**Published together with the comprehensive Documentation** (`DOCUMENTATION-PLAN.md`, roadmap Phase 9)
in the Ouronet Website's **Documentation + Audit region** — the Audit Book is the "how we made it
sound" half; the Documentation is the "what it is and does" half.

## Why it gates the redeploy
The redeploy (Phase 7) ships the *final shape*. The book is the evidence that shape is sound —
it must be complete (all audits closed, red team done + fixed) before code is deployed and the
UI capstone (Phase 8) is built on top of it.

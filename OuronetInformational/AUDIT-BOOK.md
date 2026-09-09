# The Ouronet Audit Book — structure (owner directive, 2026-08-27)

A single consolidated, publishable document (expected **hundreds of pages**) telling the whole
security + engineering story of Ouronet, assembled just before the final redeploy. Three parts.

## Part I — Initial module audits
The per-module audits already done, from their `…/Audit/<MODULE>/` trees:
- **ATS** (`1_SOVEREIGN/STAGE_01/2_Core/Audit/ATS/`) — merged to main.
- **SWP** (`…/Audit/SWP/`), **DPDC** (`…/Audit/DPDC*`), **DPTF-DPOF** — in worktrees, merging.
- **AQP** (`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/Audit/`).
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
| 2 | `11_VST.pact` `XI_MergeNonces` | `C_Merge`/`C_Slumber` do not validate the dpof against their `vzh-tag`; wrong-kind merge mints the wrong metadata shape and crashes later, data-dependently | high |
| 3 | 5 sites, incl. `INFO-ONE+.pact:2465` | `(format "literal")` with no argument list — arity error; **`INFO_ATS\|Cull` is broken on every call** | high |
| 4 | `12_LIQUID.pact:125`, `01_DALOS.pact:489` | migration guard message says "offline" while `enforce gap` requires the pause **ON** | low |
| 5 | `16_SWPI.pact` / `UC_SlippageMinMax` | slippage bound is measured in **fee-less** tokens; delivered came in 8.2× the chosen tolerance below the floor, and a breach returns a string instead of reverting | design/UI |
| 6 | `DEMIPAD\|C>WITHDRAW` | provably dead `enforce` — `UR_Funds` enforces the identical predicate first | dead code |

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

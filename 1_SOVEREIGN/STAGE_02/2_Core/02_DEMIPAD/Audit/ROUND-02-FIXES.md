# DEMIPAD Audit — Round-02 Fixes

Each fix: location · design (owner-agreed) · diff summary · REPL proof · green-gate. One issue at a time.

---

## #1C — STOAICO `C_Collect` vault drain → FIXED + PROVEN (2026-08-29)

**File:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/05_STOAICO.pact` · proof
`REPL/Stage_02/[6.3]_STOAICO.repl` (TX-02..04).

**Owner-agreed design — the "distribution-round" (generation) model + admin push-flush.** STOAICO is a
single-shot ICO distribution vault, but built to allow multiple inject rounds; the fix keeps that while
enforcing "one collect per round" (killing the drain) and adds an admin flush that push-collects
stragglers *to themselves*.

**Changes:**
- Schema: `UserContributionSchema` += `last-collected-round`; `GeneralContributionSchema` +=
  `distribution-round` (init 0). Constructor/readers/writers extended (`UR_User5`, `UR_Global11`,
  `XI_MarkCollected`, `XI_IncrementDistributionRound`).
- **Per-round idempotency (the drain-killer):** `STOAICO|REDEEM-CONTRIBUTION` now enforces
  `(< last-collected-round distribution-round)`; `C_Collect` stamps the round on collect. A second
  collect in the same round is rejected — so `unclaimed-count` can no longer be walked down to the
  whole-supply `==1` dust-sweep by repeated zero-value re-collects. The dust sweep is *kept* and is now
  safe (only the genuine last unclaimed staker can reach it).
- **Inject barrier:** `A_Inject` enforces `unclaimed-count == 0` before opening a new round, then
  `XI_IncrementDistributionRound`. A new round can't open until the previous is fully collected.
- **Shared settle-core:** `C_Collect`'s body extracted to `XI_CollectFor` (SECURE), reused by the flush.
- **Admin flush family (push-collect to the rightful users, not admin/burn):**
  `URH_UncollectedAccounts` (Hydra preflight, the one heavy scan) → `Ap_FlushUncollectedSlice` (parallel,
  retryable, idempotent-per-account) + `AA_FlushUncollected` (solo/heavy), under `STOAICO|FLUSH`. Delivers
  each straggler its own wSTOA (+ dust to the last) and urSTOA, driving `unclaimed-count → 0` so the next
  inject can proceed. UI constructs the parallel legs from the `URH_` plan.
- New-staker init: `last-collected-round := current distribution-round` (a mis-ordered post-inject stake
  is not eligible for the already-injected round).

**Proof (`[6.3]` TX-02..04, run on a deployed stack — exit 0, 10 `expect` + 2 `expect-failure`, 0 fail):**
emma self-collects her exact share; **double-collect rejected**; **A_Inject blocked** while lumy
outstanding; `URH_UncollectedAccounts` lists exactly lumy; `AA_FlushUncollected` push-collects lumy
(delivered to lumy, sweeping the dust as the last); `unclaimed → 0`; vault `wstoa-supply → 0`;
**CONSERVATION: emma + lumy wSTOA == 10,000,000 injected.**

**Notes / follow-ups (logged, not blocking #1C):**
- `[6.3]_STOAICO.repl` is not yet in the default `Z.repl` pipeline (needs the DEMIPAD sale-module IMC
  policies registered first — now done self-sufficiently in its own TX000). Wiring it into the pipeline
  → REPL-finalization phase (roadmap task #79).
- INFO cost-preview functions (`INFO_FlushFull`/`INFO_FlushSlice`) deferred to the whole-codebase INFO
  phase (roadmap task #78) — STOAICO has no INFO surface yet; the `URH_` preflight already gives the UI
  everything it needs to construct the flush legs.

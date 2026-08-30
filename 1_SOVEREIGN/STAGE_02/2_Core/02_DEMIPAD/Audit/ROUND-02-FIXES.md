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

---

## #2H — Demipad `retrieval` toggle is dead state → FIXED + PROVEN (2026-08-29)

**File:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact` · proof `REPL/Stage_02/[5.3]_Launchpad.repl`
(TX-2H..2H-e).

**Bug:** `UR_Retrieval` was read in exactly one place (the no-op check inside `TOGGLE-RETRIEVAL`); the
`RETRIEVE-*` caps (identical to the `FUEL-*` caps) gated retrieval on owner-or-admin ownership only,
never on the flag — so the advertised anti-rug lock ("`retrieval=false` ⇒ assets only leave via a buy")
was a no-op and the asset owner could pull deposited inventory mid-sale.

**Owner-agreed design — Option A (admin override).** A new shared cap
`DEMIPAD|C>RETRIEVAL-GATE (asset-id)` = `enforce-one [ admin-guard | (enforce (UR_Retrieval asset-id)) ]`,
composed by all four `RETRIEVE-*` caps (FUEL untouched — deposits always allowed). Net: admin may always
retrieve; a non-admin owner/creator may retrieve only when `retrieval=true`; others still blocked by
ownership. ~6-line cap + 4 one-line composes.

**Proof (`[5.3]` TX-2H..2H-e, run on a deployed stack):**
- **Fix (exit 0):** admin locks retrieval → non-admin `test-capability (RETRIEVAL-GATE)` **rejected**
  ("retrieval is LOCKED") · admin **passes** while locked (Option A) · non-admin **passes** once the
  admin re-enables retrieval.
- **Bug reproduced (exit 1):** with the gate body temporarily neutered to `(enforce true …)`
  (pre-fix simulation), the non-admin BLOCK assertion fails — `expected failure, got result: ()` — i.e.
  the non-admin passes the gate while `retrieval=false`. Gate restored, re-run green. Full `Z.repl` green.

**Follow-up (logged):** the NF variant (`RETRIEVE-NON-FUNGIBLE`) is currently unreachable due to **#7M**
(NF transmit mis-wired to the SF cap); the gate is on all four caps so it's correct once #7M lands. The
transmit functions themselves are `UEV_IMC`-gated and marked "to be made after Upgrade" — their Talos
wiring is separate (out of #2H scope).

---

## #3H + #4H — Custodians `C_Acquire` unguarded + broken availability reader → FIXED + PROVEN (2026-08-29)

**File:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/03_Custodians.pact` · proof
`REPL/Stage_02/[5.3]_Launchpad.repl` (TX-3H4H). Fixed together — they're coupled (the cap's reader is #4H).

**Bug:** Custodians is a half-wired copy of Snakes. (#3H) `C_Acquire` dropped straight into its `let` and
never opened `CUSTODIANS|ACQUIRE`, so the per-nonce supply cap (`enforce amount <= available`), the
`P|CUSTODIANS|CALLER`/`REMOTE-GOV` policy composes, and the `@event` were all skipped. (#4H) the cap's
`UR_NonceSaleAvailability` read the non-existent `GOV|LAUNCHPAD|SC_NAME` → runtime "Unbound free
variable" (latent; no test exercised it). So adding the cap without fixing #4H would just crash.

**Fix:** (#3H) wrap the body in `(with-capability (CUSTODIANS|ACQUIRE nonce amount) …)`, mirroring
Snakes:284. (#4H) `GOV|LAUNCHPAD|SC_NAME` → `GOV|DEMIPAD|SC_NAME` (the real member Snakes uses).

**Proof (`[5.3]` TX-3H4H, deployed stack):**
- **Fix green (exit 0):** `UR_NonceSaleAvailability(-1)` resolves to `-1` (pad holds none; no crash) —
  #4H · an over-supply Custodian acquire (`amount 999999999`) is **rejected** with "Insufficient Assets
  for Acquisiton" — #3H (the cap's supply enforce now fires).
- **Bug reproduced (exit 1):** reverting #4H to `GOV|LAUNCHPAD|SC_NAME` → `Unbound free variable …
  DEMIPAD.GOV|LAUNCHPAD|SC_NAME` at Custodians:193 through `UR_NonceSaleAvailability`. Restored, re-run
  green. Full `Z.repl` green.

**KDA→STOA naming (owner 2026-08-29):** NOT touched here. Per the settled SWP-audit L58 decision, the
Kadena→STOA rename (`kda-pid→stoa-pid`, `wkda→wstoa`, labels/comments; the oracle is already the STOA
price hardcoded at $0.10 pending the Aletheia Oracle) is **one dedicated protocol-wide sweep after all
audits — never piecemeal**. Broadened + logged on the roadmap (Phase 1.4).

**Still-open Custodians divergences (own turns):** #9M (`UC_NonceQuintessence` enforces), #10M
(`UR_NonceSaleAvailability` enforces where Snakes doesn't), #15L (missing `UEV_IMC`).

---

## #5M — STOAICO `A_Inject` div-by-zero on empty vault → FIXED + PROVEN (2026-08-29)

**File:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/05_STOAICO.pact` · proof `REPL/Stage_02/[6.3]_STOAICO.repl`
(TX-01b + TX-02).

**Bug:** `gained-rps = floor(wstoa-amount / vault-score, …)` had no `vault-score > 0` guard, so an inject
into a vault with no contributions (`vault-score == 0`) aborted with a raw div-by-zero.

**Owner-agreed design — the AQP escrow-on-empty (zombie-rewards) architecture** (owner: *"same
architecture… the zombie amount, postponed to the next injection when score is non-0"*), mirroring
`XI_DistributeInjectAmount`:
- Schema: `GeneralContributionSchema` += `zombie-rewards:decimal` (init 0). Reader `UR_Global12`, writer
  `XI_SetZombieRewards`.
- `A_Inject` branches on `vault-score`:
  - **FLUSH (`vault-score > 0`):** `eff = wstoa-amount + zombie`; `rps += floor(eff / vault-score)`;
    supply += amount; `zombie → 0`; #1C barrier + reset unclaimed + advance round. The division only ever
    runs here, so a zero denominator is structurally impossible.
  - **ESCROW (`vault-score == 0`):** move + count the amount, `zombie += amount`; nothing distributed
    (no rps/round/unclaimed change). Distributed by the next non-zero-score inject.
- The floor-to-0 edge is left unguarded (needs a $10¹⁹ vault; a `gained-rps>0` guard would false-reject a
  legit small flush).

**Proof (`[6.3]` TX-01b + TX-02, deployed stack):**
- **Fix green (exit 0):** inject 3M into the empty vault → **escrows** (`zombie=3M`, `supply=3M`, `rps=0`,
  `round=0` — no crash) · then stake + inject 7M → **FLUSH** (`zombie → 0`, `supply=10M`) · and
  **CONSERVATION: emma + lumy wSTOA == 10,000,000** — the escrowed 3M reaches the stakers through the flush.
- **Bug reproduced (exit 1):** forcing the FLUSH branch on the empty vault (`if true`) →
  `Arithmetic exception: div by zero` at STOAICO:444 (`floor (/ eff vault-score)`). Restored, re-run green.
  Full `Z.repl` green.

---

## #6M — STOAICO urSTOA double-credit → FIXED + PROVEN (2026-08-29)

**File:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/05_STOAICO.pact` · proof `REPL/Stage_02/[6.3]_STOAICO.repl`
(TX-06M).

**Bug:** `C_Collect` zeroed `urstoa-earned` but `XI_UpdateUrstoaEarned` treats it as the cumulative
entitlement `floor(score/5)` to compute the incremental `diff`. So a stake AFTER a collect saw
`diff = floor(new-score/5) − 0` (the full entitlement, not the increment) → re-credited the already-paid
urSTOA and over-decremented the 250k `urstoa-left` budget; a later collect double-minted.

**Owner-clarified model → the correct fix is a PHASE GATE, not an accounting tracker.** urSTOA is earned
ONLY during the ICO phase; once the ICO concludes (the inject/distribution), future contributions earn no
urSTOA, and the unsold remainder of the 250k returns to the foundation (simply never minted). The
`distribution-round` is the exact signal: round `0` = ICO/contribution phase; the first inject → round ≥ 1
= concluded.

**Fix:** in `A_Stake` and `A_Unstake`, gate `XI_UpdateUrstoaEarned` on `(= (UR_Global11) 0)` — earn/adjust
urSTOA only in round 0. Post-ICO stakes skip it entirely, so `urstoa-earned` can't be re-credited and the
budget can't be re-spent (the existing collect-time reset is now harmless — nothing re-earns after round 0).
No new field; the foundation remainder is automatic (unearned urSTOA is never minted).

**Proof (`[6.3]` TX-06M, deployed stack):**
- **Fix green (exit 0):** after the ICO (round 1), an admin stake of $5000 earns nothing — `urstoa-left`
  `245932 → 245932` (unchanged) and emma's `urstoa-earned 0 → 0` (not re-credited).
- **Bug reproduced (exit 1):** removing the gate → the same stake re-earns `floor(7843/5)=1568` urSTOA
  (emma `earned 0 → 1568`) and over-drops `urstoa-left 245932 → 244364`. Restored, re-run green. `Z.repl` green.

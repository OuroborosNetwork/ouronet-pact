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

**Still-open Custodians divergences (own turns):** ~~#9M (`UC_NonceQuintessence` enforces)~~ FIXED,
~~#10M (`UR_NonceSaleAvailability` enforces where Snakes doesn't)~~ FIXED, #15L (missing `UEV_IMC`).

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

---

## #7M — Demipad NF transmit guarded by the SF cap → FIXED + PROVEN (2026-08-29)

**File:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact` · proof `REPL/Stage_02/[5.3]_Launchpad.repl`
(TX-7M).

**Bug:** `X_TransmitCollectables` took `son` (true=SF, false=NF) but **hardcoded the SEMI caps** for both
branches; the `FUEL/RETRIEVE-NON-FUNGIBLE` caps existed but were wired to nothing. Since the SEMI cap
enforces `UEV_AssetFungibility asset [false true]`, a real NF asset (`[false false]`) could never
fuel/retrieve (dead feature / stuck), and an SF routed through the NF entry passed the SF guard but
transferred with `son=false` (type mismatch).

**Fix:** branch the cap on `son` (2×2: fuel/retrieve × SF/NF), wiring the existing NON caps into the
`son=false` branches. Bonus: the NF retrieve path now inherits the #2H `RETRIEVAL-GATE` (already composed
by `RETRIEVE-NON-FUNGIBLE`).

**Proof (`[5.3]` TX-7M, deployed stack — exit 0):** on the registered SF custodians (DHOC, `[false true]`),
`UEV_AssetFungibility(DHOC, [false true])` passes (SEMI path accepts SF) and
`UEV_AssetFungibility(DHOC, [false false])` **fails** (NON path rejects SF) — so post-fix an SF routed
through the NF entry (son=false → NON cap) is blocked (was the type mismatch). The NF-works direction is
the exact mirror (`[false false]` passes the NON cap / fails the SEMI cap) — the reason the pre-fix
hardcoded-SEMI path made real NF assets un-fuelable. `Z.repl` green. (A full NF-transmit end-to-end needs
a real DPNF collection + the `UEV_IMC`/"after-Upgrade" transmit path — same caveat as #2H.)

---

## #8M — Demipad `direct-injection` phantom seller funds → FIXED + PROVEN (2026-08-30)

**File:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact` · proof
`REPL/Stage_02/[5.3]_Launchpad.repl` (TX-8M).

**What it was.** `direct-injection` is an *unbuilt* feature. In `C_Deposit`, under
`direct-injection=true`, the inbound token transfer `ico3` becomes `EOC` (no `cod+rem` tokens enter the
shared launchpad account), but the seller-ledger credit `XI_DepositForAsset asset-id … rem …` still ran —
crediting withdrawable `funds-*` with **no tokens behind it**. A later `C_Withdraw` would then pull `rem`
out of *other* sellers' proceeds in the same custody account (drain). Doubly latent: (a) all four live
callers (Spark/Snakes/Custodians/STOICPAY) hardcode `direct-injection=false`, and (b) the old cap only
let `true` through when the admin flag `UR_DirectInjection` was ON — but the flag *could* be flipped, so
it was a landmine, not dead code.

**Owner design (settled).** Direct-injection only ever concerned the **`cod` (royalty)** portion — route
it into an *injection profile* once AQP vaults are live (e.g. 50% Demiurgos Holdings / 50% Coding-Division
score, both Deb-free), OR collect `cod` locally and let a **daily automaton drip-inject** it. The seller's
`rem` is unaffected — it must always transfer in and always be credited. Building the real path needs:
finalize+redeploy rehaul → deploy vaults → rewrite injection to a forward-module/profile → redeploy — not
REPL-testable now. So: **leave a true stub, keep the working non-direct path** (the automaton gives full
functionality without the deploy gymnastics). A silent no-op body was rejected as the stub because a
flipped flag would then take *no payment* while the acquire flow still delivers the asset (free-asset
hole) — the stub must make direct-injection **unreachable**, not silent.

**Changes:**
- New unprotected `UEV_DirectInjection (direct-injection:bool)` — `(enforce (not direct-injection) …)`,
  **unconditional** (no admin flag). `DEMIPAD|C>DEPOSIT` composes it in place of the old flag-gated
  `(if direct-injection (enforce (UR_DirectInjection) …) true)`. Extracted as a `UEV_` (mirrors
  `UEV_AssetFungibility`) so it is directly assertable past the `UEV_IMC` gate on `C_Deposit`.
- Removed the now-unused `read-direct-injection` let-binding from the cap.
- Defense-in-depth: `C_Deposit`'s `XI_DepositForAsset` credit is now wrapped in
  `(if (not direct-injection) … true)` — so even if the cap block is later loosened during the AQP build,
  the seller credit cannot fire until the `rem` transfer is wired (no phantom funds).
- `UR_DirectInjection` state kept **reserved** to gate the real path when built.

**REPL proof (TX-8M).** With the admin flag turned **ON**: `UEV_DirectInjection true` still fails
*"Direct Injection is not yet available"* (hard-block ignores the flag) and `UEV_DirectInjection false`
passes. Bug direction proven by neutering `UEV_DirectInjection` back to the old flag-gated form → with the
flag ON, `UEV_DirectInjection true` returns `true` instead of failing (`expected failure, got result:
true`) — the phantom path would proceed. Restored → 3/3 green, full boot clean, 0 load failures.

**Follow-up (future, post-AQP):** build the real direct-injection — route `cod` to the injection profile
(or collect-then-daily-drip) + transfer `rem` in + re-enable the seller credit. Logged in
`POST-AUDIT-MAIN-ROADMAP.md` (STAGE 3 / post-AQP).

---

## #9M — Custodians `UC_NonceQuintessence` (declared pure) enforces → FIXED + PROVEN (2026-08-30)

**File:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/03_Custodians.pact` · proof
`REPL/Stage_02/[5.3]_Launchpad.repl` (TX-9M).

**What it was.** `UC_NonceQuintessence:integer (nonce validation:bool)` is prefixed `UC_` — StoicSyntax
"pure compute on args, no table reads, no `enforce`" — yet its first line called
`UEV_ConditionalAcquisitionNonce nonce validation`, i.e. an enforce (`UEV_AcquisitionNonce` rejects any
nonce ∉ `[-3 -2 -1]`). The whole `validation:bool` param existed only to toggle that hidden enforce, so a
"pure" call could abort a tx — a contract violation (and part of the "Custodians is a half-wired copy of
Snakes" theme; Snakes has no such UC). Redundant, too: the sole caller `URC_NonceCosts` passes
`validation=true` and is only reached from `C_Acquire` **inside** `(with-capability (CUSTODIANS|ACQUIRE …))`,
which already validates the nonce (`UR_NonceSaleAvailability`→`UEV_AcquisitionNonce`) before any cost math.

**Fix (make it genuinely pure — no behavioral change on the acquire path):**
- `UC_NonceQuintessence:integer (nonce:integer)` — dropped the `validation` param and the `UEV_` call;
  body is now just the pure mapping (-1→1, -2→10, else→100). Interface signature updated to match.
- Caller `URC_NonceCosts` → `(UC_NonceQuintessence nonce)`.
- Removed the now-dead `UEV_ConditionalAcquisitionNonce` (interface decl + def) — its only user was the UC.
- Nonce validity on the **mutation** path is unchanged (the `CUSTODIANS|ACQUIRE` cap enforces it, post-#3H).
  Info-read previews (`URC_*`) correctly stop enforcing — which is right, since `URC_*` must not enforce.
- No external consumers (repo-wide grep: only the internal caller + doc references; DSA only mentions it
  in a design note, no live call).

**REPL proof (TX-9M).** Green: `UC_NonceQuintessence` returns 1/10/100 for -1/-2/-3; an out-of-range nonce
(5) returns 100 with **no enforce/abort** (purity); and `C_Acquire … nonce=5` is still rejected with
"Invalid Custodian Acquisition Nonce" (cap still validates). Bug direction proven by re-injecting
`(UEV_AcquisitionNonce nonce)` into the pure UC → the out-of-range purity assertion fails (the "pure" call
aborts). Restored → 5/5 green, full boot clean, 0 load failures.

---

## #10M — Custodians `UR_NonceSaleAvailability` enforces (twin Snakes doesn't) → FIXED + PROVEN (2026-08-30)

**File:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/03_Custodians.pact` · proof
`REPL/Stage_02/[5.3]_Launchpad.repl` (TX-10M).

**What it was.** `UR_NonceSaleAvailability:integer (nonce)` is a `UR_` (table-read prefix, must not
`enforce`) but ran `(UEV_AcquisitionNonce nonce)` before its DPDC supply read — where the identical-shaped
Snakes twin does not. So a `UR_` info-read could abort a tx (contract violation; the "half-wired copy of
Snakes" tell). **Interlocks with #9M:** this is the very enforce the `CUSTODIANS|ACQUIRE` cap relied on to
validate the nonce, so it had to be **relocated, not removed**.

**Fix (identical behavior, correct home):**
- `UR_NonceSaleAvailability` → dropped `(UEV_AcquisitionNonce nonce)`; now a pure DPDC supply read
  (matches Snakes; honors the `UR_` contract; #4H's info-read stays clean).
- `CUSTODIANS|ACQUIRE` cap → added `(UEV_AcquisitionNonce nonce)` as its first line, before the supply
  read. Nonce validity + the exact "Invalid Custodian Acquisition Nonce" error stay on the mutation path.
- Kept Custodians' explicit `[-3 -2 -1]` check (not deleted to mirror Snakes verbatim): Snakes has a
  different nonce model (positive EQUITY tiers, implicit supply-0 rejection); Custodians' finite fragment
  set warrants a clear error. #10M is about the prefix, not removing a legitimate check.

**REPL proof (TX-10M).** Green: `UR_NonceSaleAvailability 5` returns the DPDC "holds none" sentinel `-1`
with **no abort** (pure read; pre-fix it threw "Invalid Custodian Acquisition Nonce"); `UR_NonceSaleAvailability -1`
resolves (>= -1); and `C_Acquire … nonce=5` is still rejected "Invalid Custodian Acquisition Nonce" (cap
now holds the enforce). Bug direction proven by re-injecting `(UEV_AcquisitionNonce nonce)` into the UR →
the pure-read assertion fails (the reader aborts). Restored → all green, full boot clean, 0 load failures.

---

## #11M — STOICPAY workspace diverged from the live deployed module → FIXED + PROVEN (2026-08-30)

**File:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/04_STOICPAY.pact` · fixture
`REPL/Stage_02/[5.3]_Launchpad.repl` (TX-11M) · proof `REPL/Stage_02/[6.1]_DPDC.repl` (TX-015 buy + TX-015b verify).

**Root cause — not a live bug; a workspace test-divergence.** The audit's "2× KPAY out vs `sold = 100M −
0.4·resident`" finding was measured against the **workspace** copy, which had been simplified *for testing*
to a 3-recipient / **1.0×** team split (COMPANY + VENTURE1/2; the live block sat commented right below).
Pulling the **live deployed** `ouronet-ns.DEMIPAD-STOICPAY` via the Pythia dirty-read gateway
(`describe-module` → `code`) showed the on-chain module is **correct**: a 5-recipient **1.5×** team split
(COMPANY 0.5× + VENTURE1..4 0.25× each) — i.e. the intended **40/60** (100M to buyers = 40% of supply,
150M team = 60%, 250M end supply). With the 1.5× team drain, resident drops 2.5× per buy and
`sold = 100M − 0.4·resident` tracks buyer-amount **exactly** (the "20% under-count" existed only in the
diverged 1.0× test copy). Live accounting formula == workspace formula; only the transfer split diverged.

**Fix — re-sync the workspace to live, zero divergence (owner directive):**
- `04_STOICPAY.pact`: activated the live 5-address team block (COMPANY + VENTURE1..4, the real deployed
  IDs) and set `C_BuyStoicPay`'s `ico3` to `[twenty-p ten-p ten-p ten-p ten-p]` (= 1.5×). Now byte-equal
  to the deployed module.
- REPL support: `[5.3]` TX-11M deploys the live team recipient accounts so the buy-side
  `C_MultiBulkTransfer` resolves. COMPANY + VENTURE1 already exist from genesis; VENTURE2/3/4 are
  registered via admin `TS01-A::DALOS|A_DeployStandardAccount` (arbitrary key guard — standard-account
  deploy validates only the `Ѻ` prefix + glyphs + key-based guard, not ID-from-guard derivation, so the
  exact live IDs register cleanly).

**REPL proof.** Boot + `[5.3]` (TX-11M green, 0 load failures) then the `[6.1]` TX-015 buy of **1400 KPAY**
runs clean, and TX-015b asserts the split landed exactly: COMPANY **700** (0.5×) + VENTURE1..4 **350** each
(0.25×) = **2100 = 1.5×**. (Verified via an isolated boot+[5.3]+buy-tx extraction — the full `[6.1]` needs
the unrelated Nosferatu/Bloodshed mass-mint Populate chain to reach the buy.)

**Note.** The StoicPay **sale is suspended** and its continuation (tokenomics / whether to resume) is a
separate open product decision — unaffected by this code re-sync, which simply makes the workspace faithful
to what is deployed. General lesson recorded: for "does the workspace match live" questions, pull the
deployed `code` via Pythia and diff — the workspace may carry deliberate test simplifications.

---

## #12M — Launchpad slippage protection (uniform, both variants) → FIXED + PROVEN (2026-08-30)

**Files:** `00_Demipad.pact` (core chokepoint) · `01_Spark.pact` · `02_Snakes.pact` · `03_Custodians.pact` ·
`04_STOICPAY.pact` · `3_Talos/03_TS02-DPAD.pact` · proof `REPL/Stage_02/[6.1]_DPDC.repl` (TX-015 + TX-015c).

**What it was.** All buys compute cost live (`admin-price × oracle-PID`); the buyer committed only to a
token amount, no slippage/max-cost bound — an admin price change or oracle move between the UI's poll and
the tx being mined could grief the buy (exact caps mismatch) or, with a loose wallet cap, overpay.

**Owner-agreed design — mirror SWP's with/no-slippage, adapted to bound a COST (not a min output), one
decimal, no schema.** Two variants, uniform across every sale entity, user-chosen:
- **Variant 1 (default, with slippage).** The UI passes a single `max-cost:decimal` = displayed-cost ×
  (1 + slippage/100) (slippage ≤ 50 by UI policy). `C_Deposit` enforces `amount-in-dollars <= max-cost`
  via the new `UEV_SlippageCost` (sentinel `< 0` = no bound). The UI builds the signed `coin.TRANSFER`
  caps from `URC_Acquire`, which now takes `slippage` and pads each leg by `(1 + slippage/100)` (new pure
  `UC_SlippageFactor`) so the signed managed cap is a ceiling with headroom — execution transfers the
  real price ≤ ceiling, succeeding within tolerance, failing safely beyond it.
- **Variant 2 (slippage off).** `max-cost` sentinel `< 0` (no on-chain bound) + `URCI_Acquire` installs
  the live-price caps in-code; the UI does NOT sign them and warns the buyer the mined price may differ
  (seller price change or oracle move between display and mining). `URCI_Acquire` existed only on
  Custodians — added uniformly to Spark/Snakes/StoicPay.

Why a single decimal, not the percent (owner-reasoned): the on-chain buy holds no poll-time baseline, so
a bare percent has nothing to apply; the absolute `max-cost` is self-contained and directly enforceable.
The 50% tolerance ceiling is a UI policy (permissioned admin + hardcoded $0.10 STOA oracle make the
absolute ceiling the meaningful on-chain guarantee). No separate max-cost enforce beyond the deposit cap —
the managed `coin.TRANSFER` cap and `UEV_SlippageCost` are the bound.

**Cascade (signature changes threaded in lockstep):** `C_Deposit` (+`max-cost`) + `DEMIPAD|C>DEPOSIT` +
the `DemiourgosLaunchpadV1` interface; `URC_Acquire` (+`slippage`, padding); each sale module's
`C_Acquire`/`C_BuyStoicPay`/`C_BuySparks` (+`max-cost`) + `URC_Acquire` (+`slippage`) + new `URCI_Acquire`
+ their interfaces; the four `TS02-DPAD` buy wrappers (+`max-cost`) + interface. Full deploy path compiles
clean (0 errors).

**REPL proof (`[6.1]` TX-015 + TX-015c, isolated boot+[5.3]+buy extraction).** Variant-1 ACCEPT: the 1400
KPAY buy runs with `max-cost = correct-pid × 1.01` and lands the correct split (TX-015b, #11M). #12M
(TX-015c): `URC_Acquire` returns a signable cap list; 1% padding raises the ceilings (cap set differs from
0%); and a buy with `max-cost < live cost` is **rejected on-chain** with "Slippage" (`UEV_SlippageCost`).
Green, 0 load failures.

### UI integration (how the UI must implement it)
1. **Poll** the live cost off-chain: `<sale>.URC_<...>Costs` / `URC_Acquire` at the moment of display.
2. **Variant 1 (default):** let the buyer pick `slippage` (≤ 50). Compute `max-cost = displayed-cost ×
   (1 + slippage/100)`. Call `URC_Acquire buyer … slippage` to get the **padded** `coin.TRANSFER` cap
   strings; put them in the tx's **signature** (scoped caps). Call the Talos buy
   (`KPAY|C_BuyStoicPay` / `SNAKES|C_Acquire` / `CUSTODIANS|C_Acquire` / `SPARK|C_BuySparks`) with
   `max-cost`. If the price moved past tolerance the tx fails safely — re-poll and resubmit.
3. **Variant 2 (slippage off):** call the Talos buy with `max-cost = -1.0`, build the payment via
   `URCI_Acquire` (install-capability — the UI does **not** sign the transfer caps), and **warn** the
   buyer the mined price may differ from the displayed one (asset-seller price change or oracle move
   mid-flight).

**Follow-up (logged, not blocking):** explicit `…WithSlippage`/`…NoSlippage` named Talos wrappers (à la
SWP) are optional sugar — the single `max-cost` value already selects the variant. `URCI_Acquire` rename
per #17L. INFO functions that return the per-leg breakdown for the UI belong to the INFO-pass rehaul (#78).

---

## #13L — STOAICO counter lower bounds → WONTFIX (subsumed by #1C; canonical AQP has no clamp) (2026-08-30)

**File:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/05_STOAICO.pact` (no change).

**Finding.** `XI_UpdateUnclaimedCount` / `XI_UpdateNZS` decrement `(- x 1)` with no `(max 0 …)` floor.
ROUND-01 flagged that under D#1's un-gated collect they could go negative and poison the sweep/reset.

**Disposition (owner 2026-08-30): use the canonical AQP implementation, verified bug-free — no clamp.**
The AQP sibling (`02_SCORE.pact` `WU_Score|NzsCount`) updates its `nzs-count` by a computed delta with
**no floor and no enforce** — it trusts the *guarded delta* (a decrement is only ever reached on a genuine
`nonzero → 0` transition, after a matching increment). Adding a `(max 0 …)` clamp to STOAICO would make it
diverge from that settled pattern. Verified STOAICO already matches it and is free of the negative-counter
bug:
- `nzs-count`: `+1` only when `user-score == 0.0` at stake (`0 → nonzero`); `-1` only when `remaining ==
  0.0` at unstake (`nonzero → 0`). A decrement is always preceded by a matching increment — never negative.
- `unclaimed-count`: reset to `nzs-count` on every inject (`XI_ResetUnclaimedCount` = `UR_Global5` =
  `nzs-count`); decremented once per collect, gated per-round by #1C (`last-collected-round <
  distribution-round`, no double-decrement) and by the flush's uncollected-only walk. Walks `nzs-count →
  0`, never below.

Root cause (D#1's un-gated collect) was removed by #1C; the residual "clamp anyway" is declined to stay
consistent with the canonical AQP counter. No code change.

---

## #14L — STOICPAY fractional team-split → WONTFIX (non-issue; KPAY = 24 decimals) (2026-08-30)

**File:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/04_STOICPAY.pact` (no change).

**Finding (decimals-dependent).** `twenty-p = 0.5·amount` / `ten-p = 0.25·amount` on an integer KPAY count
produce fractions; "if KPAY's DPTF decimals `< 2`, `C_MultiBulkTransfer` rejects → every non-multiple buy
reverts."

**Verified precondition not met.** KPAY has **24** decimals — confirmed both in the fixture (`[5.3]` issues
KPAY with `[24]`) and on the **live chain** via the Pythia dirty-read (`DPTF.UR_Decimals
"STOICPAY-64EvuR4kgZHd"` → `24`). For an integer buy of `N`: `0.5·N` (≤1 dec) and `0.25·N` (≤2 dec) are
exactly representable at 24 decimals, so `C_MultiBulkTransfer` never rejects; team total = `1.5·N`, buyer
= `N`, resident drops `2.5·N` — all exact, zero dust, and `sold = 100M − 0.4·resident` stays exact. The
bug's precondition (`decimals < 2`) can't occur for this token (decimals are fixed at issuance). Adding a
divisibility/floor guard would defend against an impossible condition — declined, consistent with the
"trust the invariant, no unnecessary guards" reasoning applied to #13L. No code change.

---

## #15L — missing `UEV_IMC` → FIXED by reclassification: sale modules are CITIZEN, relocated (2026-08-30)

**Insight (owner 2026-08-30).** The "missing `UEV_IMC`" on Snakes/Custodians `C_Acquire`, STOAICO
`C_Collect`, and the Spark redemptions is **not a missing guard** — it's the audit surfacing a
**mis-classification**. `DEMIPAD` (`00_Demipad.pact`) is the **sovereign** launchpad (the rules); the
per-asset sales (Spark/Snakes/Custodians/StoicPay/StoicIco) are **citizen** modules that wire into those
rules. `UEV_IMC` is the sovereign inter-module gate — citizen client functions correctly don't carry it.
The sovereign **Talos** orchestrator (`TS02-DPAD`) composes those citizen sales and pays their gas; that
is the correct pattern (Talos orchestrating a citizen flow is how a citizen sale becomes gas-payable). The
real defect was **physical filing** — the sales sat under `1_SOVEREIGN/…/2_Core/02_DEMIPAD/`, making them
look sovereign/core.

**Refactor (implemented now, full repo restructure — code unchanged, only file locations + load paths):**
- Renamed `2_SLAVE/` → `2_CITIZEN/` and reorganised into numbered citizen folders: `1_BloodshedMinter/`,
  `2_NosferatuMinter/`, `3_BunniesMinter/`, `4_VaultsMinter/` (AQP-BOOT), `5_OuronetBridge/` (CADUCEUS),
  `6_Launchpad/` (per-asset sales `1_Spark`/`2_Snakes`/`3_Custodians`/`4_StoicPay`/`5_StoicIco` +
  `99_TS02-DPAD.pact` — the sovereign orchestrator, deployed last); `Stage_01/` (AOZ+/DSP+) and `Stage_Z/`
  (DPL-UR/EXPLORER) preserved.
- Moved the 5 launchpad sale modules out of `2_Core/02_DEMIPAD/` (now sovereign `00_Demipad` only) and
  `TS02-DPAD` out of `3_Talos/` into `2_CITIZEN/6_Launchpad/`. `.pact` files reference each other by
  module name (`::` modrefs), so **no Pact code changed** — only ~40 REPL `(load …)` paths + docs
  (CLAUDE.md, README, MODULE-INDEX, CONTEXT, AQP-BOOT links) repointed. Historical Audit round-docs left
  as accurate-when-written.
- Deploy order preserved (TS02-DPAD still loaded from `[3]_Talos.repl`, after the citizen sales in
  `[2.2]_DemiPad.repl`). Full default pipeline (`Z.repl`) boots green — exit 0, **0 load failures**.

**Open sub-decisions (flagged):** STOAICO placed under `6_Launchpad/5_StoicIco/` (staking-ICO alongside
the KPAY sale) — confirm vs a standalone citizen folder. AOZ+/DSP+ and DPL-UR/EXPLORER kept in
`Stage_01/`/`Stage_Z/` (outside the numbered scheme) — rename later if desired. Closes roadmap #88.

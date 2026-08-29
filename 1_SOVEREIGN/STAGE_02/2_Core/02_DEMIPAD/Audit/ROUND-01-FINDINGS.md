# DEMIPAD Audit — Round-01 Findings

6-lens fan-out (auth · arithmetic · economic/MEV · STOAICO-deepdive · custody · StoicSyntax) →
dedupe → adversarial verification. Corroboration count = how many independent lenses found it.
Verification = orchestrator re-read of the actual code. Awaiting owner verdicts.

Legend: **CONFIRMED** = verified against code · **REFUTED** = lens claim disproven · **INTENT** = real
but needs an owner design decision. Severity is the reconciled cross-lens view.

---

## CRITICAL

### D#1 — STOAICO `C_Collect` vault drain (4 lenses · CONFIRMED)
`05_STOAICO.pact` — cap `STOAICO|REDEEM-CONTRIBUTION` 194-206; `URC_ClaimableRewards` 306-312;
`C_Collect` 493-539; `XI_UpdateUnclaimedCount` 546-562.
- **Mechanism:** the redeem cap enforces only `CAP_EnforceAccountOwnership` + `iz-account` (row exists)
  — **no already-claimed flag, no `pending>0` gate.** `C_Collect` pays `URC_ClaimableRewards` then
  **unconditionally** `(XI_UpdateUnclaimedCount false)` (520). And `URC_ClaimableRewards` = when
  `unclaimed-count == 1`, return `UR_Global4` = **the entire remaining `wstoa-supply`**, ignoring the
  account's own entitlement. The `@doc` says "Can only be done once" — nothing enforces it.
- **Exploit:** any account that owns a user row (any past contributor, even 0-score) calls `C_Collect`
  on its own account repeatedly with no inject between. First call pays its real share (sets
  `last-rps=current`, `pending=0`); each further call pays ~0 but still decrements `unclaimed-count`.
  Drive it to 1 → the next call transfers the **whole remaining vault** to the attacker, stranding
  every other contributor and driving `wstoa-supply` negative. Also breaks in honest operation (a
  double-collect desyncs the counter and steals the last-claimant dust branch).
- **Fix:** per-account `collected:bool` set on first collect + enforced in the redeem cap; enforce
  eligibility (`claimable>0`) before decrementing; decrement `unclaimed-count` only on a genuine first
  claim; stop deriving "final claimer gets everything" from a mutable global — settle dust explicitly
  or pay strictly `score*(rps-last_rps)+pending` for everyone.

---

## HIGH

### D#2 — Demipad `retrieval` toggle is dead state (3 lenses · CONFIRMED)
`00_Demipad.pact` — `UR_Retrieval` (685) is read **only** at 343 (inside `TOGGLE-RETRIEVAL`, no-op
detection). The retrieve branch of `C_TransmitTrueFungible` (1094-1097) / OF (1115-1118) /
`X_TransmitCollectables` (1287-1289) is gated by `DEMIPAD|C>RETRIEVE-*` → `REGISTERED-ACCESS`
(390-401) which enforces only owner/admin ownership — never `(UR_Retrieval asset-id)`.
- **Impact:** the `@doc` promises "if `retrieval=false` the only way to retrieve Assets is a buy" — the
  anti-rug lock buyers rely on. It gates nothing: the asset owner/creator can pull deposited (unsold)
  inventory out any time, even mid-sale, defeating the launchpad's custody guarantee.
- **Fix:** enforce `(UR_Retrieval asset-id)` in each `RETRIEVE-*` cap for the non-admin branch (admin
  override if intended).

### D#3 — Custodians `C_Acquire` never opens `CUSTODIANS|ACQUIRE` (2 lenses · CONFIRMED)
`03_Custodians.pact:313` — `C_Acquire` drops straight into `(let …)`; the twin `02_Snakes.pact:284`
wraps its body in `(with-capability (SNAKES|ACQUIRE nonce amount) …)`. `CUSTODIANS|ACQUIRE` (150) has
**zero** `with-capability` sites.
- **Impact:** the cap is the only place the sale guard lives — `(enforce (<= amount available-supply)
  …)` + `compose P|CUSTODIANS|CALLER` + `compose P|CUSTODIANS|REMOTE-GOV`. For Custodian buys all of it
  is skipped: the per-nonce supply cap is not enforced (oversell up to the launchpad's raw nonce
  balance / into reserved supply), the policy caps are never composed (downstream `DPDC-T::C_Transfer`
  loses the intended caller-policy auth), and `@event` never fires. Custodians alone diverges.
- **Fix:** wrap the body in `(with-capability (CUSTODIANS|ACQUIRE nonce amount) …)` + add `(UEV_IMC)`,
  mirroring Snakes.
- Severity note: HIGH if `available-supply < launchpad nonce balance` (real oversell); MED if the
  DPDC-T balance check fully bounds it. Owner to weigh.

### D#4 — Custodians `UR_NonceSaleAvailability` calls a non-existent member (1 lens · CONFIRMED)
`03_Custodians.pact:192` — `(ref-DEMIPAD::GOV|LAUNCHPAD|SC_NAME)`. The module defines only
`GOV|DEMIPAD|SC_NAME` (53 iface / 210 impl); `GOV|LAUNCHPAD|SC_NAME` is defined **nowhere**. Twin
Snakes:174 reads the correct `GOV|DEMIPAD|SC_NAME`.
- **Impact:** modref `::` is dynamic → this is a **runtime "Unbound free variable"** the moment
  `UR_NonceSaleAvailability` executes, i.e. the Custodian sale-availability read is broken. Latent only
  because no test exercises this path (which is why the suite stays green).
- **Fix:** `ref-DEMIPAD::GOV|DEMIPAD|SC_NAME`.

> D#3 + D#4 (+ D#8/D#9 below) ⇒ **Custodians is a half-wired copy of Snakes** — the whole module needs
> a line-by-line reconcile against its working twin.

---

## MEDIUM

### D#5 — STOAICO `A_Inject` divides by `vault-score` with no zero guard (2 lenses · CONFIRMED)
`05_STOAICO.pact:391-394` — `(gained-rps (floor (/ wstoa-amount vault-score) STOA_PREC))`,
`vault-score=UR_Global1=dollarz`, no `enforce >0`. Inject before any stake / after all unstaked
(`dollarz==0`) → div-by-zero abort. Also: if `vault-score ≫ wstoa-amount`, `gained-rps` floors to 0
at 12 dp → wSTOA added to supply but 0 per-share, recoverable only via the (broken) D#1 sweep.
- **Fix:** `enforce (> vault-score 0.0)` (and `nzs-count>0`) before dividing; consider requiring
  `gained-rps>0`.

### D#6 — STOICPAY sale-accounting vs 2× KPAY outflow (1 lens · INTENT/CONFIRMED-math)
`04_STOICPAY.pact:383-393` moves `2×amount` KPAY per buy (`amount` to buyer + `0.5+0.25+0.25=amount`
to COMPANY/VENTURE1/VENTURE2), but `UR_KpayLeft` (226-245) derives `sold = 100M − 0.4·resident`. So
selling `amount` drops `resident` by `2×amount` → `sold` grows `0.8·amount` per `amount` sold; the
per-period cap drifts from real inventory and KPAY depletes ~2× faster than the 100M schedule assumes.
- **Owner-intent:** is the 2× (team vesting alongside each sale) intended, and is the `100M/0.4`
  formula meant to model it? If yes, the `sold`/`left-for-sale` accounting still needs to reflect the
  2× drain (dedicated `sold += amount` counter, or move team allocation out of the sale account).

### D#7 — STOAICO urSTOA double-credit across stake rounds (1 lens · CONFIRMED-plausible)
`05_STOAICO.pact:525` `C_Collect` mints urSTOA (509) then `XI_ResetUrstoaEarned` zeroes `urstoa-earned`
but leaves `score` + `urstoa-left` untouched; `XI_UpdateUrstoaEarned` (682-734) recomputes
`floor(new-score/5) − present` and decrements the global `urstoa-left` by the diff. So after a collect,
a further stake re-derives urSTOA from cumulative score and re-mints already-claimed urSTOA + over-spends
the capped `urstoa-left` budget. E.g. $5→earn1, collect mints1 resets earned→0; $5 more→earn `floor(10/5)=2`,
mints 2 more ⇒ 3 urSTOA minted for $10 that should yield 2.
- **Fix:** track "urSTOA already paid" separately from "entitled by score", or recompute urSTOA purely
  from cumulative score at claim so it isn't double-credited. (Confirm-at-fix with a REPL sequence.)

### D#8 — Demipad NF transmit guarded by the SF cap (1 lens · CONFIRMED-static)
`00_Demipad.pact` `X_TransmitCollectables` (1273-1292) hardcodes `FUEL-SEMI-FUNGIBLE`/
`RETRIEVE-SEMI-FUNGIBLE` for **both** `son` branches; `FUEL-NON-FUNGIBLE`/`RETRIEVE-NON-FUNGIBLE`
(363-366/380-383) are defined but referenced nowhere. SEMI cap enforces stored fungibility `==[false
true]`. ⇒ a real NF asset (`[false false]`) can never fuel/retrieve via `C_TransmitNonFungibles`
(reverts on `UEV_AssetFungibility` → dead feature / stuck asset); an SF asset routed through
`C_TransmitNonFungibles` passes the SF guard but drives `C_Transfer son=false` (type mismatch).
- **Fix:** branch the cap on `son` (NON caps when `son=false`, SEMI when `son=true`).

### D#9 — Demipad `direct-injection` credits withdrawable funds with no tokens in (1 lens · CONFIRMED-static, LATENT)
`00_Demipad.pact` `C_Deposit` — with `direct-injection=true` the inbound transfer `ico3` becomes `EOC`
and the resident update is skipped, but `XI_DepositForAsset` (1261-1271) **always** runs and raises
the per-asset withdrawable `funds-*` by `rem`. The real injection is only a comment (1023-1025). ⇒
`funds-*` > real token balance; a later `C_Withdraw` (1072-1074) drains phantom funds from other
assets' deposits. Gated by the admin `UR_DirectInjection` flag, flagged "not yet available" ⇒ latent,
but live/reachable — flipping the flag on silently corrupts custody accounting.
- **Fix:** don't credit `funds-*` unless tokens actually entered; wire the real injection before
  enabling the flag, or guard the ledger credit behind `(not direct-injection)` + the intended transfer.

### D#10 — Custodians `UC_NonceQuintessence` (declared pure) enforces (1 lens · CONFIRMED)
`03_Custodians.pact:164` — a `UC_` (contractually pure, no enforce) calls `UEV_ConditionalAcquisitionNonce`
→ `UEV_AcquisitionNonce` → `enforce`. Called from `URC_NonceCosts` (227) with `validation=true`, so a
`URC_` transitively enforces. Validation buried in a side-effect-free-looking name.
- **Fix:** make `UC_NonceQuintessence` pure; hoist nonce validation into `CUSTODIANS|ACQUIRE`; or rename `UCv_`.

### D#11 — Custodians `UR_NonceSaleAvailability` enforces; twin Snakes does not (1 lens · CONFIRMED)
`03_Custodians.pact:186-187` — a `UR_` reader calls `UEV_AcquisitionNonce` (enforce); Snakes:169 same-named
reader has no enforce. A read that aborts violates the read-only contract + diverges from the twin (Custodians
aborts on an out-of-range nonce where Snakes returns a figure).
- **Fix:** remove the enforce from the reader; enforce the nonce domain once in `CUSTODIANS|ACQUIRE`.

### D#12 — No on-chain slippage/max-cost bound on any buy (1 lens · INTENT)
All 4 buy paths (Spark 294/387, Snakes 194/281, Custodians 199/313, STOICPAY 271/366) compute cost live
= admin-set price × live oracle PID; the buyer commits only to a token *amount*, no `max-cost`/`max-pid`.
Admin (`A_DefinePrice`/`A_UpdateSharePrice`/`A_UpdateQuintessencePrice`) or an oracle move can front-run a
queued buy → silent overpay (if the signed `coin.TRANSFER` cap is loose) or a griefed failure (if exact).
- **Owner-intent:** on a *permissioned* launchpad the admin is trusted, which tempers this. Decide
  whether off-chain cap-scoping is the accepted model or an on-chain `max-total-cost` guard is wanted.

---

## LOW

### D#13 — STOAICO `unclaimed-count`/`nzs-count` have no lower bound (1 lens · CONFIRMED)
`XI_UpdateUnclaimedCount` 546-562, `XI_UpdateNZS` 646-662 — both `(- x 1)` with no floor. With D#1's
un-gated collect they can go negative, mis-triggering the `unclaimed==1` sweep and poisoning
`XI_ResetUnclaimedCount` on the next inject. **Largely subsumed by the D#1 fix.** Clamp at 0 anyway.

### D#14 — STOICPAY fractional team-split for buys not divisible by 4 (1 lens · CONFIRMED, KPAY-decimals-dependent)
`04_STOICPAY.pact:386-387` — `0.25·amount` / `0.5·amount` on an integer token count produce fractions
(e.g. `0.25*3=0.75`). If KPAY's DPTF decimals `<2`, `C_MultiBulkTransfer` rejects → every non-multiple-of-4
buy reverts. **Fix:** enforce divisibility or floor/ceil the splits to KPAY precision with a deterministic
remainder so the three shares sum to `amount`. (Confirm KPAY's declared decimals.)

### D#15 — Missing `UEV_IMC` on several client entrypoints (2 lenses · CONFIRMED, INTENT)
`02_Snakes.pact:281` + `03_Custodians.pact:313` `C_Acquire`, `05_STOAICO.pact:493` `C_Collect`,
`01_Spark.pact:416/428/440/445` (4 redemptions) go straight to `with-capability` with no `(UEV_IMC)`;
peers `C_BuySparks` (388) / `C_BuyStoicPay` (367) / all Demipad-core `C_`/`A_` open with it. No direct
theft (downstream signatures still protect), but the intended Talos/gas-station boundary is absent and it's
inconsistent. **Owner-intent:** are these paths deliberately non-Talos? If Talos-only intended, add `(UEV_IMC)`.

### D#16 — Demipad `open-for-business` reject message: `format` placeholder, no arg (1 lens · CONFIRMED)
`00_Demipad.pact:442` — `(enforce ofb (format "{} is not open for business, to allow deposits"))` — a
`{}` with an empty arg list raises a format error masking the real message (tx still fails; no state impact).
**Fix:** `(format "{} is not open for business…" [asset-id])`.

### D#17 — Interface omits `URC_Acquire`/`URCI_Acquire`; `URCI_` mis-prefixed (1 lens · REFUTED-as-blocker → LOW convention)
`00_Demipad.pact:768/799` define `URC_Acquire`/`URCI_Acquire`; the `DemiourgosLaunchpadV1` interface
declares only `URC_Prices`. **The lens claimed the undeclared modref calls "don't resolve" — REFUTED:**
`::` dispatch is dynamic (our settled modref finding) and the suite loads these calls green. Residual is
convention only: (a) declare them in the interface for the enumeration/drift-catch convention (free
pre-redeploy); (b) `URCI_` is not a registered prefix and the function does `install-capability` (a state
effect) under a read/compute-looking name → **rename** to reflect the cap-install.

---

## Cleared by the lenses (checked, no finding)
Spark bonding curves (`URC_SparkCost`/`URC_GetMaxBuy`/`XI_RedeemSparks`), Snakes/Custodians cost chains
(`URC_NonceCosts`/`URC_NonceAmountCosts`, floor-at-precision favoring protocol), Demipad royalty math,
`URC_AvailableRewards` `diff-rps ≥ 0` (rps monotonic, last-rps snapshotted); STOAICO settle-before-score
ordering in `A_Stake`/`A_Unstake` + `last-rps` snapshot-after (a late staker can't claim pre-stake injects);
`A_Unstake` over-unstake blocked by `REMOVE-CONTRIBUTION` cap; `open-for-business` enforced on every buy via
`DEMIPAD|C>DEPOSIT`; STOICPAY `UR_KpayLeft` is a cumulative-schedule release (no per-period reset gaming);
Spark redemption over-refund + `custom-kda-pid` are `DPTF::CAP_Owner` (admin) gated.

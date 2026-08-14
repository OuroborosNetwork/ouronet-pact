# Tautological validation checks — an audit smell to hunt for — 2026-08-14

**Found in:** `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/03_AQP.pact` `URC_OrtoStakeWholeNonceAmounts` (audit L1 / fix #16).
**Deleted** — it validated a condition that is **structurally always true**.

## The concrete case

`URC_OrtoStakeWholeNonceAmounts` asserted "each `nonce-amount` equals the full DPOF nonce supply
(`UR_NonceSupply`)". But:
- The OF token transfer, `DPOF::C_Transfer dpof-id nonces sender receiver true`, takes **`nonces` only** — it
  moves the WHOLE nonce and **ignores any amount**. Whole-nonce is a token-layer invariant, not something a cap
  can loosen.
- Every caller sources `nonce-amounts` from `UR_NoncesSupplies(dpof-id, nonces)` — the same supply the check then
  compares against.

So the check was `UR_NonceSupply(n) == UR_NonceSupply(n)` — **it can never fail in any real path.** Pure ceremony
(and it lived in a `URC_`, which per StoicSyntax must not `enforce`). Removed the helper + its `whole-nonce-ok`
term from both caps (`AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY`, `FVT|C>ORTO-FUNGIBLE-STAKE-FLOW`). Gates unchanged
(golden 33/0, Z 241/0, comprehensive 260/0) — literally nothing depended on it because it always passed.

## The general pattern (a tautology smell)

A validation is **tautological** when the thing it checks is already guaranteed upstream, so the check can never
be false. Recurring shapes to grep for during the audit:

1. **Value checked against its own source.** `x` is derived from `f(k)`, then a guard asserts `x == f(k)` (or
   `x <= f(k)`, etc.). The M6/#15 promile conformance is the *legit* opposite — it checks a *caller-supplied*
   value; the smell is when the value was *derived by us* from the very thing we compare it to.
2. **Re-checking a structural token-layer invariant.** A cap asserts a property that the underlying
   fungible/collectable transfer already enforces by construction (whole-nonce moves, supply=1 NFTs, amount>0 via
   `UEV_Amount`). If the transfer can't produce the bad state, the cap check is dead.
3. **Duplicated caller guard.** A helper `enforce`s something every caller already `enforce`s first (the original
   L1 sub-finding: the length check was also redundant with both callers' `(= l-n l-a)`).
4. **`enforce` inside a `UC_`/`URC_`/`UR_`.** By the prefix contract these are enforce-free; an `enforce` there is
   often a validation that either belongs in a `UEV_`/defcap *or* is redundant/tautological. Worth auditing each.

## How to hunt for more

- `grep -nE "defun U(R|RC|C)_" then scan each body for `enforce` — prefix-contract violations are the entry point.
- For each such check, ask: **"can the argument ever differ from what I'm comparing it to?"** Trace where the
  argument is *sourced*. If it's derived from the same reader/table, it's a tautology.
- Cross-check token-layer guarantees: before adding/keeping a cap check on amounts/nonces/supply, confirm the
  DPTF/DPOF/DPDC transfer doesn't already make the bad state unreachable.

Deleting a tautological check is safe *iff* the structural invariant that makes it always-true is real and
documented (here: DPOF whole-nonce transfer + caller-sourced supplies). Note that invariant in a comment where the
check used to be, so a future reader doesn't "restore" the guard.

## The mirror-image smell: flooring a value that is *legitimately* negative (audit L7 / fix #19)

The opposite mistake: adding a `max(0, x)` clamp to an accumulator whose negatives are **valid by design**.

- **L6 (ANK promile), fix #18 — floor was CORRECT.** promile = `conform-nonces × ank-promile`, with
  `ank-promile ∈ [1,10000]` and `conform-nonces` a count `≥ 0` ⇒ promile is structurally `≥ 0`. A negative can only
  be a bug (asymmetric-def), so the floor never touches a valid value.
- **L7 (SCORE user base), fix #19 — floor was WRONG.** base = `Σ trait-score-values`, and **trait scores can be
  negative** (a trait that *reduces* weight). So a negative base is legitimate — staking a −1-trait NFT sets base to
  −1, unstaking restores 0. Flooring the intermediate corrupted the round-trip and broke a live vacate test.

**Rule:** before adding a non-negativity clamp/floor, prove the value has a real `≥ 0` lower bound from its *inputs*
(bounded positive factors × non-negative counts). If any input can legitimately be negative (signed weights, signed
deltas that net across steps, trait scores), the "negative" is not corruption and the floor will silently destroy
valid data. Test it: a floor that changes any green test's outcome is flooring a value the system relied on.
Reachability of a bad *negative* (L6) and legitimacy of a *negative value* (L7) are different questions — answer both.

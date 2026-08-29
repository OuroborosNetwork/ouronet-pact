# UrStoa account creation is UI-constructed, not a standalone Pact function (#13H)

**Date:** 2026-08-27
**Context:** DALOS audit, finding #13H (LIQUID `C_RegisterOuronetAccountForUrstoaHoldings`).

## The fact

Wrapping/unwrapping UrStoa (and, before it, native Stoa) requires the caller's attached Kadena
`k:`/`c:` address to already exist in the relevant fungible's account ledger. If it doesn't (e.g. a
StoaICO contributor who only ever held wrapped UrStoa and never touched native UrStoa before), the
account must be created with the *correct* guard — the real owner's own keyset — before the
wrap/unwrap call.

This is **not** done via a standalone on-chain Pact function. It's done by the UI constructing a
bespoke transaction that:
1. Calls `IGNIS.C_Collect <patron> (IGNIS.UDC_CustomCodeCumulator)` to bill gas for the custom code.
2. Reads the target account's attached Kadena address via `DALOS.UR_AccountKadena`.
3. Conditionally calls `coin.C_CreateAccount`/`coin.C_UR|CreateAccount` with `(read-keyset "ks")` —
   the real signer's own keyset, submitted directly in that transaction's payload — only if the
   target address doesn't already exist in the destination ledger.
4. Then calls the real wrap/unwrap client function (`TS01-C2.LQD|C_UnwrapStoa`/`LQD|C_UnwrapUrStoa`/etc.).

Example (native Stoa unwrap, captured verbatim from a real explorer transaction):

```pact
(namespace "ouronet-ns")
(IGNIS.C_Collect "<patron>" (IGNIS.UDC_CustomCodeCumulator))
(let
  (
    (wp:string "<unwrapper>")
    (target:string (DALOS.UR_AccountKadena wp))
  )
  [
    (coin.C_CreateAccount target (read-keyset "ks"))
    (TS01-C2.LQD|C_UnwrapStoa "<patron>" "<unwrapper>" "<unwrapper>" <amount>)
  ]
)
```

The UrStoa variant is identical except it calls `coin.C_UR|CreateAccount` (the `ur-stoic-fungible-v1`
implementation's create-account entrypoint) instead of `coin.C_CreateAccount`, and
`TS01-C2.LQD|C_UnwrapUrStoa` instead of `LQD|C_UnwrapStoa`.

## Why this matters (the #13H fix)

`LIQUID::C_RegisterOuronetAccountForUrstoaHoldings` (and its Talos wrapper
`TS01-C2.LQD|C_RegisterOuronetAccountForUrstoaHoldings`) used to exist as an on-chain equivalent —
but it took the `guard` as a caller-supplied argument with **no ownership check at all** (just
`UEV_IMC`), so any signer could register *someone else's* Kadena address in the UrStoa ledger under
a guard the attacker controls — a real account-hijacking risk (this was audit finding #13H/H8).

Since the UI-constructed pattern above already solves the same problem correctly (the account is
always created with the *real* signer's own `read-keyset "ks"`, tied directly to that transaction —
no third party can forge it), the standalone Pact function was redundant *and* the less-safe of the
two mechanisms. It was removed outright (`12_LIQUID.pact`, `03_TS01-C2.pact` — interface + module,
both files) rather than patched, and `C_UnwrapUrStoa`/`C_WrapUrStoa`/`LQD|C_UnwrapUrStoa`/
`LQD|C_WrapUrStoa`'s `@doc` strings were updated to point at this UI-constructed pattern instead of
the removed function. `LIQUID.UR_IzOuronetAccountRegisteredForUrstoaHoldings` (a pure read-only
checker, no risk) was kept — the UI uses it to decide whether the create-account step is needed at
all, mirroring "detected if your target address ever had stoa, and if not is created on the spot."

## General lesson

When a finding's fix direction is "remove this function," always check whether a UI-constructed /
off-chain-assembled transaction pattern already covers the same need more safely, the way it does
here — removing dead-weight *and* closing a security gap in one move, rather than just patching the
on-chain function in place. Also: zero REPL coverage of a function isn't always a coverage gap to
backfill — it can be a signal the function was never meant to be exercised standalone in the first
place (same shape as the `INFO_*` UI-preview functions, see the 2026-08-24 memory on that).

# State-driven guard coverage: `env-module-admin` + `rollback-tx`

**Date:** 2026-09-12 · **Status:** technique, in use · **First uses:** `modules/LIQUID.repl <<LQD-G1>>`
(3 guards), `modules/DPTF.repl <<DPTF-G6>>` (2 guards + 2 entrypoints that had never executed)

## The problem it solves

The largest single category of "unpinnable guard" in this suite is not a hard guard — it is a guard
whose input **no legitimate flow in the suite produces**:

- a token that belongs to **two** ATS pairs (`LIQUID::UEV_IzLiquidStakingLive`, two guards)
- two fields that every writer keeps in sync (`UEV_IzLiquidStakingLive`'s "same pair" guard)
- a treasury whose OURO balance is **negative** (`GOV|SET_TREASURY-DISPO`,
  `GOV|WIPE_PARTIAL-TREASURY-DEBT`)

I had written all five off, in writing, as needing fixtures nothing builds. Wrong — not about the
fixtures, about my options for building them.

## The pattern

```pact
(begin-tx "X — …")
(env-sigs [ … ])
(env-module-admin DALOS)              ;; REPL-only: grants another module's admin
(update DALOS.DALOS|AccountTable key  ;; drive the state directly
    { "ouroboros" : (+ { "balance" : -1000000.0 } (DALOS.UR_TrueFungible key true)) })
… assertions: the refusal, AND a contrast that passes in the same state …
(rollback-tx)                          ;; NOT commit-tx

(begin-tx "Xb — the fixture left no trace")
… assert every field written above is back to its original value …
(commit-tx)
```

Four things make it safe and worth doing:

1. **`env-module-admin <MOD>`** grants the module admin that `keys`/`update` on another module's
   table demands. It takes the module name unqualified (`(env-module-admin DALOS)`).
2. **Partial-row update via object merge.** `(+ { "field" : v } existing-object)` is left-biased, so
   read the row with its own `UR_` reader and overlay only the field you are changing. Avoids
   reconstructing a schema you do not own.
3. **`rollback-tx`, never `commit-tx`.** Every write is discarded, including ones the code under test
   made (`A_WipeTreasuryDebt` mints OURO *and* resets the dispo parameters — both vanish).
4. **A separate no-leakage transaction.** Not optional. A `commit-tx` typo would leave a sovereign
   table claiming 1,000,000 OURO of phantom supply, or a fabricated ATS pair, and **every downstream
   check would silently agree with it**. The assertion costs two lines.

## Always pair the refusal with a contrast that PASSES in the same state

`DPTF-G6` asserts a type-3 dispo of 1.0 is refused against a 1,000,000 debt **and** that a type-1
dispo (ceiling = whole OURO supply) is accepted in the identical state. Without the second, the first
would also pass if the guard rejected everything — which is the failure mode a fabricated fixture is
most likely to produce, because you have just put the chain in a state no code expects.

## The boundary that must stay in the comment

This grants in a REPL what **no signer could grant on chain**. It is valid for pinning a guard's
**reaction to a state** and says **nothing** about whether the state is reachable in production.
Those are two different claims, and conflating them is exactly what produced two withdrawn findings
in this suite on 2026-09-11 (see `2026-09-12-repl-mode-is-not-production-mode.md`). Every test using
this pattern says so in its own comment block.

## Signers are a separate obstacle, and look like a defect when they are not

`A_WipeTreasuryDebt` mints to the treasury, a SMART account, so `DALOS::UEV_SmartAccOwn` runs. Its
`enforce-one` accepts the account guard, the **sovereign's** guard, or the governor. The treasury's
sovereign is guarded by `ouronet-ns.dh_sc_dhvault-keyset` = **`PK_DHV`**. Without that signer the
wipe dies with *"Ownership could not be verified!"* inside the mint, **before reaching any of its own
guards** — which reads exactly like "this admin entrypoint is broken". It is not; it needs the vault
signer. Look up the smart account's sovereign guard before concluding anything.

## Candidates left

Anything in the worklist whose blocker is phrased "no suite creates this state" rather than "needs a
different argument". `python3 _enforce_coverage.py --list` and read the reasons.

---

# THE DERIVED-ARGUMENT FAMILY (2026-09-13) — when a guard checks something the caller cannot set

Four `02_SCORE` guards looked like ordinary argument-domain checks and none of them is. In each, the
value the guard validates is **not a client argument** — the Talos wrapper derives it — so whether the
guard is reachable depends entirely on WHAT IT IS DERIVED FROM.

| site | client derives from | reachable? |
|---|---|---|
| `:1282` DPNF stake amount > 0 | `UR_AccountNoncesSupplies` (**per-account**) | zero IS constructible — but `DPDC::UEV_NonceQuantityInclusion` checks the NFT's holder identity upstream, which for an NFT is the same fact. **Shadowed.** |
| `:1110` orto LP whole-supply | `UR_NoncesSupplies` (**total**, folds the very reader the guard compares against) | **tautology** — `(= (UR_NonceSupply d n) (UR_NonceSupply d n))` |
| `:995`, `:1021` aqpool link slot | n/a | **shadowed** by `UEV_AddScorePoolAndScore` in the caller's cap |

**ONE WORD IN A READER NAME IS THE WHOLE DIFFERENCE.** `UR_AccountNoncesSupplies` vs
`UR_NoncesSupplies` — per-account vs total — decides whether `:1282` and `:1110` are live guards or
dead ones, and the two enforces look identical at the site. Read the client's derivation before
deciding a guard is argument-domain; the defcap signature is not enough.

**And check by RUNNING.** `:1282` was expected to be reachable and is not: re-staking a just-staked
nonce returned DPDC's `"doesnt hold NFT …"`, never SCORE's message. The measurement is what separated
"shadowed" from "live".

**Every one of these annotations is backed by an assertion**, not just prose — `TX-AQP-NF01` pins the
shadowing, `TX-INFO-GT` pins the tautology. An `;;UNREACHABLE` note is a claim about today's code; if
a client is ever changed to derive from a different reader, the test goes red and the annotation is
re-opened automatically.

## The derived-argument family, extended: `07_DPDC-T:347` (2026-09-13)

Fifth member, and the first whose unreachability comes from a **filter** rather than a reader choice.
`IGNIS|C>ROYALTY`'s `(enforce (> ta 0.0) ...)` cannot fire because its only acquirer,
`C_IgnisRoyaltyCollector`, passes through two gates first:

1. `(if (or ivgz (= sum 0.0)) <NO-ROYALTY branch> ...)` — a zero TOTAL never acquires the cap;
2. `UC_CleanseAggregatedRoyalties` drops every creator whose royalty is `0.0`, so the per-creator
   amounts handed to the cap are non-zero by construction.

**The proof is PURE COMPUTE**, which makes this the cheapest kind of unreachability pin in the
campaign: `UC_CleanseAggregatedRoyalties` is a `UC_` over a constructed object, so `DPDC-G16` drives
it with `["a" "b" "c"] [1.5 0.0 2.5]` and asserts the zero is dropped — no collection, no signer, no
fixture. It also drives an already-clean aggregate to show the cleanse is a FILTER and not a rewrite;
without that, "the zero is gone" is equally consistent with it mangling every input.

**Look for a pure-compute proof before building a fixture.** When a guard is unreachable because of a
filter or a derivation, the thing worth asserting is usually the filter itself — and that is almost
always callable directly.

## Sixth member: `02_IGNIS:1007` — a SANITISING CONSTRUCTOR (2026-09-13)

The interactor rule (BAR or a Σ smart account) reads like a real protection — an interactor is a fee
DESTINATION, so a standard user account there would route protocol fees to a person. It cannot fire.

`interactor` is not a client argument, and the only thing that builds one **normalises it**:

```pact
(interactor (if (DALOS::UR_AccountType active-account) active-account BAR))
```

Smart accounts pass through; **everything else becomes BAR**. The two outcomes are exactly the two
branches the `enforce-one` accepts. A triggered (free) leg is BAR regardless.

**HOW IT WAS FOUND, and the lesson: a hand-built input does not bypass a constructor that sanitises.**
`IGNIS::C_Collect` carries no `P|UEV_IMC` and `UDC_ConstructOutputCumulator` is public, so it looked
like the guard could simply be driven by handing in a cumulator naming a standard account. That call
**succeeded** — the constructor had already rewritten the field on the way in. Two rounds were then
spent raising the leg price on the theory that the elite discount was zeroing it, before reading the
constructor. **Read the builder before trying to feed a derived value.**

Proof is pure compute (`UDC_MakeModularCumulator` is a public `UDC_`), so `CUM-G1` asserts the
normalisation in both directions plus the trigger branch — no fixture, and it goes red if the
normalisation is ever weakened.

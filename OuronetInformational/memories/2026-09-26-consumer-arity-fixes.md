# Consumer fixes — the builders the sweep re-signed  (2026-09-26)

Found by checking every consumer pact call against `Deploy/OURONET-REGISTRY.json`. That is the
registry earning its keep: the truth came from the DEPLOYED module, not from the files being
checked.

## The headline: OuronetUI did not compile

Not a subtle runtime bug. `npx tsc -p tsconfig.app.json` reported **five TS2353 errors**, all of
the same shape:

```
ChangeOwnershipCFMModal.tsx(225,9): 'executor' does not exist in type
    '{ patron: string; swpair: string; newOwner: string; }'
```

The patron/executor sweep re-signed six entrypoints. **The modals were updated to pass `executor`
and the builders were never updated** — one of the modals even carries the explanatory comment
(*"the pool owner acting, not the patron paying. Two different roles that were one argument."*).
So the call sites were right, the builders were stale, and the build was red.

### Why my first typecheck said it was fine

`npx tsc --noEmit -p tsconfig.json` exited **0 with no output**, and I nearly believed it. The
root `tsconfig.json` is a project-references stub — `"files": []` with references to
`tsconfig.app.json`. It checks NOTHING. `--listFiles` showed zero of the app's own sources in the
program. **A green typecheck against a references stub is not a typecheck**; the real one is
`-p tsconfig.app.json` (or `tsc -b`).

## Fixed — six builders, against the registry's signatures

| entrypoint | was | now |
|---|---|---|
| `SWP\|C_ChangeOwnership` | `(patron, swpair, newOwner)` | `(patron, executor, executee, swpair)` |
| `SWP\|C_ModifyWeights` | `(patron, swpair, weights)` | `(patron, executor, swpair, weights)` |
| `SWP\|C_ToggleSwapCapability` | `(patron, swpair, toggle)` | `(patron, executor, swpair, toggle)` |
| `SWP\|C_ToggleAddLiquidity` | `(patron, swpair, toggle)` | `(patron, executor, swpair, toggle)` |
| `SWP\|C_ModifyCanChangeOwner` | `(patron, swpair, bool)` | `(patron, executor, swpair, bool)` |
| `CODEX\|C_ReleaseStoicTag` | `(patron, tagName)` | `(patron, executor, tagName)` |

`C_ChangeOwnership` is not just an insertion — the ENTITY moved to last, and `newOwner` is the
canon's `executee`. Order came from the registry, never from the doc comments (which still
described the old shape).

## The tests were pinning the bug

Seven `cfm-builders.test.ts` cases asserted *"the canonical 3-arg shape"*. They compared the
builder against ITSELF, never against the chain, so they stayed green while the contract
disagreed and the UI would not compile. Updated, plus 12 more call sites inside the same file
that the first regex missed (it matched `patron: PATRON` and not `patron: "p"`).

The order guard was the worst of them:

```ts
// Argument ORDER guard — patron → swpair → new-owner.
```

An explicit assertion that the wrong order was right.

## An accept-list that had started agreeing with the bug

`scripts/check-builder-arity.py` carries an `ACCEPTED` map of known-wrong builders. One entry:

> `CODEX|C_ReleaseStoicTag`: "missing executor. **No live call site in this app** -- changelog
> only -- so a corrected builder would have no caller to supply the account from."

It has **ten** call sites. The excuse came from a grep that missed them, and once written it made
the checker agree with the bug for as long as it stood. The entry is gone — and the checker
reported it STALE the moment my fix made it match, which is the property that makes an
accept-list survivable.

## Also fixed (pre-existing, blocking the build)

- `src/kadena/cfmBuilders.ts` imported `@ouronet/ouronet-core/pact/cfmBuilders`; the package
  exports `./pact`, not that subpath.
- `swp-pairs-proto.tsx:5331` referenced `activeOuroWallet` / `ouroAccounts`, neither in scope —
  **my own `MyLiquidityPositions` wiring from an earlier session**, never typechecked because of
  the stub config above. The component already computes `mgmtAddress` for exactly this.
- Two unused type declarations (`Tier1`/`Tier2` in `PantheonHeader.tsx`).

## Verified

- `ouronet-core`: **848 tests / 55 files pass, no type errors**, build clean
- `OuronetUI`: **tsc 0 errors**, **280 tests / 35 files pass**
- Diffed the typecheck before and after: **5 errors fixed, 0 introduced**

The UI resolves `@ouronet/ouronet-core` as a PUBLISHED `4.6.0`, not a workspace link, so the
rebuilt `dist/` was copied into `daimons/OuronetUI/node_modules/` for local testing.
**A real fix needs a version bump and a publish** — the local copy is wiped by `npm install`.

## NOT fixed — each needs a decision, not a rename

1. **`sparkBuy.ts`** — two arity gaps: `DEMIPAD.URC_Acquire` wants `slippage` (5th) and
   `SPARK|C_BuySparks` wants `max-cost` (5th). Both need a **UI slippage policy** first; the
   contract doc says the UI sets `max-cost = displayed-cost x (1 + slippage/100)`, slippage <= 50.
   Measured on mainnet: the current 4-arg read returns *"Evaluation did not reduce to a value"* —
   it partially applies to a CLOSURE rather than erroring, so caps come back null and the buy
   cannot be funded.
2. **`kpayFunctions.ts`** — worse than stale names. `DEMIPAD-KPAY` **does not exist on chain**
   (it is `DEMIPAD-STOICPAY`), `TS02-DPAD.KPAY|C_BuyKpay` is now
   `TS02-CPAD.KPAY|C_BuyStoicPay` with 5 params, and **`UR_Kpay` has no replacement at all** —
   the live module exposes only `UR_KpayID` / `UR_KpayLeft` / `UR_KpayPID` (all zero-arg) and
   `URC_GetMaxBuy(account, native)`. There is no per-account data object, so `getKpayData` cannot
   be renamed into correctness; the page's shape has to be decided, or an AppReads reader written
   the way the `O-UI-*` modules were. `KPaySale.tsx` is live, so this page is broken today.
3. **SmartSwap** — `SWP|C_SmartSwapNoSlippage` / `WithSlippage` are missing `bundle`, and the two
   `*SwapWithSlippage` builders are missing `slippage-bounds`. Both belong to the Smart Swap
   dirty-read harness, which does not exist yet. Already carried in `ACCEPTED` with that reason.

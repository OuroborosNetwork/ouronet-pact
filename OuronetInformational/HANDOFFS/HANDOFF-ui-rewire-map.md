# HANDOFF — the UI rewire, page by page

Companion to `HANDOFF-read-layer-split.md`. That one says how the Pact side is shaped; this one
says what has to change in `daimons/OuronetUI` and in what order.

Measured 2026-09-24 against OuronetUI `0094889` (v2.14.0) and `@ouronet/ouronet-core@4.6.0`.

## The single most important fact before starting

**Almost nothing is fixed in the UI repo.** Exactly ONE inline Talos Pact string exists in
`OuronetUI/src` — `src/kadena/sparkBuy.ts:155`. Every other chain call is emitted by
**`@ouronet/ouronet-core`**, source at `_libs/ouronet-libs/packages/ouronet-core/src/`, mostly
`pact/cfmBuilders.ts` and `interactions/*.ts`.

So the work is a **library change plus a version bump**, and the UI repo mostly follows. Planning
it as "edit the React pages" will produce a lot of searching and very few edits.

## Reads: 26 called from UI source, ~16 more only via the package

Target modules are from `READS_UI/README.md`.

| UI surface | files | reads today | → module |
|---|---|---|---|
| Dashboard header | `hooks/useDashboardHeader.ts`, `components/dashboard/DashboardInfoHeader.tsx`, core `ouroAccountFunctions.js` | `0001_HeaderV3` | **RD-HEADER** ✅ built |
| Dashboard body | `routes/logged-in/dashboard.tsx`, core `ouroPrimordialsFunctions.js` | `0002_Primordials` | RD-WALLET |
| Pools list | `hooks/usePoolsPagination.ts` | `0003`, `0005` | RD-POOLS |
| Pool detail / mgmt | `routes/logged-in/swp-pairs-proto.tsx` (6 sites) | `0005`, `0010`, `0014`, `0015` | RD-POOLS |
| Pool LP rows | `swp-pairs-proto.tsx:2298-2299` | `0008b_TrueFungibleLPEntry` | RD-TF |
| Swap | `components/pools/SmartSwapWidget.tsx`, core `dexSwapPairSmartSwapFunctions.ts` | `0006b`, `0007b` (via package) | RD-SWAP |
| True fungibles | `routes/.../trueFungibles.tsx`, core | `0008a*`, `0016`, `0017` | RD-TF |
| Orto fungibles | `routes/.../ortoFungibles.tsx` (5 sites) | `0009a*`, `0009b*`, `0018`, `0019`, `0020` | RD-OF |
| Collectables | `routes/.../collectables.tsx` (7 sites), `hooks/useCollectableNonceData.ts` | `0021`, `0022a*`, `0023`, `0024`, `0026` | RD-COLLECT |
| Account selectors | `hooks/useAccountSelectorData.ts`, `useStoaAccountSelectorData.ts`, `useAccountOverview.ts` | `0027`, `0028`, `0029` | RD-ACCOUNTS |
| Elite panel | `hooks/useEliteAccount.ts`, `useEliteRichList.ts` | `0032`, `0035` | RD-ELITE |
| Recovery | `components/UncoilAurynCFMModal.tsx`, `components/settings/RecoveryPrototype.tsx` | `0012` | RD-ELITE |
| Launchpad | `hooks/useOuroInvestment.ts`, `useIcoContract.ts`, `components/launchpad/*` | `0013`, `0030` | RD-LAUNCH |
| Pythia | core `interactions/*` | `0031`, `0033`, `0034` | RD-PYTHIA |

### Reads that break the moment DPL-UR is replaced

Seven functions were renamed by the StoicSyntax sweep. **The UI calls exactly one of them:**

- `URC_0008b_TrueFungibleLPEntry` → **`URCv_`**, at `swp-pairs-proto.tsx:2298` and `:2299`.
  The second is wrapped in `(try false …)`, so after the rename it fails **silently** — the
  frozen-LP row simply renders as absent. That is the worse of the two.

The other six (`URC_0009b_OrtoFungibleLPEntry` → `URCv_`, `UCX_` → `UCx_`,
`URC_KadenaCollectionReceivers` → `URC_Stoa…`, `URC_SplitKdaPriceForReceivers` → `URC_SplitStoa…`,
`GOV|NS_Use` → `CT_Namespace`, and `UC_LpFuelToLpStrings`, deleted outright) have **no caller**.

### Reads the package calls that exist nowhere

Already broken before any of this, so not a regression — but they are dead paths to delete
rather than port: `URC_0006_Swap`, `URC_0007_InverseSwap`, `URC_0008_CappedInverse`,
`URC_0012_HibernateFee`, `URC_0011_RecoveryPrimordial`, and `MB.C_MovieBoosterBuyer` (no `.pact`
in the tree defines that module).

## Writes: 13 broken Talos paths

35 of 48 entrypoints still match. These do not. All fixes land in
`_libs/ouronet-libs/packages/ouronet-core/src/`.

**Rejected on arity — the transaction will not execute:**

| function | UI passes | contract wants |
|---|---|---|
| `SWP\|C_ChangeOwnership` | `patron, swpair, newOwner` | `patron, executor, executee, swpair` |
| `SWP\|C_ModifyWeights` | `patron, swpair, weights` | `patron, executor, swpair, weights` |
| `SWP\|C_ToggleSwapCapability` | 3 args | 4 — `executor` at 2 |
| `SWP\|C_ToggleAddLiquidity` | 3 args | 4 |
| `SWP\|C_ModifyCanChangeOwner` | 3 args | 4 |
| `SWP\|C_SmartSwapWithSlippage` | 6 args | 7 — new `bundle` |
| `SWP\|C_SmartSwapNoSlippage` | 5 args | 6 — new `bundle` |
| `CODEX\|C_ReleaseStoicTag` | 2 args | 3 *(no UI caller yet)* |
| `SPARK\|C_BuySparks` | 4 args | 5 — new `max-cost`, **and the module moved** |

**Silently misbound — arity is right, order is wrong, every slot is a `:string` so it
type-checks:**

- **`DPTF|C_Transfer`** — UI sends `(patron tokenId sender receiver amount method)`; the contract
  wants `(patron executor executee id transfer-amount method)`. **10 call sites**, every transfer
  modal in the app. `cfmBuilders.ts:56`.
- **`CODEX|C_RegisterStoicTag`** — args 2 and 3 transposed. `cfmBuilders.ts:1000`.

**Gone or moved:**

- `DALOS|C_RotateKadena` → `DALOS|C_RotateStoa` (rename only, same arity, no UI caller)
- `KPAY|C_BuyKpay` → `TS02-**C**PAD.KPAY|C_BuyStoicPay` — renamed **and** module moved **and**
  gained `max-cost`
- `SPARK|C_BuySparks` → still that name, relocated `TS02-DPAD` → `TS02-**C**PAD`

### The one decision that is not mechanical

`SWP|C_SmartSwap{With,No}Slippage` has **two valid repairs**, and the owner should pick:

- rename the builder `C_` → **`CC_`** — `TS01-C3` kept `CC_SmartSwap*` with *exactly* the shape
  the UI already emits, deliberately, "for direct gas comparison"; or
- add the new `bundle:object{SwapperUsageV3.SmartSwapPathBundle}` argument to the `C_` call.

These are different operations, not two spellings of one. Owner-ruled, then built.

Related, and flagged by the owner: **smart swap is now driven by a dirty read** — the path bundle
is computed off-chain and fed in. That is the custom wiring the `bundle` argument exists for, and
it is why this is not a one-line arity fix.

## Why none of this was caught

OuronetUI **has** a drift guard — `src/__tests__/inventory-drift-guard.test.ts` against
`src/constants/functionInventory.generated.ts`. It validates the
`functionName="ouronet-ns.MODULE.CAT|Fn"` **annotation strings** and never inspects argument
lists. So all 13 passed.

It is the name half of what `_callarity.py` does on the Pact side, without the argument half —
and `_callarity.py` exists precisely because names matching proves nothing about arguments.
**Extending that guard to argument lists is the single highest-value thing in this document**,
because it is the only item that stops the next sweep doing this again.

## Suggested order

1. **Argument-list drift guard** in OuronetUI — so every later step is verified rather than hoped.
2. **`DPTF|C_Transfer`** — 10 sites, silent misbinding, every transfer in the app.
3. The eight remaining **arity** fixes; mechanical once the guard exists.
4. **`SmartSwap`** — after the owner's ruling, with the dirty-read bundle wiring.
5. **`KPAY` / `SPARK`** module relocations to `TS02-CPAD`.
6. **`URCv_0008b`** rename — must ship in lockstep with whichever round replaces DPL-UR.
7. Reads, page by page, as each `RD-*` module lands.

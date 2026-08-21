# SWP SmartSwap bundle architecture — the dirty-read-injected path (#34, Phase 9)

**Status:** Phase 8 (core build) done and committed. This doc is the **finished-mechanism
write-up** (P5.5) plus the **client/UI orchestration guide** (P3.7/P5.6), now that the real
functions exist to describe accurately — not the speculative design. For the full exploratory
history (why this was built, the gas-ceiling crisis that forced it, every dead end and design
decision along the way), see
[`HANDOFF-swp-exhaustive-path-search.md`](HANDOFF-swp-exhaustive-path-search.md). This doc
assumes that context and gives the short, accurate version for someone integrating against the
finished mechanism.

## 1. What this is, in one paragraph

`SWP::CC_SmartSwap` (the original multi-hop swap entrypoint) searches for its own route,
Liquid Boost pricing path, and every touched pool's stoa-value pricing path **on-chain, inside
the paid transaction** — three separate graph searches. At realistic scale (~100 active pools)
this costs **7,145,298 gas**, over 3.5x the real Stoa gas ceiling (~2,000,000). `SWP::C_SmartSwap`
(new) does **zero on-chain searching**: the caller supplies a pre-discovered `SmartSwapPathBundle`
(the route, the boost path, and the pricing paths), all found via free off-chain dirty reads
before the transaction is ever submitted. The real transaction cheaply **validates** the supplied
paths (one connectivity+active check per path, not a search) and executes. Measured on the
identical worst-case swap, same topology: **397,043 gas — an 18x reduction**, safely under the
ceiling.

`CC_SmartSwap` is kept, unchanged, as the self-searching fallback/comparison baseline — the two
coexist (§7).

## 2. The two-transaction shape and why it's safe

```
 OFF-CHAIN (free)                          ON-CHAIN (paid, real tx)
┌─────────────────────────┐               ┌──────────────────────────────┐
│ 1. Dirty-read the route  │               │ SWP|C_SmartSwapWithSlippage / │
│    A->B (URC_HopperActive)│  bundle:      │ NoSlippage (Talos)            │
│ 2. Dirty-read/cache-check │  Smart       │  -> SWPU::C_SmartSwap         │
│    boost-path B->DLK      │  Swap        │     -> validates bundle       │
│ 3. Dirty-read/cache-check │  Path        │        (cheap: one connect-   │
│    stoa-paths, per pool   │  Bundle ───► │        ivity+active check)    │
│    first-token->DWK       │              │     -> executes for real      │
│ 4. Submit                 │               │     -> prices from bundle     │
└─────────────────────────┘               │     -> registers new cache    │
                                            │        entries                │
                                            └──────────────────────────────┘
```

This is **not** "trust the client." Every supplied path is re-validated on submission,
independent of anything discovered off-chain, using the exact same standard the self-searching
path already enforced:

- **Structural connectivity** — every hop's claimed pool genuinely connects its claimed node
  pair (`SWPT::URC_ValidatePathStructure`), not just "some active pool exists somewhere."
- **Active-required** for the swap route and boost path (`SWPI::URC_ValidatePathActive` — every
  edge must have `can-swap=true`), since real funds move along the route and the boost path
  feeds a real burn.
- **Depth cap** (7 nodes / 6 hops, P0.4) enforced on every submitted path, not assumed of the
  off-chain search that produced it.
- **Endpoint match** — a structurally-valid-but-wrong-pair path (e.g. leftover from a different
  swap) is rejected; the supplied route must genuinely start/end at the swap's own input/output
  tokens.
- **Slippage floor**, computed fresh against **current** live reserves over the bundle's own
  exact edges (`SWPI::URC_HopperForKnownRoute`) — a route that goes stale between off-chain
  discovery and submission fails the floor check, exactly like today's self-searching path
  reacting to reserve movement. Staleness is caught by economics (the floor), not by trusting
  freshness.

A malformed, adversarial, or stale bundle can only ever fail safely — reject the swap
(structural/endpoint/depth-cap violations, at the defcap layer, before any state changes) or
degrade gracefully (an invalid boost-path or stoa-path just means that one component isn't
priced/boosted this round — `-1.0`/`EOC` sentinels, never a crash, never a partial-write). See
§6 for the exact mechanics.

## 3. The bundle: `SmartSwapPathBundle`

Declared on the `SwapperUsageV2` interface, `1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact`:

```pact
(defschema SwapRoute
    nodes:[string]      ;; both endpoints included
    edges:[string]       ;; one shorter than nodes — the swpair for each hop
)
(defschema CachedPathOrMiss
    nodes:[string]        ;; [BAR] sentinel = "no path exists anywhere"
    edges:[string]
    is-new:bool           ;; hint only — never trusted as write authority (§6)
)
(defschema TokenPathPair
    first-token:string
    path:object{CachedPathOrMiss}
)
(defschema SmartSwapPathBundle
    swap-route:object{SwapRoute}
    boost-path:object{CachedPathOrMiss}
    stoa-paths:[object{TokenPathPair}]
)
```

| Field | Direction | Cached? | Target token | Purpose |
|---|---|---|---|---|
| `swap-route` | `input-id` → `output-id` | **Never** — amount-sensitive, must be fresh every call (§4) | n/a | The actual swap path |
| `boost-path` | `output-id` → **DLK** (`DALOS::UR_SilverStoaID`) | Yes, amount-agnostic | DLK | Liquid Boost burn valuation |
| `stoa-paths[i]` | `distinct pool's first-token` → **DWK** (`DALOS::UR_WrappedStoaID`) | Yes, amount-agnostic | DWK | Per-pool `stoa-value` pricing |

**DLK and DWK are different tokens** (Silver/Liquid Stoa vs Wrapped Stoa) — this was a real
doc-comment bug caught while tracing `URC_PoolValue`'s actual implementation before Phase 8 was
built against it (recorded in the exhaustive-path-search HANDOFF's Phase 8 entry). Don't
conflate them when constructing a bundle.

`stoa-paths` is **deduped by first-token, not one entry per pool** — a 6-hop swap touching 6
pools that happen to share 2 distinct first-tokens only needs 2 entries, not 6 (this dedup is
where the largest chunk of the original gas crisis lived — `XE_UpdateStoaValue`'s redundant
per-pool searching was 56.9% of the 102-pool worst-case total). The on-chain side re-derives the
real dedup itself (`SWPU::URC_DedupFirstTokens`) and tolerates an imperfectly-deduped bundle —
worst case, harmless redundant lookups against already-supplied data, never a correctness issue.

## 4. Client orchestration sequence — how to build a bundle

All of this is **free** (`/local` dirty reads, not a transaction) except step 5.

1. **Route (`swap-route`)** — dirty-read `SWPI::URC_HopperActive(input-id, output-id,
   input-amount)`. This is the same best-of-3 active-only search the self-searching path already
   runs internally; running it off-chain instead of on-chain is the entire point. Never cached —
   amount-sensitive, re-derive every call.
2. **Boost path (`boost-path`)** — resolve `output-id` (the swap's last token) → DLK:
   - Dirty-read `SWPT::URC_ReadPathCache(output-id, dlk)` first. A hit (`nodes != [BAR]`) →
     use it as-is, `is-new=false`.
   - A miss → dirty-read `SWPI::URC_HopperActiveShortest(output-id, dlk, <any amount>)` (the
     discovery amount doesn't matter — this path is amount-agnostic, only used to price a
     residual fee slice at swap time via fresh math) and set `is-new=true`.
   - **Depth-cap reality check:** the boost path is validated **active-required** with the same
     7-node/6-hop cap as the swap route. In a topology where the swap's own output token is
     itself far (>6 hops) from DLK, `URC_HopperActiveShortest`'s own BFS has no depth
     restriction and can return a longer path than the cap allows — it will be rejected on
     submission (gracefully: boost simply doesn't get pumped that round, not a failure).
     Confirmed empirically in the P2-scale worst-case topology (`SWP|TX 032z6`/`032z7` in
     `[6.3]_SWP.repl`): don't assume a discovered boost path is automatically eligible — it's
     still worth submitting (graceful degrade costs nothing extra), just don't expect boost to
     fire in that case.
3. **Stoa-value paths (`stoa-paths`)** — for each **distinct pool** the route from step 1
   actually traverses, resolve its first token (`SWP::UR_PoolTokens(pool)[0]`), **dedupe by
   first-token**, then for each distinct first-token repeat step 2's cache-check/trace pattern
   targeting **DWK** instead of DLK (`ref-DALOS::UR_WrappedStoaID`). Tokens that already equal
   DWK or DLK need no path at all (`URC_WorthDWK`/`URC_PoolStoaValueFromPath`'s own
   short-circuits handle those directly).
4. **Assemble** the `SmartSwapPathBundle` object from the above.
5. **Submit** — call the real Talos entrypoint (§5) with the bundle as the last argument. This
   is the only step that costs gas.

This is the "hammering and polling, shown live to the user" UX pattern already anticipated
early in this effort — a UI can show route/pricing discovery happening (progress indicators)
while all of it is actually free, then submit once assembled.

## 5. Entrypoints — what to actually call

**Bundle-based (new, `C_` prefix — the preferred path once measured against `CC_`, §7):**

```pact
;; Talos (1_SOVEREIGN/STAGE_01/3_Talos/04_TS01-C3.pact)
(SWP|C_SmartSwapWithSlippage patron account input-id input-amount output-id slippage-bounds bundle)
(SWP|C_SmartSwapNoSlippage   patron account input-id input-amount output-id bundle)
```

Both wrap `SWPU::C_SmartSwap`, bill IGNIS via `IGNIS::C_Collect`, and then run the **dumb
writer** — `stoa-results` (precomputed inside `C_SmartSwap`, `[{pool, stoa-value}, ...]`) is
mapped straight into `ref-SWP::XE_UpdateStoaValue`, **zero** `URC_PoolValue` calls at the Talos
layer for this path (the mechanism that removes the 56.9%-of-total cost source).

**Self-searching (existing, `CC_` prefix — kept for comparison, not deprecated):**

```pact
(SWP|CC_SmartSwapWithSlippage patron account input-id input-amount output-id slippage-bounds)
(SWP|CC_SmartSwapNoSlippage   patron account input-id input-amount output-id)
```

Identical external contract to before Phase 8 (the rename from `C_` to `CC_` was mechanical,
zero behavior change — Stage A of Phase 8, `5774a79`).

## 6. Cache self-warming — how the shared path cache actually fills

`SWPT|PathCache` (keyed `<token-a>|<token-b>`, insertion-order, reversed-lookup at read time —
see its `;;Key` comment) starts empty. It fills as a **side effect of real, validated,
successful `C_SmartSwap` calls only** — there is no standalone "register a path" public
entrypoint, ever. This is the primary abuse-resistance mechanism (§7 of the exhaustive-path-search
HANDOFF's P3.8): a bad actor cannot pollute the shared cache without paying for and executing a
real, structurally-valid swap.

Mechanics (`SWPU::XI_RegisterBundlePaths`, called from inside `C_SmartSwap`'s own granted
capability — **must** run there, not after; a capability grant's scope is its own dynamic call
extent, not the rest of the transaction, confirmed the hard way via a real
`require-capability: not granted` regression failure while building this):

1. Only fires when the swap **actually executed** (not on a slippage soft-fail).
2. For `boost-path` and each `stoa-paths` entry: only registers when the bundle claims
   `is-new=true` **and** the path independently re-validates (never trusts the flag) **and**,
   for `stoa-paths`, the first-token is genuinely among the swap's own real touched pools (never
   blindly every entry a caller might have stuffed into the bundle).
3. Writes via `SWPT::XE_RegisterPath` — a proper forward-module writer (`UEV_IMC` + internal
   `SECURE` composition), **never** a caller-side grant of `SWPT.SECURE` directly. `SWPT.SECURE`
   is unconditionally `true`; a direct cross-module grant of a `true`-bodied cap would hand it to
   any caller, not just the intended one (this exact vulnerability class is documented,
   empirically, in this codebase's own `Audit/ATS/ROUND-01-FINDINGS.md`). Investigated before
   building, not assumed.
4. `SWPT::XI_RegisterPath` itself is first-write-wins, self-verifying (checks both key
   directions before writing) — a registration call here is always safe to no-op on if another
   caller already won the race for the same pair.

Once a pair is registered, subsequent bundle-builders get a cache **hit** at step 2/3 of §4 and
skip the fresh trace — the whole point of the shared cache. Every reader still re-validates on
every use regardless of hit/miss (§2) — a hit is proof of prior registration, never proof of
current validity.

## 7. `CC_` vs `C_` — measured gas, when to use which

Same worst-case swap (`W1`→`W7`, 6 hops, ~102 active pools, Liquid Boost on):

| Entrypoint | Gas | vs ceiling (~2,000,000) |
|---|---|---|
| `SWP|CC_SmartSwapNoSlippage` (self-searching) | 7,145,298 | 3.57x **over** |
| `SWP|C_SmartSwapNoSlippage` (bundle-based, cold cache) | 397,043 | 0.20x — safely under |

(385,749 gas measured before the cache-registration writes were wired in; +11,294 for the actual
first-time cache-warming inserts on that run.)

Both variants are kept, deliberately, per the owner's design (`P3.5.2`): `CC_` as the
zero-off-chain-orchestration fallback (works with no client-side infrastructure at all, at the
cost of possibly exceeding the gas ceiling at scale) and `C_` as the preferred path once a
client can do the dirty-read orchestration in §4. Whether `CC_` is ever fully retired is an
explicit open decision, not yet made — not this doc's call.

## 8. What this doc does **not** cover (still open, tracked elsewhere)

- **Genuine exhaustive route discovery** (`SWPT::URC_ComputeAllRoutes`, a real parameterized
  search beyond today's best-of-3) — Phase 11 of the master plan. `URC_HopperActive` in §4 step 1
  is what exists *today*; Phase 11 will make that discovery step itself more thorough without
  changing anything else in this doc (the bundle shape, validation model, and entrypoints stay
  the same — only what fills `swap-route` off-chain gets stronger).
- **Adversarial malformed-bundle proof** (disconnected route, inactive edge, fabricated path,
  submitted deliberately) — Phase 10. §2's validation model gives strong reason to expect clean
  rejection in every case, but this hasn't been proven with a real revert-reproduce REPL test
  yet. Don't cite this doc as that proof.
- **Manual path selection UI** (letting a user browse/pick their own route instead of the
  auto-discovered one) — same execute-only entrypoint in §5 accepts it either way (the on-chain
  side can't tell "auto-discovered" from "hand-picked," both are just a `SmartSwapPathBundle`),
  but no UI spec for that flow exists yet.

## Cross-references

- Full history / every design decision / why-not-alternatives:
  [`HANDOFF-swp-exhaustive-path-search.md`](HANDOFF-swp-exhaustive-path-search.md)
- Table key conventions used above: `StoicSyntax.md` § 19.5 (`;;Key = <...>`)
- Real code: `1_SOVEREIGN/STAGE_01/2_Core/{14_SWPT,15_SWP,16_SWPI,19_SWPU}.pact`,
  `1_SOVEREIGN/STAGE_01/3_Talos/04_TS01-C3.pact`
- Permanent regression proofs: `REPL/Stage_01/[6.3]_SWP.repl`, `SWP|TX 032z2` (CC_ baseline),
  `032z3`/`032z4` (Phase 7 core functions), `032z5` (crash-bug fix), `032z6`/`032z7`
  (bundle-based end-to-end + cache self-warming)

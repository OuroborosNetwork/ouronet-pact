# Client orchestration — dirty read, build, execute

Every Ouronet operation where the client must **read first, construct something from the result,
and only then submit**. Written for whoever is wiring OuronetUI; doubles as the source for the
Integration chapter.

Measured against the tree at 2026-09-24. Where a figure appears, it was read from the source or
a REPL run, not remembered.

---

## 0. Why this document exists

Most Ouronet calls are one transaction with literal arguments. A growing number are not, and
they are not all the same shape. Three distinct mechanics are already live and a fourth is
coming, and **the difference between them decides whether you may fire transactions in parallel**
— which is not something you can tell by looking at a function name.

Worse, two of the shapes share the `p` suffix. `Cp_WipeSlice` and `CCp_SweepRecomputeChunk` look
like siblings. One is parallel-safe and the other will corrupt its own progress if you fire two
at once.

---

## 1. The four shapes

| | shape | how you recognise it | parallel? |
|---|---|---|---|
| **I** | **Preflight → one transaction** | a `URC_`/`URHC_` read whose result becomes an argument | n/a — one tx |
| **II** | **Preflight → N fed slices** | the entrypoint takes the SLICE ITSELF (`…-obj`, explicit lists) | **YES** |
| **III** | **Cursor pager** | the entrypoint takes only a SIZE (`chunk:integer`) | **NO — strictly sequential** |
| **IV** | **`defpact`** | declared `defpact`, steps advance by continuation | no — chain-ordered |

### The recognition rule, stated once

**Look at what the entrypoint takes, not at its prefix.**

- If it takes the data to operate on — `removable-nonces-obj`, `owner-ids` + `amounts`, a fed
  `amount` — the caller decides the partition. Nothing on chain tracks position. Order cannot
  matter, so **fire them all at once**.
- If it takes a `chunk:integer` and nothing identifying *which* chunk, it computes its own
  window from **stored progress**. Two in flight read the same cursor and do the same work, or
  skip. **One at a time, confirm, then the next.**

---

## 2. Shape I — preflight, then one transaction

### 2a. SmartSwap (the headline case)

**Full detail:** `OuronetInformational/HANDOFFS/HANDOFF-swp-smartswap-bundle-architecture.md`.
Read it before implementing; this section is the orientation, not a replacement.

The mechanic changed. There are now **two** SmartSwap entrypoints and they are different
operations, not two spellings of one:

```pact
;; SELF-SEARCHING — traces the path on chain via BFS. Kept, not deprecated.
(SWP|CC_SmartSwapWithSlippage patron executor input-id input-amount output-id slippage-bounds)
(SWP|CC_SmartSwapNoSlippage   patron executor input-id input-amount output-id)

;; BUNDLE-BASED — the path is discovered CLIENT-SIDE and injected. Zero on-chain searching.
(SWP|C_SmartSwapWithSlippage  patron executor input-id input-amount output-id slippage-bounds bundle)
(SWP|C_SmartSwapNoSlippage    patron executor input-id input-amount output-id bundle)
```

`bundle` is `SwapperUsageV3.SmartSwapPathBundle`:

```pact
(defschema SmartSwapPathBundle
    swap-route  : object{SwapRoute}              ;; the route itself
    boost-path  : object{CachedPathOrMiss}       ;; targets SSTOA
    stoa-paths  : [object{TokenPathPair}]        ;; each targets WSTOA -- NOT the same target
)
```

**The trap in that schema is the last line.** `boost-path` resolves toward **SSTOA** and each
`stoa-paths` entry resolves toward **WSTOA**. Two different destination tokens in one object. A
client that builds both with the same target will produce a bundle that is structurally valid,
passes every type check, and prices the swap against the wrong asset.

**What the bundle buys:** the on-chain path search is removed entirely, and so is the Talos-layer
`URC_PoolValue` re-derivation — `stoa-results` is precomputed inside `SWPU::C_SmartSwap` and
mapped straight into `XE_UpdateStoaValue`. The handoff records that as removing a cost source
worth 56.9% of the total.

**Why it is still one transaction, and therefore shape I:** the dirty read produces an
*argument*, not a *transaction*. Nothing is written between the read and the execute. If the
pool state moves in between, the swap is protected by `slippage-bounds`, which is the same
protection it always had. **The two-phase shape introduces no new race** — that is the property
worth understanding before trusting it, and it is why the bundle can be built lazily at the
moment the user presses the button rather than held.

**Which to call.** Owner ruling pending. `CC_` has exactly the shape the UI emits today, so a
one-line builder rename restores it; `C_` needs the bundle wiring. The gas comparison is in §7 of
the handoff. They were built side by side on purpose.

### 2b. Slippage bounds

Already client-constructed today and easy to miss because it looks like a plain argument:

```pact
(UDC_SpawnSmartSwapSlippageBounds input-id input-amount output-id slippage)
(UDC_SpawnSlippageBounds          swpair input-ids input-amounts output-id slippage)
```

Pure constructors — no state — so they may be evaluated in the same dirty read that builds the
bundle.

### 2c. Stage Two emission, single-transaction form

`AA_OuroMinterStageTwo` takes one argument: four FVT ids **by position** —
`[CustodiansVault, CompanySharesTreasury, OuroLpFarm, SubsidiaryTreasury]`, length-4 enforced.

They **must** be fed, and the reason generalises to every AQP entity: **an AQP id embeds the
block hash of the transaction that minted it.** In the REPL they look derivable via `UDC_Makeid`
only because the fixture's prev-block-hash is fixed. On chain they are not derivable at all.

Preflight: `URHC_StageTwoPlan` returns the daily amount, the split, per-vault stale counts, an
estimated gas figure and a `one-tx` recommendation.

**Treat `one-tx` as advice, not a guarantee.** Its slope constant `S2-GAS-PER-STALE = 6,500` was
measured in `AQP-scale-inject.repl`, never inside the emission itself — the boot fixture's vaults
have no stakers. Honest arithmetic over a slope this function has not exercised.

---

## 3. Shape II — preflight, then N fed slices, fired together

**This is the only shape you may parallelise.** The entrypoint receives the slice, so nothing on
chain arbitrates between callers.

### 3a. `Cp_WipeSlice` — the reference fed-slice

```pact
(DPOF|Cp_WipeSlice patron id account removable-nonces-obj)
(DPSF|Cp_WipeSlice patron account id removable-nonces-obj)   ;; note: account and id transposed
(DPNF|Cp_WipeSlice patron account id removable-nonces-obj)
```

**The argument order differs between the DPOF form and the DPDC forms.** `DPOF` takes
`(id account)`; `DPSF`/`DPNF` take `(account id)`. Both are `:string`, so a transposition
type-checks and fails at the ownership enforce — or worse, does not.

Sequence: `URH_` preflight to enumerate removable nonces → partition client-side → build one
`removable-nonces-obj` per slice → **submit all slices simultaneously**. Any slice may be retried
alone; re-running one that already applied is a no-op against an already-empty set.

### 3b. `CCp_BatchVacate*` / `CCp_BatchDrain*` — AQP pool evacuation

```pact
(AQP-POOL|CCp_BatchVacateTrueFungible  patron pool-id dptf-id      owner-ids beneficiary-ids amounts)
(AQP-POOL|CCp_BatchVacateOrtoFungible  patron pool-id dpof-id      owner-ids beneficiary-ids nonces-array)
(AQP-POOL|CCp_BatchVacateCollectables  patron pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array)
```

plus the three `CCp_BatchDrain*` counterparts. Parallel lists — `owner-ids[i]` pairs with
`beneficiary-ids[i]` and `amounts[i]`. The client owns the partition, so these are fed slices and
parallel-safe. Split by owner, never mid-owner.

### 3c. Stage Two emission, parallel form

Two phases, and **the second cannot start until the first confirms**:

1. `A_OuroMinterStageTwo_Flat` — **no arguments**. Mints and leaves the residual in the Stage Two
   bucket: 50% of the daily in OURO plus the coiled AURYN.
2. `AA_OuroMinterStageTwo_InjectLeg` ×4 — **fed amounts**, therefore order-independent and
   submittable together.

The amounts are recoverable with `URC_StageTwoResidual`, which derives them from bucket balances
alone — **40 / 20 / 40 of the OURO residual and 100% of the AURYN**. Compute the two 40% figures
and take the 20% by difference; do not compute all three independently or rounding will not sum.

Why the phases cannot be merged: `URC_DailyOURO` reads OURO supply, and leg 1 *mints into it*. A
second phase that recomputed the daily would compute a smaller one. The residual is carried in
the bucket's balance rather than in a table — no bookkeeping, and self-correcting on retry.

**The operational rule:** finish a run before starting the next. Two flat legs back to back are
safe (same 40/20/40 ratio). A flat leg while injects are pending **misallocates between vaults** —
nothing is lost, the proportions are wrong. A non-empty bucket after a completed run is the
alarm, and it belongs in the UI.

---

## 4. Shape III — cursor pagers. One at a time.

```pact
(AQP-FVT|CCp_InjectFixChunk      patron fvt-id reward-dptf-id chunk)   ;; then CC_InjectFinalize
(AQP-FVT|CCp_UnstaleAll          patron fvt-id reward-dptf-id chunk)
(AQP-FVT|CCp_SweepRecomputeChunk patron anchor-id chunk)
```

`chunk` is a **size, not an index.** There is no argument saying *which* chunk — the function
reads stored progress and computes its own window. Two in flight see the same cursor.

Client loop: submit → **wait for confirmation** → submit the next → repeat until the returned
string reports completion. Then, for the inject path only:

```pact
(AQP-FVT|CC_InjectFinalize patron executor fvt-id reward-dptf-id amount)
```

Note `CC_InjectFinalize` takes an **`executor`** where the chunk functions do not. The chunkers
are maintenance sweeps attributable to the patron; the finalize moves value and must name who
did it.

**Choosing `chunk`:** too large and the transaction exceeds gas and the whole page is lost; too
small and confirmations dominate. Start conservative and raise it against measured gas, not
against a guess — the cost per item varies with how stale the rows are.

---

## 5. Shape IV — `defpact`

Distinct from everything above: a `defpact` is **one transaction with ordered continuations**,
and the chain tracks the step. You are not composing anything; you are advancing a pact id.

The eight `MTX-SWP` pool and liquidity operations and `MTX-AQP|2|CC_Inject` are here. They bill on
a later step, not the starter — so a client that reads the cumulator from step 0 will see nothing
and must not conclude the operation was free.

---

## 6. The complete register

Everything in the tree that a client must orchestrate, so nothing is discovered by accident.

| operation | shape | preflight | parallel |
|---|---|---|---|
| `SWP\|C_SmartSwap*` | I | bundle build (client BFS) | one tx |
| `SWP\|CC_SmartSwap*` | I | none — searches on chain | one tx |
| any `*WithSlippage` | I | `UDC_Spawn*SlippageBounds` | one tx |
| `AA_OuroMinterStageTwo` | I | `URHC_StageTwoPlan` + 4 fed FVT ids | one tx |
| `DPOF\|Cp_WipeSlice` | II | `URH_` removable-nonce scan | **yes** |
| `DPSF\|Cp_WipeSlice`, `DPNF\|Cp_WipeSlice` | II | same | **yes** |
| `AQP-POOL\|CCp_BatchVacate*` ×3 | II | enumerate owners | **yes** |
| `AQP-POOL\|CCp_BatchDrain*` ×3 | II | enumerate owners | **yes** |
| Stage Two flat + 4 inject legs | II | `URC_StageTwoResidual` after phase 1 | **yes, within phase 2** |
| `AQP-FVT\|CCp_InjectFixChunk` → `CC_InjectFinalize` | III | stale count | **no** |
| `AQP-FVT\|CCp_UnstaleAll` | III | stale count | **no** |
| `AQP-FVT\|CCp_SweepRecomputeChunk` | III | — | **no** |
| `MTX-SWP` ×8, `MTX-AQP\|2\|CC_Inject` | IV | — | chain-ordered |

---

## 7. What is NOT settled, and should not be guessed

- **`SmartSwap`: `CC_` or `C_`.** Owner ruling pending. Different operations, not two spellings.
- **The bundle's two targets.** `boost-path` → SSTOA, `stoa-paths` → WSTOA. Verify against a
  known route before trusting a client-side builder; a wrong target is silent.
- **`S2-GAS-PER-STALE`.** Extrapolated, never exercised inside the emission. Re-measure when the
  Custodians vault has depth.
- **Parameter naming drift.** `HANDOFF-swp-smartswap-bundle-architecture.md` §5 writes the second
  argument as `account`; the canon calls it `executor`. Same slot, same meaning — noted so nobody
  reads it as a second parameter.

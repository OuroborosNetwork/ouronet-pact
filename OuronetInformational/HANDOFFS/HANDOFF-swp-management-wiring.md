# Wiring the SWP pool-management buttons — what the registry answered, and what it can't

Analysis of the two unwired pages in **Liquidity Pools Management** (`swp-pairs-proto.tsx`):
**Pool Settings** and **Fee Management**.

---

## 1. The registry answered the contract half completely

Every unwired button mapped to a deployed entrypoint from **one query** — no grepping Pact
sources, no guessing:

| button | UI location | entrypoint | parameters |
|---|---|---|---|
| Modify Amplifier | Pool Settings › Weights | `SWP\|C_UpdateAmplifier` | `(patron executor swpair amp)` |
| Activate (frozen LP) | Pool Settings › LP Types | `SWP\|C_EnableFrozenLP` | `(patron executor swpair)` |
| Activate (sleeping LP) | Pool Settings › LP Types | `SWP\|C_EnableSleepingLP` | `(patron executor swpair)` |
| Define × 2 (frozen link) | Pool Settings › Special Links | `VST\|C_CreateFrozenLink` | `(patron executor dptf)` |
| Define × 2 (sleeping link) | Pool Settings › Special Links | `VST\|C_CreateSleepingLink` | `(patron executor …)` |
| Lock / Unlock Fees | Fee Management | `SWP\|C_ToggleFeeLock` | `(patron executor swpair toggle)` |
| Set LP Fee | Fee Management | `SWP\|C_UpdateFee` | `(patron executor swpair new-fee lp-or-special)` |
| Set Special Fee | Fee Management | `SWP\|C_UpdateFee` | same, `lp-or-special` flipped |
| Update Special Fee Targets | Fee Management | `SWP\|C_UpdateSpecialFeeTargets` | `(patron executor swpair targets)` |

**All are `execution.mode: direct`** — none needs a preflight read, which is the case that makes
wiring cheap.

### Proven, not asserted

Six preview calls were **built entirely by the registry** — no builder function, no INFO reader,
no hand-typed name — and fired at mainnet against the live pool
`W|SSTOA-8Nh-JO8JO4F5|OURO-8Nh-JO8JO4F5|WSTOA-8Nh-JO8JO4F5`:

```
ToggleFeeLock            OK   2.0 IGNIS
EnableFrozenLP           OK   1413.0 IGNIS  ($14.13)
EnableSleepingLP         OK   1411.0 IGNIS  ($14.11)
UpdateFee                OK   45.0 IGNIS
UpdateAmplifier          OK   44.0 IGNIS
UpdateSpecialFeeTargets  OK   44.0 IGNIS
```

Six operations that had never been called from this app, priced correctly, with zero hand-written
Pact. **That is the registry's answer to "how useful is it really."**

### One trap it also settled

`Set LP Fee` and `Set Special Fee` are the **same entrypoint** distinguished by a boolean. Read
from `SWP::XI_UpdateFee`: `lp-or-special = true` → writes `fee-lp`; `false` → writes
`fee-special`. The fee is in **promille**, valid range **0.0001 – 320.0** (32%). Getting that
boolean backwards sets the wrong fee to a plausible-looking value — exactly the class of bug
nothing downstream would catch.

---

## 2. What the registry does NOT do, measured

A working button in this app is four layers. The registry removes two of them outright:

| layer | before | with the registry |
|---|---|---|
| builder in `ouronet-core/pact` | ~10 lines, hand-written per op | **gone** — `buildCall(key, values)` |
| INFO reader in `ouronet-core/interactions` | ~25 lines per op | **gone** — `buildPreviewCall(key, values)` |
| CFM modal | ~340 lines | still needed |
| button `onClick` | 1 line | 1 line |

**None of the eight builders or INFO readers exists today** — checked. Before the registry, each
button meant publishing a new `ouronet-core` before the UI could even start. Now it means neither.

### The modal is the remaining work, and it is one component, not seven

Two sibling modals differ by **22 lines out of 339** — 94% boilerplate. The parts that are
identical across the whole family:

- `ZbomLayout` shell and execute button
- `InfoZoneWrapper` rendering of the `ClientInfo` response (pre-text, IGNIS/KDA cost, post-text)
- `PatronZonePattern2`
- the `strategy.execute({ build, guards, paymentKey })` submit path, including the
  `DALOS.GAS_PAYER` capability and `guards: [patronGuard, ownerGuard]` — **uniform for every
  pool-management op, because they are all owner-signed**

What genuinely varies per button: the **title/icon**, and **which parameters the user supplies
and with what widget**.

So the honest answer to *"can you wire everything in one go"*: the naming, arity, ordering, type
formatting and cost preview — **yes, done and verified**. The UI is one generic
registry-driven modal, after which each button is a few lines.

---

## 3. Suggested order, by input shape

1. **No user input** — `EnableFrozenLP`, `EnableSleepingLP`. Confirm + execute only.
2. **Autonomous boolean** — `ToggleFeeLock`. Identical in shape to the working
   `ToggleSwappingCFMModal`: the value is the inverse of chain state, the user types nothing.
3. **One decimal** — `UpdateAmplifier`, `UpdateFee` ×2. Needs a bounded numeric input
   (fees: 0.0001–320.0 promille) and, for the fee pair, the `lp-or-special` constant per button.
4. **List editor** — `UpdateSpecialFeeTargets`. `targets:[object{FeeSplit}]`, the only one
   needing a repeating-row editor; the page already renders the 7 slots read-only.
5. **Different module** — the four `Define` buttons call `VST|C_Create*Link`, not SWP, and take a
   token id rather than the pool. Check what the page has in scope before wiring.

`Modify Amplifier` is disabled unless `poolType === "S"`, and the live pool is `W` — so it cannot
be exercised against the current pool. Wire it, but expect to verify it elsewhere.

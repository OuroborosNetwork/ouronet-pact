# `(enumerate 0 (- (length xs) 1))` is not an empty range — Pact's `enumerate` counts DOWN

**Date:** 2026-09-11 · **EXTENDED 2026-09-12** — a FOURTH instance, and the first where the consequence
is a **mute guard in a supported client path** (see the section at the end)
**Status:** four confirmed defects pinned
(`Kursan/_verify_finding_EMPTY-LIST_01_index_iterating_cumulators.repl`, `EL-5`/`EL-6` in
`modules/AQP.repl`); 92 further uses inventoried, NOT claimed as bugs.

> **THE LANGUAGE FACT BELOW WAS ALREADY KNOWN HERE. This file did not discover it.**
> It is documented in `_scratch_udec_h15_hybridarray_emptyinput.repl` (DALOS audit **#20H**,
> `U_DEC::UC_AddHybridArray`) and in
> `Kursan/_verify_finding_DPDC-F-S_47L-51L_empty_definition_guards.repl` (findings **#47L/#51L**,
> DPSF set-definitions), where it was found AND fixed. The owner's note on #20H is worth repeating:
> *"never seen it crash in production — every real caller always passes a non-empty column set."*
> That is the same conclusion this file reaches independently, and it should have been the starting
> point rather than a rediscovery.
>
> **What is actually new here** is narrower and worth keeping: the SWEEP for remaining instances,
> the convention it revealed (client checks non-empty, internal predicates assume it), the three
> places that convention breaks, the `_foldeager.py` `[index]` extension, and the `enforce-one`
> boundary. Read the fact below as background, not as a finding.

## The language fact

```
(enumerate 0 -1)  ->  [0, -1]     ;; NOT []
(enumerate 0  0)  ->  [0]
(enumerate 0  2)  ->  [0, 1, 2]
```

When `from > to`, `enumerate` produces a DESCENDING range. So the standard index idiom

```pact
(fold (lambda (acc idx) … (at idx xs) …) [] (enumerate 0 (- (length xs) 1)))
```

iterates **twice** on an empty `xs` instead of zero times, and the first step does `(at 0 [])`:

```
Array index out of bounds. Length (0), Index (0)
```

**`try` does NOT catch this.** An out-of-bounds index is not recoverable by `try`, so a caller
cannot defend itself — the guard has to live in the callee. `expect-failure` does catch it, which
is the only reason it can be asserted at all. (This is a second, separate `try` trap alongside the
read-only one: `try` also bans `keys`/`select`.)

## The confirmed defect — and what it is NOT

`INFO_ATS|WithdrawRoyalties` → `ATSU::URCi_WithdrawRoyalties` → `TFT::URCi_MultiTransferCumulator []`
faults on a pool with no accrued royalties.

How the empty list arises is the interesting part. `ATSU::C_WithdrawRoyalties` carries a `@doc` for
audit finding **#33N**: multi-transfer used to debit every leg unconditionally, so a reward-token
with zero royalty hit DPTF's `(amount > 0.0)` enforce and killed the withdrawal. The fix filters to
nonzero legs — which yields an **empty** list when *all* are zero, i.e. every pool that has not yet
accrued. The #33N fix created the state that triggers this one.

**What I nearly shipped, and why I did not.** I had read `C_MultiTransfer`, seen the same idiom with
no non-empty guard in its defcap (`UEV_IzUnique` passes on `[]`; `(= l1 l2)` passes on `0 == 0`), and
was about to report a funds-path defect. Executing it says otherwise:

| path | same pool, same question | result |
|---|---|---|
| **client** `ATS\|C_WithdrawRoyalties` | | refuses cleanly: *"No Royalties to withdraw for ATS-Pair Auryndex-…"* |
| **preview** `INFO_ATS\|WithdrawRoyalties` | | `Array index out of bounds. Length (0), Index (0)` |

The client is **guarded**. Funds are not at risk. The defect is the **asymmetry**: a preview exists
to answer the question the client will be asked, and here it throws an internal fault for a state
the client treats as ordinary. Both are now pinned as a pair, because either alone is misleading.

Only the 3-argument `expect-failure` caught this. The 2-arg form would have gone green on the
client's deliberate refusal and I would have published "the funds path crashes."

## The fix is not a design decision — TFT already contains the right answer

TFT's cost previews split into two styles, and the empty case separates them cleanly:

| style | how it prices | empty input |
|---|---|---|
| **index-iterating** — `(enumerate 0 (- (length xs) 1))` | folds per leg | **faults** |
| **size-arithmetic** — takes `size:integer`, prices via `UDCx_BulkTransferCumulator` | multiplies | **0.0, no special case** |

- faulting: `URCi_MultiTransferCumulator`, `URCi_MultiBulkTransferCumulator`, `URCi_UnityBulkTransferCumulator`
- already correct: `URCi_SimpleBulkTransferCumulator`, `ComplexBulk`, `EliteBulk`

So *"a zero-leg transfer costs zero"* is already this module's answer — the index-iterating three
just don't give it. **The fix is to make three functions agree with three others in the same file**,
not to choose a new policy. All six are pinned side by side in `TFT-MT3`.

One caveat recorded in the harness so it is not misread: `URCi_BulkTransferCumulator` returns 0.0 on
empty, but it is a **dispatcher**, safe on that path only because the input routed to a
size-arithmetic branch. Its `what-type 2` branch delegates to `UnityBulk`, which faults. It is not
independently guarded.

## The inventory — a review list, not a bug list

92 uses of the idiom across 28 modules. Split by whether the list can reach it empty from outside:

- **47** take the list straight from a function parameter (a caller *could* pass `[]`) — including
  `TFT::C_MultiTransfer`, `C_MultiBulkTransfer`, `DPOF|C_BulkTransfer`, `DPDC|C_BulkTransfer`, and
  most of the AQP/VCT `nonces` and `owner-ids` families.
- **45** derive the list internally and need a per-site look.

Most are certainly fine — fed by lists that cannot be empty, or guarded upstream exactly as
`C_WithdrawRoyalties` is. Reproduce the split with the triage snippet in this session's transcript,
or just grep `(enumerate 0 (- ` and check each caller.

**The durable fix** is to make the empty case well-defined once, in the callee — a zero-leg transfer
costs nothing and transfers nothing — rather than adding a non-empty enforce at 92 call sites.

## The same defect without `enumerate`: eager `fold` + indexing

`(fold (and) true [...])` is the idiom CLAUDE.md mandates for 3+ conditions, and it is **not
short-circuiting** — `fold` receives an already-built list, so every conjunct evaluates. When a
later conjunct INDEXES a list an earlier conjunct is measuring, the index runs regardless:

```pact
(fold (and) true
    [ (= l-fa 1)                       ;; l-fa is (length fee-array), bound in the let above
      (= (at 0 (at 0 fee-array)) 0.0)  ;; runs anyway -> index fault when fee-array is empty
    ])
```

`_foldeager.py` already existed for the *table-read* version of this shape; it did not cover the
*indexing* version. **Extended rather than replaced** (the tool-duplication rule), including
resolution of let-bound length aliases — without that it found nothing, because the length is
almost always bound above the fold rather than written inline. Now reports 4 `[index]` sites.

**`U|ATS::UEV_CRF|FeeArray` is the one that matters**, and it is the worst possible placement: a
validator whose only job is rejecting malformed input. Via `ATS|C_SetColdRecoveryFees`:

| input | result |
|---|---|
| `fee-positions 0, [], []` | *"Fee Position 0 is invalid"* — deliberate, readable |
| `fee-positions 1, [10.0], []` | **`Array index out of bounds`** |

The second is the likelier mistake, and the function **already contains the right message** for it
(*"Inner Lists of the `<fee-array>` are incompatible with the `<fee-thresholds>` length"*). The eager
fold faults before that enforce is reached. The fix is to let the enforce the author already wrote
actually run. Pinned as `EL-5` / `EL-5b`.

## `enforce-one` is not a try/catch

Established by execution because the DALOS gas-station analysis turned on it:

- it **does** recover from a failed `enforce` in an earlier branch;
- it does **not** recover from a native fault — an out-of-bounds index propagates straight through
  and kills the transaction. The caller does not even get enforce-one's own message.

This matters for `DALOS::GAS_PAYER`, whose three `enforce-one` branches each index `exec-lines`
inside an eager fold — `(at 0 …)` in case 1, `(at 1 …)` in cases 2 and 3 — with the `(= n 1)` /
`(= n 2)` conjuncts sitting uselessly beside them. What keeps the gas station safe is enforce-one's
**branch ORDERING**: for `n=1`, case 1 succeeds and the later branches never evaluate. That is a
real guarantee but a load-bearing accident of ordering, not a check. Pinned as `DALOS-G2f`, and
filed as a boundary rather than a defect because empty transaction code is not reachable.

## The convention, found by sweeping — and the three places it breaks

Sweeping the AQP/VCT side turned up three more predicates that fault on an empty list
(`AQP-POOL::URC_OrtoUnstakeNoncesSufficient`, `AQP-VCT::URC_VacateOrtoNoncesSufficient`,
`AQP-VCT::URC_VacateOrtoLegBeneficiaryOk`) — and **none is a reachable defect**. The client rejects
first, with an explicit *"Invalid nonces / nonce-amounts: equal positive length required"*.

That is the real finding of the sweep. The codebase has an unwritten convention:

> **The client checks non-empty. The internal predicates assume it.**

Coherent, and unenforced. So `EL-6` pins the client-side guard the predicates silently depend on,
and `EL-6b` pins the fault underneath it — the dependency asserted from both ends. Relax the client
guard and the failure appears at the cheap readable place, not as an array-bounds fault from inside
a sufficiency predicate.

`AQP-VCT::URC_VacateOrtoLegsOk` answers an empty leg list **vacuously true** without faulting, so
the module is not self-consistent on this today; that is pinned in `EL-6b` as the contrast.

**The defects are exactly where the convention breaks**, and there are three:

| site | how it breaks |
|---|---|
| `ATSU::URCi_WithdrawRoyalties` | empty list generated **internally** by the #33N filter, so no client check could catch it; client guarded, preview not |
| `DPDC-T` bulk transfer | **client not guarded at all** — both halves fault |
| `U\|ATS::UEV_CRF\|FeeArray` | client guards *empty* but not *length mismatch* — the likelier mistake |

Everything else the sweep touched is either shielded by the convention or already correct. **Do not
report the 92-site inventory as 92 defects.**

---

## 2026-09-12 — instance four, and the first with an in-repo fix reference

**Site:** `1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact`, `DPDC|C_BulkTransfer`
**Pinned by:** `modules/DPDC.repl <<DPDC-G14>>`
**Status:** OPEN, pinned as-behaves. Needs an owner decision — the fix reorders a paid client.

### What makes this one different

The three earlier instances were internal predicates computing a wrong answer on an empty input. This
one **silences a guard written for exactly the input that triggers it**, through the only supported
client path.

`DPDC-T|C>BULK-TRANSFER` folds three shape conditions under one message:

```pact
(> l 0)   (= l (length nonces-array))   (= l (length amounts-array))
```

The cap is written correctly — nothing indexes before the enforce. But the **Talos wrapper** derives two
helper lists in an eager `let`, *before* calling the core:

```pact
(l:integer (length receiver-lst))
(ids:[string]  (map (lambda (idx) id)  (enumerate 0 (- l 1))))
(sons:[bool]   (map (lambda (idx) son) (enumerate 0 (- l 1))))
(irs: … (ref-DPDC-T::C_IgnisRoyaltyCollector patron sender ids sons nonces-array amounts-array))
```

For `l = 0` that is `(enumerate 0 -1)` → `[0, -1]`, so an **empty receiver list produces TWO ids and
TWO sons**, the royalty collector indexes past the end of the one-element arrays, and the caller gets
`Array index out of bounds` instead of the sentence written for the mistake.

### Mute in two of three directions — measured, not inferred

| input | what answers |
|---|---|
| **empty** receiver list | `Array index out of bounds` — `(> l 0)` never runs |
| **more receivers** than nonce legs | `Array index out of bounds` — same cause |
| **more nonce legs** than receivers | the written message **arrives** |

Only the direction where the arrays are *longer* survives, because the derived-list indexing stays in
bounds. That asymmetry is what makes it a defect rather than a dead guard: the same enforce does speak.

### The fix is one module over, and it is purely ORDER

`1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact`'s `DPOF|C_BulkTransfer` uses the **identical**
`(enumerate 0 (- l 1))` idiom and is **not** mute — it calls the core **first** and maps **afterwards**,
so the guard answers before the hazardous expression is ever evaluated. DPOF's working behaviour is
pinned by `DPOF-G12`, which does get the message for an empty receiver list.

Proposed: move the `ids` / `sons` / `irs` bindings below the core call, as DPOF does.

### Why no detector was added

`(enumerate 0 (- <n> 1))` appears **244 times** across the sovereign and citizen sources. Almost all are
on paths where the list is guaranteed non-empty, which is the convention this file already documents
(*client checks non-empty, internal predicates assume it*). A 244-hit rule would be read once and then
ignored — the same call made against the eager-`let` detector, which measured 182 and was also declined.

The sharp filter would need to know whether the count can reach 0 **from a caller**, and whether a guard
downstream was supposed to catch it. That is cross-module reachability, not a syntactic scan. Left as the
review question instead:

> Where a list length feeds `(enumerate 0 (- l 1))`, ask: **can a caller make `l` zero, and is there a
> guard further down that was supposed to say so?**

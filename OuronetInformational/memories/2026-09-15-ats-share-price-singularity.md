# The ATS share price has a singularity, and one of its two doors was unguarded

*2026-09-15. Red-team Stage 14, RT-A-003. Found while hunting the classic vault-inflation attack.*

## The shape

An ATS pool's index is a **share price**:

```pact
URC_Index  = floor(resident-sum / rbt-supply, p)      ; -1.0 when rbt-supply = 0
URC_RBT    = floor(rt-amount / index, p-rbt)          ; the inverse, pricing a deposit
```

`C_Fuel` raises the numerator **without minting shares**, and it is permissionless. Every piece of
the classic inflation attack is present.

## Why the inflation attack is REFUSED — and what actually stops it

1. Audit finding **#11M** bounds the KickStart **ratio** to `[0.1, 100.0]`.
2. **RBT precision is 24 decimals**, so per-coil rounding loss is `index × 10⁻²⁴`.
3. A coil minting **zero** shares aborts — via `C_Mint` → `XBv_UpdateSupply` → `UEV_Amount`
   (`amount > 0`), not via any share-level check.

> **#11M bounds the RATIO, not the SCALE.** `rbt-request-amount` is floored only at `> 0.0`, so a
> one-ulp genesis supply is legal. It is the **24-decimal precision** that makes the attack
> uneconomic (~10²⁴ × the pool's own supply in donated tokens), not the bound that was written for it.

Worth remembering if precision ever becomes configurable downward: `UEV_Decimals` permits **2..24**,
and the Cold-RBT is an ordinary DPTF the pool owner already owns, so **its precision is the owner's
choice**. At 2 decimals the loss per coil would be `index / 100`.

## The live defect: index = 0

Zero is not a contrived input. Any pair whose reward-bearing token carries supply minted **outside**
the pool reads resident-sum 0 against a positive rbt-supply. **Five such pools exist at deploy** —
the AOZ primal assets:

```
Bisthanium-98c486052a51   index = 0.0   rbt-supply = 10,000,000.0   resident-sum = 0.0
```

| op, through the real Talos client | result |
|---|---|
| `ATS\|C_Fuel` (sibling) | refused — *"Fueling requires an ATS-Pair Index of at least 0.1"* |
| **`ATS\|C_Coil`** | **`Arithmetic exception: div by zero, decimal`** |
| shared reader (INFO previews use it) | same raw exception |
| same reader, healthy pool | prices normally |

**`try` cannot catch an arithmetic exception.** The old failure was not merely ugly — no caller
could handle it.

## The lesson

`ATSU|C>FUEL` enforces `index >= 0.1`, and its comment was reworded on 2026-09-13 *specifically* so
a caller with index 0.05 is not told something untrue. That much care went into one guard's
**wording**, while `ATSU|C>COIL` — the door an ordinary user reaches — had **no index check at all**.

> The guard was not missing because the state was unknown. It was missing on the door nobody looked
> at. When one sibling op guards a state deliberately, check the other siblings for the same state.

## Fix placement

Guarded inside **`URC_RBT`** rather than in `ATSU|C>COIL`, deliberately: `URC_RBT` is the function
that divides, and it is **shared by the exec path and the INFO cost previews**, so a *quote* for an
impossible coil now refuses in the same words instead of throwing. (`URC_RBT` already carried an
`enforce` — by StoicSyntax it is arguably a `URCv_`; renaming would cascade through the interface,
so the guard was added beside the existing one rather than the prefix changed.)

## Incidental findings worth keeping

- `URC_PairRBTSupply` is the RBT token's **global supply**, not pool-held state. Supply minted
  outside the pool dilutes the index. ATS does **not** take the RBT's mint role at issue.
- A pool at index 0 cannot be bootstrapped by `C_Fuel` (its own `>= 0.1` floor) nor re-KickStarted
  (`index = -1.0` required). Resident can still rise via `XE_UpdateRUR` from fee distribution, which
  carries no index floor — that is the only route out of the state.

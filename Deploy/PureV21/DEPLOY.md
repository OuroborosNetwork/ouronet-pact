# Deploy/PureV21 — DEPLOY CARD

**Everything needed to send this round is in THIS folder.** Ignore the `see Deploy/MANIFEST.md`
and `Steps 1-0 must have run first` lines inside the transaction header — boilerplate the
planner emits for the from-scratch pipeline, which does not apply to an upgrade round.

| | |
|---|---|
| transactions | **1** |
| modules | **1** — `DALOS` |
| interfaces shipped | **0** — `OuronetPolicyV2` and `OuronetDalosV3` are both live and are STRIPPED |
| init steps | **0** |
| table repairs | **0** — and that is a finding, not an omission; see below |
| size | **92,363 bytes**, 91,858 gas |
| verified | gate green, **29,536 assertions** — the baseline was **29,531**; this round's scratch REPL is the +5 |
| live-surface audit | `_livesurface.py --round Deploy/PureV21` → clean against 401 live names |
| post-deploy | `python3 REPL/tools/_registrylive.py --record` |

## Send

| # | bytes | carries |
|---|---|---|
| `01_deploy.pact` | 92,363 | `DALOS` (module only) |

## What it fixes

`DALOS::UR_AccountCreationStoa` binds a **whole-row** read to
`object{DALOS|GasManagementSchema}`. The row it reads — `DALOS|VGD` — was written at genesis,
before the field `account-creation-stoa` existed, so it does not satisfy that schema and **Pact
fails the BINDING before the body runs**. The `contains` guard added on 2026-10-15 protects the
`at`; it is never reached.

On chain the message prints without the schema names — *"Type check failed. The argument is
object but the expected type is object"* — which is why it read as nonsense rather than as a
schema mismatch.

**Reproduced against mainnet, then isolated by bisection:**

```
INFO_DALOS|DeployStandardAccount        -> type check failed
  IGNIS::DALOS|URCi_DeployStandardAccount -> type check failed
    DALOS::UR_AccountCreationStoa         -> type check failed   <- the floor
IGNIS::UC_StoaPrice "acct-standard"     -> 50          (fine)
IGNIS::OI|UDC_FullStoaCosts 2.0         -> object      (fine)
DALOS::UR_NativeToggle / UR_AutoFuel / UR_NativeSpent -> answer  (SAME ROW)
```

The three siblings answer because all three read a **projection** and never type-check the whole
row. That is the whole difference.

## The fix is the annotation, and only the annotation — measured, not reasoned

Such a row is constructible only by upgrading a module over its own table, which a REPL can do.
`REPL/_scratch_dalos_schemadrift_readforms.repl` does exactly that and pins all four candidates:

| form | result |
|---|---|
| typed binding (what shipped) | `Runtime typecheck failure, argument is object, but expected type object{…}` |
| **untyped binding** | **`false`** — the documented default |
| projected read | `Key "b" not found in object: {}` |
| `with-default-read` | `Key "b" not found in object: {"a": true}` — its default covers an absent ROW, never an absent FIELD |

The last line is the claim the function's own `@doc` has carried since October. It was tried
anyway, and it is true.

## Why there is NO table repair in this round

`HOW-DEPLOY-ROUNDS-WORK.md` item 6 says a schema that gains a field needs a migration
transaction. **This round deliberately has none, because the fix removes the need for one** —
and a migration could not have gone first in any case.

The function's `@doc` records a deadlock, and it was re-verified:
`DALOS|C>TOGGLE-ACCOUNT-CREATION-STOA` composes `GOV|DALOS_ADMIN` and then enforces
`(!= toggle (UR_AccountCreationStoa))`. The only public path to the writer runs **through the
broken read**. Fixing the read is what UNBLOCKS the toggle; a backfill would have had to come
first and could not.

## The gate cannot see this fix

It stayed green at **29,531 assertions** across the whole correction, unchanged — the figure moved to 29,536 only when this round's own scratch REPL was added. That is not
reassurance — the REPL harness builds tables fresh from the current schema, so a row that
predates a field **is not constructible** in any DALOS suite. Every suite writes `DALOS|VGD`
complete, the reader answers, and the drift is invisible.

The scratch REPL above is the only executable evidence, which is why it is in the tree. It is
the entire difference between the 29,531 the gate reported through the whole correction and
the 29,536 at the top of this card.

## What is at stake beyond the preview

Today **only the INFO preview is dead.** `TS01-C1` guards the cost call behind
`(not URC_IsNativeGasZero)`, and native STOA collection is OFF on chain (verified:
`URC_IsNativeGasZero` → `true`), so account activation itself works.

The moment that switch is turned ON, the `if` takes the other branch and **account activation
starts failing** — which the October `@doc` predicted in writing and believed it had fixed.

## One tool change travels with this round

`OuronetDalosV3` was **not** in `_deploybundle.py`'s `LIVE_INTERFACES`, so the first generation
of this round re-sent a live interface — `Interface cannot be upgraded: ouronet-ns.OuronetDalosV3`.
It is pinned now, against a hash **verified against the chain**: `describe-module` returns 11,475
bytes and the repo block is byte-identical. That is what the entry asserts.

Consequence, stated because it is easy to miss: `LIVE_INTERFACES` applies to the from-scratch
bundle too, so `Deploy/1_Pure/02_deploy.pact` lost 238 lines. That matches the 23 interfaces
already stripped there, `OuronetPolicyV2` among them — the same file's other interface.

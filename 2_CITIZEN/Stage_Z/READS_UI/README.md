# READS_UI — one read module per UI surface

Owner directive, 2026-09-24. Reference implementation: **`01_RD-HEADER.pact`** — mirror it.

## Roster

Numbered by deploy order. Each carries **one complete interface** (`ReadsXxxV1`), declared inline
above the module. One `implements`, never a chain of additive ones.

| # | module | UI surface | reads it owns |
|---|---|---|---|
| 01 | `RD-HEADER`   | dashboard top strip | **BUILT** — 5 zones + composer |
| 02 | `RD-WALLET`   | dashboard body, asset cards | `0002_Primordials`, `0002_PrimordialsSingle`, `0002_PrimordialsMulti` |
| 03 | `RD-POOLS`    | SWP pages | `0003`, `0004`, `0005`, `0010`, `0011`, `0014`, `0015`, `SWPairCoreRead`, `PoolTypeWord` |
| 04 | `RD-SWAP`     | swap widgets | `0006b_DirectSwap`, `0007b_InverseSwap`, `ReverseSwapOutputAmount` |
| 05 | `RD-TF`       | true-fungible pages | `0008a*`, `0008b*`, `0016`, `0017`, `TrueFungibleAmountPrice` |
| 06 | `RD-OF`       | orto-fungible pages | `0009a*`, `0009b*`, `0018`, `0019`, `0020` |
| 07 | `RD-COLLECT`  | collectables | `0021`..`0026`, `UCx_NonFungibleNonceExistance` |
| 08 | `RD-ACCOUNTS` | selectors, overview, StoicTag | `0027*`, `0028*`, `0029` |
| 09 | `RD-ELITE`    | elite panel, rich list, recovery | `0012`, `0012b`, `0032`, `0035`, `MaxRecoveryAmount` |
| 10 | `RD-LAUNCH`   | StoicPay / ICO | `0013`, `0030` |
| 11 | `RD-PYTHIA`   | Apollo, dual-link, prices | `0031`, `0033`, `0034` |

`UC_TrimDecimalTrailingZeros`, `UC_ConvertPrice`, `UC_FormatIndex`, `UC_FormatTokenAmount`,
`UC_FormatDecimals`, `UC_FormatAccountsShort` are **formatters**, needed by nearly every module.
Copy them per module rather than sharing one. A shared formatter module is a deploy dependency
for eleven modules, and the whole point of this split is that a read module can be redeployed
alone. They are pure, tiny, and have no state to diverge.

## Rules

1. **No tables.** A read module is a projection. Owning nothing is what makes it freely
   redeployable — there is no migration, because there is nothing to move.
2. **No hardcoded ids.** Import `OuronetIdsV1`; resolve through `UC_PickId` (derive first,
   registry as fallback). Gate-enforced by `REPL/tools/_hardcodedids.py`.
3. **No cross-module `keys`** unless deliberate and noted. `(keys OTHER.Table)` is admin-gated in
   transactional mode and works in `/local` only on a node started with `--allowReadsInLocal`.
4. **Per-panel functions, not per-page objects.** `URC_0001_HeaderV3` bound ~40 values in one
   eager `let`; any single failure blanked the whole dashboard and named the innermost form
   rather than the zone that owned it. Split by *independent failure domain*, then compose with
   `try` if a one-call convenience is wanted.
5. **A `try`-wrapped function may not `select` or `keys`.** Pact evaluates a `try` body in
   **read-only mode**, where unbounded database operations are disallowed. So any card that
   reaches a `URH_*` scan cannot go in a `try`-composer — and an untriable card takes the whole
   object down, which is the exact all-or-nothing behaviour the split removes.

   Found by building `RD-WALLET`: with `DPOF::URH_AccountNonces` inline, `URC_Wallet` died on
   *"Operation disallowed in read-only or sys-only mode"* at `06_DPOF.pact:1857` while **every
   card still passed when called individually** — the composer was the only thing that broke,
   which is the hardest shape to diagnose.

   **The rule that follows:** keep scans out of composed cards. Put each in its own `URH_`
   function, correctly prefixed so the cost is legible, and leave it OUT of the composer. A
   caller that wants a scan asks for it. `RD-WALLET::URH_GoldenStoaNonces` is the worked example.

   Worth knowing that `RD-HEADER` survives this only by accident: zone 3 omits the account count
   because `(keys DALOS.DALOS|AccountTable)` is a node-flag dependency. It would ALSO have broken
   the composer, for this reason instead.

6. **Every function must be callable in the fixture.** The two functions that broke on
   2026-09-24 had never once executed in a test, because their hardcoded mainnet ids do not
   exist in a sandbox. A read nothing can call is a read whose staleness is invisible until a
   user finds it.

## Landing a module: the two gate passes

Every `RD-*` module adds assertions, and adding assertions costs **two** gate runs. This is
mechanical, not a fault, and it has cost a cycle three times now — so it is written down rather
than rediscovered per module.

1. Build, exclude the module in `_deploybundle.py`, regenerate `REPL_SUITE_STATS.md`, align
   `Audit/records/REPL-ROUND-REPORT.md`'s **distinct** figure, run the gate.
2. That run *executes* the new assertions. `REPL_SUITE_STATS.md` reads its **executed** figure
   from the **previous green receipt**, so it now lags. Regenerate, align the report's executed
   and positive figures, run the gate again.

Why the check cannot collapse the two: `_docclaims.py` compares the round report against
`REPL_SUITE_STATS.md`, and both derive from the same receipt — so after pass 1 they agree with
each other while both being one run behind the tree. Self-consistency is not currency. Quote
figures from the **second** run.

## Testing posture — agreed, with one carve-out

The owner's position: these are display reads; if the numbers render correctly and the maths is
right, they work. No capability audit, no red-team pass. **That is correct for most of this
folder** — a read module holds no capabilities, writes nothing, and has no authority to escalate.
There is no attack surface to audit, and applying the sovereign-module ceremony here would cost
weeks and find nothing.

**The carve-out is reads that feed a DECISION or a TRANSACTION ARGUMENT.** Those are not display:

| read | what it feeds |
|---|---|
| `0006b_DirectSwap` / `0007b_InverseSwap` | the amount and slippage bounds of a real swap |
| `MaxRecoveryAmount` | how much a user tries to uncoil |
| `URC_0017` / `0019` / `0026` button maps | which operations the UI *offers* — a wrong `true` sends a user into a failing tx |
| any `INFO_` / `URCi_` cost preview | what the user believes an operation will cost |

A wrong number in `RD-HEADER` is a cosmetic bug. A wrong number in `RD-SWAP` is a user signing a
trade against a preview that did not match. These need **arithmetic assertions** — not an audit,
but a test that pins the relationship rather than smoke-testing that a call returned.

`REPL/modules/READS-UI.repl` is where they go. The existing `RDUI-01` block is the shape: drive
both branches of a decision, and assert an identity that a plausible-but-wrong implementation
would fail.

## Why there are no empty skeleton files here

A module that loads and does nothing still needs a deploy-plan entry, a gate exclusion and a
REPL load — three pieces of bookkeeping apiece, carried for however long the shell sits empty.
`01_RD-HEADER.pact` is the template; copy it when a page is actually being wired. The roster
above is the commitment; a stub file would only be a second, weaker copy of it.

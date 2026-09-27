# The `[BAR]` sentinel class — swept, and the ATS case was the only unguarded one

2026-09-27. Written after fixing `UCx_FilterHibernatedAts`, because a defect found by accident
is worth asking whether it has siblings, and "I fixed the one I found" is not an answer.

## The class

Several list-valued readers answer "none" with the **`[BAR]` sentinel** — a one-element list
containing the pipe glyph — rather than with an empty list. `DPTF::UR_RewardToken` and
`UR_RewardBearingToken` both do. A consumer that iterates the result and uses each element as a
**table key** therefore reads `ATS|Pairs` for key `|`, which raises:

```
No value found in table ouronet-ns.ATS_ATS|Pairs for key: |
```

That is not catchable by the caller in practice — the AppReads reader carrying it had no `try` —
so it takes down the whole read rather than degrading one field.

## What the sweep found

Every consumer of the two readers was traced. **One was unguarded; the rest are guarded, and by
the same mechanism.**

| consumer | reads the list into a table key? | guarded |
|---|---|---|
| `ATS::UCx_FilterHibernatedAts` | yes | **NO — this was the defect.** Fixed; drops BAR first |
| `TFT::URCx_NFR-Boolean_RT-RBT` | yes | yes, by its caller |
| `TFT::URCx_CPF_RT` / `_RBT` | yes | yes, by the same caller |
| the `(at 0 …)` sites in OUROBOROS / TFT / LIQUID | takes element 0 as an id | by configuration — see below |

**The guard is `URC_IzRT` / `URC_IzRBT`.** Those predicates ARE the sentinel check: measured on
mainnet, `URC_IzRT` returns `false` exactly when the list is `["|"]`. `XI_CreditPrimaryFee` calls
the RT-RBT helper only under `(if (and rt rbt) …)`, so the helper is unreachable with a sentinel
even though it would raise if called directly — which it does:

```
URCx_CPF_RT-RBT("ELITEAURYN…")  -> No value found in table … for key: |
URC_IzRT("ELITEAURYN…")         -> false      <- so the caller never goes there
```

Worth saying plainly: **calling that helper directly raises, and it is still correct code**,
because its contract is "only call me when both predicates hold". The ATS case differed in
exactly one respect — nothing checked the predicate before the loop.

## The near-miss

The first evidence pointed at a live defect on the transfer fee path, and OURO reproduced it.
It took the guard check to establish that OURO takes the `rt`-only branch (`URC_IzRBT` is false
for it) and never reaches the failing helper. **A direct call to an internal helper proves the
helper unsafe, not the system broken** — the caller is part of the contract, and skipping it
manufactures a bug that does not exist.

## What to carry forward

- A list from an Ouronet reader may be a SENTINEL, not data. `["|"]` means none.
- Before iterating one into table keys, either drop `BAR` or check the matching `URC_Iz*`
  predicate. Both are correct; the predicate is better where one exists, because it is the
  contract's own answer to the same question.
- The `(at 0 …)` sites take element 0 of a possibly-sentinel list and use it as an id. They are
  safe **today** because the specific tokens they name (OURO, wrapped STOA) have real lists. That
  is a dependency on configuration rather than on a check, and it is the place this class would
  reappear.

## Cross-references

- `Deploy/PureV2/22_deploy.pact` — the ATS module upgrade carrying the fix
- `REPL/modules/STAGE-Z.repl` `<<STAGEZ-13>>` — the regression assertions
- `docs/CHAPTER-INTEGRATION/04-errors.md` §2d — the same rule, for client authors

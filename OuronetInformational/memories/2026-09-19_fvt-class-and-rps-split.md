# FVT class rule + the RPS/FVT split remnants  (2026-09-19)

## 1. Owner ruling on FVT classes

    fvt-class 0  Farm      <- LPs (TF native/frozen, OF sleeping)   = score-class 0
    fvt-class 1  Vault     <- TF and OF                             = score-class 1, 2
    fvt-class 2  Treasury  <- SFTs and NFTs (collectables)          = score-class 3, 4

`URC_ScoreClassMatchesFvtClass` (05_FVT.pact:1559) is WRONG: it maps vault -> {1,3,4} and
treasury -> {2}, i.e. it puts collectables in the vault and ortofungibles in the treasury.
`URC_TripletCategoryMatchesFvtClass` (02_SCORE.pact:2049) matches the ruling.

## 2. Applying it — measured cascade (patch: 2026-09-19_fvt-class-correction.patch)

Each step below was found by running, not by reading:

1. Fix the rule -> `TX-BOOT-09` aborts. AQP-BOOT `C_Step8` issues the four entities NAMED
   Treasury at fvt-class **1**; Step9 links SF/NF subsidiary scores to them, which only ever
   passed because the broken rule admitted 3/4 at class 1. Fixed: Step8 now issues class **2**.
2. -> `[6.4]_AQP-EXHAUSTIVE-COLLECT.repl:36,107` abort. Two fixture `enforce`s hard-assert
   "CodingDivisionTreasury must be vault class 1". Fixed to class 2.
3. -> `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl:3829` aborts. `TX-INFO-GT-FVTSEADD` borrows
   `CodingDivisionTreasury` as the target for a **TrueFungible** score. A TF score cannot enter
   a treasury, so the probe needs its own class-1 vault.
4. -> STOA managed-cap exhaustion. UNRESOLVED at time of writing: the reported failure is at
   :3740, which is in the PRECEDING transaction, so the cause is not simply the added issuance.
   Do not paper over this by widening the allowance until that is understood.

Reverted to green rather than left half-applied: a partially-applied sovereign admission rule is
worse than either end state.

## 3. The consequence worth deciding before re-applying

After the correction the production asset tree has **no Vault at all** — `C_Step8` yields one
Farm (class 0) and four Treasuries (class 2). Class-1 vaults come only from
`C_IssueGenericEarningVault` (e.g. the Stoicism vault, Deploy/3_Assets/13). Several fixtures were
using the mis-classed "treasuries" as vaults, which is why the cascade is wider than four lines.

## 4. RPS / FVT split remnants (separate finding, same session)

The #75 split of FVT into FVT + RPS left duplicates. Measured:

* **11 schemas declared in BOTH** modules. All 11 are **field-for-field IDENTICAL today** — so no
  live bug, but nothing enforces that and a one-sided edit would not fail to load.
* **RPS owns the tables** for the contested rows (`FVT|T|RPS|Global`/`Member`/`User`/`Stream`,
  `FVT|T|RewardAggregate`, `FVT|T|ScoreEntityLink`). FVT owns only `FVT|T`, `FVT|T|VacateFreeze`,
  `FVT|T|SweepProgress`.
* FVT keeps its copies only to TYPE its own `UDC_` constructors. Of those, **six are duplicated**
  in RPS and **four are DEAD** — zero callers anywhere in the tree, and not declared on the
  interface, so removable:
      UDC_FVT|RPS|Member   (05_FVT.pact:1379)
      UDC_FVT|RPS|Stream   (05_FVT.pact:1360)
      UDC_FVT|RPS|User     (05_FVT.pact:1396)
      UDC_FVT|SettleScorePlan (05_FVT.pact:1414)
  Live in FVT: `UDC_FVT|RPS|Global` (2 calls), `UDC_FVT|ScoreEntityLink` (2),
  `UDC_FVT|RewardAggregate` (3 — and this one is NOT duplicated in RPS).

# AppReads — read modules, per app, per display entity

Owner directive, 2026-09-24. Replaces the flat `READS_UI/` layout.

```
AppReads/
  OuronetUI/        OURO-UI-<N>      the wallet / DeFi front end
  Pythia/           PYTH-UI-<N>      the oracle console
  Aletheia/         ALET-UI-<N>      Stage 3, not started
  Caduceus/         CADU-UI-<N>      the bridge, Stage 3
  OuronetExplorer/  OURO-EX-<N>      no live callers yet
  StoaExplorer/     STOA-EX-<N>      not started
```

**One folder per app; one module per display entity within it.** An app's reads are its own —
two apps showing the same number still want different shapes, and coupling them means a change
for one is a redeploy for both.

## Why numbered module names rather than descriptive ones

`OURO-UI-ONE` rather than `RD-HEADER`. The number is the **entity's slot**, fixed at assignment
and never reused, so a module's name never has to change when its contents grow. A descriptive
name invites renaming, and a deployed Pact module cannot be renamed — only superseded.

The entity a number means is recorded in the app's own README, which is the thing that can be
edited.

## OuronetUI entity map

Slots are permanent. A new entity takes the next free number; it does not renumber its
neighbours.

| # | module | entity | state |
|---:|---|---|---|
| 1 | `OURO-UI-ONE` | Header | **built** |
| 2 | `OURO-UI-TWO` | Dashboard | pending — `READS_UI/02_RD-WALLET` migrates here |
| 3 | `OURO-UI-THREE` | EliteAccount | not started |
| 4 | `OURO-UI-FOUR` | StoaIco | not started |
| 5 | `OURO-UI-FIVE` | CrossChain | not started |
| 6 | `OURO-UI-SIX` | ExecuteCode | not started |
| 7 | `OURO-UI-SEVEN` | Codex | not started |
| 8 | `OURO-UI-EIGHT` | TrueFungible | not started |
| 9 | `OURO-UI-NINE` | OrtoFungibles | not started |
| 10 | `OURO-UI-TEN` | Collectables | not started |
| 11 | `OURO-UI-ELEVEN` | AtsPairs | **blocked — no UI** |
| 12 | `OURO-UI-TWELVE` | SwpPairs | pending — `READS_UI/03_RD-POOLS` + `04_RD-SWAP` migrate here |
| 13 | `OURO-UI-THIRTEEN` | EarningPools | not started |
| 14 | `OURO-UI-FOURTEEN` | Launchpad | not started |
| 15 | `OURO-UI-FIFTEEN` | StoaLiquidStaking | not started |
| 16 | `OURO-UI-SIXTEEN` | NFTMarketPlace | Stage 3 — does not exist |
| 17 | `OURO-UI-SEVENTEEN` | LendingPlatform | Stage 3 — does not exist |

### Slot 11 is blocked on purpose

`AtsPairs` has a UI — `autostake-pairs/`, three files, 354 lines — and it reads the chain
**zero times**. No `pactRead`, no `pactQueryCache`, no `DPL-UR` call; it renders hardcoded
strings including the literal `'Auryndex-O136CBn22ncY'`. It is a mockup.

**Reads are PULLED by a UI, not PUSHED by a contract.** Every module built so far was ported
from what the UI demonstrably calls. For a surface that does not exist there is nothing to
port, and inventing reads means guessing a shape the eventual design will contradict — which is
exactly how `URC_0001_HeaderV3` became one 70-key object in a single eager `let`.

So slot 11 waits for the panel, and the module then falls out of what the panel displays. The
same holds for 13, 16 and 17.

## Rules

Unchanged from `READS_UI/README.md`, which remains the normative reference until the last
module migrates out of it: no tables, no hardcoded ids, no scan inside a `try`, scans get their
own `URH_`, helper names are tree-global to `_callarity.py`, and every function must be callable
in the fixture.

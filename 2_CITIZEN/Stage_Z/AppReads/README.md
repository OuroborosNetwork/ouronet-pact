# AppReads — read modules, per app, per display entity

Owner directive, 2026-09-24. Replaces the flat `READS_UI/` layout.

```
AppReads/
  OuronetUI/        O-UI-<N>      the wallet / DeFi front end
  Pythia/           P-UI-<N>      the oracle console
  Aletheia/         A-UI-<N>      Stage 3, not started
  Caduceus/         C-UI-<N>      the bridge, Stage 3
  OuronetExplorer/  O-EX-<N>      no live callers yet
  StoaExplorer/     S-EX-<N>      not started
```

**One folder per app; one module per display entity within it.** An app's reads are its own —
two apps showing the same number still want different shapes, and coupling them means a change
for one is a redeploy for both.

## Why numbered module names rather than descriptive ones

`O-UI-ONE` rather than `RD-HEADER`. The number is the **entity's slot**, fixed at assignment
and never reused, so a module's name never has to change when its contents grow. A descriptive
name invites renaming, and a deployed Pact module cannot be renamed — only superseded.

The entity a number means is recorded in the app's own README, which is the thing that can be
edited.

## OuronetUI entity map

Slots are permanent. A new entity takes the next free number; it does not renumber its
neighbours.

| # | module | entity | state |
|---:|---|---|---|
| 1 | `O-UI-ONE` | Header | **built** |
| 2 | `O-UI-TWO` | Dashboard | **built** |
| 3 | `O-UI-THREE` | EliteAccount | **built** — account panel, rich list, recovery panel (iface V2) |
| 4 | `O-UI-FOUR` | StoaIco | **built** — fixes a div-by-zero `try` cannot catch |
| 5 | `O-UI-FIVE` | CrossChain | not started |
| 6 | `O-UI-SIX` | ExecuteCode | not started |
| 7 | `O-UI-SEVEN` | Codex | **built** — selectors; parity-asserted against DPL-UR |
| 8 | `O-UI-EIGHT` | TrueFungible | **built** — per-row degradation |
| 9 | `O-UI-NINE` | OrtoFungibles | **built** — valuation split out from a `select` |
| 10 | `O-UI-TEN` | Collectables | **built** — fixes an unreachable Wipe button |
| 11 | `O-UI-ELEVEN` | AtsPairs | **blocked — no UI** |
| 12 | `O-UI-TWELVE` | SwpPairs | **built** — pools + swap previews, two testing postures in one module |
| 13 | `O-UI-THIRTEEN` | EarningPools | **slice 1 built** — anchors, client + manager. Scores/pools/aggregators pending |
| 14 | `O-UI-FOURTEEN` | Launchpad | not started |
| 15 | `O-UI-FIFTEEN` | StoaLiquidStaking | not started |
| 16 | `O-UI-SIXTEEN` | NFTMarketPlace | Stage 3 — does not exist |
| 17 | `O-UI-SEVENTEEN` | LendingPlatform | Stage 3 — does not exist |

### What is left, and why

Slots **5** (CrossChain), **6** (ExecuteCode) and **13** (EarningPools) have no DPL-UR reads
behind them — no `URC_` in DPL-UR maps to those pages, so there is nothing to port. Slots 14–17
are Stage 3 or unbuilt. Slot 11 is a mockup; see below.

That leaves the migration's read surface **complete for every OuronetUI page that reads the
chain**. What remains in DPL-UR after these nine modules are wired are the three PYTHIA reads
(see [`Pythia/README.md`](Pythia/README.md) — nothing calls them) and six dead references the
UI names but never reaches: `URC_0001_Header`, `URC_0006_Swap`, `URC_0007_InverseSwap`,
`URC_0008_CappedInverse`, `URC_0011_RecoveryPrimordial`, `URC_0012_HibernateFee`. Those get
deleted from `ouronet-core`, not ported.

**CORRECTED 2026-09-26 — `URC_0012_HibernateFee` was NOT dead, and calling it dead is how it
stayed broken for another day.** `getHibernateFee` is reached from `BrumateModal` and
`ConstrictModal`, both imported by `AssetItem` ← `AccountCards` ← `dashboard.tsx`, which is a
live route. It is the fee figure a user reads before locking WSTOA or SSTOA.

Being unreached was never the point about that one. All six name functions that **have never
existed in any Pact source in this repo** — `git log -S` over the whole history finds each zero
times — so every call was a resolution error. The *other* five happen to sit in code nobody
reaches; this one sat behind a `catch` that returned a hardcode, which rendered
indistinguishably from a chain read and was numerically correct for the parameters mainnet
happens to hold. So "never reaches" was a claim about the wrong property, and it was checked the
wrong way: by grep, which cannot tell a live read from dead code, which is the same failure this
folder's own legacy-read census was built to avoid.

`getHibernateFee` now reads `ATS::UR_Hibernate` / `UR_PeakHibernatePromile` /
`UR_HibernateDecay` / `UR_Royalty` directly — no AppReads module needed, because those are
ordinary `UR_` readers on a deployed core module. **The remaining five stand as written**, and
each is now a reasoned entry in `check-chain-symbols.py`'s accept-list rather than a line in
prose, so a sixth cannot join them silently.

**What distinguishes the two cases is REACHABILITY, and this repo can only guess at it.** The
authority is OuronetUI's route table (`src/routes/index.tsx`, 49 `<Route>` entries): `poolDetail
.tsx` has none, which is what makes `URC_0006/7/8` genuinely dead, and `dashboard.tsx` has one,
which is what makes the hibernation fee live. A claim about liveness written in this repo is a
claim about a file in another one.

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

## State, 2026-09-25

**All nine modules are on mainnet** (PureV2/01–12) and **all 47 reads are wired** through
OuronetUI's transport redirect. Two files remain:

| file | what | why it is not optional |
|---|---|---|
| `PureV2/13` | O-UI-ONE + O-UI-TWO + O-UI-THREE + O-UI-TWELVE upgrades | two display defects: five Unicode glyphs flattened to ASCII (including `Ξ₳`, so the header reads "Total Xi-A"), and a `<0.0001` sentinel that has never fired in any module |
| `PureV2/14` | DPL-UR → archive mode, 3,025 lines to 158 | deploy **last**, and only after every page has been checked: it deletes every read, which is what the redirect's fallback currently falls back *to* |

DPL-UR ends as a governance capability and two constants. The first draft of `14` kept seven
reads by dependency closure; counting call sites showed the closure was keeping a cluster of
dead code alive by citation — every one had zero callers anywhere in the workspace. Two were
already superseded (`O-UI-TWO::URC_Prices` over `URC_PrimordialPrices`, `UC_Amount` over
`UC_FormatTokenAmount`) and two were being kept only to preserve a test, which inverts the
dependency: `STAGEZ-08` now asserts the STOA conservation invariant against
`U|DALOS::UC_TenTwentyThirtyFourtySplit`, the arithmetic itself, rather than a display wrapper
over it.

## Deploying

`Deploy/PureV2/` holds the hand-deploy round; the owner sends one file at a time and the wiring
follows each. **The body of every live file there is GENERATED** from these sources by
`REPL/tools/_purev2.py` and diffed by the gate — only the prose header above the marker is
hand-written. That exists because a hand-copied deploy file drifted from its module and the
drift reached mainnet; see RULES.md rule 10.

## Rules

In [`RULES.md`](RULES.md) — normative for every app, ten of them, each earned by something
that went wrong: no tables, no hardcoded ids, no scan inside a `try`, scans get their own
`URH_`, helper names are tree-global to `_callarity.py`, every function callable in the
fixture, formatters copied not shared, and never edit the tree while the gate runs.

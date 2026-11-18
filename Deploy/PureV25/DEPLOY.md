# Deploy/PureV25 — DEPLOY CARD

**Everything needed to send this round is in THIS folder.** Ignore the `see Deploy/MANIFEST.md`
and `Steps 1-0 must have run first` lines inside the transaction headers — boilerplate the
planner emits for the from-scratch pipeline. There are no preceding steps and no init step.

| | |
|---|---|
| transactions | **2** — send `01` before `02` |
| modules | **5** — `AQP-POOL` · `TS02-C1` · `TS02-C2` · `DEMIPAD-SNAKES` · `DEMIPAD-CUSTODIANS` |
| interfaces shipped | **1** — `TalosStageTwo_ClientOneV5` (new; V1–V4 confirmed live by `describe-module`) |
| init steps | **0** |
| tables created | **0** — every `create-table` is commented by upgrade mode and NONE needs uncommenting |
| size | 01: **246,197 B** · 02: **202,250 B** (cap 320,000) |
| gas | 01: **242,927** · 02: **235,433** — 478,360 total, each ~12% of a block |
| verified | gate green, **97 entrypoints, 30,880 assertions** |
| post-deploy | `_registrylive.py --probe` → `--record` → regenerate registry → **publish `@ouronet/talos-registry`** |

## Order is not cosmetic

`TS02-C1` calls `ref-AQP::UEV_AQP|NoLiveStakeOfAsset`, which is **module-only** — it is not
declared in `AcquisitionPoolsV3` (deliberately: declaring it would bump that interface and
cascade through every AQP consumer, to publish a validator only Talos calls). An undeclared
modref member resolves at CALL time, not load time, so `02` will deploy happily against the old
AQP-POOL and then **fail at runtime on the first share issuance**. Send `01` first.

## What it fixes

A score's base is an **accumulated signed delta**. The class-3 equity leg weighs a position at
the **live** share value — `URCx_EquityShareRawWeight` reads nonce-1 supply at call time — and
records nothing at stake time. So the two legs of a round trip can be priced at different scales.

Measured on the DHCompany fixture: stake 5 tier-6 E|DH packages at m=1 (unit 2,000 shares, base
10,000) → issue 1,000,000 shares (unit becomes 4,000) → full unstake subtracts 20,000 against the
10,000 the stake added → **base −10,000, and the score's global total with it.**

PureV23 is what made the input movable. Before `C_IssueShares` existed the share count could not
change, and the weight function's own `@doc` leaned on exactly that.

**The identical defect was already caught once, one input over.** `SCR|C>UPDATE-MULTIPLIERS`
carries an emptiness gate whose doc states the arithmetic outright. Share count was a second
input to the same formula that never got the same gate.

## The two halves

**A — the gate.** `URH_AQP|DpsfStakedPools` scans the DPSF tracker BY ASSET (`dpsf-id` is a
Select Key, so one `select` answers for every pool at once) and `UEV_AQP|NoLiveStakeOfAsset`
refuses while anything is staked, **naming the blocking pools** — a creator told only "something
is staked" cannot act on it. Both share doors call it, which makes them `CC_` under StoicSyntax
19.3 and is why the interface bumped.

**B — the repair.** `URH_AQP|ScoreTargetBaseForBeneficiary` became a dispatcher on score class.
The class-0/1 arithmetic is **byte-identical**; the new Sf route CALLS
`URC_SignedBaseDeltaForDpsfStake` rather than reimplementing it. Fence relaxed to `[0 1 3]`;
classes 2 and 4 stay out, each needing its own target and its own tests.

**Why B is needed at all:** `URC_U-SCR|UserScoreDebStale` recomputes the DERIVED layers from the
STORED base, so a base error moves neither side of its comparison and the row reads FRESH.
Boosters and DEB only ever stale the derived layers. Asserted, not assumed —
`modules/EQUITY-SHARE-STALENESS.repl` TX-EQSS-04 pins `deb-stale = false` on a base proven wrong.

## Two consequences to expect

**The two entrypoints are RENAMED.** `DPSF|C_IssueShares` → `DPSF|CC_IssueShares`, and likewise
for retire. `Deploy/TALOS-ABI.json` already carries them (surface `1bf4305900ab408f`), but
`Deploy/OURONET-REGISTRY.json` is generated from the CHAIN and still describes the old surface —
which is why `_pkgsync.py` reads clean right now against a registry that disagrees with the
sources. **Until the npm package is published, any client calling `DPSF|C_IssueShares` gets
`no such member`**, which `try` cannot catch and the UI renders as missing data.

**One published price changed, and it was not a price change.** `AQP-POOL|C_AddScore` moved from
COMPLEX `≥ 243` to exact `243`. `SCALES` in `_ignis_price_sheet.py` runs over `billing_text`,
which deliberately keeps `@doc`/comment prose, and it carries `per-nonce` as a LITERAL PHRASE;
the freeze-site comment contained "per-nonce TABLE VALUES". Rewriting that comment dropped the
phrase. Checked before accepting: `URCi_AddScore` builds one cumulator from a single fixed
`UC_IgnisPrice` with no `length`, `fold` or item count anywhere, so **243 is the true price and
`≥ 243` was the artefact**. Recorded in `IGNIS-PRICING.md`.

## Post-deploy, in order

```bash
python3 REPL/tools/_registrylive.py --probe    # regenerate the registry FROM the chain
python3 REPL/tools/_registrylive.py --record   # stamp "confirmed against mainnet"
python3 REPL/tools/_registry.py --check        # expect the new surface hash, 447 entrypoints
# then publish @ouronet/talos-registry, and only then re-embed in OuronetUI
```

`--probe` regenerates; `--record` only confirms. Running `--record` alone stamps a date on the
OLD artefact.

## Still open, deliberately not in this round

- **SF score definitions are the same hole, ungated.**
  `AQP-SCR|C_IssueSemiFungibleScoreDefinition` re-weighs a nonce through `WW_SFScore`, an UPSERT
  with no emptiness check, re-valuing a live position exactly the way a share issuance used to.
  TX-EQSS-04 *uses* this to create staleness, so it is a running test rather than a note.
- **DPNF model 0/1 definitions** read `DPDC-S::URC_N|Score` and trait tables live — same class.
- **Class 2 (DPOF)** belongs to the sleeping-token custody work.
- **The gate binds the Talos path**, which is the only gas-funded client path. A module holding a
  registered IMP guard on EQUITY could still reach `EQUITY::C_IssueShares` directly. Closing that
  needs state in EQUITY, which the owner ruling forbids — so it stays a governance property: do
  not register an IMP guard on EQUITY without re-reading this.

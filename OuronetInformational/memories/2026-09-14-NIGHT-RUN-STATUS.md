# NIGHT RUN — STATE, AND WHAT IS LEFT BEFORE RED TEAMING

Read this first. Detail and reasoning are in `2026-09-14-HANDOFF-START-HERE.md`.

## GATE

**GREEN — 20,142 assertions** (16,315 positive / 3,827 negative), 76 entrypoints, ~333s.
Started the night at 19,722. Every figure below was verified against a full green gate, and the
gate was re-run after every source change.

## 17 PREVIEW/CHARGE DEFECTS FOUND AND FIXED

Every one was a client-facing lie about price. Every one is now pinned by a MEASURED test — the
quote read before the op, the charge counted across it. Every fix is in SOURCE, not in a test.

| preview | quoted | really charges | pinned by |
|---|---|---|---|
| `INFO_EQUITY\|IssueCompany` | 0 STOA | **918 STOA** | `modules/EQUITY.repl <<EQ-I1>>` |
| `INFO_SWP\|ToggleFeeLock` | 0 STOA | **432.5 STOA** | `modules/SWP.repl <<SWP-I1>>` |
| `INFO_ATS\|ToggleParameterLock` | 0 STOA | **500 STOA** | `modules/ATS.repl <<ATS-I2>>` |
| `INFO_VST\|CreateFrozenLink` + 4 siblings | 0 STOA | **76.5 STOA** each | `modules/VST.repl <<VST-I1>>` |
| `INFO_AQP-FVT\|Inject` + 3 siblings | 276.13 IGNIS | **276.66 IGNIS** | `[6.5.1] <<TX-INFO-GT-INJECT>>` |
| `INFO_SWP\|IssueStandard` + 2 siblings | 600 STOA | **500 STOA** | `[6.2+3] <<SWP-ISSUE-INFO>>` |
| `SNAKES.INFO_Acquire` + `CUSTODIANS.INFO_Acquire` | 89.002 IGNIS | **89.004 IGNIS** | `launchpad-groundtruth.repl` |

Three distinct failure modes, worth keeping separate in your head:
- **a literal zero** for a currency the op really charges (1-8) — the loudest, and the one
  `REPL/_infostoa.py` now detects automatically;
- **a missing LEG** in a multi-part cost (9-12, 16-17) — the preview sums some of what the exec
  collects. Found by asking which sibling is not shaped like the others;
- **the wrong SOURCE CONSTANT** (13-15) — two execution paths with two prices, one preview.

Source files changed: `11_EQUITY+`, `01_INFO-TWO`, `15_SWP`, `08_ATS`, `11_VST`, `02_INFO-ONE+`,
`04_RPS`, `09_AQP-INFO`, `16_SWPI`, `02_Snakes`, `03_Custodians`. Six new read-only price twins were
added so exec and preview read ONE source and cannot drift again:
`SWP::URCi_ToggleFeeLockStoa`, `ATS::URCi_ToggleParameterLockStoa`,
`VST::URCi_CreateSpecial{True,Orto}FungibleLinkStoa`, `RPS::URCi_InjectFull`, `SWPI::URCi_IssueStoa`.

## TWO OPS THAT HAD NEVER SUCCEEDED ANYWHERE NOW DO

Per the owner's ruling *"if an op exec counterpart is missing it has to be added"*:
- `VST|C_Slumber` — `modules/VST.repl <<VST-I2>>`. Its only historical caller had been calling it
  BY MISTAKE; the repair removed that caller and never wrote a correct one.
- `DPTF|C_ToggleFeeExemptionRole` — `modules/DPTF.repl <<DPTF-I1>>`. Three authors read an
  intersection of two guards as a contradiction and concluded "unreachable". The fixture (`KC.BJ`)
  was in the boot chain the whole time.

## ONE THING NEEDS YOUR DECISION — I DID NOT FIX IT

**The special-link IGNIS model.** Measured, pinned as behaviour, deliberately not "repaired":

    INFO_VST|CreateFrozenLink   quoted 719.74 IGNIS   charged 601.02    (raw 1358.0 vs 1134.0)
    INFO_SWP|EnableFrozenLP     quoted 719.74         charged 601.02
    INFO_SWP|EnableSleepingLP   quoted 721.86         charged 599.96

STOA is exact on all three (76.5 == 76.5); only IGNIS disagrees.

`VST::URCi_CreateSpecial*FungibleLink` adds a `vst-link` deterrence (279.0 raw, ~$2.50) that
`XI_CreateSpecial*FungibleLink` **never charges**, and under-models two other legs (9.0 vs 64.0). The
two sides disagree in both directions, so it is not a transcription slip. Either:

* **(a)** the preview invents a fee the op was never meant to carry → fix the preview; or
* **(b)** the exec forgot to collect a deterrence that was designed in → **a revenue bug**, and every
  special link ever created has been under-charged.

All 17 defects I did fix had an unambiguous answer (the exec is the truth). Here the exec may be the
broken side, so guessing would either under-price the op permanently or silently raise its price.

**One reader pair, seven previews**: `INFO_VST|Create{Frozen,Reservation,Vesting,Sleeping,
Hibernating}Link` + `INFO_SWP|Enable{Frozen,Sleeping}LP`. Resolving it fixes all seven at once.
Pinned at `modules/VST.repl <<VST-I1>>` and `modules/SWP.repl <<SWP-I8>>`/`<<SWP-I9>>`.

## `INFO_` COVERAGE

**160 of 425 previews (38%) are now measured against a real charge** (was effectively none).
Complete families: PYTHIA 4/4, CODEX 4/4. Substantial: DPTF 22/30, AQP-POOL 18/25, DPSF 18/65,
ATS 14/42, DPOF 11/24, SWP 10/38, VST 10/29, DPNF 10/61, DEMIPAD 8/10, DALOS 5/9, launchpad sales 4.

**DPNF was 0 of 61 and is now open** — ten blocks, all green on the first run, covering the shared
`INFO_DPDC-MNG|Simple` / `INFO_DPDC-R|Toggle` / `INFO_DPDC-N|Field` hubs that most of the remaining
51 route through. The marginal cost of the rest of that family is now low.

The AQP set is the most valuable, because those previews are RECONSTRUCTIONS rather than shared
readers — `URCi_CollectFull` sums three independently-derived sources and matched to the decimal
(295.74), and `URCi_SyncTrueFungibleAnchorsFull` re-derives three legs including a per-anchor term,
measured against a deliberately MULTI-anchor asset (39.75, 2 anchors). Both were previously unproven
claims; both are now facts.

## NEW TOOL

`REPL/_infostoa.py` — finds previews claiming a currency is free when the exec tree collects it.
**Mutation-tested**: it reports 0 today, and that 0 is trustworthy because reintroducing a known
defect makes it name the defect. It reported "0 to review" twice while blind; see the handoff for
both bugs. Report-only, not a gate: an escrow or a purchase price is not a protocol fee.

## WHAT REMAINS BEFORE RED TEAMING

1. **`INFO_` coverage, ~265 previews left.** The method is proven and mechanical — generate blocks
   from a template, one `begin-tx`/`rollback-tx` per op, always with a `(> real 0.0)` guard.
   Fixture tables for SWP/ATS/AQP/DPDC/DPOF/DPTF/VST/DALOS/LAUNCHPAD are in the handoff.
   Known gaps with NO fixture (stated, not to be invented): all 11 `INFO_AQP-DSA|*`, both
   `INFO_AQP-MTX|*`, `INFO_SWP|Issue*Pool` (3-step defpact), `INFO_SWP|Firestarter`,
   `INFO_ATS|WithdrawRoyalties`, `INFO_ATS|Curl`/`Brumate`/`VestedCurl`.
2. **The remaining `URCi_` / `UEV_` / `A_` / `C_` coverage families** from the phase-5 plan.
3. **Phase 6** — assembly + REPL folder reorganisation (owner said LAST), then a final full
   `ZALL.repl` run as the red-team baseline.

## RANKED LEADS STILL OPEN (highest value first)

DONE since this list was written: `SyncTrueFungibleAnchors` (39.75, multi-anchor), `AQP-FVT|Collect`
(295.74, exact), `ATS|ColdRecovery` and `ATS|Cull` (composers, both exact), `AQP-POOL|AbortVacate`
(split proof now closed in one file), `FinalizeVacate`, `EnablePoolStake`/`DisablePoolStake` (the
shared constant checked from BOTH sides).

1. `INFO_SWP|EnableFrozenLP` / `EnableSleepingLP` — two independently-derived conditionals that must
   agree, charging through a VST `XI_`. **One-shot and irreversible; only two pools still eligible**,
   so this must be written carefully and cannot be iterated on.
2. `INFO_ATS|Syphon` — the last untested composer. Needs `C_Control` to re-enable syphoning first
   (that setup op is IGNIS-only, so it cannot pollute the figure).
3. `INFO_AQP-POOL|SyncSemiFungibleAnchors` / `SyncNonFungibleAnchors` — the TF twin is now proven, and
   both of these route through a DIFFERENT reader (`URCi_SyncCollectableAnchorsFull`) which the TF
   measurement says nothing about.
4. Eight AQP previews that abort on missing state and are not yet pinned as findings, unlike their
   six already-pinned siblings.
5. `INFO_ATS|Issue` — the only preview in either family that hands a raw decimal to
   `OI|UDC_DynamicIgnisCost` without passing it through `OI|UC_IfpFromOutputCumulator`, so the
   discount is applied to a number that never went through the cumulator machinery.

## OPERATIONAL NOTES THAT COST TIME TONIGHT

- **Never edit source while the gate runs.** Two runs failed on half-written files and both looked
  like real regressions.
- **Read modref interface versions out of the harness.** There is no pattern
  (`...ClientOneV2`, `...ClientThreeV4`, `...ClientFourV8`).
- **Anchor edits on function BODIES, not names.** Interfaces are co-located in the same file, so
  `(defun X:` matches the stub first. I corrupted five unrelated previews that way; it was caught
  only because the inserted text happened not to compile.


---

# SESSION 2 — continuation (same day)

## WHAT WAS ADDED

**~95 new preview measurements**, all green, spread across the families the first session left open:

| file | blocks | notes |
|---|---|---|
| `modules/DPDC.repl` | 44 (`DPNF-I11..I35`, `DPDC-I20..I38`) | the whole DPNF/DPSF nonce-field, transfer, wipe and set surface |
| `modules/VST.repl` | 14 (`VST-I9..I22`) | vest/reserve/sleep/hibernate + all four repurpose families |
| `modules/ATS.repl` | 12 (`ATS-I12..I23`) | incl. `Syphon`, the LAST untested ATS composer |
| `modules/DPOF.repl` | 9 (`DPOF-I12..I20`) | transmit + the full wipe family |
| `modules/SWP.repl` | 5 (`SWP-I10..I14`) | branding, fee targets, fuel, add-liquidity |
| `modules/LIQUID.repl` | 3 (`LQD-I2..I4`) | unwrap + both UrStoa directions |
| `modules/OUROBOROS.repl` | 2 (`ORBR-I1..I2`) | the three ZERO-quoted conversion ops |
| `Stage_02/[6.5.1]` | 2 | streamed inject + the COLLECTABLE anchor-sync reader |

## TWO CLAIMS THAT WERE ASSUMED AND ARE NOW FACTS

- **`INFO_AQP-FVT|InjectStream`** — the custody-transfer defect was found on `Inject` and FIXED on all
  four inject previews, but only `Inject` was ever weighed. The streamed path routes through
  `XIv_FvtAddStream`, not `XI_FvtInjectCore`, so it shared a shape but not a code path. Now measured:
  **268.18 = 268.18**.
- **`URCi_SyncCollectableAnchorsFull`** — a SECOND hand-written reconstruction, distinct from the TF
  one proven earlier. **49.29 = 49.29** against a live-anchor asset.

## THE ONE NEW FINDING — and it is NOT a preview defect

`<<SWP-I14>>` `INFO_SWP|AddLiquidity`. A plain balance-delta reads **quoted 1118.83, charged
1318.83** and looks exactly like the missing-leg defect found four times in session 1. It is not.
`URC_STOA-PID|CLAD` returns `mt-ids`/`mt-amt` — the tokens the account sends IN — and on an
asymmetric addition that list carries the IGNIS token itself:

    mt-ids = [GAS DLK OURO DWK]      mt-amt = [200.0 10.0 10.0 10.0]

The 200 is the asymmetry tax and it leaves as **principal** via `XI_AddLiqSendAndMint`, not as gas via
`IGNIS::C_Collect`. It lands in the same balance the meter reads, so it counterfeits a defect.
Subtracting the declared IGNIS leg gives **1118.83 = 1118.83 exactly** — the gas preview is correct.

**The part that IS for the owner:** nothing in `ClientInfo` surfaces that 200. A client who funds
exactly `ignis-need` runs out of IGNIS. `URCi_AddStandardLiquidity`'s own @doc says "the CLAD
**perfect**-ignis-fee", so the omission is deliberate — it is the client-facing consequence that is
not documented. Same decision shape as the `VST::URCi_CreateSpecial*Link` deterrence question.
Pinned as behaviour, not silently "fixed".

## FIXTURE FACTS LEARNED (cost real time; write them down)

- **`INFO_DPSF|WipeHeavy` / `INFO_DPNF|WipeHeavy` are `(patron ACCOUNT id)`** while `WipeNonce` and
  friends are `(patron ID account)`. Both are strings, so the wrong order does not fail on arity — it
  dies on a row-not-found deep inside `URCi_WipeCumulator`.
- **`INFO_DPNF|Create` has no `amount` argument** (an NFT nonce is always supply 1); the SFT twin does.
- **`INFO_DPNF|UpdatePendingBranding` takes 6 args, not 2** — unlike the ATS and SWP twins, which
  really are 2-vs-6. Passing 2 partially applies and dies inside `at` with a type error.
- **`entity-pos` is 1-BASED** (`UEV_PositionalVariable` checks `(enumerate 1 positions)`).
- **`VST|C>RESERVE` wants a STANDARD account; `VST|C>UNRESERVE` wants a SMART one.** The account that
  can reserve can never unreserve its own position. `KC.BJ` (key `PK_BJ`) is the only user-deployed
  smart account in the boot chain.
- **`C_Unvest` and `C_Unsleep` need MATURITY**, so those blocks advance `env-chain-data` and put it
  back — `rollback-tx` does NOT undo the clock.
- **`modules/LIQUID.repl` leaves GAP ON and committed** (LQD-03 needs it), so every later client op is
  refused by `P|TS`; and LQD-03 MIGRATED the escrow empty, so an unwrap must re-wrap first.
- **`ATS|C>TOGGLE-ELITE` wants 7 cold-recovery positions AND cold recovery OFF** — no pair satisfies
  both, so the block switches Auryndex's off first.
- **`ATS|C_KickStart` has NO fixture at EOF** — `TestKickPair` has already been kickstarted (index is
  no longer -1). Stated, not invented; needs a fresh `ATS|C_Issue` to become testable.

## STILL OPEN

- `INFO_SWP|*` swap family (Single/Multi/Smart ×6, incl. the documented `C_`/`CC_` name INVERSION),
  `RemoveLiquidity`, `UpgradeBranding`/`UpgradeBrandingLPs` (STOA), the four Add*Liquidity variants.
- `INFO_ATS|Issue` / `UpgradeBranding` / `HOT-RBT|*` (STOA caps), `Redeem`/`Reverse`/`RemoveSecondary`.
- The 29 `AQP-INFO` gaps: 11 `AQP-DSA|*` and 2 `AQP-MTX|*` have NO fixture in any chain that loads
  `AQP-INFO` (stated in the handoff, still true).
- The 8 AQP previews that abort on missing state and are not yet pinned as findings.

## DEFECT #18 — `URCi_DefineHybridSet` quoted the wrong price KEY (found + fixed, session 2)

`08_DPDC-S.pact` — `URCi_DefineHybridSet` **delegated** to `URCi_DefinePrimordialSet`, whose own
`@doc` asserted an *"identical cost shape"*. The shape is identical; the **price is not**:

```
02_IGNIS.pact:681-683   DPNF|C_DefineCompositeSet 43.0 · DPNF|C_DefineHybridSet 45.0 · DPNF|C_DefinePrimordialSet 43.0
02_IGNIS.pact:763-765   DPSF|C_DefineCompositeSet 43.0 · DPSF|C_DefineHybridSet 45.0 · DPSF|C_DefinePrimordialSet 43.0
```

while `C_DefineHybridSet` bills its OWN key (`08_DPDC-S.pact:1473`). So every hybrid set-class
definition was under-quoted by **2.0 raw IGNIS** (1.06 after discount) on **both** fungibility sides.
Fixed by giving the preview its own key; measured green at `<<DPDC-S-I27>>` / `<<DPDC-S-I33>>`.

**Why it survived, and the lesson.** Composite really IS 43.0, so *its* delegation is correct, and
the two siblings measured immediately above match to the decimal. Anyone spot-checking one of them
would have confirmed the doc's claim. Only asking all three and counting the coins separates them.

**A nuance worth keeping.** This is the ONE defect so far that the reader-vs-reader "tautology"
check the owner rejected would have caught — the two readers genuinely disagree, no execution needed.
It was never caught because `[6.1.9]_PRICE-SWEEP.repl` does not cover the define-set family at all.
So the tautology check is not worthless; it is **insufficient** (it cannot see a missing leg, which is
6 of the 18) and it was **unapplied here**. Both facts, not one.

**Running total: 18 pricing defects found and fixed.**

## SESSION 2, PART 2 — SWP swaps + ATS STOA

**+11 more measured**: `SWP-I15..I21` (the whole swap family) and `ATS-I24..I27` (branding STOA,
hot-RBT, remove-secondary).

**A doc claim retired.** `<<SWP-I19>>` runs the SAME preview as `<<SWP-I15>>` against the PRIMORDIAL
pool. `SWPU::C_Swap` branches on `(= swpair (UR_PrimordialPool))` (`19_SWPU.pact:2278`) — the
primordial branch forwards a real `stoa-pid` and triggers an extra `XI_STOA-PID|OPU` oracle write,
which `URCi_Swap`'s @doc merely ASSERTS is free (the reader has no `stoa-pid` parameter at all).
Both branches measure **42.93 = 42.93**. The claim is now a fact.

**The smart-swap name inversion is pinned.** `04_TS01-C3.pact` declares both `SWP|C_SmartSwap*` and
`SWP|CC_SmartSwap*`, and they are NOT the heavy/light pair the prefix convention implies:
`CC_` takes no bundle and SEARCHES the route → pairs with `INFO_...SmartSwap*`; `C_` takes a bundle →
pairs with `INFO_...*Bundle`. Matching by name alone yields two green tests that measure each
other's op. `<<SWP-I20>>`/`<<SWP-I21>>` wire it the right way round and say why.

## A MEASUREMENT TRAP THAT PRODUCED FOUR FALSE GREENS BEFORE IT WAS CAUGHT

**The gas meter must read the OP's patron, not the file's.** `ATS|HOT-RBT|*` and `CC_RemoveSecondary`
are paid by AOZT, not ANHD. Differencing ANHD's IGNIS gives a flat `0.0`, and the equality then
passes **exactly when the quote is also zero** — i.e. it silently converts every IGNIS-charging op in
the family into a vacuous test. It only surfaced because two of the four ops had non-zero quotes.
Any new block whose exec takes a patron other than `KST.ANHD` must move the meter with it.

## OTHER FIXTURE FACTS

- **Branding upgrades refuse while >15 days of Blue Flag remain** (`04_BRD.pact:266`), and most
  entities were already upgraded upstream. Moving `env-chain-data` past the expiry and restoring it is
  more robust than hunting for an un-upgraded entity, which makes the block depend on which suites ran.
- **`ATSU|C>X_REMOVE-SECONDARY` requires ALL THREE recovery states off.** They fail one at a time, so
  the first error names cold recovery and hides the other two.
- **NFT set positions need MORE THAN ONE allowed nonce** (`UEV_PrimordialSetElement`, `08_DPDC-S.pact:873`)
  — an NFT position is a CHOICE among candidates. The SFT twin accepts one, so fixtures do not port.
- **SET-NONCE updates require the set class to be FRAGMENTED** (`08_DPDC-S.pact:946`), on both sides.

## DEFECT #19 — `URCi_RemoveLiquidity` read the wrong price SOURCE (found + fixed)

`18_SWPLC.pact`. The preview's flat leg read

```
UC_IgnisPrice "SWP|C_RemoveLiquidity" "lp-churn"   = 1029.0   ;; 1000.0 deterrent + 29.0 component
```

while `C_RemoveLiquidity`'s `ico-flat` reads the **bare** deterrent

```
UC_IgnisDeter "lp-churn"                           = 1000.0   ;; 18_SWPLC.pact:1322
```

so every liquidity removal was **over-quoted by 29.0 raw IGNIS** (15.37 after the patron's 0.53
discount). Fixed by pointing the preview at exactly what the exec reads. Green at `<<SWP-I25>>`.

**Why it looked right.** The ADD sibling uses `UC_IgnisPrice` on **both** sides and matches exactly
(`<<SWP-I14>>`, `<<SWP-I22>>`), and both call sites carry the identical *"central IG|DETER lp-churn"*
comment. Reading either one alone confirms the other; only weighing both separates them.

**LEFT FOR THE OWNER.** Add and remove now disagree about the same deterrent — add charges
deter+component, remove charges deter alone. Whether removal *should* carry its component is a
pricing decision. Mirroring the exec is the only change a preview is entitled to make.

**Running total: 19 pricing defects found and fixed.**

## AND ONE NEAR-MISS WORTH THE SAME ATTENTION

`INFO_SWP|AddIcedLiquidity` / `AddGlacialLiquidity` first reported as defects because I reused
`<<SWP-I14>>`'s asymmetry-tax subtraction. They are **correct**: the CLAD collection FLAGS differ per
variant — standard passes `(asymmetric-collection=true, gaseous-collection=true)`, iced and glacial
pass `(false, true)`. With asymmetric collection off there is no IGNIS in `mt-ids` at all, so the
plain balance-delta is exact and the copied split subtracts a tax that was never charged. A correction
applied by pattern rather than by reading turns a correct preview into a reported defect.

## SESSION 2, PART 3 — the STOA surface

**+13 more**: `DPDC-I39..I42` (SFT/NFT collection issue + branding, both currencies),
`SWP-I22..I29` (liquidity variants, both issue siblings, both branding ops), `EQ-I2` (MorphEquity),
plus an ALIAS pin inside `EQ-I1`.

**Two earlier repairs are now verified on every member, not one.**
- The six-preview swap-pair STOA fix (600 quoted vs 500 charged) was measured only on
  `IssueStandard`. `<<SWP-I26>>`/`<<SWP-I27>>` now weigh `IssueStable` and `IssueWeighted` too.
- `INFO_DPSF|IssueCompany` and `INFO_DPSF|MorphEquity` are *forwarding aliases*. Both now assert they
  return the SAME numbers as their targets, not merely the same shape — a forwarding wrapper is
  exactly the code that gets edited on one side only.

**Two STOA sites collect with a HARDCODED `trigger=false`** — `02_DPDC.pact:1905` and
`18_SWPLC.pact:913` — so branding upgrades charge even when native gas is switched off, unlike every
other STOA site, which passes `(URC_IsNativeGasZero)`. Pinned at `<<DPDC-I41>>` and `<<SWP-I29>>`.

## A HARNESS TRAP THAT COST TWO FULL AQP-FULL RUNS (~12 min)

Appending to a `Stage_02/*.repl` and running `AQP-FULL` in the SAME backgrounded Bash call is not
safe: if the generator step fails (here, unescaped `{}` in a Python `.format` template), the `&&`
chain short-circuits, the run never happens, and **the previous run's log is still on disk** — so the
grep afterwards shows the OLD, passing output and the new blocks appear to have "not run". Verify the
append landed (`grep -c <tag> <file>`) BEFORE launching the run, as a separate step.

## SESSION 2 CLOSING STATE

**`INFO_` coverage: 219 untested → 61.** ~364 of 425 previews now measured against a real charge.
**Gate: GREEN.** Two more pricing defects found and fixed (#18 hybrid set price KEY, #19 remove-liquidity
price SOURCE) — **19 total**.

**Two MORE never-executed ops now run**, bringing the total to four:
`DPSF|C_ToggleExemptionRole` and `DPNF|C_ToggleExemptionRole`. `<<DPDC-G13>>` pinned only the refusal
("Only Smart Ouronet Accounts can get this role") using ANHD and asserted ANHD is standard; nobody
then supplied a smart one, so the accept arm and its price stayed unreached. Same shape, same fixture
(`KC.BJ`) and same root cause as `DPTF|C_ToggleFeeExemptionRole` in session 1.

### WHAT THE REMAINING 61 ACTUALLY ARE — categorised, so nobody re-derives this

| # | class | members |
|---|---|---|
| 8 | **internal helpers, reached transitively** — take a pre-built `ico` or are shared constructors; not client previews | `INFO_DPDC-I\|Issue`, `INFO_DPDC-MNG\|Simple`/`WipeMulti`, `INFO_DPDC-N\|Field`/`Bulk`, `INFO_DPDC-R\|Toggle`/`Move`, `INFO_DPDC\|UpgradeBranding`. NOTE: `_scale_report.py` does not mark these `VIA` even though every wrapper above them is now measured — a reporting gap, not a coverage one. |
| 2 | **not cost previews at all** — return `HibernatedNoncesView`, no ignis/stoa | `INFO_VST\|HibernatedNonce(s)Display` |
| 3 | **campaign totals, no single exec** | `INFO_{DPSF,DPNF,DPOF}\|WipeFull` — sum over an N-transaction `Cp_WipeSlice` plan; needs an accumulating multi-tx harness |
| ~12 | **NO FIXTURE, stated not invented** | 3 `AQP-DSA\|*` (no DSA state in any chain that loads `AQP-INFO`), 3 `SWP\|Issue*Pool` (3-step defpact, unreachable in one `begin-tx`), `SWP\|Firestarter` (credits IGNIS; quote and charge both zero), `ATS\|KickStart` (`TestKickPair` already kickstarted — index no longer -1), `ATS\|VestedCurl` (needs two chained AWAKE pairs; the only chain has one hibernating), `AQP-FVT\|SetCommonDenominator` (needs a link-free FVT that also has `can-upgrade`), `INFO_Collect` (STOAICO zero-mint deadlock, documented in `[6.3]_STOAICO.repl:434`) |
| ~36 | **reachable, simply not written yet** | ATS `Redeem`/`Reverse`/`DirectRecovery`/`AddHotRBT`/`HOT-RBT\|Repurpose`/`Issue`; DPNF fragments ×4; `EnableNonceFragmentation` ×2; `ORBR\|WithdrawFees`; SWP `AddFrozen`/`AddSleeping`/`*Bundle` ×2/`UpdateAmplifier`; AQP unstake family ×4 + `SyncNonFungibleAnchors` + score-model family ×5 + the four subsidised zero-quote ops; `DEMIPAD\|Deposit` |

**The `SetMosaic` lesson generalises to that last row.** It looked like a no-fixture case — every
standing FVT carries a `ScoreEntityLink` from `REPL_BootstrapVault`, and the guard demands zero — until
the setup ISSUED a fresh one. Several of the ~12 "no fixture" entries may fall the same way; the
honest label is "not reachable from the state these files leave behind", not "impossible".

## SESSION 2, PART 4 — the reachable tail

**+13 more**: `ATS-I28..I30` (redeem / reverse / hot-RBT repurpose), `DPNF-I37..I40` + `DPDC-I44`
(the whole fragmentation surface, both fungibility sides), `ORBR-FEE4` (withdraw-fees, measured where
the fee fixture lives), `LPAD-I1` (DEMIPAD deposit), `SWP-I30`/`I31` (the bundle half of the
smart-swap name inversion). All green.

### A GATE FAILURE WORTH THE LESSON: shared suite files can only use what their NARROWEST loader gives

I first wrapped the deposit measurement around `[5.3]_Launchpad.repl`'s own `TX-DEP-01`. It passed
under `modules/LAUNCHPAD.repl` and **failed the gate** under `launchpad-groundtruth.repl`:

```
modules/LAUNCHPAD.repl      -> deploy-stage02 -> Stage_02/[Z]_Reads.repl -> INFO-TWO deployed
launchpad-groundtruth.repl  -> builds Stage 02 by hand, never loads [Z]_Reads
```

so naming `INFO-TWO` inside the shared file compiles in one chain and dies with *"Module INFO-TWO has
no such member"* in the other — a message that points at the module, not at the missing loader.
**Before adding a reader to a `Stage_0*/*.repl`, check every entrypoint that loads it.** The
measurement now lives in the entrypoint that actually has the reader.

### FIXTURE FACTS

- **The fragment nonce is the NEGATION of the native nonce.** Fragmenting MOCKN nonce 2 lands on -2;
  `[6.1.4]` uses -1 only because it fragments nonce 1. Copying that -1 across gives *"doesnt hold NFT
  ... Nonce -1 in sufficient quantity"* — and on MOCKN nonce -1 is a DECOMMISSIONED row whose supply
  reads `-1`, so the arithmetic even looks plausible.
- **The 1000 fragments-per-nonce is a hardcoded protocol constant** (`09_DPDC-F.pact:263`), not a
  per-collection property. Asserted at `<<DPNF-I39>>` rather than trusted.
- **`UEV_NonceQuantityInclusion` compares against the PER-ACCOUNT holding** (`UR_AccountNonceSupply`),
  not the token-wide `UR_NonceSupply`. The two differ by one argument and give the same error.
- **`ATS|C_Redeem` / `C_Reverse` take the HOT-RBT DPOF id**, not the ATS pair id — the one place in
  that family where the second positional argument changes kind. `[6.6]` mints and consumes both
  DDKOSON nonces, so a fresh `C_HotRecovery` in setup is required and the nonce index must be read back.

## SESSION 2 FINAL — 43 untested, gate green at 20,533

`INFO_` coverage: **219 → 43** across this session. Of the 43, **~25 are structurally out of reach**
(8 internal helpers reached transitively, 2 that are not cost previews, 3 multi-tx campaign totals,
~12 with no fixture), leaving roughly **18 genuinely unwritten**.

Last batch: `TX-INFO-GT-SCRCTRL` / `SCRBOOST` / `SCRCOMB` / `SCRFROM` — the score-model family.

**`CreateScoreBoostLink` needed a score with NO stakers** (`02_SCORE.pact:910`, *"vacate to
reconfigure"*), which disqualifies every score this file uses — they are the ones carrying stake. The
subject has to be ISSUED inside the same transaction, carrying the STOA caps, and closed before the
meter opens. That is the `SetMosaic` pattern again, and it is now the third time it has decided a
fixture: **when a guard demands a virgin entity, issue one rather than hunt for one.**

### THE REMAINING ~18, and what each needs

- **AQP unstake family (4) + `SyncNonFungibleAnchors`** — need live staked positions; `[6.5.1]`
  deliberately drains every one. Same ABORT -> ENABLE -> STAKE chain as `<<TX-INFO-GT-SYNC>>`.
- **The four subsidised zero-quote ops** (`SweepBegin`, `SweepRecomputeChunk`, `UnstaleAll`,
  `InjectFinalize`). Their fixtures live in `[6.2.8]_AQP-SWEEP-CC.repl` / `[6.2.8c]` / `[6.2.8d]`,
  which AQP-FULL has COMMENTED OUT and which are loaded only by the `deb-staleness-*.repl` runners —
  and **those chains do not load `AQP-INFO`**. Either add that load to the runner (safe: single
  loader) or accept them as unreachable. This is the shared-file trap from Part 4 in a new place;
  check the loader BEFORE writing the block.
- **`ATS|Issue`** (STOA; needs a fresh pair name AND a fresh reward-bearing token id),
  **`ATS|AddHotRBT`** (needs an unregistered DPOF; `THRBT`'s `can-upgrade` is latched off forever),
  **`ATS|DirectRecovery`** (recoverer must hold KOR's cold-RBT — unverified).
- **`SWP|UpdateAmplifier`** (stable-pool only; the live stable pools are load-bearing for `[6.3]`),
  **`AddFrozenLiquidity`** / **`AddSleepingLiquidity`** (need a frozen DPTF / a dormant sleeping-LP
  nonce held by the account).
- **`AQP-SCR|IssueLiquidityScore`** (needs a valid `lp-denominator` SWP pair),
  **`IssueNonFungibleSetScoreDefinition`** (needs a live NF score id),
  **`AQP-FVT|IssueMultipletFamily`** (needs a validated ATS ladder).

## SESSION 2, PART 5 — the subsidised ops and the unstake family

**Gate green at 20,548. `INFO_` untested: 43 → 37.**

- `TX-INFO-GT-UNSTAKE-OF` / `-SF` — the multi-leg unstake previews, via the proven
  ABORT -> ENABLE -> STAKE setup chain (every position in `[6.5.1]` is deliberately drained, and a
  drain leaves the pool vacate-frozen with staking disabled).
- **All four subsidised zero-quote ops are now MEASURED rather than believed**: `SweepBegin` and
  `SweepRecomputeChunk` in `[6.2.8]`, `UnstaleAll` in `[6.2.8d]`, `InjectFinalize` in `[6.2.8c]`.

### Reaching them required solving the shared-file problem properly

Their fixtures live in suites AQP-FULL keeps COMMENTED OUT, loaded live only by the
`deb-staleness-*.repl` runners — **and those chains never loaded `AQP-INFO`**. Rather than name the
reader inside a shared suite (the mistake that failed the gate in Part 4), the load was added to each
**runner**, with a comment in the runner recording that AQP-FULL already loads `AQP-INFO` at `[6.5]`
but LATER in the file than its commented sweep block, so uncommenting would require moving it.

### Why the zero-quote proofs are not vacuous

A zero-vs-zero equality passes just as happily against an op that did nothing. Each of the four is
therefore placed inside a transaction that ALREADY pins the work: the sweep block pins that the pool
froze, the anchor was revoked and the cursor opened; the chunk block pins the recompute, unfreeze and
cursor close; `UnstaleAll` pins that a real staker was unstaled and the entity left injection-ready.
The zero is then a statement about the FEE, not about whether the op ran.

### `InjectFinalize` — the third of four inject-fix members verified

**406.4 = 406.4.** The custody-transfer defect was found on `Inject` and repaired across all four
inject previews; `Inject` and `InjectStream` were weighed earlier, this is the third. Only
`MTX|2Inject` remains unweighed, and it has no fixture in any chain that loads `AQP-INFO`.
Finalize's fixture exists nowhere else — it is only reachable at the end of a paginated
enforced-fresh inject, which is exactly what `[6.2.8c]` builds.

### REMAINING: 37 listed, ~25 structurally out, **~12 genuinely unwritten**

`AQP-POOL|StakeNonFungibleCollectable` / `UnstakeNonFungibleCollectable` / `SyncNonFungibleAnchors`
(need a fresh NF pool+score+vault fixture, the `*-FIXTURE` pattern already in `[6.5.1]`);
`AQP-SCR|IssueLiquidityScore` (valid `lp-denominator` pair) / `IssueNonFungibleSetScoreDefinition`
(live NF score); `AQP-FVT|IssueMultipletFamily` (validated ATS ladder);
`ATS|Issue` (**`UEV_IssueData` runs `DPTF::CAP_Owner` on the reward-bearing token — the RBT must be
an EXISTING caller-owned DPTF that is not already an RT/RBT**, which is the actual blocker, not the
name), `ATS|AddHotRBT`, `ATS|DirectRecovery`;
`SWP|UpdateAmplifier` / `AddFrozenLiquidity` / `AddSleepingLiquidity`.

## SESSION 2, PART 6 — the NF pool family and the wipe CAMPAIGNS

**Gate green at 20,571. `INFO_` untested: 37 → 29.**

- `TX-INFO-GT-STAKE-NF` / `-UNSTAKE-NF` / `-NFSYNC` — the non-fungible pool family. The pool is
  BORROWED, not built: `[6.2.4]_AQP-FVT-NF.repl` already provisions `NfSyncPool`/`NfSyncScore`/
  `NfSyncVault` over `DHB-98c486052a51` (class 4) and AQP-FULL loads it through `[6.2.4]_AQP-FVT`'s
  tail. **`NFSYNC` measured 49.29 — byte-identical to the SF twin**, which turns the reader's
  son-INDEPENDENCE @doc claim into a measurement instead of an inheritance.
- `TX-INFO-GT-NFSETDEF` — `IssueNonFungibleSetScoreDefinition`, the last of the eight
  abort-on-probe-id previews to get a real subject.
- `SWP-I32` — `UpdateAmplifier`, with the new amplifier DERIVED by doubling the current one so the
  block cannot silently become a no-op if an earlier suite re-amplifies the pool.

### THE THREE `WipeFull` PREVIEWS ARE NO LONGER "NO SINGLE EXEC"

`DPOF-I21`, `DPDC-I45`, `DPNF-I41`. These were parked as structurally unmeasurable because
`WipeFull` quotes the GRAND TOTAL of a Hydra campaign and there is no `C_WipeFull` to point a meter
at. The answer was not a different assertion but a different WINDOW: open the meter once, run every
`Cp_WipeSlice` in the plan, close it once, compare to the single quoted total.

**All three are deliberately MULTI-SLICE (3 slices each, 7.95 = 7.95).** With one nonce the campaign
degenerates to a single slice and the test proves only that `WipeFull` equals `WipeSlice` — leaving
the SUMMING, which is the one thing `WipeFull` adds, entirely unexercised. Extra nonces are moved to
the holder in setup and `(> slice-count 1)` is asserted, so the fixture cannot quietly decay into the
vacuous shape.

**Fixture cost of the DPOF one, worth knowing:** minting to a third party needs the ADD-QUANTITY role
on the ACCOUNT BEING CREDITED (`06_DPOF.pact:851`, not on the caller) AND the CREATE role, which is
single-holder — `C_MoveCreateRole` hands it over rather than granting a copy, so the block is
destructive to LUMY's holding and must roll back.

### REMAINING: 29 listed — 8 internal helpers, 2 non-previews, **and only ~7 genuinely unwritten**

`AQP-FVT|IssueMultipletFamily` (validated ATS ladder), `AQP-FVT|SetCommonDenominator` and
`AQP-SCR|IssueLiquidityScore` (both now look reachable via the issue-a-virgin-entity pattern — a
fresh CLASS-0 farm FVT satisfies can-upgrade + zero-links, and an LP token id satisfies the class-0
lp-denominator rule), `ATS|Issue` / `AddHotRBT` / `DirectRecovery`, `SWP|AddFrozenLiquidity` /
`AddSleepingLiquidity`. The rest are no-fixture by construction: 3 `AQP-DSA|*`, 3 `SWP|Issue*Pool`
(defpact), `SWP|Firestarter`, `ATS|KickStart`, `ATS|VestedCurl`, `INFO_Collect` (STOAICO deadlock).

## CORRECTION TO EVERY COVERAGE NUMBER I HAVE QUOTED — read this before the ones above

I have been reporting `python3 REPL/_scale_report.py --untested | grep -c INFO_` as though it meant
"measured". **It does not.** That tool answers *"is this function reached at all"*, and a preview is
"reached" by either of these, neither of which compares a quote to a charge:

```
(expect "..." true (contains "ignis" (INFO-ONE.INFO_DPTF|Control p ouro)))              ;; shape only
(expect-failure "..." "No value found in table" (AQP-INFO.INFO_AQP-FVT|Inject p "FVT-x" ...))
```

The honest split, from the new tool `REPL/_info_measured.py`:

```
declared previews      : 412
named in a live .repl  : 392
MEASURED (cost proof)  : 366   <-- the number that answers the owner's spec
named but NOT measured : 26    <-- shape-checks and abort-pins, counted as "covered" by _scale_report
never named at all     : 20
```

So the real remaining work is **46**, not the 24 the untested count suggested. The tool scopes by
`begin-tx` block (binding and assertion are routinely 20+ lines apart) and treats a block as a cost
proof when it extracts `ignis-need` or `stoa-need`. That is a PROXY and it is deliberately generous
in one direction — a block that extracts the field but forgets to `expect` it would still count — so
read it as an upper bound, not a certificate. It is not generous in the other: nothing shape-only can
pass it.

**How the mistake happened, because the shape will recur.** `[6.5]_AQP-INFO.repl` and
`[6.11]_INFO.repl` were written earlier as shape/abort suites, and they name ~26 previews. Those names
satisfy the reachability tool, so every preview they touch dropped out of my worklist before it was
ever weighed. The lesson is narrow and specific: **when the question is "does X equal Y", a coverage
tool that answers "was X called" is not a proxy for it.**

### The 26 named-but-unmeasured

`AQP-FVT|AddRewardLink` `AddScoreEntity` `InjectFixChunk` `RotateOwnership` `SetQualitySplit`
`SweepRevokeAnchor` · `AQP-POOL|AddScore` `RevokeScore` · `AQP-SCR|CreateScoreBoostClassLink`
`EnableDebBoost` `IssueNonFungibleScoreDefinition` `IssueSemiFungibleScoreDefinition` `IssueTriplet`
`RotateScoreOwnership` · `ATS|Brumate` `Curl` `SetColdRecoveryFees` `WithdrawRoyalties` ·
`DPOF|DeployAccount` `Issue` `UpgradeBranding` · `DPTF|Issue` `ToggleFeeLock` `Transmute` ·
`SWP|AddFrozenLiquidity` `AddSleepingLiquidity`

Several are plainly reachable (`DPOF|Issue`, `DPTF|Issue`, `AQP-POOL|AddScore`, the FVT link
toggles); a few carry the old blockers (`ATS|Curl`/`Brumate` need two chained awake pairs,
`ATS|WithdrawRoyalties` needs a pair with accrued royalties).

## SESSION 2, PART 7 — four more "no fixture" labels overturned, then the correction above

**Gate green at 20,607. MEASURED previews: 366 → 371 of 412.**

Before the coverage correction landed, four ops I had filed as unreachable turned out to be reachable
by the same move, bringing that pattern's tally to **seven**:

| op | the guard that looked fatal | why a virgin entity satisfies it |
|---|---|---|
| `AQP-FVT|SetCommonDenominator` | farm + can-upgrade + ZERO ScoreEntityLinks | `REPL_BootstrapVault` links at creation; a fresh class-0 farm has none |
| `AQP-SCR|IssueLiquidityScore` | class 0 needs a non-BAR native DPTF `lp-denominator` | an LP token id read from a live pool |
| `ATS|Issue` | `DPTF::CAP_Owner` on the RBT — must be an owned DPTF not already an RT/RBT | issue a virgin DPTF first |
| `ATS|AddHotRBT` | owned zero-supply DPOF + a pair with NO hot-RBT yet | issue a virgin pair AND a virgin DPOF |
| `ATS|KickStart` | `(= index -1.0)` — reachable once per pair, at birth | a pair issued here is born at -1 |
| `ATS|DirectRecovery` | direct recovery ON + a cold-RBT position to recover | coil first, switch the flag by negation |

**"No fixture" almost always meant "not reachable from the state these files leave behind".** The
label is only honest when the op is structurally unreachable — a defpact that cannot fit one
`begin-tx`, or an op whose own preview credits rather than charges.

### Also settled

- `INFO_DPTF|ToggleFeeLock` — the lock leg is free and only the UNLOCK charges STOA
  (`URCi_ToggleFeeLockStoa` is `(if toggle 0.0 (UC_FeeUnlockPrice))`), the exact shape that hid the
  `INFO_SWP|ToggleFeeLock` defect. Both legs now weighed: **2651.06 IGNIS + 382.5 STOA**.
- `DPOF|C_Issue`'s flag list is SEVEN long with `can-transfer-oft-create-role` inserted fourth,
  against DPTF's six. Copying the DPTF call across shifts every flag by one position, silently.

### THE 41 THAT REMAIN (21 named-but-unmeasured + 20 never-named)

Run `python3 REPL/_info_measured.py --gaps` for the live list. Structurally out: 3 `AQP-DSA|*`,
3 `SWP|Issue*Pool` (3-step defpact), `SWP|Firestarter` (credits IGNIS; nothing to difference),
`INFO_Collect` (STOAICO zero-mint deadlock), 2 `VST|Hibernated*Display` (not cost previews), and the
~9 `INFO_DPDC-*` internal helpers that take a pre-built cumulator. The rest are reachable and simply
unwritten — `ATS|Curl`/`Brumate` (two chained awake pairs, now clearly buildable from two virgin
pairs), `ATS|WithdrawRoyalties` (a pair with accrued royalties), the AQP link/score toggles, and
`SWP|AddFrozenLiquidity`/`AddSleepingLiquidity`.

## SESSION 2, PART 8 — closing the measured-vs-named gap

**Gate green at 20,625. MEASURED previews: 366 → 380 of 412** (named-but-unmeasured 26 → 12).

Fourteen previews that `_scale_report` had been counting as covered are now actually weighed:
`DPTF|Issue` `UpgradeBranding` `ToggleFeeLock` · `DPOF|Issue` `UpgradeBranding` `DeployAccount` ·
`ATS|SetColdRecoveryFees` · `AQP-SCR|RotateScoreOwnership` `EnableDebBoost`
`IssueSemiFungibleScoreDefinition` · `AQP-POOL|AddScore` `RevokeScore` ·
`AQP-FVT|AddScoreEntity` `AddRewardLink` `RotateOwnership`.

### Guard facts that each cost one run to learn

- **`AQP-SCR|IssueSemiFungibleScoreDefinition` needs `sft-equality = FALSE`** (`02_SCORE.pact:790`).
  Equality means every nonce scores the same, so a per-nonce value table contradicts it. The error
  names five conditions at once, so the failing one has to be read out of the source.
- **`AQP-FVT|AddScoreEntity` needs the score EMPLOYED BY A POOL first.** `05_FVT.pact:1574` reads
  `UR_AQP|PoolAssetId` on the score's pool; an unemployed score carries the BAR sentinel there, so the
  failure is a raw table miss on key `"|"` naming neither the score nor the rule.
- **`ATS|C_SetColdRecoveryFees` requires cold recovery OFF** — the ladder cannot be rewritten while
  the mechanism it configures is live.
- **`DPOF|C_Issue`'s flag list is SEVEN long** with `can-transfer-oft-create-role` inserted fourth,
  against DPTF's six; copying the DPTF call across shifts every flag silently.

### THE 32 THAT REMAIN — and what they are

**12 named-but-unmeasured**, all with a real blocker:
`ATS|Curl` / `Brumate` / `VestedCurl` (two CHAINED awake pairs — now clearly buildable from two virgin
pairs, since `ATS|Issue` works); `ATS|WithdrawRoyalties` (a pair with accrued royalties);
`AQP-SCR|CreateScoreBoostClassLink` (a boost CLASS, not a score) / `IssueTriplet` (three scores) /
`IssueNonFungibleScoreDefinition` (a class-4 score + trait keys); `AQP-FVT|SetQualitySplit`
(a MULTIPLET_BASE reward, which nothing in AQP-FULL creates) / `InjectFixChunk` / `SweepRevokeAnchor`
(zero-quote, fixtures in the deferred `[6.2.8*]` suites — the runner already loads `AQP-INFO`, so
these are now cheap); `SWP|AddFrozenLiquidity` / `AddSleepingLiquidity` (a frozen DPTF / a dormant
sleeping-LP nonce held by the account).

**20 never-named**: 9 `INFO_DPDC-*` internal helpers that take a pre-built cumulator and are verified
transitively; 2 `VST|Hibernated*Display` which are not cost previews at all; 3 `AQP-DSA|*`;
3 `SWP|Issue*Pool` (3-step defpact, cannot fit one `begin-tx`); `SWP|Firestarter` (credits IGNIS —
nothing to difference); `AQP-FVT|IssueMultipletFamily` (validated ATS ladder);
`INFO_Collect` (STOAICO zero-mint deadlock). Genuinely structural: ~15 of the 20.

## SESSION 2, PART 9 — the chained-pair fixture

**Gate green at 20,637. MEASURED previews: 380 → 384 of 412** (named-but-unmeasured 12 → 9).

`ATS-I36`/`I37`/`I38` (`Curl` 176.0, `Brumate` 262.0, `VestedCurl` 263.0) plus `InjectFixChunk`,
which completes the subsidised zero-quote family — **all five now measured rather than believed.**

### WHAT "CHAINED PAIRS" ACTUALLY MEANS — I had it half-wrong twice

Curl moves a position between two autostake pairs, and it needs **TWO** relationships at once. Each
one alone looks like the whole rule, and each failure message names a token but never the
relationship it was expected to have:

| # | rule | source | message when only the OTHER one holds |
|---|---|---|---|
| 1 | the `rt` ARGUMENT must be a reward token of `ats1` | `10_ATSU.pact:422` | *"Existance isnt verified for Token GTX1 as RT with ATS Pair GtChainPair1"* |
| 2 | `ats2`'s reward token must BE `ats1`'s cold-RBT | `08_ATS.pact:1649` | *"RT GTX1 isnt not an RT in the ATS-Pair GtChainPair2"* |

My first note said rbt→rt (rule 2 only); my "correction" said shared reward token (rule 1 only).
Both are required. The fixture is: DPTF-1 and DPTF-2 issued virgin → pair-1 (rt = PKOSON,
cold-RBT = GTX1) → pair-2 (rt = **GTX1**, cold-RBT = GTX2) → coil PKOSON into pair-1 → curl with
`rt = PKOSON`.

**Two further links the variants need, and neither is visible from the op's signature:**
- `Brumate` additionally needs a HIBERNATING counterpart on `ats2`'s cold-RBT (`08_ATS.pact:593`
  runs `DPTF::UEV_Hibernation <ats2 cold-rbt> true`); a freshly issued DPTF has no `H|` twin.
- `VestedCurl` needs a VESTING link on **`ats2`'s** cold-RBT, not `ats1`'s — the curl lands the
  position in pair 2 and the vest wraps what is there.

### THE 9 NAMED-BUT-UNMEASURED THAT REMAIN

`AQP-FVT|SetQualitySplit` (needs a MULTIPLET_BASE reward — nothing in AQP-FULL creates one);
`AQP-FVT|SweepRevokeAnchor` (**no positive exec anywhere**: the single-tx sweep-revoke was superseded
by the paginated `CC_SweepBegin`/`CCp_SweepRecomputeChunk` pair, and only the MTX defpact variant is
ever driven — this is structural, not a fixture gap);
`AQP-SCR|CreateScoreBoostClassLink` (a boost CLASS) / `IssueTriplet` (three scores) /
`IssueNonFungibleScoreDefinition` (class-4 score + trait keys); `ATS|WithdrawRoyalties` (a pair with
accrued royalties); `DPTF|Transmute` (an ELITEAURYN holder in the DPTF chain);
`SWP|AddFrozenLiquidity` / `AddSleepingLiquidity` (a frozen DPTF / a dormant sleeping-LP nonce).

## SESSION 2, PART 10 — down to six

**Gate green at 20,644. MEASURED previews: 384 → 387 of 412** (named-but-unmeasured 9 → 6).

`TX-INFO-GT-SCRNFDEF` (NF TRAIT definition), `TX-INFO-GT-SCRTRIP` (triplet), `ORBR-I4`
(`DPTF|Transmute`, placed where Elite-Auryn actually lives rather than where the op's family sits).

### Three guard facts, each of which cost one 6-minute run

- **The NF trait KEY must already exist on the collection.** `02_SCORE.pact:2908` reads DHB nonce 1's
  raw metadata and requires `(contains trait-key meta-data)`. The key is `"Rarity"` — capital R, as
  `01_BSD-L.pact:297` writes it. A lower-case `"rarity"` fails with a message listing key, value,
  score AND precision, none of which is the thing that was wrong. The VALUE is free (2..256 chars),
  because a definition declares a BAND rather than matching an existing nonce.
- **A managed cap caps the CUMULATIVE transfer.** The triplet block issues THREE scores in setup, and
  the one-issue STOA split every other block uses is exhausted by the third call — failing as
  *"STOA TRANSFER exceeded for balance 0.0"*, a funding message naming neither the cap nor the op that
  ran out of it. Setup ops that repeat need their caps multiplied.
- **`DPTF|Transmute` belongs in `modules/OUROBOROS.repl`, not `modules/DPTF.repl`.** DPTF's harness has
  no ELITEAURYN holder (its mocks are MOCKA/MOCKB); ORBR-G2 funds one as a side effect of the
  dispo-lock tests. And the patron must be ANHD, not EMMA — the elite branch composes
  `TFT::UEV_DispoLocker` and EMMA is deliberately in OURO debt there.

### THE FINAL SIX NAMED-BUT-UNMEASURED

| preview | blocker | verdict |
|---|---|---|
| `AQP-FVT|SweepRevokeAnchor` | **no positive exec anywhere** — superseded by the paginated `CC_SweepBegin`/`CCp_SweepRecomputeChunk` pair; only the MTX defpact variant is driven | STRUCTURAL. Worth an owner decision: either the single-tx op is dead and its preview with it, or the paginated pair should not be the only route. |
| `AQP-FVT|SetQualitySplit` | needs a `MULTIPLET_BASE` reward; nothing in AQP-FULL creates one, and creating one needs a validated ATS ladder (the same blocker as `IssueMultipletFamily`) | reachable in principle, expensive |
| `AQP-SCR|CreateScoreBoostClassLink` | needs a boost CLASS id; classes are minted inside `XI_IssueBoostClass` off the anchor-issue path, so one must be created by issuing an anchor with `acnoi` | reachable |
| `ATS|WithdrawRoyalties` | a pair with ACCRUED royalties; every pair on the chain has zero (ATS-G6 asserts it). Set a royalty on a virgin pair, coil to accrue, then withdraw | reachable |
| `SWP|AddFrozenLiquidity` | a frozen DPTF of a pool token, held by the account | reachable |
| `SWP|AddSleepingLiquidity` | a dormant sleeping-LP nonce held by the account | reachable |

Plus the 19 never-named, of which ~15 are structural (9 `INFO_DPDC-*` internal helpers verified
transitively, 2 `VST|Hibernated*Display` that are not cost previews, 3 `SWP|Issue*Pool` defpacts,
`SWP|Firestarter` which credits rather than charges, `INFO_Collect`'s STOAICO deadlock, 3 `AQP-DSA|*`
with no DSA state in any chain that loads `AQP-INFO`).

## SESSION 2, PART 11 — the named-but-unmeasured list is down to TWO

**Gate green at 20,655. MEASURED previews: 387 → 391 of 412.**

`ATS-I39` (`WithdrawRoyalties`), `TX-INFO-GT-SCRBCLINK` (`CreateScoreBoostClassLink`),
`SWP-I33` (`AddFrozenLiquidity`), `SWP-I34` (`AddSleepingLiquidity`).

All four had been filed as no-fixture. **Every one fell to building the entity instead of hunting for
one** — the tally for that move is now TWELVE.

- **`WithdrawRoyalties`**: `<<ATS-G6>>` asserts every standing pair has accrued ZERO royalties and pins
  the refusal. That is a fact about the standing state: royalties accrue from coils once a pair HAS a
  royalty set, and none does. Virgin pair -> set royalty -> coil -> withdraw. Accrued 10.0, charge 1.0.
- **`CreateScoreBoostClassLink`**: a boost CLASS has no constructor — it is minted as a side effect of
  issuing an anchor with `acnoi = true`. `[6.2.1]`'s `CoreBoostTFa` exists but is INACTIVE by this
  point ("BoostClass must be active"), so the setup issues an ANCHOR purely to obtain a live class.
  That is also why the STOA cap split is sized `issue-score + 2 x anchor`: `acnoi` doubles the anchor price.

### A near-miss worth keeping: you cannot always observe a tax where it lands

`SWP-I34` reads **quoted 1197.8, charged 1397.8** — the same 200-IGNIS asymmetry tax as `<<SWP-I14>>`,
paid as PRINCIPAL rather than gas. My first instinct was to observe it directly at the account it is
transferred to, since `18_SWPLC.pact:1266` moves `total-ignis-tax-needed` to the VST smart account.
**VST's IGNIS delta is 18.285, not 200.** That 18.285 is ordinary gas flow; the 200 goes into the POOL
via `XI_AddLiqSendAndMint`, and the pool is ALSO a gas interactor — so no single account's delta
isolates the tax. Only the CLAD's own `mt-ids`/`mt-amt` does.

The sleeping path's CLAD also cannot be reconstructed the way `<<SWP-I14>>` reconstructs the standard
one: it builds its liquidity vector from the NONCE's supply (`18_SWPLC.pact:1239-1242`), not from a
client-supplied amounts list, and an all-zero vector is refused outright. It has to go through
`UC_MakeLiquidityList` with the token's pool position.

### WHAT IS ACTUALLY LEFT: 2 + 19, and almost all of it is structural

**Named but unmeasured — 2:**
- `AQP-FVT|SweepRevokeAnchor` — **no positive exec anywhere in the tree.** Superseded by the paginated
  `CC_SweepBegin`/`CCp_SweepRecomputeChunk` pair; only the MTX defpact variant is driven. NOT a fixture
  gap. Owner decision: either the single-tx op is dead and its preview with it, or the paginated pair
  was not meant to be the only route.
- `AQP-FVT|SetQualitySplit` — needs a `MULTIPLET_BASE` reward, which needs a validated ATS ladder; the
  same blocker as `IssueMultipletFamily`, so ONE fixture would clear both.

**Never named — 19**, of which ~15 are structural: 9 `INFO_DPDC-*` internal helpers that take a
pre-built cumulator (verified transitively by every wrapper above them), 2 `VST|Hibernated*Display`
that are not cost previews at all, 3 `SWP|Issue*Pool` (3-step defpact, cannot fit one `begin-tx`),
`SWP|Firestarter` (credits IGNIS — nothing to difference), `INFO_Collect` (STOAICO zero-mint
deadlock). The remaining ~4: 3 `AQP-DSA|*` (no DSA state in any chain that loads `AQP-INFO`) and
`AQP-FVT|IssueMultipletFamily`.

## SESSION 2, PART 12 — DONE: every MEASURABLE preview is measured

**Gate green at 20,666. MEASURED: 396 of 412.** The remaining 16 are all structural.

Added: the three `INFO_AQP-DSA|*` previews, `IssueMultipletFamily`, `SetQualitySplit`.

### The DSA family needed the runner trick, one more time

All three DSA previews sat unmeasured because their fixtures exist ONLY in the `Kursan/dsa-*.repl`
runners and **none of those loaded `AQP-INFO`** — while `[6.5.1]` has the reader and no DSA state.
The reader was added to the two runners that hold the fixtures (`dsa-fee-tests`, `dsa-capture-tests`),
never to a shared suite file. Same rule as the launchpad gate failure, third application.

`SetOracleValidity` is **the only preview in the whole surface with no `patron` argument** — it takes
`(seconds)` and nothing else, because the op is a chain-wide GOV switch with no account to bill. Its
zero is guarded by the two assertions already in that transaction: the same call provably moved the
validity window AND flipped a live oracle from fresh to expired.

### The deepest fixture in the surface, and why it read as "no fixture" for so long

`SetQualitySplit` needs a MULTIPLET_BASE reward -> which needs a live multiplet family -> which needs
a two-rung ATS ladder (`ats-0-1`: rt = token-0, cold-RBT = token-1; `ats-1-2`: rt = token-1,
cold-RBT = token-2). Nothing on the AQP chain forms it; AQP-FULL does not even load `[6.6]_ATS.repl`.
The full chain is **eight setup ops**: 3 virgin DPTFs -> 2 virgin ATS pairs -> the family -> a virgin
FVT -> the reward link -> the op. Nothing was missing; the prerequisites were simply five deep.

**One derivation worth keeping:** the family id is `UCk_MultipletFamily token-0 token-1 token-2`
(`04_RPS.pact:3506`) — a COMPOSITE of all three tokens, not token-0. Guessing token-0 fails as a raw
table miss on `FVT|T|MultipletFamily` naming the TOKEN id, so the message reads as if the family was
never created rather than as a wrong key.

## FINAL STATE — the 16 that remain are all structural

| # | class | why it cannot be measured |
|---|---|---|
| 9 | `INFO_DPDC-*` internal helpers | take a PRE-BUILT `ico` — they are shared constructors, not client previews, and are exercised transitively by every wrapper above them (all measured) |
| 3 | `SWP|Issue*Pool` | 3-step defpact; a `begin-tx` cannot contain `continue-pact` |
| 2 | `VST|Hibernated*Display` | return `HibernatedNoncesView` — not cost previews at all, no ignis/stoa fields |
| 1 | `SWP|Firestarter` | CREDITS IGNIS to the firestarter; there is no charge to difference |
| 1 | `AQP-FVT|SweepRevokeAnchor` | **no positive exec anywhere in the tree** — superseded by the paginated `CC_SweepBegin`/`CCp_SweepRecomputeChunk` pair; only the MTX defpact variant is driven. **OWNER DECISION**: either the single-tx op is dead and its preview with it, or the paginated pair was not meant to be the only route. |

**`python3 REPL/_info_measured.py --gaps` reproduces this list at any time.**


## SESSION 2, PART 13 — the OWNER'S FOUR DECISIONS, implemented

The four open questions from PART 12 were put to the owner and all four came back as rulings rather
than answers ("use your logic and deduction capabilities to fix this"). All four are now implemented,
measured, and green.

**Gate: GREEN, 76 entrypoints, 20,690 assertions (16,861 positive / 3,829 negative), 0 failures.**
**`_info_measured.py`: 397 of 412 MEASURED — named-but-unmeasured is now ZERO.**
**`_conformance.py`: 0 violations.**

> **CORRECTION, and it is the most important paragraph in this section.** The first version of this
> write-up claimed "GREEN, 20,533 assertions" on the strength of a log that **the gate had never
> written**. The run was launched as `cd REPL && ... python3 _gate.py > /tmp/gate11.log` from a shell
> already inside `REPL/`. The `cd` failed, `&&` short-circuited, `_gate.py` never started — and a log
> from an earlier session was still sitting at that path, ending in `GATE GREEN`. The trailing
> `; echo "GATE rc=$?"` reported the *echo's* success, so the task looked like a clean completion.
>
> A stale green was read as a fresh green, and it was hiding a REAL failure caused by fix #1 below:
> `Stage_01/[6.1]_Cumulator.repl <<TX-IGC-008>>` pinned the VST link's leg 0 as
> `deterrence + issuance` FUSED IN ONE LEG, and fix #1 deliberately splits them. Expected 1349.0,
> received 279.0. The totals never changed — 279 + 1070 = 1349, and `<<VST-I1>>` still measures
> 748.89 = 748.89 — but the leg-level assertion was stale and the suite was right to reject it.
> `<<TX-IGC-008>>` now pins each leg separately AND their sum, so the original invariant survives
> while a fused leg is no longer an acceptable way to satisfy it.
>
> This is the SAME trap already recorded under "A HARNESS TRAP THAT COST TWO FULL AQP-FULL RUNS",
> in a new costume: there it was `&&` short-circuiting a generator step, here a failed `cd`. The
> constant is *a stale log at a well-known path answers a question nobody asked it*.
>
> FIXED STRUCTURALLY, not by resolving to be careful. `_gate.py` now prints
> `GATE RUN STARTED <timestamp> (pid N)` as its first line, flushed before any work. **A gate log
> without that header was never produced by a gate run.** Note also that `_gate.py` has always
> `chdir`-ed to its own directory (line 35), so it is cwd-independent and the `cd REPL &&` that
> caused this was never needed. A cwd guard was written and then DELETED for exactly that reason —
> it could never fire, and an unreachable guard dressed as protection is the shadowed-guard pattern
> `_shadowed.py` exists to find.

---

### 1. VST `CreateSpecial*Link` — the ruling, and why BOTH sides were wrong

Owner: *"CreateSpecial on the VST has a small deterrence and pays in full whatever is asked when
issuing new token."*

That ruling makes a previously undecidable disagreement decidable. `<<VST-I1>>` had pinned
719.74 quoted vs 601.02 charged as a FINDING precisely because the two sides were wrong in OPPOSITE
directions and neither could be declared the truth:

| leg | preview had | exec had | intended |
|---|---|---|---|
| deterrence (`vst-link`) | 279.0 (folded into leg 1) | **nothing** | 279.0 |
| issue the wrapper | 1070.0 | 1070.0 | 1070.0 |
| update-special | 5.0 | 5.0 | 5.0 |
| transfer-role toggle | a hand-made `UDC_LegCumulator` at **4.0** | the real `C_ToggleTransferRole` at **59.0** | 59.0 |

So the EXEC was under-collecting a deterrence it was designed to charge — **a revenue bug, not a
quoting one** — and the PREVIEW was under-modelling the toggle by 55.0. Both fixed in `11_VST.pact`:

* Two module-only readers, `URCi_CreateSpecial{True,Orto}FungibleLinkDeterrence`, are read by BOTH
  the preview and the exec. The pair cannot drift apart again.
* Two more, `...LinkToggle`, supply the toggle leg. They do NOT call `DPTF/DPOF::URCi_ToggleTransferRole`,
  and the reason is worth keeping: that reader ends on `(UR_Konto id)`, and the id the exec toggles is
  the wrapper it *just created from the block hash*, which no preview can name. Passing the base token
  instead happens to work for TrueFungibles and **hard-fails for Ortofungibles** — `DPOF|T|Properties`
  has no row for a DPTF id. Both halves are knowable without the id: the price is flat per op, and the
  konto is `VST|SC_NAME` because VST is the issuer.
* The preview keeps the deterrence in its OWN leg rather than folding it into the issue leg.
  `UDC_PrimeIgnisCumulator` discounts and quarter-splits PER LEG, so a preview with a different leg
  COUNT can round differently from its exec even when the totals are algebraically equal.

Measured, four ways, because the shared reader pair feeds SEVEN previews:

    <<VST-I1>>   TrueFungible link      748.89 = 748.89   (279 + 1070 + 5 + 59, at 0.53)
    <<SWP-I8>>   EnableFrozenLP         748.89 = 748.89   (same path, two modules down)
    <<SWP-I9>>   EnableSleepingLP       747.83 = 747.83   (Orto, vzh-tag 2)
    <<VST-I1c>>  CreateHibernatingLink  719.21 = 719.21   (Orto, vzh-tag 3 — NEW)

`<<VST-I1c>>` is new and covers the branch nothing executed: `vzh-tag 3` is transfer-free, so its
toggle leg resolves to `EOC`. It also asserts the hibernating link is strictly CHEAPER than the
sleeping one, which is what notices if the `if` on `vzh-tag` ever collapses.

Each equality carries a non-vacuity witness that the deterrence is genuinely INSIDE the charge —
without it, the equality would pass just as well if both sides dropped the deterrence together.

### 2. `lp-churn` — the disagreement was remove-vs-add, not preview-vs-exec

Owner: *"whatever the fee is, the INFO should mirror it... and make them consistent."*

I had previously moved `URCi_RemoveLiquidity` DOWN to the bare `UC_IgnisDeter "lp-churn"` to mirror
its exec. Mirroring was right; the direction was wrong, and the owner's "make them consistent" is
what settles it. The real asymmetry was side-wide:

* all five ADD ops bill `UC_IgnisPrice <op> "lp-churn"` on BOTH sides — deterrent **plus** component;
* REMOVE billed the bare deterrent on both sides once I "fixed" it, so an add paid 1029.0 and a
  remove paid 1000.0 for the same churn;
* `UC_IgnisPrice`'s own `@doc` says *"every `URCi_*` reader should bill through this, so a price lives
  in exactly one place"*;
* and the `"SWP|C_RemoveLiquidity" : 29.0` row sat in the IGNIS components table **billed by nothing at all**.

So the EXEC moved UP to `UC_IgnisPrice` (`18_SWPLC.pact`, both the `ico-flat` and the preview).
Removal now carries its own component exactly as an add does; the fee rises 29.0 raw / 15.37 net.

`<<SWP-I25b>>` is new and pins the DIRECTION, because the plain equality would hold just as well if
both sides slid back to the bare deter together: the measured charge must exceed the discounted bare
deterrent, and `UC_IgnisPrice "SWP|C_RemoveLiquidity" "lp-churn"` must equal `deter + 29.0`.

### 3. The add-liquidity asymmetry tax is now DECLARED

Owner: *"fix this as well, use recommended settings."*

`<<SWP-I14>>` had measured 1118.83 quoted against 1318.83 actually leaving the account, and proved
the 200.0 difference was NOT a missing leg: it is the Asymmetric-Liquidity TAX, which moves as
**principal** through `mt-amt` and never enters an OutputCumulator. The quote was correct and
incomplete at the same time — a client funding exactly `ignis-need` ran out of IGNIS.

**It went into `pre-text`, not into `ignis-need`.** `ignis-need` means "what the collector will take
as GAS", and the whole billing chain — discount, quarter-split, the cumulator itself — is built
around that meaning. Folding a principal transfer in would make the number wrong for the thing it is
actually used for and would silently re-discount a tax that is not discounted. Declaring amounts in
`pre-text` is the convention the launchpad previews already use.

Single-sourced rather than reconstructed. Five new readers in `18_SWPLC.pact` —
`URCi_Add{Standard,Iced,Glacial,Frozen,Sleeping}LiquidityClad` — now own the CLAD for each shape, and
each `URCi_Add*Liquidity` reads its own twin instead of inlining `URC_STOA-PID|CLAD`. The INFO layer
reads the same twin. This matters because the CLAD takes two collection flags that differ per variant
(`asymmetric-collection`, `gaseous-collection`), and **a preview that guesses those flags describes a
different operation than the one it prices**:

| shape | asymmetric | gaseous | carries the IGNIS tax? |
|---|---|---|---|
| Standard | ON | ON | **yes** |
| Sleeping | ON | ON | **yes** |
| Iced | OFF | ON | no |
| Glacial | OFF | OFF | no |
| Frozen | OFF | OFF | no |

`INFO-ONE::UC_LiquidityTaxDeclaration` presents it. The CLAD already computed both the figures and the
per-leg human wording (`gaseous-text`, `deficit-text`, `special-text`, `lqboost-text`, `fueling-text`),
so this is pure presentation over an argument — a `UC_`, reading nothing.

    PRINCIPAL, NOT included in the IGNIS cost below: 200.0 IGNIS of Asymmetric-Liquidity TAX, ...
    PRINCIPAL, NOT included in the IGNIS cost below: 39.685317861164310699777404 LP relinquished ...
    ~491.5352 LP out of a total ~7022.0802 Asym-LP, covered by 50.0 IGNIS (discounted as GAS) ...
    50.0 IGNIS costs for a Deviation of ~0.0240%, as Asym-Liq.-Deficit-TAX
    50.0 IGNIS credited to Special Targets, as Asym-Liq.-Special-TAX
    100.0 IGNIS fueling SSTOA LiquidIndex, as Asym-Liq.LqBoost-TAX

**The gaseous leg is deliberately NOT part of the declared tax** (50.0 here): it is billed through the
cumulator as gas and is therefore already inside `ignis-need`. 200.0 = deficit 50 + special 50 +
lqboost 100, and that is exactly the figure the balance meter sees.

What pins it — and this is the part that makes it a test rather than a comment. The assertions do not
compare the declaration to another reader. They format the **MEASURED** tax, the figure that satisfies
`predicted + tax = real`, and require the preview's own prose to contain it:

    <<SWP-I14>>  standard add    declared 200.0 == measured 200.0
    <<SWP-I22>>  multistep twin  same (shares the body; a one-sided repair would have missed it)
    <<SWP-I34>>  sleeping add    declared 200.0 == measured 200.0
    <<SWP-I23>>  iced add        declares "No Asymmetric-Liquidity TAX" — the OTHER arm

If the declaration ever drifts from the charge — say the two CLAD flags diverge — the substring stops
matching. `<<SWP-I23>>` exists so both arms of the helper are executed.

### 4. `INFO_AQP-FVT|SweepRevokeAnchor` — the last unmeasured preview

Owner: *"use your logic and deduction capabilities to fix this."*

The deduction: `CC_SweepRevokeAnchor` is not dead. It is the **single-transaction** variant standing
beside the paginated `CC_SweepBegin`/`CCp_SweepRecomputeChunk` pair, exactly as `CC_Inject` stands
beside the paginated inject — its own `@doc` says so. What was missing was a live invocation, which
`Kursan/AQP-sweep-single-tx.repl` now supplies at the same 50-holder population its paginated twin
uses (the metamorphic point: the one-shot must land on the END STATE the four-transaction pagination
reaches).

The preview quotes ZERO of both currencies, and a zero quote is the exact shape that turned out to be
a defect four times tonight. Here it is correct — the Talos wrapper carries no `IGNIS::C_Collect` and
no `STOA|C_Collect` — but *believed* is not *measured*. `<<SWP1-INFO>>` measures both currencies
around the live call. A zero-vs-zero equality is vacuous alone, so the non-vacuity guard is the
surrounding transaction: the same call provably revoked the anchor, unfroze the pool and recomputed
all fifty holders to zero. Both currencies are read because a subsidised op that quietly starts
charging is far likelier to do it in STOA than in IGNIS.

### Also fixed in passing

Three dead `(ref-DALOS:module{OuronetDalosV2} DALOS)` bindings in `INFO_SWP|Issue{Stable,Standard,Weighted}`
— `_conformance.py` is back to **0 violations**.

### One process note worth keeping

Interface declarations in this repo are edited **in place**, pre-mainnet, without a version bump —
`e735f6d` changed `SwapperIssueV4::URCi_Issue`'s ARITY that way. That is what made fix #3 cheap: five
new declarations went into `SwapperLiquidityClientV2` with no cascade, because the cascade rule fires
on RENAMING an interface, not on adding to one.

---

## THE 15 THAT REMAIN — all structural, none actionable

| # | class | why it cannot be measured |
|---|---|---|
| 9 | `INFO_DPDC-*` internal helpers | take a PRE-BUILT `ico` — shared constructors, not client previews; exercised transitively by every wrapper above them (all measured) |
| 3 | `SWP|Issue*Pool` | 3-step defpact; a `begin-tx` cannot contain `continue-pact` |
| 2 | `VST|Hibernated*Display` | return `HibernatedNoncesView` — not cost previews at all, no ignis/stoa fields |
| 1 | `SWP|Firestarter` | CREDITS IGNIS to the firestarter; there is no charge to difference |

`AQP-FVT|SweepRevokeAnchor` has left this table. **`python3 REPL/_info_measured.py --gaps` reproduces
the list at any time.**


## SESSION 2, PART 14 — a defect nothing could have executed, and a worklist that was not one

Two results, and they point in opposite directions: one queued task turned out to be already done,
and one unqueued check found a live bug.

### The "78 unreached UEV_ guards" was never a coverage gap

It was carried as the next major worklist item for two sessions. It is an artefact of reading the
wrong tool's answer. `_scale_report.py --untested` measures **static call-graph reachability**, and
its own output says `calls to a ref- binding this tool could not resolve: 89` — so any guard invoked
only as `(ref-DPDC::UEV_AccountFreezeState ...)` looks unreached even when a negative test drives it
to abort. Checked against the tool that actually owns the question:

    _enforce_coverage.py : 777 enforce sites with a matchable message, 753 PINNED (96%)
                           LIVE unpinned = 0.  All 24 remaining sit in the DEAD 00_DPMF module.
    _cheapseam.py        : 12 unpinned guards in plain callable functions, ALL 12 in 00_DPMF.
                           "the zero-fixture seam is exhausted."

Spot-confirmed by hand rather than trusted: `UEV_AccountFreezeState`'s message is pinned at
`Stage_02/[6.1.8]_DPDC-HYDRA-WIPE.repl:207`, and `UEV_SlippageCost`'s twice in `modules/DEMIPAD.repl`.
Both are on the "never reached" list.

**Guard pinning is COMPLETE.** The lesson is not about guards: two different tools answer two
different questions, and the one whose number was easier to quote was the one that did not answer
the question being asked. An audit figure must name the tool that owns it — which is precisely why
`_suite_stats.py` computes nothing itself and cites a source command beside every section.

The `A_`/`C_` entrypoint figure needed the same correction: 51 became **33** once the 18 in dead
DPMF were removed.

### DEFECT — NOSFERATU `A_Fix01` mis-tiled the Legendary rarity

The minter encodes its mint plan as literals inside one-line wrappers. There are two ladders:
`A_StepNN -> C_Spawn` mints, `A_FixNN -> C_Fix` rewrites the metadata of the same tiles. They are
identical rung-for-rung, 24 rungs each — **except rung 1**:

    A_Step01   C_Spawn ... "Legendary"  1  70      <- correct
    A_Fix01    C_Fix   ... "Legendary"  1 100      <- WRONG
    A_Fix02a   C_Fix   ... "Legendary" 71  30

Two consequences, and the second is the dangerous one:

1. Legendary 71-100 is covered TWICE — the Fix ladder totals 1530 positions against Spawn's 1500.
2. `C_Fix` enforces `(= (length mdm) number-of-positions)`, so the rung size IS the caller's list
   size. Every other rung in BOTH ladders is <= 70, and that 70 is not a style choice: it is the
   per-transaction gas budget, which is the entire reason the ladders carry split `a`/`b` rungs at
   rarity boundaries. `A_Fix01` was the one rung that could fail to fit in a transaction on chain.

**Why no test could have caught it.** A `.repl` cannot read a literal — it can only execute a rung —
and nothing in the suite executes the `A_Fix` family at all (`grep -r A_Fix --include=*.repl` returns
one comment). Even full execution coverage of `C_Fix` would not have found it, because `C_Fix` is
correct; the defect is in the arithmetic of the plan handed to it.

So the instrument matches the bug class: **`REPL/_ladder.py`**, a static check that every ladder tiles
its collection contiguously from 1 with no gap or overlap, that no rung exceeds the 70-position
budget, and that each Fix ladder matches its Spawn twin rung-for-rung. Mutation-tested against the
original bug (it reports all three symptoms) and against an independent over-budget mutation in
KBunnies. Wired into `_gate.py` as a hard failure, next to the Stage-Z variant check.

It handles both collection shapes: NOSFERATU is rarity-tiered, KBunnies is flat (no rarity argument,
no Fix twin — its metadata is set at spawn). A ladder that parses ZERO rungs is a violation rather
than a skip, because the usual cause is that the call shape moved and the check silently stopped
checking anything — the first draft skipped a missing file silently and therefore checked KBunnies
not at all.

    01_NOSFERATU.pact  A_Fix   24 rungs  1500  Common:800 Epic:200 Legendary:100 Rare:400
    01_NOSFERATU.pact  A_Step  24 rungs  1500  Common:800 Epic:200 Legendary:100 Rare:400
    02_KBunnies.pact   A_Step  16 rungs  1120  (flat):1120

### `modules/AQP.repl` — three leftover PROBE blocks, finished rather than deleted

`./_prerun.sh` (which must run before every gate) flagged them. They were guard-coverage work
abandoned mid-formalisation: a triplet fixture, a debug `print` of the guard's return, and one
`expect-failure`. Promoted to `<<AQP-G46a/b>>` (fixture, with assertions that the fixture is
actually right, since the guards under test are unreachable otherwise) and `<<AQP-G46>>`, which now
pins THREE of `UEV_AddScoreEntityTripletContext`'s five enforces — including the hoisted existence
check, whose whole point is that it used to sit under five eager `let` reads of the very row it
validated and was unreachable for every input. The other two enforces are covered by
`Kursan/dsa-grand-tour.repl <<GT-16>>`, which has the non-mosaic vault this file lacks.

### Also

Three dead `ref-DALOS` modref bindings removed from `INFO_SWP|Issue{Stable,Standard,Weighted}`;
`_conformance.py` back to 0 violations.

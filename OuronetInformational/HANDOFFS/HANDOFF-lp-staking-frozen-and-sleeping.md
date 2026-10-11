# HANDOFF — staking FROZEN and SLEEPING LP: the view, and the custody gap

Owner ruling, 2026-10-10, written down at 99% weekly usage for pickup the next day.
**Nothing below is built.** v2.18.0 shipped freeze / sleep / stake of NATIVE LP; the frozen and
sleeping legs were never wired into the Stake view.

---

## 1. The Stake view — two tabs

| tab | toggle | notes |
|---|---|---|
| **True Fungibles** | native / **frozen** / reserved | `reserved` DISABLED for LP staking |
| **Ortofungibles** | **sleeping** / hibernating | `hibernating` DISABLED for LP staking |

Frozen is the easy half: a toggle that swaps the subject token for its `F|` counterpart. The
capture controls above the zbom are unchanged, because a frozen LP is still a true fungible with
a flat balance.

Sleeping is the hard half: it is **nonce-based**, so a balance field is the wrong instrument.

## 2. The construction rule (owner's, and it is the constraint that shapes everything)

> *"whatever we do we should keep a similar construction true versus ortofungible. in the sense,
> the capture part of the view appears for truefungibles and is enough. the ortofungibles would
> also have it, but it would also have additionally below, an extra rectangle for the nonce view."*

So: **one shared capture block on top for both tabs**, and the ortofungible tab grows a SECOND
rectangle underneath holding the nonce view. Not a different screen — an additional panel.

The nonce view to reuse is the one fixed in v2.18.0 on the Remove-Liquidity page
(`SleepingLpNonceView` in `swp-pairs-proto.tsx`), which already:
  * reads `URC_05|SleepingLpList`, `DPOF.UR_NoncesSupplies`, `DPOF.UR_NoncesMetaDatas`;
  * gates its buttons on `URC_06|Buttons`, i.e. the chain decides what is enabled;
  * keeps the shared `LP_ACTION_LINE` and turns `nonces` into Back.

It should expose **unsleep, merge, and a new STAKE** button from that same line.

### The open design question, stated honestly

For true fungibles the UI **captures input parameters before the zbom**. For ortofungibles no
such pattern exists anywhere today — not on the swap page, not in the hibernation view. Either
build it specially here, or find a shape where the nonce SELECTION is the input and no separate
capture is needed. Decide this first; it determines the component boundaries.

## 3. Unstake — the harder view, and it does not exist for ortofungibles at all

Today the unstake view is **true-fungible only**. The ortofungible one must show, per nonce:

* **who the beneficiary is** (who earns),
* **who the owner is** — for a custodial stake this is the **AQP contract**, not the user,
* **when it can be unstaked**.

Two candidate shapes, owner leaned toward the second:
  * (a) a nonce selector box with a panel above naming who earns it; or
  * (b) **paginated staked-nonce entries**, each carrying its own beneficiary / owner / maturity.

**Readers already exist for this** — no Pact work needed for the VIEW:
```
AQP-POOL.URH_AQP|DpofStakesByOwner       (owner-id)        -> [object]
AQP-POOL.URH_AQP|DpofStakesByBeneficiary (beneficiary-id)  -> [object]
```
Both were registered as the preflight reads for the custodial recipes on 2026-10-10.

## 4. THE REAL GAP — custody and beneficiary are welded together

Owner's realisation, and it is a **protocol gap, not a UI one**:

> *"staking a sleeping nonce for someone else would relinquish custody over it, as it would
> transfer the collection rights to that other person. So staking a sleeping nonce for someone
> else while keeping its custody is not really supported — we don't have support in the pact
> code for this."*

What exists today:
* `CCp_StakeSpecialCustodial` — stakes a sleeping nonce under **pool custody**
  (`custodial = (= tracker-owner AQP|SC_NAME)`), because a duration-weighted multiplier requires
  the pool to hold the asset for the whole term;
* `CCp_ReassignCustodialBeneficiary` — moves the BENEFICIARY of an already-custodial position,
  which is how a locked position is sold;
* `CCp_ReleaseSpecialCustodial` — pays the native counterpart to whoever is beneficiary at
  maturity.

What is missing: **"stake MY nonce so THEY earn, while I keep the right to take it back."**
Beneficiary and the claim on the underlying asset are the same thing at release time, so
nominating someone else today is equivalent to giving them the asset. There is no third role.

**Do not design the UI around a capability that does not exist.** Either:
  * (a) accept the current semantics and make the UI state them plainly at the point of staking
    ("staking for another account transfers the claim to them"); or
  * (b) add the missing role in Pact first — a custodial position with a beneficiary distinct
    from the party entitled to the principal at release. That is a schema change on the tracker
    and a change to `CCp_ReleaseSpecialCustodial`'s payout target, so it is a ROUND, not a patch.

Owner has not ruled between (a) and (b). **Ask before building.**

## 4b. OWNER RULING, 2026-10-11 — the gap is CLOSED by design, and it is smaller than it looked

> *"We switch back to the original mode, where I am the owner of the staked batch, while
> specifying a beneficiary (me or someone else). We simply disallow unstaking until the sleeping
> period expires, while allowing switching the beneficiary while the batch is staked — and the
> same must exist for every staked NFT and SFT. For true fungibles we don't need this; it's
> complicated to get right, leave it as is."*

**Custody is replaced by a MATURITY LOCK.** Ownership returns to the staker; what guarantees the
pool holds the asset for the full term is an explicit refusal to unstake before the release date,
not a different name in the owner column.

### Why this is safe, verified rather than assumed

`XI_OrtoStakePhases`'s docstring is decisive (`05_FVT.pact`, ~3816):

> *"the batch moves from the USER while the tracker records `AQP|SC_NAME` as its owner. That
> single split IS the custody mechanism — the tracker key is what `CAP_StakeOwner` checks on an
> unstake, so naming the pool as owner makes an early user exit fail for free."*

So **the asset already leaves the user in the ORDINARY flow too.** Custody was never about
possession; it was one column. Returning ownership therefore creates **no transfer risk** — a
staker cannot move a batch they no longer hold — and the only thing lost is the free early-exit
refusal, which is exactly what the maturity lock replaces.

### The three roles ALREADY EXIST as parameters

`XI_OrtoStakePhases` takes them separately today:

| role | parameter | meaning under the new model |
|---|---|---|
| who hands the asset over | `transfer-sender` | the staker |
| who may unstake, and gets the PRINCIPAL back | `tracker-owner` | the staker (was `AQP\|SC_NAME`) |
| who EARNS while staked | `settle-beneficiary` | anyone the staker names |

This is the third role the 2026-10-10 note said was missing. It is not missing — it was being
collapsed by passing the pool as `tracker-owner`. **Switching the beneficiary is therefore not
giving away the asset**, because the principal follows `tracker-owner`, not the beneficiary.

### What actually has to be built

1. **A maturity guard on the sleeping unstake path.** Refuse while `release-date > now`. The
   reader exists (`DPOF::UR_NonceMetaData` → `release-date`); `VST::UEV_StillHasSleeping`
   enforces the OPPOSITE (`dt > 0`, must still be dormant), so this is its mirror and the two
   should be written as a pair so neither drifts.
2. **An in-place beneficiary switch**, for sleeping LP **and for every staked NFT and SFT**.
   `CCp_ReassignCustodialBeneficiary` is the sleeping-LP prototype — it runs the orto flow twice
   with `move-asset` false. Generalise it; do NOT copy it three times.
3. **Retire or re-point the custodial path.** `CCp_StakeSpecialCustodial` /
   `CCp_ReleaseSpecialCustodial` exist only to express custody. Under the new model an ordinary
   unstake at maturity hands the batch back and the user unsleeps it themselves through the
   normal `VST` path — so the custodial release may be **removable**, not merely adjusted.
   Check before deleting: `move-asset=false` exists because a pool-owned batch cannot be handed
   to the account in the owner column, and that reason disappears here.
4. **The mandatory-custody guard added in PureV6 must INVERT.** It currently refuses a
   multiplier-earning sleeping leg that is NOT staked under pool custody
   (`"Invalid stake path: a sleeping leg that earns a duration multiplier must be staked under
   pool custody"`). Under the new model that is exactly backwards.
5. **True fungibles are OUT OF SCOPE** by ruling. No beneficiary switching for TF stakes.

### Open questions for the owner

* Does the beneficiary switch still need the transfer-restriction gate
  (`URC_SpecialLegIssuerRestricted` → `UEV_MoveRoleCheck`)? It was added because reassignment
  was a DEFERRED DELIVERY of the asset. Under the new model it redirects *earnings only* and the
  principal never leaves the owner — so the justification for that gate appears to evaporate.
  **Do not remove it without a ruling**; it is the difference between "sell a locked position"
  and "pay someone my yield".
* Is a beneficiary switch free, or priced? It is cheap (no asset movement), but it is a client
  op and everything else in the tree is billed.
* What happens to a position whose beneficiary is a smart account that later vanishes?

### Migration

Check whether anything is staked under the custodial path before changing semantics. If nothing
is, the model can change freely; if something is, the owner column on those rows says
`AQP|SC_NAME` and no user could ever unstake them under the new rules.

## 5. Suggested order

1. Settle the ortofungible capture question (§2) and the (a)/(b) ruling (§4) — both are
   decisions, not code.
2. Frozen LP staking — the toggle. Smallest, fully supported today.
3. Sleeping LP staking — second rectangle + nonce view + stake button.
4. Ortofungible unstake view — shape (b), on the two readers above.

## State at handoff

* `v2.18.0` committed on `dev` in both repos; deploying to devwallet and master.
* Pact gate GREEN, 28,378 assertions. UI 101 files / 1,646 tests.
* `Deploy/PureV7` (9 tx) and `Deploy/PostV7/01_o-ui-nine.pact` are both ON CHAIN.

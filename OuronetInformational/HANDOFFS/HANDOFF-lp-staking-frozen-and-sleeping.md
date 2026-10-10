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

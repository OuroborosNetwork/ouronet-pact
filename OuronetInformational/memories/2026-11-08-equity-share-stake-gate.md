<!-- purpose: 2026-11-08 — the equity share-count stake gate: the owner ruling that EQUITY stays stateless, why the gate had to live in Talos, and the three traps this round walked into. -->

# 2026-11-08 — equity share count vs. accumulated score bases

## The owner ruling (durable)

> *"EQUITY has no domain tables — only policy tables; it's pure logic over DPDC's state.
> And it has to stay that way."*

`1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/11_EQUITY+.pact` declares `P|T` and `P|MT` and **nothing
else**. Share state lives in DPDC's tables; EQUITY is the rulebook over them. Treat a proposal to
give EQUITY a `deftable` as rejected unless the owner reopens it.

**This is load-bearing on more than tidiness.** It is half the reason the share-count gate could
not be put where the rule belongs (see below) — the other half being deploy order. Any future
"just keep a counter on the collection" idea runs into both.

## What was wrong

A score's base is an **accumulated signed delta**. The class-3 equity leg weighs a position at the
**live** share value (`URCx_EquityShareRawWeight` reads nonce-1 supply at call time) and records
nothing at stake time. So the two legs of a round trip can be priced at different scales.

Measured on the DHCompany fixture: stake 5 tier-6 E|DH packages at m=1 (unit 2,000 shares, base
10,000) → issue 1,000,000 shares (unit becomes 4,000) → full unstake subtracts 20,000 against the
10,000 that was added → **base −10,000, and the score's global total with it.**

PureV23 is what made the input movable. Before `C_IssueShares` existed the share count could not
change, and the weight function's own `@doc` leaned on exactly that.

## Three things worth remembering

**1] The identical defect had already been caught one input over, and the fix was already written
down.** `SCR|C>UPDATE-MULTIPLIERS` carries an emptiness gate whose doc spells out the arithmetic:
*"stake 100 at x2, change to x3, unstake 100: the row goes to -100 and the global total with it.
Deb-staleness does not compare mx, so nothing would report it."* Share count was a **second input
to the same formula** that never got the same gate. **When adding an input to a formula whose
output accumulates, go and read what guards the inputs that already exist.**

**2] Deb-staleness is structurally blind to a base error, and that is not a bug in it.**
`URC_U-SCR|UserScoreDebStale` recomputes the **derived** layers from the **stored** base, so a base
error moves neither side of its comparison and the row reads FRESH. Boosters and DEB only ever
stale the derived layers — which is why "stale it and let the user unstale" has always sufficed for
them, and why it could not work here. A base needs a **recompute from the trackers**, which is what
the class-3 re-rate route now is. Asserted, not assumed: `modules/EQUITY-SHARE-STALENESS.repl`
TX-EQSS-04 pins `deb-stale = false` on a base that is provably wrong.

**3] A price classification was being driven by a COMMENT.** `SCALES` in
`_ignis_price_sheet.py` runs over `billing_text`, which deliberately keeps `@doc` and comment prose
(so `charge()` can harvest deter keys from string literals), and it carries `per-nonce` as a
**literal phrase**. `C_AddScore`'s freeze-site comment contained "per-nonce TABLE VALUES", so the
op was published COMPLEX at `≥ 243`. Rewriting that comment dropped the phrase and the row became
exact. Checked before accepting: `URCi_AddScore` builds one cumulator from a single fixed
`UC_IgnisPrice`, no `length`/`fold`/item count anywhere — so `243` is true and `≥ 243` was the
artefact. **A floor label on a fixed charge should be confirmed against the cumulator, not
trusted.**

## Why the gate lives in Talos

EQUITY deploys at **tx 13**, AQP at **tx 16**. EQUITY can never ask AQP what is staked, and (per the
ruling above) it cannot keep its own answer. So `UEV_AQP|NoLiveStakeOfAsset` lives in **AQP-POOL**
and `TS02-C1`'s two share doors call it.

This is the established shape, not a workaround — the same constraint put the multiplier gate in
`AQP-POOL::C_UpdateScoreMultipliers` rather than AQP-SCORE, and
`AQP-SCR|C_IssueSemiFungibleScoreDefinition`'s dead-definition guard records it in its own comment:
*"Here rather than in AQP-SCORE because the pool fact lives one module LATER in deploy order."*

**Residual, stated rather than hidden:** the gate binds the Talos path, which is the only
gas-funded client path. A module holding a registered IMP guard on EQUITY could still reach
`EQUITY::C_IssueShares` directly. Closing that needs the counter the ruling forbids, so it stays a
governance property: do not register an IMP guard on EQUITY without re-reading this.

## The regression this round caused, and what predicted it

Admitting class 3 to the re-rate engine flipped `C_AddScore`'s auto-freeze, which had borrowed
`URC_AQP|ScoreBackfillSupported` to decide whether employing a score should stop the pool.
`CC_Step14_OpenCustodiansAgency` employs a triplet in the class-3 `CustodiansPool` and **stakes in
the same transaction**, so the freeze made its own stake inadmissible — AQP-FULL died at 311 of 982.

**The comment at that freeze site had already recorded this exact failure happening once before.**
Split into `URC_AQP|ScoreAutoFreezeOnAdd` — a POLICY about freezing, deliberately narrower than the
engine's support fence. The two are different questions ("should employing it stop the pool" vs
"can the engine re-rate it") that happened to share an answer while the engine handled only classes
0 and 1. **Do not collapse them again.**

## Still open (deliberately not fixed here)

- **SF score definitions are the same hole, ungated.** `AQP-SCR|C_IssueSemiFungibleScoreDefinition`
  re-weighs a nonce through `WW_SFScore`, an **upsert with no emptiness check**, re-valuing a live
  position exactly the way a share issuance used to. TX-EQSS-04 *uses* this to create staleness, so
  the hole is recorded as a running test rather than a note.
- **DPNF model 0/1 definitions** read `DPDC-S::URC_N|Score` and trait tables live — same class.
  Class 4 stays fenced out of the re-rate engine; it needs its own target and its own tests.
- **Class 2 (DPOF)** belongs to the sleeping-token custody work.

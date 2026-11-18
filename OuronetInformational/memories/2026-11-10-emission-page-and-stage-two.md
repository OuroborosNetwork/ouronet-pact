# Emission page, and the Stage Two cutover — 2026-11-10

**Status when this was written:** the V26 round is DEPLOYED and all fixes are live. `coin` is
upgraded on all ten chains with the vault repair applied; AQP transactions 01–09 and the S1
counter backfill all landed. This note is the brief for the NEXT piece of work, captured before
planning so the planning session starts from facts rather than recollection.

---

## What the owner asked for

An **Emission page**: a public, transparent view of every token emission the platform runs.

> *"The emission page is very important because it allows us to display transparently how our
> main Token is emitted … This will allow the users to track our token emissions transparently,
> see where they are going, and when the next mint event is due, as well as when the next inject
> and evict rewards event happens."*

**Three tokens get their own sub-page, for now:**

| token | role |
|---|---|
| **Ouroboros (OURO)** | the main token — the headline emission |
| **Stoicism** | |
| **Stoa** | |

**What each page must show:** how the token is emitted, the split (where it goes), **when the
next mint event is due**, and **when the next inject and evict-rewards event happens**.

That last column is the one with teeth: it is a forward-looking claim about an automaton's
schedule, not a read of current state, and it is the part most likely to drift from reality.

---

## The OURO emission, as the owner states it

Emitted via a **daily emission TX**. The amount is **1/10,000 of (Maximum Total Supply −
current Total Supply)**.

That matches the deployed code exactly — `DSP+::URC_DailyOURO` (`2_CITIZEN/Stage_Z/03_DSP+.pact`):

```pact
(maximum-theorethical-supply:decimal 10000000.0)
(speed:decimal 10000.0)
(floor (/ (- maximum-theorethical-supply current-ouro-supply) speed) op)
```

### Stage Two split (the designed end state) — sums to 100%

- Ouronet Custodians (former Midas Validators) — **20%**
- Ouroboros Pie — **80%**, comprised of:
  - Demiourgos Treasury 10%
  - Demiourgos Shareholders 10%
  - Ouroboros Liquidity Farming 20%
  - Autostaking 20% (fuelling the Auryndex ATS-Pair)
  - Subsidiary Staking 20% (Demiourgos NFT Staking)

Already encoded in `U_DALOS::UC_StageTwoEmissionSplit`, in **destination order**
`[custodians-20 treasury-10 shareholders-10 liquidity-farm-20 autostake-20 subsidiary-20]`, with
every share derived from one floored 10% unit and the **last share absorbing the rounding
remainder** so the parts always sum to the input with nothing minted-but-unassigned.

### Stage One split (what is running today) — sums to 100%

Stage One on Kadena has no SFTs, NFTs or Stake-Pools, so three destinations are redirected:

- Shareholders 10% → Autostaking (Auryndex ATS-Pair)
- Ouroboros Liquidity Farming 20% → Elite-Autostaking (Elite-Auryndex ATS-Pair)
- Subsidiary Staking 20% → Elite-Autostaking

Giving the effective Stage One emission:

- Demiourgos Treasury — **10%**
- Ouronet Custodians — **20%**
- Autostaking (Auryndex ATS-Pair fuelling) — **30%**
- Elite-Autostaking (Elite-Auryndex ATS-Pair fuelling) — **40%**

---

## The cutover

**From 1 December** Stage One Emission is **replaced** by Stage Two Emission.

Stage Two must be **automated via the DALOS automaton — the Ancient Hub automaton**, which is
`2_CITIZEN/Stage_Z/03_DSP+.pact` (interface `DispenserV3`).

**Plus:** automate the **injection of the StoicismVault with 20% of the production of our
miners.**

---

## What ALREADY EXISTS — do not rebuild this

`03_DSP+.pact` is further along than the brief implies. Present and deployed:

| member | what it does |
|---|---|
| `URC_DailyOURO ()` | the daily emission amount (formula above) |
| `A_OuroMinterStageOne:[decimal] ()` | **the Stage One minter — what runs today** |
| `AA_OuroMinterStageTwo:[decimal] (fvt-ids:[string])` | **the Stage Two minter** |
| `A_OuroMinterStageTwo_Flat:[decimal] ()` | the flat leg, for when the full run will not fit one tx |
| `URHC_StageTwoPlan:object (fvt-ids:[string])` | **read-only preflight** — "does today's emission still fit in ONE transaction, or must it run as the flat leg plus four parallel injects" |
| `A_StoicismMinter (stoicism-amounts:[decimal] stoicism-targets:[string])` | Stoicism minting, gated by `DSP|STOICISM-MINTER` |
| `URC_DailyKOSON (iz-game-live:bool)`, `A_KosonMinterStageOne` + `_1of3/_2of3/_3of3` | the KOSON line |

So the Stage Two **mechanism** is built. The outstanding work is the **schedule**, the
**cutover**, the **Stoicism injection rule**, and the **page that displays all of it**.

`URHC_StageTwoPlan` is the natural data source for "when is the next mint event due" and for
warning the page when a day's emission will need the split-leg path.

---

## The StoicismVault injection — ANSWERED by the owner, 2026-11-10

**The 20% is enforced by worker allocation, not by on-chain arithmetic.** That is the whole
design, and it is why the contract side is almost trivial.

- 10 miners, mining the pool through **3 workers**.
- **One of those 3 workers is assigned 2 of the 10 miners** — that is the 20%.
- That worker's rewards are **automatically collected to a dedicated Chainweb account**.
- **Once per day:** take the ENTIRE STOA balance of that account at transaction time, wrap it to
  WSTOA, and inject it into the StoicismVault.
- **Scaling:** when miners are added, more are simply assigned to that worker to hold the ratio.

So no contract ever computes "20% of" anything. It sweeps an account whose balance IS 20% by
construction. Nothing to drift, no percentage arithmetic, no rounding remainder.

### The on-chain path already exists end to end

| leg | entrypoint | verified |
|---|---|---|
| wrap STOA → WSTOA | `LIQUID::C_WrapStoa (patron executor amount)` | present in `12_LIQUID.pact` |
| inject the vault | `TS02-C3::AQP-FVT|CC_Inject` on `StoicismVault-VbI5pmK2CWEf` / `WSTOA-8Nh-JO8JO4F5` | lane live, `reward-enabled: true` |

StoicismVault's **only** enabled reward lane is `WSTOA-8Nh-JO8JO4F5` (ticker `WSTOA`), confirmed
live 2026-11-10 — which settles the earlier open question: "inject the StoicismVault" does mean
injecting WSTOA, and the wrap step is what makes the swept native STOA eligible.

### Two operational edges, measured

1. **`min-inject-amount` on that lane is `1.0` WSTOA** (live). A day whose swept balance is below
   1.0 will be REFUSED by `CC_Inject`, not silently skipped. The daily job needs to handle that —
   either skip the day and let the balance roll over (the account accumulates, so the next day
   clears the floor), or lower the floor for this lane. Rolling over is the simpler of the two and
   needs no contract change.
2. **The account must be dedicated.** Because the rule is "sweep the whole balance", anything else
   ever sent to that address is injected into the StoicismVault too. That is a property of the
   design, not a bug — but it makes the account single-purpose by contract.

### What the transparency page must NOT claim

The 20% is a fact about the **mining pool configuration**, not something a reader can verify on
chain. On chain all that is visible is "this account's balance was wrapped and injected". The page
should describe the mechanism honestly — 2 of 10 miners assigned to a dedicated worker, that
worker's output swept daily — rather than presenting 20% as a protocol-enforced split, which is
what the OURO emission genuinely is. Conflating the two would be the one dishonest line on a page
whose entire purpose is transparency.

## Open questions for the planning session

1. **What drives the cutover on 1 December?** A latch, a block height, a date constant, or an
   owner-sent transaction? A date constant in a deployed module cannot be changed without a
   redeploy on every affected chain — worth deciding deliberately rather than by default.
2. ~~What is 20% of miner production, measured where?~~ **ANSWERED** — see the section above.
   Worker allocation, swept whole. No on-chain percentage.
3. ~~Is the StoicismVault lane WSTOA?~~ **ANSWERED** — yes, and the wrap leg is why.
4. **Which Chainweb account is the collector?** Not yet named. It must be dedicated, because the
   rule is "sweep the whole balance".
5. **What fires the daily sweep?** Same question as the OURO daily TX, and the two could ride the
   same run — both are once-per-day, both are owner-authorised.
4. **Who sends the daily transaction, and what happens when it is missed?** "Automated" against
   a chain still means something holds a key and fires. A missed day is a visible gap on a
   transparency page.
5. **Does the page read live, or from a snapshot?** The AppReads layer (`2_CITIZEN/Stage_Z/
   AppReads/`) is the existing read-layer pattern, and the owner is migrating those pages
   personally, page by page — this one should join that process rather than bypass it.
6. **Next inject / evict-rewards event** — the AQP side. The round just deployed made the evict
   path exact; the page should source these from AQP rather than restating them.

---

## Verified against the deployed code, 2026-11-10

Not taken on trust — both splits were read out of the tree and compared to the owner's page text:

| | owner's text | code | agrees |
|---|---|---|---|
| daily amount | 1/10,000 of (Max − Current) | `URC_DailyOURO`: `floor((10,000,000 − supply) / 10,000)` | **yes** |
| Stage One | 10 / 20 / 30 / 40 | `A_OuroMinterStageOne` → `UC_TenTwentyThirtyFourtySplit` → `[v1, 2×v1, 3×v1, remainder]` | **yes** |
| Stage Two | 20 + (10+10+20+20+20) | `UC_StageTwoEmissionSplit` → six shares, destination order, last absorbs remainder | **yes** |

Both split helpers share the same discipline: one floored 10% unit, every share a multiple of it,
and the **last share takes the rounding remainder** so the parts sum exactly to the input. Nothing
is minted-but-unassigned in either stage. The maximum theoretical supply is **10,000,000 OURO**,
hard-coded in `URC_DailyOURO`.

## Why this note exists at all

The emission split is stated in three places that must agree: the owner's public page text, the
`UC_StageTwoEmissionSplit` code, and whatever the Emission page renders. **Two of the three are
already written and they agree today** — both sum to 100% and both order the destinations the
same way. A third copy is a third thing to drift, so the page should DERIVE the split from the
chain, not restate it.

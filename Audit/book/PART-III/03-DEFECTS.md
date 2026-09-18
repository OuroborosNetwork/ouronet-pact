# Part III · Chapter 3 — The twenty defects

Every defect below was found by driving a live operation, was fixed, and carries the assertion tag
that goes red if the fix is reverted. The tags run in the gate.

Ordered by what a user would lose, not by the order they were found.

**Twenty of the thirty-eight attacks found a defect**, and all twenty are below. One further defect
— the OURO mispricing that opens Tier 1 — was found by the audit rounds rather than by an attack,
and is included here because it was the most expensive single finding in the whole programme and
belongs with the money.

*This chapter enumerated eighteen while its title said nineteen and the register said twenty, for
several days, and the discrepancy was found by a machine and not by a reader. `_booktables.py` now
checks that every attack the register marks FIXED is named somewhere in this chapter — a check
written because the earlier version compared only the summary **table** against the register, and a
table can agree with the register while the prose beneath it enumerates a different set.*

---

## Tier 1 — Money

### A 38.65% mispricing of OURO, feeding the oracle, the launchpad and the explorer

`URC_OuroPrimordialPrice` priced a **weighted** three-token pool with a flat
`value / supply` ratio — the weights omitted entirely. Its sibling `URC_SingleOuroWorthWSTOA` had
been repaired months earlier to perform a real weighted-pool swap; this one kept the pre-repair
expression, and the two were called **three lines apart** in the launchpad's price block.

**Proven by controlled experiment, not by reading.** Reserves held constant, `stoa-pid` fixed,
the pool's weights moved through the live client path:

| pool weights `[SSTOA, OURO, WSTOA]` | flagged function | weight-aware sibling | error |
|---|---|---|---|
| `[0.4, 0.4, 0.2]` | `0.092000677826921560374870` | `0.119981820629800000000000` | −23.3% |
| `[0.2, 0.6, 0.2]` | **bit-identical** | `0.179963642484000000000000` | −48.9% |
| `[0.3, 0.5, 0.2]` — **genesis** | **bit-identical** | `0.149973488864900000000000` | **−38.65%** |

The flagged output does not move by a single digit across three weightings of the very pool it
prices. The −38.65% at genesis weights independently reproduces the ~38% gap measured when the
sibling was repaired.

*Blast radius:* the on-chain OURO price oracle writes this value whenever it deviates by >0.1%, and
that path is enabled at genesis; the launchpad converts dollar-denominated sale prices through it;
the block explorer derives several published figures from it.

**Fixed** by delegating to the weight-aware path — no new arithmetic. **Pinned by `SWP-G27`**, which
recomputes the *removed* formula inline and asserts it **disagrees** on live reserves. That makes the
mutation test permanent: every run re-proves both that the guard discriminates and that the original
defect was real, rather than resting on a measurement somebody took once.

> The repair changed **no existing assertion**. A 38% change to the token behind the oracle moved
> nothing in a suite of ~23,000 assertions — which is exactly how it shipped, and exactly how its
> repair could have regressed unnoticed.

### A fee charged before the gate that refuses — `RT-F-002`

`MTX|C_Issue` with the permissioned flag set:

| step | what happens |
|---|---|
| 0 | shape validation — **no authorisation check of any kind**; the permissioned flag actually *skips* a limit check, so the privileged path is the **laxer** one |
| 1 | **commits 2,919.77 IGNIS + 459.0 STOA** |
| 2 | admin gate → refused: `MTX-SWP Ownership not verified` |

No refund, no cancel. Rolling back costs a further 53 IGNIS; abandoning leaves the transaction open
forever, which is structural — Pact has no scheduled execution.

**The contrast that makes it a defect:** the single-transaction twin of the same operation refuses
the same caller and charges **0 IGNIS / 0 STOA**, because it hoists its conditional admin gate above
validation, exactly as this codebase's own authorisation-precedes-validation ruling requires. *Same
logical operation, two live client doors, and only one charges you for a refusal* — and the flag that
selects the expensive door is an undocumented boolean whose documentation never mentions it.

Three controls were required before this could be called a defect: a **differential** (the same drive
with the flag off fails with a *different* message, so the refusal is attributable to the admin gate),
a **non-vacuity** (the operation completes when the admin key signs), and the **cost contrast** above.

**Fixed** by hoisting the admin gate above the collection. **Pinned by `RT-F-002`.**

> This defect also **falsified something already written in the project's own defect ledger**, which
> had recorded this operation as the *specification* — "validation before money". That is true with
> the flag off and false with it on: *shape* validation precedes the money, *authorisation* follows
> it. The operation cited as the counter-example was carrying the unrepaired case.

### A deterrent charged on one door and not the other — `RT-A-001`

Adding standard liquidity was reachable through **two** live client paths, and only one charged the
`lp-churn` deterrent. A deterrent with a free door is not a deterrent.

### A share price that could be gamed at the rounding boundary — `RT-A-003`

An autostake pool's index is a share price, `floor(resident-sum / rbt-supply, p)`, and the deposit
path inverts it. The two `floor` operations do not commute, leaving an exploitable edge.

---

## Tier 2 — The protocol lying about what it did

### A swap that reported success while moving nothing — `RT-A-005`

The AMM's slippage floor — the line the source itself calls *"the real protection this whole check
exists for"* — **refuses by returning**, not by raising. It returns a one-element payload carrying
the refusal text; the success arm returns four elements. Only the client wrapper turns that into
anything a caller sees, and the wrappers did it differently:

| door | index taken | on a refusal | result |
|---|---|---|---|
| smart swap | `(at 3 out)` | out of range on a 1-element list | `Array index out of bounds. Length (1), Index (3)` |
| single / multi swap | `(at 0 out)` | **valid** on a 1-element list | *silent* |

Measured verbatim on shipped code:

> `"Succesfully swapped input(s) to Expected Output of 2366.80… out of Slippage bounds min of 990000.0 - max of 1010000.0 OURO-…"`

A sentence that **begins by claiming success and ends by reporting refusal**. The transaction
commits. The swap event has already fired — it sits on the capability acquisition, ahead of the floor
check — so an off-chain indexer sees a swap event and a success string for a swap that never
happened. Zero in, zero out.

> **The same defect, and the louder one was the safer one.** The index fault destroyed the guard's
> message but stopped the transaction. The silent one let it through. The noisy variant was found
> first *only because it was noisy*; the dangerous one was found by asking what its siblings did.

The two repairs differ because the two payloads do: the smart-swap door can test length, the
single/multi doors cannot — both payloads are one element — so they test the **type** (success is a
decimal, refusal a string).

### A documented field that did not hold what it said — `RT-D-002`

A collectable's `nonce-holder` field is documented as *"stores the account holding the nonce"*. It
does not. Anything reading it as authoritative is reading a value that can be stale.

### The preview and the execution disagreeing about refusal — `RT-K-001` … `RT-K-008`

**The largest family in the round: eight attacks, eight defects, on a surface nobody had swept.**

Ouronet offers a free `INFO_` preview for every priced operation. Cost parity — *does the preview
quote what the operation charges?* — was proven for all {{fig:previews_measured}} previews. **Refusal parity — does the
preview refuse what the operation refuses? — was proven for none.**

Where a preview re-derives state rather than sharing the execution path's readers, the two can
disagree, and they did: on bad inputs the execution refused cleanly while the preview died on a raw
array-index fault, across **seven separate module families** — autostake, true fungibles,
ortofungibles, collectables, swap pools, the citizen launchpad, and the acquisition-pool readers.

The launchpad case is the sharpest because its separating input is not a malformed id: the sale is a
live object and the amount is simply one no sale can honour. A caller checking the preview before
committing gets a crash where the operation would have given them a reason.

The eighth, `RT-K-008`, was found differently from the other seven and the difference is the
methodological point of the whole family. The first seven came from suspicion about a surface. The
eighth came from **counting the population**: `INFO_Collect` was the one client-facing cost preview
in the entire tree named by no test at all, and it was identified by enumerating all of them and
subtracting, not by anyone noticing it. A sweep that stops when the suspicious cases are exhausted
stops before it reaches the case nobody suspected.

---

## Tier 3 — Reach, sentinels and accounting

| id | defect |
|---|---|
| `RT-B-001` | The inter-module gate, described as passing only for a caller that *is* a registered module, did not enforce that — undermining the claim that the orchestrator is the only supported path |
| `RT-H-001` | The capability guarding the **no-slippage** swap path — the one a caller reaches by passing the `-1.0` sentinel — did not constrain what it should |
| `RT-H-002` | Slippage was unbounded **in both directions**; the documented `<= 50` limit was UI policy, not a contract rule, so a forged bound could bypass the check entirely |
| `RT-H-003` | A reader returns the `"|"` sentinel when an autostake pair has no hot reward token — **nine of fifteen live pairs** were in that state — and callers treated the sentinel as an id |
| `RT-I-001` | The gas station whitelists by reading the transaction's top-level forms; one case pinned a **single** form, so appending others changed what was actually executed under a matched whitelist |
| `RT-J-001` | A true fungible's `supply` and the sum of its account balances are written by **separate paths**, so the protocol's own accounting could diverge from itself |
| `RT-F-001` | The multi-transaction liquidity recipe collected its **entire deterrent in step 0**, then validated in step 1 that the pool had not moved since it quoted. A caller whose pool shifted between the two — which anybody else's transaction can cause — paid in full for an operation that then refused. The griefing shape is that the *attacker* controls whether the *victim's* already-paid transaction can complete |

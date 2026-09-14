# Conformance phase (P-item 2) — 2026-09-13

**VIOLATIONS 0 throughout. OBSERVATIONS 117 -> 114**, and the drop is real work, not reclassification:
three sites were deleted outright. The other two families were settled by execution and their rulings
are now BOUNDED and machine-checked rather than asserted in prose.

## The standing instruction that shaped this

> "fix whatever problem you find yourself, if you find any, dont stop to ask me for every little
> shiet. if the fueling cant happen on negative index, then thats what needs to not happen, and must
> be enforced in code, if its not it needs fixing, its that simple."

So: no escalation. Decide, fix, test, record.

## The fuel-index wording, resolved by reading the sibling twelve lines up

`10_ATSU.pact` `ATSU|C>FUEL` enforced `(>= index 0.1)` under the message *"Fueling cannot take place
on a negative Index"*. Two readings were possible — the bound is wrong, or the message is. The
sibling settles it: `ATSU|C>KICKSTART`, in the SAME file, applies the SAME 0.1 bound to
`would-be-index` and words it honestly as *"KickStart index must be at least 0.1"*. So 0.1 is a
deliberate system floor and the enforcement was already correct and strictly stronger than "not
negative". **The message was the defect.** Now reads *"Fueling requires an ATS-Pair Index of at least
0.1"* — deliberately distinct wording from the KickStart one so the two guards keep separate
coverage credit.

The test that found it (`modules/ATS.repl` `<<ATS-G17>>`) already drove BOTH states, which is why the
fix was cheap: the -1.0 sentinel (no RBT supply) and a live pair at index 0.05. One message now has
to be true for two different failures, so both are kept.

**Lesson: when a guard's message and its bound disagree, look for a sibling guard with the same
bound before deciding which half is wrong.** The sibling is the author's own statement of intent.

## Three dead `let` bindings deleted (rule now a regression detector at 0)

Left alone for a long time because each reads as though one half MUST be wrong and nobody could tell
which was authoritative. The unlock was ordering: **pin the equivalence by execution first, then
delete.** `STAGEZ-10` had already done the pinning — and, crucially, it asserts against
`URC_PrimordialIDs` DIRECTLY rather than against the dead bindings, so it survives the deletion and
still guards that function's element order for its other consumers. Write equivalence tests against
the function, not against the redundancy.

| site | what went | cost it was carrying |
|---|---|---|
| `01_DPL-UR` `URC_PrimordialPrices` | a `p-ids` destructure whose six names were ALL dead — five shadowed by the named reads below, `ignis` never read at all | a helper call + 6 table reads per invocation |
| `01_DPL-UR` `URC_0027a_AccountSelectorSingle` | a `public-key` re-read identical to the `try`-guarded binding above it | 1 read on the activated path |
| `17_SWPL` | a duplicate `UR_IgnisID` on the asymmetric-collection swap path | 1 read, and this one is TRANSACTIONAL — real user gas |

Plus a fourth found by an agent and outside the rule's reach: `02_KBunnies.pact` bound
`(iz-legendary ())` in an outer `let`, shadowed by a *differently scoped* binding inside a fold
lambda — so the duplicate-name rule never saw it. **A binding whose value is `()` is never
intentional.**

## `self-C-call-citizen` (64) — the direction is inverted

CLAUDE.md blocks a sovereign `C_` from self-calling because it builds an IGNIS OutputCumulator that
only Talos may collect; a self-call can drop or double it. **These citizen `C_`s return a STRING** —
the `format` output of the Talos wrapper, which has already collected. There is no cumulator at that
level to mishandle. They sit UPSTREAM of billing.

The 64 collapse to 3 families in 2 files (NOSFERATU `A_FixNN->C_Fix` x24 and `A_StepNN->C_Spawn` x24,
KBunnies `A_StepNN->C_Spawn` x16).

**The one thing that still needed checking** was that two steps split a 70-element mint across TWO
`C_Spawn` calls (A_Step02 = 30+40, A_Step05 = 20+50), so two Talos collects instead of one. That is
only safe if the price has NO FIXED PER-CALL COMPONENT. Settled by execution —
`[5.1]_PopulateNosferatu.repl` `<<NSFR-G2>>`: `URCi_RegisterCollectablesPrice` is
`(* smallest (sum amounts))`, and 30+40 costs exactly what 70 costs. The test ALSO pins the one
branch that would break linearity — the `(and (= ft "E|") son (= nu 0))` first-nonce discount — as
out of reach for a DPNF, so a future collection that IS `E|`+son fails the test instead of silently
mispricing.

## `C-without-cumulator` (38) — the note said two shapes; there are six

Every one traced to its Talos wrapper. Beyond A (core returns cumulator) and B (wrapper builds it
from a `URCi_`): **C** STOA-priced, **D** billed in the core itself (`STOA|C_CollectWT`), **E**
defpact step (all 8 MTX-SWP), **F** nested Talos client (all 3 DEMIPAD), plus **primitives** that
ARE the collectors. Recorded in CLAUDE.md as a table.

**One genuinely unbilled op, ruled NOT a defect:** `TS01-C4::PYTHIA|C_Link` takes no `patron` and
collects nothing, while its three siblings all charge. Deliberate (both @docs say "(no fee)") — but
"deliberate" is not "safe". What makes it safe is an economic bound living in a DIFFERENT function
and, until now, untested:

1. linking needs two deployed Apollo halves, 500 native STOA each;
2. `UEV_DualPairForLink` refuses a half whose counterpart is already set;
3. **counterparts are NEVER cleared** — revoke only flips the row inactive.

=> ONE-SHOT PER PAIR, FOREVER. ~1000 STOA buys exactly one free link and no amount of revoking buys
another. Pinned by `modules/PYTHIA.repl` `<<PYTHIA-LINK-ECON>>`, which exploits the fixture leaving
the pair through a full revoke->re-activate cycle (a stronger state than planned) and shows the free
entry stays closed, including against a fresh partner half.

**Generalised: an unbilled operation is not a defect if it is bounded — but the bound is usually in
another function, and that is exactly the thing nobody tests.**

## The watch-list that is now a gate

`cross-module-scan` (10 calls in 6 UI readers) was ruled an observation on 2026-09-12 because those
readers have ZERO Pact callers, so nothing transactional reaches them. That premise sat in prose.
**A premise nobody re-checks is a premise that quietly stops being true**, so it is now a companion
VIOLATION rule, `cross-module-scan-called`, evaluated every run.

It was verified to actually fire before being trusted: injecting a `C_` that calls
`DPL-UR::URC_0001_HeaderV3` took VIOLATIONS 0 -> 1, and a comment-only mention does not trip it
(the scanner blanks comments and strings). **A new detector that finds nothing is indistinguishable
from a broken one — prove it fires, then revert.**

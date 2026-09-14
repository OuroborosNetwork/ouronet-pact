# @doc claim verification (P3.6 / gate G5) closed — 2026-09-13

**100 claims, 0 unexercised.** Scoped in the plan as "~100, not started"; the real worklist was
**19**, because 81 were already exercised. All 19 closed in one pass.

## The scoping lesson, which is the reusable part

`_docclaims.py` counts a claim as touched **if the function's name appears anywhere in any `.repl`**.
Its own docstring says so. That cuts both ways and BOTH directions bit during this phase:

* **Over-counts (false "covered").** A function can be named in a comment and count as verified.
* **Under-counts (false "untested").** Four of the twelve SWP items were already exercised
  *behaviourally* and only lacked their name in a file. `SWP|C>ROTATE-PRINCIPAL` had **4 of its 5
  rejections** already driven through its Talos wrapper — the scanner just never sees a defcap's own
  name. `XE_RegisterPath`'s positive path is pinned on every run (a real smart swap leaves a
  non-BAR path-cache row, which can only exist if it ran).

**So: before writing a test for a "never mentioned" function, check whether it is already driven
under another name.** Roughly a third of this worklist was naming, not coverage.

## Most `@doc`s that trip an INVARIANT scanner are CHANGELOGS

The scanner fires on "always", "never", "must", "guaranteed". In this codebase those words very
often describe **a check that was REMOVED**:

> `UC_LpID` — "#40L fix: dropped the cross-module UEV_UniformList length-parity enforce that used to
> live here — a UC_* purity violation... Confirmed dead defense."

There is no live invariant there at all. Its only forward-looking sentence is an explicit
**non-guarantee**: mismatched-length inputs "hit a plain out-of-bounds crash instead of a clean
enforce message". That IS worth pinning — as a non-guarantee — so nobody "restores" the enforce and
nobody assumes a clean message exists. Same shape for `XE_CanAddOrSwapToggle` (#55L).

**When a doc is a changelog, say so in the test and pin the residual.** Don't invent an invariant to
match the scanner's guess.

## TWO EXISTING PROOFS WERE VACUOUS — the most valuable find of the phase

`[6.3]_SWP.repl` carried two "byte-identical" proofs for the #65bL shared-graph refactor:

    URC_PoolValueFromRaw  (test-pool, raw-graph) == URC_PoolValue(test-pool)
    URC_PoolValueFromGraph(test-pool, graph)     == URC_PoolValue(test-pool)

Both used `test-pool = "P|OURO-98c486052a51|VST-98c486052a51"`. `URC_PoolValueFromRaw` feeds the
pool's **first token** to `URC_WorthWSTOAFromRaw`, whose `id == ouro` branch short-circuits to
`URC_SingleOuroWorthWSTOA` and **never reads the graph argument at all**. Verified by execution:
passing an **EMPTY graph** returns the identical answer.

So both proofs of the graph-SOURCING refactor were green while proving nothing about graph sourcing.
They would have passed if the parameter were deleted.

**Repaired** with a pool whose first token is graph-searched (the BUSD stable pool — not
WSTOA/SSTOA/OURO, the three short-circuit ids) plus a **starvation control**. The vacuity is also
pinned in place, deliberately, so the trap is documented rather than erased.

### And the starvation control exposed an asymmetry worth knowing

Same pool, same empty graph:

| | empty graph |
|---|---|
| `URC_PoolValueFromRaw` | **FAULTS** — "Array index out of bounds" |
| `URC_PoolValueFromGraph` | returns **`[0.0 0.0]`, silently** |

A caller handing `FromGraph` a stale or empty graph gets a plausible-looking **zero valuation**
rather than an error. Safe today only because `URCx_Hopper` always builds the graph immediately
before use. Recorded at the site; it is the trap waiting for the first cached-graph caller.

**Generalised: an equality assertion between a function and its parameterised twin proves nothing
until you show the parameter is actually consumed. Starve it and watch it break.**

## A genuinely unobserved mechanism

`UR_TopologyVersion` was read by **zero** `.repl` files — the whole #65bL Phase 1 path-cache
freshness counter ran unwatched. It matters because a bump that FAILS to happen serves **stale
routes as fresh**: a silent wrong answer, not a crash.

Pinned with a three-state ladder on `XI_UpdatePair` — new pair (+1), new parallel pool on the same
pair (+1), **identical replay (no bump)**. The third line is the whole claim; an unconditional bump
passes the first two and fails only there.

Two things that would have made this wrong:
* `XI_` IS reachable from a REPL — `(acquire-module-admin ouronet-ns.SWPT)` then
  `(with-capability (SWPT.SECURE) …)`, since SWPT's `SECURE` is `(defcap SECURE () true)`.
* **Do not assert `(+ v 1)` against a pool issuance.** `XI_UpdateGraphForSwpair` calls
  `XI_UpdatePair` for every ordered pair, so an n-token pool bumps by n·(n−1). Drive the primitive.

## The peg claim, tested the only way that discriminates

`UC_StoaPrice` / `URCi_IssueAnchorStoa` / `URCi_IssueScoreStoa` all document the same past bug: each
"previously read the raw usage price... never dollar-denominated and so ignored the peg entirely."

**A test asserting 50 STOA and 100 STOA would have passed on the broken code too.** The claim is that
the figures TRACK the peg, so the test moves it: `A_UpdateUsagePrice "stoa|price"` 0.10 → 0.25, and
asserts the AMOUNTS fall to 2/5 while `amount × peg` — the dollars — does not move at all. Restored
in the same transaction.

**When a doc describes a fixed bug, write the test that the OLD code would fail.**

## Mechanics learned

* **`env-module-admin` must sit at transaction top level.** Inside a `let` the write silently aborts
  the whole file with **no FAILURE line at all** — the "grep -c FAILURE = 0 is not proof" shape again.
* **Field names are not doc names.** `UR_Frozen` reads the column `frozen-link`, not `frozen`; the
  wrong key gives a schema-mismatch abort listing every column, which is at least self-diagnosing.
* **Interface version suffixes cost two cycles here**: `AcquisitionVacateV1`→`V2`,
  `AcquisitionDelegationV1`→`DsaV2`. Grep `^(interface` in the source file rather than guessing.
* `UC_EquityID` returns a **pair** `[name ticker]`; only element 1 carries the `E|` prefix, and it is
  the ticker the id is built from. Element 0 is the "Equity" display name.

## One claim tested in the direction that mattered

`DSA|C>SET-AGENCY-FEE` — "reprices only FUTURE injects (the fee is never baked into a stored weight)".
The grand tour already set the fee *then* injected, which tests the forward direction. The claim is
about the other one, so the new test injects at 20%, raises the fee to 40% **with the inject
uncollected**, then collects. Operator receives 1800 (the 20% split), not 2000. A fee change is not
retroactive — now demonstrated rather than asserted.

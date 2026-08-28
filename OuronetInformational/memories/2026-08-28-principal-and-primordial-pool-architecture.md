# Principal & primordial-pool architecture — what actually exists, and why rotating a principal is safe (2026-08-28)

**Owner raised a sharp, independent concern:** if principals can be added/removed/rotated, and
existing pools were anchored to a principal at issuance time, doesn't rotating that principal break
the routing/pathfinding infrastructure everything else depends on? Framed as a possible "major vs.
minor principal" tiered architecture (majors fixed, minors changeable) that would need documenting.

**Answer, verified against the actual current code, not assumed:** this exact scenario was already
identified as **HIGH severity finding `H3`/`#21H`** earlier in this same SWP audit, and fixed across
three passes (`ROUND-02-FIXES.md` Fix #12, #13, #14) — with a **live adversarial proof matching the
owner's exact scenario**: issue a real pool anchored to a freshly-added principal, confirm a
genuinely non-empty route, rotate that principal to a different token, confirm the identical route
survives byte-for-byte. It does. This isn't a new issue — it's a re-discovery of an already-closed
one, worth writing down precisely because the concern is real and easy to reason your way back into
without remembering the fix.

## What actually exists (no major/minor tier)

There is **no two-tier principal system** in the code — the owner's "major vs. minor" framing doesn't
match what's implemented, and this is worth correcting plainly so nobody builds against a mental
model the code doesn't have:

- **`principals`** (`15_SWP.pact`, `SWP|Properties`) is a **flat, undifferentiated list** of token
  IDs. Every member is treated identically by every check — there's no field, flag, or separate table
  distinguishing "OURO/DWK-tier" principals from any other. Bounded to **2 minimum, 7 maximum**.
  Mutated via `A_UpdatePrincipal` (add, or remove while >2 remain) or `A_RotatePrincipal` (atomic
  replace-in-place, count-preserving). All three operations gated by the same `GOV|SWP_ADMIN` admin
  capability — nothing about OURO/DWK/DLK gets special protection at this layer.
- **`primordial-pool`** (`SWP|Properties`, set via `A_DefinePrimordialPool`) is a **completely
  separate, single-swpair property** — one pool ID, not a token list. `SWPI::URC_OuroPrimordialPrice`
  reads that one pool's token supplies by fixed position (`at 0`=DLK, `at 1`=OURO, `at 2`=DWK) to
  price OURO. This mechanism doesn't consult `principals` at all, and `A_UpdatePrincipal`/
  `A_RotatePrincipal` don't touch `primordial-pool` either — the two concepts are mechanically
  unrelated, even though OURO/DLK/DWK are (by convention, not by enforced code coupling) also listed
  as principals.

So: OURO and DWK aren't "majors that can't be removed" in any code-enforced sense — an admin *could*
rotate OURO out of `principals` today (subject to the same floor/cap as any other principal). What
actually protects the system isn't a tier, it's that **removing or rotating a principal genuinely
doesn't break anything already built**, per the next section — so the distinction the owner was
reaching for (something that needs extra protection) isn't needed in the first place.

## Why rotation/removal is actually safe (the H3/#21H fix)

The pre-H3 design (`SwapTracerV1`) stored the routing graph **keyed by principal identity** — every
swpair got filed under an `Edges` entry per principal it touched. Removing or replacing a principal
under that design genuinely did orphan every entry filed under it, permanently, system-wide, with no
resync — exactly the failure mode the owner's question is worried about.

`H3`/`#21H` (Fix #12, `ROUND-02-FIXES.md`) replaced this with `SwapTracerV2`: **plain token-to-token
adjacency**, principal identity playing no role anywhere in `SWPT`'s storage, keys, or reads. Verified
directly (not trusting the code's own doc comments) by grepping every consumer of `SWP::UR_Principals`
across the whole codebase: it has exactly one real caller outside `A_UpdatePrincipal`/
`A_RotatePrincipal` themselves — `SWPI::UEV_Issue`'s **issuance-time-only** anchoring gate
(`iz-principal` for W/P pools, `contains-principals` for S pools). Nothing in the graph
(`SWPT::UR_Graph`/`URC_ComputeGraphPath`/etc.), nothing in value computation
(`SWPI::URC_WorthDWK` and its `FromRaw`/`FromGraph` siblings), and nothing in live trading
(`SWP::URC_Swap`) ever reads current principal status. An existing pool's routing, pricing, and
tradability are **completely unaffected** by later principal changes — confirmed structurally, not
just claimed by a doc comment.

Fix #13/#14 added the operational guardrails on top: 7-cap and duplicate-add guard, atomic
`A_RotatePrincipal` as a count-preserving alternative to remove-then-add, then re-allowed standalone
removal with a 2-minimum floor (the floor exists purely so `UEV_Issue` always has *something* to
anchor a brand-new W/P pool to — not because removal itself is unsafe).

**The one real, narrower effect of removing/rotating a principal:** it's forward-only. A *future*
pool trying to anchor to a token whose only nearby principal was just removed might fail
`UEV_Issue`'s issuance-time check — existing pools keep working; only new-pool-growth near that part
of the graph gets harder until something else nearby is (re-)anchored to a live principal. That's a
usability/growth consideration for whoever manages the principal list, not a correctness bug.

## Small doc fix made alongside this (`#65dL`)

While re-verifying, found `A_RotatePrincipal`'s own `@doc` still claimed "standalone removal via
`A_UpdatePrincipal` is disabled" — accurate as of Fix #13, but Fix #14 re-enabled removal (floor-gated
at 2) and this doc comment was never updated to match. Corrected in `15_SWP.pact` — pure doc change,
no behavior touched, full regression re-run clean. See `ROUND-01-OWNER-FEEDBACK.md`'s `H3` entry
(addendum) and `ROUND-02-FIXES.md` for the fix write-up.

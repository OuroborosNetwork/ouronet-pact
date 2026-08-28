# Principal & primordial-pool architecture — what actually exists, why rotation was already safe, and the major/minor policy layer added on top (2026-08-28)

**Update (`#65eL`, same day, below):** the "no major/minor tier" section right below describes the
state as of the first two rounds of this investigation (`#65dL`) — still true of the *safety*
argument, but a real major/minor **policy** layer was added shortly after (see the final section) at
the owner's explicit request, once the safety re-verification confirmed rotation/removal was safe but
still pointless-to-ever-do for OURO/DWK/DLK specifically. Read both — the safety argument explains
*why* a tier wasn't load-bearing; the policy layer explains what now exists anyway, by choice.

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

## The major/minor policy layer, added on top (`#65eL`)

Once the safety re-verification above landed, the owner proposed an actual rule rather than leaving
things "safe but unrestricted": a **"major" principal is now defined as one currently a member of the
primordial pool** (live membership check, not a hardcoded list — see `URC_IsMajorPrincipal` below) —
in practice always exactly OURO/DWK/DLK, since `SWP|C>DEFINE-PRIMORDIAL-POOL`'s own capability gate
already enforces that whatever pool is designated primordial contains exactly those 3 tokens (and
`H6`/`#18H` already confirmed a second pool sharing that exact token set is structurally impossible to
issue). Majors are now **permanently fixed** — `A_UpdatePrincipal` (remove) and `A_RotatePrincipal`
both reject them outright, independent of and in addition to the pre-existing floor/rotation checks.
Any other ("minor") principal is completely unaffected — add/remove/rotate all work exactly as before.

This is a genuinely new rule, not a rediscovery — the code did not have this distinction before
`#65eL`; the section above ("no two-tier system") described the state accurately *at the time it was
written*, a few hours earlier in the same day. The rule exists for a different reason than the
`#65dL` safety question: even though rotating/removing any principal (major or minor) can't corrupt
existing routing, there's no legitimate operational reason to ever retire OURO/DWK/DLK specifically —
blocking it outright removes a whole class of admin mistakes (fat-fingering the wrong token into
`A_UpdatePrincipal`/`A_RotatePrincipal`) for free, at zero cost to anything that was actually using
the flexibility.

**What was built** (`1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`, `1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact`):
- `URC_IsMajorPrincipal(token):bool` — `contains token (UR_PoolTokens (UR_PrimordialPool))`, `false`
  if no primordial pool is defined yet (never crashes pre-bootstrap; `SWP|Properties` always has the
  `BAR` sentinel inserted at genesis). Doesn't require `token` to already be a registered principal —
  callers check that separately where it matters.
- `SWP|C>PRINCIPAL`'s removal branch and `SWP|C>ROTATE-PRINCIPAL` each gained one additional, distinct
  `enforce` rejecting a major principal, on top of their existing checks.
- Adversarially proven live (`SWP|TX 035a`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl`): confirms
  `URC_IsMajorPrincipal` correctly flags OURO/DLK/DWK (DWK checked even though it isn't currently a
  registered principal at all, per genesis — proving the check is about pool membership, not
  principal-list membership), confirms a minor principal reports `false`, confirms removing/rotating
  OURO is rejected at 7 principals defined (well above the floor, isolating the new guard from the old
  one), confirms a minor principal is completely unaffected (removed then restored in the same test).
  Both new guards reverted **in isolation** (one neutralized at a time) and re-run — each shows a
  genuine "expected failure, got result" independently, not a shared/confounded proof. (First attempt
  at this proof had two real flaws, caught and fixed before landing: a nonexistent token as the rotate
  target failed a different, unrelated check regardless of the guard being tested; and reverting both
  guards together let the removal test's real side effect — OURO actually leaving the list once
  unprotected — contaminate the rotate test running right after it on the same token.)

Full detail: `ROUND-01-OWNER-FEEDBACK.md`'s `H3` entry (third follow-up) and `ROUND-02-FIXES.md`
Fix #44.

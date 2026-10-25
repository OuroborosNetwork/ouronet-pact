# 2026-10-23 — Interface bumps are the default; the forced-fix payer rule; inject-path inventory

## 1. OWNER RULING — bumping the interface is the DEFAULT, not the exception

Verbatim: *"we ofcourse use A, and thats the default way to do such things always in the future.
when we add or modify stuff, we rewrite the interface with the new functions/inputs/shapes, etc,
and bump the interface."*

This settles a question that had been treated as a per-change judgement call. It is not one.

**The rule.** Adding or changing ANY public surface — a new `C_`/`CC_`/`A_`/`AA_`/`XE_`/`XB_`, a new
unprotected reader, a changed parameter list, a changed shape — means: write the new members into
the interface, bump its version suffix by exactly one, and carry the cascade through every module
that names it (`module{B}` / `object{B.Schema}`), in lockstep, per `CLAUDE.md`'s cascade rule.

**What this overrides.** The temptation it closes off is the "keep it off the interface and reach
it by a dot call instead" shortcut, which avoids a cascade at the cost of making a function
invisible to anyone reading the interface — i.e. it trades a day of mechanical work for a
permanent discoverability hole. The 2026-10-12 ruling (every `C_` belongs in its module's
interface) already said where functions live; this says the cost of honouring that is accepted.

**Scope note.** `CLAUDE.md`'s "new/active work stays on V1 until first mainnet deployment" is NOT
in tension with this: that clause governs the window BEFORE a module is live. For AQP-FVT and RPS
that window is closed — `Deploy/LIVE-MODULES.json` records `"deployed": true` for both, already at
V2 from the PureV10 round — so every further change to them is a V2→V3 bump and the cascade below.

**The AQP cascade, measured 2026-10-23** — files naming `AcquisitionRewardPerShareV2` or
`AcquisitionFarmsVaultsTreasuriesV2`:

    05_FVT.pact · 06_VCT.pact · 07_MTX-AQP.pact · 08_DSA.pact
    3_Talos/04_TS02-C3.pact · 2_CITIZEN/Stage_Z/03_DSP+.pact
    2_CITIZEN/Stage_Z/AppReads/OuronetUI/14_O-UI-FOURTEEN.pact

Same chain `Deploy/PureV10/README.md` records for the V1→V2 round.

## 2. OWNER RULING — who causes a forced fix decides who pays for it

Verbatim: *"When the FVT owner injects, and unstales, it generates the ignis bounty … When
someone other than the pool owner funds the fvt, and unstales, thats his busines, and no bounty
should be generated … if Bob injects and unstales Alices, no bounty is generated, because they
are both clients."*

Implemented 2026-10-23, with NO interface change (both fixers were already deployed and already
interface-declared):

| caller | fixer used | forced-fix count |
|---|---|---|
| `executor == UR_FVT\|OwnerKonto` | `XE_XI_FixUserFvtDebPenalizedIn` | recorded |
| anyone else | `XE_XI_FixUserFvtDeb` | **not** recorded |

Applied at **both** permissionless inject paths: `AQP-FVT::CC_Inject`, and all three fix sites of
`MTX-AQP::MTX|2|C_Inject` (including the step-1 continuation). The MTX path was found only because
a test's `ffc` baseline was unexpectedly non-zero — left alone it would have been a straight
loophole: anyone wanting to force-bill an FVT's stale members simply injects through the defpact.

**Side effect, deliberate:** this also closes the dust-grief. `CC_Inject` has no minimum amount
beyond `> 0.0` (confirmed — `UEV_InjectContext` line, and `DPTF::UEV_Amount` only checks precision),
and the fix loop never reads `amount`, so before this a stranger could force-bill every stale
member in an FVT for one smallest unit. Now that costs the victims nothing.

**NOT applied** to `CCp_FvtFixSlice` / `CCp_InjectFixChunk`: both are EXECUTORLESS BY DESIGN and
carry no caller identity to compare. Giving them one is an interface change — fold into the next
cascade.

**Cost accepted:** the non-owner branch is heavier. The penalized fixer takes hoisted
`members`/`reward-rows`; the plain one re-derives both internally, so a stranger's inject costs 2N
heavy reads against the owner's 2. A hoisted-list non-penalized variant is a new interface member;
add it when a cascade happens anyway, not for this alone.

Pinned by `[6.2.7]_AQP-DEB-MTX.repl` `<<TX-AQP-DEB15c>>`, which asserts BOTH halves — the member
comes out FRESH *and* the count is UNCHANGED. Asserting only the second would also pass if the
non-owner branch stopped fixing anybody, which is the worse bug.

## 3. THE INJECT PATHS, as measured 2026-10-23

| fn | fixes stale? | parallel? | ceiling |
|---|---|---|---|
| `CC_Inject` | yes, ALL inline | n/a (one tx) | gas; ~307 users ≈ 1.79M (`INJECT-FIX-CHUNK-MAX`) |
| `CC_InjectStream` | **no — and requires none** | n/a | `STREAM_MIN_DURATION` 1h … 365d, min rate `STREAM_MIN_UPS` |
| `CCp_FvtFixSlice` | yes (fed slice) | **YES** — disjoint lists, re-filters in-tx | none; add slices |
| `CCp_InjectFixChunk` | yes (cursor pager) | **NO** — `take chunk` of a shared list | sequential only |
| `CC_InjectFinalize` | no — *enforces* zero stale | n/a | — |
| `CCp_UnstaleAll` | yes, owner-gated, no inject | paginated, sequential | — |
| `MTX-AQP::MTX\|2\|C_Inject` | yes, 2 steps | **NO** — defpact | **2×N_FIX = 800** stale, hard |
| `CC_UnstaleMyScores` | own scores only, non-penalized | per-FVT list | — |

**Scaling rule.** `URH_FvtStalePresentUsers fvt-id` → split DISJOINT → N × `CCp_FvtFixSlice` fired
in PARALLEL → one `CC_InjectFinalize`. This has no ceiling. The defpact caps at 800 and is strictly
sequential; its only real advantage is that each step's opening scan IS its freshness proof, so it
avoids `CC_InjectFinalize`'s one re-scan. That is a marginal gain against a hard ceiling.

**Defpacts are NOT useless in general** — `MTX|2|C_SweepRevokeAnchor` holds a FREEZE BRACKET across
its steps (sweep-in-progress must persist between transactions), which parallel transactions cannot
express. The inject defpact has no such cross-step state, which is exactly why it is the weaker one.

## 4. OPEN — `CC_InjectStream` does not require freshness, and arguably should

Measured: `FVT|C>INJECT-STREAM` validates `UEV_InjectContext` + `UEV_StreamParams` only. No stale
scan, no stale enforce, no fix. So a stream can be opened over a stale membership, and the drip
(`XI_ReleaseStream` → `XI_DistributeInjectAmount`) divides by the STORED `total-deb-score` mirror
while each member's payout reads their STORED deb at claim time — both the fields staleness
corrupts. The mis-split then persists for the stream's whole duration and is never corrected
retroactively.

Not fixed here because it is a behaviour change needing a ruling: either make stream enforce
zero-stale (refuses often), or give it `CC_Inject`'s fix loop (costs gas on a path that currently
has none). Flagged for the next cascade.

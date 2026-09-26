# @ouronet/talos-registry — the constructor finished, and the package built  (2026-09-26)

Owner: *"finish the constructor, once its ready use it to create the package, then prepare it
with everything it needs to be ready for use."*

## The constructor: all nine requirements

| # | requirement | state |
|---|---|---|
| 1 | execution function + shape | 423/423 |
| 2 | info function + shape | 423/423 |
| 3 | ownership | 384/423 resolved, `ALWAYS`/`CONDITIONAL` marked, remainder listed |
| 4 | live-vs-repo provenance | 423/423, 0 divergences |
| 5 | other capabilities expected | 4/4 (the launchpad buys) |
| 6 | sponsorship | 423/423, step-scoped for defpacts |
| 7 | formula for cap params | same field |
| 8 | **ghost values** | **2,182/2,182 slots, 423/423 entrypoints** |
| 9 | execution mode | 423/423, five modes |

### Ghosts: per PARAMETER, not per entrypoint

The owner's objection was right — 423 hand-authored objects is absurd. The 423 entrypoints
share 2,182 parameter slots but only **276 distinct names**, and four (`patron`, `executor`,
`id`, `executee`) cover half. So the dictionary is keyed by name, with a type fallback, and
each entrypoint's example is composed. 42 name entries + 11 type entries cover everything.

Every id was read from **mainnet**, so the shape is real.

Three things the composer refuses to fake:

- a **preflight-fed** parameter gets `null` and a note naming the read. Inventing a plausible
  `SmartSwapPathBundle` would contradict the execution block two keys away.
- a **guard** gets `{readKeyset: "ks"}`, because that is the convention — the code carries
  `(read-keyset "ks")` and the keyset travels in the transaction data.
- an **object** is derived from the contract's own `defschema`, so the fields are right.

**A NAME DOES NOT PIN A TYPE** — the correction that mattered. `ats` is a bare id on most
entrypoints and `[string]` on `ATS|C_Issue`; `method` is a string in one place and a bool in
another. Applying the name entry blindly produced values the formatter refused — caught **23
times** by the package's build-every-ghost test, fixed by checking the value against the
declared type and falling through when it does not fit.

The first schema scan indexed **72 of 232** because it used `repo_modules()`, which slices from
`(module ` — and most schemas a client passes are declared in the **interface** above it.

## The package

`_libs/ouronet-libs/packages/talos-registry`, v1.0.0, surface `67c0979111eb156b`.
**461 tests**, tsc clean, workspace-linked and resolving from siblings.

| module | what it is for |
|---|---|
| `registry.ts` | lookup; throws on a stale key naming near matches; **refuses** an ambiguous bare name |
| `build.ts` | `buildCall` — arguments BY NAME, rendered in the contract's declared order |
| `format.ts` | the Pact literal rules |
| `plan.ts` | `planCall`/`explainCall` — assembles facts that live in different keys |
| `caps.ts` | the four launchpad buys |

**Why `buildCall` is the point.** Arguments by name make two failure classes impossible: a
short call (Pact partially applies and yields a closure — it does not error) and a transposed
one (`C_ChangeOwnership` kept four parameters and moved the pool id last).

`format.ts` encodes rules that each already cost someone: decimals never bare (`5` is an
integer literal and will not coerce), lists SPACE-separated, glyph accounts verbatim rather
than `\u`-escaped, guards as `(read-keyset "name")`.

### Two tests worth keeping

- **one per entrypoint**, asserting its ghost builds. 423 real assertions; this is what found
  the 23 type mismatches and the six guard parameters.
- **the README's figures and code are asserted against the snapshot.** A stale number fails the
  suite rather than misleading a reader. Whitespace-normalised, so prose may reflow freely —
  otherwise the suite trains people to edit the test instead of checking the number.

### The snapshot is pinned, and its drift is checked BOTH ways

Bundled at build time, never fetched at runtime: refreshing live adds a trust surface and an
offline failure mode a pinned artefact does not have.

- `npm run sync:check` (in the package) fails when the bundle drifts from upstream.
- `REPL/tools/_pkgsync.py --check` (in the Pact repo, wired into the gate) reports when the
  package is shipping a different surface. **Non-fatal on purpose** — the package is a separate
  repo that may not be checked out, and this gate must not depend on that. Stale is loud;
  absent is skipped.

`sync` also refuses a snapshot built without reading the chain, or one carrying deployed/repo
divergences: a consumer validating against a wrong surface is worse off than one with none.

## Proving it on a live bug

`sparkBuy.ts` sent four arguments to two five-parameter forms — `DEMIPAD.URC_Acquire` (missing
`slippage`) and `SPARK|C_BuySparks` (missing `max-cost`), both added when launchpad slippage
protection landed. **Spark purchases could not be funded.** Fixed, with slippage a REQUIRED
argument rather than a default, because one number drives two things that must agree.

Tree-wide, **two** arity mismatches remain: `SWP|C_SmartSwap*` missing `bundle`, which needs
the dirty-read harness.

## An accident, and the guard it produced

A scripted edit computed `old = s[ia:ib]` where `ib < ia`, making `old` the empty string.
`str.replace("", new)` inserts between every character: `_registry.py` went 55 KB → **193 MB**.
`git checkout` then reverted it to last commit, discarding a session of uncommitted tool work —
recovered only because a negative test had copied the tool to `/tmp` minutes before.

Every scripted edit since asserts the slice is non-empty and the anchors ordered. The reason
the ordering was wrong is worth keeping: `if PREVIEW.match(name):` occurs BEFORE the ownership
block, not after — an assumption never checked.

## Still open

1. **Publish.** OuronetUI consumes `@ouronet/ouronet-core` as a published version, not a
   workspace link, so the cfmBuilders fix needs a version bump and a publish to reach it. The
   rebuilt `dist/` was copied into the UI's `node_modules` for local testing; `npm install`
   wipes that.
2. **kpay** — `KPaySale.tsx` is broken and cannot be renamed into correctness: `DEMIPAD-KPAY`
   does not exist, and `UR_Kpay` has no replacement. Needs the page's data shape decided, or an
   AppReads reader written the way the `O-UI-*` modules were.
3. **Smart Swap harness** — the `bundle` producer.
4. **`IGNIS.C_DonateStoa`** — a deployed client function no client can call; needs an owner
   ruling on free-vs-priced before a Talos wrapper.
5. **Tooltip** still attached to zero buttons; 37 buttons still unwired.

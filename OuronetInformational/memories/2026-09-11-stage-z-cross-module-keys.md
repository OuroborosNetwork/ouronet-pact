# Stage-Z's UI readers scan other modules' tables — which makes them LOCAL-ONLY, not broken

**Date:** 2026-09-11 · **CORRECTED 2026-09-12** (see the correction box below — the original
conclusion of this note was wrong)
**Status:** behaviour confirmed by execution, pinned in `REPL/modules/STAGE-Z.repl`
(`STAGEZ-04/05/06`) as an observation
**Supersedes the diagnosis in:** `2026-09-11-stage-z-reads-are-mainnet-only.md`
**Withdrew:** `2026-09-11-cross-module-keys-FIX-PROPOSAL.md`

## CORRECTION (2026-09-12) — read this first

This note originally concluded **"six Stage-Z readers cannot run on ANY chain, including mainnet."**
**That was wrong.** Owner ruling: *"keys can be called freely, there is no admin gating on this."*

What I measured is real: `keys` on another module's table aborts with
`Module admin necessary for operation but has not been acquired:ouronet-ns.<MODULE>`. What I got
wrong is **where** it applies. Pact admin-gates cross-module scans in **transactional** mode only,
and **a REPL is always transactional** — so every observation came from the one execution mode these
functions never run in. Chainweb nodes run **`--allowReadsInLocal`** (verified on this project's own
nodes), making reads unrestricted in `/local` queries, which is how a UI reader is actually invoked.
The REPL cannot reproduce that: `FlagAllowReadInLocal` is a node exec flag and
`(env-exec-config ['FlagAllowReadInLocal])` is rejected as an unrecognised repl flag.

Confirmed before withdrawing: **all six readers have ZERO callers in Pact code**, so no transaction
reaches them.

**What survives as useful:** the property itself. A function containing a cross-module scan
**cannot be called from a transaction.** So the list below is a **watch list**, not a worklist — if
one of these is ever invoked from a `C_` / `A_` path, it becomes a real defect *at that moment*.
`_conformance.py --rule cross-module-scan` keeps the list as an OBSERVATION for exactly that reason,
and `STAGEZ-05` keeps the legal in-module form pinned for the day a transactional scan is needed.

**Lesson:** an error reproduced in a REPL is an error in a REPL. Before calling it a production
defect, establish that production runs in the same execution mode the test used.

Everything below is the original text, kept because the inventory and the mechanics are accurate —
only the severity was wrong.

## The finding

Six Stage-Z reader functions call `keys` on a table owned by **another** module
(inventory accurate; see the correction above for what it means):

| function | reaches into |
|---|---|
| `EXPLORER::URC_0001_LandingPage` | `DALOS.DALOS\|AccountTable` |
| `DPL-UR::URC_0001_HeaderV3` | `DALOS.DALOS\|AccountTable` |
| `DPL-UR::URC_0016_TruefungibleHeader` | `DPTF.DPTF\|PropertiesTable` |
| `DPL-UR::URC_0018_OrtofungibleHeader` | `DPOF.DPOF\|T\|Properties`, `…\|T\|Nonces` |
| `DPL-UR::URC_0021_CollectablesHeader` | `DPDC.DPSF\|T\|*`, `DPDC.DPNF\|T\|*` |
| `DPL-UR::URC_0035_EliteAccountRichList` | `DALOS.DALOS\|AccountTable` |

Pact requires the **owning module's admin** for `keys`. A read-only explorer call never holds it, so
every one of these aborts with:

```
Module admin necessary for operation but has not been acquired:ouronet-ns.<MODULE>
```

**This is not a sandbox artefact.** It has no dependence on chain state, ids, or fixtures. These six
functions — the primary UI entry points for the explorer and the deployer dashboard — have never
been callable by anyone, on any chain, including mainnet.

## Why it stayed hidden — two stacked blockers

`EXPLORER::URC_0001_LandingPage` binds `(ATS::URC_Index "Auryndex-O136CBn22ncY")` in its `let`.
Pact `let` is **eager**, so on a test chain it died *there*, in the bindings, and never reached the
`keys` call in its body. The id defect was standing in front of the admin defect and absorbing the
blame. The earlier memory concluded "Stage-Z reads are mainnet-only" — the right observation about
the first blocker, and a wrong conclusion about the function, because the investigation stopped at
the first error message.

The way the second blocker surfaced was **removing the first one**: a testing variant with the
sandbox ids got past the `let` and immediately produced a different error. That is the whole value
of the variant — not that it makes the page work, but that it proves the id fix is *necessary and
not sufficient*.

**The four DPL-UR headers are the control.** None of them hardcodes an id; they take an account and
read the live chain. They fail identically. So the defect is independent of the id issue, and the
differing module name in each message (DPTF / DPOF / DPDC / DALOS) shows it is a pattern, not a slip.

## The fix shape

The legal form of the same read is the owning module doing its own scan. `DALOS` already ships it:

```
DALOS::URH_AccountCounter   ->  "Ouronet has 27 real Accounts!"   ;; works
(keys DALOS.DALOS|AccountTable)  ->  admin gate                    ;; fails
```

Both are asserted side by side in `STAGEZ-05`, so the rule is pinned independently of any caller.

So each site routes through a `URH_*` in the owning module, reached via the module ref. `DALOS` has
the reader already. `DPTF`/`DPOF`/`DPDC` have `URH_*` families but **no plain counter** — those need
a new `URH_` each, which is a sovereign-module change and therefore an interface bump under the
cascade rule. **Owner decision required; not done.**

This also restates an existing repo rule the sites violate: no raw table access outside the owning
module's `UR_*`/`URH_*`.

## Method notes

- **`try` made two probes lie.** `try` puts the DB in read-only mode, so `keys` inside a `try` fails
  with *"Operation disallowed in read-only or sys-only mode"* — the probe's own error, not the code's.
  Plain `read` under `try` is fine, which is why earlier `try`-based probes looked trustworthy.
  Anything touching `keys`/`select` must be probed with a direct call or `expect-failure`.
- Every assertion passes the **exact** expected message. With the 2-arg form all six would have gone
  green against the wrong error and "proved" the opposite.

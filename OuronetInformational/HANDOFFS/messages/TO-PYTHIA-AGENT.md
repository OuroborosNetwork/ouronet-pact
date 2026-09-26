# ── PASTE TO THE PYTHIA AGENT ─────────────────────────────────────────────

A new package is live: **`@ouronet/talos-registry@1.1.0`** (npmjs.org, public). It is the
Ouronet callable surface generated from the **deployed** contracts — 423 entrypoints, their
parameters in declared order, their `INFO_` previews, capability recipes, example values.

**Your brief:**
`_onchain/Ouronet/OuronetInformational/HANDOFFS/HANDOFF-talos-registry-PYTHIA.md`
(read `HANDOFF-talos-registry.md` beside it first — API, and the three traps.)

## Read this part before anything else: authentication was down fleet-wide

`apps/pythia/src/connectors/auth/dualLinkCache.ts` called

```
(ouronet-ns.PYTHIA.URD_ListActiveDualLinks)
```

Mainnet answers **`Module ouronet-ns.PYTHIA has no such member`**. The deployed name is
`URH_ListActiveDualLinks`; it returns 6 rows.

**This was the second time**, and the first is written in that file's own docstring: v3.0.2 found
`UR_ActiveDualLinkSet` did not exist — *"the read failed on every poll, the fail-closed cache
stayed empty, and so EVERY consumer's account read as inactive (all `/verify` → `202 pending`, no
`x-pythia-key` ever minted, fleet-wide)."* **The fix for that repointed to
`URD_ListActiveDualLinks`, which is also not a member, and reproduced the outage it was written
to end.**

**Already fixed and committed** (`URD_` → `URH_`, 90 tests / 12 files pass, tsc clean, commit
`9d53a42`). Your pending `package.json` / `package-lock.json` changes were left untouched.

### Why it happened twice, and what to take from it

A Pact call naming a function that does not exist is a **resolution error**: `try` cannot catch
it, nothing throws at the call site, and a **fail-closed** cache turns it into *"nobody is
authorised"* rather than *"this read is broken"* — which looks exactly like a quiet day.

The author was careful. They wrote the incident up, named the failure mode precisely, and chose a
replacement they believed was live. **Care was not the missing ingredient; a source of truth was.**
`tryGetEntrypoint` returns `undefined` for `URD_` and `resolveByName` offers `URH_` — at build
time, and would have on both rounds.

## How to depend on it

A plain **`dependency`** — you are a deployed service, not a library someone composes. You own
your tree and your version; a newer registry arrives on your next install and deploy, showing up
as a new organ in that deploy.

(Codex gets the opposite advice — `peerDependency` — for the opposite reason: it is composed *by*
an app, so the app should own the version and there must be exactly one copy. Same package,
different declaration, each following from what the thing is.)

## The one thing your brief asks for that Codex's does not

**A boot-time existence check over every entrypoint the automaton and connectors call.**

You are fail-closed, which means a dead read is indistinguishable from an empty world. One check
at startup — *does every name I will call exist?* — converts a silent fleet-wide outage into a
loud startup failure. For an auth cache, that is worth more than the migration itself.

## And one thing to resist

You are the chokepoint — all daimon traffic routes through you — so a rewriting shim that fixes
everyone's stale names at the transport is tempting. **Don't.** OuronetUI does exactly that in
`staleNames.ts`, whose own header reads *"THIS IS A SHIM AND SHOULD DIE"*, and it is precisely
why the Codex cannot tell that nineteen of its names are broken. A shim that works is a shim that
hides what it patches; moving it to the chokepoint would hide every consumer's staleness from
every host.

**Diagnose, never rewrite.** Naming a dead symbol in an error response is a real service. Making
it live for someone else is how you become load-bearing for their bugs.

## Also yours to know

Four of the Codex's nineteen dead names are **your own contract's**, and the middle two renamed
the *operation*, not just the prefix:

```
PYTHIA|INFO_DeployApiKey           -> INFO_PYTHIA|DeployApiKey
PYTHIA|INFO_LinkDualApiKey         -> INFO_PYTHIA|Link
PYTHIA|INFO_UnlinkDualApiKey       -> INFO_PYTHIA|RevokeLink
PYTHIA|INFO_UpdateDualConsumerLane -> INFO_PYTHIA|UpdateDualConsumerLane
```

A consumer doing the mechanical `CATEGORY|INFO_x → INFO_CATEGORY|x` flip fixes two of four and
silently leaves two broken. That is what happened, for weeks. **The residue of a mechanical
rename is exactly the entries its key could not express** — and here that residue is in the
previews consumers are most likely to call.

## Done means

- zero `ouronet-ns.` literals in your source
- a boot-time existence check over every name the automaton and connectors use
- `surfaceHash` + package version reported in `health`
- a test walking every key through `tryGetEntrypoint`, so the next rename fails your suite rather
  than your fleet's authentication

# Pythia agent — adopting `@ouronet/talos-registry`

**Read [`HANDOFF-talos-registry.md`](HANDOFF-talos-registry.md) first** for what the package is,
its API, and the three traps. This file is your brief.

> **CORRECTED 2026-09-26.** An earlier version of this document told you that you build no Pact
> calls and probably need no dependency. That was wrong, and the way it was wrong is the same
> mistake this whole package exists to stop: **the measurement was narrower than the claim.** It
> counted Pact names in the published `@ancientpantheon/pythia-client` `dist/` — a thin transport
> client, 0 names — and reported that as "Pythia has no Pact names". The constructor repo has
> **32**, the automaton and connectors among them. The conclusion was drawn from the wrong
> directory, stated confidently, and would have left the outage in §1 in place.

---

## 1. One of those names was breaking authentication fleet-wide

`apps/pythia/src/connectors/auth/dualLinkCache.ts` called

```
(ouronet-ns.PYTHIA.URD_ListActiveDualLinks)
```

Asked of mainnet: **`Module ouronet-ns.PYTHIA has no such member`.** The deployed name is
`URH_ListActiveDualLinks`, and it returns **6 rows** today.

What that costs is written in the file's own docstring, because **this is the second time**:

> *NOTE (v3.0.2): this previously called `UR_ActiveDualLinkSet`, which does NOT exist on the
> deployed `ouronet-ns.PYTHIA` module — the read failed on every poll, the fail-closed cache
> stayed empty, and so EVERY consumer's account read as inactive (all `/verify` → `202 pending`,
> no `x-pythia-key` ever minted, fleet-wide). Repointed to `URD_ListActiveDualLinks` — the live
> function the landing page already uses.*

**The v3.0.2 fix swapped one non-existent name for another** and reproduced the outage it was
written to end. Same empty fail-closed cache, same fleet-wide `202 pending`, same silence.

**Fixed** (`URD_` → `URH_`), tests pass, tsc clean, and the docstring now records both rounds.

### Why it happened twice, and why a third repoint is not the fix

A Pact call naming a function that does not exist is a **resolution error**. `try` cannot catch
it. Nothing throws at the call site. A fail-closed cache then turns it into *"nobody is
authorised"* rather than *"this read is broken"* — which looks exactly like a quiet day.

The author was careful. They wrote the incident up, named the failure mode precisely, and chose a
replacement they believed was live. **Care was not the missing ingredient. A source of truth was.**
`tryGetEntrypoint("PYTHIA.URD_ListActiveDualLinks")` returns `undefined`, and
`resolveByName("ListActiveDualLinks")` offers `URH_`. At build time. Both times.

---

## 2. Your Pact surface

Five names in your own source, four fine:

| name | status |
|---|---|
| `PYTHIA.URH_ListActiveDualLinks` | **was `URD_` — fixed** |
| `PYTHIA.UR_Counterpart` | resolves |
| `PYTHIA.UR_Public` | resolves |
| `PYTHIA.UR_PythLedgerEpochStart` | resolves (`2026-08-01T00:00:00Z`) |
| `TS01-C4.PYTHIA\|A_RevokeLink` | resolves |

Across the constructor repo including vendored code there are 32, overlapping heavily with the
Codex's — so expect the same rot when you audit: `INFO-ZERO.DALOS-INFO|URC_*` moved to
`INFO-ONE.INFO_DALOS|*`, `…StoaChain` dropped to `…Stoa`, and the whole `DPL-UR` family was
retired into the per-app AppReads modules.

### Four of the Codex's dead names are your own contract

```
PYTHIA|INFO_DeployApiKey           -> INFO_PYTHIA|DeployApiKey
PYTHIA|INFO_LinkDualApiKey         -> INFO_PYTHIA|Link
PYTHIA|INFO_UnlinkDualApiKey       -> INFO_PYTHIA|RevokeLink
PYTHIA|INFO_UpdateDualConsumerLane -> INFO_PYTHIA|UpdateDualConsumerLane
```

Note the middle two: the **operation** was renamed, not just the prefix. A consumer doing the
mechanical `CATEGORY|INFO_x → INFO_CATEGORY|x` flip fixes two of four and silently leaves two
broken — which is exactly what happened, for weeks. **The residue of a mechanical rename is the
entries its key could not express**, and here that residue is in your surface.

---

## 3. Migration

1. **`npm i @ouronet/talos-registry`** — direct, not through `ouronet-core`. Nothing re-exports
   it; core's dependency is a devDependency used by one test and never ships.
2. **Inventory your own source, not just a published dist.** That distinction is what made the
   first draft of this document wrong. Also check for namespace **aliases** —
   `const NS = KADENA_NAMESPACE`, `import { KADENA_NAMESPACE as NS }`, a value passed as a prop.
   And strip comment-only lines, or you will chase prose mentions.
3. **Check every name** with `tryGetEntrypoint` / `resolveByName`.
4. **Replace the string builders with `buildCall` / `buildPreviewCall`.** Delete argument-order
   constants — they go stale without saying so.
5. **Add a startup assertion for the reads the automaton depends on.** You are fail-closed, which
   means a dead read is indistinguishable from an empty world. One check at boot — *does every
   name I will call exist?* — converts a silent fleet-wide outage into a loud startup failure.
   For an auth cache that is worth more than the migration itself.
6. **Report `surfaceHash` and the package version in `health`.** Two daimons on different
   surfaces are composing different contracts, and right now nothing in the fleet would say so.

### One thing to resist

You are the chokepoint — all daimon traffic routes through you — so it is tempting to add a
rewriting shim and fix everyone's stale names at the transport. **Don't.**

OuronetUI does exactly that in `staleNames.ts`, and its own header says *"THIS IS A SHIM AND
SHOULD DIE."* It is why the Codex cannot tell that nineteen of its names are broken: something
else is quietly correcting them. A shim that works is a shim that hides what it patches. Moving
that into Pythia would hide every consumer's staleness from every host and drop the incentive to
fix a name to zero.

**Diagnose, never rewrite.** Naming a dead symbol in an error response is a real service. Making
it live for someone else is how you become load-bearing for their bugs.

---

## 4. Definition of done

- zero `ouronet-ns.` literals in your source
- a boot-time existence check over every entrypoint the automaton and connectors use
- `surfaceHash` + version in `health`
- a test that walks every key through `tryGetEntrypoint`, so the next rename fails your suite
  rather than your fleet's authentication

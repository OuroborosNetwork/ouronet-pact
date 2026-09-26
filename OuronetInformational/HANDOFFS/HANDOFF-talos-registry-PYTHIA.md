# Pythia agent — `@ouronet/talos-registry`, and why your brief is the opposite of the Codex's

**Read [`HANDOFF-talos-registry.md`](HANDOFF-talos-registry.md) for what the package is.** This
file exists because you were pointed at the same package as the Codex agent and **you should not
adopt it the same way — quite possibly not at all.**

---

## 1. The measurement that decides this

Every `ouronet-ns.<module>.<function>` string in each package's `dist/`:

| package | distinct Pact names | dead on mainnet |
|---|---:|---:|
| `@ancientpantheon/codex` | 34 | **19** |
| `@ancientpantheon/pythia-client` | **0** | — |

**You build no Pact calls.** You carry them. Nineteen of the Codex's names are broken and it
cannot tell, because OuronetUI rewrites them at the transport before they leave the browser;
none of yours are broken, because you have none.

So the Codex brief — *"replace your hand-written call strings with `buildCall`"* — has no subject
in your codebase. **If you take one thing from this document: do not go looking for call strings
to migrate. There are none, and inventing some to justify the dependency would be the wrong
outcome.**

---

## 2. What you are, in this failure mode

You are the chokepoint. *"All daimon blockchain traffic routes through Pythia."* That is
architecturally interesting here for one reason:

**A Pact resolution error is invisible to the caller.** A call naming a function that does not
exist is not an exception — `try` cannot catch it — it is a failed response. Every consumer bug
found this month surfaced as an **empty panel**, never as an error:

- `URD_OwnedSwapPairs` (renamed to `URH_`) → *"Demo Mode — your account does not own any pools"*,
  shown to the owner of the pool
- `DPL-UR.URC_0031` → the API-key list simply rendered empty
- a 4-argument call to a 5-parameter reader → Pact **partially applies** and returns a *closure*;
  Spark purchases could not be funded, with nothing in any log

Each of those crossed a transport. **You are the only layer that sees all of them, from every
consumer, and you are the only layer positioned to say `this call names a function that does not
exist` instead of returning an empty result.**

---

## 3. The two things worth considering — and neither is "use `buildCall`"

### A. Name a resolution failure, don't just relay it

Cheap, additive, and it changes nothing about what you send. When a response comes back failed,
match the error against the registry before handing it on:

```ts
import { tryGetEntrypoint, resolveByName } from "@ouronet/talos-registry";
// "Module ouronet-ns.SWP has no such member: URD_OwnedSwapPairs"
//   -> registry has no such key
//   -> resolveByName("URD_OwnedSwapPairs") -> did you mean URH_OwnedSwapPairs?
```

The consumer still gets its failure. It gets a *named* one, once, instead of a blank panel and an
afternoon.

**This is a diagnostic, not a rewrite. Do not silently correct the call** — see §4.

### B. Report the surface you are compiled against

One line in `health`. Two consumers on different `surfaceHash`es are composing different contract
surfaces, and right now nothing in the system would say so. You are where that is observable for
everyone at once.

---

## 4. The argument against, which you should weigh seriously

**A transport that knows about contracts is no longer a transport.**

OuronetUI's `staleNames.ts` rewrites 52 names on the way out. It is explicitly a shim, and its own
header says so: *"THIS IS A SHIM AND SHOULD DIE."* It exists because the consumers could not be
fixed in time, and its cost is exactly what this document opens with — **the Codex cannot tell
that nineteen of its names are broken, because something else is quietly fixing them.** A shim
that works is a shim that hides the thing it patches.

If you take that same rewriting into Pythia you would make it worse, not better: now *every*
consumer's staleness is hidden, from every host, and the incentive to fix a name drops to zero.

So: **diagnose, never rewrite.** Say the name is dead. Do not make it live. The difference between
those two is the difference between a transport that helps and one that becomes load-bearing for
other people's bugs.

If you conclude Pythia should stay a dumb pipe and take no dependency at all, **that is a
defensible answer** and I would rather you reach it deliberately than adopt a package because it
arrived in the same message as someone else's migration.

---

## 5. If you do adopt it

- `npm i @ouronet/talos-registry` — direct, not through `ouronet-core` (nothing re-exports it;
  core's dependency is a devDependency used by one test and never ships)
- it does **not** sign, submit, or hold keys — it renders strings and answers questions about the
  surface. Your transport and your key handling stay entirely yours
- 66 kB, one bundled JSON snapshot, no network at runtime, no peer dependencies
- pin `^1.1.0` and surface the version; the version moves when the *data* moves, not only the API

## 6. One thing that is genuinely yours

Four of the Codex's dead names are **your own contract's**:

```
PYTHIA|INFO_DeployApiKey          -> INFO_PYTHIA|DeployApiKey
PYTHIA|INFO_LinkDualApiKey        -> INFO_PYTHIA|Link
PYTHIA|INFO_UnlinkDualApiKey      -> INFO_PYTHIA|RevokeLink
PYTHIA|INFO_UpdateDualConsumerLane-> INFO_PYTHIA|UpdateDualConsumerLane
```

Note the middle two: the operation was renamed, not just the prefix, so a consumer doing the
mechanical `CATEGORY|INFO_x → INFO_CATEGORY|x` flip fixes two of these four and silently leaves
the other two broken. That happened — it is why `Link` and `RevokeLink` went unshimmed for weeks
while their two neighbours were fixed.

Whatever you decide about the dependency, **that is worth knowing about your own surface**: the
PYTHIA previews a consumer is most likely to call are the two hardest to rename correctly.

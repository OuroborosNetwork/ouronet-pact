# `@ouronet/talos-registry` — for the Codex and Pythia agents

**What to do with this document:** it replaces hardcoded Pact call strings with a package you
install. Read §1 and §2 before touching code; §5 is the migration.

---

## 0. The one-paragraph version

Every consumer that talks to Ouronet builds Pact strings by hand — a module name, a function
name, arguments in a remembered order. Those strings drift from the contracts and **nothing
fails loudly when they do**. `@ouronet/talos-registry` is the deployed callable surface as data:
423 entrypoints, their parameters in declared order, their `INFO_` cost previews, capability
recipes and example values. **You supply values; you never type a function name, an argument
order, or an arity.**

```ts
import { buildCall } from "@ouronet/talos-registry";

buildCall("TS01-C1.DPTF|C_Transfer", {
  patron: "Σ.…", executor: "Σ.…", executee: "Σ.…",
  id: "OURO-8Nh-JO8JO4F5", "transfer-amount": 1, method: false,
});
// (ouronet-ns.TS01-C1.DPTF|C_Transfer "Σ.…" "Σ.…" "Σ.…" "OURO-8Nh-JO8JO4F5" 1.0 false)
```

Note `1` became `1.0`: Pact's decimal lexer rejects a bare integer in a decimal slot, and that is
the least interesting thing this package stops you getting wrong.

---

## 1. Why you specifically need it — measured, not argued

**The codex package's hardcoded names are already broken, and you cannot see it from inside
OuronetUI.** Asked of mainnet today:

```
ouronet-ns.CODEX.CODEX|INFO_RegisterStoicTag   -> has no such member
ouronet-ns.CODEX.CODEX|INFO_ReleaseStoicTag    -> has no such member
ouronet-ns.INFO-ZERO.DALOS-INFO|URC_DeploySmartAccount -> has no such member
ouronet-ns.DPL-UR.URC_0031                     -> has no such member
```

They work **only** because OuronetUI rewrites them at the transport, in `staleNames.ts` and
`appReadRedirect.ts`, before they leave the browser. `CODEX|INFO_x` became `INFO_CODEX|x`;
`DPL-UR` was stubbed and its reads moved to the AppReads modules.

So the codex organ is not standalone today — **it is standalone-shaped and OuronetUI-dependent in
fact.** Run it anywhere else and those calls fail as *resolution* errors, which `try` cannot
catch and which surface as an empty panel rather than an exception.

That is the architecture this package replaces. Not "a nicer API" — a correctness problem you
currently cannot observe.

### The failure mode is always silence

Every consumer bug found this month was a hand-written template that drifted, and **none failed
loudly**:

| what was wrong | what the user saw |
|---|---|
| 4 args sent to a 5-parameter reader | Pact **partially applies** and returns a *closure*. No error. Spark purchases could not be funded. |
| `C_ChangeOwnership` reordered its parameters | 3 args in the old order — tx built, chain refused after signing |
| `URD_OwnedSwapPairs` renamed to `URH_` | "Demo Mode — your account does not own any pools", shown to the owner of the pool |
| `URC_0012_HibernateFee` never existed at all | a hardcoded fallback fee rendered as though it came from chain |

A short call in Pact is not an error. **That single fact is why this package exists.**

---

## 2. What it is, and what it deliberately is not

**A bundled snapshot, pinned at build time.** Generated from the chain by
`REPL/tools/_registry.py` (`describe-module` against mainnet), copied in at build, versioned.

It does **not** refresh at runtime, on purpose: that would add a trust surface (whatever a node
returns) and a failure mode (offline ⇒ no registry) that a pinned artefact does not have.

It does **not** sign, submit, or hold keys. It renders call strings and tells you what a call
needs. Your transport stays yours.

**`surfaceHash` identifies exactly which contract surface a build was compiled against.** Two
consumers showing different hashes are composing different surfaces — visibly, before it becomes
a bug report.

### Version discipline

The version moves whenever the *data* moves, not only the code. `1.0.0 → 1.1.0` was a ghost-value
change with no API change and no contract change. Surface `67c0979111eb156b → 7e59e59d4c5b7257`.

**Show the version in your settings UI.** OuronetUI does, in its integrated-packages panel, read
live from `node_modules/<pkg>/package.json` so it cannot lie about what is installed.

---

## 3. API

```ts
// rendering
buildCall(key, values)          // execution call string
buildPreviewCall(key, values)   // its INFO_ preview call string
buildGhostCall(key)             // a complete call using example values — for smoke tests

// asking
getEntrypoint(key)              // throws if absent
tryGetEntrypoint(key)           // undefined if absent
getPreview(key)
entrypointKeys() / modules() / entrypointsOfModule(m)
resolveByName(name)             // fuzzy: "C_Transfer" -> candidates

// planning
planCall(key, values)           // what this call needs: caps, sponsorship, execution mode
explainCall(key)                // human-readable

// capabilities
parseCapability(s) / parseCapabilities(ss) / capabilityRecipe(key)

// formatting, if you must build a string yourself
formatForType(value, pactType)  // the decimal rule, the keyset rule, the list rule
```

Each entrypoint carries: `params` (name + Pact type, **in declared order**), `returns`,
`preview`, `ownership` (whose key must sign, and whether that is conditional), `sponsorship`
(gas-station or not, and under which capability), `execution` (`direct` / `indirect-*` /
`defpact`, with the preflight read named when there is one), and `ghost` (example values).

---

## 4. The three traps

**① The preview's parameter list is NOT the entrypoint's.** 410 of 423 differ.

```
C_Transfer        (patron executor executee id transfer-amount method)
INFO_DPTF|Transfer (patron id sender receiver transfer-amount)
```

If you substitute real values into a preview call, key them on the **preview's** names. Merging
positionally against the execution signature puts an account into an `id` slot on 97% of calls —
silently, with a confident cost beside it. `getPreview(key).params` is the list you want.

**② Ghost values are illustrative, not a fixture.** Accounts and token ids are read from mainnet
and real; **entity ids are often the literal `"example"`** (227 slots — `fvt-id`, `pool-id`,
`score-id`). That is deliberate: a plausible-looking fake id returns a confident number for an
entity nobody owns, and an obviously-fake value is the better failure. Substitute your own before
showing a user a number.

**③ `execution.mode` is not decoration.** An `indirect-*` entrypoint takes an argument that is
the *output of another read* — `SWP|C_SmartSwap*` needs a route `bundle` assembled from four
preflight reads. Calling it without one does not error; Pact partially applies it. `planCall`
names the preflight.

---

## 5. Migration

1. **Install.** `npm i @ouronet/talos-registry` — a direct dependency, not through `ouronet-core`.
   It is a **sibling** of `ouronet-core`, not part of it: nothing in `ouronet-core` re-exports it,
   and core's own dependency on it is a devDependency used by one test, which never ships. Each
   consumer installs it so each consumer's version is its own and visible.
2. **Inventory what you hardcode.** `grep -o 'ouronet-ns\.[A-Za-z0-9|_-]*\.[A-Za-z0-9|_-]*'` over
   your `dist/`. Watch for namespace ALIASES — `const NS = KADENA_NAMESPACE`,
   `import { KADENA_NAMESPACE as NS }`, a JSX prop — a scan that knows only the literal spelling
   missed four files in OuronetUI, including the one with the live Spark bug.
3. **Check each against the registry** with `tryGetEntrypoint` / `resolveByName`. Anything
   absent is either renamed or gone. Expect the `CODEX|INFO_x → INFO_CODEX|x` flip and the whole
   `DPL-UR` family.
4. **Replace the string builders with `buildCall`.** Delete your argument-order constants.
5. **Drop your reliance on OuronetUI's shims.** Once the names come from the registry there is
   nothing left for `staleNames.ts` to rewrite, and the codex organ becomes genuinely standalone.
6. **Surface `surfaceHash` and the package version in settings.**

### What to do when the contracts move

The registry is regenerated in the Pact repo (`_registry.py --probe`), the package version is
bumped, you update your pin. `_registrylive.py` is what proves a snapshot still matches mainnet —
one `describe-module` per module, and a Pact module hash changes on any redeploy, so twelve calls
settle all 423 entrypoints.

**Do not hand-edit the bundled JSON.** Consumers would validate against it and get confident
wrong answers, which is the failure this package exists to remove.

---

## 6. Status

| | |
|---|---|
| version | `1.1.0` |
| surface | `7e59e59d4c5b7257` |
| entrypoints | 423 (+428 previews) |
| verified against mainnet | 12 modules, 0 drifted |
| tests | 461 |
| package size | 66 kB (1.6 MB unpacked — the snapshot) |

Consumers today: **OuronetUI** (direct dependency; drives 409 execution tooltips) and
**`ouronet-core`** (devDependency; one test checks all 39 of its Pact builders against the
declared arities — it found six wrong).

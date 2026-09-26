# Codex agent — adopting `@ouronet/talos-registry`

**Read [`HANDOFF-talos-registry.md`](HANDOFF-talos-registry.md) first** for what the package is,
its API, and the three traps. This file is your migration, and it opens with a measurement rather
than a recommendation.

---

## 1. Nineteen of your thirty-four contract names do not exist

Every `ouronet-ns.<module>.<function>` string in `@ancientpantheon/codex@0.11.0`'s `dist/`, asked
of mainnet on 2026-09-26:

**34 distinct names · 19 return `has no such member` · 15 resolve.**

They work today **only inside OuronetUI**, which rewrites them at the transport in
`staleNames.ts` and `appReadRedirect.ts` before they leave the browser. Outside that host — which
is what "standalone codex package" means — every one of the nineteen fails as a **resolution
error**. Pact resolution errors are not catchable by `try`, so they do not raise in your code:
they come back as a failed response and surface as an empty panel.

So the codex organ is standalone-*shaped* and OuronetUI-dependent in fact. That is the thing this
migration fixes. The package is how you stop needing someone else's shim.

### The nineteen, with their live replacements

All verified against mainnet.

| dead name | live replacement |
|---|---|
| `CODEX.CODEX\|INFO_RegisterStoicTag` | `CODEX.INFO_CODEX\|RegisterStoicTag` |
| `CODEX.CODEX\|INFO_ReleaseStoicTag` | `CODEX.INFO_CODEX\|ReleaseStoicTag` |
| `DALOS.UR_AccountStoaChain` | `DALOS.UR_AccountStoa` |
| `TS01-C1.DALOS\|C_RotateStoaChain` | `TS01-C1.DALOS\|C_RotateStoa` |
| `INFO-ZERO.DALOS-INFO\|URC_DeploySmartAccount` | `INFO-ONE.INFO_DALOS\|DeploySmartAccount` |
| `INFO-ZERO.DALOS-INFO\|URC_DeployStandardAccount` | `INFO-ONE.INFO_DALOS\|DeployStandardAccount` |
| `INFO-ZERO.DALOS-INFO\|URC_RotateGovernor` | `INFO-ONE.INFO_DALOS\|RotateGovernor` |
| `INFO-ZERO.DALOS-INFO\|URC_RotateGuard` | `INFO-ONE.INFO_DALOS\|RotateGuard` |
| `INFO-ZERO.DALOS-INFO\|URC_RotateSovereign` | `INFO-ONE.INFO_DALOS\|RotateSovereign` |
| `INFO-ZERO.DALOS-INFO\|URC_RotateStoaChain` | `INFO-ONE.INFO_DALOS\|RotateStoa` |
| `PYTHIA.PYTHIA\|INFO_DeployApiKey` | `PYTHIA.INFO_PYTHIA\|DeployApiKey` |
| `PYTHIA.PYTHIA\|INFO_LinkDualApiKey` | `PYTHIA.INFO_PYTHIA\|Link` |
| `PYTHIA.PYTHIA\|INFO_UnlinkDualApiKey` | `PYTHIA.INFO_PYTHIA\|RevokeLink` |
| `PYTHIA.PYTHIA\|INFO_UpdateDualConsumerLane` | `PYTHIA.INFO_PYTHIA\|UpdateDualConsumerLane` |
| `DPL-UR.URC_0027_AccountSelectorMapper` | `O-UI-SEVEN.URC_01\|Accounts` |
| `DPL-UR.URC_0027b_StoicTagSelectorMapper` | `O-UI-SEVEN.URC_03\|StoicTags` |
| `DPL-UR.URC_0027c_StoicTagSelectorSingle` | `O-UI-SEVEN.URC_04\|StoicTag` |
| `DPL-UR.URC_0028_StoaAccountSelectorMapper` | `O-UI-SEVEN.URC_05\|StoaAccounts` |
| `DPL-UR.URC_0031` | `P-UI-ONE.URC_01\|ApiKeys` |

**Three patterns, and each says something about why a name list rots.**

- **A prefix flip.** `CATEGORY|INFO_Action` → `INFO_CATEGORY|Action`. Mechanical — and note
  `INFO_LinkDualApiKey → INFO_PYTHIA|Link` is *not*, because the operation was renamed too. A
  sweep keyed on the prefix reached `DeployApiKey` and `UpdateDualConsumerLane` and could not
  reach `Link` and `RevokeLink`. **The residue of a mechanical rename is exactly the entries its
  key could not express.**
- **The Kadena → Stoa sweep.** `…StoaChain` → `…Stoa` on both a reader and an executor.
- **DPL-UR was retired.** Its reads moved into the per-app AppReads modules. `URC_0031` is not a
  rename at all — it now lives in `P-UI-ONE`, a module built for the Pythia surface.

> **`ouronet-ns.CODEX.register-codex-identity` is a false positive** — it appears in a doc comment
> describing a signature, not in a call. Reported here because the grep that finds these will hit
> it too, and chasing a prose mention is how an audit loses an afternoon.

---

## 2. Why the table is not the fix

You could paste those nineteen replacements in and be correct until the next rename. That is the
loop this package exists to break: the names above were each correct when they were written.

`buildCall` takes the key and your **values**; it renders the name, the order and the types from
the deployed surface:

```ts
import { buildCall, buildPreviewCall, tryGetEntrypoint } from "@ouronet/talos-registry";

buildCall("TS01-C4.CODEX|C_RegisterStoicTag", { patron, executor, "stoic-tag": tag });
buildPreviewCall("TS01-C4.CODEX|C_RegisterStoicTag", { patron, executor, "stoic-tag": tag });
```

When a contract moves, you bump the package. Nothing in your source names a function.

---

## 3. Migration

1. **`npm i @ouronet/talos-registry`** — a direct dependency of *your* package, not through
   `ouronet-core`. Nothing re-exports it; core's own dependency is a devDependency used by one
   test and never ships. Yours is yours, and its version shows in your settings.
2. **Inventory.** `grep -rho 'ouronet-ns\.[A-Za-z0-9|_-]*\.[A-Za-z0-9|_-]*' dist/ | sort -u`.
   **Then check for namespace ALIASES** — `const NS = KADENA_NAMESPACE`,
   `import { KADENA_NAMESPACE as NS }`, a value passed as a JSX prop. A scan that knows only the
   literal spelling missed four files in OuronetUI, one of which held a live funding bug. Strip
   comment-only lines before matching, or `register-codex-identity` will be in your results.
3. **Check each with `tryGetEntrypoint` / `resolveByName`.** Absent means renamed or gone.
4. **Replace the string builders with `buildCall` / `buildPreviewCall`.** Delete your
   argument-order constants — they are the thing that goes stale silently.
5. **Drop the OuronetUI shim dependency.** Once names come from the registry there is nothing for
   `staleNames.ts` to rewrite, and the organ is genuinely standalone. Verify it: import your
   package into an empty directory and exercise it with no OuronetUI present. That is the test
   that would have caught all nineteen.
6. **Show `surfaceHash` and the package version in settings**, so a mismatch with OuronetUI's is
   visible before it is a bug report.

### One trap that will bite you specifically

You call both executions and their `INFO_` previews. **410 of 423 previews take a different
parameter list from their entrypoint.** `INFO_DPTF|Transfer` is
`(patron id sender receiver transfer-amount)`; `C_Transfer` is
`(patron executor executee id transfer-amount method)`. If you substitute real values into a
preview, key them on `getPreview(key).params` — merging positionally against the execution
signature puts an account into an `id` slot on 97% of calls, silently, with a confident number
beside it.

---

## 4. Definition of done

- zero `ouronet-ns.` literals in your source
- your package exercised from an empty directory, with no OuronetUI in the tree
- `surfaceHash` + version rendered in settings
- a test that walks every key you use through `tryGetEntrypoint`, so a future rename fails your
  suite instead of a user's panel

# Codex agent — the pre-ZBOM tooltip, and the per-consumer settings zone

Two asks, and the second is the one worth your attention: **verify the consumer-settings
mechanism is sound**, because every app preference from here on goes through it.

---

## 0. The answer to "is it constructed properly": yes, and better than expected

`IConsumerSettings` in `@ancientpantheon/codex`:

```ts
interface IConsumerSettings {
  consumerName: string;     // registry key -- "OuronetUI", "Mnemosyne", …
  consumerVersion: string;  // the app's semver at write time
  schemaVersion: number;    // rejects a STRICT downgrade; equal is allowed
  settings: Record<string, unknown>;   // opaque, round-trips verbatim
  lastUpdatedAt: string;    // SERVER-stamped, so it is a trustworthy marker
}
```

stored as `Record<string, IConsumerSettings>` and reached through
`actions.getConsumerSettings(name)` / `actions.updateConsumerSettings(entry)`.

Four properties that matter, all already present:

- **Namespaced by consumer**, so OuronetUI and the standalone Codex hold *different answers to
  the same preference for the same user* — exactly the behaviour asked for.
- **Opaque payload.** The package never inspects those keys. Neither app has to teach the other
  about its settings.
- **Downgrade protection** on `schemaVersion`, so an older build cannot quietly overwrite a
  newer schema.
- **`lastUpdatedAt` is stamped by the store**, not the caller — a caller-supplied timestamp is
  overridden, so it cannot lie.

**Nothing needs adding to the mechanism.** What was missing was a *user*: OuronetUI has written
an entry since the v0.2→v0.3 migration and its `settings` payload was `{}` — the zone existed
and nothing had ever put anything in it. This is the first.

### Two rules the shape does not enforce, and both have already bitten

1. **MERGE, never replace.** `updateConsumerSettings` overwrites the entry. Writing
   `settings: { myKey: v }` drops every other key — including ones a *newer* build of your own
   app wrote. Always `{ ...(existing?.settings ?? {}), [key]: v }`.
2. **Never lower `schemaVersion`.** `Math.max(existing?.schemaVersion ?? 0, YOURS)`. A hardcoded
   constant is a rejected write the day someone bumps it and an old tab is still open.

---

## 1. What OuronetUI just shipped, to mirror

**The tooltip.** Hover any button that OPENS a ZBOM and see: the function it will call, its
parameters *as the contract declares them*, the arguments positionally against them, and a live
`/local` cost preview. If the cost renders, the whole path resolved — names, arity, types.

Components: `ExecutionHint` (hover, portal, placement) wrapping `ExecutionTooltip` (render +
preview read). Both driven by `@ouronet/talos-registry`, so there is no Pact string in either.

**The setting.** `Pre-ZBOM Tooltip`, **default ON**, in Settings → ZBOM. Off means off: no read
fires and nothing renders.

**The persistence.** `hooks/useCodexBackedSetting.ts` — Redux holds the live copy for reactive
reads, the codex holds the authoritative one. `CodexDataBridge` seeds Redux from the codex once
on load; the hook writes both on change.

> The write-back lives with the SETTER, not in a watcher on the live copy. A watcher cannot tell
> a user's change from a hydration, so it writes back what it just read — and against
> downgrade-protected storage a spurious write is not free.

---

## 2. Your work

1. **If the tooltip does not exist in the Codex UI, implement it.** Same shape: hover a
   ZBOM-opening button, show the entrypoint, its declared parameters, the arguments, and a live
   preview. Use `@ouronet/talos-registry` (`buildPreviewCall` / `getEntrypoint`) so no Pact
   string is written by hand — see `HANDOFF-talos-registry-CODEX.md`.
2. **Add the same setting** to the Codex's own ZBOM settings, default ON.
3. **Persist it under YOUR consumer name**, not `"OuronetUI"`. That separation is the feature:
   on in one app, off in the other, one codex.
4. **Read it back on load**, so the preference actually travels.

### Three traps, from building it here

- **The tooltip belongs on the LAUNCHER, not on the ZBOM's own execute button.** Owner ruling.
  Inside a ZBOM the information is already on the page — the input zone lists every parameter
  with its declared type, the INFO panel shows the cost — and a tooltip there draws *over* the
  modal it annotates.
- **Arguments belong to the PREVIEW, not the execution.** 410 of 423 entrypoints have a preview
  whose parameter list differs from their entrypoint's. Labelling preview values with execution
  parameter names shifts everything after the first — it rendered
  `executor = <the pool id>`, `swpair = true`, `toggle = MISSING` for a call that was correct.
- **Key the preview effect on the rendered CALL STRING, not on a values object.** A caller
  passing an inline literal gets a new object every render; keying on identity re-fires the
  read, which sets state, which re-renders. The INFO panel refreshed forever on a ZBOM whose
  inputs were all fixed before it opened.

### Worth enforcing rather than remembering

The rule is *every* ZBOM-opening button, which is a statement about a class. Here the Define
buttons were missed once, because they are plain `<button>`s while their neighbours go through a
shared component — so a wrapper on that component looked like it covered everything.
`src/__tests__/prezbom-tooltip.test.ts` walks every launcher and fails on a naked one; it models
both coverage forms (a textual wrap, or an `entrypoint=` on a component that wraps internally)
and excludes `onClose` handlers, which close a ZBOM rather than open one.

---

## 3. And the wider point

This is the first thing in that zone. Every OuronetUI and Codex preference from here belongs
there rather than in `localStorage`: it follows the codex across machines, it is namespaced per
app, and it is the only store either app has that a user already carries deliberately.

`localStorage` remains correct for what is genuinely per-device — a window size, a cached
password timeout. The test is whether the user would expect it to follow them.

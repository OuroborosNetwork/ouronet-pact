# REPL Test Architecture — the two-variant rebuild

Owner-directed (2026-09-04). The REPL test surface is rationalised into **two variants that share
one deploy core and one set of suite files**, so the same tests power both an exhaustive run and
fast single-module iteration with zero duplication.

## The two variants

### 1. `ZALL.repl` — the exhaustive top-to-bottom runner
One `pact ZALL.repl` deploys the **entire** stack (Stage 00 → 01 → 02 → ZZ) and runs **every
scenario suite we have ever built** — every module, every client/admin function, every ground-truth
and regression harness — in one long run (accepting ~an hour). This is the single authoritative
"tests EVERYTHING" artifact and the exact shape the red team attacks.

- **Segmentable.** `ZALL.repl` is a flat, banner-grouped list of `(load …)` lines, each individually
  commentable, grouped by module/stage. Disabling a group gives a faster partial big-run. (For true
  single-module iteration, use variant 2 — that's its job.)
- **Contamination-resolved.** Because one `pact` process = one shared DB, suites that mutate shared
  canonical fixtures (account-guard rotations, canonical-asset re-issues) are made order-independent
  — see *Contamination strategy* below. This is the real work of assembling ZALL.

### 2. `modules/<MODULE>.repl` — standalone per-module testers
Each bootstraps a **minimal blockchain-like environment in a single REPL flow**: Stage 00 sandbox +
deploy the module's dependency closure + run that module's own suite(s). `pact modules/DPTF.repl`
tests just DPTF in ~seconds-to-a-minute, so you never boot the whole world to check one edit. This is
our stand-in for "keep a local devnet running and test against it" (a real StoaChain private
dev/testnet is a later, separate decision).

## The shared core (why there is no duplication)

The connective tissue answering "do the individual testers plug into the big flow?":

- **Deploy core** — the deploy sequence already separates cleanly from suites in each stage tester
  (`[0.0]`–`[5.2]` = deploy; `[6.x]` = suites). It is extracted into authoritative includes:
  `deploy-stage00.repl`, `deploy-stage01.repl`, `deploy-stage02.repl`, `deploy-stagezz.repl`.
- **Suite files** — the `Stage_0N/[6.x]_*.repl` scenario files ARE the tests, unchanged.
- **Both variants compose the same pieces.** ZALL = all deploy cores + all suites. A module tester =
  sandbox + deploy core up to its deps + its suite file(s). So a module tester's "core parts" (its
  deploy deps and its suite file) are literally the same files ZALL loads; only the thin wrapper that
  selects *deploy depth + which suites* is per-module. Suites are never duplicated.

## File layout (constrained by `(load)` semantics)

**Verified:** Pact `(load "x")` resolves relative to the **loading file's directory**, not the
process CWD. Therefore:

```
REPL/
  Z.repl                # KEEP: fast dev loop (AQP subset) — quick daily iteration
  ZALL.repl             # NEW: exhaustive runner (everything)
  deploy-stage00.repl   # NEW: extracted deploy cores (in REPL/ root so "Stage_0N/…" loads resolve)
  deploy-stage01.repl
  deploy-stage02.repl
  deploy-stagezz.repl
  Stage_00/ Stage_01/ Stage_02/   # suites (unchanged test bodies)
  modules/              # NEW: standalone per-module testers
    DPTF.repl SWP.repl ATS.repl DPOF.repl VST.repl DALOS.repl DPDC.repl
    DEMIPAD.repl CODEX.repl PYTHIA.repl DSP.repl LIQUID.repl SWPI.repl …
    AQP-ANK.repl AQP-SCORE.repl AQP-POOL.repl RPS.repl FVT.repl VCT.repl MTX-AQP.repl DSA.repl
  # module testers use one-level `(load "../deploy-stageNN.repl")` + `(load "../Stage_0N/…")`
```

Deploy cores live in `REPL/` root so their `(load "Stage_0N/…")` paths stay root-relative. Module
testers sit one level down and reach up with `../`.

## Contamination strategy (making ZALL green end-to-end)

Discovered while enabling the full chain: some suites rotate the canonical account (`KST.ANHD`) guard
or re-issue canonical assets (MVST), breaking later suites (e.g. `#12a`: `[6.5]_DPOF`/`[6.6]_ATS`
self-loaded by the AQP path). Resolution, in priority order:

1. **Fixture isolation (preferred).** A suite that MUTATES shared state uses its own suite-scoped
   accounts/assets (unique id prefix per suite) so it cannot corrupt another suite's fixtures.
2. **Terminal ordering (fallback).** Genuinely destructive admin/rotation suites run in a final
   segment of ZALL, after every suite that needs pristine canonical state.
3. **Idempotent guards.** Deploy/issue steps guard on existence (`with-default-read` / "if not
   exists") so a canonical asset is never double-issued across suites.

Each suite is audited for contamination as it is folded into ZALL; the standalone module testers are
immune (fresh boot each).

## Build phases

- **P1** — extract deploy cores; refactor `Stage01_Tester`/`Stage02_Tester` to load them (DRY, no
  behaviour change); green-gate `Z.repl`. ← *foundation*
- **P2** — build `ZALL.repl`; fold in every suite; resolve contamination per-suite until the whole
  Stage 1+2 run is green.
- **P3** — build `modules/*.repl` standalone testers (one per sovereign + citizen module).
- **P4** — fold the standalone harnesses (`*-groundtruth`, `*-harness`, `deb-staleness-*`, `triplet-*`)
  into ZALL and/or the module testers; curate/retire the `_scratch_*` audit probes.

## Later decision (out of scope here)
Whether to stand up a local devnet or a private StoaChain dev/testnet for integration testing
(Kadena teams typically test on private nets, not public testnets). Until then, REPL is the harness.

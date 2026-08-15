# Single-core / no duplicated logic block — a StoicSyntax discipline — 2026-08-15

**Owner rule (verbatim intent):** *"If there is a single core that works across all injects, then all inject
variants need to use it. Running two blocks of code for the same thing is forbidden by StoicSyntax — if it isn't,
it should be."* One operation ⟹ one code block ⟹ one place to audit and one place to fix.

## The concrete case (FVT inject — Refactor R-INJECT)

The inject distribution logic (custody transfer · escrow/flush distribute · available-rewards · `GAS|INJECT`) had
**two hand-maintained copies**:
- inline in `C_Inject` (handled farm + vault/treasury), and
- in `XI_FvtInjectCore` (vault/treasury only), used by `CC_Inject` and the `MTX|n|C_Inject` defpact (via
  `XE_FvtInject`).

The smell that proved the danger real: #12 added **escrow-on-empty (zombie-rewards)** to *both* copies by hand. Two
copies of one algorithm means every future fix must be applied twice, and the day someone forgets, the paths drift
and one entrypoint silently misbehaves.

**Resolution:** promote the shared helper to THE core for all cases (added the farm branch to `XI_FvtInjectCore`),
then make every entrypoint a thin wrapper:
- `C_Inject` = `(UEV_IMC)` + `(with-capability (FVT|C>INJECT …) (XI_FvtInjectCore …))` — the naive path.
- `CC_Inject` / `XE_FvtInject` = pre-fix stale members (freshness is a *caller* concern) → same core; they
  class-guard (`≠0`) before the call, so a shared core that also handles farms never mis-serves them.

Behavior-identical (the core *is* the former inline block); gates bit-identical.

## The general rule (hunt for more)

When two or more entrypoints do "the same operation," the persisted-write/compute body must live in ONE function
(`XI_*`/`UDC_*`/`URC_*` as fits the prefix), and each entrypoint reduces to **auth + wiring** around that one body.
Variation between entrypoints belongs at the EDGES, not in a forked copy of the core:
- **Authorization** differs → different `defcap`, same core.
- **Pre/post-conditions** differ (e.g. "fix stale first", "penalize", "class-only") → a prelude/guard in the
  wrapper, same core.
- **Cheap vs enforced/heavy** variants (`C_` vs `CC_`, single-tx vs defpact) → all still terminate in the one core.

### How to hunt
- Grep sibling entrypoints that claim to do the same op (`C_Inject`/`CC_Inject`/defpact; stake vs flow variants;
  per-asset TF/OF/SF/NF paths) and diff their bodies. If the *distribution/persistence* math appears in more than
  one, that's a duplicate-core violation.
- A tell: a helper named `*Core` / `*Shared` exists AND an entrypoint still open-codes the same block inline
  instead of calling it. Either the entrypoint has an unmodeled difference (extract it as a wrapper prelude) or
  it should just call the core.
- After consolidating, confirm the removed copy was truly identical (diff), then rely on the existing green suite —
  a behavior-preserving merge should leave every expect count unchanged.

**Fold into StoicSyntax (R5 consolidation):** add "single-core / no duplicated logic block" to the Ouronet chapter
alongside the tautological-check smell (`2026-08-14-tautological-validation-checks.md`). They're complementary
review lenses: one deletes checks that can't fail, this one merges bodies that must never diverge.

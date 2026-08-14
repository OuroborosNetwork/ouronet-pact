# 2026-08-11 — StoicSyntax §19: Ouronet-specific rules (from AQP audit Round I)

**Context.** During the AQP audit (Round I owner feedback — see
`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/Audit/ROUND-01-OWNER-FEEDBACK.md`), several audit "discipline
violations" were ruled **not bugs** by the owner but **Ouronet-specific conventions** that StoicSyntax
should explicitly allow. Rather than leave these scattered as inline "Ouronet example" callouts, the owner
asked for a **single consolidated chapter**. This is fix **#1** of the AQP audit Round II fix plan.

**What changed.** Added **§19 "Ouronet-specific rules"** to `OuronetInformational/StoicSyntax.md`
(version **1.6.7 → 1.7.0**, minor — new section, no break):

- **R1 · `X-cm_` naming.** X functions (`XI`/`XE`/`XB`) that return an IGNIS `OutputCumulator` (allowed when
  it simplifies a complex flow) append `-cm` to the leading prefix token: `XI-cm_`, `XE-cm_`, `XB-cm_`,
  tiered `XI-cm_1|Name`. A plain `X_` must not return a cumulator — the name is a promise.
- **R2 · Multi-table X allowed.** One `XI`/`XE`/`XB` may write >1 table when the writes are one indivisible
  bookkeeping step (still via `W_*`/SECURE, still no `enforce`).
- **R3 · `CC_`/`AA_` HEAVY prefixes.** A `C_`/`A_` (or any function in its call graph) that unavoidably uses
  a `URD_`/scan is renamed `CC_`/`AA_` for instant observability. The §10.2 no-scan-on-hot-path ban still
  stands; `CC_`/`AA_` is a warning label, allowed only where a scan is genuinely unavoidable (e.g. a
  single-tx full-vacate) and never on a daily-hot path.
- **R4 · X `@doc` output rule.** An X that deliberately returns a value must state what/why in `@doc`; only
  the IGNIS-cumulator return is also name-reflected (R1).
- **R5 · Consolidation.** §19.5 indexes the other Ouronet-specifics (IGNIS §2.3a, Talos aggregator §2, the
  prefix universe, §18 inventory) in one place.

**Why (owner reasoning).** Flow complexity sometimes makes cumulator-in-X cleaner than threading it to the
`C_`; some genuinely-coupled writes belong in one X; and some recipes (single-tx full-vacate) cannot avoid a
scan — making them *observable* (`CC_`/`AA_`) beats pretending they don't exist. The prefix **is** the
contract, so the name must announce these behaviours.

**Follow-up (later AQP audit fix items).** The **code** is not yet refactored to these names — that is fix
plan items **#22** (`CC_`/`AA_` renames — VCT full-vacate, POOL sync, …), **#23** (`X-cm_` renames — ANK XE
update entries, …), **#24** (X `@doc` output notes), done after the logic fixes land.

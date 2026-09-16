# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **START HERE — load the single skill hub first:** [`OuronetInformational/SKILL.md`](OuronetInformational/SKILL.md).
> It is the one entry point: load order, the StoicSyntax discipline, the Pact 5 language layer, the module
> map ([`MODULE-INDEX.md`](OuronetInformational/MODULE-INDEX.md)), and the active-learning protocol. Read it
> before writing or reviewing any Pact — everything else hangs off it. (Cursor loads the same hub via the
> `ouronet-pact` skill; Claudstermind's Pact workspace + brain point at it too.)

## What this repo is

**Ouronet** is a virtual blockchain implemented entirely in **Pact** (Kadena's smart-contract language), deployed on **StoaChain** under the namespace **`ouronet-ns`** (migrated from legacy `free`). It defines its own token architecture (true fungibles, ortofungibles, collectables) and DeFi primitives (ATS autostake pools, SWP liquidity pools, AQP acquisition pools, DemiPad launchpad). Development is **REPL-first**: iteration happens through staged `.repl` harnesses before any on-chain deploy.

Authoritative docs live under `OuronetInformational/`:
- `CONTEXT.md` — consolidated project facts and vocabulary.
- `MODULE_ARCHITECTURE.md` — prefixes, capability bands, Talos, client flows. Read before touching any sovereign core or Talos module.
- `ARCHITECTURE/README.md` + `ARCHITECTURE/*` — inventory, interface versioning, REPL layout spec, module deep dive.
- `IGNIS-PRICING/` — how Ouronet charges. **`IGNIS-PRICING/IGNIS-PRICING.md` is the single
  authoritative reference** (cost model, every price decision, architecture, status, lessons);
  `IGNIS-PRICE-SHEET.md` is the GENERATED per-function price list that feeds the Chapter-2
  documentation. Do not add more pricing docs to this folder — fold new facts into the one file.
- `HANDOFFS/` — long-form handover documents (PYTHIA, SWP path search, bulk transfer).
- `skills/` — repeatable procedures (enforce grouping, UR layout, REPL test layout, etc.).
- `memories/` — dated conversation captures and decisions.

## Running the REPL pipeline

The canonical entry points live under `REPL/` and are loaded from that working directory:

```bash
cd REPL && pact Z.repl                # Full pipeline: Stage 00 sandboxes → 00a Stoa coin tests → Stage 01 → Stage 02 (Stage ZZ commented)
cd REPL && pact Stage01_Tester.repl   # Stage 1 only (deploy + scenario 6.1–6.8)
cd REPL && pact Stage02_Tester.repl   # Stage 2 only (DPDC, DemiPad, AQP, Talos, scenarios)
cd REPL && pact Stage00_Sanboxes.repl # Kadena + Stoa sandbox bootstrap
cd REPL && pact Stage00a_StoaTests.repl # Stoa coin regression tests
cd REPL && pact StageZZ_Tester.repl   # Deploy 2_CITIZEN/Stage_Z/01_DPL-UR.pact only
cd REPL && pact ZALL.repl             # EXHAUSTIVE runner — every suite, incl. the ones Z.repl skips
```

**`Z.repl` is the fast path, not the gate.** It deliberately skips `Stage_01/[6.1]_Cumulator.repl`,
the full `[6.2]_DPTF` / `[6.3]_SWP` suites (issuance-only variants run instead) and the Stage-1
scenario tail (`[6.6]_ATS`, `[6.7]_VST`, …). **Any change to pricing, STOA collection or IGNIS
billing must be verified with `ZALL.repl`** — or, better, with `python3 REPL/tools/_gate.py`, which is
the actual gate.

CORRECTED 2026-09-14, because the old wording overstated this and an overstated rule is one people
stop believing. It said a green `Z.repl` "does not execute the assertions written to protect"
pricing. That is false: `Z.repl` → `Stage02_Tester.repl` runs `[6.1.9]_PRICE-SWEEP.repl` (64
assertions) and, via `[6.2]_AQP.repl`, `[6.2.16]_AQP-PRICE-SWEEP.repl` (42) — **106 pricing
assertions do run.** What it skips is `[6.1]_Cumulator.repl`'s **75**, commented out at
`Stage01_Tester.repl:32`. The rule stands and the 75 matter — they are the LEG-LEVEL assertions,
and on 2026-09-14 `[6.1]`'s `<<TX-IGC-008>>` was the only thing in the suite that caught a VST
preview leg-split, which every total-level assertion passed straight through. But the reason is
"a quarter of the pricing assertions, including every leg-level one, are not in the fast path",
not "none of them are".

Individual scenario REPLs live in `REPL/Stage_01/[*].repl` and `REPL/Stage_02/[*].repl`. The reference hand-maintained integration suites are `REPL/Stage_02/[6.2.1]_AQP-ANK.repl` and `REPL/Stage_02/[6.2.2]_AQP-SCORE.repl` — mirror these when writing new integration tests.

Stage 1 has two DPTF/SWP paths — pick **one** in `Stage01_Tester.repl`: full suites (`[6.2]_DPTF.repl` + `[6.3]_SWP.repl`) or issuance-only (`[6.2+3]_DPTF-SWP_Issuance-Only.repl`, faster, used when prepping for Stage 2).

### REPL maintenance scripts

Run from repo root (they skip the two reference AQP REPLs):

```bash
python3 REPL/tools/_normalize_repl_layout.py --apply   # Preamble + ;;|| NEXT > between commit-tx/begin-tx + subdivision
python3 REPL/tools/_subdivide_repl.py --apply          # Only the mm-banner insertion inside each begin-tx
```

**`--apply` is REQUIRED on both, since 2026-09-16, and this block used to omit it** — which
contradicted the rule three paragraphs below (*"Tools that rewrite source require `--apply`"*). That
rule was added after the 2026-09-15 incident and applied to the five `_fvt*` tools that caused it,
not to the class; these two still rewrote the tree on a bare run. A tool census on 2026-09-16 did
exactly that — **188 files, 16,457 insertions** — and because `_normalize_repl_layout` *also*
performs subdivision, running both duplicated every `;;====` banner. Nothing was lost, because the
tree was committed; "the tree was committed" is not a safety property.

**Run only ONE of the two.** `_normalize_repl_layout` already calls `_subdivide_repl`'s logic
internally; running both duplicates the banners it inserts.

**Both are currently NON-NO-OP on the committed tree**: `--apply` changes ~167 files, so the
committed REPL layout has drifted from what the formatter produces (expected — blocks get appended
by hand). Re-normalising is a deliberate, reviewable act, not a tidy-up to fold into another commit.

**Tools that rewrite source require `--apply`.** `_fvtasm` / `_fvtcut` / `_fvtfacade` / `_fvtflip` /
`_fvtgen` mutate `.pact` files **at module level** — they have no `if __name__ == "__main__"` guard,
so *importing* them used to be enough to rewrite the tree. On 2026-09-15 a loop that imported each
revived tool "just to prove it loads" fired five of them and silently deleted 111 lines of schemas
from `05_FVT.pact`. They now refuse unless `--apply` is passed. **Never run a tool to find out what
it does** — read its docstring, or check the table in `REPL/TOOLS.md`.

**Generated artefacts are gate-enforced.** `OuronetInformational/IGNIS-PRICING/IGNIS-PRICE-SHEET.md`
and `IGNIS-DETER-WORKSHEET.md` are regenerated and diffed by `REPL/tools/_pricesync.py --check`,
fatal inside `_gate.py`. Edit the **generator**, never the artefact; `--write` to refresh both.
The sibling check for `ARCHITECTURE/*.md` is `_figuresync.py`.

**Tool paths are gate-enforced too.** `REPL/tools/_toolpaths.py --check` statically resolves every
hard-coded path literal in every tool. If you move a tool, this is what tells you what you broke —
the 2026-09-14 move killed eleven tools that died at *import*, so nothing that diffed their output
could see it.

## Repository layout

| Path | Role |
|------|------|
| `1_SOVEREIGN/STAGE_01/` | `0_Interfaces/`, `1_Utilities/` (`U_*` — 13 files), `2_Core/` (DALOS, DPMF, IGNIS, DPTF, DPOF, ATS, VST, SWP family, …), `3_Talos/` (TS01-A/C1/C2/C3/P) |
| `1_SOVEREIGN/STAGE_02/` | `0_Interfaces/`, `2_Core/01_DPDC/` (DPDC family), `2_Core/02_DEMIPAD/` (**DEMIPAD sovereign launchpad core only** — the per-asset sales moved to `2_CITIZEN/7_Launchpad/`), `2_Core/03_AQP/` (AQP, AQP-ANK, AQP-SCORE, FVT), `3_Talos/` (TS02-C1/C2/C3) |
| `2_CITIZEN/` | Citizen (extension) modules consuming sovereign APIs — anyone can write one; these are Admin-authored citizen modules in `ouronet-ns`: `1_AOZ/` (Age of Zalmoxis — primal-asset registrar; calls only TS01-C2 ATS Talos), `2_BloodshedMinter/`, `3_NosferatuMinter/`, `4_BunniesMinter/`, `5_VaultsMinter/` (AQP-BOOT + readme), `6_OuronetBridge/` (CADUCEUS), `7_Launchpad/` (per-asset **pure-citizen** sales `1_Spark`/`2_Snakes`/`3_Custodians`/`4_StoicPay`/`5_StoicIco` — each calls only Talos ops, Σ-billed, with `URCi_`/`INFO_` cost readers — + `99_TS02-CPAD.pact`, the **citizen** launchpad Talos (all `SPARK\|`/`SNAKES\|`/… user wrappers, the sole gas-funded path, deployed last). The **sovereign** launchpad Talos moved to `1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact` (`DEMIPAD\|*` + `DEMIPAD\|C_Deposit`)), `Stage_Z/` (DPL-UR, EXPLORER, `03_DSP+` dispenser automaton — reads AOZ, deployed last). AOZ + DSP are already pure-citizen (Talos-only). |
| `0_Sample/` | Module layout samples (`ModuleSample.pact`) |
| `0_Stoa/genesis/` | Historical Stoa genesis tx / JSON payloads (`stoa-genesis-1` … `5`) — ordering reference for the Stoa sandbox |
| `00_KadenaSandbox/` | Kadena-like sandbox; note `coin` is renamed to `kadena-coin` here so `coin` stays free for Stoa |
| `00_StoaSandbox/` | Stoa-like sandbox: root `ns`, `coin`, `util`, `stoa-ns` interfaces/modules (phased `init-phase-*.repl`) |
| `REPL/` | Staged loaders and scenario files. **The REPL analysis scripts live in `REPL/tools/`** (moved there 2026-09-14). CORRECTED 2026-09-15: this said *"All 44 analysis scripts"*, and there are **three** tool directories — `REPL/tools/` (the analysis suite and the gate), `tools/` (StoicSyntax canon: `skeleton_emit`/`canon_check`/`cap_band`, plus a `gate.sh` that is **not** the hard gate), and `OuronetInformational/tools/` (the MODULE-INDEX generator). `_toolpaths.py` scans all three; a sentence asserting they all live in one place is how the other two went unchecked. The `REPL/tools/` index is `REPL/TOOLS.md`, generated by `REPL/tools/_toolindex.py` (CORRECTED 2026-09-16 — this said `tools/_toolindex.py`, which is the StoicSyntax-canon directory, not where the generator lives; `_toolpaths.py --check` resolves path literals *inside* tools and cannot see a path written in prose). The gate is `python3 REPL/tools/_gate.py`; it resolves its own paths, so it runs from any directory. |
| `OuronetInformational/` | Persistent context for humans and AI — **read before editing sovereign modules** |

## High-level architecture

### Sovereign vs citizen

- **Sovereign** (`1_SOVEREIGN/`) — canonical Ouronet modules maintained by the project. Contain the business logic and the capability gates. **Talos** (the orchestrator/gas boundary) is sovereign-only.
- **Citizen** (`2_CITIZEN/`) — extension modules anyone can write. They call **only** into sovereign public APIs; they do not add capabilities to the core surface, and their own client functions carry no `UEV_IMC` (that sovereign inter-module gate belongs to Talos/core paths). The per-asset **launchpad sales** (Spark/Snakes/Custodians/StoicPay/StoicIco) are citizen modules that wire into the sovereign `DEMIPAD` launchpad rules; `2_CITIZEN/7_Launchpad/99_TS02-DPAD.pact` is the **sovereign** Talos orchestrator that composes those citizen sales and pays their gas (co-located with the launchpad for readability, but sovereign-role and deployed last).

### Layer cake: Utilities → Core → Talos

- **Utilities** (Stage 1 only) — small pure helpers (`U_CT`, `U_G`, `U_LST`, …).
- **Core** — main business logic (DALOS, TFT, VST, DPDC, DemiPad, AQP, …). Each core module starts with **policy tables** (shared guard structures used for inter-module authorization) before bulk logic.
- **Talos** — orchestration entrypoints. **The only supported client path.** Talos sequences compose `A_` / `C_` across core modules into curated flows. The **Ouronet gas station** pays execution **only** for paths defined in Talos, and Talos is the only place that collects **IGNIS** (virtual-chain gas) after a `C_`. Any new `A_` / `C_` / protected `X*` on a core module must be wired into the appropriate Talos module to finalize it for client and gas semantics. `C_` is blocked from being invoked inside its own module by design.

### Deployment order and interface versioning

Kadena's ~150k deploy size cap forces strict deploy ordering: a module may only call into modules already deployed. Consequences:

- Cross-module calls use **module references** with `::` (e.g. `(ref-M::some-fun ...)`), not `module.function`, so only the used interface members matter for coupling.
- Interfaces (`V1`, `V2`, `V3`, …) carry nearly the full public API. Interface names always end in a version suffix; each revision advances the suffix by **exactly one**.
- **Cascade rule**: when interface B → B′, every interface A that names B (via `module{B}` or `object{B.Schema}`) must bump to A′ with the new reference, and every consumer updates in lockstep. Implementing modules `implements` only the **latest** version. Details: `OuronetInformational/ARCHITECTURE/INTERFACE_VERSIONING.md`.
- **Policy**: new/active work stays on `V1` until first mainnet deployment. Bump to `V2` only after live deployment if post-deploy adjustments force a versioned move. Until then `V1` code is edited freely.
- **Same-interface object types**: inside an interface, write `object{PoolTokens}` (unqualified) for schemas defined in that same interface; use `object{OtherInterface.Schema}` only for row shapes owned by a different interface.
- **Interface object-return rule**: if a function would return `object{Schema}` where `Schema` is defined in the implementing module (not the interface), **remove it from the interface** — interface loads before module schemas exist. Ouronet convention is to keep schemas in modules, so such functions stay module-only (applied for `AQP-ANK`, `AQP-SCORE`).

### Canonical module section order

1. Schemas, tables, constants (labeled `{1}`, `{2}`, `{3}` blocks in sources).
2. Capabilities grouped by band:
   - **C1** — trivial / "always true" roots.
   - **C2** — simple, no composition.
   - **C3** — ownership patterns.
   - **C4** — composite (`compose-capability`).
3. Functions. Under FUNCTIONS, **true `UC_*` compute helpers come first**.

Reference: `0_Sample/C0s__01_01_ModuleSample.pact`.

### Function prefix system

Unprotected (callable without caps — safe by construction):

| Prefix | Meaning |
|--------|---------|
| `UC_*` | Pure compute on arguments only — **no table reads, no `enforce`**. First under FUNCTIONS. |
| `UCv_*` | `UC_` whose `enforce` is **intrinsic to its own computation** (a shape/domain guard on the computation itself), not business validation. See the `v` role in `StoicSyntax-Prefixes.md` §1. |
| `UR_*` | Table reads. **No raw `read` on domain tables outside `UR_*`.** Per-field `UR_*` take table keys, not row objects. |
| `URC_*` | Read + derive. **No `enforce`** (validation lives in `UEV_*` / defcap). May call `UR` / `UC` / other `URC`. |
| `URCv_*` | `URC_` whose `enforce` is **intrinsic to its own computation** — same `v` role as `UCv_`. Use it when the guard is unavoidable in the derivation itself and relocating it would mean duplicating the identical check at every real call site; use a `UEV_*` / defcap when the check is a business rule. |
| `UEV_*` | Read + `enforce`. Failure aborts the tx. Unprotected. |
| `UDC_*` | Data construction — named constructors for objects; prefer over ad-hoc `object{}` literals. |
| `CAP_*` | Ouronet account-ownership enforcement (UEV-like but specifically tied to account ownership). |

Protected (locked inside their module — **not** the public integrator surface):

| Prefix | Meaning |
|--------|---------|
| `A_*` / `AA_*` | Admin-key mutations. Doubled `AA_` = **heavy**: a heavy scan (`URH_*`/`URHC_*`/`URD_*`) is reached **somewhere in the whole execution tree, at any depth** (transitive). |
| `C_*` / `CC_*` | Client entry for citizen modules. Builds IGNIS cumulators and returns `OutputCumulator`. **Cannot be invoked from its own module** — clients reach it via Talos. Doubled `CC_` = **heavy** (a `URH_*`/`URHC_*`/`URD_*` scan is reached anywhere in its execution tree, at any depth). |
| `Cp_*` / `CCp_*` / `Ap_*` / `AAp_*` | **Hydra** multi-transaction recipes (contrast `defpact` = one ordered continuation). `Cp_`/`Ap_` carry NO heavy read; `CCp_`/`AAp_` still do. Anatomy: `URH_*` preflight → slices/pages → optional `C_`/`CC_` begin/finalize. **Two shapes wear the `p`, and only one is parallel** (verified 2026-09-14, all three in the tree): a **fed-slice** takes an explicit slice object and IS order-independent and parallel-safe (`Cp_WipeSlice`); a **cursor pager** takes a size, computes its own window from stored progress, and is strictly SEQUENTIAL (`CCp_SweepRecomputeChunk`). Check which one you have before firing N at once. See `OuronetInformational/StoicSyntax-Prefixes.md` § "Recipe axes". |
| `XI_*` | Internal-only protected (this module). |
| `XE_*` | For external modules only (forward-module entrypoints). |
| `XB_*` | Both internal and external. |

### Client flow shape (`C_` / defcap / `XI`/`XE`/`XB`)

This is the intended decomposition — deviations should be deliberate.

- **Client `defcap`** (often `@event`, may `compose-capability (SECURE)` or a core cap): **all** authorization and validation — `CAP_EnforceAccountOwnership`, `UEV_*`, `UEV_Fee`, table reads. Boolean predicates are combined in **one** `enforce` per the rule below.
- **`XI_*` / `XB_*`**: persisted writes under `require-capability` on a `SECURE`-composing cap. May call `UR` / `URC` / `UC` / `UDC`, but must **not** `enforce` or call `UEV_*` — every check belongs in the defcap. Body ends on `insert` / `update` / `write` — **no trailing `true`, no `OutputCumulator` return**.
- **`XE_*`**: forward-module entrypoint. Start with `UEV_IMC`, then `with-capability (…|XE>…)` inside the defun. The defcap holds all local + deployed-dep checks. The defun body is writes (and scoped reads) only — no `enforce` / `UEV_*` after `UEV_IMC`. No `OutputCumulator`; the forward module's `C_` composes IGNIS.
- **`C_*`**: wiring + billing. `UEV_IMC`, `with-capability (ClientCap …)`, one or more `XI`/`XE`/`XB` calls, optional STOA / `KDA|C_Collect`, then `IGNIS::UDC_*` / `UDC_ConstructOutputCumulator` so the returned `OutputCumulator` reflects the whole operation.

#### Two billing shapes, and where the "no self-`C_`" rule actually applies

The sentence above describes **shape A**, which is the common case but not the only correct one. A full trace of all 38 non-cumulator `C_`s (2026-09-13) found **six** shapes, all legitimate:

| shape | where the billing happens | example |
|---|---|---|
| **A** | core `C_` returns the cumulator; Talos passes it to `IGNIS::C_Collect` | most ops |
| **B** | Talos wrapper builds the cumulator from a `URCi_*` and collects | `DALOS::C_RotateGuard` → `TS01-C1` |
| **C** | STOA-priced — wrapper calls `STOA|C_Collect*`, no IGNIS at all | `DALOS::C_DeploySmartAccount` |
| **D** | billed **in the core** — the `C_` itself ends on `STOA|C_CollectWT` | `SWPLC::C_UpgradeBrandingLPs` |
| **E** | **defpact step** — the `C_` is only a starter; a later step bills | the 8 `MTX-SWP` pool/liquidity ops |
| **F** | **nested Talos** — the core calls another Talos client that collects | `DEMIPAD::C_Transmit*` → `DPTF|C_Transfer` |

Plus **primitives** (`IGNIS::C_TransferDalosFuel`, the `STOA|C_Collect*` family) which *are* the collectors and cannot collect from themselves.

The choice belongs to the op. `_conformance.py`'s `C-without-cumulator` reports all of these as **observations**, not violations — but the rule is still worth reading, because it is the only place that would surface a genuinely unbilled operation.

**One deliberately free op exists** and is worth knowing about: `TS01-C4::PYTHIA|C_Link` takes no `patron` and collects nothing, while its three siblings all charge. It is safe because it is bounded, not because it is cheap: linking needs two deployed Apollo halves at 500 native STOA each, and counterparts are **never cleared** (revoke only deactivates), so it is **one-shot per pair, forever**. That bound is pinned by `modules/PYTHIA.repl` `<<PYTHIA-LINK-ECON>>`. If counterparts ever become clearable, the op stops being safe.

**`C_` must not be invoked inside its own module** — but read the rule for what it protects, which is the cumulator. A sovereign `C_` builds an OutputCumulator that only Talos may collect, so a self-call can drop or double it. That is why the rule is absolute for sovereign modules (`self-C-call` must stay at **0**).

In the **citizen minters** (`NOSFERATU`, `KBunnies`) the direction is inverted: their `C_Spawn` / `C_Fix` call *into* Talos and return the wrapper's **string**, after Talos has already collected. There is no cumulator at that level to mishandle, so `A_StepNN → C_Spawn` is sound. `_conformance.py` splits these into `self-C-call-citizen` (observation, bounded to those two files). **The bound is the point** — a citizen `C_` that returns an `OutputCumulator` is shape A and the rule applies to it normally.

When a citizen batch step splits one logical mint across several `C_` calls, the safety condition is that the price carries **no fixed per-call component** (`URCi_RegisterCollectablesPrice` is `smallest × Σamounts`). Pinned by `Stage_02/[5.1]_PopulateNosferatu.repl` `<<NSFR-G2>>`, which also pins the one non-linear branch (the `E|` + `son` + `nonces-used = 0` first-nonce discount) as out of reach for a DPNF.

If one user operation spans multiple tables, use **multiple** `XI`/`XB` functions — one focused write path each — rather than cramming unrelated persistence into a single `XI`.

### Combining boolean checks in one `enforce`

| # bool conditions | Form |
|---|---|
| 1 | `(enforce p "msg")` |
| 2 | `(enforce (and p q) "msg")` |
| 3+ | `(enforce (fold (and) true [p q r ...]) "msg")` |

`CAP_*`, `UEV_*`, `UEV_Fee` stay as separate calls **before** the combined boolean `enforce` (they are not plain booleans). Reference: `SCR|XI>ISSUE-SCORE` in `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/02_SCORE.pact`.

### Authorisation precedes validation inside a `defcap`

Owner ruling, 2026-09-14. When a `defcap` both **authorises** (`compose-capability` of a `GOV|*_ADMIN`
or equivalent) and **validates** (business `enforce`s), the authorisation goes **first** — before any
business rule, and before the `let` that derives the data those rules read.

The reason is not tidiness, it is testability. `GOV|WIPE_ALL-TREASURY-DEBT` had the order reversed:

```pact
(enforce (< treasury-supply 0.0) "Cannot Wipe Positive Treasury Balance")   ;; business
(compose-capability (GOV|DPTF_ADMIN))                                       ;; authorisation
```

A solvent treasury is the normal state, so **every** attempt — admin or stranger — was turned away
by the business rule and the admin gate was never reached. A red-team test could report "a non-admin
was refused" and be telling the truth while proving nothing: **had `GOV|DPTF_ADMIN` been deleted from
that capability, the test would still have passed.** A shadowed gate is indistinguishable from an
absent one from the outside.

Swept across all 18 sites that had the two in the wrong order (`REPL/RedTeam/[RT-C]_AdminImpersonation.repl`
`<<RT-C-001>>` pins the treasury case by its *message*, which is the only thing that can tell the two
refusals apart).

**SCOPED 2026-09-16 — the sweep covered the ADMIN band only.** "All 18 sites" is true of the
definition the sweep used (a business `enforce` before a `compose-capability` of a `GOV|*_ADMIN`) and
false of the rule as written, which says *"or equivalent"*. Re-scanning all 989 `defcap`s: **two**
admin-band sites were still unswept — `GOV|GAP` and `GOV|MIGRATE`, both in `01_DALOS.pact`, the
ruling's own module, with `GOV|MIGRATE` reproducing the treasury shape exactly (GAP-offline is the
normal state, so the admin gate was never reached). Both fixed; see DEFECT-LEDGER §7.2h, G-42/G-43.
Read "or equivalent" to include the `CAP_*` **ownership** gates — which the prefix table above calls
*"Ouronet account-ownership enforcement"* — and there are **62 sites across 23 files**, none of them
in the sweep's scope.

**Do not resolve those 62 by reordering them.** Ordering is a *proxy* for testability, and it can
expose only ONE of two state-dependent guards at a time. `[6.2.10]` `TX-AQP-NEG-SCRCTL` and `[6.4]`
`<<TX-AQP-FA01>>` both **depend** on the current order to reach an argument guard without a
signature; hoisting the ownership gate there would make the distinctness clause unreachable instead.
**A fixture that satisfies the first guard exposes BOTH** — which is what `<<TX-AQP-NEG-OWNER2>>`
does, choosing entities whose latched flag is still `true` so ownership is the only thing left that
can refuse. Prefer that, and prefer it as an *additive* test: it cannot introduce an authorisation
hole, which a reorder demonstrably can.

**When moving an authorisation form, check what it is nested inside.** If it sits in an `if`, `and`,
`or` or `cond` branch, the authorisation is *conditional* (e.g. `SWPI|C>ISSUE` requires the admin key
only for a primordial issuance) and hoisting the bare `compose-capability` out of the branch changes
who may call the function. Hoist the **whole conditional form** instead. A scripted reorder that
ignores this silently converted an unconditional gate into a conditional one during this very sweep.

### `UR_*` ordering

- `UR_*` groups follow the **order schemas are declared** in the module (first schema → first UR block, …).
- Within a group, mirror the **field order of the `defschema`**: full-row reader first (when present), then per-field readers in field order, then object-taking helpers/predicates.
- **Multi-table dispatch** (same schema, fungibility discriminator, etc.): prefer a single entry `UR_*` using `with-default-read (UC_*Table discriminator) row-key …` over copy-pasted per-table readers. Split only when the read logic diverges. Reference: `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact` — `{F0} [UR]` blocks.
- **Per-field `UR_*` take table keys, not row objects.**

### Greenfield feature workflow

When adding a new slice (new schemas/tables + client entrypoints), follow this order:

1. Fix **schemas / `deftable`** shapes and declaration order.
2. Decide **`C_*` client names and outcomes** (surface spec, not implementation).
3. Populate **`UR_*` readers** grouped and ordered as above, including multi-table dispatch.
4. Build each `C_` **end-to-end one at a time**: defcap + cap wiring, `XI` / `XE` / `XB`, `UDC`, and introduce `URC` / `UEV` **as each path needs them**. Do not front-load all `URC`/`UEV` before the client code.

## Pact style rules specific to this repo

- **Formatting is a hard requirement, not cosmetic.** Preserve existing indentation, block comments (section bars), grouped `let` bindings, aligned multi-line args. Avoid formatting churn unrelated to behavioral changes.
- **Line length** — keep source lines within ~88–92 chars. For long `@doc` strings, use Pact string continuation: end a line with `\` and start the next with `\`; break at phrase/clause boundaries. Don't write multi-line `@doc` without continuation.
- **`@doc` placement** — **immediately after the parameter list**, before the body. Never between the function name and `(`.
- **Evented `defcap`** — order metadata `@doc` first, then `@event`, then body (Pact requirement).
- **`let` vs inline** — use `let` when a bound name is used **more than once**; if used only once, inline (common with `with-default-read (UC_*Table …) (UC_*Key …)`). No duplicate `defun` aliases.
- **Function/cap comments** — when introducing or refactoring, add a meaningful `@doc` and annotate core logic with numbered step comments (operational — what the line does). Don't duplicate validation across defcap + UEV for the same input.
- **Talos client output** — Talos `C_*` functions end with a clear `format` result string explaining the branch taken, not raw IDs. When output IDs differ by branch, the message describes what happened.

## Integration REPL canonical layout (required for new `begin-tx`/`commit-tx` suites)

Mirror `REPL/Stage_02/[6.2.1]_AQP-ANK.repl` and `[6.2.2]_AQP-SCORE.repl`. Spec: `OuronetInformational/ARCHITECTURE/REPL_AND_TESTS.md` § *Canonical layout*; checklist: `OuronetInformational/skills/repl-integration-test-layout.md`.

- **File header** — `FILE` banner, Legend (angle-bracket log prefixes), Source line, REPL tests line.
- **Inter-tx separator** (between `commit-tx` and next `begin-tx`) — three-line `;;|| NEXT >` block (see `REPL/Stage_01/[2.2]_Core.repl`).
- **Intra-tx groups** — inside each `begin-tx`, label blocks `;;==== TXnnn · mm · <slug> ====` where `mm` restarts at `01` per transaction, and on the **next line** print a matching banner: `(print "--- [TXnnn · mm · <slug>] ---")`.
- **Assertions** — `(expect (format "…" [vals]) expected actual)` and `(expect-failure (format "…" [vals]) expr)` with a **single** `format` for the doc string (don't wrap the whole `expect` in `format`). Because both return strings, batch them in `(map print [ (expect …) … ])` so every line prints.
- **`map print` residue** — `(map print xs)` evaluates to `[() () …]`. Place it so the `let` body's last form isn't a long bracket line; end with `""` or a short neutral `print` if you want to suppress that echo.

## Sandboxes

- **Kadena sandbox** (`00_KadenaSandbox/kda-env/init.repl`) — mainnet-style fungibles. `coin` in `kadena/coin-v6.pact` is renamed to `kadena-coin` in this sandbox so the identifier `coin` remains free for the Stoa native token in the same REPL.
- **Stoa sandbox** (`00_StoaSandbox/stoa-env/init.repl`) — live sources: root `ns`, `coin`, `util`, `stoa-ns` interfaces/modules. Initialized in **genesis order** via phased `init-phase-*.repl` files, with payloads aligned to `0_Stoa/genesis/*.json`. Registers `ouronet-ns` the same way the on-chain genesis does.
- All Ouronet deploy/test `.repl` files under `REPL/` use `(namespace "ouronet-ns")` and qualified refs like `ouronet-ns.DALOS`.

## Historical note: DPMF → DPOF

`DPMF` is the original MetaFungible module, kept for historical/migration context. Live metadata-rich fungible behavior is represented by **`DPOF`** (OrtoFungible). Naming shifted from MetaFungible to OrtoFungible to separate the active path from legacy meta-fungible semantics.

## Working agreement

When adding modules or functions:

1. Respect **deploy order** and **interface versioning** (cascade rule).
2. Place code in the right section (schemas → caps by C1–C4 → FUNCTIONS with `UC_*` first).
3. Use the correct **prefix** (`UC` / `UR` / `URC` / `UEV` / `UDC` / `CAP` / `A_` / `C_` / `X*`).
4. Wire new `A_` / `C_` / `X*` into the appropriate **Talos** module and add **policy** guards where inter-module or client access requires it.
5. When something stable is learned, append to `OuronetInformational/CONTEXT.md` or add a dated note under `OuronetInformational/memories/` so future sessions don't start from zero.

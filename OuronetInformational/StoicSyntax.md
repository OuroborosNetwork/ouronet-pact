# StoicSyntax — a discipline for writing Pact

| | |
|--|--|
| **Version** | **1.10.0** |
| **Status** | Published discipline — rules Ouronet follows; offered for any Pact builder |
| **Date** | 2026-08-24 |
| **Home** | Ouronet (this repository) — the codebase that practices and proves the method |

**What StoicSyntax is.** A **discipline and set of rules** for writing Pact: how to name and place functions, where validation lives, how writes are isolated, how modules authorize each other **without borrowing each other’s capabilities**, and how one module can safely **compose calls across many modules** into auditable client flows.

It is **tied to Ouronet** — Ouronet’s large sovereign codebase is written this way on purpose. It is also **meant for any Pact builder**. Anyone assembling non-trivial multi-module Pact should be able to adopt the same discipline to produce code that is easier to create at scale and **easier for a human to observe and audit**.

**What problem it solves.** Without a shared discipline, large Pact bodies become opaque: side effects hide in helpers, validation scatters, cross-module capability graphs become unreadable, and “does this call do what I think?” becomes a research project. StoicSyntax makes the codebase **sort of self-auditable**: prefixes, section order, and gate rules announce intent so a human can follow a path without reverse-engineering every body.

**What composition it unlocks.** Protected units live in many cores; an **Aggregator** (Ouronet: **Talos**) composes only **curated** multi-module flows — see **§ 2**. Optional policy post-steps (Ouronet example: **IGNIS** virtual gas) can be forced on that path because composition is centralized; they are **not** required by StoicSyntax itself. IMC + local caps make aggregation safe without foreign `compose-capability`.

**How to use this document.** Ouronet authors and agents write and review against **this file** as the compatibility contract. External Pact builders can treat it as the rulebook for the same discipline. When a durable rule changes, bump the version (§ Versioning) and update this file first. Deeper Ouronet inventory: `OuronetInformational/`. Worked artefacts: `0_Sample/C0s__01_01_ModuleSample.pact`; `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_VCT.pact`.

---

## Why this discipline exists

Ouronet needs **large** Pact surfaces (many modules, many tables, many client recipes). StoicSyntax exists so that growth stays human: structure carries meaning, bugs have fewer legal seats, module boundaries enforce trust, and **composed multi-module functions** (Talos-style aggregation) stay inspectable.

### 1. Self-auditable for humans

In StoicSyntax, a function’s **prefix is its contract**. You know privilege and side-effect class before opening the body:

> **The complete, authoritative prefix registry — every class, the `k`/`x` role suffixes, the
> old→new migration (`URD→URH`, `URDC→URHC`, `UCK→UCk`, uppercase-`X`→lowercase-`x`), and the colour
> families — lives in [`StoicSyntax-Prefixes.md`](StoicSyntax-Prefixes.md).** Make prefix changes
> there first; the table below is a quick-glance summary using the **new** heavy-read spelling.

| Prefix signal | Meaning |
|---------------|---------|
| `UC_` / `UCk_` | Pure compute / compute that builds a composite table key |
| `UR_` / `URH_` | Point read / table scan (heavy — off-path only) |
| `URC_` / `URHC_` | Derive from reads (no `enforce`) — point / heavy |
| `UEV_` / `CAP_` | May fail the transaction (enforce / ownership) |
| `UDC_` | Data constructor |
| `WI_` / `WU_` / `WW_` | Persistence only (insert / update / write) |
| `XI_` / `XE_` / `XB_` | Orchestrate writes (no validation) |
| `C_` / `CC_` / `A_` | Client / single-tx client / admin recipes |
| `…x` (lowercase) | Auxiliary of the function directly above it (same class + colour) |

Capabilities are banded (**C1–C4**), FUNCTIONS are ordered (**UC → … → X**), and `defcap` / `let` bodies follow a fixed statement order. A reader can navigate a multi-thousand-line module by **prefix and section**, not by hunting for side effects. That is intentional: **the layout is the first audit pass**.

### 2. Bugs are designed out

Many Pact defects are “wrong layer did the wrong thing”: a write without a gate, a scan inside a capability, validation after a write, `(and a b c)` blowing up at runtime, or fees skipped because someone called a core recipe outside the blessed path.

StoicSyntax **makes illegal states unrepresentable by convention**:

| Hazard | Architectural answer |
|--------|----------------------|
| Validation forgotten or duplicated | **Only** `defcap` / `UEV_*` enforce; writers and recipes never do |
| Accidental table scan in hot paths | `keys` / `select` **only** in `URD_*`; **never** call `URD_`/`URDC_` from caps / `C_*` / `X_*` — prefer aggregate tables (§ 10.2) |
| Partial / opaque persistence | One `W_*` per site; persistence is the **last** expression |
| Binary-`and` arity bugs | Hard rule: 1 / 2 / `fold (and)` for 3+ |
| Fee / metering skipped on a product that requires it | Clients enter via an **aggregator**; optional policy post-steps (Ouronet: IGNIS) attach there — § 2 |
| Dishonest helper names | UC / URC / URDC migration signals force the name to match read depth |

You are not relying on reviewer memory alone — the layout **rejects** common mistakes by where code is allowed to live.

### 3. Modules protect each other — so composition can scale

Pact capabilities are powerful — and unsafe if modules reach into each other’s caps. StoicSyntax’s security spine:

1. **Capabilities are module-local.** Never `compose-capability` / `with-capability` / `require-capability` on a capability **defined in another module**.
2. **Policies replace foreign caps.** Inter-module trust is a **guard registry** (policy tables), checked at the callee (`UEV_IMC`), not by composing `OTHER.SOME|CAP`.
3. **Protected entrypoints gate on IMC.** Cross-module mutators start with an implementer check: only callers whose capability-guards were **explicitly registered** may enter.
4. **Internal writes gate on a home `SECURE`.** Persistence helpers require a capability composed only by **home** recipe / export caps.
5. **Account governors stay home.** Vault / smart-account GOV caps are composed **only in the owning module**. Peers that must operate the account register a **local** remote-gov capability-guard on the owner’s policy table.
6. **Aggregation is a first-class layer.** A dedicated module (Ouronet: **Talos**) composes client/admin recipes **across several cores** into one human-facing sequence, attaching economic collection so the blessed path cannot skip fees. That pattern is what the discipline is built to support.

**Summary:** Ouronet uses StoicSyntax so large code stays creatable and human-auditable, and so multi-module composition (Talos aggregation) remains safe. Any Pact builder facing the same scale problem should use the same discipline.

### Design principles

| Principle | In one line |
|-----------|-------------|
| **Declare by prefix** | Name encodes read/write/validate/orchestrate privilege — first audit signal |
| **Indent for observation** | Stable nesting, section bars, grouped `let`, ~88–92 cols (§ 13.0) |
| **Validate at the gate** | Capabilities (and shared `UEV_*`) own failure; bodies execute |
| **One write site** | Canonical persistence helpers; orchestration does not scatter `update`s |
| **No foreign caps** | Trust is registered guards, not cross-module `compose-capability` |
| **Deploy-honest refs** | Peer **calls** via `module{…}` + `::` only; never peer `MODULE.fun`; `(use …)` only for selective schemas/types if needed (§ 4) |
| **Composable aggregation** | Orchestrator sequences many modules; each core stays locally gated |
| **No hot-path scans** | Prefer aggregate rows + `UR_*`; `URD_`/`URDC_` for UI/dirty reads (§ 10.2) |

---

## 0. Mental model (read this first)

Roles as Ouronet practices them; the same roles apply if you adopt the discipline elsewhere.

| Role | Rule |
|------|------|
| **Layers** | **Utilities → Core → Aggregator**, released in **phases** (§ 1). Curated flows: § 2. Ouronet Aggregator = **Talos** |
| **Clients** | End users / integrators go through the aggregator, not raw core `C_` |
| **Optional policy on curated path** | Aggregator may force post-steps (Ouronet example: **IGNIS** collect). Not a StoicSyntax requirement — § 2.3a |
| **Interfaces** | Historical in an interfaces pack; current module API in the module file; shared types in a shared-interfaces file before modules (§ 3) |
| **Validation** | Lives in **`defcap`** (and reusable **`UEV_*`**). Never in `XI_` / `XE_` / `XB_` / `C_` / `W_` |
| **Reads** | Domain `read` only in **`UR_*`**. Scans only in **`URD_*`**, and those are for **UI / dirty reads** — not execution caps/`C_*`/`X_*` (§ 10.2) |
| **Writes** | Persistence in **`WI_` / `WU_` / `WW_`** when the write layer is adopted. Orchestration in **`XI_` / `XE_` / `XB_`**. Recipes in **`C_` / `A_`** |
| **Cross-module composition** | Aggregator calls many cores via `ref-M:module{…}` + `::` + IMC; never peer `MODULE.fun`; never `(use …)` for calls |
| **Foreign caps** | **Never** use another module’s capabilities. Use **policies + IMC** (§ 14) |
| **This file** | The StoicSyntax rulebook Ouronet writes against |

---

## 1. Deploy layers (recommendation)

Ouronet grew as **Utilities / Core / Talos**. StoicSyntax **recommends** the same split under **generic names**, so any Pact builder can map the idea without Ouronet vocabulary.

| # | Layer | Role | Ouronet name (example) |
|---|--------|------|-------------------------|
| 1 | **Utilities modules** | Small shared helpers, constants, guards, list/string tools — no product business tables | Stage 01 `U\|CT`, `U\|G`, `U\|LST`, … |
| 2 | **Core modules** | Business logic, domain tables, recipes (`C_` / `A_` / `X*`), policy spine | DALOS, TFT, AQP-*, PYTHIA, … |
| 3 | **Aggregator modules** | Client-facing sequences that call **many cores** in one flow; thin `@event` shells; optional policy post-steps | **Talos** (`TS01-*`, `TS02-*`) |

**Why three layers**

- Utilities stay tiny and load first.  
- Cores own state and validation.  
- Aggregators compose cross-module functions **without** owning domain tables — that is how large human-facing APIs stay auditable.

**Phases.** If more code ships over time, group each layer’s deploy into **phases** (Stage / Phase 01, 02, …). Later phases may add utilities, cores, and aggregators, but **within a phase** the load order stays:

```
Shared interfaces (if any)
  → Utilities
    → Core
      → Aggregator
        → Executor / boot (P|A_Define, governor rotate, …)
```

**Recommendation vs Ouronet today.** Treat this table as the **target architecture**. Ouronet’s folder names (`1_Utilities`, `2_Core`, `3_Talos`, `STAGE_01` / `STAGE_02`) are one concrete mapping. New work and refactors should align to Utilities → Core → Aggregator + phases.

---

## 2. Curated multi-module flows (Aggregator)

This is the **prime product pattern** StoicSyntax exists to make safe: **protected pieces in many modules**, composed only as **curated flows** in an Aggregator. End users hit the Aggregator; they do not pick core components à la carte on the blessed path.

**What is architecture vs what is an example**

| | Role in StoicSyntax |
|--|---------------------|
| **Aggregator curated flows** | **Architecture** — required shape of the discipline |
| **Forced post-steps on that path** (fee, receipt, audit hook, …) | **Optional policy** the Aggregator *can* enforce because composition is centralized |
| **IGNIS** (Ouronet virtual-chain gas) | **Ouronet’s example** of such a post-step — a “MUST on Ouronet’s blessed path,” **not** a StoicSyntax primitive |

Anyone adopting StoicSyntax needs Aggregator + locked cores. They may attach **no** economic token, or a different one. Ouronet chose IGNIS to show what the architecture **allows**.

### 2.1 The problem it solves

Without this layering, a multi-module Pact system either:

- exposes every core `C_` / write path as a public entry (clients skip steps, call half-flows), or  
- piles all tables into one mega-module (unreadable, undeployable under gas caps).

StoicSyntax splits the difference:

1. **Cores** own tables and define **protected** recipes (`C_` / `A_` / `XE_` / `XB_` / `W_*`) — each correctly gated (defcap + IMC + SECURE).  
2. **Aggregator** is the **only** client-facing composer that sequences those pieces into **allowed patterns**.  
3. **Optional:** the Aggregator may append **policy steps** that always run with the curated flow (Ouronet example: collect **IGNIS** so “run the flow” and “pay virtual gas” stay one envelope).

Result: complex functions that **span many modules and tables**, auditable piece-by-piece, while end users cannot legally execute random components as the blessed path.

### 2.2 How protection stacks (no room for “skip the hard part”)

```
End user / slave / gas-station
    │
    ▼
Aggregator                  ← only blessed client surface (Ouronet: Talos)
    │  with-capability (thin @event / summoner)
    │  ref-CoreA::C_*  →  ref-CoreB::C_*  →  …
    │  [optional policy step — e.g. Ouronet IGNIS collect]
    ▼
Core modules                ← own tables; validate in defcaps
    │  C_* / A_*  →  with-capability (master cap)
    │  XI_* / XE_* / XB_*  →  (UEV_IMC) / SECURE
    ▼
W_* persistence             ← SECURE; one write site each
```

| Layer | What is protected | What a stranger cannot do on the blessed path |
|-------|-------------------|-----------------------------------------------|
| **`W_*` / `XI_*`** | Require home `SECURE` (or documented SECURE via `W_*`) | Raw table writes without a home cap envelope |
| **`XE_*` / `XB_*`** | `(UEV_IMC)` + home named caps | Cross-module writes without registered IMP |
| **Core `C_*` / `A_*`** | Master defcap holds **all** validation; body only wires | Call the recipe without passing the cap’s enforces |
| **Aggregator** | Sequences **only** allowed cores; may force optional post-steps | Run “just the cheap half” of a multi-module flow and still get blessed / gas-station semantics |

**Core `C_` is not the end-user surface.** Clients use the Aggregator (Ouronet: **Talos**). Core recipes stay behind IMC / summoner / policy so the Aggregator can force curated steps first, then any optional policy post-step. Ad-hoc core admin may exist for maintenance but **loses** the gas-station / blessed-path story.

### 2.3 What this makes possible that would not be otherwise

| Capability | Why StoicSyntax enables it |
|------------|----------------------------|
| **Multi-module, multi-table “one function”** | Each core keeps correct local protection; Aggregator sequences `ref-::C_*` without composing foreign caps |
| **Curated-only execution** | Components live in cores; **production clients** only get Aggregator entrypoints that wire the safe order |
| **Optional forced post-steps** | Because composition is centralized, the Aggregator can require a fee, receipt, or hook **after** gated work — skip-proof on that path |
| **Chain gas-station allowlist stays small** | Station sponsors Aggregator entrypoints, not an ever-growing core list (§ 2.4) |
| **Human audit of huge systems** | Prefixes + caps + IMC + Aggregator list = follow the flow without guessing |
| **Safe evolution** | New core `C_` / `X` must be **wired into the Aggregator** to finalize for clients (§ 2.6) |

### 2.3a Example (Ouronet only): IGNIS as optional-MUST metering

**IGNIS is not part of StoicSyntax.** It is Ouronet’s chosen **optional-MUST** on curated flows: virtual-chain gas collected in / after the Aggregator path so clients cannot use the blessed Talos envelope without paying.

- **Architecture:** Aggregator sequences protected cores.  
- **Ouronet policy:** that sequence **must** include IGNIS collection (cumulator build + collect).  
- **Other adopters:** may omit metering, use another token, or attach a non-economic post-step — same Aggregator shape.

That is the point of the example: the discipline makes “execute A then B then a policy step” enforceable; IGNIS is one policy Ouronet plugged in.

### 2.4 Gas stations — plan against the Aggregator, not every core

A **gas station** (sponsor that pays native chain gas for allowed txs) must decide **which module entrypoints** are payable. Without an Aggregator layer you would whitelist **each** client-facing core — and that set grows without bound as the product adds modules.

StoicSyntax keeps the station simple:

- **Allow / reference the Aggregator module(s)** (Ouronet: Talos — `TS01-*`, `TS02-*`, …).  
- Blessed product flows **enter there**; cores are callees inside those curated txs.  
- New cores do **not** force a gas-station redesign — only new Aggregator entrypoints do.

The Aggregator is the **stable seam** for gas-station planning as cores multiply. (Ouronet’s IGNIS story is separate: virtual gas inside the flow; the station still points at Talos.)

### 2.5 Pattern sketch (Aggregator)

```pact
;; Aggregator client — curated flow spanning cores (illustrative)
(defun SomeClientFlow:string (patron:string …)
    (with-capability (P|TS)   ;; thin aggregator shell
        (let
            (
                (ref-CORE-A:module{CoreAV1} CORE-A)
                (ref-CORE-B:module{CoreBV1} CORE-B)
                ;; Ouronet example only — optional policy module:
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (ico …)   ;; after gated work
            )
            (ref-CORE-A::C_StepOne …)
            (ref-CORE-B::C_StepTwo …)
            ;; Optional-MUST for Ouronet; omit or replace in other StoicSyntax systems:
            (ref-IGNIS::C_Collect patron ico)
            (format "…")
        )
    )
)
```

Each `C_Step*` still runs its **own** master defcap and writes. The Aggregator does not re-implement validation; it **composes** already-protected units and **may** bind them to a policy post-step.

### 2.6 Finalization rule

When a new **`A_` / `C_` / protected X** is added to a core module, it is **not** production-complete until it is **wired into the matching Aggregator** (Ouronet: Talos) and IMP / summoner registration is updated. Until then it is an internal or incomplete path — not a blessed client flow (and not something the gas station needs as a new top-level allowlist entry).

Detail of IMC summoner wiring: § 14. Exact client/cap/W split: § 8–12.

---

## 3. Interface file placement

StoicSyntax rule for **where `interface` forms live in `.pact` files**. Write this down as the architecture even if a tree is still migrating toward it.

| Kind of interface | Where it lives | Why |
|-------------------|----------------|-----|
| **Historical / retired versions** | A dedicated **interfaces pack** module file(s), loaded early | Frozen APIs for old callers; do not clutter live module files |
| **Current API of one module** | **Same `.pact` file** as that module (interface first, then `(module …)`) | One deploy loads the live surface + implementation; upgrades stay co-located |
| **Shared by multiple modules** (types, policy, info schemas, collectors, …) | A **separate shared-interfaces `.pact`**, deployed **before** any module that references it | Avoid load-order cycles and duplicate interface deploys |

**Deploy sketch**

```
0_Interfaces/
  shared.pact          ;; multi-module interfaces (policy, ClientInfo, …)
  historical.pact      ;; old frozen versions only
1_Utilities/ …
2_Core/
  Foo.pact             ;; (interface FooV3 …) then (module FOO … implements FooV3)
3_Aggregator/
  Agg.pact             ;; (interface AggV2 …) then (module AGG …)  OR historical AggV1 in 0_Interfaces
```

**Rules**

1. **Do not** keep the **latest** interface in both the shared pack and the module file — double deploy fails (“interface cannot be upgraded”).  
2. When an interface is **retired**, move that version into the **historical** pack; leave only the current version beside its module (or in shared if still multi-implementer).  
3. Object-return caveat remains (§ 13.5): prefer not exposing `object{ModuleLocalSchema}` on interfaces unless the schema lives on the interface.

**Ouronet note.** The repo is **converging** on this layout (module-owned latest + slim `0_Interfaces` for shared/historical). Gaps may remain; **new code and refactors must follow this section**, then migrate stragglers.

---

## 4. Cross-module calls — interfaces + `::` (and when `(use …)` fits)

This chapter is the StoicSyntax rule for **how one module reaches another**. It exists because Ouronet deliberately **avoided** `(use …)` and peer `MODULE.fun` as the default — not only for readability, but as a **deploy-gas and coupling optimization**.

**Kadena-era ~150k deploy gas** made module size and dependency surface expensive. Pulling a **whole peer module** into the caller’s definition story (bare `(use Peer)`, or thinking in `Peer.fun` terms) makes the caller pay for / couple to a **large surface**. StoicSyntax’s answer: **cherry-pick** what you need through a **versioned interface**, then call with **`::`**. Only the interface members you actually use matter for typing and for how heavy the dependency feels at deploy time.

### 4.1 Required pattern for **calling** peers — typed module ref + `::`

Cross-module **function calls** bind a **module reference typed to an interface**, then invoke with **`::`**:

```pact
(let
    (
        (ref-DALOS:module{OuronetDalosV1} DALOS)
        (ref-TFT:module{TrueFungibleTransferV1} TFT)
    )
    (ref-DALOS::CAP_EnforceAccountOwnership account)
    (ref-TFT::C_Transfer dptf-id sender receiver amount true)
)
```

| Piece | Role |
|-------|------|
| **`module{SomeInterface}`** | Caller depends only on the **interface surface** the callee implements |
| **`::`** | Dereference / call through that typed ref |
| **Interface members** | Almost the full **public** API peers may call — version bumps when the surface changes |

Only members **used** through that interface matter for typing and coupling. StoicSyntax is **interface-heavy**: peers link a **declared API**, not “the whole module.”

### 4.2 Forbidden for peer **calls** — direct `MODULE.function`

```pact
;; WRONG — peer business calls
(DALOS.CAP_EnforceAccountOwnership account)
(TFT.C_Transfer dptf-id sender receiver amount true)
```

Dot-style `MODULE.function` treats the peer as a **whole-module** reference. That fights Ouronet’s deploy model: it inflates what must be resolved when the caller is deployed and fights the ~150k-class deploy gas budget that forced strict order and slim interfaces. **Forbid** peer business calls via `MODULE.fun`.

**Exception (docs only):** `@doc` / README may write `AQP-VCT.URDC_BuildVacateSlicePlan` as prose, not Pact call syntax.

**Capability guards** may use `MODULE.CAP` inside `create-capability-guard` for **home** caps — not a peer business call. Peer trust uses policies / IMC (§ 14).

### 4.3 What `(use …)` is — and why Ouronet never needed it for calls

Pact’s **`use`** imports names from another module (or brings schemas/types into an interface / module scope). Forms:

```pact
(use some-module)                    ;; all names into scope
(use some-module [a b c])            ;; only listed names
(use some-module HASH)               ;; all names + hash pin
(use some-module HASH [a b c])       ;; listed names + hash pin
```

Kadena’s Marmalade-style example mixes **`implements`** with **`use`** to pull **schemas / types** (and sometimes helpers) into the implementing module:

```pact
(module ledger GOVERNANCE
  (implements marmalade-v2.ledger-v2)
  (implements kip.poly-fungible-v3)
  (use kip.poly-fungible-v3 [account-details sender-balance-change receiver-balance-change])
  (use kip.token-policy-v2 [token-info])
  (use util.fungible-util)              ;; whole-module import — StoicSyntax avoids this class
  (use marmalade-v2.policy-manager)     ;; same — function/helper surface via use
  …
)
```

**Why Ouronet did not need `(use …)` so far — including gas**

Avoiding `(use …)` was a **conscious architecture choice**, not an accident:

1. **Cherry-pick the API** — `module{Iface}` + `::` depends on the **interface members you call**, not on importing the peer’s entire name table into your module. That is the StoicSyntax substitute for “I only want some of Peer.”  
2. **Deploy-gas / coupling** — bare `(use Peer)` (no import list) brings **every** name from Peer into scope at definition time; that is the expensive, whole-module-shaped dependency. Even selective `(use Peer [many functions…])` used as a **call** mechanism still hides edges and tends to grow toward a large import surface. Interface-bounded refs keep the caller’s deploy story tied to a **slim declared API**.  
3. **Shared types without import** — `object{Iface.Schema}` on shared interfaces.  
4. **Versions instead of hash-`use`** — `FooV1` → `FooV2`.  
5. **Trust via IMC**, not imported helpers.

| Need Marmalade solves with `use` | What Ouronet does instead |
|----------------------------------|---------------------------|
| Bring **shared schemas/types** into an implementing module | Define schemas on **shared interfaces** and type as **`object{Iface.Schema}`** |
| Call helpers from another module by **unqualified name** | **`(ref-X:module{Iface} X)` + `ref-X::fun`** — cherry-picked, interface-bounded |
| Pin a dependency with a **module hash** | **Interface versioning** + deploy order |
| Layer KIP / policy-manager style stacks | **Utilities → Core → Aggregator** + IMC |
**What `(use …)` is good for (when you need it)**

- **Selective schema/type import** into an `interface` or `module` that must reuse names defined elsewhere and cannot comfortably write `object{Other.Schema}` everywhere (rare in Ouronet; common in KIP/Marmalade stacks).  
- Optional **hash pin** for a frozen dependency when interface versioning is not enough.

**What `(use …)` is a bad fit for in StoicSyntax**

- Importing **functions** so you can call them unqualified — hides peer edges; prefer `ref-::`.  
- Bare **`(use some-module)`** with **no** import list — pulls **every** name into scope (same “whole surface” smell as `MODULE.fun`).  
- Using `use` as a substitute for **IMC / policy** trust.

### 4.4 StoicSyntax rule for `(use …)` (proposed)

| Form | Rule |
|------|------|
| Peer **function calls** | Always **`module{Iface}` + `::`**. Do **not** `(use …)` to call peers. |
| Bare `(use M)` / `(use M HASH)` with **no** name list | **Do not use** — whole-module import. |
| `(use M [schema-or-type-names…])` | **Allowed only** to import **schemas / types / constants** needed for `implements` or local typing when `object{Iface.Name}` is insufficient or unavailable. Document why in `@doc` or a one-line comment. Prefer shared-interface `object{Iface.Schema}` first (§ 3). |
| `(use M HASH […])` | Same as selective import; hash pin optional. Ouronet normally prefers **interface version bumps** over hash pins. |

**Default for Ouronet code:** keep doing what works — **no `(use …)`** until a concrete schema-layering case appears. Do not introduce `use` for call convenience.

### 4.4a Own modules vs foreign modules — do you *need* `(use …)`?

**No.** `(use …)` is **not** “the keyword for other people’s modules.” Pact docs present it as a general import tool (schemas, names, optional hash pins). Marmalade uses it heavily **inside its own** stack (`kip.*`, `marmalade-v2.*`, `util.*`) — ownership is not the dividing line.

**What actually decides the pattern** is whether the peer exposes a **usable interface**:

| Situation | Can you use StoicSyntax `module{Iface}` + `::`? | Role of `(use …)` |
|-----------|--------------------------------------------------|-------------------|
| **You own** the peer (Ouronet cores) | **Yes** — you design `implements` + versioned interfaces | Usually **unnecessary**; Ouronet’s default |
| **You don’t own** the peer, but it **`implements` a published interface** (KIP fungible, a vendor `FooV1`, …) | **Yes** — same as own code: `(ref-X:module{TheirIface} TheirModule)` then `ref-X::…` | Still optional; only if you must import **their schemas/types** by bare name |
| **Peer has no interface** (only a bare module API) | **`module{…}` typing cannot express their surface** | Then callers often fall back to **`(use TheirModule […])`**, `TheirModule.fun`, or ask the vendor for an interface |

So: anyone can adopt StoicSyntax’s call style for **third-party** code **whenever that code ships an interface**. Ouronet did not invent a private trick — it **standardized on interfaces end-to-end**, which is why `(use …)` never became necessary.

If you integrate a foreign module **without** an interface, StoicSyntax’s preference is still: **prefer asking for / wrapping behind an interface** over bare `(use …)` for calls. Use selective `(use … [types…])` only when you must reuse their schema names and cannot reference `object{TheirIface.Schema}`.

### 4.5 Load-time consequence

`(ref-X:module{Iface} OtherModule)` resolves when the **caller module is loaded**. `OtherModule` must **already be deployed**. Deploy order: Utilities → Core → Aggregator (§ 1). Avoid Core↔Aggregator load cycles in `P|A_Define` (§ 14.8).

### 4.6 Quick table

| Form | StoicSyntax? |
|------|----------------|
| `(ref-M:module{Iface} M)` then `(ref-M::fun …)` | **Required** for peer **calls** |
| `(M.fun …)` | **Forbidden** for peer business calls |
| `(use M)` / `(use M HASH)` no name list | **Forbidden** |
| `(use M [types…])` selective | **Optional**, schemas/types only — not for calling functions |
| Unqualified calls after `(use M)` | **Forbidden** — still use `ref-::` for calls |

---

## 5. File / module section order

Top of a StoicSyntax module (reference skeleton: ModuleSample):

1. **Policies** — inter-module guard tables (`P|T`, `P|MT`, `P|A_Define`, …) first  
2. **Schemas & tables & constants** — numbered blocks `{1}` / `;;1]` style  
3. **Capabilities** — bands **C1 → C2 → C3 → C4**  
4. **FUNCTIONS** — prefix blocks in **§ 7** order  

### Capability bands (C1–C4)

| Band | Meaning |
|------|---------|
| **C1** | Trivial / always-true-style roots (e.g. `SECURE`) |
| **C2** | Simple caps that **do not** compose other caps |
| **C3** | Ownership / account-style caps |
| **C4** | **Composite** — `compose-capability`, recipe masters, event shells |

### Schema / table numbering

- **One numbered entry per `deftable` only** — not per nested object schema.  
- Nested `object{OtherSchema}` schemas sit **under** the parent table’s `;;N]` header.  
- `deftable` declarations follow the **same** numbered order.  
- If the table will be inventoried with `select`/`where`, include a **`;;Select Keys`** field block (§ 10.3).

---

## 6. Naming — prefixes and identifiers

### 6.1 Unprotected utilities (no admin/client lock)

| Prefix | Meaning | May | Must not |
|--------|---------|-----|----------|
| **UC_** | Pure compute | `UC_`, `UDC_` | `UR_`, `URD_`, `read`, `select`, `keys`, **`enforce`** |
| **UCK_** | Table **key** constructors (AQP) | args only | table reads, enforce |
| **UR_** | Single-row read | `read` / `with-default-read` | scans |
| **UDC_** | Object constructors | build objects | — |
| **URD_** | Scan / inventory | `select`, `keys`, multi-row | **Execution path** (caps, `C_*`, `X_*`) — UI/dirty-read instead (§ 10.2) |
| **URC_** | Read + compute via **UR_** | `UR_`, `UC_`, `UDC_`, `URC_` | **URD_**, **`enforce`** |
| **URDC_** | Read + compute via **URD_** | `URD_` + UR/UC/UDC/URC | **`enforce`**; same execution ban as **URD_** (§ 10.2) |
| **UEV_** | Enforce / validate | may `enforce` | placed **after** all read tiers |
| **CAP_** | Account / ownership enforce helpers | like UEV, ownership-focused | — |

**Auxiliary depth:** `URCX_` / `URDCX_` under parent URC/URDC blocks (same read-depth rules).

**Documented exception — bounds-guard `enforce` inside `UC_` list/string helpers (SWP L41, 2026-08-23):**
`U|LST`'s own `UC_*` helpers (`UC_ReplaceAt`, `UC_RemoveItemAt`, `UC_LE`, `UC_FE`, and `UEV_NotEmpty`
where they call it) `enforce` on a list's own shape — index-in-bounds, list-not-empty — before indexing
into it. This is **not** a business/domain validation the "must not enforce" rule is meant to keep out of
`UC_*`; it is a guard **intrinsic to the computation itself**, preventing a bare out-of-bounds crash mid-
computation, not gating an application-level decision. Any `UC_*` elsewhere in the codebase that calls
these specific helpers (e.g. `U|SWP`'s `UC_ComputeY`/`UC_ComputeInverseY`/`UC_AddSupply`/
`UC_RemoveSupply`) **stays `UC_*`** and is **excluded from any StoicSyntax rename/reclassification
sweep** — do not rename these to `UEV_`/`URC_` or split them apart chasing pure-`UC_` compliance. Scope
is narrow and explicit: only this specific class (list/string-shape bounds guards). A `UC_*` calling into
real business validation (an owner check, a balance check, a domain-rule enforce) is still a genuine
violation and not covered by this exception.

**Migration signals**

- `UC_` that calls `UR_` / `read` → rename **`URC_`**  
- `URC_` that calls `URD_` → rename **`URDC_`**  
- Invalid input in URC → return safe default / bool; fail in **UEV_** or **defcap**

### 6.2 Protected entrypoints

| Prefix | Who | Role |
|--------|-----|------|
| **AU_** | Admin keys, admin-mode only | **Admin Update** — schema/data migration functions only (e.g. force existing rows to pick up a newly-added field). Distinct from `A_`'s live-business-mutation role; placed immediately before `A_` in the FUNCTIONS block (§7). Introduced 2026-08-24 from the SWP audit (L54) — codifies the pre-existing `AHU`/`AUP_*` pattern already used across `01_DALOS`, `05_DPTF`, `06_DPOF`, `08_ATS`, `15_SWP`, `02_DPDC` as the forward-going standard name. |
| **A_** | Admin keys | Administrator recipes |
| **C_** | Client / via Aggregator | Client recipes; may wire optional fee cumulators (Ouronet: IGNIS) |
| **XI_** | This module only | Internal orchestration → `W_*` |
| **XE_** | Forward / external modules | Cross-module write entry |
| **XB_** | Home **and** peers | Bidirectional write; **IMC** replaces SECURE |

### 6.3 Identifier style

| Kind | Rule | Example |
|------|------|---------|
| **`defun` inside module** | Prefix only — **no** redundant `MODULE\|` in the name | `UC_ComputeMinSliceCount` not `UC_VCT\|ComputeMinSliceCount` |
| **Capabilities / schemas** | May use `MODULE\|…` | `VCT\|C>FULL-…`, `VCT\|Job`, `PYTHIA\|A>FLUSH` |
| **`@doc` / README cross-refs** | `ModuleName.function` | `AQP-VCT.URDC_BuildVacateSlicePlan` |
| **Cap name shape** | `MODULE\|C>…`, `MODULE\|A>…`, `MODULE\|XI>…`, `MODULE\|XE>…` | `SCR\|C>ISSUE-SCORE` |

### 6.4 Capability naming quick map

| Cap | Typical use |
|-----|-------------|
| **`SECURE`** | Internal write gate; composed by recipe / XE caps |
| **`MODULE\|GOV`** | Smart-account governor for this module’s vault |
| **`P\|…\|CALLER`**, **`P\|SECURE-CALLER`** | Policy / caller guards |
| **`MODULE\|C>…`** | Master **client** recipe (often `@event`) |
| **`MODULE\|A>…`** | Master **admin** recipe |
| **`MODULE\|XI>…`** | Named cap for an XI path (when needed) |
| **`MODULE\|XE>…`** | Named cap for an XE path (validation + compose SECURE) |

---

## 7. FUNCTIONS block order (canonical)

Under **FUNCTIONS**, group in this order (AQP reference: `05_VCT.pact`):

| # | Prefix | Role |
|---|--------|------|
| 1 | **UC_** | Pure compute |
| 2 | **UCK_** | Key constructors (AQP) |
| 3 | **UR_** | Single-row reads |
| 4 | **UDC_** | Object constructors (right after UR_) |
| 5 | **W_** (`WI_` / `WU_` / `WW_`) | Persistence (AQP) |
| 6 | **URD_** | Scans |
| 7 | **URC_** | Read+compute (no URD) |
| 8 | **URDC_** | Scan+compute |
| 9 | **UEV_** | Validation |
| 10 | **C_** | Client recipes |
| 11 | **AU_** | Admin Update — schema/data migration functions only (§6.2), placed immediately before `A_` |
| 12 | **A_** | Admin recipes |
| 13 | **X** (`XI_` / `XE_` / `XB_`) | Orchestration / cross-module writes — inside XI: **all tier 0, then all tier 1, then all tier 2…** (§ 12.1) |

**CAP_** helpers sit with **UEV_** or just before **C_** per module habit.

---

## 8. Client flow decomposition (the architecture)

```
Talos / slave
    → C_* / A_*          (with-capability master cap → wire; optional fee step)
        → defcap         (ALL validation; compose SECURE / GOV / XE caps)
            → XI_* / XE_* / XB_*   (orchestrate; no enforce)
                → W_*    (SECURE + one insert|update|write LAST)
```

| Layer | Responsibility |
|-------|----------------|
| **Master `defcap`** | **All** auth + validation: `CAP_*`, `UEV_*`, boolean `enforce`, ownership. May `@event`. Ends with **`compose-capability`** |
| **`W_*`** | Module-internal persistence only. `(require-capability (SECURE))` then **one** persistence op as **final** expression. **No** `enforce`. **Not** on interfaces |
| **`XI_*` / `XB_*`** | `UR_*` + compute + one or more `W_*`. **No** `enforce`, **no** `UEV_*`, **no** `OutputCumulator` |
| **`XE_*`** | `(UEV_IMC)` → `with-capability (…\|XE>…)` → `W_*` / `XI_1|*`. Caller `C_*` may build fee cumulator |
| **`C_*` / `A_*`** | `UEV_IMC` (when needed) → `with-capability` → call `W_*` / `X_*`. Optional fee cumulator (Ouronet: IGNIS). **No** bare `enforce`, **no** raw `write` when `W_*` exists |

**Several writes:** prefer **multiple** focused `XI_`/`XB_` functions rather than one kitchen-sink writer.

**X tier naming / source order** — see **§ 12.1** (`XI_*` → `XI_1|*` → `XI_2|*`; never skip a hop; **all tier 0, then all tier 1, then all tier 2…**).

---

## 9. Capabilities — how to write them

### 9.1 Master recipe cap (every public `C_*`)

1. One **master** cap per public recipe: `MODULE|C>…` (or `MODULE|A>…`).  
2. **`@doc`** then **`@event`** (if evented), then body.  
3. **All** validation inside the cap via **`UR_*` / `URC_*` / `UEV_*`** (point reads) — **never** raw domain `read`/`select`, and **avoid `URD_*` / `URDC_*`** in caps (§ 10.2).  
4. Cap **`compose-capability (SECURE)`** for same-module `XI_*` / `W_*`.  
5. Cross-module legs: compose `MODULE|XE>…` / GOV / nested recipe caps as needed.  
6. **`C_*` body:** acquire cap → compute in `let` → call `X_*` / `W_*` — **no** `enforce`, **no** raw persistence.

### 9.2 `defcap` body statement order (strict)

1. **`let`** — refs first, then `;;`, then locals (see § 13)  
2. **All Pact natives** — every `enforce` / `enforce-guard` / `enforce-keyset` / `enforce-one` (including `(enforce (ref-M::URC_…))`)  
3. **All bare `ref-*` calls** — `ref-DALOS::CAP_*`, `ref-DPTF::UEV_id`, fees, …  
4. **Home-module helpers** — rare standalone `URC_*` / `CAP_*` validators  
5. **`compose-capability` last** — `SECURE`, `GOV`, `P|CALLER`, child caps  

Rule of thumb: **all enforce → all bare ref → home → compose caps.**

### 9.3 Boolean grouping in one `enforce`

Pact `and` is **binary only**. Combining booleans:

| Count | Form |
|------:|------|
| 1 | `(enforce p "msg")` |
| 2 | `(enforce (and p q) "msg")` |
| 3+ | `(enforce (fold (and) true [p q r …]) "msg")` |

Same 1 / 2 / 3+ rule for **`:bool`** utilities (final form `(and p q)` or `(fold (and) true […])`).

**Wrong:** `(and a b c)` → runtime `Attempted to apply a closure to too many arguments`.

**Non-booleans** (`CAP_*`, `UEV_*`, `UEV_Fee`, …) stay as **separate** calls **before** the combined boolean `enforce`.

### 9.4 Batch / array validation

1. One **`UEV_*:bool`** that **folds** the array (pure bools in the lambda — no `enforce` inside).  
2. Cap: **one** `(enforce (UEV_Entries entries) "…")`.  
3. **Never** `(keys …)` for existence in caps — use `try` + `UR_*` (see PYTHIA flush). `(keys …)` only in **`URD_*`**, and those helpers are **not** for execution-path caps (§ 10.2).

### 9.5 Dynamic data needed for validation

Compute in **`C_*` `let` before `with-capability`**, pass values **into the defcap** as parameters, validate **inside** the cap.

### 9.6 No duplicate validation

Do not re-check the same inputs in both **defcap** and **UEV_**. Keep UEV focused; prefer existing bindings over alias renames (`x:string y`).

---

## 10. UR / URD reads — layout, and when **not** to scan

### 10.1 `UR_*` layout (point reads — execution-safe)

1. **Call sites** never `read` domain tables — always call **`UR_*`**.  
2. **Inside `UR_*`:** full-row `(read table key)`; per-field `(at "field" (read table key ["field"]))`.  
3. **Groups** — one UR block per `deftable`, **same order** as schemas.  
4. **Within a group** — full-row → per-field in **schema key order** → object helpers → multi-key composites.  
5. **Per-field args** = **row key components**, not `object{…}` rows.  
6. **Multi-table same schema** — one dispatch `UR_*` with `(with-default-read (UC_*Table disc) key …)`; don’t triple-copy.  
7. **`with-default-read`** for absent rows lives in **`UR_*`** (defaults via `UDC_*`).  
8. **`let` only when a binding is used ≥ 2 times** — otherwise inline.  
9. One name per read — no redundant aliases.

### 10.2 `URD_*` / `URDC_*` — avoid like the plague on the execution path

**`URD_*`** (`keys` / `select` / multi-row inventory) and **`URDC_*`** (derive from those scans) are **expensive**. They belong almost never in:

- **`defcap`** validation  
- **`C_*` / `A_*` / `XI_*` / `XE_*` / `XB_*`** execution bodies  
- any **on-chain tx** that must stay inside block gas

Treat scans as **off the hot path**. Prefer a **new table (or field) that already stores the aggregate** you would have scanned for — maintain it with **`W_*` / `UR_*`** on each write — so execution does a **point read**, not a table walk.

| Do this | Not this |
|---------|----------|
| `UR_Counter` / `UR_Totals` / indexed row maintained at write time | `(keys Table)` or `select` inside a cap / `C_*` to “count” or “find all” |
| Pass known ids into the cap (computed earlier or known from prior issuance) | Discover ids by scanning in the same tx |
| UI / `/local` **dirty read** calling `URD_*` / `URDC_*` | Same scan inside gas-station / Aggregator / core execution |

**Intended homes for `URD_*` / `URDC_*`**

1. **UI / clients before submit** — build the payload (id lists, plans, inventories) with dirty reads, then submit a tx that only uses **`UR_*` / `URC_*`** + caps.  
2. **Local / dirty-read queries** (`/local`, REPLs, dashboards) — inventory, explorers, “show me everything.”  
3. **Rare, explicitly budgeted** ops — only when a scan is unavoidable and gas is proven safe; document why no aggregate table exists.

**Why (gas)**

| Environment | Typical block / practical ceiling | Implication |
|-------------|-----------------------------------|--------------|
| **Kadena-class** | ~**150k** gas | Scans in caps/txs are especially lethal — **Kadena Pact builders should follow this rule hard** |
| **StoaChain / Ouronet** | ~**2,000,000** gas | More headroom, **still** avoid scans on the execution path — 2M is not permission to `select` the world in every recipe |

StoicSyntax: **design data so execution never needs `URD_` / `URDC_`.** If you catch yourself reaching for a scan in a cap or `C_*`, stop and ask whether a **maintained aggregate row** (or passing ids from the UI) fixes it.

**Anti-patterns**

- `(contains id (keys Table))` for existence → `try` + `UR_*`  
- Cap validates “all rows of kind X” via `URDC_*` → maintain membership / counters at write time; validate with `UR_*`  
- `C_*` builds a vacate/stake plan by scanning on-chain → UI builds plan via dirty `URDC_*`; tx consumes the plan + point reads  

### 10.3 Schema “Select Keys” — design rows so `select` / `where` can filter

Pact **`select`** / **`where`** filter on **row object fields**, not on the opaque string table key. If the only copy of `pool-id` / `owner-id` / … lives inside a concatenated key string, you **cannot** write `(where 'pool-id …)` cleanly.

StoicSyntax discipline: when a table may be inventoried (even only for UI / dirty `URD_*`), **denormalize the filter dimensions into the schema** under an explicit **`;;Select Keys`** block — the same components used to build **`UCK_*`**.

```pact
(defschema AQP|TrueFungibleTracker
    balance:decimal
    ;;
    ;;Select Keys
    pool-id:string
    dptf-id:string
    owner-id:string
    beneficiary-id:string
)
```

(Ouronet: `03_AQP.pact` trackers — same pattern on Pool `aqp-id`, score attributions, beneficiary totals, …)

| Rule | Detail |
|------|--------|
| **Mark them** | Comment block **`;;Select Keys`** in the `defschema` so authors know why the fields exist |
| **Mirror the key** | Same atoms as **`UCK_*`** / composite key — written once at **`WI_*` / `WW_*`** via **`UDC_*`** |
| **Usually not alone-updated** | W block: `;; WU_Table\|PoolId — select key; WU not needed.` (not mutable as a lone field) |
| **Enables `URD_*`** | `(select Table […] (where …))` for dirty reads / UI — still **not** for hot caps/`C_*` (§ 10.2) |
| **Cost tradeoff** | Extra columns on every row in exchange for **filterable** inventory without parsing keys |

Without Select Keys, teams either scan everything and filter in Pact lists (worse gas) or cannot express the query. With them, `URD_*` stays possible for **off-path** use while execution stays on **`UR_*`**.

---

## 11. W writes (AQP: ANK → VCT)

**Scope:** `STAGE_02/2_Core/03_AQP/`. Other modules migrate when touched.

| Prefix | Op | When | Payload |
|--------|-----|------|---------|
| **WI_** | `insert` | Row must not exist | Full row via `UDC_` |
| **WU_** | `update` | Row exists | One non-key field |
| **WU{N}_** | `update` | Row exists | N fields |
| **WW_** | `write` | Upsert | Full row via `UDC_` |

No row delete in Pact — deactivate with a **WU_** on a flag.

### Guards / visibility

- **Internal only** — never on interfaces, never `ref-OTHER::W_*`.  
- Body: `(require-capability (SECURE))` then **persistence as last expression**. Nothing after. **No `enforce`**.  
- External writes: `XE_*` / `XB_*` → `UEV_IMC` + named cap → `W_*`.

### Naming

- **Table short name** = last segment after `T|` (`ANK|T|Anchor` → `Anchor`).  
- Drop module prefix: `WU_Anchor|State`, not `WU_ANK|Anchor|State`.  
- Single-field suffix mirrors paired **`UR_*`**: `UR_ANK|State` → `WU_Anchor|State`.  
- Multi-field: `WU2_Anchor|State&Promile` or aggregate `WU4_Pool|VacateJobState`.  
- Keys: take components; call **`UCK_*`** inside. Migrate `UC_*Key` → `UCK_*` when touching AQP.

### W block layout (per table)

```
WI_*  →  WW_*  →  WU_* (every schema field)  →  WU2_+ (only if needed)
```

- Missing WI/WW: **comment**, not empty `defun`:  
  `;; WI_Anchor — not used: first row touch is WW_Anchor (upsert path).`  
- Every schema field gets a **WU line**: `defun` or comment (`not mutable [.]`, `select key; WU not needed`, `not used: mutates via WW_*`).  
- No placeholder comments for unused **WU2_+**.

### Anti-patterns

- Raw `insert`/`update`/`write` in `XI_`/`XE_`/`C_` when a `W_*` exists  
- Code after the persistence op in a `W_*` body  
- `enforce` in `W_*` or `XI_*`  
- Cross-module `W_*` calls  

---

## 12. X functions — guards, tiers, and returns

| Entry | Guard | Body |
|-------|-------|------|
| **XI_*** | `(require-capability (SECURE))` **or** `;; SECURE: granted by W_…` | `W_*` orchestration; no enforce |
| **XE_*** / **XB_*** | `(UEV_IMC)` first (or documented comment) | `with-capability` → `XI_*` / `W_*` |
| **C_*** / **A_*** | recipe cap | wire only — no enforce |

When **all** persistence goes through `W_*` (each already requires SECURE), **do not** repeat SECURE on `XI_*` — use the `;; SECURE:` comment.

**Returns:** `XI_` / `XE_` / `XB_` = **writes only** — no trailing `true`, no fee `OutputCumulator` object. **`C_*` / Aggregator** build optional metering after the gated write (Ouronet: IGNIS).

**Wrong:** `(enforce (UEV_IMC) "…")` — IMC is a statement, not an enforce predicate.  
**Wrong:** `enforce` / persist-check inside `XE_` / `C_` after `with-capability`.

### 12.1 X tier naming (`XI_*` / `XI_1|*` / `XI_2|*` …)

Internal orchestration is **layered by depth**. The name encodes the tier so callers never jump into a deep helper without the intermediate step.

| Name form | Tier | Who may call it | Role |
|-----------|------|-----------------|------|
| **`XI_Name`** | **0** | Home **`C_*` / `A_*`** (same module) | Top internal orchestrator for that home path |
| **`XI_1\|Name`** | **1** | Tier-0 **`XI_*`**, or **`XE_*` / `XB_*`** | First sub-step (fold body, one write site, …) |
| **`XI_2\|Name`** | **2** | Tier-1 **`XI_1|*`** only | Deeper helper under tier 1 |
| **`XI_3\|Name`** … | **3+** | Previous tier only | Same rule — one hop at a time |

```
Home client path:
  C_* / A_*  →  XI_* (tier 0)  →  XI_1|* (1)  →  XI_2|* (2)  →  …

Cross-module path:
  XE_* / XB_*  →  XI_1|* (tier 1)  →  XI_2|* (2)  →  …
                 ;; never XE_* → XI_2|* (skip forbidden)
```

**Rules**

1. **Never skip a hop** — `XE_*` / `XB_*` must not call `XI_2|*` directly; go through `XI_1|*`. `C_*` must not call `XI_1|*` as if it were tier 0 when a tier-0 `XI_*` wrapper exists for that path (use the tier-0 entry, or document an intentional flat path).  
2. **Pipe `|` after the tier digit** — `XI_1|ApplyOneFlushEntry`, `XI_1|PlaceAnchorInBookkeeping` (readable depth marker).  
3. **Tier 0 keeps the plain `XI_` prefix** — no `XI_0|`; bare `XI_Foo` means depth 0.  
4. **Same no-enforce / write-only rules** at every tier — validation stays in defcap; persistence via `W_*` (or documented SECURE).  
5. **Depth exists for audit and reuse** — fold/`map` bodies and shared sub-writes sit at tier 1+ so the entry (`C_*` / `XE_*`) stays thin.  
6. **Source order = all of one tier, then the next** — under the **X** FUNCTIONS block, arrange definitions as:

```
;; all tier 0
(defun XI_Foo …)
(defun XI_Bar …)
;; all tier 1
(defun XI_1|FooStep …)
(defun XI_1|BarStep …)
;; all tier 2
(defun XI_2|FooLeaf …)
…
;; then XE_* / XB_* (cross-module entries) in their own band after XI tiers
```

**Do not** nest children under each parent (`XI_Foo`, then its `XI_1|…`, then `XI_Bar`, then its `XI_1|…`). That yields a bouncing **0 → 1 → 2 → 0 → 1** scroll and breaks visual tier banding. Flat **0s, then 1s, then 2s, then 3s…** keeps every depth in one scannable strip.

Within a tier, order by domain / call-graph habit of the module (stable and local); the hard rule is **tier bands**, not interleaved parent/child stacks.

Example (Ouronet PYTHIA flush shape):

```pact
;; A_* / C_* → XI_Flush… (tier 0) → fold XI_1|ApplyOneFlushEntry → WI_/WU_
(defun XI_FlushPythLedger …)           ;; tier 0  — with other XI_* 
(defun XI_1|ApplyOneFlushEntry …)      ;; tier 1  — with other XI_1|*
```

Example (cross-module):

```pact
(defun XE_TrueFungibleTransfer …)
    (UEV_IMC)
    (with-capability (AQP|XE>…)
        …                              ;; may call XI_1|* for tracker legs, not XI_2|*
    )
```

### 12.2 XB vs XE

| | **XB_** | **XE_** |
|---|---------|---------|
| Direction | Home `C_*` **and** peer modules | Forward export, typically one direction |
| Guard | `UEV_IMC` (IMC replaces SECURE) | `UEV_IMC` + named `MODULE\|XE>…` |
| When | Same table write shared by peers without a second public API | Forward module needs a dedicated validated entry |
| Next hop | Often `XI_1|*` or `W_*` | Often `XI_1|*` or `W_*` — still no skip to `XI_2|*` |

Caller registers IMP via **`P|A_Define`** → target `P|A_AddIMP` (boot Step 0 after both modules load).

---

## 13. Indentation, formatting, and observability

Readability is a **hard StoicSyntax requirement**, not cosmetics. Indentation and layout are how a human **observes** intent in multi-thousand-line modules — the same goal as prefixes and section order.

### 13.0 Indentation and visual scan

| Practice | Why |
|----------|-----|
| **Stable indentation** | Nested `let` / `with-capability` / `if` / `map` must show depth at a glance — same indent step throughout the file (Ouronet sovereign: typically **4 spaces**, match the file you edit) |
| **One visual language per module** | New code matches nearby style so the file does not become a mix of layouts |
| **Section bars and labeled blocks** | `;;<====>`, `;;POLICY`, `;;{C1}`, `{F0} [UR]`, `;;Select Keys` — jump points for eyes and search |
| **Grouped `let` bindings** | Refs first → `;;` → locals (§ 13.1); optional inner `;;` chunks for logical groups |
| **Multiline params when long** | One param per line (§ 13.3) — signatures stay scannable in review |
| **Aligned schema field comments** | Trailing `;;[M]` / class notes lined up where the file already does — domain meaning next to the field |
| **Numbered step comments** | `;; 1] natives`, `;; 2] ref`, `;; 3] home`, `;; 4] caps` in complex caps/recipes |
| **~88–92 character lines** | Avoid horizontal scrolling; break `@doc` with `\` continuation |
| **`let` is ALWAYS expanded — never `(let ((…`** | `(let` on its own line; the binding-list `(` on its own indented line; **each binding on its own line**; the body follows the closed binding list. The compact `(let ((x …)) body)` (let + binding-list opener + first binding all on one line) is **forbidden**, even for a single binding — depth must be visible at a glance. Dependent bindings → derive them via a helper bound in the same list (a binding cannot reference a sibling), not a nested `let` (the codebase does not use `let*`). |
| **No stacked closing parens — `)))))` is forbidden** | Every **structural** closer (`defun`, `let`, `map`/`filter`/`fold` lambda, multi-line `if`/`with-capability`, a call whose args span lines) gets **its own line, indented to the form it closes** — so a human can see *what* closes *where* without counting parens. Never end a form with a run of stacked `)))))`. A leaf call whose whole content fits on one line keeps its single trailing `)` inline (`(+ "F\|" asset-id)`, `(at "legs" lane)`); the rule targets the multi-closer stacks, not one-liners. **Derive the collection a `map`/`filter`/`fold` iterates as a NAMED binding in the `let` first** — never inline a complex list/`if`/`filter` expression as the iterated argument. |
| **No drive-by reformat** | Behavioral PRs must not churn unrelated whitespace — preserves blame and review focus |

```pact
;; Good — depth and groups are obvious
(defun C_Example:string (patron:string id:string)
    @doc "…"
    (UEV_IMC)
    (let
        (
            (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            ;;
            (row …)
            (ok:bool …)
        )
        ;; 1] natives live in the defcap — body only wires
        (with-capability (MOD|C>EXAMPLE id)
            (XI_Example id)
        )
        (ref-IGNIS::UDC_… )
        (format "…")
    )
)
```

```pact
;; WRONG — compact let: let + binding-list opener + first binding on one line (depth hidden)
(let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS))
    (body …))

;; RIGHT — expanded let, even for one binding
(let
    (
        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
    )
    (body …))

;; RIGHT — dependent bindings use NESTED let (no let* in this codebase)
(let
    (
        (native-id:string (ref-AQP::UR_AQP|PoolAssetId pool-id))
    )
    (let
        (
            (frozen-id:string (+ "F|" native-id))
        )
        (body …)))
```

**Anti-pattern:** dense one-liners, the compact `(let ((…` form, mixed tabs/spaces, params squeezed on continuation lines, or “reindent the whole module” in a logic PR.

Detail that feeds observability (already required elsewhere): **`let` order** (§ 13.1), **body statement order** (§ 13.2), **parameter layout** (§ 13.3), **`@doc` / `@event` / step comments** (§ 13.4).

### 13.1 `let` binding order

```pact
(let
    (
        (ref-DALOS:module{OuronetDalosV1} DALOS)
        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
        ;;
        (key:string (UCK_…))
        (bal:decimal (UR_…))
    )
    …
)
```

1. All `(ref-*:module{…} …)`  
2. `;;` separator (when locals follow)  
3. Local variables  

Bind once when the same expression appears in multiple `enforce` lines (`entry-count`, `l-n`, …).

### 13.2 Executable body order (after `let`)

| Step | What |
|------|------|
| 1 | Pact natives (`enforce*`, …) |
| 2 | Bare `(ref-MODULE::…)` |
| 3 | Home (`UR_*`, `URC_*`, `XI_*`, `W_*`, …) — **not** `URD_*` / `URDC_*` on hot paths (§ 10.2) |
| 4 | Capabilities (`with-capability`, `require-capability`, `compose-capability`) |

Inside `with-capability`: peer `ref-*::XE_*` before home `XI_*` / `W_*`.

### 13.3 `defun` / `defcap` parameters

| Case | Layout |
|------|--------|
| Fits one line | Full signature on one line |
| Too long | Name (+ return type) on line 1; **one param per line** in `(…)` |

**Do not** hybrid-squeeze params onto continuation lines.

`@doc` (then `@event` on caps) comes **immediately after** the closing `)` of the parameter list — never between name and `(`.

### 13.4 Docs and comments

- Prefer meaningful **`@doc`** on new/refactored functions and caps.  
- Numbered **step comments** inside complex caps / recipes (`;; 1] natives`, `;; 2] ref`, …).  
- Keep source lines roughly **~88–92 characters**; break long `@doc` with `\` continuation.  
- Prefer **`let`** when a name is used more than once; otherwise inline.  
- Match nearby file style; don’t churn unrelated formatting (§ 13.0).

### 13.5 Interfaces and object returns

If an interface would return `object{ModuleLocalSchema}` before that schema exists at load time:

- Prefer **keep schemas in the module** and **omit** those typed full-row functions from the interface, **or**  
- Move the schema into the interface.

Common pattern: interface exposes **scalar** `UR_*` and untyped `object` / `DataOrNull`; typed full-row stays module-local.

---

## 14. Inter-module communication (policies, IMC, GOV)

This section is StoicSyntax’s **security spine**. Caps alone are not enough when many modules share accounts and write paths. The architecture **rejects** “compose a capability that lives in another module” and replaces it with a **policy-guard registry** plus an implementer check (`UEV_IMC`). Ouronet’s modules are the worked example; the pattern ports to any multi-module Pact system.

### 14.1 Hard rule — capabilities stay inside their module

**A module must never use capabilities that exist in another module.**

Forbidden (examples of the old / wrong pattern):

```pact
;; WRONG — composing / requiring a foreign module capability
(compose-capability (AQP-POOL.AQP|GOV))          ;; from a peer module
(with-capability (OTHER.OTHER|C>RECIPE …) …)
(require-capability (PEER.SECURE))
```

Allowed:

```pact
;; RIGHT — only home-module caps in compose / with / require
(compose-capability (SECURE))
(compose-capability (P|FVT|CALLER))
(compose-capability (P|FVT|REMOTE-GOV))
(compose-capability (FVT|C>…))
(with-capability (AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY …) …)  ;; only inside the home module
```

**Why:** Foreign `compose-capability` couples modules at the capability graph, breaks deploy/signing assumptions, and lets callers open another module’s internal `SECURE` / `GOV` envelope. Trust between modules must be **explicit, admin-wired, and guard-based**.

### 14.2 Policy spine — exact boilerplate (copy this)

Every StoicSyntax core / aggregator module that participates in IMC implements the policy interface (Ouronet: **`OuronetPolicyV1`**) and this block **verbatim in structure**. Replace `SAMPLE` / `GOV|SAMPLE_ADMIN` / `P|SAMPLE|CALLER` with the module’s names. Source of truth: `0_Sample/C0s__01_01_ModuleSample.pact` (mirrored in live modules such as `AQP-POOL`, `TS01-C4`).

```pact
;;==================================================================
;; POLICY  — Inter-Module Communication (IMC) spine
;;==================================================================
;;{P2}
(deftable P|T:{OuronetPolicyV1.P|S})
(deftable P|MT:{OuronetPolicyV1.P|MS})
;;{P3}
(defcap P|SAMPLE|CALLER ()
    true
)
(defcap P|SECURE-CALLER ()
    (compose-capability (P|SAMPLE|CALLER))
    (compose-capability (SECURE))
)
;;{P4}
(defconst P|I                   (P|Info))
(defun P|Info ()
    (let ((ref-DALOS:module{OuronetDalosV1} DALOS))
        (ref-DALOS::P|Info)
    )
)
(defun P|UR:guard (policy-name:string)
    (at "policy" (read P|T policy-name ["policy"]))
)
(defun P|UR_IMP:[guard] ()
    (at "m-policies" (read P|MT P|I ["m-policies"]))
)
(defun P|A_Add (policy-name:string policy-guard:guard)
    (with-capability (GOV|SAMPLE_ADMIN)
        (write P|T policy-name
            {"policy" : policy-guard}
        )
    )
)
(defun P|A_AddIMP (policy-guard:guard)
    (with-capability (GOV|SAMPLE_ADMIN)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (dg:guard (create-capability-guard (SECURE)))
            )
            (with-default-read P|MT P|I
                {"m-policies" : [dg]}
                {"m-policies" := mp}
                (write P|MT P|I
                    {"m-policies" : (ref-U|LST::UC_AppL mp policy-guard)}
                )
            )
        )
    )
)
(defun P|A_Define ()
    ;; Post-deploy only: register THIS module as implementer on TARGETS it calls.
    ;; Do not wire Aggregator↔Core here at module-load time if that creates a cycle —
    ;; run P|A_Define from the executor / boot after both sides are deployed.
    (let
        (
            (ref-P|TARGET:module{OuronetPolicyV1} TARGET)
            (mg:guard (create-capability-guard (P|SAMPLE|CALLER)))
        )
        (ref-P|TARGET::P|A_AddIMP mg)
    )
)
(defun UEV_IMC ()
    (let
        (
            (ref-U|G:module{OuronetGuardsV1} U|G)
        )
        (ref-U|G::UEV_Any (P|UR_IMP))
    )
)
;; After (module …): (create-table P|T) (create-table P|MT)
```

| Symbol | Meaning |
|--------|---------|
| **`P|T` / `P|UR` / `P|A_Add`** | Named policy slots (RemoteGov, custom roles) |
| **`P|MT` / `P|UR_IMP` / `P|A_AddIMP`** | Implementer list for **`UEV_IMC`** |
| **`P|<MODULE>\|CALLER`** | Local caller cap; its **capability-guard** is what you register as IMP |
| **`P|A_Define`** | This module’s post-deploy registration onto **targets** |
| **`UEV_IMC`** | Gate on the **callee**: any registered implementer guard must pass |

Optional on vault owners (Ouronet AQP-POOL): a local **`P|<MODULE>|REMOTE-GOV`** placeholder cap (body `true`) documenting that peers register **their** remote-gov guards on this module’s `P|T` by name.

### 14.3 How to use IMC — exact call patterns

#### A) Callee gate (every cross-module mutator on Home)

First statement of `XE_*` / `XB_*` / IMC-gated `C_*` — **not** wrapped in `enforce`:

```pact
(defun XE_CreateFvtLink:string
    (score-id:string fvt-id:string)
    @doc "Forward entry: UEV_IMC; home cap validates; W_ writes."
    (UEV_IMC)
    (with-capability (SCR|XE>CREATE-FVT-LINK score-id fvt-id)
        (WU_Score|FvtLink score-id fvt-id)
    )
    fvt-id
)
```

(Ouronet: `AQP-SCORE.XE_CreateFvtLink`.)

Custody-style XE (Ouronet: `AQP-POOL.XE_TrueFungibleTransfer`):

```pact
(defun XE_TrueFungibleTransfer:object{IgnisCollectorV1.OutputCumulator}
    (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    (UEV_IMC)
    (with-capability (AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY pool-id owner-id beneficiary-id dptf-id amount direction)
        (let
            (
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                ;;
                (vault:string AQP|SC_NAME)
            )
            (if direction
                (ref-TFT::C_Transfer dptf-id owner-id vault amount true)
                (ref-TFT::C_Transfer dptf-id vault owner-id amount true)
            )
        )
    )
)
```

#### B) Core → other core (Caller registers CALLER on Target)

```pact
(defun P|A_Define ()
    (let
        (
            (ref-P|TFT:module{OuronetPolicyV1} TFT)
            (ref-P|DPOF:module{OuronetPolicyV1} DPOF)
            (ref-P|DPDC-T:module{OuronetPolicyV1} DPDC-T)
            ;;
            (mg:guard (create-capability-guard (P|AQP|CALLER)))
        )
        (ref-P|TFT::P|A_AddIMP mg)
        (ref-P|DPOF::P|A_AddIMP mg)
        (ref-P|DPDC-T::P|A_AddIMP mg)
        true
    )
)
```

(Ouronet: `AQP-POOL.P|A_Define` — run from boot / executor after deploy.)

#### C) Aggregator → many cores (summoner guard)

```pact
(defcap P|TALOS-SUMMONER ()
    @doc "Aggregator summoner capability"
    true
)

(defun P|A_Define ()
    (let
        (
            (ref-P|CODEX:module{OuronetPolicyV1} CODEX)
            (ref-P|PYTHIA:module{OuronetPolicyV1} PYTHIA)
            (ref-P|IGNIS:module{OuronetPolicyV1} IGNIS)
            (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
            (ref-P|TS01-A:module{TalosStageOne_AdminV1} TS01-A)
            (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
        )
        (ref-P|CODEX::P|A_AddIMP mg)
        (ref-P|PYTHIA::P|A_AddIMP mg)
        (ref-P|IGNIS::P|A_AddIMP mg)
        (ref-P|DALOS::P|A_AddIMP mg)
        (ref-P|TS01-A::P|A_AddIMP mg)
    )
)
```

(Ouronet: `TS01-C4.P|A_Define`. Aggregator client caps compose **`P|TALOS-SUMMONER`** so core `UEV_IMC` passes.)

#### D) Peer → Home IMP + named RemoteGov (no foreign GOV)

```pact
(defun P|A_Define ()
    (let
        (
            (ref-P|SCR:module{OuronetPolicyV1} AQP-SCORE)
            (ref-P|AQP:module{OuronetPolicyV1} AQP-POOL)
            (ref-P|TFT:module{OuronetPolicyV1} TFT)
            ;;
            (dg:guard (create-capability-guard (SECURE)))
            (mg:guard (create-capability-guard (P|FVT|CALLER)))
            (rg:guard (create-capability-guard (P|FVT|REMOTE-GOV)))
        )
        (ref-P|SCR::P|A_AddIMP dg)
        (ref-P|AQP::P|A_AddIMP dg)
        (ref-P|AQP::P|A_Add "FVT|RemoteAqpGov" rg)
        (ref-P|TFT::P|A_AddIMP mg)
        ;; …
    )
)
```

(Ouronet: `AQP-FVT.P|A_Define`. Inject/collect caps **`compose-capability (P|FVT|REMOTE-GOV)`** only — never `AQP|GOV`.)

#### E) Flow summary (no guessing)

```
1. Deploy Utilities → Core → Aggregator (phase order).
2. Executor / boot calls each module’s P|A_Define (dependency-safe order).
3. Tx: Caller acquires its OWN caps (recipe / CALLER / SUMMONER / REMOTE-GOV).
4. Caller invokes Home::XE_* / XB_* / C_*.
5. Home runs (UEV_IMC) → UEV_Any over P|UR_IMP → then home with-capability → W_*.
```

| Layer on Home | Gate |
|---------------|------|
| Cross-module mutator (`XE_*`, `XB_*`, many `C_*`) | **`(UEV_IMC)`** first |
| Home-only writer (`W_*`, often `XI_*`) | **`(require-capability (SECURE))`** — composed only by **Home** caps |
| Named validation | Home **`defcap`** only |

**What IMC is not**

- Not an `enforce` predicate: **never** `(enforce (UEV_IMC) "…")`.  
- Not required for plain **`UR_*` / `CAP_*` / account-type reads**.  
- Not a substitute for Home’s recipe / XE **validation caps**.  
- Core **`P|A_Define`** must **not** register on Aggregator at **module load** if Aggregator loads later — wire Aggregator→Core from Aggregator’s `P|A_Define`; run both Defines at executor time.

### 14.4 Named policies vs IMP list

| Mechanism | Table | Use when |
|-----------|-------|----------|
| **`P|A_Add` + `P|UR`** | `P|T` | Named slots: RemoteGov, custom governor fragments |
| **`P|A_AddIMP` + `P|UR_IMP`** | `P|MT` | **Who may call** IMC-gated functions (`UEV_IMC`) |

RemoteGov rotate (concept): owner smart-account governor becomes `UEV_GuardOfAny` of `[create-capability-guard (HOME|GOV), ref-P|HOME::P|UR "FVT|RemoteAqpGov", …]`.

### 14.5 Smart-account governor patterns

| Pattern | Account owner | Runtime compose | Rotate governor |
|---------|---------------|-----------------|-----------------|
| **Simple vault** | Same module | **`MODULE\|GOV`** on send **and** receive | `(create-capability-guard (MODULE.MODULE\|GOV))` |
| **Hub + children** | Parent | Child composes **`P|*|REMOTE-GOV`** (own module) | **`UEV_GuardOfAny`**: parent GOV + `P|UR` child slots |
| **Forward on foreign vault** | Other module | Forward composes **only** its **`P|*|REMOTE-GOV`** | Named slot on **owner’s** `P|T` via child `P|A_Define` |

- **`MODULE|GOV`** = “I **own** this account” (home only).  
- **`P|*|REMOTE-GOV`** = “I **operate** your account from my module”.

**Why `MODULE|GOV` is safe even with a `true`/no-`enforce` body:** Pact requires a *foreign* caller (a
different module, or bare transaction/top-level code) to already hold **that module's admin** before it can
`with-capability` one of its capabilities — verified empirically (Pact 5.4, two-module repro,
2026-08-16, see `memories/2026-08-16-with-capability-requires-module-admin-for-foreign-callers.md`): only
code physically inside the home module can freely compose `MODULE|GOV`; a foreign module or raw
transaction attempting the same gets `"Module admin necessary for operation but has not been acquired"`.
So `MODULE|GOV` is **not** a cross-module skeleton key — it cannot be forged from outside. The real risk
to audit is narrower: every **public function inside the home module** that composes `MODULE|GOV` must
still do its own real authorization (ownership/policy check) *before* composing it, since Pact does not
restrict *which of the module's own public functions* may compose it — only *who outside the module* can.

### 14.6 XB shared writes (home + peers, still no foreign caps)

| | Home | Peer |
|---|------|------|
| Write entry | **`XB_SetFoo`** — `(UEV_IMC)` then `W_*` | `ref-HOME::XB_SetFoo` under peer’s own recipe + IMC |
| Public | **`C_SetFoo`** — home caps → `XB_*` → metering | Does not duplicate XB |
| Wire | Peer `P|A_Define` → Home `P|A_AddIMP` | Boot after both load |

### 14.7 Layered capability composition — unevented core + named event leaves

**Rule:** when two or more client-facing actions need the **identical (or near-identical) authorization
body** but must stay **distinguishable as separate events** (for indexers, off-chain listeners, or just
readable transaction logs), factor the shared body into one **unevented "core" `defcap`**, then give each
action its own **thin, `@event`-tagged "leaf" `defcap`** whose entire body is
`(compose-capability (CORE args))`. Client `C_*` functions `with-capability` their own leaf, never the
core directly, never each other's leaf.

**Never duplicate a validation body across sibling `@event` caps just to get two event names.** That's
exactly the failure mode this pattern exists to prevent: the same `CAP_Owner` / `UEV_*` checks
copy-pasted into two (or more) places drifts the moment one copy gets fixed and the other doesn't.

This composes exactly like the rest of § 14 — `compose-capability` stays **home-only** (§ 14.1), and a
leaf may itself be composed by a still-more-specific leaf (a real chain, not just two levels) when an
action needs the shared body **plus** one more check of its own. Two live examples, same file:

**Multi-level (pre-existing, `08_ATS.pact`)** — one core, two mid-tier specializations, five `@event`
leaves total:
```pact
(defcap ATS|S>CONTROL-RECOVERY (atspair:string)          ;; core — no @event
    (CAP_Owner atspair)
    (UEV_ParameterLockState atspair false)
)
(defcap ATS|C>CONTROL-COLD-RECOVERY (atspair:string)      ;; mid-tier — no @event, adds one check
    (UEV_ColdRecoveryState atspair false)
    (compose-capability (ATS|S>CONTROL-RECOVERY atspair))
)
(defcap ATS|C>SET_COLD_FEES (atspair:string ...)          ;; leaf — @event, thin
    @event
    (let (...)
        (ref-U|ATS::UEV_CRF|Positions fee-positions)      ;; leaf may add its OWN extra checks too
        (compose-capability (ATS|C>CONTROL-COLD-RECOVERY atspair))
    )
)
;; ATS|C>CONTROL-COLD-FEES, ATS|C>SET_COLD-DURATION, ATS|C>TOGGLE_ELITE also compose
;; ATS|C>CONTROL-COLD-RECOVERY as their own distinct leaves.
```

**Single-level (minimal case)** — one core, two thin leaves, nothing else:
```pact
(defcap ATS|C>HOT-RBT-BRD (entity-id:string)              ;; core — no @event
    (let ((atspair:string (ref-DPOF::UR_RewardBearingToken entity-id)))
        (CAP_Owner atspair)
        (compose-capability (ATS|GOV))
    )
)
(defcap ATS|C>HOT-RBT-UPDATE-BRD (entity-id:string)        ;; leaf — @event, thin
    @event
    (compose-capability (ATS|C>HOT-RBT-BRD entity-id))
)
(defcap ATS|C>HOT-RBT-UPGRADE-BRD (entity-id:string)       ;; leaf — @event, thin
    @event
    (compose-capability (ATS|C>HOT-RBT-BRD entity-id))
)
```

**Naming:** core caps keep the `MODULE|S>*` or `MODULE|C>*` shape same as any other cap — nothing marks
"this is a core" except the *absence* of `@event`. Leaves are named for the client-visible action they
gate (`…UPDATE-BRD`, `…UPGRADE-BRD`), not for the shared mechanism.

### 14.8 Load / deploy order (IMC wiring)

```
Shared interfaces → Utilities → Core → Aggregator → Executor (all P|A_Define)
```

- `(ref-X:module{Iface} OtherModule)` resolves at **load** time.  
- After redeploy of an IMC pair: re-run **`P|A_Define`** (and governor rotate if RemoteGov). Without it, `UEV_IMC` fails even when code is correct.

### 14.9 Aggregator finalization (Talos)

See **§ 2** (curated Aggregator flows). Wire every new core **`A_` / `C_` / protected X** into the matching Aggregator; register summoner IMP (§ 14.3 C). Thin `@event` on Talos; validation stays in core master caps. Ouronet may also attach IGNIS as an optional-MUST post-step (§ 2.3a).

---

## 15. Greenfield feature workflow

1. **Schema** — shapes, keys, one numbered entry per table; nested schemas under parent.  
2. **Client surface** — name `C_` outcomes and aggregator / policy callers (intent only).  
3. **UR_*** — grouped like schemas; field order like schema keys.  
3b. **UCK_ + W_*** — WI/WW/WU blocks when using the write layer; not-used comments where needed.  
4. **Implement each `C_` end-to-end** — defcap → W/X → add `URC`/`UEV` **as that path needs them** (do not front-load every helper).

---

## 16. Migration checklist (legacy Pact → StoicSyntax)

Use this when converting an older module or adopting StoicSyntax in a new codebase. Treat **this file’s version** as the target contract.

- [ ] Section order: policies → schemas/tables → C1–C4 caps → FUNCTIONS in § 7 order  
- [ ] Deploy layers: **Utilities → Core → Aggregator**, phased as needed (§ 1)  
- [ ] Curated flows only via Aggregator; wire new `C_`/`X` into Aggregator/Talos (§ 2). Optional: Ouronet-style IGNIS post-step (§ 2.3a)  
- [ ] Interfaces: historical in pack; current beside module; shared types before modules (§ 3)  
- [ ] Peer **calls** only via **`module{Iface}` + `::`** — never `MODULE.fun`; no `(use …)` for calling peers (§ 4)  
- [ ] Policy spine present with **exact IMC helpers** (§ 14.2): `P|T`, `P|MT`, `P|UR`, `P|UR_IMP`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `UEV_IMC`  
- [ ] **No foreign caps** — never compose/with/require another module’s capabilities (§ 14.1)  
- [ ] Cross-module mutators gated with **`(UEV_IMC)`**; peers registered via **`P|A_Define` → P|A_AddIMP** (§ 14.3)  
- [ ] Remote vault ops use **`P|*|REMOTE-GOV`** + named `P|A_Add`, not foreign `MODULE|GOV`  
- [ ] Sibling `@event` caps with identical/near-identical bodies: factor into one unevented core `defcap` + thin `@event` leaves that only `compose-capability` it (§ 14.7) — never duplicate the validation body  
- [ ] Rename mis-tiered helpers (`UC_` that reads → `URC_`; `URC_` that scans → `URDC_`)  
- [ ] Strip `enforce` from UC/URC/URDC/XI/XE/XB/C/W  
- [ ] Move all validation into **defcap** (+ reusable **UEV_**)  
- [ ] Domain reads via **UR_***; **no `URD_*` / `URDC_*` in caps / `C_*` / `X_*`** — prefer aggregate tables; scans for UI/dirty reads (§ 10.2)  
- [ ] Schemas that need inventory: **`;;Select Keys`** fields mirroring `UCK_*` for `select`/`where` (§ 10.3)  
- [ ] (AQP) Introduce **UCK_** + **W_***; replace raw persistence in X/C  
- [ ] Cap body order: enforce → ref → home → compose  
- [ ] Boolean 1 / 2 / 3+ (`and` vs `fold (and)`)  
- [ ] `let`: refs → `;;` → locals; params one-line or one-per-line  
- [ ] `@doc` after param list; `@doc` then `@event` on caps  
- [ ] X returns write-only; fee/IGNIS cumulators (if any) live in `C_*` / Aggregator — not in X  
- [ ] X tier naming: `XI_*` (0) → `XI_1|*` → `XI_2|*`; `XE_*`/`XB_*` enter at tier 1 — no hop-skip (§ 12.1)  
- [ ] X source order: **all tier 0, then all tier 1, then all tier 2…** — not interleaved parent/child stacks (§ 12.1)  
- [ ] Wire aggregator (Talos) + executor/boot `P|A_Define` / governor rotate  
- [ ] No `(keys …)` in cap validation — `try` + `UR_*`  
- [ ] Indentation/observability: stable nesting, section labels, grouped `let`, ~88–92 cols; no drive-by reformat (§ 13.0)  
- [ ] Line length ~88–92; step comments on complex flows  

---

## 17. Anti-pattern cheat sheet

| Don’t | Do |
|-------|-----|
| `compose-capability` / `with-capability` on **another module’s** cap | Home caps only; peers via **policy guards + IMC** (§ 14) |
| Call core `C_*` as the public client path (skip Aggregator) | Aggregator curated flow only (§ 2) |
| Peer call via `MODULE.fun` | `(ref-M:module{Iface} M)` then `ref-M::fun` (§ 4) |
| `(use M)` with no name list / `use` to call functions | Selective `(use M [types…])` only if schemas need it; calls stay `ref-::` (§ 4) |
| Latest interface duplicated in pack + module | Module-owned latest **or** shared pack — never both (§ 3) |
| Shared multi-module interface only inside one core file | Shared-interfaces `.pact` before modules (§ 3) |
| Compose foreign `OTHER\|GOV` from a forward module | Local `P|*|REMOTE-GOV` + `P|A_Add` on owner + `UEV_GuardOfAny` |
| Call IMC-gated `XE_*` without registering IMP | Caller `P|A_Define` → target `P|A_AddIMP` |
| `read` / `select` in defcap / C_ / XI_ | `UR_*` (point reads) |
| `URD_*` / `URDC_*` in caps / `C_*` / `X_*` | Aggregate table + `UR_*`, or UI dirty-read then pass ids (§ 10.2) |
| Composite key with no filterable columns | Add **`;;Select Keys`** fields for `select`/`where` (§ 10.3) |
| `enforce` in XI_ / XE_ / C_ / W_ | Put it in defcap / UEV_ |
| `(and a b c)` | `fold (and) true [a b c]` |
| `(enforce (UEV_IMC) …)` | `(UEV_IMC)` as a statement |
| Raw `write` in C_ when W_ exists | Call `W_*` / `XI_*` |
| Fee cumulator from XI_/XE_/XB_ | Build optional metering in `C_*` / Aggregator (Ouronet: IGNIS) |
| `ref-M::WU_…` | `XE_*` / `XB_*` on home |
| `(keys Table)` for existence in caps | `(try false (let ((_ (UR_…))) true))` |
| `UC_VCT\|Foo` inside VCT | `UC_Foo` |
| Dense / inconsistent indentation | Stable indent + section bars + step comments (§ 13.0) |
| `XE_*` / `C_*` calls `XI_2|*` directly | Respect tier hops: `XI_*` → `XI_1|*` → `XI_2|*` (§ 12.1) |
| Interleaved `XI_` / `XI_1|` / `XI_` stacks in source | Band by tier: all 0s, then all 1s, then all 2s (§ 12.1) |
| Compose SECURE before all enforces | Enforce / ref first; compose last |
| Two `@event` caps, same validation body pasted twice | One unevented core `defcap` + thin `@event` leaves composing it (§ 14.7) |
| Core `P|A_Define` → Talos at load | Executor-time Define after both load |
| Skip boot `P|A_Define` after redeploy | Re-wire IMP / RemoteGov or `UEV_IMC` fails |

---

## 18. Ouronet detail (same discipline, deeper inventory)

These paths document how Ouronet applies StoicSyntax in this tree. External adopters need only this handbook; these links are for Ouronet maintainers and deep audits.

| Topic | File (under `OuronetInformational/`) |
|-------|------|
| Full architecture / prefixes | `ouronet/MODULE_ARCHITECTURE.md` |
| Convention checklist | `ouronet/conventions/index.md` |
| Function / cap body order | `pact/function-body-order.md`, `pact/defcap-body-order.md` |
| `let` / params | `pact/let-binding-layout.md`, `pact/defun-parameter-layout.md` |
| Booleans | `pact/enforce-boolean-grouping.md`, `pact/enforce.md` |
| UC / URC / URDC | `ouronet/conventions/uc-urc-urdc-prefixes.md` |
| UR layout | `ouronet/conventions/ur-layout.md` |
| W writes | `ouronet/conventions/w-writes.md` |
| UR vs W vs XI | `ouronet/conventions/ur-and-w-writes.md` |
| X guards | `ouronet/conventions/x-function-guards.md` |
| XB + IMC | `ouronet/conventions/xb-imc-cross-module.md` |
| X no cumulator | `ouronet/conventions/x-writes-no-cumulator.md` |
| Recipe caps | `modules/aqp/recipe-cap-validation.md` |
| GOV / vault / RemoteGov | `ouronet/conventions/smart-account-governor.md`, `modules/aqp/tft-vault-imc.md` |
| Load order | `ouronet/conventions/module-load-order-and-pact-refs.md` |
| Interface objects | `pact/interface-object-return-rule.md` |
| Vocabulary | `CONTEXT.md` |
| Policy sample | `0_Sample/C0s__01_01_ModuleSample.pact` (repo root) |

---

## 19. Ouronet-specific rules (normative for Ouronet; optional for other adopters)

Everything above is **generic StoicSyntax**. This chapter collects the rules that are **Ouronet-specific**:
they layer on top of the discipline and are **normative for Ouronet code**, but an external adopter may
ignore them (they concern IGNIS metering, the exact prefix universe, and Ouronet's observability tuning).
Kept in one place per **R5** so Ouronet-specifics are not scattered across the handbook.

### 19.1 `X-cm_` — X functions that emit an IGNIS cumulator (R1)

§12 says X functions (`XI`/`XE`/`XB`) are writes-only and return **no** `OutputCumulator` — the `C_`/`A_`
recipe composes IGNIS. In Ouronet this holds by default. **But** when a flow is complex enough that
threading the cumulator all the way up to the `C_` obscures the logic, an X function **may** build and
return the IGNIS `OutputCumulator` itself. Such a function is **named with `-cm` appended to the leading
prefix token**, so the emission is visible at the call site:

| Default (no cumulator) | Emits IGNIS cumulator |
|------------------------|-----------------------|
| `XI_Name` | `XI-cm_Name` |
| `XI_1\|Name` (tier 1) | `XI-cm_1\|Name` |
| `XE_Name` | `XE-cm_Name` |
| `XB_Name` | `XB-cm_Name` |

1. `-cm` is **only** for the IGNIS `OutputCumulator` return — not for other return values (those use R4).
2. The tier marker stays after `-cm`: `XI-cm_1|…`, `XI-cm_2|…`.
3. A plain `XI_`/`XE_`/`XB_` (no `-cm`) must **not** return a cumulator — the name is a promise.
4. Prefer the default (cumulator built in the `C_`); reach for `-cm` only when it genuinely simplifies a
   multi-leg flow, and say **why** in `@doc`.

### 19.2 Multi-table X functions are allowed (R2)

§11/§12 prefer "one focused write path per X." Ouronet **permits** a single `XI`/`XE`/`XB` to write to
**more than one table** when the writes are part of **one indivisible bookkeeping step** (e.g. a
nonce-total table + its ANK-meta counter that must move together). Keep it deliberate: the tables must be
genuinely coupled by the same operation — do **not** use this to dump unrelated persistence into one X.
Each underlying write still goes through its `W_*` (SECURE), and the X still carries **no** `enforce`.

### 19.3 `CC_` / `AA_` — HEAVY recipes that unavoidably scan (R3)

§10.2 bans `URD_`/`select`/`keys` on the execution path. That ban **stands** — avoid at all costs, and
**never** on a daily-hot path (stake / unstake / collect / inject / transfer). But a few recipes have no
correct alternative to a scan (e.g. a single-transaction **full-vacate** that must attempt to empty a
pool). When a `C_`/`A_` — **or any function in its call graph** — unavoidably uses a `URD_`/scan, it is
**HEAVY** and is renamed with a doubled prefix so it is instantly observable:

| Normal recipe | HEAVY recipe (URD/scan somewhere in its graph) |
|---------------|-------------------------------------------------|
| `C_Name` | `CC_Name` |
| `A_Name` | `AA_Name` |

1. `CC_`/`AA_` is a **warning label, not a license** — every one must justify in `@doc` why the scan is
   unavoidable and confirm it is not a daily-hot path.
2. The scan still lives in a `URD_`/`URDC_` (never inline `select`/`keys` in the recipe body), and
   **never** inside a `defcap`.
3. If a maintained-aggregate row can replace the scan, do that and keep the plain `C_`/`A_`.

### 19.4 X `@doc` output rule (R4)

An X function may end on a value other than its final `W_*` (§12 default). When it **deliberately returns a
value**, its `@doc` **must state what it outputs and why** ("returns the new nonce id", "returns the settle
bundle for the caller"). Only the IGNIS `OutputCumulator` return is *also* reflected in the **name** (R1
`-cm`); every other return is documented in `@doc` but keeps the plain prefix.

### 19.5 `;;Key = <...>` — every `deftable` documents its own row key (R6)

Introduced by the AQP modules (`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/`), formalized here after being applied
retroactively to the SWP-family modules. Every `deftable` — **domain table or policy table (`P|T`/`P|MT`)
alike, no exceptions** — carries a trailing inline comment on the **same line** stating what value(s) the
table is actually `read`/`insert`/`with-default-read` keyed by:

```pact
(deftable SWP|Pairs:{SWP|PairsSchemaV3})                    ;;Key = <swpair>
(deftable SWPT|PathCache:{SwapTracerV2.PathCacheRow})        ;;Key = <token-a>|<token-b> (insertion-order, reversed-lookup at read time)
(deftable P|T:{OuronetPolicyV1.P|S})                         ;;Key = <policy-name>
(deftable P|MT:{OuronetPolicyV1.P|MS})                       ;;Key = P|I (module-identity singleton constant)
```

1. Format is `;;Key = <...>` — a `<placeholder>` per key component, `|` between composite-key pieces
   (matching how the key string is actually built, e.g. `(+ (+ token-a "|") token-b)`), free text in
   parentheses when the key has a non-obvious property (insertion order, a singleton constant, a fixed
   sentinel) worth flagging for the next reader.
2. This documents the table's **own primary row key** — distinct from **§10.3's `;;Select Keys`**, which
   denormalizes *filterable dimensions inside the schema* for `select`/`where` inventory queries. A table
   can have both: one `;;Key = <...>` (what `read` takes) and, if it's ever scanned, a `;;Select Keys`
   block inside its `defschema` (what `where` can filter on).
3. **`P|T`/`P|MT` are not exempt.** Every module implementing `OuronetPolicyV1` gets the identical pair —
   `P|T` keyed by `<policy-name>`, `P|MT` keyed by the module's own `P|I` singleton constant — so the
   comment is boilerplate-identical across modules, but still required; a reader auditing one module in
   isolation should never have to cross-reference another to know what a table's key shape is.
4. Applies retroactively: when touching a module for other reasons and its tables are missing this
   comment, add it as part of that pass rather than leaving it for a dedicated sweep.

### 19.6 Consolidation index (R5) — other Ouronet-specifics already in this handbook

These stay explained in context; this is the single index of what is Ouronet-specific (not generic):
- **IGNIS as optional-MUST metering** on the Talos blessed path — §2, §2.3a.
- **Talos = the Aggregator**; the gas-station allowlist targets Talos, not an unbounded core set — §2, §2.4.
- **Prefix universe** — `UC / UCK / UR / URD / URC / URDC / UDC / UEV / CAP` and
  `A / C / CC / AA / XI / XE / XB` (+ `-cm`) — §6, §7, and §19.1 / §19.3 here.
- **Every `deftable` documents its own row key** — `;;Key = <...>`, §19.5 (R6).
- **Deep inventory** of how Ouronet applies all the above — §18.

---

## Versioning

| Version | Date | Notes |
|---------|------|-------|
| **1.0.0** | 2026-08-01 | First published handbook: syntax layers, why-architecture intro, full IMC / no-foreign-caps spine |
| **1.1.0** | 2026-08-01 | Framed as a reusable Pact architecture; Ouronet as reference implementation |
| **1.2.0** | 2026-08-01 | Presented as **Ouronet’s discipline** for human-auditable large Pact + Talos-style multi-module composition; offered for any Pact builder |
| **1.3.0** | 2026-08-01 | Deploy layers (**Utilities / Core / Aggregator** + phases); interface file placement; **exact IMC boilerplate and call patterns** from Ouronet |
| **1.4.0** | 2026-08-01 | Cross-module calls: **`module{…}` + `::` required**; forbid peer **`MODULE.fun`**; initial `(use …)` ban |
| **1.5.0** | 2026-08-01 | Refined **`(use …)`**: why Ouronet never needed it for calls; allow selective schema/type import only; calls stay `ref-::` |
| **1.5.1** | 2026-08-01 | Clarified: StoicSyntax `::` works for **foreign** modules too when they publish interfaces; `(use …)` is not “for non-owned modules only” |
| **1.5.2** | 2026-08-01 | § 4 framed as dedicated chapter; explicit **deploy-gas / cherry-pick** motivation for avoiding bare `(use …)` |
| **1.6.0** | 2026-08-01 | **§ 2 Curated multi-module flows**: Aggregator-only blessed paths, locked components, IGNIS virtual gas |
| **1.6.1** | 2026-08-01 | § 2.4: **gas-station allowlist** targets Aggregator (Talos), not an unbounded core set |
| **1.6.2** | 2026-08-01 | **IGNIS** reframed as Ouronet **optional-MUST example**, not a StoicSyntax architectural requirement (§ 2 / § 2.3a) |
| **1.6.3** | 2026-08-01 | **§ 12.1 X tier naming**: `XI_*` / `XI_1|*` / `XI_2|*`, no hop-skip |
| **1.6.4** | 2026-08-01 | **§ 10.2**: avoid `URD_`/`URDC_` on execution path; prefer aggregates; UI/dirty-read; Kadena 150k / Stoa ~2M gas |
| **1.6.5** | 2026-08-01 | **§ 10.3 Schema Select Keys**: denormalize key components for `select`/`where` |
| **1.6.6** | 2026-08-01 | **§ 13.0**: indentation / visual observability discipline for human scan |
| **1.6.7** | 2026-08-01 | **§ 12.1**: X source order = all tier 0, then all tier 1, then all tier 2… (no interleaved stacks) |
| **1.7.0** | 2026-08-11 | **§ 19 Ouronet-specific rules** (new chapter): `X-cm_` naming for X funcs that emit an IGNIS cumulator (R1); multi-table X allowed (R2); `CC_`/`AA_` HEAVY prefixes for `C_`/`A_` that unavoidably scan (R3); X `@doc` output rule (R4); Ouronet-specifics consolidation index (R5). From AQP audit Round I owner feedback. |
| **1.8.0** | 2026-08-21 | **§ 19.5 `;;Key = <...>`** (new rule, R6): every `deftable` — domain or `P|T`/`P|MT` policy table alike, no exceptions — carries an inline comment stating its own row key. Introduced by the AQP modules, formalized here after being applied retroactively across the SWP-family modules (owner reminder, #34 session). |
| **1.9.0** | 2026-08-23 | **§ 6.1 documented exception**: `U|LST`'s bounds-guard `enforce` helpers (`UC_ReplaceAt`, `UC_RemoveItemAt`, `UC_LE`, `UC_FE`) and any `UC_*` calling them stay `UC_*` and are excluded from renaming/reclassification — the `enforce` guards the computation's own list/string shape (index-in-bounds, not-empty), not a business/domain decision. From SWP audit Round I, finding L41 (owner direction, 2026-08-23). |
| **1.10.0** | 2026-08-24 | **§ 6.2 / § 7 new prefix `AU_`** (Admin Update): admin-mode-only functions whose sole purpose is schema/data migration (force existing rows to pick up a newly-added field), distinct from `A_`'s live-business-mutation role; placed immediately before `A_` in the FUNCTIONS block order. Codifies the pre-existing `AHU`/`AUP_*` pattern already used across `01_DALOS`, `05_DPTF`, `06_DPOF`, `08_ATS`, `15_SWP`, `02_DPDC` as the forward-going standard name — existing instances are a known, deliberate, shared pattern intentionally left unrenamed for now, deferred to the full post-merge StoicSyntax sweep as one coordinated cross-module rename rather than touched piecemeal. From SWP audit Round I, finding L54 (owner direction, 2026-08-24). |

**Bump rules**

- **MAJOR** — incompatible convention changes (e.g. rename of a required prefix tier, IMC model change).  
- **MINOR** — new sections / rules that extend without breaking existing compliant code.  
- **PATCH** — clarifications, examples, typo fixes, link updates.

When publishing updates: change the version table at the top **and** append a row here. Ouronet Pact (and anyone adopting StoicSyntax) should cite **StoicSyntax ≥ the version in force** at authoring time.

---

*StoicSyntax is the discipline Ouronet uses to write large, human-auditable Pact — and the rulebook any Pact builder can follow for the same ends. Durable rule changes land in this file first (version bump), then in matching OuronetInformational detail docs.*

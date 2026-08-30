# Ouronet — accumulated context

_Last updated: 2026-05-06_

## What Ouronet is

**Ouronet** is a **virtual blockchain system** implemented entirely in **Pact** (Kadena’s smart-contract language). It defines its own token architecture and DeFi-style primitives, deployed in **stages**, with a split between **sovereign** (canonical architecture) and **slave** (third-party) modules.

### Token and pool vocabulary

| Concept | Meaning |
|--------|---------|
| **True fungible** | Standard fungible tokens |
| **Orto fungible** (“ortofungible”) | Fungible with **metadata in batches** (live path uses `DPOF`) |
| **Semi-fungibles** | Numbered “NFTs” (editions) |
| **Non-fungibles** | Unique NFTs |
| **Collectables** | Umbrella term for semi- + non-fungible |
| **ATS-pairs** | **Autostake pools** built from true fungibles |
| **SWP-pairs** | **Liquidity pools** built from true fungibles; ortofungibles can also interact |
| **AQP** | **Acquisition pools** (earning pools) |

### Deployment stages (on-chain design)

- **Stage 1:** True fungibles, ortofungibles, autostake pools (ATS), SWP-pairs.
- **Stage 2:** Collectables, **DemiPad** (Demiourgos launchpad), **AQP** acquisition pools.

### Sovereign vs slave modules

- **Sovereign modules** — **Ouronet** modules that define the core architecture (maintained by the project author).
- **Slave modules** — Modules **anyone** can write; they call into sovereign APIs.

Repository layout mirrors this: **`1_SOVEREIGN/`** and **`2_CITIZEN/`**, each with subfolders **`STAGE_01`**, **`STAGE_02`**, etc.

### Kadena, StoaChain, and REPL testing

- **Kadena LLC** wound down; **StoaChain** continues a **Chainweb-class** stack with **custom coin**, **namespaces**, and **economy**. **Ouronet** is deployed on **StoaChain** under **`ouronet-ns`** (migrated from earlier Kadena-era testing under `free`).
- **Dual sandbox (Stage 0):** **`REPL/Stage00_Sanboxes.repl`** loads **`00_KadenaSandbox/kda-env/init.repl`**, then **`00_StoaSandbox/stoa-env/init.repl`**.
  - **Kadena sandbox:** Mainnet-style fungibles and **`kadena-coin`** (module renamed from `coin` in `kadena/coin-v6.pact`) so the identifier **`coin`** is reserved for Stoa’s native token in the same REPL.
  - **Stoa sandbox:** **Live** sources under **`00_StoaSandbox/`** — root **`ns`**, **`coin`**, **`util`**, **`stoa-ns`** interfaces/modules — initialised in **genesis order** with payloads aligned to **`0_Stoa/genesis/*.json`** (phased `init-phase-*.repl` files). Registers **`ouronet-ns`** the same way as on-chain genesis.
- **REPL namespaces:** All Ouronet deploy / test `.repl` files under **`REPL/`** use **`(namespace "ouronet-ns")`** and qualified refs like **`ouronet-ns.DALOS`** (bulk migration from former `free`).
- **`REPL/Stage00a_StoaTests.repl`:** Stoa **`coin`** regression script inline (legacy `coinn` / `free` tests adapted: root **`coin`**, foundation **`stoa-foundation`**, **`test-capability`** where genesis keys differ from the old k: foundation). Run after **`Stage00_Sanboxes.repl`**.
- **Integration REPL suites** (scripted **`begin-tx`** / **`commit-tx`**): follow **`OuronetInformational/ouronet/architecture/REPL_AND_TESTS.md`** (*Canonical layout*) and **`OuronetInformational/ouronet/conventions/repl-integration-test-layout.md`**. Reference **`REPL/Stage_02/[6.2.1]_AQP-ANK.repl`** and **`[6.2.2]_AQP-SCORE.repl`** (`;;|| NEXT >`, **`TX… · mm ·`** group comments + matching **`(print "--- [TX… · mm · …] ---")`**, **`map print`** over **`expect`** / **`expect-failure`**, file header legend).
- **Stage 2 AQP bootstrap (handoff):** Slave **`2_CITIZEN/4_VaultsMinter/04_AQP-BOOT.pact`** exposes **`C_Step1`**–**`C_Step6`** (discrete provisioning). **`REPL/Stage02_Tester.repl`** loads it in-namespace **before** **`[6.2]_AQP.repl`**. In **`[6.2.2]_AQP-SCORE.repl`**, **score-definition** exercises (**`TX-SCORE-11`**) must run **after** **`C_Step4`/`C_Step5`/`C_Step6`** txs (**`TX-SCORE-08`–`10`**) because **`C_Issue*ScoreDefinition`** reads existing **`SCR|T|Score`** rows — see **`ouronet/architecture/REPL_AND_TESTS.md`** § *Stage 2 AQP + AQP-BOOT*.
- **Genesis reference:** **`0_Stoa/genesis/`** — ordered `stoa-genesis-1` … `stoa-genesis-5` (JSON payloads for 1–4 where applicable); sandbox phases mirror this using **live** `00_StoaSandbox` Pact where it differs from frozen genesis sources.

## Goals

- Preserve accurate architecture vocabulary and stage boundaries for implementation and REPL work.
- Keep Kadena-compatible and Stoa-compatible test harnesses usable side by side where needed.

## Non-goals

*(Not specified yet.)*

## Repository layout (high level)

| Path | Role |
|------|------|
| `1_SOVEREIGN/STAGE_*` | Canonical Ouronet modules by stage |
| `2_CITIZEN/*` | Community / extended modules using sovereign APIs |
| `00_KadenaSandbox/` | Kadena-like sandbox: **`kadena-coin`**, kip, util (`kda-env/init.repl`) |
| `00_StoaSandbox/` | Stoa-like sandbox: **`coin`**, `ns`, `util/*`, `stoa-ns/*` (`stoa-env/init.repl`) |
| `0_Stoa/genesis/` | Historical genesis txs + JSON payloads (ordering reference) |
| `REPL/` | Staged `.repl` files; `Z.repl` loads full pipeline |
| `OuronetInformational/` | Persistent notes for humans and AI across sessions |

## Tech stack & tooling

- **Pact** smart contracts.
- **Chainweb-class** execution on **StoaChain** for production deployment of this fork/migration story.

## Conventions & naming

- **DemiPad** — Demiourgos launchpad (Stage 2).
- **`ouronet-ns`** — Namespace for Ouronet sovereign/slave modules in REPL and on StoaChain (replacing legacy **`free`** in test harnesses).
- **`kadena-coin`** vs **`coin`**: Kadena KDA analogue in REPL is **`kadena-coin`**; Stoa native token module is **`coin`** at root.

### Module structure, function prefixes, and Talos

Sovereign code follows a fixed **layout and naming system**: Stage‑1 **utilities** (`U|CT`, `U|G`, `U|LST`, …), **core** modules with **policy tables** up front, capability bands **C1–C4**, then **unprotected** helpers (**UC**, **UR**, **URC**, **UEV**, **UDC**, **CAP**) and **protected** entrypoints (**A_** admin, **C_** client, **X**/XI/XE/XB). Because of deploy size limits, modules depend on **earlier** deploys and use **interface-heavy** APIs (version bumps cascade refactors). **Talos** modules are the only intended place to chain **A_**/**C_** for users, enforce **IGNIS** gas collection after **C_** paths, and match **gas-station** payout rules. Full detail: **`OuronetInformational/ouronet/MODULE_ARCHITECTURE.md`** (including **Client flows**: **`XI`/`XE`/`XB`** = **`insert`/`update`/`write`** only — no trailing **`true`**, no **`OutputCumulator`**; **`C_`** builds IGNIS **`UDC_*`**; **combining booleans in one `enforce`**: 1 → plain; 2 → **`(and p q)`**; 3+ → **`fold (and) true [...]`**); sample layout: **`0_Sample/C0s>>01|01_ModuleSample.pact`**. For **greenfield features**, that doc also defines the workflow: schema → client API intent → **`UR_*`** (grouped like schemas, ordered like schema keys) → implement each **`C_`** path with caps and **`X_*`**, adding **`URC`**/**`UEV`** as needed per path.

### Scaling pattern — defun+gate (batch ops too big for one tx)

For an operation whose work is **O(stakers/positions)** and can exceed a single tx's gas (anchor sweep,
enforced-fresh inject, pool vacate), Ouronet uses a **defun+gate** shape rather than a fixed-step `defpact`
(a `defpact` can't scale past `2×N`): a repeatable **`CC_*Chunk`** defun pages the set, with progress held as
**committed state** — either a persisted cursor (`FVT|SweepProgress`, vacate's `nns`/`unn`) or a naturally
**shrinking set** (the inject's stale scan) — and **completeness enforced** at the gate (the finalizing
chunk unfreezes / injects only when the set is exhausted). Chunk size is bounded by a **loose backstop const**
that seeds the UI's `/local` simulation (the node gas meter is the real ceiling; an oversized chunk aborts
atomically). The single-tx path + any `defpact` are kept as **comparison oracles**. Live examples: vacate-v2
drain (`Cp_BatchDrain*`), sweep (`CC_SweepBegin`/`CCp_SweepRecomputeChunk`), inject
(`CCp_InjectFixChunk`/`CC_InjectFinalize`). Design of record: `03_AQP/Audit/{SWEEP-VACATE,VACATE-V2,M3-DEB}-DESIGN.md`.

### Why Stage 1 has separate Utility modules, and why Stage 2 doesn't

- **Stage 1's Utility layer (`U|CT`, `U|G`, `U|LST`, `U|INT`, `U|SWP`, `U|BFS`, `U|DALOS`, `U|DPTF`, `U|ATS`,
  …) exists because of Kadena's ~150k gas/deploy-size cap.** Core modules couldn't hold all their own
  `UC_*` compute functions inline and stay under that limit, so compute got split out into standalone
  Utility modules deployed separately.
- **Two distinct kinds of content live there, both legitimately:**
  - **Fully generic compute**, usable by any module regardless of domain — `U|LST` (string processing),
    `U|INT` (integer/array processing), `U|G` (guard computation), `U|CT` (shared constants), `U|BFS`
    (breadth-first search).
  - **Module-family-tied compute** — not fully generic, but too much for the individual modules in one
    family to each hold their own copy, so it's centralized once per family. `U|SWP` is the example: it
    holds compute used across the whole SWP module family (`SWP`, `SWPI`, `SWPT`, `SWPL`, `SWPU`,
    `MTX-SWP`), not because the logic is domain-generic, but because splitting it further would exceed
    the deploy-size budget per module.
- **Stage 2 dropped this pattern entirely.** Stage 2 deploys on StoaChain under a **~2,000,000 gas**
  ceiling (see `MODULE_ARCHITECTURE.md` / the SWP audit's own #34 handoff docs for the real measured
  numbers), which removes the deploy-size pressure that motivated Stage 1's Utility layer. Stage 2 never
  created an equivalent module (no `U|DPDC`, no `U|AQP`, etc.) — every Stage 2 module keeps its own
  `UC_*` compute functions inline, since Stage 2 modules are smaller anyway and there's ample headroom
  under the higher cap. **Do not propose splitting Stage 2 `UC_*` functions into a new Utility module** —
  that would be reintroducing a pattern the project deliberately moved away from once the size pressure
  that justified it went away.

### DPMF historical note

- `DPMF` is the original **Meta Fungible** module kept for historical/migration context.
- Live "meta-token" behavior is represented by **OrtoFungibles** in `DPOF`.
- Naming shifted from MetaFungible to OrtoFungible to clearly separate the new path from legacy migration semantics.

## Open questions

- Whether `Z.repl` should optionally skip Kadena-only or Stoa-only stages for partial tests.
- If `pact` rejects `(namespace "")` in `init-phase-04-coin.repl`, reset to root the way your Pact version documents.

## Related paths in this repo

- `OuronetInformational/ouronet/MODULE_ARCHITECTURE.md` — module layout, prefixes (UC/UR/…/Talos), policies, C1–C4
- `OuronetInformational/ouronet/architecture/` — **full inventory**: Stage 1/2 modules, interfaces, slave, REPL harness, whitepaper roadmap
- `OuronetInformational/` — this knowledge base
- `REPL/Stage00_Sanboxes.repl` — Kadena sandbox + Stoa sandbox
- `REPL/Stage00a_StoaTests.repl` — Stoa `coin` REPL tests (Stage 00a)
- `00_KadenaSandbox/kda-env/init.repl` — Kadena environment bootstrap
- `00_StoaSandbox/stoa-env/init.repl` — Stoa phased genesis bootstrap

## What Ouronet is

Ouronet is a virtual blockchain written entirely in Pact, Kadena's smart-contract language, and
deployed on StoaChain — a Chainweb-class stack with its own native coin and namespace economy —
under the namespace `ouronet-ns`. Earlier testing lived under Kadena's `free` namespace; the whole
tree was migrated.

"Virtual blockchain" is the load-bearing phrase and it is not decoration. Ouronet is not a dapp
that holds balances in a table. It re-implements, inside Pact, the things a chain normally
provides to the contracts running on it, and then provides those things to its own contracts:

| chain concern | what StoaChain supplies | what Ouronet supplies for itself |
|---|---|---|
| accounts | `k:` principal accounts in the root `coin` module | `DALOS\|AccountTable` — an Ouronet account with a `sovereign`, a `governor` guard, a `smart-contract` flag and payability rules |
| native balance | `coin` | `DALOS\|StoaLedger`, the per-account mirror of native STOA |
| gas | real gas, metered by the node, paid in native coin | **IGNIS**, a virtual gas unit pegged at 1 IGNIS = 1 US/EUR cent |
| where gas is held | the payer's coin account | the `ignis` field **on the Ouronet account row itself** — IGNIS is not a separate fungible |
| who pays real gas | whoever signs | the Ouronet gas station: `DALOS`'s `GAS_PAYER` capability, allowance const `DALOS\|GAS-BUDGET` = 2,000,000 gas |
| token standards | `fungible-v2` | `DPTF`, `DPOF`, `DPDC` (see next section) |
| transaction entry | any module a signer names | **Talos only** (see *The layer cake*) |

Read the last two rows together and the shape of the system falls out. A transaction that takes a
Talos path and is accepted by the gas station has its **real** gas paid by Ouronet, and in exchange
Ouronet charges its own **virtual** gas, IGNIS, at rates it sets itself. Real gas and virtual gas
are two separate meters running at once, and essentially all of the economics — and most of the
audit surface — live on the second one.

Two precisions, because this is the kind of summary that invites overstatement. First, "the user
spends no StoaChain gas" holds only for sponsored paths: the gas station pays **only** for paths
defined in Talos, and its `GAS_PAYER` capability is a whitelist over the transaction's top-level
forms, not a blanket subsidy. A transaction it does not match is paid for by whoever signed it.
Second, `DALOS|GAS-BUDGET` is a **per-transaction allowance**, not a pot that drains: the gate is
`gas-price × gas-limit ≤ GAS-BUDGET × ceiling`, enforced against the protocol minimum read live from
`coin` on every call, so the allowance does not decay as the network's minimum price rises.

That allowance is 2,000,000 gas, which is also StoaChain's **block** gas limit — so a sponsored
transaction may in principle consume a whole block. The two numbers are stated separately here
because no source states that they were set equal deliberately, and treating a coincidence as a
design intent is how a reader ends up reasoning from a rule that does not exist.

The system deploys in stages, because it has to (see *Interfaces and the cascade rule*):

- **Stage 1** — identity and gas (`DALOS`, `IGNIS`), fungibles (`DPTF`, `DPOF`, `TFT`), autostake
  (`ATS`, `ATSU`), the swapper family (`SWP`, `SWPI`, `SWPL`, `SWPLC`, `SWPU`, `SWPT`, `MTX-SWP`),
  `VST`, `ELITE`, `BRD`, `CODEX`, `PYTHIA`, `OUROBOROS`, `LIQUID`.
- **Stage 2** — collectables (the `DPDC` family), the `DEMIPAD` launchpad core, and acquisition
  pools (`AQP-POOL`, `AQP-ANK`, `AQP-SCORE`, `RPS`, `AQP-FVT`, `AQP-VCT`, `MTX-AQP`, `AQP-DSA`).
- **Stage Z** — read-only and deployer modules (`DPL-UR`, `EXPLORER`, `DSP`), last, as they read
  everything.

Development is REPL-first: nothing is deployed to prove it works, it is loaded into staged `.repl`
harnesses first, and those harnesses are the largest single artefact in the repository. Two version
records exist and deliberately disagree — `LIVE-INTERFACE-VERSIONS.md` records what is **deployed
on chain**, the tree records what is **developed**, and the first is never refreshed from the second
because being the thing the second is compared against is its whole purpose.

## The asset taxonomy

Ouronet defines four asset families plus one legacy one. The distinctions are not marketing
categories: each family is a different set of tables with a different row key, and the row key tells
you what "one unit" of the thing is.

| family | module(s) | the table that defines a unit | row key | one unit is |
|---|---|---|---|---|
| **true fungible** (DPTF) | `DPTF` | `DPTF\|BalanceTable` | `<id>` + `<account>` | a decimal balance |
| **ortofungible** (DPOF) | `DPOF` | `DPOF\|T\|Nonces` | `<id>` + `<nonce>` | a nonce: one holder, a supply, an immutable metadata chain |
| **semi-fungible** (DPSF) | `DPDC` family | `DPSF\|T\|Nonces` + `DPSF\|T\|AccountSupplies` | `<id>`+`<nonce>`, and `<account>`+`<id>`+`<nonce>` | an edition, held by many accounts in parts |
| **non-fungible** (DPNF) | `DPDC` family | `DPNF\|T\|Nonces` + `DPNF\|T\|AccountSupplies` | same shape | a unique item |
| **meta-fungible** (DPMF) | `DPMF` | — | — | legacy; deployed for provenance, never called |

**Collectables** is the umbrella term for semi- plus non-fungible, and `DPDC` is where they live —
one module owning both the DPSF and DPNF table sets, with the rest of the family (`DPDC-C`,
`DPDC-I`, `DPDC-R`, `DPDC-MNG`, `DPDC-T`, `DPDC-S`, `DPDC-F`, `DPDC-N`, `DPDC-UDC`, `EQUITY`)
routing every write through it.

**Ortofungible** is the term a new reader will not recognise, and it is worth being exact. It is a
fungible token whose supply is partitioned into *nonces* — numbered batches — each carrying its own
metadata. The schema says it plainly:

```pact
(defschema DPOF|NonceElement
    holder:string                       ;;Stores the <OuronetAccount> holding the nonce - mutable
    id:string                           ;;ID of the Ortofungible - immutable.
    value:integer                       ;;Stores the Nonce value itself - immutable.
    supply:decimal                      ;;Nonce Supply - mutable
    meta-data-chain:[object]            ;;Stores Nonce Metadata - immutable
)
```

A nonce has exactly one `holder` and a divisible `supply`, so an ortofungible sits between the two
familiar extremes: unlike a true fungible, units in different nonces are not interchangeable,
because the nonces carry different metadata; unlike an NFT, a nonce is not one indivisible item, it
has an amount. The name changed from "MetaFungible" to keep the live path (`DPOF`) distinct from
the legacy migration semantics (`DPMF`).

The difference between `DPOF` and `DPDC` is visible in the table above: `DPOF` has no
`AccountSupplies` table, because a nonce is **single-held**; `DPDC` has one, keyed by account
*and* nonce, because an edition is held in parts by many accounts. That one table is the whole
ortofungible/collectable distinction in structural form.

On top of the assets sit the DeFi primitives, built out of these families rather than beside them:
**ATS** autostake pairs and **SWP** liquidity pools (both from true fungibles, with ortofungibles
able to interact with SWP), **AQP** acquisition pools (earning pools with anchors, scores and
reward-per-share accounting), **VST** vesting, and **DEMIPAD**, the launchpad whose per-asset sales
were deliberately pushed out into citizen modules.

## Sovereign and citizen

Every module in the tree is one of two classes, and the tree says which by path. **Sovereign**
(`1_SOVEREIGN/`) modules are the canonical Ouronet architecture, maintained by the project. They
hold the business logic, own the tables, and define the capability gates. Talos — the orchestration
and gas boundary — is sovereign.

**Citizen** (`2_CITIZEN/`) modules are extensions that anyone may write. They call into sovereign
public APIs and nothing else. They do not add capabilities to the core surface, and their client
functions carry no `UEV_IMC` — the sovereign inter-module gate, which belongs to Talos and core
paths. The citizen modules in the tree (`AOZ`, the Bloodshed/Nosferatu/Bunnies/Vaults minters, the
`CADUCEUS` bridge, the five launchpad sales, `DPL-UR`, `EXPLORER`, `DSP+`) are Admin-authored but
structurally citizen — the standing proof that the boundary is usable from outside.

What the boundary buys an auditor is a decidable question. "Can this module write to that table?"
has a mechanical answer: only through a sovereign entrypoint, and only if that entrypoint's gate
lets it. That gate is the policy layer — every module opens with two policy tables, `P|T` and
`P|MT`, before any business logic, holding the guards through which modules authorise each other.
The inter-module check is `P|UEV_IMC`, which enforces that any guard returned by `P|UR_IMP` is
satisfied; `P|UR_IMP` defaults to the module's own `SECURE` capability guard when nothing has been
registered, so an unregistered policy list is satisfiable only from inside the module and the gate
answers identically before and after first registration. That default was added in September 2026,
after the bare `read` was found to raise a raw table error rather than refuse cleanly.

Two documented places bend the sovereign/citizen line, and both matter later in this book.
**There is a citizen Talos**: `2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact` carries the per-sale user
wrappers for the five launchpad sales and is the sole gas-funded path for them, while its sovereign
counterpart `1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact` carries the `DEMIPAD|*` ops — one
letter apart, and the project's own documentation had the roles swapped until 2026-09-17. And **the
citizen minters invert the client direction**; see the end of the next section.

## The layer cake

Sovereign code is three layers: **Utilities → Core → Talos**.

**Utilities** exist only in Stage 1 — thirteen modules (`U|CT`, `U|G`, `U|ST`, `U|RS`, `U|LST`,
`U|INT`, `U|DEC`, `U|DALOS`, `U|ATS`, `U|DPTF`, `U|VST`, `U|SWP`, `U|BFS`) of small pure helpers.
They exist because of Kadena's roughly 150k deploy-size cap: core modules could not hold their own
`UC_*` compute inline and stay under it. Two kinds live there — genuinely generic compute (`U|LST`
strings, `U|INT` integers, `U|G` guards, `U|BFS` search) and module-family-tied compute centralised
once per family because splitting it further would blow the budget (`U|SWP`, shared across the six
SWP modules). **Stage 2 dropped the pattern entirely**: it deploys under roughly a 2,000,000 gas
ceiling, so every Stage 2 module keeps its `UC_*` inline. There is no `U|DPDC` and no `U|AQP`, and
proposing one would reintroduce a pattern the project deliberately left behind.

**Core** is the business logic — `DALOS`, `IGNIS`, `DPTF`, `DPOF`, `ATS`, `VST`, the SWP family,
`DPDC`, `DEMIPAD`, the AQP family. Each starts with its policy tables, then schemas, tables and
constants, then capabilities, then functions.

**Talos** is orchestration, and it is the part an auditor should internalise first. Talos modules
sequence `A_` and `C_` calls across core modules into curated flows. Three consequences follow, and
they are the reason Talos is a choke point rather than a convenience layer:

- **Talos is the only supported client path.** A core `C_` is blocked from being invoked inside its
  own module by design; clients reach it through Talos.
- **The gas station pays execution only for paths defined in Talos.** Ad-hoc `A_` calls straight
  into a core module remain possible for maintenance, but they fall outside the gas-station
  envelope.
- **Talos is the only place that collects IGNIS after a `C_`.** Because the core cannot call its own
  `C_`, a Talos sequence can force "execute `C_`, then collect" and a client cannot skip paying
  while still using the blessed path.

The operative rule for anyone adding code: a new `A_`, `C_` or protected `X*` on a core module is
not finished until it is wired into the appropriate Talos module. Until then it has no client
semantics and no gas semantics.

For an auditor this inverts the usual problem. The client-reachable attack surface is not "every
public function in 88 modules" — it is the Talos entrypoint list, which is enumerable. Eleven files
carry it (six Stage 1 sovereign, four Stage 2 sovereign, one citizen) and define **413** client and
**73** admin entrypoints between them. Conversely, a surface not in Talos is not reachable by a
client, and a finding about such a surface needs to say how a client would get to it.

Every Talos client op passes the same door first: the `P|TS` capability, which reads
`DALOS::UR_GAP` and refuses while the global administrative pause is online — *"While Global
Administrative Pause is online, no client Functions can be executed"* — and then composes
`P|TALOS-SUMMONER`.

**The documented exception.** In the citizen minters `NOSFERATU` and `KBunnies` the direction is
inverted: their `C_Spawn` / `C_Fix` call *into* Talos and return the wrapper's string, after Talos
has already collected. So `A_Step01 → C_Spawn` is a citizen module calling its own `C_`, which the
sovereign rule forbids — and it is sound here precisely because there is no cumulator at that level
to mishandle. The conformance tooling splits these out as `self-C-call-citizen` observations bounded
to those two files. The bound is the point: a citizen `C_` that *does* return an `OutputCumulator`
is an ordinary billing shape A and the rule applies to it normally.

## IGNIS: virtual gas on top of real gas

`IGNIS` is the virtual-chain gas collector, its unit pegged hard at **1 IGNIS = 1 US/EUR cent**, so
a 5000 deterrence is $50. Balances are not a fungible — they are the `ignis` field on the `DALOS`
account row, so charging gas is an account-table update.

### The OutputCumulator

The object that carries a charge through an operation is the `OutputCumulator`, defined in
`IGNIS`:

```pact
(defschema OutputCumulator
    cumulator-chain:[object{ModularCumulator}]
    output:list
)
(defschema ModularCumulator
    ignis:decimal
    interactor:string
)
```

It is a **list of legs**, each naming an amount and the interactor it is attributable to. A core
`C_` builds one as it works, concatenating the legs its `XI_`/`XE_`/`XB_` writers produce, and
returns it. Talos hands the finished object to the collector with the transaction's `patron`:

```pact
(ref-IGNIS::C_Collect patron
    (ref-TFT::C_Transfer id sender receiver transfer-amount method)
)
```

`C_Collect` compresses the chain per interactor, primes it against the patron, and debits. The
`patron` is the account that pays; a smart account may not be one, with a single hard-coded
exception for the admin gasless path (the Ouroboros daily minter) — a restriction that was only a
caller-side convention until a red-team finding in September 2026 made it an enforcement.

**This is what the "`C_` must not be invoked inside its own module" rule protects.** A sovereign
`C_` builds a cumulator that only Talos may collect. A self-call can drop it or double it. For
sovereign modules the count of such calls must stay at zero.

### The cost model

```
IGNIS charged = deter (IG|DETER) + the op's own compute (IG|COMPONENTS)    ;; UC_IgnisPrice
STOA  charged = dollars(deter) / stoa_price          — ISSUE ops only      ;; UC_StoaPrice
```

Four constant maps in `1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact` hold every price: `IG|DETER` (54
per-op deterrence keys — the business decision), `IG|COMPONENTS` (~394 generated per-op compute
costs, calibrated against measured gas), `IG|WEIGHTS` (14 primitives the components are computed
from), `IG|LEGS` (22 per-write and per-item unit costs charged inside the writers).

Four properties of that model are easy to get wrong and are worth stating flatly:

- **Deterrence is additive, not the total.** "A $50 function" means its deterrence is 5000; it still
  pays its ordinary compute on top. `usage` = 1 is the neutral element — an op with no deterrence
  still pays its full computation.
- **Every price is denominated in dollars** and converted to STOA at the oracle price. No STOA
  quantity is hard-coded. The one deliberate exception is `CODEX::UC_StoicTagStoaFee` — 1 STOA per
  glyph, fixed in STOA units, non-discountable, by owner ruling.
- **A tier value that is multiplied by a count is a unit, not a price.** Migrating such a site to
  `deter + components` replaces a unit with a whole-op price and then multiplies it by the item
  count — a compounding error far worse than the flat tier it replaced.
- **Quoted prices are full prices.** Discounts apply on top (IGNIS up to 49% via Elite tiers, STOA
  up to 24.5%); PYTHIA tolls, StoicTag registration and some asymmetric-liquidity legs are flagged
  non-discountable in code.

Every cost-emitting op has a `URCi_*` reader: pure, read-only, no `enforce`, returning the cost
cumulator. It is called **inside the execution path for billing and served to the UI for
preview**, so the two cannot drift. A *leaf* `URCi` prices one writer; a *composer* `URCi`
concatenates leaves into the op's total, and the `INFO_` preview calls the composer. A `URCi`
lives in the same module as the function it prices — if a module gets too big the module is split,
not its cost functions. The tree holds **595** `URCi_` and **623** `INFO_` definitions.

### The six billing shapes

The description above — core `C_` returns the cumulator, Talos collects — is the common case but not
the only correct one. A full trace of all 38 non-cumulator `C_`s on 2026-09-13 found six legitimate
shapes:

| shape | where the billing happens | example |
|---|---|---|
| **A** | core `C_` returns the cumulator; Talos passes it to `IGNIS::C_Collect` | most ops |
| **B** | Talos wrapper builds the cumulator from a `URCi_*` and collects | `DALOS::C_RotateGuard` → `TS01-C1` |
| **C** | STOA-priced — wrapper calls `STOA\|C_Collect*`, no IGNIS at all | `DALOS::C_DeploySmartAccount` |
| **D** | billed **in the core** — the `C_` itself ends on `STOA\|C_CollectWT` | `SWPLC::C_UpgradeBrandingLPs` |
| **E** | **defpact step** — the `C_` is only a starter; a later step bills | the 8 `MTX-SWP` pool/liquidity ops |
| **F** | **nested Talos** — the core calls another Talos client that collects | `DEMIPAD::C_Transmit*` → `DPTF\|C_Transfer` |

Plus the **primitives** — `IGNIS::C_TransferDalosFuel` and the `STOA|C_Collect*` family — which
*are* the collectors and cannot collect from themselves. The practical rule that falls out, and
which cost two rounds of wrong conclusions before it was written down: **to decide whether an op
charges, follow the Talos wrapper's `IGNIS::C_Collect` argument, never the core `C_`'s return
type.** A core `C_` returning a `string` says nothing.

**One deliberately free op exists.** `TS01-C4::PYTHIA|C_Link` takes no `patron` and collects
nothing while its three siblings all charge. It is safe because it is bounded, not because it is
cheap: linking requires two deployed Apollo halves at 500 native STOA each, and counterparts are
never cleared (revoke only deactivates), so it is one-shot per pair, forever. If counterparts ever
become clearable, the op stops being safe.

## The function prefix system

Every function name in sovereign Pact begins with a prefix that is a contract about what the
function may do. The prefixes are the vocabulary the rest of this book uses. They split into
**unprotected** (callable without capabilities — safe by construction) and **protected** (locked
inside their module; not the public integrator surface).

Unprotected:

| Prefix | Meaning |
|--------|---------|
| `UC_*` | Pure compute on arguments only — **no table reads, no `enforce`**. First under FUNCTIONS. |
| `UCv_*` | `UC_` whose `enforce` is **intrinsic to its own computation** (a shape/domain guard on the computation itself), not business validation. |
| `UR_*` | Table reads. **No raw `read` on domain tables outside `UR_*`.** Per-field `UR_*` take table keys, not row objects. |
| `URC_*` | Read + derive. **No `enforce`** (validation lives in `UEV_*` / defcap). May call `UR` / `UC` / other `URC`. |
| `URCv_*` | `URC_` whose `enforce` is **intrinsic to its own computation** — same `v` role as `UCv_`. Use it when the guard is unavoidable in the derivation itself and relocating it would duplicate the identical check at every real call site; use a `UEV_*` / defcap when the check is a business rule. |
| `UEV_*` | Read + `enforce`. Failure aborts the tx. Unprotected. |
| `UDC_*` | Data construction — named constructors for objects; prefer over ad-hoc `object{}` literals. |
| `CAP_*` | Ouronet account-ownership enforcement (UEV-like but specifically tied to account ownership). |

Protected:

| Prefix | Meaning |
|--------|---------|
| `A_*` / `AA_*` | Admin-key mutations. Doubled `AA_` = **heavy**: a heavy scan (`URH_*`/`URHC_*`/`URD_*`) is reached **somewhere in the whole execution tree, at any depth** (transitive). |
| `C_*` / `CC_*` | Client entry for citizen modules. Builds IGNIS cumulators and returns `OutputCumulator`. **Cannot be invoked from its own module** — clients reach it via Talos. Doubled `CC_` = **heavy** (a `URH_*`/`URHC_*`/`URD_*` scan is reached anywhere in its execution tree, at any depth). |
| `Cp_*` / `CCp_*` / `Ap_*` / `AAp_*` | **Hydra** multi-transaction recipes (contrast `defpact` = one ordered continuation). `Cp_`/`Ap_` carry NO heavy read; `CCp_`/`AAp_` still do. Anatomy: `URH_*` preflight → slices/pages → optional `C_`/`CC_` begin/finalize. |
| `XI_*` | Internal-only protected (this module). |
| `XE_*` | For external modules only (forward-module entrypoints). |
| `XB_*` | Both internal and external. |

The letters compose rather than enumerate: a **doubled** initial letter means heavy (a table scan
reached transitively), a trailing **`v`** that the function's own `enforce` is intrinsic to its
computation, an **`i`** (as in `URCi_`) that it returns a cost cumulator, a **`p`** a Hydra recipe.
The AQP modules additionally use `W_` write helpers (`WI_` insert, `WU_` update, `WW_` upsert) and
`UCk_` key constructors, a rollout scoped to `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/`.

**Two shapes wear the `p`, and only one is parallel.** A *fed-slice* takes an explicit slice object
and is order-independent and parallel-safe (`Cp_WipeSlice`, in `DPOF` and `DPDC-MNG`). A *cursor
pager* takes a size, computes its own window from stored progress, and is strictly sequential
(`CCp_SweepRecomputeChunk`, in `FVT`). Check which one you have before firing N at once.

The intended decomposition of a client operation, which later chapters assume: the **client
`defcap`** holds **all** authorisation and validation (`CAP_EnforceAccountOwnership`, `UEV_*`,
`UEV_Fee`, table reads); **`XI_*` / `XB_*`** do persisted writes under `require-capability` on a
`SECURE`-composing cap, must **not** `enforce` or call `UEV_*`, and end on the
`insert`/`update`/`write` with no trailing `true` and no cumulator return; **`XE_*`** starts with
`UEV_IMC`, then `with-capability`, then writes only; and **`C_*`** is wiring and billing —
`UEV_IMC`, `with-capability`, the `X*` calls, optional STOA collection, then the cumulator.

Counted with `grep -rhoP '^\s*\(defun\s+\Q<prefix>\E'` across `1_SOVEREIGN/` and `2_CITIZEN/`
(declarations and implementations together): `UR_` 1,405 · `URC_` 655 · `C_` 640 · `INFO_` 623 ·
`URCi_` 595 · `UEV_` 528 · `XI_` 412 · `UC_` 405 · `XE_` 334 · `UDC_` 304 · `A_` 188 · `URH_` 118 ·
`XB_` 62 · `WU_` 62 · `CAP_` 35 · `UCv_` 34 · `CC_` 32 · `URCv_` 28 · `WW_` 28 · `URHC_` 20 ·
`WI_` 20 · `CCp_` 18 · `Cp_` 4 · `AA_` 3 · `Ap_` 1.

## Capability bands C1–C4

Capabilities in every module are grouped into four bands, in this order: **C1** — trivial, "always
`true`"-style capability roots; **C2** — simple capabilities that do **not** compose other
capabilities; **C3** — ownership-related patterns; **C4** — composite capabilities
(`compose-capability`).

That ordering sits inside the canonical module section order — **(1)** schemas, tables and
constants (labelled `{1}`, `{2}`, `{3}` in sources), **(2)** capabilities by band, **(3)** functions
with true `UC_*` compute helpers first; reference layout `0_Sample/C0s__01_01_ModuleSample.pact`.
Within FUNCTIONS the order runs `UC_` → `UCK_` → `UR_` → `UDC_` → `W_` → `URD_` → `URC_` → `URDC_`
→ `UEV_` → `C_` → `A_` → `X*`; `UR_` blocks follow the order the schemas are declared in, and
within a block mirror the field order of the `defschema`.

Two conventions inside a `defcap` produce most of the findings in Part III. **Boolean checks are
combined by count**: one condition is a plain `enforce`; two use
`(enforce (and p q) "msg")`; three or more use `(enforce (fold (and) true [p q r ...]) "msg")`.
`CAP_*`, `UEV_*` and `UEV_Fee` stay as separate calls *before* the combined boolean `enforce`,
because they are not plain booleans. The `fold` form is not stylistic: `(and a b c d)` raises
*"Attempted to apply a closure to too many arguments"*.

**Authorisation precedes validation** — an owner ruling of 2026-09-14. When a `defcap` both
authorises (composes a `GOV|*_ADMIN` capability or equivalent) and validates (business `enforce`s),
the authorisation goes first: before any business rule, and before the `let` that derives the data
those rules read. The reason is testability, and it is the origin of a term this book uses often.

A **shadowed gate** is an authorisation check that never runs, because an earlier check refuses
first in every reachable state. `GOV|WIPE_ALL-TREASURY-DEBT` had the order reversed:

```pact
(enforce (< treasury-supply 0.0) "Cannot Wipe Positive Treasury Balance")   ;; business
(compose-capability (GOV|DPTF_ADMIN))                                       ;; authorisation
```

A solvent treasury is the normal state, so every attempt — admin or stranger — was turned away by
the business rule and the admin gate was never reached. A red-team test could report "a non-admin
was refused", be telling the truth, and prove nothing: **had `GOV|DPTF_ADMIN` been deleted from
that capability, the test would still have passed.** From outside, a shadowed gate is
indistinguishable from an absent one.

Two qualifications this book needs the reader to carry:

- **The 2026-09-14 sweep covered the admin band only.** It fixed 18 sites matching "a business
  `enforce` before a `compose-capability` of a `GOV|*_ADMIN`". Re-scanning all 989 `defcap`s on
  2026-09-16 found two more admin-band sites (`GOV|GAP` and `GOV|MIGRATE`, both in `DALOS` — the
  ruling's own module) and, reading "or equivalent" to include the `CAP_*` ownership gates,
  **62 sites across 23 files** the sweep's definition never covered.
- **Those 62 are not to be fixed by reordering.** Ordering is a proxy for testability and can expose
  only one of two state-dependent guards at a time — some existing tests *depend* on the current
  order to reach an argument guard without a signature. A fixture that satisfies the first guard
  exposes both, and cannot introduce an authorisation hole, which a reorder demonstrably can.
  Relatedly: an authorisation form inside an `if`/`and`/`or`/`cond` branch is *conditional* by
  design, and hoisting the bare `compose-capability` out of the branch silently changes who may
  call the function.

## Interfaces and the cascade rule

Kadena's roughly 150k deploy-size cap forces a strict deploy order: a module may only call into
modules already deployed. Everything in this section is downstream of that one constraint.

**Cross-module calls use module references and `::`,** not `module.function`:

```pact
(let ((ref-DALOS:module{OuronetDalosV2} DALOS))
     (ref-DALOS::UR_GAP))
```

The type is the *interface*, not the module, so only the used interface members are relevant to
typing and coupling. Consequently **interfaces carry nearly the whole public API** — 87 interfaces
are declared across `1_SOVEREIGN/` and `2_CITIZEN/`, containing 3,177 `defun` declarations against
5,451 implementations in module bodies. In most files the interface and the module that implements
it now live in the same `.pact` file, the interface first; the `0_Interfaces/` directories have
been reduced to short index comments.

**Interface names always end in a version suffix, and each revision advances it by exactly one.**
`SwapperIssueV2` → `SwapperIssueV3`, never `V2` → `V4`.

**The cascade rule**: when interface **B** is superseded by **B′**, every interface **A** that
*names* B in its surface is stale and must become **A′** with the new reference. "Names" covers both
`module{B}` in a type position and qualified row types such as `object{B.SomeSchema}`. Every
consumer — module, Talos client, citizen bridge, sample, REPL — updates in lockstep, and
implementing modules `implements` only the **latest** version of each family.

A worked example from the current tree: on chain `SWP` implements `SwapperV3`; in the tree it
implements `SwapperV4`. That one bump names the interface in **16 files** and **241** type
positions — the SWP family itself (`SWPI`, `SWPL`, `SWPLC`, `SWPU`, `MTX-SWP`, several also using
`object{SwapperV4.PoolTokens}` and `object{SwapperV4.FeeSplit}`), three Talos modules (`TS01-A`,
`TS01-C3`, `TS01-P`), the read layer `INFO-ONE+`, four Stage 2 AQP modules (`AQP-SCORE`,
`AQP-POOL`, `RPS`, `AQP-FVT`) that reference pools they do not own, and two citizen modules
(`DPL-UR`, `EXPLORER`). And
because those consumers are themselves interfaced, their own interfaces bumped in lockstep:
`SwapperIssueV3` → `V4`, `SwapperMtxV3` → `V4`, `SwapperUsageV2` → `V3`, `SwapperLiquidityV1` →
`V2`, `SwapTracerV1` → `V3`. A one-line change to a schema in `SwapperV3` is never a one-line
change.

Three narrower rules follow from the same mechanics:

- **Same-interface object types** are written unqualified: inside `SwapperV4`, write
  `object{PoolTokens}`, not `object{SwapperV4.PoolTokens}`. Reserve the qualified form for schemas
  owned by a *different* interface.
- **Interface object-return rule**: if a function would return `object{Schema}` where `Schema` is
  defined in the *implementing module*, remove it from the interface — the interface loads before
  the module's schemas exist. Ouronet keeps schemas in modules, so such functions stay module-only
  (this is why `AQP-ANK` and `AQP-SCORE` have module-only readers).
- **Version policy**: new work stays on `V1` until first mainnet deployment, and bumps only
  afterwards if a post-deploy adjustment forces it. Until then `V1` code is edited freely — which
  is why the tree holds one `V1`, sixty `V2`s, fourteen `V3`s, five `V4`s, four higher numbers on
  long-lived families (`DeployerReadsV13`, `TalosStageOne_ClientFourV8`,
  `DemiourgosPactMetaFungibleV7`, `PythiaV5`) and three unversioned citizen interfaces
  (`AgeOfZalmoxis`, `Bloodshed`, `Dispenser`).

## The scale of the thing

Every figure below was measured on 2026-09-18 against the working tree, each taken twice by two
different commands. Where the project's own tooling reports a different number for the same
quantity, both are given with the reason.

**Pact source** (`1_SOVEREIGN/` and `2_CITIZEN/` only — the Stoa/Kadena sandboxes and `0_Sample/`
are excluded):

| | count | how |
|---|---:|---|
| `.pact` files | **93** | `find 1_SOVEREIGN 2_CITIZEN -name '*.pact' \| wc -l` (74 sovereign, 19 citizen) |
| lines of Pact | **116,040** | `find … -exec cat {} + \| wc -l`, cross-checked with `xargs wc -l` |
| `(module …)` declarations | **89** | `grep -rhoP '^\s*\(module\s+\S+'`; **88 distinct names** — `CADUCEUS`, a bridge scaffold, declares two draft module blocks in one file |
| `(interface …)` declarations | **87** | `grep -rhoP '^\s*\(interface\s+\S+'`; all 87 names distinct, spread over 77 files |
| `defun` | **8,628** | of which **5,451** are implementations inside module bodies and **3,177** are interface declarations |
| `defcap` | **989** | 988 in module bodies, 1 in an interface — matches the 989 figure the project's own capability sweep used |
| `defschema` | **217** | `grep -rhoP '^\s*\(defschema\s+\S+'` |
| `deftable` | **231** | `grep -rhoP '^\s*\(deftable\s+\S+'` |
| `defconst` | **903** | `grep -rhcP '^\s*\(defconst\s'` summed |
| `defpact` | **6** | the multi-step continuations, as distinct from the Hydra `p` recipes |

The anchored regex (`^\s*\(defun`) and an unanchored one differ by exactly one for `defun` and one
for `defcap` — two definitions not starting their line; the anchored figures are used above. The
largest modules are `AQP/04_RPS.pact` (5,621 lines), `AQP/02_SCORE.pact` (4,283),
`Z_Reads/02_INFO-ONE+.pact` (4,199), `AQP/05_FVT.pact` (3,977) and `AQP/06_VCT.pact` (3,508): the
acquisition-pool family dominates, which is why it gets its own chapter.

**The Talos surface**, counted inside module bodies only, is client/admin `TS01-A` 0/31, `TS01-C1`
62/3, `TS01-C2` 77/3, `TS01-C3` 34/3, `TS01-P` 8/3, `TS01-C4` 8/9, `TS02-C1` 66/3, `TS02-C2` 60/3,
`TS02-C3` 81/5, `TS02-DPAD` 10/7 and the citizen `TS02-CPAD` 7/3 — **413 client and 73 admin across
12,611 lines**. `TS01-A` is the admin Talos and carries no client op at all. The pricing
documentation counts **452** Talos client entrypoints by its own census, **442** of them carrying a
price row and 5 not (3 admin ops free by rule, 2 billing-shape-B wrappers); the difference from 413
is a counting definition, not a discrepancy — that census resolves Talos→Talos delegation and
includes entrypoints this chapter's prefix-anchored count does not.

**The test harness** (`REPL/`, excluding `REPL/archive/`, as the project's own scale tool does):

| | count | how |
|---|---:|---|
| `.repl` files | **207** | `find REPL -name '*.repl' -not -path '*/archive/*' \| wc -l` (275 including the 68 archived) |
| lines | **137,733** | the project's `_scale_report.py`. A raw `cat \| wc -l` gives 137,712; the 21-line gap is **21 files with no trailing newline**, counted directly, which `wc -l` does not count |
| distinct assertions written | **5,873** | project tool, counted from source |
| assertions executed per full gate run | **25,035** | project tool, from gate output — 20,042 `expect` and 4,993 `expect-failure` |

The last two rows differ by about 4× because shared files run once per entrypoint that loads them.
**Quote the distinct figure for "how many tests exist"; the executed figure answers "how much ran".**
A raw source count of `(expect`/`(expect-failure` forms returns 5,529, lower than 5,873 because the
project's counter also resolves assertions generated inside `map`/`fold` constructs.

The gate that has to be green is `python3 REPL/tools/_gate.py`. The fast path, `REPL/Z.repl`, is
deliberately not the gate: it skips `Stage_01/[6.1]_Cumulator.repl` and its 75 leg-level pricing
assertions, runs issuance-only DPTF and SWP variants, and drops the Stage-1 scenario tail, though it
still runs 106 pricing assertions of its own. Any change to pricing, STOA collection or IGNIS
billing is verified with the gate, not with `Z.repl`.

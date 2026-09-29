# Interfaces and versioning

Every Ouronet interface name ends in a version — `OuronetPolicyV2`, `AutostakeV3`,
`DemiourgosPactMetaFungibleV8`. That suffix is not decoration. It exists because of one hard fact
about Pact:

> **A deployed interface can never be changed.** Not edited, not upgraded, not replaced in place.
> A module can be redeployed over itself freely; an interface cannot.

Everything in this chapter follows from that sentence.

---

## 1. What an interface is for here

A Pact module declares which interfaces it implements, and cross-module calls go through
**module references** rather than direct names:

```pact
(ref-U|CT::CT_NS_USE)        ;; a modref call — couples to one interface member
```

The distinction matters at this scale. `.` couples a module to the *whole* of another module;
`::` couples it to the single interface member it uses. The owner's reasoning:

> "using it with dot instead of double dot, I learned would load the whole module … That's the
> reason I use `::` to call functions from different modules."

So interfaces are the coupling surface. They carry nearly the full public API of each module, which
is what makes the deploy graph tractable — and what makes their immutability expensive.

## 2. The cascade rule

Because an interface cannot be edited, a change means a **new interface**, one version higher. And
because interfaces reference each other, that bump propagates:

> When interface **B** becomes **B′**, every interface **A** that names B — via `module{B}` or
> `object{B.Schema}` — must also bump to **A′** with the new reference, and every implementing
> module updates in lockstep.

Version suffixes advance by **exactly one**. The distribution in the tree today shows the history:

| suffix | count | |
|---|---:|---|
| `V1` | 20 | never revised after first deployment |
| `V2` | 60 | the common case — one revision |
| `V3` | 8 | |
| `V4` | 5 | |
| `V5` | 1 | |
| `V8` | 2 | `DemiourgosPactMetaFungible`, seven revisions deep |

**`OuronetPolicyV2` is implemented by 58 modules.** That single number is the cascade rule's cost:
a change to the policy interface is a 58-module redeploy. It is also why the rule is worth
obeying rather than working around — the alternative is 58 modules disagreeing about what a policy
is.

**Policy for active work:** stay on `V1` until first mainnet deployment, editing freely. Bump only
after a live deploy forces a versioned move. Implementing modules `implements` only the latest
version.

## 3. Interfaces moved into the files that implement them

`1_SOVEREIGN/STAGE_01/0_Interfaces/` and its Stage-2 sibling still exist and contain **60 lines of
comments between them**. Nothing deploys from there.

Interfaces are now declared in the same `.pact` file as the module implementing them, and each
deploy file ships `interface → module → its own create-table` calls in sequence. The reason is
practical: a batch then emits *A-complete, then B-complete* rather than "module A, module B, then
the tables of both", which is the shape you would paste by hand and the shape that fails
comprehensibly when it fails.

The empty directories are recorded as a deliberate exclusion in `Deploy/MANIFEST.md`, not left to
be rediscovered.

### Two rules that follow from the file layout

**Same-interface object types.** Inside an interface, write `object{PoolTokens}` unqualified for
schemas defined in that same interface. Use `object{OtherInterface.Schema}` only for row shapes
owned by a different interface.

**The interface object-return rule.** If a function would return `object{Schema}` where `Schema` is
defined in the *implementing module* rather than the interface, **remove it from the interface**.
An interface loads before module schemas exist, so the reference cannot resolve. Ouronet keeps
schemas in modules by convention, so such functions stay module-only — applied for `AQP-ANK` and
`AQP-SCORE`.

## 4. What is actually implemented, measured from the chain

| | |
|---|---|
| interfaces declared in the tree | **98** |
| distinct interfaces implemented by a deployed module | **93** |
| declared but implemented by nothing deployed | **6** |
| implemented on chain but not declared here | **1** |

The six unimplemented ones are each explicable, and listing them is the point — an interface
nobody implements is either a plan or a leftover, and the two look identical from a count:

- `OuronetIdsV1` — the entity-id registry, deliberately held back from the round
- `DemiourgosPactMetaFungibleV8` — DPMF's archive-mode bump; DPMF is not redeployed
- `AcquisitionSchemasV1` — shared row shapes for the AQP family, implemented by nothing by design
- `Bloodshed`, `DpofUdcV2`, `InfoTwoV2`

And the one on chain that this tree does not declare is **`gas-payer-v1`** — StoaChain's own
standard, implemented by the gas station. It is the only interface Ouronet implements without
defining, which is a neat marker of where the system ends and the host begins.

## 5. Why an archived module bumps its interface instead of editing it

`DPMF` went into archive mode in 2026-09-21: every function that *changes* something was removed —
108 definitions and all three `implements` clauses — while every reader was kept, so the history in
its tables stays readable. 2,416 lines became 902.

Its interface could not simply be trimmed to match, because a deployed interface cannot change. So
`DemiourgosPactMetaFungibleV7` (95 functions) was superseded by **`V8`** (2 schemas, 53 functions).
The old one still exists on chain, because it must.

Two consequences worth knowing:

- **Dropping `implements` removes a module from every future cascade.** DPMF implemented
  `BrandingUsagePrimaryV2` alongside four other modules, so every branding signature change had to
  be carried into a module nobody calls. That cascade is now four modules, not five.
- **The tree's dead modref calls went from 13 to 0**, because all thirteen lived inside DPMF's
  removed write functions.

---

## Where to go next

- `04-deploy-order.md` — the other thing that forces deployment order
- `03-the-module-map.md` — which modules implement what
- `../30-modules/` — per-module pages, each stating the interfaces it implements on chain

## Sources

- Immutability, the cascade rule and the object-return rule: `CLAUDE.md`, *"Deployment order and
  interface versioning"*; `OuronetInformational/ARCHITECTURE/INTERFACE_VERSIONING.md`.
- Version distribution: `grep -rhoE '^\(interface [^ )]+' --include=*.pact 1_SOVEREIGN 2_CITIZEN`,
  suffixes counted, 2026-09-29.
- Implemented-on-chain figures: `Deploy/LIVE-MODULES.json`, probed from mainnet 2026-09-29 —
  each module's `interfaces` field is what `describe-module` returned.
- Archive mode: `OuronetInformational/StoicSyntax-Prefixes.md` §7.21; `CLAUDE.md`, *"Historical
  note: DPMF → DPOF"*.
- The `::` versus `.` reasoning: owner, 2026-08-28, session transcripts.

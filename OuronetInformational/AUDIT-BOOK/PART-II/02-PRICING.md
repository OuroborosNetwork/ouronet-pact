# Part II · Chapter 2 — The re-pricing

> Source of record: `OuronetInformational/IGNIS-PRICING/IGNIS-PRICING.md` — the project's own
> single authoritative reference, which folded in and deleted five earlier pricing documents.
> `IGNIS-PRICE-SHEET.md` and `IGNIS-DETER-WORKSHEET.md` in the same folder are **generated** and
> **gate-enforced**; §5 of this chapter explains that mechanism, which is one of the stronger
> controls in the project.

{{ch:previews}} built one cost reader per operation. This chapter is about what those readers were made to
return.

---

## 1. The model

```
IGNIS charged = deter(op) + components(op)          ;; UC_IgnisPrice
STOA  charged = dollars(deter(op)) / stoa_price     ;; UC_StoaPrice — issuance ops only
```

Four rules make it legible, and each is an owner ruling with a date:

- **1 IGNIS = 1 US cent.** A deterrence of 5000 is $50.
- **Deterrence is a multiplier and it is ADDITIVE, not the total.** An operation with "no
  deterrence" still pays its full computation; `usage = 1` is the neutral element.
- **Every price is denominated in dollars** and converted at the oracle. When a real oracle replaces
  the $0.10 peg, the STOA *amount* moves and the *value* the user pays does not.
- **All published prices are full prices.** Elite discounts apply on top — up to 49% on IGNIS, up to
  24.5% on STOA, *exactly half*. Three things are explicitly non-discountable: PYTHIA tolls, StoicTag
  registration, and some legs of the asymmetric-liquidity path.

The deliberate exception, recorded in the function's own `@doc` so nobody "corrects" it:
`CODEX::UC_StoicTagStoaFee` is **1 STOA per glyph**, fixed in STOA units. A glyph costs one STOA
whatever the oracle says.

## 2. Where a price lives

Four constant maps, all in `1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact`. **[VERIFIED by command]** —
key counts parsed from the `defconst` bodies today:

| map | holds | keys |
|---|---|---:|
| `IG\|DETER` | the per-op deterrence — the business decision | **54** |
| `IG\|COMPONENTS` | per-op computed work cost, keyed `ENTITY\|FN`, calibrated to measured gas | **396** |
| `IG\|WEIGHTS` | the primitives components are computed from | **14** |
| `IG\|LEGS` | per-write and per-item unit costs charged inside `XI_`/`XB_` writers | **22** |

`IGNIS-PRICING.md` §2 says `IG|COMPONENTS` holds *"~394"* and §8 says 396; `DEFECT-LEDGER.md` §5
item 16 already flagged that one document carries three different counts. The tree says **396**.

### The calibration, and what it overturned

`IG|WEIGHTS` was not modelled and left alone — it was measured against real gas in the rehaul's
sixth substage, and **three of its four parameters were wrong**:

| parameter | modelled | measured |
|---|---|---|
| read multipliers (s/m/l/xl) | 1 / 1 / 2 / 3 | **1 / 2 / 5 / 9** |
| update cost | `ceil(fields ÷ 2)` | **`ceil(fields ÷ 4)`** |
| hydra wipe ceiling | 120 nonces | **1000 (DPOF) / 500 (DPDC)** |
| write multipliers | 1 / 2 / 3 / 5 | unchanged |

The wipe ceiling is the one with a user-visible consequence. Measured through the real `Cp_WipeSlice`
path, a DPOF nonce costs **405.6 gas** and a collectable nonce **952.4** — 2.3× heavier — which puts
roughly 4,900 and 2,100 nonces in a 2M-gas transaction against a configured ceiling of 120.
*A ceiling set 40× too low charges users for transactions they did not need.* Both were raised to
about a quarter of the measured ceiling, which is a deliberate margin rather than an estimate.

### The distinction that prevented a compounding error

> **A legacy tier read that is MULTIPLIED BY A COUNT is a *unit*, not a price.**

Migrating such a site from a flat tier to `deter + components` replaces a per-item unit with a
whole-operation price and then multiplies it by the item count. **Four readers were caught at the
edge of exactly that** — `DPOF::URCi_MoveCumulator`, both `Repurpose` families, and
`DPDC-N::URCi_UpdateNonces` (`DEFECT-LEDGER.md` B-13). They were lifted into `IG|LEGS` at parity
instead, and no price moved. The ledger calls it *"the canonical structurally-wrong price shape in
this corpus"*, and the check is one sentence long: **before migrating any tier read, check whether it
is multiplied.**

---

## 3. What the round actually changed

The decision log in `IGNIS-PRICING.md` §9 is the authority. The entries worth reading as an auditor
are the ones where a live price was wrong by an order of magnitude or more:

| site | before | after | why it was wrong |
|---|---|---|---|
| fee-unlock ladder (`U_DEC::UC_UnlockPrice`) | `base × (unlocks+1)`, **unbounded** | flat **$50 IGNIS + $50 STOA** | no ceiling existed; DPTF's *first* unlock already cost $100 and each subsequent one grew without bound. Its STOA leg was computed as `ignis/100` — dollars-at-$1, **10× short** of the peg |
| AQP pool / FVT / score issuance | **0.02 STOA** | 100 STOA | issuance had borrowed the account-creation price keys "as a convenient small number" — a **5000× gap** that also bypassed the account-creation STOA switch |
| blue-flag branding | **0.025 STOA/month** | 250 STOA/month ($25) | |
| `ATSU::C_ColdRecovery` / `C_Cull` / `C_HotRecovery` | 10 / 10 / 15 IGNIS | 130 / 132 / 117 | a flat placeholder ~13× below the measured computation |
| `DPTF::C_Burn` / `C_Mint` | 2 / 7 IGNIS | 72 / 87 | approved only after confirming `C_Burn`'s 71 components are **11 cross-module calls plus 7 reads**, not a modelling artefact |
| seven `AQP-DSA` client ops | **free** | priced | they wore an `A_` prefix while gating on `CAP_EnforceAccountOwnership` — owner-gated, therefore client ops — and a Talos wrapper prefixed `A_` is classified admin and exempt. All seven renamed `A_`→`C_` |

That last row is the one to keep. **A naming convention was load-bearing on money**: seven live
client operations collected nothing because their prefix told the biller they were administrative.

### The constants-only conversion, and how parity was proven

Owner, 2026-09-07: *"we run no more table values, but constants for determining prices now."* All
**65** live `UR_UsagePrice "ignis|*"` reads became `UC_IgnisLeg "tier-*"` against six new `IG|LEGS`
constants lifted verbatim from the old table values.

The proof of no-change is the part worth copying: **the regenerated price sheet was byte-identical
to the pre-conversion one.** Not "the suite stayed green" — byte-identical output from an independent
generator. No price moved; only where the number lives changed.

**And the first attempt at that edit destroyed the source.** From commit `981c708`:

> *"the first attempt used a paren-depth scanner for defun boundaries, overran on a body it
> mis-counted, and duplicated content exponentially — **1.78M insertions across 19 files**."*

Recovered by `git checkout` of `1_SOVEREIGN` only, preserving in-flight sandbox work. The rewrite
used **line-based boundaries plus an assertion that the line count cannot change**, which for an
in-line substitution is exactly true and turns a silent catastrophe into a clean abort. The same
class of failure had already destroyed source once before in this project, deleting 624 lines across
four utility files. `IGNIS-PRICING.md` §8 now carries the rule in imperative form: **never use
paren-depth scanning to define an edit region in Pact.**

### One claim in the authoritative document that the tree does not support

**[VERIFIED by command]** — `grep -rn 'UR_UsagePrice' --include=*.pact 1_SOVEREIGN 2_CITIZEN`.

`IGNIS-PRICING.md` §2 states: *"As of 2026-09-07 **no live pricing path reads a database table**."*
The narrow version of that claim is true — the only surviving `ignis|*` **tier** reads are in the
dead `00_DPMF` module. The sentence as written is not. Seven live reads of the DALOS usage-price
table remain on pricing paths outside DPMF:

| site | key | what it prices |
|---|---|---|
| `04_BRD.pact:408` (`URCi_UpgradeBranding`) | `"blue"` | blue-flag branding, per month |
| `11_VST.pact:922, 1589` | `"dptf"` | the STOA leg of the frozen / reservation links |
| `11_VST.pact:934, 1662` | `"dpmf"` | the STOA leg of the vesting / sleeping / hibernating links |
| `20_MTX-SWP.pact:1048–1049` | `"dptf"` + `"swp"` | the defpact pool-issuance STOA leg |

plus their `INFO-ONE+` preview twins, and the oracle read inside `UC_StoaPrice` itself — which is by
design, since the whole dollar rule is *"divide by the oracle price"*, and the oracle lives in a
table.

**[VERIFIED by reading]** `REPL/Stage_01/[4.0]_Sovereign-Executor.repl` explains how the two
statements were reconciled in practice. The executor seeds those keys twice: first with legacy
literals (line 236: `DALOS|A_UpdateUsagePrice "blue" 0.025`), then **overwrites them from the
constants** (line 272: `DALOS|A_UpdateUsagePrice "blue" (UC_StoaPrice "branding-blue")`). So
`IG|DETER` really is the source of truth — *through a deploy-time seeding step, not through the read
path.*

**[INFERRED]** — the operational consequence, which the document does not state. §2's rule is
*"a price is retuned there and nowhere else."* For these four keys it is not: retuning
`IG|DETER "branding-blue"` changes nothing on a deployed chain until an administrator re-runs
`DALOS|A_UpdateUsagePrice "blue"`. That is a two-step retune wearing the description of a one-step
one, and the second step is an admin entrypoint that the test ledger records as invoked 32 times with
**zero adversarial assertions**.

---

## 4. The generated price sheet

`IGNIS-PRICE-SHEET.md` is the per-function price list and the declared input to the Chapter-2 user
documentation. It is produced by `REPL/tools/_ignis_price_sheet.py`, which walks the Talos client
surface and extracts each operation's real cumulator legs.

### The generator's own defect history is the most useful part of it

Every defect found in it *made the published sheet disagree with a chain that was already correct* —
so when a price looks wrong, the sheet is the first suspect, not the contract. The full-coverage pass
of 2026-09-09 took it from 82 unresolved rows to **0**, resolving 80 and repricing 14, with **zero
rows demoted**. Each fix was a distinct blind spot:

| blind spot | what it hid |
|---|---|
| `@doc` prose not stripped (`\\.` cannot cross a newline, so no doc string ever closed — and the unmatched quote then stripped **real code**) | doc-mentioned functions charged to the wrong operation |
| a module alias read as a module name (`ref-B\|DPOF` is module `DPOF`) | every branding operation |
| same-module delegation not followed | thin alias operations |
| `defpact` bodies invisible (`defun_body` matched only `(defun`) | all 5 SWP liquidity adds + 3 pool issuances |
| cumulator constructors not followed cross-module | the 100-IGNIS branding charge, and the **flat $50 fee-unlock, which published as 2 IGNIS** |
| price helpers not followed (`UC_DeployPrice → UR_Config → UC_StoaPrice`) | the PYTHIA tolls |
| a literal `0.0` cumulator counted as a price | **every SWP swap published as FREE** |
| no notion of a STOA-only or free-by-design operation | 58 rows reading `?` where the honest answer was "charges nothing" |

**Two rules the walk must keep**, both of which were violated during the round, caught by an
invariant, and reverted:

1. **Depth stays 3**, escalating to 5 then 7 *only for a row that resolved to nothing*. Raising it
   globally crosses into **sibling** operations — `AQP-FVT|CC_Collect` absorbed a neighbour's 500
   deterrence and `DPTF|C_Mint`, moving its floor from 557 to 1150.
2. **Same-module `C_*` is followed for ONE hop.** Transitively it reaches neighbouring client
   operations — `DPDC-F|C_MergeFragments` absorbed `C_MakeFragments`, floor 18 → 152, though its code
   calls only `C_Transfer`. *One hop captures a delegation alias; more hops capture the
   neighbourhood.*

The invariant that caught both is worth stating on its own: **for a re-pricing refactor, an
already-priced row must not change value** — so diffing the regenerated sheet at every step is what
rejected two generator "fixes" before they shipped.

### The one that is worst to get wrong

`SWP|C_Firestarter` is the **bootstrap** operation for a brand-new account, and it is *gated on the
caller holding under 100 IGNIS*. The sheet published it at **≥ 93 IGNIS**. The wrapper builds three
cumulators, reads one value out of one of them, collects none of them, and its own success message
says *"with no IGNIS Costs!"*.

> The sheet told someone whose defining characteristic is having no IGNIS that they needed 93 of it
> first.

The fix is narrow on purpose. The obvious rule — *"no `C_Collect` in the wrapper means free"* — was
tried and is **wrong**: billing shapes D, E and F bill in the core, in a defpact step, or in a nested
Talos wrapper, and the loose rule flipped 14 rows to free including `C_AddStandardLiquidity`, whose
entire point is a 1000-IGNIS churn deterrent. The correct rule requires a **bound-and-unused**
cumulator.

---

## 5. The gate mechanism — how the artefacts stay true

This is the control a reader should understand, because it is stronger than what most projects have
and because its boundary is exactly where this chapter's finding sits.

`REPL/tools/_pricesync.py --check` is **fatal inside `REPL/tools/_gate.py`**. It does three distinct
things, and the third is the unusual one:

**(a) Artefact equals generator.** It re-runs both generators *in memory*, from the repository root,
and diffs the output against the committed files. Not a timestamp check, not a hash recorded at
generation time — a live regeneration compared byte-for-byte. A contract edit that changes a price
and is not accompanied by a regenerated sheet fails the gate.

**(b) The document must not contradict itself.** `legend_vs_table()` extracts the sheet's own
**EXEMPT legend paragraph** — the prose that says which operations are deliberately free — and
checks that every operation it names is published as `0` in the sheet's own table, 500 lines further
down. This exists because the legend named `Firestarter` as free while the table published it at
`≥ 93`, *and nothing compared the two halves of one document*. It is derived from the legend text
rather than a retyped list, so a newly-exempt operation is covered the day it is added.

**(c) The narrative must quote the artefact.** `narrative_tally()` parses the generated sheet's
footer tally and requires `IGNIS-PRICING.md` to contain that exact line, and the exact total, as
literal text. This is the rule the project states elsewhere and enforces here:

> *A generated artefact guarded by the gate, quoted by a narrative nobody checks, just moves the
> stale number one file along.*

The reason it exists is specific: on 2026-09-15 the prose document still read *"Nothing on pricing.
Every one of the 420 Talos client functions now carries a price"* — figures no longer produced by
anything, because **both generators had been dead since the tools directory moved** and nothing had
re-derived them. They died at *import*, on hard-coded sibling paths, so no output existed to diff.
Meanwhile the artefacts had been **hand-edited**: their `Regenerate:` provenance lines were updated
to name the new path, i.e. *the provenance line of a document that could not be regenerated was
corrected to name a command that crashed.*

`_figuresync.py` is the sibling control for `ARCHITECTURE/*.md`, and `_toolpaths.py --check` is what
makes a repeat of the dead-generator incident visible — it statically resolves every hard-coded path
literal in every tool. Both are also fatal in the gate.

---

## 6. The finding: a gate-enforced headline that is eleven operations short

**[VERIFIED by command]**, counting the price sheet's own row markers:

```
admin/exempt ........................ 41
core op returns an empty cumulator ... 5
builds cumulators and collects none .. 1
collects no IGNIS and no STOA ........ 3     → 50 exempt
| STOA only | ....................... 11
| COMPLEX | ........................ 199
| $n.nn |  ......................... 182
                                    ----
                            total    442 priced rows
```

442 rows, plus a further **5** listed in the sheet's own `UNPRICED` section. **[VERIFIED by
reading]** — the physical row count reconciles: 437 rows begin with a backticked name, and 5 more
(the three `HOT-RBT|` rows and the two `MTX-AQP|2|` rows) carry an escaped pipe instead.

The sheet's footer reads:

```
182 simple (exact price) · 199 complex (floor price) · 11 STOA-only · 50 exempt
  · 0 unresolved · 5 unpriced · 431 Talos client functions
```

**[VERIFIED by reading]** `_ignis_price_sheet.py:730` computes that last figure as:

```python
f" · {nsimple+ncomplex+nexempt} Talos client functions"
```

`nstoaonly` is omitted. So **every operation priced in STOA and not in IGNIS is counted in its own
column and then dropped from the headline** — the branding upgrades, the PYTHIA deploy and rename
tolls, and the CODEX StoicTag family. `182 + 199 + 50 = 431`; the sheet holds 442.

`IGNIS-PRICING.md` §6 repeats it twice — *"431 Talos client functions priced, 0 unresolved"* and
*"**431** Talos client functions carry a price"*.

Three things make this worth a section rather than a footnote:

**It is a known defect that was recorded and not fixed.** `DEFECT-LEDGER.md` §5 item 14, dated
2026-09-15, states it precisely and names the line: *"the footer computes the total as
`nsimple+ncomplex+nexempt` and omits `nstoaonly`. So the sentence 'every one of the 420 … carries a
price' silently excludes 10 ops that do."* At that date the figures were 420 and 430. Today they are
**431 and 442**, and the excluded set has grown from 10 to 11.

**The control added the same week now enforces it.** `narrative_tally()` requires `IGNIS-PRICING.md`
to contain the literal string `**431**`. Correcting the prose document by hand — writing the true
total — would **fail the gate**. The undercount is no longer merely published; it is *mandatory*
until the generator is fixed.

**It is the book's third rule, from the inside.** *A count is reported with its exclusions, or not at
all.* The sheet does report its exclusions — the 11 are in the breakdown, one field to the left of
the total that drops them. A reader who adds the columns finds it in ten seconds. A reader who quotes
the headline, as the authoritative document does twice, does not.

> The fix is one identifier. The instructive part is that a genuinely good control — regenerate,
> diff, and force the prose to quote the artefact — **propagates a wrong number as faithfully as a
> right one.** Consistency is not correctness, and a gate that enforces the first can make the second
> harder to reach.

---

## 7. What the pricing is actually tested by

**[VERIFIED by command]**, counting `(expect …)` forms in the three dedicated suites:

| suite | assertions | what it pins |
|---|---:|---|
| `REPL/Stage_01/[6.1]_Cumulator.repl` | **75** | the **leg-level** assertions |
| `REPL/Stage_02/[6.1.9]_PRICE-SWEEP.repl` | **64** | every `son`-taking reader, twice, once per fungibility side |
| `REPL/Stage_02/[6.2.16]_AQP-PRICE-SWEEP.repl` | **42** | the AQP family |
| | **181** | |

Plus the measured preview-versus-charge proofs described in {{ch:previews}}, which are balance deltas
rather than table comparisons.

### Which of them run where, stated exactly

`CLAUDE.md` warns that the fast-path runner skips pricing suites, and that warning has itself been
corrected once for overstating the case. The precise position today — **[VERIFIED by command]**:

- `Stage01_Tester.repl:32` carries `;(load "Stage_01/[6.1]_Cumulator.repl")` — **commented out**.
  So `Z.repl`, the fast path, runs **106** pricing assertions (64 + 42) and skips **75**.
- **The gate runs all 181.** `[6.1]_Cumulator.repl` is loaded by `ZALL.repl:27` **and** by
  `REPL/modules/CUMULATOR.repl:6`, and both are gate entrypoints.

The 75 matter more than their share suggests, and the reason is on the record: on 2026-09-14
`[6.1]`'s `<<TX-IGC-008>>` was **the only assertion in the entire suite** to catch a VST preview
leg-split, because the total was unchanged and every total-level assertion agreed. *A cost split
across a different number of legs prices differently, because the cumulator discounts per leg.*

So the honest formulation, which this book adopts: **a quarter of the pricing assertions, including
every leg-level one, are outside the fast path — and none of them are outside the gate.**

---

## 8. What this chapter does not establish

- **`components` is a model, not a measurement, per operation.** The sheet says so in its own
  caveat: it counts the core operation's own module-internal work, and *"cross-module callee
  internals are not re-summed, so delegating ops read a little low."* The `IG|WEIGHTS` primitives
  were calibrated against measured gas; the per-operation totals built from them were not
  individually measured against a live charge. The preview-versus-charge work in {{ch:previews}} is what
  measures live charges, and it measures **previews**, which is the same arithmetic but not the same
  claim.
- **199 of 442 rows are floors, not prices.** A `COMPLEX` row publishes *"costs at least N"*, because
  the composition varies with a list length or a scan. That is honest, and it means the sheet cannot
  answer "what will this cost me" for 45% of the surface.
- **Two pricing judgement calls remain open** and are recorded as such in §6 of the reference:
  `MTX-SWP::C_AddSleepingLiquidity` still carries `tier-token-issue` 500, the last legacy number
  under a new name, inside a defpact that already carries a 5000 deterrence; and the double-piped
  `MTX-AQP|2|C_*` Talos names are either a deliberate defpact step marker or a naming slip, and
  nobody has said which.
- **Five entrypoints carry no row.** Three are admin operations that are free by rule; two
  (`DALOS|C_UpdateEliteAccount` and its `Squared` twin) are billing shape B — the Talos wrapper
  builds the cumulator and collects it itself, so there is no core operation for the sheet's row
  model to key on. The sheet names the authoritative reader for each rather than inventing a
  component cost, and **before 2026-09-15 it dropped them silently while the footer reported
  `0 unresolved`.**

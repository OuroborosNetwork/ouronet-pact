# IGNIS + STOA pricing — the authoritative reference

**This is the single source of truth for how Ouronet charges.** It replaces the README, the SPEC,
the PLAN, the URCi architecture note, the Hydra design note and the pre-rehaul archive, all of
which were folded in here and deleted (git history keeps them).

There are only **three** files in this folder, and only one of them is written by hand:

| file | what it is |
|---|---|
| **`IGNIS-PRICING.md`** (this file) | the rules, every price decision, the architecture, status, and the decision log |
| `IGNIS-PRICE-SHEET.md` | **GENERATED** — the per-function price list. This is the input to the Chapter-2 documentation |
| `IGNIS-DETER-WORKSHEET.md` | **GENERATED** — the per-op compute estimate the component costs are derived from (supporting working) |

Regenerate both after any price change:

```bash
python3 REPL/_ignis_price_sheet.py     > OuronetInformational/IGNIS-PRICING/IGNIS-PRICE-SHEET.md
python3 REPL/_ignis_deter_worksheet.py > OuronetInformational/IGNIS-PRICING/IGNIS-DETER-WORKSHEET.md
```

---

# 1. The cost model

```
IGNIS charged = deter (IG|DETER)  +  the op's own compute (IG|COMPONENTS)     ;; UC_IgnisPrice
STOA  charged = dollars(deter) / stoa_price       — ISSUE ops only            ;; UC_StoaPrice
```

* **1 IGNIS = 1 US/EUR cent.** Hard peg. A 5000 deterrence is $50.
* **Deterrence is a MULTIPLIER, and it is ADDITIVE — not the total.** "A $50 function" means its
  deterrence is 5000; the op still pays its ordinary compute on top. **`usage` = 1 is the neutral
  element**: an op with "no deterrence" still pays its full computation, it just carries no premium.
* **Every price is denominated in DOLLARS** and converted to STOA at the oracle price. When a real
  oracle replaces the $0.10 peg the STOA *amount* moves but the *value* the user pays does not.
  Never hard-code a STOA quantity.
* **All prices in this document are FULL prices.** Discounts apply on top: **IGNIS up to 49%**
  (Elite tiers), **STOA up to 24.5%** (exactly half the IGNIS discount).
* **Non-discountable exceptions**, taxed in full and flagged explicitly in code: **PYTHIA** tolls,
  **StoicTag** registration, and some legs of the asymmetric-liquidity-addition path.

## The one deliberate exception to the dollar rule

`CODEX::UC_StoicTagStoaFee` = **1 STOA per glyph**, fixed in STOA units, non-discountable
(owner, 2026-09-07). A glyph costs one STOA whatever the oracle says. This is intentional —
do not "correct" it to derive from IG\|DETER.

---

# 2. Where a price lives

Four constant maps, all in `1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact`.
**A price is retuned there and nowhere else.** As of 2026-09-07 **no live pricing path reads a
database table** — the DALOS usage-price tiers are gone from every client path (owner: "we run no
more table values, but constants for determining prices now").

| map | holds | keys |
|---|---|---:|
| IG\|DETER | per-op deterrence — the business decision | 54 |
| IG\|COMPONENTS | per-op computed work cost, keyed `ENTITY\|FN` — GENERATED, calibrated to measured gas | ~394 |
| IG\|WEIGHTS | the primitives components are computed from | 14 |
| IG\|LEGS | per-write and per-item unit costs charged inside `XI_`/`XB_` writers | 22 |

**IG\|WEIGHTS** (the cost model's primitives, calibrated against measured gas in substage 6):

```
tx 1 · ins 3 · upd-per-4f 1 · xcall 2
writes   w-s 1 · w-m 2 · w-l 3 · w-xl 5
reads    r-s 1 · r-m 2 · r-l 5 · r-xl 9
wipe-nonce 5 · frag-nonce 100
```

Calibration overturned three of four modelled parameters: reads became 1/2/5/9 (from 1/1/2/3),
updates `ceil(÷4)` (from `ceil(÷2)`), and the wipe ceiling 1000 for DPOF / 500 for DPDC (from 120).
Only the write multipliers survived unchanged. Collectible wipes measured 2.3x heavier than
ortofungible (952.4 vs 405.6 gas/nonce).

**IG\|LEGS** — named internal write legs plus the generic per-item unit tiers:

```
tracker-write-tf/of/collectable 3 · tracker-zero-tf 3 · ben-total-tf 5
ben-nonce-total-sf/nf 3 · ank-sync-count-tf 5 · ank-sync-count-collectable 5
stake-anchor-refresh 3 · special-tf-link 5 · special-of-link 5
vst-link-role-toggle-tf 4 · vst-link-role-toggle-of 5 · lp-mint 2
UNIT TIERS: tier-smallest 1 · tier-small 2 · tier-medium 3 · tier-big 4
            tier-biggest 5 · tier-branding 100 · tier-token-issue 500
```

The unit tiers are the pre-rehaul DALOS table values lifted verbatim, so the move changed no
price. They are the per-ITEM unit fed to scaling formulas (per nonce, per amount, per fragment,
per transfer-size band) — **not** per-op prices.

> **The distinction that matters most.** A legacy tier read that is MULTIPLIED BY A COUNT is a
> **unit**, not a price. Migrating such a site to `deter + components` replaces a unit with a
> whole-op price and then multiplies it by the item count — a compounding error far worse than the
> flat tier. Four ops were caught at the edge of exactly this mistake (DPOF move, both Repurpose
> families, UpdateNonces). **Before migrating any tier read, check whether it is multiplied.**

---

# 3. Deterrence — the full table

`IG|DETER`, 54 keys. Dollar value = ignis ÷ 100.

### Generic tiers

| key | ignis | $ | meaning |
|---|---:|---:|---|
| usage | 1 | $0.01 | ordinary operation — the neutral element, no premium |
| setup | 5 | $0.05 | config / property change |
| auth | 10 | $0.10 | authority change (ownership, guard rotation) |
| fee | 25 | $0.25 | fee-parameter change |
| small | 50 | $0.50 | small deterrent |
| token-account | 50 | $0.50 | token-account creation |

### Asset issuance (these also carry a STOA leg — see §4)

| key | ignis | $ | applies to |
|---|---:|---:|---|
| issue-tf | 1000 | $10 | DPTF true fungible |
| issue-of | 1000 | $10 | DPOF ortofungible |
| issue-sft | 2000 | $20 | DPSF collection |
| issue-nft | 2500 | $25 | DPNF collection |
| issue-ats-pair | 4000 | $40 | ATS autostake pair |
| issue-swp-pair | 5000 | $50 | SWP liquidity pool |
| issue-shareholder | 10000 | $100 | DPSF equity / company |
| issue-dsa-vault | 5000 | $50 | DSA delegation vault |
| issue-dsa-agency | 2000 | $20 | DSA agency |

### AQP / scoring

| key | ignis | $ | | key | ignis | $ |
|---|---:|---:|---|---|---:|---:|
| issue-pool | 1000 | $10 | | add-score | 200 | $2 |
| issue-fvt | 1000 | $10 | | revoke-score | 250 | $2.50 |
| issue-score | 1000 | $10 | | add-score-entity | 500 | $5 |
| issue-triplet | 500 | $5 | | add-reward-link | 500 | $5 |
| issue-score-model | 500 | $5 | | aqp-inject | 500 | $5 |
| issue-multiplet | 500 | $5 | | aqp-collect | 500 | $5 |
| combine-triplet | 100 | $1 | | unstale | 100 | $1 |
| anchor | 500 | $5 | | sync-anchors | 50 | $0.50 |
| revoke-anchor | 100 | $1 | | pool-stake-toggle | 50 | $0.50 |
| revoke-boost | 500 | $5 | | fvt-split-setup | 100 | $1 |
| recompute-capture | 300 | $3 | | fvt-link-toggle | 50 | $0.50 |

### Everything else

| key | ignis | $ | note |
|---|---:|---:|---|
| fee-unlock | 5000 | $50 | flat per unlock — replaced the escalating ladder; also $50 STOA |
| pythia-deploy | 5000 | $50 | STOA only — PYTHIA carries NO ignis cost. Non-discountable |
| pythia-rename | 1000 | $10 | STOA only, non-discountable |
| branding-blue | 2500 | $25 | STOA only, **per month** |
| acct-smart | 1000 | $10 | STOA only, behind the account-creation switch |
| acct-standard | 500 | $5 | STOA only, behind the account-creation switch |
| define-set | 500 | $5 | defining a collectable Set — NOT an issuance, no STOA leg |
| vst-link | 250 | $2.50 | VST link creation — the DPTF/DPOF it triggers is taxed on its own |
| ats-secondary | 250 | $2.50 | add/remove an ATS secondary — a link, not an issuance |
| lp-churn | 1000 | $10 | liquidity churn |
| fee-withdraw | 100 | $1 | **deter-only — the one op that charges NO component cost** |
| frag-enable | 100 | $1 | nonce-fragmentation gate |
| royalty-fuel | 500 | $5 | |
| royalty-dispose | 400 | $4 | |
| set-oracle-auth | 300 | $3 | |
| set-agency-fee | 300 | $3 | |
| oracle-write | 200 | $2 | |

---

# 4. The STOA rule — issuance only

```
STOA = dollars(deter) / stoa_price      ;; UC_StoaPrice — at the $0.10 peg, deter / 10
```

| op | deter | $ | STOA @ $0.10 |
|---|---:|---:|---:|
| DPTF C_Issue · DPOF C_Issue | 1000 | $10 | 100 |
| DPSF C_Issue | 2000 | $20 | 200 |
| DPNF C_Issue | 2500 | $25 | 250 |
| ATS C_Issue | 4000 | $40 | 400 |
| SWP C_IssueStable / Standard / Weighted (+ the 3 defpact pool variants) | 5000 | $50 | 500 |
| DPSF C_IssueCompany | 10000 + 2000 | $120 | 1200 |
| AQP pool / FVT / score issue | 1000 | $10 | 100 |
| AQP anchor issue (x2 when acnoi) | 500 | $5 | 50 |
| Account deploy — standard / smart | 500 / 1000 | $5 / $10 | 50 / 100 |
| Branding blue flag, **per month** | 2500 | $25 | 250 |
| Fee unlock (DPTF / ATS / SWP) | 5000 | $50 | 500 |
| PYTHIA deploy / rename (non-discountable) | 5000 / 1000 | $50 / $10 | 500 / 100 |

Everything derives from `IG|DETER` through `UC_StoaPrice`. **No STOA price is a hardcoded amount**
— retune the dollar value in IG\|DETER and every consumer follows.

**Account-creation STOA sits behind its own switch** (`DALOS::UR_AccountCreationStoa`, admin
`A_ToggleAccountCreationStoa` + Talos wrapper), independent of the global STOA switch, so the
global can be on while onboarding stays free. **Default OFF.**

Modules that charge **nothing**: BRD (beyond branding), CODEX (beyond StoicTag), DEMIPAD, DPDC.

---

# 5. Architecture

## `URCi_` — one cost definition, two callers

Every cost-emitting op has a `URCi_*` reader: pure, read-only, **no `enforce`**, returns the cost
cumulator. It is called **inside the execution path for billing AND served to the UI for preview**,
so the two cannot drift. This is the Option-A decision of 2026-08-27 that introduced the prefix.

* **Leaf `URCi`** — one per cost-emitting `XE_`/`XI_`; the writer returns it after its write.
* **Composer `URCi`** — one per `C_`/`CC_`/`A_`; concatenates leaf `URCi`s into the op's total.
  This is what the INFO function calls.

**Placement rule:** a `URCi` lives in the **same module as the function it prices**, never in a
shared cost module. An atomic leaf cost must not cross a module boundary. If a module gets too
big, split the module — do not exile its cost functions.

**INFO layer:** 345 of 365 INFO implementations are thin wrappers over a `URCi_` reader; 14
declare their op free (gas-station-subsidised hydra slices, ORBR, DSA oracle toggles), 4 are data
views. 395 of 401 Talos client ops have an INFO preview.

> **To decide whether an op charges, follow the Talos wrapper's `IGNIS::C_Collect` argument —
> never the core `C_`'s return type.** A core `C_` returning a `string` says nothing; the cumulator
> comes from its `URCi_` at the Talos hop. Reading it wrong produced a false "CODEX is gasless"
> report that survived two rounds.

## Hydra — parallel wipe

`URH_*` dirty-read preflight → `Cp_`/`CCp_` order-independent retryable slices fired in parallel →
optional `C_`/`CC_` finalize. Contrast `defpact`, which is sequential. Slices are disjoint by
construction, the frozen target cannot move nonces mid-campaign, and a replayed slice reverts (a
wiped nonce is decommissioned to supply -1.0, failing debit validation) — no job state, the live
table is the completion ledger.

---

# 6. Status — 2026-09-07

| phase | state |
|---|---|
| **P1** foundation (the four constant maps + helpers) | **done** |
| **P2** account-creation STOA switch | **done** |
| **P3** issue functions, IGNIS + dollar-pegged STOA | **done** |
| **P4** fee-unlock flat $50 + $50 | **done** |
| **P5** migrate ~200 `URCi_` readers off legacy tiers | **done** — zero deterrence-only readers, zero legacy tier calls on a client path |
| **P6** retire dead cumulator constructors | **done in practice** — the 11 surviving `UDC_<tier>Cumulator` refs are all in `00_DPMF.pact`, dead code that is out of scope |
| **P7** REPL price assertions (acceptance gate) | **done** — 73 assertions in `[6.1]_Cumulator.repl` plus 8 full-module sweeps (DPTF, ATS, DPDC, DPOF, SWP, SCORE/RPS, AQP, IG\|LEGS) |
| **P8** the documentation price list | **open — the only remaining work** |

**Beyond the original plan** (owner decisions taken after it was written): the dollar rule for all
STOA; the constants-only conversion (65 table reads lifted); the `define-set` / `ats-secondary` /
`fee-withdraw` / branding / PYTHIA / CODEX tiers; and real-cost migrations for ATSU recovery
(10 -> 130) and DPTF Mint/Burn ($0.07 -> $0.87, $0.02 -> $0.72).

## What is open

**P8: 82 of 348 rows in the price sheet have no price.**

```
170 exact  ·  138 floor  ·  40 exempt  ·  82 unresolved
```

The chain charges correctly for all 82 — this is the sheet generator's static analysis failing to
reach the cost reader, not a missing price. The known blocker is documented in §7.

Smaller open items:
* `MTX-SWP::C_AddSleepingLiquidity` carries `tier-token-issue` 500 — the last legacy number under
  a new name. It is a leg inside a defpact that already carries `issue-swp-pair` 5000. Keep or fold?
* `MTX-AQP|2|C_Inject` / `2|C_SweepRevokeAnchor` — odd double-piped Talos names; intentional
  defpact step marker, or a naming slip?

---

# 7. The sheet generator — known limits

`REPL/_ignis_price_sheet.py` walks the Talos client surface and extracts the real cumulator legs.
**Four defects in it were found and fixed during the rehaul, and every one made the published sheet
disagree with a chain that was already correct.** When a price looks wrong, suspect the sheet first.

Fixed: the son-branch positional pick that kept one of two legs (29 rows understated); STOA legs
invisible because the readers call `UC_StoaPrice` not `UR_UsagePrice` (every issuance row showed
"—"); son-branch deter legs summed instead of selected (`C_Issue` published 4549, a price no
caller can pay); multiplied tiers ignored (`ATS|C_SetColdRecoveryFees` published 5 when it charges
100); and a literal `0.0` identity cumulator counted as a price (**every SWP swap published as
FREE**).

**The remaining blocker — the coupled-text problem.** The walk must follow same-module `C_*`
delegation to resolve ~26 rows (`DPOF::C_WipeClean` is a thin alias onto `C_WipePure`, so the walk
stops before the cumulator). But `BILL_FN` then also matches function names inside **`@doc`
prose** — `ATS::C_ToggleUpgrade`'s doc says "Gates C_Control", and C_Control's components got
charged to it, moving an exact price 24 -> 43. Stripping strings before the call scan fixes that
but breaks the extractor, because `charge()` **also harvests deter keys FROM string literals**
(`(URCi_IssueAnchor "anchor-nf" ...)`). **The walk must ignore strings while the extractor must
read them**, and they currently share one text blob. Separating the two is a real refactor and is
the highest-value next step.

**Two approaches tried and rejected — do not retry blind:**
1. Raising walk depth 3 -> 5 makes it cross into SIBLING operations: `AQP-FVT|CC_Collect` absorbed
   `deter:aqp-inject` 500 and `DPTF|C_Mint`'s components, its floor going 557 -> 1150.
2. Following same-module `C_*` without solving the coupled-text problem: resolves 26 rows but
   causes 12 new regressions and silently drops legs elsewhere.

---

# 8. Verification rules — learned the hard way

* **Gate on `ZALL.repl`, never `Z.repl`.** `Z.repl` skips `[6.1]_Cumulator.repl`, where the price
  assertions live. A green `Z.repl` on a pricing change executes none of the assertions written to
  protect it. A clean full run is **6279 lines** ending "Load successful".
* **A green pipeline is not evidence a price is right.** A half-migrated `(if son …)` branch kept
  charging the legacy NFT price through many green runs. Only an assertion catches that.
* **Never use paren-depth scanning to define an edit region in Pact.** Use line-based boundaries
  (`^    \(defun `), which are monotonic and cannot overlap. **This has destroyed source twice** —
  once deleting 624 lines across four utility files, once duplicating 1,780,444 lines across 19
  files. Both were caught only by checking `git diff --stat` after the edit.
* **Assert an invariant the edit must preserve.** For an in-line substitution, the line count
  cannot change — that single assertion turns a silent catastrophe into a clean abort. For a
  re-pricing refactor, the invariant is "an already-priced row must not change value"; diffing the
  regenerated sheet at each step is what caught both rejected generator fixes before they shipped.
* **A missing IG\|COMPONENTS key is not evidence of a missing price.** Whole families bill through
  one shared reader (all ~20 `C_UpdateNonce*` price from `DPDC-N::URCi_UpdateNonceField`), and thin
  alias ops delegate to a priced op. 222 of 396 component keys are legitimately never read directly.
* **An alias is not a module name.** `(ref-B|DPOF:module{BrandingUsagePrimaryV2} DPOF)` binds alias
  `B|DPOF` to module `DPOF`. Also ANK -> AQP-ANK, AQP -> AQP-POOL, ORBR -> OUROBOROS,
  LEDGER -> PYTHIA, and every `B|*`/`P|*` form. Resolving the alias literally returns nothing and
  silently drops the hop.
* **Pact `@doc` quoting.** Never emit a bare `"` inside a `@doc` body; put trailing text INSIDE the
  closing quote; use `\` continuations for long docs. This class of error bit three times.
* **Derived fixture values survive a re-pricing; hardcoded ones do not.** The AQP fixtures compute
  `split-smart` as `(* 2.0 (UR_UsagePrice "smart"))` and auto-scaled through a 5000x change, while
  301 hardcoded `(coin.TRANSFER … 50.0)` caps had to be raised by hand.

---

# 9. Decision log

Owner rulings, in the order they were made. Where two entries conflict, the later one wins.

**2026-08-27 — Option A.** Leaves expose `URCi_`, the executor composes as today; INFO composers
concat the same leaf readers. Option B (billing through the composer) rejected as a top-to-bottom
rehaul. `URCi_` lives in its own module, never a shared cost module.

**2026-09-05 — the pricing spec.** True fungible $10, ortofungible $10, semifungible $20,
nonfungible $25, shareholder collection $100, ATS pair $40, SWP pool $50. All `A_` admin functions
exempt; `C_TransferDalosFuel` exempt. Per-table size buckets (Option A) for component granularity.
Talos hops excluded from cost, priced at 2 ignis. **Deterrence constants centralised in the IGNIS
module as `defconst`** — one place, not scattered. DPDC-MNG wipe mirrors DPOF's 5 ignis/nonce.

**2026-09-06 — corrections.** Deterrence is ADDITIVE, not the total. "Simple" means fixed logic
(the building blocks). Group the sheet by logical Talos entity. Anchors are a flat 500 for every
type. Fee-unlock is flat $50 + $50, replacing the escalating ladder. Nonce-field updates take one
uniform price. DPMF is dead code — leave it alone.

**2026-09-07 — the dollar rule and the last tiers.**
* An issuance op's STOA fee carries the **same dollar value as its deterrence**, at the oracle price.
* **"No more table values — constants for determining prices now."** All 65 legacy table reads
  lifted into IG\|LEGS at parity.
* **"No deterrence means 1x, as 1 is the neutral element of multiplication."**
* CODEX ops pay structural ignis at deterrence 1x. StoicTag stays 1 STOA/glyph, fixed in STOA.
* PYTHIA becomes dollar-denominated at $50 / $10 — the same amounts at today's peg.
* Blue-flag branding $25/month. Standard account $5, smart account $10.
* `define-set` 500 — a Set is not an issuance, only its ignis cost. `ats-secondary` 250 — a link,
  same deal as a VST link. `fee-withdraw` 100 flat, deterrence only.
* Score definitions, SWP Enable/Toggle ops: leave as priced. ATSU recovery/cull: ordinary usage.
  Vest/unvest: normal operation, no deterrence.
* DPTF Mint $0.07 -> $0.87 and Burn $0.02 -> $0.72 — approved after confirming `C_Burn`'s 71
  components are 11 cross-module calls plus 7 reads, not a modelling artifact.

**Sandbox note.** The Stoa sandbox `coin` tracks **current chain state, not genesis** — genesis
lacks all three `coin` functions Ouronet calls (`UC_MinimumGasPriceANU`, `URC_URV|ClaimableRewards`,
`UR_URV|UserSupply`), so on genesis Ouronet would not load. Beware
`0_Stoa/coin-contract/coin-live.pact`: despite the name it is BEHIND the sandbox copy and lacks
the whole bulk-transfer surface that `Stage00b_StoaBulkTests.repl` exercises 49 times.

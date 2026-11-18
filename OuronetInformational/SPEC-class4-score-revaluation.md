<!-- F2 · opened 2026-11-08 · OPEN -->

# SPEC — class-4 (DPNF) score revaluation, and the class with no repair path

> **Companion to** [`FINDINGS-2026-11-08.md`](FINDINGS-2026-11-08.md) §F2 and to
> [`SPEC-score-definition-reissue.md`](SPEC-score-definition-reissue.md) (F1), whose §1–§2 establish
> the defect class and are **not restated here**. Read F1 first.
>
> **Why this is a separate spec and not an F1 section.** F1's remedy is a guard or a stamp inside
> `02_SCORE.pact`, on a writer the score owner controls. Class 4 has **two** vectors, and the
> harder one is **not reachable from AQP at all** — it is a DPDC write, by a different role holder,
> in a module that is deployed *before* `02_SCORE` and therefore cannot be made to consult it. That
> changes the available fixes, not just their scope.

---

## 1. Two vectors, not one

`URC_SignedBaseDeltaForDpnfStake` dispatches on the NFT score model. Both arms read a live input;
they differ in who owns it.

| | **model 1** — `URCx_DpnfModelOneScrDefinitionRawWeight` | **model 0** — `URCx_DpnfModelZeroDpdcNativeRawWeight` |
|---|---|---|
| weight source | `SCR|T|NF|TraitScore` + `SCR|T|NF|ClassScore` point reads | `DPDC-S::URC_N|Score` (the cooked canonical nonce score) |
| owning module | `02_SCORE` (AQP) | `08_DPDC-S` / `10_DPDC-N` (DPDC) |
| mutator | `SCR|C>ISSUE-NF-SCORE-DEFINITION`, `…-NF-SET-…`, `SCR|XI>X_ISSUE-NF-…` | `DPDC-N|C>SET-SCORE` → `UR_N|RawScore` |
| authority | the **score** owner (`CAP_EnforceAccountOwnership` on `owner-konto`) | the **asset's** NFT-update role (`UEV_RoleNftUpdateON`) |
| guardable in place? | **yes** — F1's remedy applies verbatim | **no** — see §2 |

Model 1 is F1 with three revision nonces instead of one. Everything in F1 §1.1 (the residue
arithmetic), §4 (the transition table), §5 (what it must account for) and §6 (the two families)
transfers unchanged. **Do not re-derive it; extend it.**

### 1.1 The one thing model 1 adds — the trait key set can change

`URC_NFTraitKeysList` is read **once per call** and the per-`(key, value)` trait defs are point-read
against it. A re-issue can therefore change the **key set** as well as the weights: a nonce's
contribution can gain or lose an entire trait term, not merely have one re-weighted.

The consequence is specific to F1's family (A): **a stamp must record the resolved total, not the
inputs.** Stamping per-trait figures and reversing them term-by-term re-reads the key list at
unstake time and silently drops the terms that no longer appear — reversing less than was awarded,
which is the exact failure the sleeping-LP ledger was built to avoid.

### 1.2 Model 0's vector, and the one DPDC already closed

Model 0's weight is `Σ amountᵢ × URC_N|Score(dpnf-id, nonceᵢ)`, clamped at 0. `URC_N|Score` cooks
three inputs:

1. **`UR_N|RawScore`** — set by `DPDC-N|C>SET-SCORE`, which validates only `(UEV_Score score)` and
   the caller's update role. **Repeatably settable. This is the live vector.**
2. **`UR_SetMultiplier`** — the Set-class multiplier. **Already immutable**: `C_UpdateSetMultiplier`
   was *removed* under DPDC Audit #15H, recorded twice in `08_DPDC-S.pact` (lines 99, 1200) as
   *"score-multiplier is now immutable after Define"*.
3. **The `-1.0` unscored sentinel and the `/1000` fragment scale** — pure functions of the nonce,
   not mutable state.

**Item 2 is the precedent that matters.** DPDC faced one of model 0's two moving inputs and closed
it by making the input **immutable after definition** — not by gating it, not by repairing
downstream. It is a third fix family, it is already in the tree, and it is the cheapest correct
answer available for a value nobody should be editing after the fact. §6.3 asks whether raw score
should follow it.

---

## 2. Why model 0 cannot be gated at the write site

The obvious fix — put `nzs-count = 0` (or any AQP-aware refusal) on `DPDC-N|C>SET-SCORE` — is
**architecturally impossible**, and it is worth writing down why so nobody spends a round
discovering it.

**Deploy order forbids the reference.** From `Deploy/MANIFEST.md`:

| step | modules |
|---|---|
| 13 | `07_DPDC-T`, **`08_DPDC-S`**, `09_DPDC-F`, **`10_DPDC-N`**, `11_EQUITY+` |
| 14 | `00_Demipad`, `00_AQP-SCHEMAS`, `01_ANK` |
| 15 | **`02_SCORE`** |
| 16 | `03_AQP` |

DPDC is deployed **two steps before** `02_SCORE`. A module may only call into modules already
deployed, so `10_DPDC-N` cannot hold a `module{…}` modref to AQP-SCORE. Measured: DPDC's only
mentions of AQP across the whole family are **four comments**; there is not one modref.

**And it should not hold one even if it could.** DPDC is the asset layer. AQP is one consumer of its
scores. Making an NFT issuer's ability to correct a nonce score contingent on whether some unrelated
third party's acquisition pool happens to have stake against a score that references it inverts the
dependency and makes the asset layer's behaviour depend on its consumers — the same objection that
keeps **EQUITY free of domain tables**: *"it's pure logic over DPDC's state. And it has to stay that
way."*

**Therefore model 0 admits only downstream remedies**: stamp at stake time (F1 family A), or detect
and re-rate (F1 family B), or make the input immutable (§6.3). There is no gate. This is the first
place in the system where the *input* is genuinely out of reach, and it is why F2 cannot simply
inherit F1's §6.3 quick win.

---

## 3. The aggravating factor — class 4 has no repair path

`URC_AQP|ScoreBackfillSupported` admits **classes 0, 1 and 3**. Class 4 is fenced out, and the fence
is deliberate and correctly reasoned:

> Everything downstream refuses rather than computes when this is false, because a delta derived from
> the wrong formula does not fail — **it writes a plausible wrong number into a maintained
> accumulator, where it is indistinguishable from a real one.**

Class 3 was admitted on 2026-11-08 (B1/PureV25) by having the target **call**
`URC_SignedBaseDeltaForDpsfStake` rather than reimplementing `Σ(amount × mx)`. Class 4 was left,
needing its own target and its own tests.

So today:

- a corrupted class-3 base **can** be repaired — `URH_AQP|ScoreTargetBaseForBeneficiarySf` +
  `URHC_AQP|ScoreBackfillOutstanding` + `CCp_BackfillScoreSlice`;
- a corrupted class-4 base **cannot be repaired by any route in the system**, and
  `URHC_AQP|ScoreBackfillOutstanding` returns `[]` for it — which, per its own `@doc`, means
  *"fully rated"*.

**That last point is the sharpest thing in this spec.** The work-list reader answers "empty" for
class 4 for two completely different reasons — *nothing is wrong* and *I am not allowed to look* —
and returns the same value for both. Its `@doc` is honest about this (*"Refusing to answer is the
only safe answer"*), but any UI or operator reading "score stale: no" gets a **false negative** for
every class-4 score. F1 §6.2's family (B) is built on exactly this reader. **Fixing F2 by family (B)
requires opening the fence first**, and opening the fence requires the class-4 target (§4).

---

## 4. The class-4 target

Admitting class 4 means supplying `URH_AQP|ScoreTargetBaseForBeneficiaryNf` and extending the
dispatcher, following the class-3 pattern exactly:

- **Call, do not reimplement.** The target must call `URC_SignedBaseDeltaForDpnfStake(… direction
  true)` over the beneficiary's live staked `(nonce, amount)` pairs. Reimplementing the model-0/1
  dispatch is how the `Σ(amount × mx)` trap gets re-entered.
- **It must dispatch on the model**, because the two arms share no arithmetic. The dispatcher
  (`URH_AQP|ScoreTargetBaseForBeneficiary`) already has the `…Sf` / `…Lp` split to copy.
- **Fence becomes `[0 1 3 4]`.** Per F1 §5.9's reasoning, confirm this cannot accidentally admit the
  EQUITY branch — EQUITY is keyed on the *asset*, not the class, and has no definition rows.
- **It is a heavy read** (`URH_`), so the entrypoint stays `CCp_` (fed-slice, parallel-safe) and the
  cost reader must be extended. `CC_`/`AA_` heavy labelling applies transitively per StoicSyntax
  §19.3.
- **Nonce pair extraction**: `UC_AQP|BackfillNoncePairsForBeneficiary` already produces
  `(nonces, amounts)` from tracker rows for class 3. Check whether class-4 tracker rows carry the
  same shape before assuming reuse; if they do, this is a dispatcher change and a target, nothing
  more.

**Opening the fence is net-positive on its own**, independent of which F1 family is chosen: it turns
`URHC_AQP|ScoreBackfillOutstanding`'s class-4 answer from a false negative into a real one. That is a
*detection* improvement with no semantic commitment, and it is the recommended first increment.

---

## 5. What it must account for

Everything in F1 §5, plus:

1. **The `-1.0` unscored sentinel clamps to 0.** An unscored nonce weighs 0 and a *scored* one does
   not, so `SET-SCORE` moving a nonce off the sentinel is a `0 → non-zero` weight change — F1 §5.2's
   "I forgot a nonce" case, with DPDC as the writer. Likeliest real-world trigger.
2. **The clamp is asymmetric and already load-bearing.** `(if (< full-unit-score 0.0) 0.0 …)` (L7
   #19) means a *negative* raw score and the sentinel both weigh 0. Two distinct DPDC states map to
   one weight, so a stamp design cannot reconstruct which one was in force. Stamp the **clamped**
   figure.
3. **Set-member nonces carry the multiplier.** It is immutable (§1.2) and therefore safe, but the
   *stamp* must capture the multiplied value — the same "resolved total, not inputs" rule as §1.1.
4. **Model is per-score, but raw score is per-asset.** One `SET-SCORE` call can revalue positions
   across *every* model-0 score in *every* pool that references that asset. The blast radius is wider
   than F1's, where a definition write is scoped to one `(score-id, asset-id)` pair.
5. **Fragment nonces divide by 1000 inside `URC_N|Score`** and model 0 does **not** apply F1's
   separate `0.001` scale — the cooking already did it. Do not double-scale; this is an easy error
   when generalising the class-3 stamp to class 4.

---

## 6. The fix

### 6.1 Increment 1 — open the fence (recommended, unconditional)

Build `URH_AQP|ScoreTargetBaseForBeneficiaryNf`, extend the dispatcher, fence `[0 1 3]` → `[0 1 3 4]`.
Class 4 gains a repair path and an honest staleness answer. **Commits to no F1 family**, fixes the
false negative in §3, and is a prerequisite for any family-(B) treatment of F2.

### 6.2 Increment 2 — model 1 inherits F1

Whichever family F1 §12.1 picks, model 1 takes it: the three NF definition writers get the
`drift-locked` guard (F1 §6.3) and, per §12.1, either the `nzs-count` gate or the stamp or the
`applied-def-revision-nonce` triple. Note **three** nonces to compare, and §1.1's resolved-total rule
for a stamp.

### 6.3 Increment 3 — model 0, and the question DPDC already answered once

Model 0 has no gate (§2). The options, in order of preference:

- **(i) Make `UR_N|RawScore` immutable after first set**, following `UR_SetMultiplier` and DPDC Audit
  #15H. Cheapest, strongest, and consistent with a decision DPDC already took about the sibling
  input. **Cost: an NFT issuer can never correct a mis-set nonce score.** That is a real product
  cost and the reason this is a question rather than a recommendation.
- **(ii) Stamp at stake time** (F1 family A). Kills it structurally with no DPDC change and no loss
  of issuer capability. Needs the §3.2 table.
- **(iii) Detect and re-rate** (F1 family B). Needs a DPDC-side revision counter on raw score — DPDC
  keeping a counter purely so AQP can notice. Weakest: it adds state to the asset layer for a
  consumer's benefit, which §2's second paragraph argues against, and it is still lazy.

**(i) and (ii) are not exclusive.** Immutability prevents new corruption; the stamp makes the path
correct regardless. If F1 picks family (A), (ii) comes for free and (i) becomes optional hardening.

---

## 7. Interfaces, cascade, prefixes

- **Increment 1**: new `URH_` + dispatcher change inside `03_AQP.pact`, plus its interface entry
  (every unprotected reader belongs in the interface — owner ruling 2026-10-12). This is an
  `AcquisitionPoolsV*` bump and its cascade. **No schema change.**
- **Increment 2**: per F1 §7 — same `AcquisitionSchemasV3 → V4` the S1 round already forces. Land it
  there.
- **Increment 3(i)**: a guard inside `10_DPDC-N.pact`. No schema change; `DpdcNftV*` bump only if the
  surface changes, which a defcap-internal `enforce` does not.
- **Increment 3(iii)**: a DPDC schema field ⇒ a DPDC schema bump and the **whole** DPDC→AQP→Talos
  cascade. This is the expensive arm and another reason to prefer (i)/(ii).

Do not build a bump map before F1 §12.1 is answered — `LIVE-INTERFACE-VERSIONS.md` is a cached
snapshot and is unlinked from the load order precisely because a wrong bump map was built from it.
Use `python3 REPL/tools/_livemodules.py --diff`, and remember it **understates** a cascade: an
interface rename changes no function shapes, so consumers read as identical and must still ship.

---

## 8. Tests

Mirror F1 §9, with class-4 fixtures. New assertions specific to F2:

- `<<TX-F2-001>>` — **model 0**: stake a DPNF nonce; `DPDC-N|C>SET-SCORE` the nonce to a new value;
  unstake fully; assert base ≠ 0 and equal to `floor(W₁·a) − floor(W₂·a)`. Must pass on today's tree.
- `<<TX-F2-002>>` — the sentinel case (§5.1): nonce at `-1.0` (weighs 0) at stake, scored at unstake.
- `<<TX-F2-003>>` — the clamp case (§5.2): negative raw score at stake, positive at unstake. Assert
  the stake leg contributed **0**, not a negative.
- `<<TX-F2-004>>` — **blast radius** (§5.4): two model-0 scores in two pools over one asset; one
  `SET-SCORE`; assert **both** bases corrupt. This is the assertion that shows F2 is not F1 rescoped.
- `<<TX-F2-005>>` — **model 1 trait-key set** (§1.1): re-issue that *removes* a trait key; assert the
  reversal under family (A) still returns the full awarded figure.
- `<<TX-F2-006>>` — the §3 false negative: `URHC_AQP|ScoreBackfillOutstanding` on a *known-corrupt*
  class-4 score returns `[]` before increment 1 and the corrupt row after. The before-half is the
  one worth keeping as a regression, because it is the assertion that would have caught this.
- `<<TX-F2-007>>` — immutability of `UR_SetMultiplier` (§1.2) as a standing regression: assert no
  route re-sets it. It is currently true by *absence* of a function, which nothing pins.

**Reference the hand-maintained suites** `[6.2.1]_AQP-ANK.repl` / `[6.2.2]_AQP-SCORE.repl` for layout,
and extend `[6.2.17]` where the class-3 re-rate assertions (`TX-RERATE-04`) already live — the
class-4 target belongs beside them, not in a new file.

---

## 9. Decisions needed from the owner

### 9.1 Does increment 1 ship on its own?

Opening the fence commits to nothing and removes a false negative. **Recommendation: yes** — it is the
only part of F2 that is correct under every answer to every other question here.

### 9.2 Should `UR_N|RawScore` become immutable after first set? (§6.3(i))

This is a **product** decision, not an engineering one: it trades an NFT issuer's ability to correct a
mis-set nonce score against the strongest available guarantee for everyone staking against it. DPDC
already made exactly this trade for the Set multiplier under Audit #15H. Worth knowing before
answering: **were a raw score ever re-set on live mainnet state?** Answerable by a read.

### 9.3 Does class 4 wait for F1's family decision?

Increments 2 and 3(ii) are F1's remedy applied one class over; they cannot be designed before
F1 §12.1. **Recommendation: yes, wait** — and ship increment 1 meanwhile, so the detection gap closes
without prejudging it.

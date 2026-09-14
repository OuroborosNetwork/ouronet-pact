# Red Team — running report

*Audit-paper source material. One section per stage, written as each stage closes.*

Everything in the constructive suite asserts that **documented behaviour holds** and that
**documented refusals fire**. This programme asks the opposite question: *what can someone do that
nobody documented?* The suite lives in `REPL/RedTeam/`, is gated like any other entrypoint, and its
method is fixed in `REPL/RedTeam/README.md`.

**The register is the honest summary.** An adversarial suite is uniquely bad at self-reporting: an
attack that was never written and an attack that was refused both show up as a green gate. So every
block carries a machine-read `FAMILY` / `STATUS` header, `REPL/_redteam.py` builds the register from
those, and the gate **fails** on a malformed header — a shrinking register looks exactly like a
clean one.

    python3 REPL/_redteam.py          # attempts by family and outcome
    python3 REPL/_redteam.py --md     # the table for this document

## Method, and why it is shaped this way

**Pin the exploit before fixing it.** Fix on discovery and you are left holding only the
"attack refused" half; a reader has to take your word it was ever exploitable. Pin first and one
block shows both states — the measured exploit in its comment, the measured refusal in its
assertions. This earned its place on the first finding: `RT-A-001`'s pre-fix measurement
(53.0 against 557.03) exists only because it was taken before the repair.

**Probe before pinning.** Run the attack as an open experiment, observe, *then* write the
assertion. Writing the assertion first biases the experiment toward the expected answer — and an
attack you expect to fail is an attack you will accidentally arrange to fail. This also earned its
place immediately: the first draft of `RT-A-001` targeted a pool id that does not exist in the
fixture. Had the assertion been written first, the attack would have "failed" for a reason with
nothing to do with the defence.

**A red-team `expect-failure` must check the message.** "The attack was refused" is worthless if
the code refused for an unrelated reason. That is the shadowed-guard trap, which accounts for 36 of
this project's recorded defects.

**Fix policy.** Findings are pinned as-observed and fixed in a pass at the end of their stage, so
the whole class is visible before a fix is chosen. The exception is anything exploitable now with
value at risk, fixed immediately — a live exploit must not sit in a backlog, and leaving it live
corrupts the state later attacks run against.

---

## Stage 0 — verify the backlog before attacking

Red-teaming over an unknown backlog produces findings nobody can act on, so the 28 entries marked
**open** in `DEFECT-LEDGER.md` were first re-verified against source as it exists today. Three
agents worked in parallel, split by class.

**Outcome: all 28 confirmed open — none had been silently fixed — plus eight factual corrections to
the ledger, one refuted escalation, and one live finding that was not in the ledger at all.**

### The refuted claim, and why it matters more than the confirmed ones

One agent escalated **P-13** to *"every `STOA|C_Collect` in the codebase is currently a no-op"*,
reasoning from the genesis seed line `native-gas-toggle: false`. The mechanism it described is
real — `STOA|C_CollectWTEx` wraps its four transfers in `(if (not trigger) …)` and `trigger` is
`(URC_IsNativeGasZero)`, so a false toggle would indeed disable all STOA collection.

Measured directly on the live fixture: **`native-toggle=true`, `IsNativeGasZero=false`.** Collection
is active, which is consistent with an independent measurement taken the same day
(`modules/VST.repl <<VST-I1>>`, 76.5 STOA observed moving). The agent read the seed and missed the
flip.

The base P-13 defect stands, and inverts the escalation: seven branding sites pass a hardcoded
`trigger=false`, so they collect **regardless** of the global toggle — an administrator disabling
native gas would find branding still charging.

This is recorded prominently because it is the second time in this project that a plausible,
mechanically-correct chain of reasoning produced a false conclusion about coverage (the first being
a "78 unreached guards" worklist that was an artefact of one tool answering a question it does not
ask). **The correction in both cases came from measuring, not from re-reading.**

### Ledger corrections

| entry | correction |
|---|---|
| M-08 | 6 message sites, not 7 — the count included the `defconst` line |
| M-11 | over-classed; a duplicate of G-33 |
| R-02 | understates `DPL-UR` (12 hardcoded ids across two deployment hashes), miscounts EXPLORER's derived ids, and attributes a header to a file that does not carry it |
| R-04 | names the wrong file (`URC_PoolValueFromGraph` is in `16_SWPI.pact`) |
| G-29 | wider than recorded — the three outer messages are mute too |
| G-30 | narrower than recorded — the annotation overstates the call sites |
| G-33 | the framing is a misread; the rule *is* enforced one line lower |
| GS-01 | **mechanism misread**, with a larger defect underneath — see below |
| P-14 | count correct; two citation errors |

### GS-01 — the misread that concealed a bigger defect

The row attributed a `$1.00` published floor for five add-liquidity ops to the known
"literal-counted-as-a-price" generator bug. It is not that: the `literal 100` is a faithful reading
of real code. The actual defect is in `_ignis_price_sheet.py:38`, where the `CLIENT` pattern is
anchored `^` with no optional `ENTITY|` prefix — so **nine real client entrypoints are silently
skipped**, including `SWP|C_AddLiquidity` and all three `ATS|HOT-RBT|*`, and never counted in the
sheet's own "420 priced, 0 unresolved" claim. The sibling generator already carries the fix and its
docstring names this exact bug class.

Both generated artefacts are additionally **stale**: the price sheet differs in 15 rows from a fresh
regeneration with 5 rows regressed to `?`, contradicting the "0 unresolved" claim these documents
feed into the published Chapter-2 material.

### Fixed during Stage 0

Two actively-misleading messages — the class where a reader can *act* on the message and be sent
the wrong way, as distinct from a message that is merely terse:

- **DEMIPAD type-3 deposit** enforced `iz-ouro` and reported *"SSTOA Deposits must be turned on"*.
  SSTOA is a real, separately-togglable admin flag, so an operator could perform the suggested
  remedy, observe nothing change, and retry forever. Its pin now demands **different** text per
  branch — with identical wording, a test that swapped the two branches would still pass.
- **Snakes acquisition** had no nonce guard, so an unsellable nonce was refused by the *supply* cap
  with text identical to a genuine over-buy. Its Custodians twin had `UEV_AcquisitionNonce` from the
  start; Snakes now carries it.

### Targets this stage produced

| target | why it is first-rank |
|---|---|
| **G-34 / V-03** | `UEV_SwapData` runs **only on the slippage branch**. With `slippage = -1.0` the real gate is `SWPU\|X>SWAP` — no uniqueness, no count bound, no "output ∉ inputs". Attacker-drivable through `C_Swap`. |
| **V-01** | slippage unbounded in *both* directions; the `@doc`'s "≤ 50" is UI policy the chain never runs, and the on-chain ceiling is opt-in and disabled by a negative sentinel. |
| **`GAS_PAYER` Case 3** | validates exec-code forms 0, 1 and 2 only; forms at index ≥ 3 are unconstrained and form 2 need only *start with* `(let`. The only bound is economic. |

---

## Stage 1 — Family A, arithmetic & value

### RT-A-001 — the LP-churn deterrent could be declined *(FIXED)*

**Hypothesis.** Adding standard liquidity is reachable through two live Talos client paths, and one
does not charge the `lp-churn` deterrent. If so the deterrent is optional: a provider pays it only
by choosing the more expensive door.

**Confirmed, measured before the fix:**

| route | charged |
|---|---:|
| `TS01-C3 → SWP\|C_AddLiquidity → SWPLC` | **557.03** (1051.0 raw at a 0.53 discount) |
| `TS01-CP → SWP\|C_AddStandardLiquidity → MTX-SWP` | **53.00** (a flat literal 100.0) |

Same operation, same pool, **10.5×**. Both routes are `P|UEV_IMC`-gated Talos clients, so this is
not a matter of calling core directly — and the cheaper door is the one the gas station subsidises.
`lp-churn` appeared **zero times** in `20_MTX-SWP.pact`.

**Why it survived, and this is the transferable part.** An earlier repair moved every add-liquidity
op onto `UC_IgnisPrice`; it landed in `18_SWPLC.pact` only. Nothing compared the two modules
afterwards, and nothing could have: the suite measured each route against **its own** preview, and
both routes agreed with themselves. Preview-versus-charge testing — however rigorous, and this
project has 397 such measurements — cannot see this class. It asks *"does this route quote what it
charges"*. The unasked question is *"do two routes to the same operation charge the same"*: a
**cross-route** invariant, not a per-route one.

**Fix.** Step 0 of all three add-liquidity defpacts now bills `UC_IgnisPrice … "lp-churn"`, with
`UC_AddLiquidityChurnKey` selecting Standard/Iced/Glacial from the same two collection flags that
already decide which variant is running. The Frozen and Sleeping twins carried the identical gap and
were repaired with it.

**Deliberately not changed.** The three `step-with-rollback` branches still charge the flat 100 — a
rolled-back step did not perform the operation, so charging the full deterrent is a design choice,
not a defect. `MTX|C_Issue`'s flat 100 is a *different* operation with a different deterrent and was
left for a ruling rather than guessed at.

**Verification.** The block now measures 557.03 = 557.03, and the two assertions that encoded the
exploit went red at the moment of repair — evidence a fix-first approach cannot produce.

*Footnote worth keeping: the exploit assertion itself first failed on a three-argument `(* a b c)`.
Pact's `*` is binary — the same arity trap this project's ledger already records for a
three-argument `or`.*

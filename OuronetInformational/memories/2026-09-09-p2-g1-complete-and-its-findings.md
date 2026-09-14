# 2026-09-09 — G1 reaches 100%, and the six defects it found on the way

**Status: P2 complete.** All 448 Talos client entrypoints are invoked by an asserting test **AND
every one of those tests is executed by the gate** (`B4 = 0`, `B4b = 0`, `B10 = 100%`). Regenerate
with `python3 REPL/tools/_test_ledger.py > OuronetInformational/ARCHITECTURE/REPL-TEST-LEDGER.md`.

> **The first "100%" was wrong and is worth remembering.** It was published while NINE entrypoints
> lived exclusively in files the gate does not run (`vst-harness.repl`, `_audit_ats_baseline.repl`,
> two `_scratch_` probes) — invoked, therefore absent from the G1 gap, and re-executed by nothing.
> The protected figure was 439/448. Same error as RULE 10 (comments) and RULE 11 (ZALL vs written),
> in a third disguise: *a metric computed over the whole tree instead of over what actually runs.*
> `_test_ledger.py` now imports `_gate.py`'s GATE list and closure and prints both rows, so the two
> cannot drift apart.

The point of this note is **not** the coverage number. It is that "call every entrypoint once and
assert on what actually happened" — the weakest possible discipline above a smoke test — found
six real defects. None required an adversarial test, a fuzzer, or a red-team hypothesis.

---

## Confirmed defects (each has a pinning test; none are fixed yet)

### 1. StoicIco distribution vault DEADLOCKS from round 2  — *severe*
`2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact:496`, `XI_CollectFor`:

```pact
(ref-TS01-C1::DPTF|C_Mint patron urSTOA-id DEMIPAD|SC_NAME urSTOA-supply false)
(if (!= urSTOA-supply 0.0) <multi-transfer> <single-transfer>)
```

The `if` guards the **delivery** against a zero amount. The **mint above it does not**, and
`DPTF::UEV_Amount` refuses a zero-amount mint. An account's urSTOA entitlement is zeroed by its
FIRST collect, so from the second collect onward the whole transaction aborts — while real wSTOA
is still owed (measured: emma at 0 urSTOA, ~309 claimable wSTOA, global urSTOA pool at 245,932,
so it is per-account, not the ICO running dry).

Three entrypoints share the abort and together close every exit:
* `C_Collect` aborts → the holder cannot self-collect
* `AA_FlushUncollected` aborts → the admin cannot push-collect (same `XI_CollectFor`)
* `A_Inject` is barred while `unclaimed-count != 0` → no new round can open

**Fix:** the guard the delivery already has. `IGNIS::C_TransferDalosFuel` documents this exact
lesson in its own `@doc` ("A ZERO amount is a NO-OP, not a transfer … passing 0.0 aborts the whole
transaction"); it was simply not applied here.
**Test:** `REPL/Stage_02/[6.3]_STOAICO.repl` TX-TAL. When fixed, that block must be rewritten as a
POSITIVE collect plus the `INFO_Collect` quote-equals-charge assertion (written and waiting in
this file's git history).
**Why it survived:** the suite only ever called `STOAICO.C_Collect` **directly on the core
module**. That path proves the state machine and bills nothing, so nobody had walked round 2
through Talos — where IGNIS is actually collected.

### 2. `VST|C_Merge` / `C_Slumber` do not check what they are merging
Both delegate to `XI_MergeNonces` with a `vzh-tag` (2 = Sleeping, 3 = Hibernating). Nothing
validates that the dpof handed in is the link that tag assumes, and the tag decides **two** things:
which link resolves the underlying DPTF (`UR_Sleeping` vs `UR_Hibernation`) **and which metadata
shape the surviving nonce is minted with**.

So `C_Slumber` on a SLEEPING dpof succeeds and mints hibernating metadata
(`{mint-time, release-date}`) into a sleeping collection whose readers want
`{release-amount, release-date}`. Permanently malformed, silently. The DPTF mis-resolution
(the `"|"` sentinel) is only reached in the release branch — i.e. once a nonce has EXPIRED — so
the crash is **data-dependent** and surfaces months later as a table read naming neither the op
nor the cause.
**Test:** `REPL/modules/VST.repl` VST-09. The suite's own earlier transaction had created a
malformed nonce without noticing.

**ESCALATION (VST-11 * 04): the malformed position is PERMANENTLY UNRECOVERABLE.** `C_Unsleep` is
the only release path for a sleeping nonce, and on the malformed one it dies with
`Runtime typecheck failure, argument is list, but expected type list (object{VST|MetaDataSchema})`
inside `URC_CullMetaDataAmountWithObject` — not a guard, not a named rejection. The nonce is fully
matured and holds 200.0 of real value that can never be withdrawn. So finding #2 is not "writes a
malformed record"; it is **"silently and irreversibly destroys access to the underlying tokens,
and reports success."**

### 3. Five `(format "literal")` calls with no argument list
Pact's `format` takes a template AND a list. One argument is an arity error that resolves to a
closure and aborts with `Expected Pact Value, got closure or table reference`.

| site | branch | fires |
|---|---|---|
| `LIQUID.pact:125` | migration guard message | rejection |
| `ATS.pact:884` | Hot-RBT enforce message | rejection |
| **`INFO-ONE+.pact:2465`** | `INFO_ATS\|Cull` description | **success — every call** |
| `DSP+.pact:361` | "nothing to distribute" | normal empty case |
| `DPL-UR.pact:2460` | "KPay Sale has concluded" | normal end state |

The third is not an error message but part of the returned object, so **`INFO_ATS|Cull` is broken
for every input** and no client can price a cull. `DALOS.pact:489` writes the identical sentence
correctly with `[]`. Every one of the five sits on a branch tests do not reach — that is the
mechanism, not a coincidence.
**Tests:** `REPL/modules/ATS.repl` ATS-BRD·02, `REPL/modules/LIQUID.repl` LQD-03pre.

### 4. `LIQUID`'s migration guard is ALSO worded backwards
`(enforce gap "…can only be executed when Global Administrative Pause is offline")` — `enforce gap`
passes when the pause is **ON**. Requiring GAP ON is correct (it freezes the chain for the window
in which the escrow is empty); only the wording is wrong. The `format` bug above hides it, since
the sentence never reaches the operator. `DALOS` has the same inverted wording in
`GOV|MIGRATE`.

### 5. `SWP|C_SmartSwapWithSlippage` measures its bound in FEE-LESS tokens
Measured on the suite's own 6-hop route, 5.0 in: fee-less quote 4.999878, caller's 1% floor
4.949879, **actually delivered 4.541454** — 0.408 below the floor, 8.2× the chosen tolerance, and
the swap executed. Not a bug (the code says "fee-less" in three places and quote and check agree);
the hazard is at the UI boundary, because `UC_SlippageMinMax` returns `[min max]` shaped exactly
like "minimum you will receive", and the error **scales with hop count**. A breached bound also
returns a string rather than reverting — no event, no failure, no balance change.
**Test:** `REPL/Stage_01/[6.3]_SWP.repl` TX 054.

### 6. `DEMIPAD|C>WITHDRAW` has a provably dead `enforce`
`C_Withdraw` reads `UR_Funds` *before* the capability, and `UR_Funds` enforces the identical
predicate. In-range passes both; out-of-range dies in the reader. The cap's check is unreachable
for every input. Left in place — deleting it is a core-code change and there is a
defence-in-depth argument.

---

## Behaviours worth knowing (correct code, non-obvious)

* **A freshly issued SWP pool is INERT.** `can-swap` AND `can-add-liquidity` both start `false`.
  "The pool exists" and "the pool works" are different states.
* **W and P pools require the FIRST token to be a Principal**; stable pools do not. Opening
  liquidity must clear `SWP::UR_SpawnLimit` in wSTOA, measured from the first token's deposit
  alone — not the sum.
* **The SWP pool id is DERIVED from (tokens, weights, amp)**, so weights are part of the identity:
  the same tokens at uniform weights are a DIFFERENT pool.
* **Branding `flag` is a TIER that counts DOWN.** Entities seed at 3; an upgrade lands on 1.
  `months` buys time measured from branding genesis, not from now.
* **`DPTF|C_Wipe` requires the account to be FROZEN first** (`C>WIPE` → `C>X_WIPE` →
  `UEV_AccountFreezeState true`). Wipe BURNS — supply falls, nobody is credited. Repurpose MOVES.
* **A former holder reads `0`; `-1` means "never held".** Residue rows keep the two distinguishable
  (`UR_AccountNonceSupply`).
* **Repurpose is a FORCED move** — the collection owner debits a third party who does not sign.
* **`VST` "repurpose" is decommission + re-issue, not a transfer.** The source nonce is consumed
  (holder `"|"`, supply `-1`) and a NEW nonce is minted. Anything tracking a position by nonce id
  must follow the re-issue. True of `C_RepurposeHibernating`, `C_RepurposeSleeping` and
  `C_RepurposeVested` alike.
* **`VST|C_RepurposeReserved` takes the RESERVED token id, not the parent.** Passing the parent
  silently repurposes the holder's plain balance and leaves the reserve untouched —
  `vst-harness.repl` passes the parent id and asserts nothing, so it had been doing exactly that.
* **`C_Reserve` needs the reservation OPENED first** (`DPTF|C_ToggleReservation`), and the
  RESERVER must sign — recovery afterwards does not need their signature. That asymmetry is the op.
* **`C_Unsleep` releases a SLEEPING nonce; `C_Awake` releases a HIBERNATING one.** Release is not
  a transfer: the position is destroyed and the underlying DPTF returns as liquid balance.
* **`LQD|C_UnwrapStoa` needs the CALLER to sign a `coin.TRANSFER` out of the LIQUID escrow** — an
  account they do not own and cannot discover from the signature (`LIQUID.pact:516` has the in-code
  install commented out as "added instead in the JavaCode"). The signed amount is the real per-tx
  unwrap ceiling.
* **SPARK redemption is not a sale.** The holder exchanges LIQUID Sparks for wSTOA **plus the same
  count of FROZEN Sparks**, and needs TWO signatures (the capability is scoped to the account being
  redeemed; step 1 transfers wSTOA from the payer). The pad is a way station — its liquid balance
  nets to no change.
* **A collection creator cannot patron a sale of their own collection** — the royalty pays
  patron → creator and `IGNIS|C>ROYALTY` refuses sender == receiver.
* **Role toggles are not idempotent.** Granting an already-granted role is rejected, so a caller
  that re-asserts desired state (any idempotent deploy script) breaks.

---

## Test-infrastructure lessons (all now RULEs in `ARCHITECTURE/REPL_TEST_ARCHITECTURE.md`)

* **RULE 9** — `expect-failure` catches an abort but does **not** roll back writes. 22 such sites
  existed and `rollback-tx` was used in exactly zero places. Every negative probe on a mutating op
  must be followed by a guard assertion proving no residue.
* **RULE 10** — a commented-out invocation is not coverage. Stripping comments dropped the claimed
  figure from 98% to 94%: 13 entrypoints were "covered" by `;` alone, across 85 disabled
  invocation sites in 16 files.
* **RULE 11** — coverage counted is not coverage GATED. 51% → **95%** of written assertions now
  execute in the gate. The gap closed by fixing **exclusions**, not by writing tests: `Kursan/`
  (343 assertions), `Stage00b_` (51 — the fragment caught the DRIVERS) and
  `launchpad-groundtruth.repl` (256) were all excluded by **filename prefix instead of role**.
* **`./_run1.sh <file>`, never `pact <file> | grep FAILURE`.** A file that aborts before reaching
  any assertion yields zero `FAILURE:` lines and reads as green.
* **No state crosses between testers** — each is its own process with its own in-memory DB. That
  isolation is what makes `xargs -P 16` safe; it is now asserted, not assumed.

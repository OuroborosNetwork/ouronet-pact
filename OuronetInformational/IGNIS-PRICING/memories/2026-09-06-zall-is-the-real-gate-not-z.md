# 2026-09-06 — `Z.repl` green is NOT enough: it skips the suites that catch pricing regressions

## What happened

The whole IGNIS re-pricing rehaul was verified against `cd REPL && pact Z.repl`, which exits 0 with
zero failures. Running `REPL/ZALL.repl` (the exhaustive runner) surfaced **two regressions this
session introduced**, both invisible to `Z.repl`:

1. **Zero-amount STOA transfer aborts the tx.** P2 made `DALOS|URCi_DeploySmartAccount` return
   `0.0` while the account-creation STOA switch is OFF. The Talos path still called
   `STOA|C_Collect account 0.0`, which splits into four `coin.transfer` legs of `0.0` — and Stoa's
   `coin` enforces `(> amount 0.0)`. Every smart/standard account deploy with the switch OFF
   aborted. Fixed by making `IGNIS::C_TransferDalosFuel` a **no-op on a zero amount**, which is the
   single funnel for every `STOA|C_Collect*` path. That also covers a second latent case: a small
   dollar-pegged amount whose split rounds ONE of the four legs to zero would have aborted too.
2. **`[6.6]_ATS.repl` ran out of STOA.** P4 replaced the escalating fee-unlock ladder (cheap first)
   with a FLAT $50 STOA + $50 IGNIS per unlock, so the parameter-unlock scenario now outspends the
   AOZ account's 5000 genesis STOA. Raised to 9000 in `[0.0]_Starter.repl` (test scaffolding —
   no price moved).

## Why `Z.repl` missed both

`Z.repl` is the documented fast path and it **deliberately skips**:

- `Stage_01/[6.1]_Cumulator.repl` — which is where the **P7 price sweeps live**. So the DPTF/ATS
  price assertions were not running in any "green Z.repl" claim made during this rehaul.
- `Stage_01/[6.2]_DPTF.repl` + `[6.3]_SWP.repl` (full) — `Stage01_Tester.repl` picks the
  issuance-only variant instead. The smart-account STOA bug lived in `[6.3]`.
- `[6.6]_ATS.repl`, `[6.7]_VST.repl` and the rest of the Stage-1 scenario tail.

**Rule going forward: any change to pricing, STOA collection, or IGNIS billing must be verified
with `ZALL.repl`, not `Z.repl`.** `Z.repl` is fine for iteration speed; it is not a gate for
anything money-related. A green `Z.repl` on a pricing change is close to meaningless — it does not
execute the price assertions written to protect that change.

## The general shape (third instance this session)

1. Half-migrated `son` branch — valid syntax, wrong price, green pipeline.
2. Dead `::` modref calls — resolved at runtime, so they load clean and die only when called.
3. This one — the assertions existed but the runner used to claim "green" never executed them.

All three are the same failure: **the check that would have caught it was not actually running.**
Before trusting a green run, confirm the specific assertion you care about appears in its output.

# Finishing the constructor — capabilities and ownership  (2026-09-26)

The last two of the owner's nine requirements. Both were at **0/423**; both had a root cause that
was the same shape as everything else found this week: *the thing that must follow an entrypoint
lives in a file nothing compares it against.*

## Requirements 5 + 7 — external capabilities, and the formula for their arguments

These are ONE mechanism, not two. Some operations need the caller to sign `coin.TRANSFER` legs
paying a sale contract, and the amounts cannot be computed client-side — they depend on live
price, the native-vs-wrapped split and a slippage pad. So the contract ships a READER returning
the capability strings ready to parse, and **that reader IS the formula** the owner asked about
(*"if there is a formula that computes the parameters that must be supplied for these
capabilities, which is the case for some launchpad functions"*).

**Why it emitted zero.** `caps_reads()` looked for the reader in the ENTRYPOINT's own module. The
entrypoint is `TS02-CPAD.SPARK|C_BuySparks`; the reader is `DEMIPAD-SPARK.URC_Acquire`. Verified:
`caps_reads(TS02-CPAD) -> []`, `caps_reads(DEMIPAD-SPARK) -> ['URC_Acquire']`. Zero out of 423
read as *"no operation needs extra capabilities"* rather than as a failed lookup.

Fixed by resolving what each entrypoint DELEGATES to — with modref aliases resolved, since Talos
binds `(ref-SPARK:module{...} DEMIPAD-SPARK)` and then calls `ref-SPARK::…`.

### The over-attribution that nearly shipped

Resolving delegates gave **16** entrypoints, and 12 were wrong. DEMIPAD holds a cap reader and
sixteen entrypoints delegate there, but every `Retrieve`/`Fuel`/`Withdraw` among them takes no
payment at all. Telling a consumer to sign transfer capabilities for those is worse than silence.

The discriminator is principled rather than tuned: **can the entrypoint supply the reader's
arguments?** `slippage` is exempt (it is the client's pad, deliberately not an entrypoint
argument); names are matched loosely in one direction (`sparks-amount` against `amount`) because
the citizen readers were written to mirror their entrypoints. Applying it leaves exactly the
**4 launchpad buys** — SPARK, SNAKES, CUSTODIANS, StoicPay — and rejects all 12.

### Prefer the CITIZEN reader

`DEMIPAD-SPARK.URC_Acquire (buyer amount iz-native slippage)` takes the entrypoint's own
arguments. The sovereign `DEMIPAD.URC_Acquire` additionally needs the asset id and the amount
converted to DOLLARS. Both were exercised live and both work; the registry points at the citizen
one, and says so.

## TWO LIVE CONSUMER BUGS, found by building this

1. **`daimons/OuronetUI/src/kadena/sparkBuy.ts:94`** calls `DEMIPAD.URC_Acquire` with **4
   arguments**; the signature takes **5** — `slippage` was added by `5df9637a` (launchpad
   slippage protection) and the call site never followed.

   Measured against mainnet, both arities:
   - 4-arg -> `"Evaluation did not reduce to a value"` — the **partial application** case. Pact
     does not say "wrong arity"; it silently yields a CLOSURE.
   - 5-arg -> reaches real logic, failing only on a non-existent test account.

   So `getSparkAcquireCapabilities` returns `null`, no `coin.TRANSFER` caps are attached, and
   **the buy cannot be funded.** The changelog's "both native and wrapped purchases confirmed
   working" predates the slippage commit.

2. **`_libs/ouronet-libs/packages/ouronet-core/src/interactions/kpayFunctions.ts:85`** calls
   `DEMIPAD-KPAY.URC_Acquire` with 3 arguments. **`DEMIPAD-KPAY` does not exist on chain** —
   confirmed by `describe-module`; the module is `DEMIPAD-STOICPAY`, and its reader takes 4.

Neither is fixed yet. Both are exactly what the registry exists to prevent, and both were
invisible to every existing check.

## Requirement 3 — ownership

Root cause was one line, `_authsurface.py:130`: `\(?([A-Za-z0-9|_.:-]+)` steps OVER an opening
paren and grabs the first identifier, so `(UR_OwnerKonto swpair)` captured **`UR_OwnerKonto`** —
the reader — and discarded `swpair`, the subject.

Added `surface_structured()` alongside the existing walk: same sites, but reading the WHOLE
balanced argument and classifying it.

- a bare name -> that parameter IS the account
- `(UR_OwnerKonto x)` -> the account is what the reader returns for ENTITY `x`

**The markdown artefact is untouched.** It is gate-enforced as a superset; churning it would
either mask a real regression or manufacture a fake one. `--check` still reports 1,225
entrypoints, none weakened.

### Only `CAP_EnforceAccountOwnership` counts

The markdown's `OWN` lists all eight `CAP_*` variants, right for a coverage baseline and wrong
here — **only that one takes an account.** The other seven take an ENTITY and resolve the owner
themselves:

```
CAP_Owner (swpair)        -> CAP_EnforceAccountOwnership (UR_OwnerKonto swpair)
CAP_StakeOwner (owner-id) -> CAP_EnforceAccountOwnership owner-id        (already an account)
```

Counting the wrappers double-counts AND reports the entity as the account — which is precisely
the `["patron","swpair"]` defect. Every wrapper was checked to bottom out at
`CAP_EnforceAccountOwnership`, directly or through another wrapper, so the transitive walk loses
nothing by ignoring them. Before the fix `SWPLC.STOA-PID|C_AddFrozenLiquidity` reported BOTH
"the `swpair` parameter itself" and "owner of `swpair`"; now only the latter.

### ALWAYS vs CONDITIONAL — the nuance that makes the field safe

`IGNIS.UEV_Patron`:

```pact
(if (UR_AccountType patron)
    (do (enforce (= patron DALOS|SC_NAME) ...)
        (CAP_EnforceAccountOwnership DALOS|SC_NAME))   ;; gas station signs
    (CAP_EnforceAccountOwnership patron))              ;; the user signs
```

Reported flat, that says "the caller must hold the patron's key" — **false on the gas-sponsored
path, which is the common one.** So every clause now carries `when: ALWAYS | CONDITIONAL`.
CLAUDE.md already warns about this shape for *moving* an authorisation; it applies equally to
*reporting* one. `DPTF|C_Transfer` now reads correctly: `owner of id` ALWAYS, `patron`
CONDITIONAL.

Result: **384 resolved / 39 unresolved**, 176 ALWAYS and 381 CONDITIONAL clauses.

### The known remainder: argument threading

The walk is transitive, so an enforce at depth N is written in THAT callee's parameter names. For
`DPTF|C_Transfer` the sender's enforce lands on a parameter called `sender` inside the shared TFT
engine, while the entrypoint calls it `executor` — so it appears under `unmapped` rather than
`requires`. Mapping it back needs arguments threaded through each call, which is not done.

Unmapped subjects are therefore **listed, not guessed**, with a note saying why. `requires` is
complete for everything the entrypoint names directly.

## An accident worth recording

A scripted edit computed `old = s[ia:ib]` where `ib < ia`, making `old` the EMPTY STRING.
`str.replace("", new)` inserts between every character: `_registry.py` went from 55 KB to
**193 MB**. `git checkout` then reverted the file to its last COMMIT, discarding a full session of
uncommitted tool work — recovered only because a negative test had copied the tool to `/tmp`
minutes earlier.

Two rules from it, both now applied: **assert the slice is non-empty and the anchors ordered
before replacing**, and the reason the ordering was wrong is that `if PREVIEW.match(name):`
occurs BEFORE the ownership block, not after — an assumption never checked.

## State of the nine requirements

| # | requirement | state |
|---|---|---|
| 1 | execution function + shape | 423/423 |
| 2 | info function + shape | **423/423** (PureV2/20 landed mid-session) |
| 3 | ownership | **384/423 resolved**, conditional-marked, remainder listed |
| 4 | live-vs-repo provenance | 423/423, 0 divergences |
| 5 | other capabilities expected | **4/4 correct set** |
| 6 | sponsorship | 423/423, step-scoped for defpacts |
| 7 | formula for cap params | **same field** — reader, its params, arg mapping, parse recipe |
| 8 | ghost values | 3/423 — hand-authored, cannot be derived |
| 9 | execution mode | 423/423, five modes |

Gate green at 26,120. Surface `cee5dbcbe00479e8`.

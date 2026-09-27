# Signing and capabilities — who signs what, and who pays

Which keys a transaction needs, which capabilities go on them, and the three roles Ouronet
separates that most chains conflate.

Measured against `Deploy/OURONET-REGISTRY.json` on 2026-09-27. Every count below was computed
from that file; none is remembered.

---

## 0. Three roles, not one

Most chains have a sender who pays, acts and is acted upon. Ouronet splits these, and the split
is positional canon across every client entrypoint:

| role | position | who it is |
|---|---|---|
| **patron** | 1st | the account whose IGNIS pays for the operation |
| **executor** | 2nd | the account performing it — whose ownership is enforced |
| **executee** | 3rd, when one exists | the account it is done *to* |

The consequence for a client: **the patron is an argument, not a signer.** It does not sign.
Its balance is charged because the contract says so, not because a key authorised it. What
signs is the executor's guard.

Getting this backwards produces a call that looks right and is refused — or worse, one that
charges the wrong account. The registry records the intended role of every parameter, so a
consumer never has to infer it from a name.

---

## 1. The standard transaction shape

415 of the 423 client entrypoints are **gas-sponsored**: the Ouronet gas station pays the
Kadena-level gas, and the user pays only IGNIS. Every one of those 415 uses the same capability:

```
ouronet-ns.DALOS.GAS_PAYER
```

The shape, in full:

```js
Pact.builder
  .execution(pactCode)
  .setMeta({ senderAccount: STOA_AUTONOMIC_OURONETGASSTATION, chainId, gasLimit, ... })
  .setNetworkId(NETWORK)
  // the caps key carries GAS_PAYER and nothing else
  .addSigner(capsKeyPub, w => [ w(`ouronet-ns.DALOS.GAS_PAYER`, "", { int: 0 }, { decimal: "0.0" }) ])
  // the guard keys sign bare -- they authorise, they do not scope
  .addSigner(guardPub)
  .createTransaction();
```

Two distinct key roles:

- **the caps key** carries `GAS_PAYER`. This is what makes the gas station pay.
- **the guard keys** are added as **bare signers** — no capability list. They are the proof that
  the executor's account guard is satisfied.

`GAS_PAYER`'s arguments (`"", 0, 0.0`) are placeholders the gas station reads; they are not a
limit you should tune per operation.

### The eight that are NOT sponsored

```
ATS.HOT-RBT|C_Repurpose, C_UpdatePendingBranding, C_UpgradeBranding
SWPLC.STOA-PID|C_Add{Frozen,Glacial,Iced,Sleeping,Standard}Liquidity
```

These are reached through a different path and the sponsorship does not apply. If you wire one,
do not assume the gas station covers it.

---

## 2. Whose ownership is actually enforced

The registry resolves this for **384 of 423** entrypoints. The remaining 39 reach an ownership
check deeper in the call tree whose subject is named for a callee's parameter rather than the
entrypoint's — mapping those back needs argument threading, so they are **listed rather than
guessed**. Treat an unresolved entry as "read the contract", not as "no ownership required".

Two things a client must not flatten:

**`ALWAYS` versus `CONDITIONAL`.** 176 requirements always bind; 381 are reached inside an `if`
and bind on one path only. A conditional requirement presented as mandatory makes a UI demand a
signature the operation may not need.

**`parameter` versus `reader`.** 404 requirements name an account the caller passes directly;
153 name one the contract *looks up* — a pool's owner, a token's issuer. The second kind cannot
be known from the form the user filled in. It has to be read first.

That second case is the one that bites. Several operations are performed **by the issuer, on
someone else's holding**:

```
C_Wipe / C_WipeSlim   →  UEV_ExecutorIsKonto  →  the TOKEN's owner must sign
VST|C_Create*Link     →  DPTF::CAP_Owner      →  the TOKEN's owner must sign
```

A "Wipe" button sitting in a holder's token list is gated on the *issuer's* key. On the live
chain, the token owner, the LP owner and the pool owner of one pool were three different
accounts — so "the user owns this token, therefore they may act on it" is not a safe inference
anywhere.

---

## 3. When the receiver must sign too

`DPTF|C_Transfer` and its DPOF/DPNF siblings take a trailing `method:bool`. It is not a
formatting flag:

```pact
(if (and method (ref-DALOS::UR_AccountType receiver))
    (ref-DALOS::CAP_EnforceAccountOwnership receiver)   ;; the RECEIVER must sign
    true)
```

With `method = true` and a **smart** receiver account, the transaction needs the recipient's
signature as well as the sender's. With `method = false` it is an ordinary transfer.

For a UI this is the difference between a transfer that can be completed alone and one that
cannot. Default it to `false`, and if you expose it, say what it does rather than showing a
switch labelled `method`.

---

## 4. The four that need a capability you have to compute

Four launchpad purchases require a capability that is **not fixed and not derivable from the
entrypoint's own arguments** — it has to be fetched:

```
TS02-CPAD.SPARK|C_BuySparks         computed by  DEMIPAD-SPARK.URC_Acquire
TS02-CPAD.SNAKES|C_Acquire                       DEMIPAD-SNAKES.URC_Acquire
TS02-CPAD.CUSTODIANS|C_Acquire                   DEMIPAD-CUSTODIANS.URC_Acquire
TS02-CPAD.KPAY|C_BuyStoicPay                     DEMIPAD-STOICPAY.URC_Acquire
```

The reader returns strings shaped `<(coin.TRANSFER "from" "to" <decimal>)>`. Strip the angle
brackets, parse each, and attach it as a real capability with args `[from, to, {decimal: amount}]`.

One argument of that reader is **not** an entrypoint argument: `slippage` is client policy. The
registry's note on it is worth quoting, because it names a failure that would be hard to
diagnose:

> Keep it consistent with the entrypoint's own ceiling argument (`max-cost`), or the capability
> the user signs and the ceiling the contract enforces describe different amounts.

A user signing `coin.TRANSFER` for one figure while the contract enforces another is the worst
kind of mismatch: both are internally valid.

---

## 5. Unlock before you cover the screen

A practical failure worth one paragraph, because it cost a working feature an evening.

If your signing path fetches a cached password and prompts when the cache has lapsed, that
prompt is a modal. A confirmation panel opened at the same z-index and mounted later **paints on
top of it**, so the prompt is on screen, unreachable, and its promise never settles. The symptom
is a spinner that says "awaiting signature" forever.

Two rules that make it structural rather than remembered:

- **Unlock before the overlay mounts**, so any prompt appears with nothing over it.
- **Give every blocking panel an escape**, in every phase. A modal with no way out is a worse
  failure than whatever it was waiting for — and while signing, it is waiting on something
  outside itself.

---

## Cross-references

- `01-client-orchestration.md` — the read-build-execute shapes these transactions sit inside
- `03-cost-preview.md` — what the patron will actually be charged
- `04-errors.md` — what a missing or wrong signature looks like coming back
- `OuronetInformational/StoicSyntax-Prefixes.md` §2.2 — the patron/executor/executee canon

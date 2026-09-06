# Handover — `coin` bulk-transfer functions for StoaChain

**Target repo/module:** StoaChain core `coin` contract (`StoaChain/pact/stoa-coin/…/live-coin-module.pact`), the native-token (fungible-v2-style) module. This is a **core-protocol upgrade** deployed on all 10 chains — give it core-contract audit weight.

**Audience:** an agent writing + REPL-testing Pact on the StoaChain pact-construction system. This doc is the spec, not the implementation.

---

## 1. Purpose

Add **batched transfer** functions so one transaction can pay many recipients, replacing N independent `coin.transfer` / `coin.transfer-create` calls. Driving use case: the StoaChain mining pool's daily payout pays hundreds–thousands of miners from one coinbase account; N independent transfers floods the explorer/mempool and multiplies gas. With the raised **2,000,000** block gas limit (up from the 150k default) and ~250 gas/credit, a single bulk tx comfortably pays thousands of recipients.

General-purpose value beyond the pool: airdrops, payroll, exchange withdrawals.

---

## 2. What to add — two functions

| Function | For | Guard arg |
|---|---|---|
| `transfer-bulk` | recipients that **already exist** on this chain | none (existing accounts) |
| `transfer-create-bulk` | recipients that **may not exist** (creates them) | yes — one guard per recipient |

Rationale for two (not one): `coin`'s create-path enforces that a supplied guard **matches** an existing account's guard, so an "always-create" single function would require the caller to know every existing recipient's real guard. Splitting lets the caller use the guard-free `transfer-bulk` for known-existing accounts and reserve the guard-bearing variant for new ones.

Typical caller flow: detect which recipients exist → `transfer-bulk` for the existing set, `transfer-create-bulk` for the new set. When all exist, it's a single `transfer-bulk` call.

---

## 3. Signatures

```pact
(defun transfer-bulk:string
  ( sender:string
    receivers:[string]
    amounts:[decimal] )
  ...)

(defun transfer-create-bulk:string
  ( sender:string
    receivers:[string]
    receiver-guards:[guard]
    amounts:[decimal] )
  ...)
```

- `receivers[i]` is paid `amounts[i]`.
- `transfer-create-bulk` uses `receiver-guards[i]` to create `receivers[i]` if absent (and, per `coin` create semantics, the guard must equal the existing guard if it already exists).
- Lists are positionally zipped; all must be the **same length** and **non-empty**.

---

## 4. Capability model (the part that must be exactly right)

Define a **managed** capability authorizing the aggregate spend:

```pact
(defcap TRANSFER_BULK:bool
  ( sender:string
    total:decimal )
  @managed total TRANSFER_BULK-mgr
  (enforce-guard (at 'guard (read coin-table sender)))   ; sender must sign
  (enforce (> total 0.0) "bulk total must be positive"))

(defun TRANSFER_BULK-mgr:decimal (managed:decimal requested:decimal)
  ; one-shot: the whole authorized total is consumed by the single bulk call
  (enforce (<= requested managed)
    (format "bulk total {} exceeds authorized {}" [requested managed]))
  (- managed requested))
```

The bulk functions run their debit/credits **inside** `(with-capability (TRANSFER_BULK sender total) …)` where `total = (fold (+) 0.0 amounts)`. The sender signs `TRANSFER_BULK(sender, total)`; the managed-amount machinery guarantees the signature authorizes **exactly** `total` and no more.

**Security property to document loudly:** `TRANSFER_BULK(sender, total)` authorizes a **budget**, not specific recipients — the signature does NOT bind the receiver list. The signer is trusting the receiver/amount lists in the tx payload. This is standard for batch-pay primitives and acceptable for the pool (the hub builds and signs its own tx body), but it MUST be called out so no one assumes the cap pins recipients.

> **Optional hardening (decide in §11):** bind `(hash [receivers amounts])` into the cap as a third managed/observed parameter so the signature commits to the exact list. Stronger, slightly more gas, and the caller must compute the same hash. Recommend offering it as `transfer-bulk-bound` later rather than complicating v1.

Do **not** route bulk credits through the per-pair `TRANSFER` managed cap — that defeats the purpose (you'd need N installs).

---

## 5. Algorithm & invariants

Both functions, in order:

1. **Shape:** `receivers`, `amounts` (and `receiver-guards`) are the **same length** and **non-empty**. Fail otherwise.
2. **Per-amount validation** for every `amounts[i]`:
   - `> 0.0` (reject `0.0` — a zero credit is a stealth no-op/create; reject negatives — theft).
   - precision ≤ `MINIMUM_PRECISION` (12): `(enforce (= (floor amt 12) amt) "precision violation")`.
3. **Per-account validation:** `validate-account`/`enforce-account` each `sender` and `receivers[i]`; enforce `sender != receivers[i]` (no self-transfer line).
4. **Total:** `total = (fold (+) 0.0 amounts)`. (This IS the debit; the `sum == total` identity is structural — debit once by `total`.)
5. `(with-capability (TRANSFER_BULK sender total)`
   - `debit sender total` (single debit of the aggregate).
   - `(zip (lambda (r a) (credit r <guard> a)) receivers amounts)` — credit each. For `transfer-bulk`, `credit` against the existing account (read its guard); for `transfer-create-bulk`, `credit` with `receiver-guards[i]` (create-or-match).
   `)`
6. Return a summary string (e.g. count + total).

Keep it **O(n)** — `zip`/`map`/`fold`, no nested scans. Each credit is one table write (~the per-recipient gas).

**Conservation invariant (assert or prove in tests):** post-state `sender.balance` decreased by exactly `total`, and `Σ receiver.balance` increased by exactly `total`. No coin minted or burned.

---

## 6. Guard handling (`transfer-create-bulk`)

- The pool only ever **creates** `k:` (single-key) accounts — named accounts must already exist to have been verified, so they go through `transfer-bulk`. For a `k:` account, the guard is **derivable from the address**: `keys-all` over the embedded pubkey. The caller passes that derived keyset as `receiver-guards[i]`.
- The function should NOT trust guards blindly for accounts that already exist: rely on `coin`'s existing create semantics (the supplied guard must equal the stored guard for an existing account; mismatch fails). Don't add a path that overwrites an existing account's guard.
- Reject empty/!-prefixed/invalid account names via the module's existing `enforce-account`.

---

## 7. Edge cases to enforce (the test-failure surface)

- list length mismatch (receivers vs amounts vs guards) → fail.
- empty lists → fail (no-op spends gas for nothing; make it explicit).
- any amount `<= 0.0` → fail.
- amount precision > 12 → fail.
- `sender` in the receiver list (self-pay) → fail or net-zero; recommend **fail** for clarity.
- **duplicate receivers** in one call → DECIDE (see §11): either reject, or sum duplicates before crediting. The pool won't emit duplicates, but the primitive must define behavior — silent double-credit is the dangerous default.
- insufficient sender balance for `total` → fail atomically (debit guard handles it).
- recipient guard mismatch on an existing account in the create variant → fail (don't overwrite).
- `total` overflow/precision: fold of many 12-dp decimals stays exact in Pact decimals; no float — confirm.

---

## 8. Atomicity note

A bulk tx is **all-or-nothing**: any failing line aborts the whole batch. For a **pre-validated, caller-built list** (the pool's case — all recipients verified, all amounts positive whole-STOA payables, `total ≤ on-chain pot`) this is the desired property and there is no realistic in-batch failure. Document that callers MUST pre-validate; the function is not the place to "skip bad rows".

---

## 9. Pact REPL test matrix

Write `coin`-style REPL tests (`(env-data …)`, `(env-sigs …)`, `(expect …)`, `(expect-failure …)`):

**Happy path**
- pay 3 existing accounts, assert each balance += its amount and sender -= total.
- `transfer-create-bulk` to 3 NEW k: accounts (derived keysets), assert created + funded.
- mixed run: `transfer-bulk` to existing + `transfer-create-bulk` to new in the same tx batch (two function calls), conservation holds.
- scale: 500–1000 recipients in one call; record gas (sanity vs 2M block limit).
- fee-as-last-line: include a PoolSavings-style receiver as the (n+1)-th line; assert it's credited and folded into `total`.

**Capability**
- signing `TRANSFER_BULK(sender, total)` succeeds; signing for `total - epsilon` **fails** ("exceeds authorized").
- no `TRANSFER_BULK` sig → fail.
- wrong sender guard → fail.

**Validation / security**
- length mismatch → fail.
- empty lists → fail.
- a `0.0` amount anywhere → fail.
- a negative amount → fail.
- a 13-dp amount → precision failure.
- self-transfer (sender in receivers) → fail.
- insufficient balance (`total` > sender balance) → fail, **no partial credit** (assert all balances unchanged).
- existing account + mismatched guard in create variant → fail.
- duplicate receiver → asserts the chosen §11 behavior.
- conservation: Σ deltas == 0 across every passing test.

---

## 10. How the caller (the pool hub) will use them

The hub (off-chain) builds, signs (codex coinbase key), and submits — the function only needs to accept the lists. Intended call shape (illustrative; the agent designs the function, the hub adapts):

```
;; existing recipients (+ the PoolSavings fee line) — no guards
(coin.transfer-bulk COINBASE
  [ "k:worker1" "k:worker2" ... "k:PoolSavings" ]
  [ 9.93        12.40       ...  7.07 ])         ;; nets… + summed fee

;; new recipients — derived k: guards
(coin.transfer-create-bulk COINBASE
  [ "k:newminer1" ... ]
  [ (read-keyset 'ks1) ... ]
  [ 4.50 ... ])
```

Signed with `(TRANSFER_BULK COINBASE <total>)` capability scoped to the exact summed total of that call. Same-chain only (chain 0) — cross-chain aggregation is a separate concern handled by the hub before this runs.

---

## 11. Open decisions for the implementer (flag, don't guess)

1. **Duplicate receivers:** reject vs sum-then-credit. (Recommend **reject** — simplest, safest; callers dedupe.)
2. **Recipient-binding hardening:** ship v1 with budget-only `TRANSFER_BULK(sender,total)`, or also bind a `(hash [receivers amounts])`? (Recommend budget-only v1; offer bound variant later.)
3. **Return value shape:** count + total string, or a list of per-recipient results? (Recommend a compact summary string — per-recipient lists bloat gas/output.)
4. **Max batch length cap:** enforce a hard `(enforce (<= (length receivers) MAX) …)` to keep a single tx under the block gas limit, or leave it gas-bounded only? (Recommend a generous explicit cap, e.g. 5000, so an over-large list fails fast instead of burning gas to an out-of-gas abort.)
5. **Event emission:** emit one `TRANSFER` event per line (explorer-friendly, more gas) or a single `TRANSFER_BULK` event? (Recommend a single bulk event + assess explorer support.)

---

## 12. Scope boundary (so expectations are right)

These functions solve the **same-chain batched payment** only. They do **not** address cross-chain aggregation — moving the coinbase's balance from chains #1–#9 onto chain #0 before payout. That is irreducibly ~18 transactions (9 `transfer-crosschain` burns + 9 SPV continuations) because a transaction cannot span source chains, and is orchestrated off-chain by the hub. `transfer-bulk` is the final, single-tx payment step that runs after aggregation settles on chain 0.

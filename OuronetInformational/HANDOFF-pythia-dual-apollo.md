# HANDOFF — Pythia dual-Apollo: Pact contract + service

**Target repos:** the `PYTHIA` Pact module (stoa-js / on-chain), and the Pythia
API service (off-chain). **Read `DUAL-APOLLO-CONSUMER-IDENTITY.md` first** — this
doc implements §2–§8 of it.
**Prereq:** the existing deploy surface from
`HANDOFF-codex-apollo-activation-ui.md` §2 (`PYTHIA|C_DeployApiKey`,
`A_DeploySmartApiKey`, `INFO_DeployApiKey`).

---

## PART A — On-chain (PYTHIA Pact module)

### A1. Drop the admin gate on the smart deploy (D1)
`PYTHIA|A_DeploySmartApiKey` currently enforces `GOV|PYTHIA_ADMIN` →
`ouronet-ns.dh_master-keyset`. **Remove that governance requirement** so any user
can deploy a smart-form API key, exactly like the standard form. Rename to a
`C_`-form (`PYTHIA|C_DeploySmartApiKey`) or collapse both into a single
`C_DeployApiKey` that takes the curve/form as a parameter. Same 5 args as today
(`patron, owner-account, apollo-account, public, consumer-lane`).

**Safety rationale:** an unbound smart key is inert — it can do nothing until it
is bound (A2) to a slot whose owner controls it. The **binding is the gate**, so
no admin keyset is needed. Document this in the defun.

### A2. Pairing: immutable `consumer` field + `iz-active`
Extend the api-key registry row (schema of the table `C_DeployApiKey` writes) with:

| field | type | semantics |
|---|---|---|
| `consumer` | string | the **counterpart** Apollo public key (the other half). Set **once**, then **immutable** (enforce: fail if already set to a non-empty value). |
| `iz-active` | bool | `false` at deploy; `true` only after the pair is linked (A3) and ready. |
| `iz-revoked` | bool | `false`; set `true` by revoke (A4). Kept separate from `iz-active` so the immutable link survives. |

Primary key = the **Standard Apollo** (the slot). Provide a read that resolves
**consumer → slot** too (reverse lookup) — either a second table or an indexed
select — because auth arrives as "consumer signs" (see B2).

### A3. `C_BindConsumer` (or fold into deploy) — the pairing tx
A capability/defun that links `(standard, consumer)`:
- Signed by **both** the standard-slot key **and** the consumer key (mutual
  attestation — no admin).
- Sets `consumer` (immutably) and flips `iz-active = true`.
- Idempotent-guard: fail if `consumer` already set or `iz-revoked`.
- Emits an event (for the service's fast-lane, B3).

Do the register (A1) + bind (A3) **atomically or before S is exposed**, so no one
can bind their own C to your S in the gap.

### A4. `C_RevokeApiKey` — owner-signed revoke (D2, D5)
- Signed by the **owner** (who holds both halves): accept a signature from the
  standard-slot key (and/or the consumer key).
- Sets `iz-active = false`, `iz-revoked = true`. **Does NOT clear `consumer`** —
  the link stays immutable; only the status changes.
- Emits a **revoke event** (fast-lane signal, B3). After revoke, the owner mints
  a fresh `S'`/`C'` pair and binds anew (a new row; the old one stays dead).

### A5. Read/INFO functions the service needs
- `URC_ApiKeyByConsumer(consumerPub)` → `{ standard, consumer, iz-active,
  iz-revoked, lane, ... }` (the auth-path lookup).
- `URC_ApiKeyBySlot(standardPub)` → same shape (owner/status views).
- `URC_RevocationEpoch()` → a cheap monotonic counter or a compact
  revoked-set/merkle-root that bumps on every revoke — the **fast-lane** read
  (B3). Keep it O(1) to read frequently.

---

## PART B — Off-chain (Pythia API service)

### B1. Local table (mirror of on-chain, for zero-chain-read auth)
Keyed by standard Apollo, with a reverse index on `consumer`:
```
api_key_binding(
  standard_pub    TEXT PRIMARY KEY,
  consumer_pub    TEXT UNIQUE,      -- reverse-lookup index
  iz_active       BOOLEAN,
  iz_revoked      BOOLEAN,
  lane            TEXT,
  cached_at       TIMESTAMP,        -- drives the daily-refresh timer
  next_refresh_at TIMESTAMP
)
```

### B2. Auth flow (per session/call — ZERO chain reads) (D4, §6)
1. Caller: "I'm consumer `C`, serve slot for me."
2. Pythia: issue **challenge** = fresh nonce + request-bound payload (method,
   params, timestamp, short TTL).
3. Caller signs the challenge with **C's private key**; sends `{request, sig}`.
4. Pythia: look up `consumer_pub = C` in `api_key_binding`; **verify sig against
   the cached `consumer_pub`** (Ed25519/whatever the curve is); require
   `iz_active && !iz_revoked`; reject reused nonce.
5. Pass → serve + meter under `(standard_pub, C)`.

**Never** authorize on an *asserted* identifier (a pubkey in a header) — always
the signed challenge. This is the whole security hinge (§6).

### B3. Cache freshness (D4, §5)
- **Binding + pubkey:** refresh from chain **once/day** per slot
  (`URC_ApiKeyBySlot` / `URC_ApiKeyByConsumer`). Surface `next_refresh_at` so the
  UI can show a per-slot **"next update in HH:MM"** timer.
- **Revocation:** poll `URC_RevocationEpoch()` on a **short interval (minutes)**
  or subscribe to revoke events; on change, immediately re-pull affected rows and
  flip `iz_revoked`. This makes a compromised pair die in minutes, not 24h.
- Per API call touches **only the local table** — no chain read.

### B4. Metering / attribution
Meter usage under `standard_pub` (the slot / billable unit). `consumer_pub`
confirms *which* consumer; `lane` is the human label.

---

## Test / acceptance checklist
- Smart deploy works with **no** admin keyset present (A1).
- `consumer` cannot be overwritten once set (A2 immutability).
- Bind requires **both** signatures; single-sig bind fails (A3).
- Revoke flips `iz-active=false`, keeps `consumer` (A4); a fresh pair binds fine.
- Service auth **rejects** a request that only *asserts* C's pubkey without a
  valid signature (B2, the hinge).
- Revoked pair stops working within the fast-lane interval, not a day (B3).
- Per-call path issues **zero** chain reads (B2).

## Open questions (confirm with owner)
- Signature curve/verify lib for the Apollo pubkey on the service side.
- Revocation fast-lane: polled epoch vs event subscription (B3).
- Exact FQN/module path of the deploy + read functions (mirror StoicTag
  resolution, per the activation handoff §2).

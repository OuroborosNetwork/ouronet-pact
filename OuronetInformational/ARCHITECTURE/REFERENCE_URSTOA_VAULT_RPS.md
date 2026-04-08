# Reference — UrStoa Vault (Stoa `coin.pact`)

_Source: `00_StoaSandbox/coin.pact` — UR-STOA submodule (~L909), UrStoa Vault submodule (~L1193). Chain 0 only for UR / vault ops._

This is the **canonical RPS stake-pool pattern** to mirror when completing Stage 2 **AQP**.

## Structure inside `coin`

1. **STOA** — main fungible coin.
2. **UrStoa** (~L909) — second token (1M genesis), `UR|StoaTable`, transfers; **cannot** send UrStoa to the vault address except via **Stake** (enforced in `X_UR|TRANSFER`).
3. **UrStoa Vault** (~L1193) — reward pool + RPS index + per-user state.

## Vault table (single row, key `USV` = `"UR-Stoa-Vault-Key"`)

| Field | Role |
|-------|------|
| `urstoa-supply` | Total UrStoa locked in vault — **global score** (denominator for RPS increments). |
| `stoa-supply` | Total STOA sitting in vault as **claimable** rewards. |
| `nzs-count` | Count of users with **non-zero** stake (`user-supply` > 0). |
| `current-rps` | Global cumulative **reward per unit score** (RPS). |
| `unclaimed-count` | Users who still have something to claim (see stake/unstake/collect). |

## User table (`URV|UrStoaVaultUser`, key = account)

| Field | Role |
|-------|------|
| `user-supply` | User’s UrStoa in vault — **user score**. |
| `last-rps` | RPS snapshot after last **sync** (stake / unstake / collect). |
| `pending-rewards` | STOA **banked** before score changes; refreshed via `URC_AvailableRewards`. |

## RPS (reward per share)

On **inject** of `stoa-amount` STOA:

- `gained-rps = floor(stoa-amount / vault-score, STOA_PREC)` where `vault-score = urstoa-supply`.
- `new-rps = current-rps + gained-rps`.
- Vault `stoa-supply` increases by `stoa-amount`.

**Accrual** for a user (in `URC_AvailableRewards`):

- `diff-rps = current-rps - last-rps`
- `gained = floor(user-supply * diff-rps, STOA_PREC)`
- Claimable = `pending-rewards + gained`

So each unit of global stake earns proportionally: **STOA injected** is spread as a delta to `current-rps` per unit of total UrStoa staked.

## Dust-proof collect (`URC_URV|ClaimableRewards`)

If **`unclaimed-count == 1`** and computed `available > 0`, the user receives **`stoa-supply` (full vault STOA)** instead of the rounded formula — avoids **dust** trapped by `floor` across many stakers.

## Four client actions

| Action | Role |
|--------|------|
| **Inject** | Move STOA into vault; bump `current-rps` and `stoa-supply`. Requires `urstoa-supply > 0` (`URV|INJECT`). |
| **Stake** | Move UrStoa user → vault konto; refresh pending; bump scores; if first time from 0 stake, bump `nzs-count` and `unclaimed-count`; set `last-rps` to current vault RPS. |
| **Unstake** | Refresh pending; move UrStoa vault → user; shrink scores; if user score hits 0, adjust `nzs-count` and possibly `unclaimed-count`; sync `last-rps`. Enforces **≥ 1.0** UrStoa remains in vault when unstaking (so global score never goes to zero while vault is used). |
| **Collect** | Pay out claimable STOA (`C_Transmit` vault → user); reset `pending-rewards`; adjust `unclaimed-count` when `user-supply` is 0; sync `last-rps`; reduce vault `stoa-supply`. |

## Two inject variants (`XI_URV|Inject`, flag `coinbase`)

| Variant | Transfer | Use |
|---------|----------|-----|
| **Normal** `C_URV|Inject` | `C_Transfer` (managed) | Injecting account can scope caps / pay gas in the usual way. |
| **Coinbase** `C_URV|CoinbaseInject` | `C_Transmit` (unmanaged) | Miner path: **no** requirement that the mining account pays gas the same way; used when wiring **block emission** into the vault. |

## Genesis bootstrap (`XM_InitialiseUrStoaVault`)

Vault starts with **1.0** UrStoa supply and **1.0** to foundation user so **`vault-score > 0`** before any external stake — injections and RPS math are always defined.

## Invariants (carry into AQP)

1. **Inject needs a positive global stake** — RPS increment is `injection / total_staked`; if total staked is 0, injection is undefined / forbidden. In UrStoa Vault this is enforced by `URV|INJECT` (`urstoa-supply` must be **> 0**).
2. **Minimum residual stake** — `C_URV|Unstake` enforces **at least 1.0 UrStoa** must remain in the vault (`vault-remaining >= 1.0`), so the pool never goes to zero stake while the system is in use.

**AQP implication:** each pool needs the same idea — **do not allow unstaking the last unit of stake** (or equivalent rule) if you want **continuous injectability**; otherwise **inject** must be rejected when `total_stake == 0`.

## AQP mapping (preview)

AQP pools should reuse this **vault + user schema + RPS + pending + nzs/unclaimed + dust rule** pattern, adapted to Ouronet modules, asset types, and admin inject rules. **Preserve the non-zero stake + minimum residual stake semantics** unless a different bootstrap is explicitly designed.

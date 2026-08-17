# Pact storage patterns — list-in-a-row vs entries-with-select

When you need "the set of X for key K" (and later must read that set back), there are exactly **two**
ways to store it in Pact, with opposite cost profiles. Choosing wrong puts an unbounded scan on a hot
path — or bloats a hot row. This is the rule of thumb, learned the hard way.

## The two patterns

**(1) List in a single row** — store the whole set as one `[…]` column on one row, keyed by K.
- **Read:** one **point read** returns the whole set. Cheap, bounded by the set size.
- **Write (add/remove):** read-modify-write the **whole** row → cost grows with the set size.
- Pact (de)serializes a **whole row** as a unit, so a big list makes *every* read/write of that row cost O(list).

**(2) One entry per element** — store each element as its own row, keyed by `(K, element)`.
- **Write (add/remove):** O(1) — insert/delete one small row.
- **Read the set back:** you must **`select`/`keys`** (a table scan) to collect the elements → heavy.

## Which to use

| Situation | Use | Why |
|-----------|-----|-----|
| Set is **bounded and small**, and expected to stay small | **(1) list-in-a-row** | reads are one cheap point read; the whole point is to avoid a scan on the read path |
| Set can grow to **hundreds / thousands+** | **(2) entries + `select`** | a huge list-in-a-row makes every read/write of that row expensive; `select` is the right tool for genuinely large sets (and is effective in Pact 5.4) |

## Two hard riders

1. **If you pick (1), give it its own table.** Don't co-locate a growing list on a row that's read for
   *other* reasons — every unrelated read of that row would then deserialize the list. Segregate the
   list into a dedicated table so only the path that needs it pays. *(Example: `SCR|T|NF|TraitKeys` was
   split out of `SCR|NF|DefRevision` so the hot revision-nonce reads stay lean.)*

2. **`select` / `keys` must stay OFF the execution path.** Per `StoicSyntax.md` §10.2, a scan (`URH_`/
   `URHC_`) may not sit inside a `defcap` / `C_` / `CC_` / `X` / writer on the gas-metered path. So (2)
   is fine only when the *read* happens off-path (UI, admin, or a **paginated** client flow that
   deliberately processes a large set — vacate, sweep, collect). If a bounded-small set is being
   `select`ed on a per-tx path, that's pattern (1) done wrong — convert it to a list-in-a-row.

## Worked example — the model-1 NF trait fix (#FP0)

Scoring a staked NFT by its traits needs *"which trait-keys have definitions for this (score,dpnf)?"*.
Pact can't enumerate a nonce's metadata-object keys, so the code originally answered this with a
**`select` over the whole trait-def table on every stake** — pattern (2) on a hot path, wrong, because
the trait-key set is **bounded-small** (a collection's trait schema, ≈7).

Fix = pattern (1), segregated: a dedicated `SCR|T|NF|TraitKeys` row (keyed `score-id|dpnf-id`) holds the
distinct defined trait-keys, distinct-appended at definition-issuance (off-path). At stake, one point
read yields the keys, then bounded point reads score them. No scan on the stake path.

**Contrast — where (2) is correct here:** vacate / sweep / collect scan the *staker* set, which is
genuinely large and unbounded, and they do it **paginated** through client defpacts. Those keep `select`
— that's pattern (2) used correctly for a large set.

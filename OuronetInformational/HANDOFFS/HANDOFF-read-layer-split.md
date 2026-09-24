# HANDOFF — splitting the read layer, and an ids registry

Owner directive, 2026-09-24. Written to be picked up cold.

## Why

`DPL-UR` is **one module, 71 public reads, 2,919 lines, 211,588 gas to deploy.** Every UI page
reads through it. That has three consequences the owner named:

1. **It will not fit.** The reads needed for the pages that exist are already most of a module;
   the pages still to come cannot be added. StoaChain allows ~2M gas per transaction, and DPL-UR
   alone is ~11% of a block *today* with none of the Explorer's reads in it.
2. **Every change redeploys everything.** Adding one field to the dashboard header reruns a
   211k-gas transaction carrying 70 functions nobody touched.
3. **Blast radius.** The 2026-09-24 outage took out *all 26* reads the UI makes, because they
   live in one module whose modrefs stopped binding. A per-page module would have taken out one
   page.

## Shape

```
2_CITIZEN/Stage_Z/
  READS_UI/            one module per UI surface
    01_RD-HEADER.pact      dashboard top strip        (URC_0001_HeaderV3)
    02_RD-WALLET.pact      primordials / balances     (URC_0002_*)
    03_RD-POOLS.pact       SWP pages                  (URC_0003..0005, 0010, 0011, 0014, 0015)
    04_RD-TOKENS.pact      TF + OF pages              (URC_0008*, 0009*, 0016..0020)
    05_RD-COLLECT.pact     collectables               (URC_0021..0026)
    06_RD-ACCOUNTS.pact    selectors / overview       (URC_0027*, 0028*, 0029)
    07_RD-ELITE.pact       elite panel + rich list    (URC_0032, 0035)
    08_RD-LAUNCH.pact      StoicPay / ICO             (URC_0013, 0030)
    09_RD-PYTHIA.pact      Apollo / dual-link         (URC_0031, 0033, 0034)
  READS_EXPLORER/      same idea, per explorer page
```

**One interface per module**, each complete (the V7..V13 lesson: an interface declaring one
function is a changelog, not a contract). Name them `ReadsHeaderV1`, `ReadsPoolsV1`, ….

### Rules that fall out of this round

- **A read module owns NO tables.** It is a projection over sovereign state. This is what lets
  a read module be redeployed freely: nothing is lost because nothing is stored.
- **No hardcoded entity ids.** Derive, or take from the ids interface below. Gate-enforced by
  `REPL/tools/_hardcodedids.py`.
- **Never scan another module's table in a function a UI calls** unless the same call already
  works live. `(keys OTHER.Table)` is admin-gated in transactional mode and only permitted in
  `/local` on a node started with `--allowReadsInLocal`. DPL-UR does this in five functions and
  it works today — but it is a node-configuration dependency, not a Pact guarantee, and it
  should be an explicit decision per function rather than an accident.
- **Every module needs at least one REPL assertion that CALLS its reads.** The outage happened
  in two functions that had never once executed in a test, because their hardcoded mainnet ids
  do not exist in a sandbox. A read module with no executing test is a read module whose
  staleness is invisible until a user hits it.

### What happens to DPL-UR

It stays deployed — a Pact module cannot be removed — and becomes a **stub**, per
`StoicSyntax-Prefixes.md` §7.21 archive mode: keep the reads that have not moved yet, delete
nothing that anything still calls, and point the `@doc` at the replacements. Migrate page by
page; the UI can call old and new side by side during the move.

## The ids interface

Owner directive: *"an interface holding as constants all the important token IDs, so we won't
have to guess them."*

`1_SOVEREIGN/STAGE_01/0_Interfaces/` → `OuronetIdsV1`, a **constants-only interface**.

```pact
(interface OuronetIdsV1
    (defconst ID_OURO        "OURO-8Nh-JO8JO4F5")
    (defconst ID_IGNIS       "GAS-8Nh-JO8JO4F5")
    (defconst ID_AURYN       "AURYN-8Nh-JO8JO4F5")
    (defconst ID_ELITEAURYN  "ELITEAURYN-8Nh-JO8JO4F5")
    (defconst ID_WSTOA       "WSTOA-8Nh-JO8JO4F5")
    (defconst ID_SSTOA       "SSTOA-8Nh-JO8JO4F5")
    (defconst ID_GSTOA       "GSTOA-8Nh-JO8JO4F5")
    (defconst ID_HGSTOA      "H|GSTOA-8Nh-JO8JO4F5")
    (defconst IDX_AURYNDEX   "Auryndex-O136CBn22ncY")
    (defconst IDX_EAURYNDEX  "EliteAuryndex-O136CBn22ncY")
    (defconst IDX_SILVER     "SilverStoaPillar-O136CBn22ncY")
    (defconst IDX_GOLDEN     "GoldenStoaPillar-O136CBn22ncY")
)
```

**This is deliberately still hardcoded, and that is the point.** These ids are facts about
mainnet, not things a sandbox can produce. What was wrong before was not that they were
literals — it was that there were **forty-plus copies of them**, scattered across two repos,
with no single place that is authoritative. One registry, one place to correct, and a UI that
imports instead of guessing.

Two things to decide before writing it:

- **Interface or module?** An interface's `defconst` must be a literal, which is what we want
  here. A module could COMPUTE them at load (`(defconst ID_OURO (DALOS.UR_OuroborosID))`) and
  be self-correcting — but that freezes the value at deploy time and makes the module
  undeployable against a chain where a token is missing. Prefer the interface; take the
  literals.
- **Values must be READ FROM CHAIN, not copied from this file.** Everything here came from
  source that predates the redeploy. Confirm each with a dirty read before shipping — the whole
  purpose of this interface is to be the thing nobody has to double-check afterwards, and it
  earns that only if it is right on day one.

## Open, blocking the dashboard

`Deploy/2_Init/00_MANUAL_probe-dashboard.pact` — layered dirty reads, L0..L7. The live suspect
is **L2**: `UR_RewardToken` / `UR_RewardBearingToken` read a reverse index whose unset value is
`["|"]`, not `[]`, so an unpopulated index does not abort — it leaks a BAR into
`ATS::URC_Index` and fails several frames away. If that is what happened, the hardcoded pair
ids were working AROUND an empty index, and the ids interface above is the fix rather than a
tidy-up.

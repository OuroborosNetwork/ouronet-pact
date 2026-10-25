# Deploy/PureV13 — per-lane injection floor + the AQP interface cascade + the DPL-UR stub

**13 transactions, STRICT ORDER, 01 through 13.** Work down the list. Do not reorder, do not
skip, and do not send 05 out of position — see **THE ONE ORDERING RULE** below.

> **Verified 2026-10-24:** `python3 REPL/tools/_livesandbox.py --round Deploy/PureV13` reports
> `ROUND OK -- 13 transaction(s) composed clean against live content`, replayed against a
> virtual chain built from the REAL DEPLOYED SOURCE of 136 live `ouronet-ns`
> modules/interfaces. That is a composition proof, not an authorisation one — see
> `OuronetInformational/SPEC-round-simulator.md` §S5 for exactly what it does and does not show.

## Why 12 and not 24

`Deploy/MANIFEST.md` plans **24 transactions / 79 modules**, because it is a FROM-SCRATCH
planner: it builds a virgin chain and has no notion of what is already live. This round changed
**15 modules**, so 12 transactions carry all of it. Sending the full 24 would also be correct —
it would redeploy ~64 unchanged modules for roughly 5M gas of nothing.

The 15 that changed are exactly the files naming an interface this round bumped:

```
00_AQP-SCHEMAS  01_ANK  02_SCORE  03_AQP  04_RPS  05_FVT  06_VCT  07_MTX-AQP  08_DSA
09_AQP-INFO  04_TS02-C3  04_AQP-BOOT  03_DSP+  13_O-UI-THIRTEEN  14_O-UI-FOURTEEN
```

## The round

| # | file | what it carries |
|---|---|---|
| 01 | `01_deploy.pact` | `00_Demipad`, **`00_AQP-SCHEMAS`**, **`01_ANK`** |
| 02 | `02_deploy.pact` | **`02_SCORE`** |
| 03 | `03_deploy.pact` | **`03_AQP`** |
| 04 | `04_deploy.pact` | **`04_RPS`** |
| **05** | **`05_backfill.pact`** | **the schema backfill — MUST run here, not later** |
| 06 | `06_deploy.pact` | **`05_FVT`** |
| 07 | `07_deploy.pact` | **`06_VCT`**, **`07_MTX-AQP`**, **`08_DSA`** |
| 08 | `08_deploy.pact` | **`04_TS02-C3`**, **`09_AQP-INFO`**, `05_TS02-DPAD` |
| 09 | `09_deploy.pact` | **`04_AQP-BOOT`** |
| 10 | `10_deploy.pact` | **`03_DSP+`** |
| 11 | `11_deploy.pact` | **`13_O-UI-THIRTEEN`** (AppReads) |
| 12 | `12_deploy.pact` | **`14_O-UI-FOURTEEN`** (AppReads) |
| **13** | **`13_deploy.pact`** | **`01_DPL-UR`** — the archive-mode stub (MODULE-ONLY, no `implements`) |

`01` also redeploys `00_Demipad`, which did not change — it shares a transaction with
`00_AQP-SCHEMAS` in the generated plan. Harmless; an unchanged upgrade just costs its gas.

`11` and `12` are hand-authored. The generated planner cannot emit them: it globs the
`deploy-stage0*.repl` loaders and AppReads modules load from `modules/APPREADS-OuronetUI.repl`
instead. `MANIFEST.md` flags this under *"Modules that must redeploy but are in no deploy
chain"*. They are carried here so the round is complete in one folder rather than complete only
if someone reads that warning.

## 13 — DPL-UR: A ONE-TOKEN CASCADE FIX

**Corrected 2026-10-24 by measuring the chain.** An earlier draft of this section said the
chain still runs "the original 3,025-line DPL-UR" and that the stub "was never deployed."
**Both were false.** Live DPL-UR is already the archive-mode stub: 76 lines, three defuns
(`GOV|Demiurgoi`, `CT_Namespace`, `CT_Bar`), zero `implements`. The stubbing shipped.

What did not ship is a cascade. After the stub went out, DALOS bumped `OuronetDalosV2` →
`OuronetDalosV3`, and DPL-UR was missed. It still declares:

```pact
(ref-DALOS:module{OuronetDalosV2} DALOS)
```

while live DALOS implements only `OuronetDalosV3` (plus `OuronetPolicyV2`). The live and repo
sources differ in **exactly one token**.

### The interface is not missing — it has no implementor

`OuronetDalosV2` is still deployed and always will be; a deployed interface is never removed.
`module{I}` is a type whose only inhabitants are modules declaring `implements I`, and the
cascade rule has implementing modules carry only the **latest** version. So V2 is a present,
permanently uninhabited type, and any modref naming it cannot bind:

```
Runtime typecheck failure, argument is modref, but expected type module{ouronet-ns.OuronetDalosV2}
```

DALOS *is* a modref. It is just not that one.

### Why it matters even though the module does nothing

The failure is at **bind** time, so the module is unusable on chain rather than merely empty —
and it is a live trap for anyone browsing the namespace. It is also how it was found: the round
simulator must exclude DPL-UR to build a working sandbox, and it reports every exclusion.

This is the cascade rule's whole point, demonstrated: **a module that drops out of a cascade does
not fail at bump time, it fails later, at bind time, and silently until something touches it.**

Position: **last.** `Stage_Z` citizen module, reads sovereign state, independent of 01–12 — so a
failure here cannot affect them.

## THE ONE ORDERING RULE

**`05_backfill.pact` goes between `04` (RPS) and `06` (FVT). Not at the end.**

This round added `min-inject-amount` to `FVT|RPS|Global`. Lanes created from now on are born
carrying the 1.0 default; every lane written BEFORE this round has no such field, and 05 is what
gives them one.

- **After 04**, obviously — `AA_MigrateMinInject` does not exist until RPS is live.
- **Before anything else touches a lane**, less obviously and more dangerously.
  `UR_FVT-RG|RpsGlobal` does a FULL `read` binding every schema field, the new one included. So
  the first inject / collect / stake / stream against an un-migrated lane faults on a missing
  key — a raw table error, not a clean refusal. There is no degraded middle state: lanes are
  either migrated or unusable.
- **Before any owner sets a custom floor.** 05 writes the default UNCONDITIONALLY, because Pact
  will not let it ask whether a typed field is absent on a row. Re-running after a partial run
  is safe; re-running after an owner has raised their floor silently resets it to 1.0.

Signer: `GOV|RPS_ADMIN` (the Demiurgoi keyset), same as any RPS admin op.

## What this round contains

**The feature.** A per-lane floor on a single injection, owner-settable, defaulting to 1.0.
`CC_Inject` runs its stale-fix loop regardless of `amount` — the loop never reads it — so
`> 0.0` was never a floor in any useful sense: one smallest unit bought a full force-fix of an
entire present membership. New surface: `UR_FVT-RG|MinInjectAmount`,
`WU_RpsGlobal|MinInjectAmount`, `XI_`/`XE_SetMinInjectAmount`, owner-gated
`C_SetMinInjectAmount` (61 IGNIS), Talos wrapper `AQP-FVT|C_SetMinInjectAmount`,
`AA_MigrateMinInject`, and `XE_XI_FixUserFvtDebIn` (the hoisted non-penalized bulk fixer).
Enforcement is one `enforce` in `UEV_InjectContext`, which covers `CC_Inject`,
`CC_InjectStream` and `CC_InjectFinalize` at once. `C_AddRewardLink` is untouched.

**The cascade.** 60 files, 1,484 references, eight interfaces bumped in lockstep:

```
AcquisitionSchemasV1 -> V2          AcquisitionScoresV3  -> V4
AcquisitionAnchorsV2 -> V3          AcquisitionPoolsV2   -> V3
AcquisitionRewardPerShareV2 -> V3   AcquisitionVacateV2  -> V3
AcquisitionFarmsVaultsTreasuriesV2 -> V3   DsaV2 -> V3
```

**Also in this round** (shipped earlier, same working tree): the forced-fix payer rule — a
forced fix records its IGNIS penalty only when the FVT's OWN OWNER caused it. A stranger funding
someone else's aggregator repairs the membership at no cost to its members. Applied at both
permissionless inject paths: `CC_Inject`, and all three fix sites of `MTX|2|C_Inject`.

## Verified, and NOT verified

- **Gate green** at 28,537 assertions with the round in place (`python3 REPL/tools/_gate.py`).
- **Pinned by test**: `[6.2.7] <<TX-AQP-DEB16>>` (default on a pre-existing row, dust refused,
  boundary refused, owner raise binding, zero rejected as a floor) and `<<TX-AQP-DEB15c>>` (the
  payer rule — member comes out FRESH *and* unbilled).
- **NOT verified: `05_backfill.pact` itself.** The REPL creates its tables fresh from the
  current schema, so a row that predates a field is not reproducible there — the exact condition
  the backfill exists for cannot be constructed in the harness. Its logic is argued in its own
  header, not executed. A testnet chain carrying pre-round lane rows is the only thing that
  actually proves it.
- **Gas figures are REPL figures** (`env-gasmodel "table"`), excluding per-transaction overhead
  and signature verification. The largest transaction here is `04_deploy.pact` at 318,509 bytes
  against a ~320 KB practical ceiling, so confirm on testnet before mainnet.

## Known consequence worth a decision

`STREAM_MIN_UPS` is now **structurally unreachable for high-precision tokens**. At 24 decimals
the rate guard triggers below ~3.15e-10, while the new floor is 1.0 — about nine orders of
magnitude apart. It remains live for low-decimal tokens (at 12 decimals the trigger is amount
< 315.4) and for lanes whose owner has dropped the floor into dust territory. Keep it as a
low-decimal backstop, or retire it as superseded — but it is no longer doing the work its name
suggests.

# A5 Rename Proposal — StoicSyntax sweep #90 (owner approval gate)

Every function below currently blocks the reorder tool (no canon prefix → `UNCLASSIFIED`).
Renames are **owner-gated** — nothing here is applied until you approve. Classifications
(`XI`/`XE`/`XB`) come from whole-repo call-site evidence (internal-only → `XI`; external
callers only → `XE`; both → `XB`). Suffix/scope forms follow §2.1: `PREFIX_MODULE|Name`.

Green-gate after each batch: `cd REPL && ~/.local/bin/pact Z.repl` (0 FAILURE + Load).

---

## Batch 1 — `X_` → `XI_` by reach (no external callers found)

| File | Current | → Proposed | Reach evidence |
|---|---|---|---|
| 10_ATSU | `X_KickStart` | `XI_KickStart` | only C_/A_KickStart internal (ATSU L798/808); not in any interface |
| 10_ATSU | `X_RemoveSecondary` | `XI_RemoveSecondary` | only C_/A_ internal (ATSU L626/636); **heavy** (`ref-ATS::URH_ExistingAutostakePairs`) |
| 00_Demipad | `X_TransmitCollectables` | `XI_TransmitCollectables` | only internal Demipad L1284/1291; not in any interface |

> Note (follow-up, not a rename): `X_RemoveSecondary` is heavy — confirm its `C_`/`A_`
> callers are already the doubled `CC_`/`AA_` heavy variants. (Flag only.)

## Batch 2 — DPDC unprefixed / malformed

| File | Current | → Proposed | Kind / evidence |
|---|---|---|---|
| 01_DPDC-UDC | `C` | `UDC_DPDC\|AllowedClassForSetPosition` | object constructor; **interface-declared** (DpdcUdcV1) + cross-module callers |
| 01_DPDC-UDC | `N` | `UDC_DPDC\|AllowedNonceForSetPosition` | object constructor; interface-declared + cross-module callers |
| 01_DPDC-UDC | `S` | `UDC_DPDC\|Set` | object constructor; interface-declared + DPDC-S callers |
| 03_DPDC-C | `CreditOrDebitDPDC` | `XI_CreditOrDebitDPDC` | write; 0 external callers |
| 03_DPDC-C | `MappedCreditOrDebitDPDC` | `XI_MappedCreditOrDebitDPDC` | write; 0 external callers |
| 03_DPDC-C | `MappedUpdateOwnerNFT` | `XI_MappedUpdateOwnerNFT` | write; 0 external callers |
| 10_DPDC-N | `XI\|U_NonceMetaData` | `XI_NonceMetaData` | write; 0 external; fixes malformed `\|`→`_` (bogus `U`) |
| 08_DPDC-S | `URCX\|PSD_FirstNoncesList` | `UC_FirstNoncesFromPSD` | **no** table read → pure compute |
| 08_DPDC-S | `URCX\|CSD_NonceList` | `URH_NonceListFromCSD` | mapped per-element `UR_NonceOfSet` → **heavy** |

## Batch 3 — STOA-PID scope family (true prefix + `PREFIX_STOA-PID\|Name`)

| File | Current | → Proposed | Reach / kind |
|---|---|---|---|
| 17_SWPL | `URC\|STOA-PID_LpToIgnis` | `URC_STOA-PID\|LpToIgnis` | read+derive |
| 17_SWPL | `URC\|STOA-PID_TokenToIgnis` | `URC_STOA-PID\|TokenToIgnis` | read+derive |
| 17_SWPL | `URC\|STOA-PID_CLAD` | `URC_STOA-PID\|CLAD` | read+derive |
| 17_SWPL | `URCXX_D1forWP` | `URC_D1forWP` | compute (`XX` was a placeholder) |
| 17_SWPL | `XE\|STOA-PID_AddLiqudity` | `XE_STOA-PID\|AddLiquidity` | **external-only** (SWPLC/MTX-SWP callers); fixes spelling |
| 18_SWPLC | `C\|STOA-PID_AddStandardLiquidity` | `C_STOA-PID\|AddStandardLiquidity` | client entry |
| 18_SWPLC | `C\|STOA-PID_AddIcedLiquidity` | `C_STOA-PID\|AddIcedLiquidity` | client entry |
| 18_SWPLC | `C\|STOA-PID_AddGlacialLiquidity` | `C_STOA-PID\|AddGlacialLiquidity` | client entry |
| 18_SWPLC | `C\|STOA-PID_AddFrozenLiquidity` | `C_STOA-PID\|AddFrozenLiquidity` | client entry |
| 18_SWPLC | `C\|STOA-PID_AddSleepingLiquidity` | `C_STOA-PID\|AddSleepingLiquidity` | client entry |
| 19_SWPU | `XI\|STOA-PID_Swap` | `XI_STOA-PID\|Swap` | internal-only |
| 19_SWPU | `XI\|STOA-PID_OPU` | `XI_STOA-PID\|OPU` | internal-only |
| 01_U_CT | `UR\|STOA-PID` | `UR_STOA-PID\|Price` *(see Q1)* | interface-declared reader (DiaStoaPidV1) |

## Batch 4 — Citizen minter helpers

**Bloodshed** (per rarity module L/E/R/C — same shape):
| Current | → Proposed | Kind |
|---|---|---|
| `OrderMultiplier` | `UC_OrderMultiplier` | pure compute |
| `LegendaryOM`/`EpicOM`/`RareOM`/`CommonOM` | `UC_<Rarity>OM` | pure compute |
| `LS`/`ES`/`RS`/`CS` | `UC_<Rarity>Score` | pure compute |
| `LegendaryLink`/`EpicLink`/`RareLink`/`CommonLink` | `UC_<Rarity>Link` | pure compute (builds IPFS URL from consts — **not** a read) |
| `MD` | `UDC_MetaData` | object constructor |
| `L-x`/`E-x`/`R-x`/`C-x` | `UDC_<Rarity>ByPosition` | object constructor (position→MD dispatcher) |

**Bloodshed SETS:** `SetLink` → `UC_SetLink`; `N` → `UDC_AllowedNonce`; `C` → `UDC_AllowedClass`
(thin wrappers over the sovereign DPDC-UDC constructors renamed in Batch 2).
**A01_…A11_ (incl. A09a/A09b): already canon — NO rename.**

**Nosferatu / KBunnies:**
| Current | → Proposed | Kind |
|---|---|---|
| `N` | `UDC_MetaData` | object constructor |
| `NonceComputer` | `UC_Nonces` | pure compute |
| `NosferatuNonceDataMaker` | `UDC_NonceData` | object-list constructor |
| `NosferatuSpawner` / `BunnySpawner` | `C_Spawn` *(see Q2)* | wraps sovereign `DPNF\|C_Create` |
| `NosferatuFixer` | `C_Fix` *(see Q2)* | wraps sovereign `DPNF\|C_UpdateNonces` |

**CADUCEUS (+ duplicated in both minters):**
| Current | → Proposed | Kind |
|---|---|---|
| `GOV\|NS_Use` | `CT_Namespace` (constant) | namespace accessor |
| `GOV\|BridgeKey` | `CT_BridgeKey` (constant) | derived keyset-name |
| `GOV\|Demiurgoi` | **keep `GOV\|`-scoped** | genuine governance keyset ref |

---

## Cascade impact
- **Interface `DpdcUdcV1`** (Stage-2 02_Core.pact): rename `C`/`N`/`S` decls → callers in
  KBunnies, BSD-SETS, DPDC-S, 0_Sample. V1 is pre-mainnet → edit in place (no version bump).
- **Interface `DiaStoaPidV1`**: rename `UR\|STOA-PID` decl → many cross-module callers
  (Demipad, Spark/Snakes/Custodians/StoicPay, TS01-P/C3, IGNIS, SWPI, DPL-UR).
- All STOA-PID `XE_`/`C_` renames update SWPLC + MTX-SWP call sites.

## Open decision points
- **Q1 — `UR\|STOA-PID`:** you earlier said "STOA-PID should be CT functions." Its body is an
  oracle **read** (Dia price, currently a `0.1` stub), so true prefix is `UR_`. Proposed
  `UR_STOA-PID\|Price`. Prefer that, or a `CT_`-constant form? (It can't be a `defconst` —
  it's meant to call the Dia oracle.)
- **Q2 — Nosferatu/KBunnies `Spawner`/`Fixer`:** called only by internal `A_Step*` admin ops.
  `C_` (client-op semantics, wraps sovereign billed calls) vs `XI_` (internal-only helper)?
  I lean `C_` since they drive sovereign client billing, but they're not the citizen's public
  entry. Your call.

## Separate (non-rename) items surfaced
- **App bug (Bloodshed):** every rarity module has `(defconst MH3 Bloodshed.MH2)` — looks like
  a copy-paste error (should be `MH3`). Confirm before I touch it.
- **Cap-band markers:** 7 modules lack the full `{C1}–{C4}` skeleton (AQP-BOOT, INFO-ZERO,
  VCT = 0/4; PYTHIA, SWP, MTX-AQP = 2/4; AQP = 3/4) — marker-only insert, no reordering.
- **Interface-mirror reorder:** cosmetic-only, deferred (interfaces use per-module blocks, not
  the `{Fx}` skeleton).

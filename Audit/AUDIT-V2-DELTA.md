# AUDIT v2 — what changed, and what must be re-verified

The patron/executor/executee sweep changes the **client surface of every module**, so the
published audit has to be re-issued. This file is the bridge between v1 and v2.

**The facts are GENERATED, the judgement is WRITTEN.** `python3 REPL/tools/_auditdelta.py`
derives every changed entrypoint signature from git against the pre-sweep baseline
(`21fa54f`); it does not and cannot derive which assertions must be re-run or which v1 findings
are invalidated. That is what the per-module blocks below are for, and `--check` fails if a
module with a changed surface has no block. Neither half pretends to be the other.

## Cross-cutting, and true of every module

1. **Every `A_`/`C_` entrypoint gained `patron` and `executor`.** v1's attack register drives
   the client surface by position, so **every adversarial call site in the register has moved**.
   An attack that still passes without being re-pointed is passing on an arity error, not on the
   guard it names — the failure mode this sweep hit six times. Chapter *register* must be
   re-derived, not re-read.
2. **New ownership gates are ADDITIVE.** `_authsurface.py` is gate-fatal and reports 1,192
   entrypoints with **none weakened** across the whole sweep. The audit should state the
   direction: the sweep only ever *added* enforcement. Any claim of a loosened gate is
   falsifiable against that baseline.
3. **The executor binding is the new guard class.** `UEV_ExecutorIsKonto` /
   `…IsOwnerKonto` / `…IsParentKonto` / `…IsHotRbtOwner` bind the NAMED executor to the entity's
   owner. Ownership itself is still proven by the pre-existing capability; the binding stops the
   parameter being decorative. **Each needs an adversarial test that names a wrong-but-owned
   account** — ownership passes, the binding must refuse. That is a v2 attack family with no v1
   equivalent.
4. **`_callarity.py` is a new gate-fatal instrument** and belongs in Part IV. Its existence is a
   finding in itself: **Pact validates modref call arity at RUNTIME, not at load**, so a missed
   caller compiles, deploys and waits. v1 had no check for this.
5. **`_modulecomplete.py`** is how a module's turn is certified; the audit can cite it per module
   rather than re-deriving completeness.

---

### 00_DPMF.pact
**ARCHIVED, not swept.** 2,416 → 902 lines; 108 definitions removed, all three `implements`
dropped, own interface bumped `V7 → V8` (2 schemas + 53 readers).

- **v1 findings about DPMF's write surface are INVALIDATED** — that surface no longer exists.
  They should be marked superseded, not deleted: the code is still on chain.
- `CONF-06`'s claim narrowed. It asserted DPMF "is deployed with no storage at all"; that is
  proven only for a FRESH boot, because `create-table` fails when a table exists and an upgrade
  source therefore omits it. **Mainnet may hold rows. Unresolved without a live read.**
- Tree-wide **dead modref calls went 13 → 0**; all thirteen were inside DPMF.
- New instrument to document: `_archivemode.py`'s **governance-chain guard**, which refuses to
  leave a module unupgradeable.

### 01_DALOS.pact
18 entrypoints. Deploy ops are **patronless by design** — the account being created is the
executor, so there is no patron to name.
- `A_UpdatePublicKey` is the canon's first **indirect executor**: ownership is proven only by
  `GOV|DALOS_ADMIN`, deliberately, because it is the key-RECOVERY path. The `@doc` states it.
  **The audit must decide whether it accepts an indirect route here**; it is the one place the
  executor's ownership is not directly provable.
- Three v1 fixtures were re-pointed because the new gate **shadowed the gate under test**
  (`DALOS-G9`, `CONF-04`, `RT-C-001`). Any v2 fixture naming an executor must name one its own
  signer owns, or it proves nothing.

### 02_IGNIS.pact
The collectors left the `C_` band entirely: `C_Collect` → `XE_CollectIgnis`, `STOA|C_Collect*` →
`XE_`/`XB_CollectStoa*`, all behind `P|UEV_IMC`.
- **v1's "unbilled collector" attacks are re-based.** `RT-I`'s payload no longer exists.
- `RT-I` was **re-framed, not fixed**: its Case 3 is the *product* (25 IGNIS buys a sponsored
  arbitrary `let`), not a vulnerability. The audit must carry the corrected framing, and the
  **25-IGNIS floor** on transmuting the gas id — added because a free sponsored op with no floor
  drains the station.
- `C_DonateStoa` is a NEW client entrypoint; it has no v1 coverage.

### 04_BRD.pact
2 admin entrypoints. `GOV|BRD_ADMIN` is a **shared keyset**, so it proves admin-ness but not
*which* account acted — hence the executor's ownership is enforced in the defun. Same shape as
DALOS's admin band.

### 05_DPTF.pact
23 entrypoints, the widest blast radius: 183 reorders, 188 inserts, 61 nested compositor calls.
- **`C_Mint`/`C_Burn` are RENAMES, not additions** — the named account always was the executor.
  The owner's rule ("an executor cannot force an executee to mint or burn; to remove someone
  else's tokens you freeze then wipe") is a **structural invariant** and worth stating as one.
- `C_DeployAccount` → `XBv_DeployAccount`: it left the entrypoint band, so **`CONF-01`'s claim
  changed meaning**. The refusal was always `P|UEV_IMC`, never the `C_` prefix.
- **`Kursan/dsa-grand-tour.repl` carried a FALSE FINDING** for weeks: a 3-arg call to a 5-arg
  entrypoint returned a closure, the `expect-failure` was satisfied, and the block documented a
  "native error, cause not yet isolated". The cause was the arity. **The zero-royalty EXEC path
  is now an open question**, not a proven finding; only the PREVIEW bug survives.
- The price sheet's shape-B detector had been **silently degraded since module 2** (it grepped
  for the extinct `C_Collect`), so three entrypoints stopped naming their real cost reader.

### 06_DPOF.pact
19 entrypoints, plus the `XBv_DeployAccount` twin.
- The three transfers adopt the **owner ruling of 2026-09-21**: `sender` → `executor`,
  `receiver` → `executee` in the entrypoint signature; internals and caps keep the domain names.
  **TFT, DPTF and DPDC-T inherit this**, so the audit's transfer chapters change with them.
- `DPOF.URC_BrandingKonto` is new: the branding authority was being retyped at call sites and
  got retyped WRONG for derived entities. Worth citing as a duplication-of-fact defect.

### 08_ATS.pact
20 entrypoints, all pool-owner gated.
- **`HOT-RBT|C_Repurpose`'s capability does two jobs** that are easy to conflate: `CAP_Owner
  atspair` gates *which caller*, while the `ATS|GOV` it composes supplies *module* authority
  (the hot-RBT's DPOF owner is `ATS|SC_NAME`). Only the first is about the executor. v1's
  finding #5C touches this cap; v2 should record the distinction explicitly.
- Token ids (`reward-token`, `hot-rbt`) sit where a receiver would but are **entities, not
  accounts** — not executees. A reviewer reading positionally would get this wrong.

---

## Changed as a DOWNSTREAM CONSEQUENCE — not yet swept in their own right

These files have a changed client surface **because a module they call was swept**, not because
their own turn has come. Two distinct causes, and the audit should not treat them alike:

- **threaded `patron`** — a function that calls a swept entrypoint had no patron to pass, so it
  gained the parameter. Its own `executor` work is still pending. The signature is therefore
  **intermediate**: correct today, and it will change again at that module's turn.
- **forwarded call sites only** — a Talos wrapper or a citizen module whose arguments moved.

They are listed here so no auditor mistakes silence for "unchanged", and so the intermediate
signatures are not read as final. Each will get its own block when its turn is taken.

```
STAGE_01 core      07_ELITE  09_TFT  10_ATSU  11_VST  12_LIQUID  13_OUROBOROS  14_SWPT
                   15_SWP  16_SWPI  17_SWPL  18_SWPLC  19_SWPU  20_MTX-SWP  21_CODEX  22_PYTHIA
STAGE_01 Talos     01_TS01-A  02_TS01-C1  03_TS01-C2  04_TS01-C3  05_TS01-P  06_TS01-C4
STAGE_02 DPDC      01_DPDC-UDC  02_DPDC  03_DPDC-C  04_DPDC-I  05_DPDC-R  06_DPDC-MNG
                   07_DPDC-T  08_DPDC-S  09_DPDC-F  10_DPDC-N  11_EQUITY+
STAGE_02 other     00_Demipad  01_ANK  02_SCORE  03_AQP  04_RPS  05_FVT  06_VCT  07_MTX-AQP  08_DSA
STAGE_02 Talos     01_TS02-C1  02_TS02-C2  04_TS02-C3  05_TS02-DPAD
CITIZEN            01_Spark  02_Snakes  03_Custodians  04_STOICPAY  99_TS02-CPAD  03_DSP+
```

**One consequence worth calling out now.** `13_OUROBOROS`'s `C_Sublimate` / `C_SublimateV2` /
`C_Compress` are **PATRONLESS BY DESIGN** (owner ruling: they make gas or compress it back to its
source). The DPTF threading pass gave all three a patron and it had to be reverted — the
`PATRONLESS` registry in `_executorplan.py` did not contain them, so nothing objected. The
registry is now filled. **An auditor seeing a patron on any of those three is looking at a
regression**, not a design.

# IGNIS + STOA pricing spec — the settled list (owner directives, 2026-09-05)

> Status: **SPEC / not yet implemented.** The earlier rehaul wired only the ops named by number
> to the central `IG|DETER` (~70 call sites: the AQP family + the specific issuance/wipe/anchor/
> DSA/LP ops). Every other client op still charges its legacy `UDC_*Cumulator` tier. This
> document is the target state to implement against.

## 1. The cost model

```
IGNIS charged = deter (the multiplier, in IGNIS) + the op's own component consumption
STOA  charged = ONLY on ISSUE functions (see §3)
```
* **1 IGNIS = 1 US/EUR cent** (hard peg).
* Prices below are **FULL prices**. Discounts apply on top:
  * **IGNIS: up to 49%** (Elite tiers)
  * **STOA: up to 24.5%** (exactly half the IGNIS discount)
* **Non-discountable exceptions** (rare, taxed in FULL): PYTHIA's costs; some legs of the
  asymmetric-liquidity-addition path. These must be flagged explicitly in code.

## 2. STOA rule (ISSUE functions only)

The STOA charge carries the **same dollar value as the IGNIS deter**, converted at the live STOA
price. STOA is currently **hard-pegged at $0.10** (oracle placeholder), so:

```
stoa_amount = deter_dollars / stoa_price        e.g. $40 deter / $0.10 = 400 STOA
```
When a real STOA price exists the amount varies, but the **dollar value stays constant**. This
must be computed from the oracle price, never hard-coded as a STOA quantity.

## 3. The per-module list

| module | function | IGNIS deter | STOA |
|---|---|---:|---:|
| **ATS** | `C_Issue` | 4000 ($40) | 400 ($40) |
| **ATS** | `C_ToggleParameterLock` | 5000 ($50) | 500 ($50) — see §4 |
| **DALOS** | `C_DeployStandardAccount` | — | 50 ($5) — see §5 |
| **DALOS** | `C_DeploySmartAccount` | — | 100 ($10) — see §5 |
| **DPNF** | `C_Issue` (NFT collection) | 2500 ($25) | 250 ($25) |
| **DPOF** | `C_Issue` | 1000 ($10) | 100 ($10) |
| **DPSF** | `C_Issue` (SFT collection) | 2000 ($20) | 200 ($20) |
| **DPSF** | `C_IssueCompany` | 10000 ($100) | 1000 ($100) |
| **DPTF** | `C_Issue` | 1000 ($10) | 100 ($10) |
| **DPTF** | `C_ToggleFeeLock` | 5000 ($50) | 500 ($50) — see §4 |
| **PYTHIA** | `C_DeployApiKey` | none (confirmed: PYTHIA has NO ignis cost) | 500 (no discount) |
| **PYTHIA** | `C_UpdateDualConsumerLane` | none (confirmed) | 100 (no discount) |
| **SWP** | `C_IssueStable` / `C_IssueStandard` / `C_IssueWeighted` | 5000 ($50) | 500 ($50) |
| **SWP** | `C_IssueStablePool` / `…StandardPool` / `…WeightedPool` (defpact) | 5000 ($50) | 500 ($50) |
| **SWP** | `C_ToggleFeeLock` | 5000 ($50) | 500 ($50) — see §4 |
| **VST** | `C_Create*Link` (×5) | 250 ($2.50) | — (the DPTF/DPOF issue it triggers carries its own cost) |
| BRD · CODEX · DEMIPAD · DPDC | — | nothing | nothing |

**PYTHIA note:** an API key needs **2 deploys** (one Standard + one Smart) = $50 + $50; a rename
is $10. Its STOA is **non-discountable**, and PYTHIA carries **no IGNIS cost at all** (confirmed).

## 4. Fee-unlock family — DECIDED: flat, not escalating

`DPTF|C_ToggleFeeLock`, `ATS|C_ToggleParameterLock`, `SWP|C_ToggleFeeLock`.

*Current code* (`U_DEC::UC_UnlockPrice`): `IGNIS = base × (unlocks+1)`, `STOA = IGNIS/100`, with
`base` = `CT_DPTF-FeeLock` 10000 (prod) / `CT_ATS-FeeLock` 1000. It escalates **linearly with no
ceiling** (the remembered ceiling does not exist in code), and its STOA leg is dollars-at-$1, so
it is 10× short under the §2 rule.

**Decision: replace the ladder with a flat $50 IGNIS + $50 STOA per unlock**, making fee-unlocking
uniformly expensive rather than cheap-then-punitive. `UC_UnlockPrice` and both `CT_*-FeeLock`
constants become dead once all three call sites move over.

## 5. DALOS account deploys — STOA gated by its own toggle

Standard = $5 (50 STOA), Smart = $10 (100 STOA). STOA collection for these is currently OFF by
design (onboarding). **Add a dedicated global on/off switch for account-creation STOA collection**, independent of
the global STOA-collection switch, so the global can be on while onboarding stays free. It needs
its own `A_*` admin function in DALOS **and a Talos wrapper** (admin ops are IGNIS/STOA exempt).

## 6. Cleanup implied by this spec

Once every `URCi_*` reader is moved onto the new constants, the legacy tier constructors become
dead and must be **retired from the IGNIS module**: `UDC_SmallestCumulator`, `UDC_SmallCumulator`,
`UDC_MediumCumulator`, `UDC_BigCumulator`, `UDC_BiggestCumulator` — plus any other cumulator
constructor left with no callers.

## 7. Work plan (owner's ordering)

1. **Settle the final price list** (this document) — owner review.
2. **Set up the constants properly** in `02_IGNIS.pact` (deter + the STOA-from-oracle helper,
   the discountable/non-discountable distinction).
3. **Clean IGNIS** of unused cumulator constructors (§6).
4. **Rewrite every `URCi_*` pricing function** onto the new constants — this is the bulk of the work.
5. **INFO functions should need no change** — they call the `URCi_*` readers, so fixing the
   readers fixes the previews (confirm this holds for each).
6. **REPL-test every SIMPLE function**: assert the observed IGNIS equals the table's expected
   price (pre-discount), so the sheet becomes test-enforced rather than documentation.

## 8. Open items

* **`MTX-AQP|2|C_Inject` / `2|C_SweepRevokeAnchor`** — odd double-piped Talos names; check whether
  the `2|` prefix is intentional (defpact step marker) or a naming slip.
* **90 of 237 Talos ops** could not have their cumulator resolved statically for the price sheet;
  they are marked `?`. They resolve once §4 lands, since most inherit legacy tiers.

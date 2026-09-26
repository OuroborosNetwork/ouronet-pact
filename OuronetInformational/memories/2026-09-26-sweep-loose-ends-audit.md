# Post-sweep audit — what else the executor canon sweep left behind  (2026-09-26)

Owner, after catching that my `ClearDispoForeign` write-up was mis-framed: *"check that, we need
to know if anything else is missing."*

The sweep is **COMPLETE** — `_executorplan.py` reports 776/776, 0 remaining. So this is a
post-hoc audit, not a mid-flight one.

## Method — the shape being hunted

`ClearDispoForeign` was missing its `INFO_` reader because the sweep commit added the entrypoint
AND its price, but the INFO readers live in `Z_Reads/` which that commit never touched, and
nothing compared the two files. So: **enumerate everything that must FOLLOW an entrypoint and
lives in a file the sweep would not open, then check each.**

## Results

| # | must follow an entrypoint | lives in | verdict |
|---|---|---|---|
| 1 | IGNIS price entry | `2_Core/02_IGNIS.pact` | **clean** — all 483 keys accounted |
| 2 | `INFO_` cost preview | `Z_Reads/*` | **1 gap** — `ClearDispoForeign`, fixed, now gate-enforced |
| 3 | obligations 1–3 (sigs, interface, Talos wrappers, call sites) | various | **clean** — `_modulecomplete.py` PASS on all **69** modules |
| 4 | obligation 4 (audit delta) | `Audit/AUDIT-V2-DELTA.md` | **clean** — `_auditdelta.py --check` covers every changed module |
| 5 | REPL test coverage | `REPL/**` | **clean** — of 423 client entrypoints, only 6 untested, and all 6 are core `SWPLC`/`ATS` entries that are not client-callable; their Talos wrappers ARE covered |
| 6 | consumer signature manifest | `daimons/OuronetUI/src/constants/pactSignatures.generated.ts` | **clean** — 850 signatures, **0 mismatched, 0 missing, 0 extra** against the registry |
| 7 | Talos wiring for every core `C_`/`A_` | `3_Talos/*` | **1 real finding** — see below |
| 8 | auth surface | `ARCHITECTURE/AUTH-SURFACE.md` | gate-enforced (after today's 29-entrypoint filter fix) |
| 9 | `Deploy/`, `TALOS-ABI.json`, patron slots | generated | gate-enforced |

## THE FINDING: `IGNIS.C_DonateStoa` is a client function no client can call

Added by **Sweep 2/46**, commit `9b3725d7` *"02_IGNIS — close the IMC tail"*. That commit did the
right thing: it converted the IGNIS collectors from `C_` to IMC-gated `X_`
(`XB_MoveDalosFuel`, `XB_Collect*`, `XE_Collect*`), removing a standing exception. CLAUDE.md
records the conversion.

It then added `C_DonateStoa` as, in its own `@doc`, *"the ONE legitimate standalone use of the
collection machinery"* — donating STOA, where nobody is being charged, so it is a true client
function. Patronless by design, collected in full, no Elite discount. The reasoning is sound.

**But its own internal path is IMC-gated, so the standalone use it exists to enable does not
work.** Measured, not reasoned — a direct client call in a full Stage-01 REPL:

```
C_DonateStoa → XB_CollectStoaFull → XB_CollectDalosFuel → XB_MoveDalosFuel → P|UEV_IMC → FAIL
```

`P|UEV_IMC` requires the CALLER to be a registered module. A direct client call has no calling
module, so it is refused.

**All four functions are LIVE on mainnet** (confirmed via `describe-module "ouronet-ns.IGNIS"`,
92,888 bytes). So a deployed, documented client entrypoint is dead.

### Why nothing caught it — the same shape as the INFO gap, one layer further

It has **no Talos wrapper, no price entry, and no test**. Each absence hides the others:

- no Talos wrapper → CLAUDE.md's rule (*"Any new `A_`/`C_` on a core module must be wired into
  the appropriate Talos module to finalize it for client and gas semantics"*) was not followed,
  and nothing enforces that rule mechanically;
- no price entry → my price-table audit could not see it, because that audit's denominator is
  the price table;
- no test → nothing ever executed it, so the IMC refusal never surfaced.

A function with none of the three is invisible to every check that exists. That is the general
lesson: **the audits are all keyed on an entrypoint appearing in some registry, and a function
that appears in none of them is unfalsifiable rather than verified.**

### The fix is a decision, not a patch — OWNER RULING NEEDED

The canonical repair is a **Talos wrapper**, because Talos IS an IMC-registered module, so the
call would arrive from a registered caller and `P|UEV_IMC` would pass. But a new Talos entrypoint
drags the whole tail with it:

- which Talos module (`TS01-C2` holds the `LQD|` STOA family)
- **is it free?** It is patronless by design, and the precedent exists — `TS01-C4::PYTHIA|C_Link`
  is deliberately free. But CLAUDE.md is explicit that the PYTHIA exemption is safe *because it
  is bounded* (one-shot per pair, forever). A donation is unbounded and repeatable, so the same
  argument does NOT transfer, and an unpriced repeatable Talos entrypoint is a gas-station drain
  vector.
- an `INFO_` preview (a donation with no cost preview is odd but arguably fine — the donor names
  the amount)
- tests, including the adversarial one

The alternative is to **delete it** — it is unreachable, so nothing can regress. But a deployed
module cannot have a function removed from the chain; the repo copy would go and the live one
would remain dead. Archive-mode precedent (§7.21) applies to modules, not single functions.

**Not built. The economics question (free vs priced) is the owner's, and getting it wrong
creates a drain vector rather than a missing feature.**

## What was NOT a finding, and why it looked like one

- **"458 of 715 core entrypoints unwired from Talos."** My first pass matched
  `ref-<MODULE>::<fn>`, but Talos binds modrefs under LOCAL aliases
  (`(ref-FVT:module{…} AQP-FVT)` → `ref-FVT::CC_Inject`). Every module reported N/N, which is the
  tell. Resolving aliases first: 315. Excluding `P|` policy functions (canon-exempt) and citizen
  modules (which call INTO Talos by design): **3**, of which two resolve —
  `SWP.C_ToggleAddOrSwap` is reached via `SWPU` (core-to-core, CLAUDE.md billing shape F) and is
  tested; `SWPI.A_RebuildGraph` is a direct admin op, which is exactly how PureV2/15 invoked it.
- **"7 orphan `INFO_` previews."** Two are `INFO_VST|Hibernated*Display` — display helpers, not
  cost previews, legitimately module-only. Five are SHARED INTERNAL HELPERS in INFO-TWO with
  2–10 call sites each: `INFO_DPNF|WipePure` is a one-line delegation to
  `INFO_DPDC-MNG|WipeMulti`. They match `^INFO_` so the registry classifies them as previews;
  they are not entrypoint-facing. Minor classification imprecision, not a gap.

Both of those would have been confident, wrong findings. The `458` one especially — it is the
kind of number that gets acted on.

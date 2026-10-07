# HANDOFF — anchorable assets: LP tokens, smart-account custody, and the tag column

**Written 2026-10-03, to resume 2026-10-04.** Deploys **27 and 28 are LANDED** (owner confirmed).
Everything below is the NEXT round. Nothing here has been started.

---

## 0. CORRECTED 2026-10-04 — I MISREAD THE SCREENSHOTS. Only ONE caveat was false.

**What I wrote here on 2026-10-03 was wrong, and measuring took four minutes.** I read the two
screenshots as being of the owner's own account. They are not: the wallet widget top-right reads
**VST** in the first and **SWP** in the second. Both are views of a SMART account's holdings.

Measured on mainnet, `DPTF::URH_OwnedTrueFungibles`:

```
VST owns: F|ELITEAURYN-8ZLws7IkbT7x  F|SPARK-6B42e2_oW8j0  F|VST-8Nh-JO8JO4F5  R|OURO-8Nh-JO8JO4F5
SWP owns: W|SSTOA-OURO-WSTOA|LP-6D_MJJXmhuz3
ATS owns: (none)
```

Exactly the four specials in screenshot A and exactly the one LP in screenshot B. So my ORIGINAL
measurement was right -- specials belong to the vesting contract, LP tokens to the swap contract --
and the caveat saying they do not appear under your own account **is still true**. Do not delete it.

**The one caveat that IS false** is the LP sentence: *"an LP token cannot be anchored at all …
even the pool's own owner cannot booster its LP token."* True before deploy 27, false after it.
Fix that sentence only.

**Lesson for this file's own credibility:** I wrote "two of my caveat texts are now FALSE" from a
screenshot, in a handoff, as a finding. It was an inference from a misread header, not a
measurement, and it would have sent the next session deleting a correct warning.

---

## 0b. (superseded — kept for the reasoning, the conclusion above replaces it)

The owner sent two screenshots of **AQP-Pairs → Boosters → Manager → My Anchorable Assets**, and
they contradict the "ASSETS THIS LIST CANNOT FIND" panel I wrote in
`src/routes/logged-in/aqp/manager/AnchorsMgmt.tsx` (`CreatorCaveat`).

**Screenshot A — AncientHodler selected.** True fungibles (4): `Frozen^EliteAuryn`,
`Frozen^Spark`, `Frozen^Vesta`, `Reserved^Ouroboros`. So **frozen/reserved specials DO appear**,
while my caveat says *"they do not appear yet. This is a gap in the reader, not a rule."*
**That sentence is wrong and must go.** Before rewriting it, establish WHY they appear: I had
measured `XI_CreateSpecialTrueFungibleLink` issuing them to `VST|SC_NAME`, and
`URH_OwnedTrueFungibles` selecting on `owner-konto`. One of those two measurements, or my
inference joining them, is wrong. **Re-measure, do not re-reason.**

**Screenshot B — the SWP smart account selected.** True fungibles (1):
`W|SilverStoa^Ouroboros^WrappedStoa`, id `W|SSTOA-OURO-WSTOA|LP-6D_M3JXmhuz3`. So the **LP token
is already reachable by the reader** — it simply belongs to `SWP|SC_NAME`, so it only surfaces
when that account is the one selected. That is exactly the wrong place (see §2).

My caveat also still says *"an LP token cannot be anchored at all … so even the pool's own owner
cannot booster its LP token."* **That was true before deploy 27 and is false after it.** Fix.

---

## 1. THE ASK — LP tokens must appear under the POOL OWNER

> *"the account selected owns the single swpair that exists on Ouronet, and therefore its LP
> should be visible in the True Fungible List. Yet it doesn't show. … there is a read function
> that resolves what pools I own — it is used in the SWP-Pairs tab, where the UI shows the pools
> I own. That has to be wired in here, showing what pools I own, and then their LP tokens listed
> as anchorable assets."*

So: find the reader the **SWP-Pairs tab** already uses for "pools I own", call it from the
anchorable-assets path, and map each owned swpair to `SWP::UR_TokenLP swpair`. Deploy 27 made
those anchorable (`URCv_AnchorableDptfAuthority` resolves an LP to `UR_OwnerKonto swpair`), so
the authority already lines up — this is purely a READER gap.

Decide where it lives: a new slice in `O-UI-THIRTEEN` (`URH_13|MyAnchorableAssets` unioning the
LP ids) would be one deploy and keeps the page on one read; a second top-level dot call from
the UI needs no deploy. Prefer the reader, for the same reason `MyAnchorableAssets` exists.

---

## 2. SMART-ACCOUNT CUSTODY — the owner's ruling, verbatim in substance

Some tokens are owned by **Smart Ouronet Accounts**. DALOS owns Auryn, Ouro, EliteAuryn, etc.

**A Smart Ouronet Account has a SOVEREIGN — the standard account that created it.** So the owner,
holding AncientHodler (sovereign of DALOS), *should* be able to anchor the tokens DALOS owns.

**BUT three smart accounts are explicitly excluded: `VST`, `ATS`, `SWP`.** They own tokens by
*custody*, not by management intent, and custody must never become a management route. For
those, authority resolves to the parent instead:

- **LP tokens → the POOL OWNER** of the swpair (already implemented in deploy 27).
- VST / ATS → resolve to the parent likewise. **Exact rule not yet specified — ask.**

Open questions to settle before writing Pact:
- Is there a reader for "sovereign of a smart account"? (DALOS almost certainly has one.)
- Should the SOVEREIGN route be in `URCv_AnchorableDptfAuthority` too, or only in the UI reader?
  It is an authority rule, so it belongs in the contract — but that is another ANK deploy.
- `UEV_ExecutorIzAssetAuthority` and `CAP_TF|Owner` must stay in lockstep with whatever is done;
  they already share `URCv_AnchorableDptfAuthority`. **Keep it to ONE resolver.**

---

## 3. THE TAG COLUMN — asked for explicitly

Add a tag column to the True Fungibles list:

| token | tags |
|---|---|
| ordinary | `Native` |
| LP | `LP` |
| frozen / reserved | `Special` |
| frozen LP | `LP` + `Special` |

Derivable from the id prefix, no read needed:
`S|`/`W|`/`P|` → LP · `F|`/`R|` → Special · `F|` over an LP prefix → both.
`CT_ANK_LP_PREFIXES` in `01_ANK.pact` is the canonical prefix set; mirror it, do not re-invent it.

---

## 4. SIDE QUESTION THE OWNER RAISED (investigate, do not change)

DPDC owns the Equity collectable `E|DH-SUVEHxb9UQ6_` (`Equity^DemiourgosHoldings`), which is a
**Company Special Collectable as SemiFungible**. The owner wants to know *why* it is semi-fungible
and whether that is by design. Read-only investigation; report, do not touch.

---

## 5. STATE AS OF THIS HANDOFF

- **Gate GREEN** — 0 BROKEN, 26,451 assertions. `_suite_stats.py --gate` has been run and the
  figures in `Audit/records/REPL-ROUND-REPORT.md` are synced.
- **UI: 937 tests, tsc clean, build clean.**
- Deploys 27 (AQP-ANK, LP anchorable) and 28 (TS02-C3 `CC_Vacate*` + V2 interface + AQP-BOOT +
  DSP+) are **LANDED**.
- **STILL OWED after 28 landed** — run these, they have NOT been run:
  ```
  python3 REPL/tools/_registrylive.py --record
  python3 REPL/tools/_registry.py --probe
  ```
  The registry is still at 423 entrypoints against a chain that now has 427. `TALOS-ABI.json` was
  regenerated from SOURCES and already shows 427; the registry reads the CHAIN and has not.
- **Also owed:** the four `AQP-POOL|CC_Vacate*` are newly visible to the price sheet and carry no
  price row (`IGNIS-PRICING.md` says 15 unpriced, up from 11, and says why). They are BILLED —
  shape A — so this is a missing sheet row, not a free operation.

## 6. MISTAKES FROM THIS SESSION, SO THEY ARE NOT REPEATED

1. **A blanket prose rename rewrote identifiers.** `useState<string>("anchors")` became
   `"boosters"` and the page threw on first render. tsc could not see it because the state was
   typed `string`. Fixed by introducing `AreaId`; three render-safety tests now cover it.
   **Lesson: after any sweep, grep for the NEW token across the whole glob — do not trust tsc to
   have found every site.**
2. **I twice asserted "nothing in the tree proves X" without searching `REPL/modules/`.** Both
   times something did (`<<AQP-G37>>` pinned the LP exclusion by its exact error message).
3. **`_purev2.py --write` regenerated an already-deployed file (24).** Deployed files must move
   to `FROZEN` the moment they land.
4. **Several of my own assertions were vacuous** — a prefix-matching `toContain` on a union, a
   regex that `false && …` satisfied, a bounds test that compared a spec to itself. **Negative-test
   every new assertion by breaking the thing it guards.**

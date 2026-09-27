# HANDOFF — the 325 unwired entrypoints, made decidable

Written 2026-09-27, after every button that exists in OuronetUI was wired. What remains is not a
wiring backlog; it is a **product question**, and this document exists to reduce it from 325
individual questions to three.

Every figure was computed from `Deploy/OURONET-REGISTRY.json` and the OuronetUI route table by
`daimons/OuronetUI/scripts/talos-coverage.py`. Re-run it rather than trusting the numbers below
once anything moves.

## Where the surface stands

```
415 client entrypoints on the deployed Talos modules
     90  called by a consumer   (44 through the registry, no Pact in the source)
      0  rendered but unwired   -- this was 28; the dialog has nothing left to explain
    325  no consumer at all
```

The 90 are not a coverage target met. They are **every operation that had a button**. The 325
have no button, and that is the whole finding: they are not blocked on engineering.

## The first cut — is there a page?

This is the cut that matters, and it was the surprise. The routes exist for almost every family,
but half of them are placeholders:

| family | unwired | surface today |
|---|---|---|
| DPSF | 59 | `/app/collectables` — **real page** |
| DPNF | 54 | `/app/collectables` — **real page** |
| DPTF | 23 | `/app/true-fungibles` — **real page** |
| DPOF | 17 | `/app/orto-fungibles` — **real page** |
| SWP | 17 | `/app/swp-pairs`, `/app/liquidity-pools` — **real pages** |
| ATS | 33 | `/app/autostake-pairs` → **`ComingSoon`** |
| AQP-* | 80 | `/app/aqp-pairs` → **`ComingSoon`** |
| VST | 16 | `/app/vesting` → **`ComingSoon`** |
| DEMIPAD | 10 | not determined |

`/app/semi-fungibles` and `/app/non-fungibles` are `Navigate` redirects into the Collectables
page, so DPSF and DPNF already have their home.

**So the 325 divide roughly in half:**

- **~170 have a real page.** Wiring them needs no new surface and no new machinery — the registry
  specs and the generic modal already do this, and 44 operations arrived that way.
- **~129 are behind a `ComingSoon` route.** The page has to exist before a button can. Wiring is
  the smaller half of that work.

## The second cut — who is it for?

Of the 312 in the top fourteen families, **128 are issuer or admin operations** — `C_Issue`,
`C_Control`, `C_Rotate*`, `C_Toggle*Role`, `C_Set*`, branding — and **184 are holder
operations**.

That matters because the two want different homes. A holder acts on what they own and belongs on
the asset page. An issuer configures an asset they created, and putting `C_Control` beside
"Transfer" offers most users a control they will never have permission to use. `/app/token-
management` exists as a route and is currently `ComingSoon`; it is the obvious home for the 128,
and that is a layout decision rather than a wiring one.

## The three questions

1. **Wire the ~170 that already have a page?** No new surface needed. The largest single block is
   Collectables, which today wires 9 of the 124 DPSF/DPNF entrypoints.
2. **Build `/app/token-management` for the 128 issuer operations**, or scatter them onto the
   asset pages beside holder actions?
3. **Which `ComingSoon` page is worth building first** — autostake (33), AQP (80), or vesting
   (16)? AQP is the biggest and the least explored; vesting is the smallest and has a wired
   counterpart already (the VST link family on the token pages).

## What is NOT a question

**The machinery is done.** A new operation costs an `OpSpec` — one object naming how each
declared parameter is filled — plus a line in the page's dispatcher. No Pact string, no bespoke
modal. Field kinds now cover: patron, executor, self, subject, pool, account, const, bool,
autoBool, supplied, decimal, integer, nonce, nonces, select, selectPair, decimalPerNonce and
json -- eighteen in all.

**And it should be simulated before it ships.** `scripts/simulate-token-ops.mjs` in OuronetUI
runs the whole set unsigned against mainnet and classifies every outcome; it carries a
`--selftest` that proves malformed calls are still detected. Adding a case is one line. Two
lessons are built into it and should survive any rewrite:

- Give each call a fixture of the RIGHT FAMILY. `V|` vesting, `S|` sleeping, `H|` hibernating;
  semi-fungible apart from non-fungible. One id reused across a family measures the fixture, not
  the calls — and once produced a type error that looked like a wiring defect and was not.
- Keep the negative control. "Zero malformed" means nothing unless malformed can be detected.

## Cross-references

- `docs/CHAPTER-INTEGRATION/` — how a client calls any of this
- `daimons/OuronetUI/src/constants/{tokenOpSpecs,ortoOpSpecs,collectableOpSpecs}.tsx` — the specs
- `daimons/OuronetUI/src/components/cfm/RegistryOpCFMModal.tsx` — the generic modal
- `HANDOFF-ui-rewire-map.md` — the earlier page-by-page map

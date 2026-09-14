# 2026-09-11 — Stage-Z read modules cannot run on a test chain (and why that hid a whole layer)

> **CORRECTION (same day, later): the diagnosis below is INCOMPLETE, and incomplete in the
> direction that hides a bug.** This file concludes the Stage-Z readers are blocked by hardcoded
> mainnet ids and would therefore work on mainnet. Removing the id blocker — via the testing
> variant the owner authorised — revealed a **second, independent** blocker underneath: these
> functions call `keys` on *other modules'* tables, which Pact admin-gates. Six Stage-Z UI entry
> points cannot run on **any** chain, mainnet included. Read
> `2026-09-11-stage-z-cross-module-keys.md` instead.
>
> Why this file got it wrong: `let` is eager, so the id error fired first and the investigation
> stopped at the first error message. **A first error message is not a root cause** — it is the
> first of possibly several. The only way to know is to remove it and look again.


## What the scale sweep surfaced

`_scale_report.py` measures how many module functions any test path reaches. Three read-only
modules came back at or near zero:

| module | never reached |
|---|---|
| `2_CITIZEN/Stage_Z/02_EXPLORER.pact` | **7 of 7** |
| `2_CITIZEN/Stage_Z/01_DPL-UR.pact` | **71 of 72** |
| `1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact` | 153 of 154 (now 152 — see below) |

The first instinct — "read modules, nobody bothered" — is wrong for the Stage-Z pair. They are
**deployed** in the gate (`ZALL.repl` loads `deploy-stagezz.repl`). Deploying is not calling.

## The cause: hardcoded mainnet ids

`EXPLORER::URC_0001_LandingPage` aborts on any test chain:

```
No value found in table ouronet-ns.ATS_ATS|Pairs for key: Auryndex-O136CBn22ncY
```

`O136CBn22ncY` is the **live deployment hash**. A REPL sandbox derives its own (`98c486052a51`)
from `prev-block-hash`, so those rows can never exist there.

Both Stage-Z modules do it — EXPLORER hardcodes 2 ids, DPL-UR at least 4
(`Auryndex`, `EliteAuryndex`, `GoldenStoaPillar`, `SilverStoaPillar`, all `-O136CBn22ncY`).

**The inconsistency is inside a single `let`.** EXPLORER lines 130-136:

```pact
(auryn-id:string       (ref-DALOS::UR_AurynID))        ;; derived  — chain-agnostic
(elite-auryn-id:string (ref-DALOS::UR_EliteAurynID))   ;; derived  — chain-agnostic
;;
(Auryndex:string  "Auryndex-O136CBn22ncY")             ;; hardcoded — mainnet only
(EAuryndex:string "EliteAuryndex-O136CBn22ncY")        ;; hardcoded — mainnet only
```

The right pattern is used two lines above the wrong one.

## Why it matters beyond testability

1. **Nothing can catch a regression in these modules.** They are the explorer and deployer UI read
   surface; a break shows up as a broken UI, discovered by a user.
2. **They do not survive a redeployment.** If the ATS pairs are ever reissued under a new hash, the
   landing page silently starts aborting and no test fails.

## Why this was NOT fixed here

Both files carry a header saying *"canonical; keep aligned with live net"*. Editing them risks
desynchronising the repo from what is deployed, which is a deploy-coordination decision, not a
test-coverage one. Flagged rather than changed.

## Options, if it is taken up

- **Derive the pair ids.** No reverse lookup (RBT -> ATS pair) exists today, so this needs either a
  new reader — `DALOS::UR_AuryndexID` alongside the existing `UR_AurynID` — or an ATS pair lookup.
  Strictly better: the modules become chain-agnostic AND testable in one change.
- **Accept and document.** Keep the hardcoding, and record that Stage-Z reads are verified on-chain
  by observation, not by the suite. Cheapest, but the redeployment hazard stays.

## The one that WAS fixable

`INFO-TWO` had zero coverage for a different reason — it simply fell between the stages (Stage-2
module, Stage-1 INFO tester). It has no hardcoded ids, so `REPL/modules/INFO-TWO.repl` now exists
and pins the invariant the whole preview family rests on: **the preview's `ignis-full` must equal
the cost the wrapped `URCi_` reader reports**. Compare `ignis-full`, not `ignis-need` — `need` is
`full` after the elite discount, so comparing it folds two independent things together and a
discount change would read as a preview bug.

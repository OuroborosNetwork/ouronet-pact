# HANDOFF — interface-membership sweep

**STATUS 2026-10-12: DONE.** Owner instruction, same day, after reading the numbers below:
*"do the sweep now, and lets fix this gap with the interfaces, i want to do a single deploy. yes
widen pure V10, for the whole pact code stage 1 and stage 2 modules."* That is path 2 below,
taken to its full extent — not just AQP-FVT/TS02-C3, but **all 36 sovereign modules, 38
interfaces, 307 stubs**. `REPL/tools/_ifacebump.py` did the mechanical work; `Deploy/PureV10` was
rebuilt from 6 transactions to 22 to carry it (see that directory's `README.md` for the full
writeup, the dot-pin cascade, and four tool bugs found and fixed along the way before the gate
would stay green). Citizen scope remains OUT per the 2026-09-26 ruling this file already flagged
as an open question — it is no longer open: `_ifacemembership.py` now prints citizen gaps under
an explicit "OUT OF SCOPE" banner naming that ruling, same convention as `_executorplan.py`. The
rest of this file is kept as the record of what was measured BEFORE the decision, including the
two-paths framing that the owner resolved.

**Owner ruling, 2026-10-12.** Verbatim: *"it was agreed upon that all user functions must sit in
the module's interface by default, as a glossary of all the user/client functions said module
employs. So if you added new ones, or modified existing ones, the rule is the module's interface
must list them all, and that goes for all other such function types that appear in the module's
interface... i dont want the interfaces to miss functions, just because it was inconvenient to add
them due to interface bump and refactoring."*

This **supersedes** the deferred-bump policy recorded in
`OuronetInformational/memories/2026-08-29-modref-interface-semantics.md` ("declare for enumeration
convenience, NOT as a correctness requirement... pre-redeploy, interfaces are edited FREELY...
the single Phase-7 bump captures the whole final shape at once"). That memory's *technical*
finding is still correct — Pact does not require interface membership for a modref call to load or
run — but the *policy* drawn from it (treat it as optional, defer indefinitely) is overruled. See
`StoicSyntax-Prefixes.md` §5 for the canon text and the full ruling.

**Ground truth: `python3 REPL/tools/_ifacemembership.py`.** Never hand-count — the first attempt at
measuring this (an ad-hoc agent scan, 2026-10-12, same day) found "30 gaps" by searching only
`C_`/`CC_`/`A_`/`AA_`/`Cp_`/`CCp_`/`Ap_`/`AAp_` — it missed `XE_`/`XB_` entirely, which §5 also
requires, and undercounted RPS alone by 18. The tool scans the full §5 "must appear" list.

## The numbers, measured 2026-10-12

Two bands, reported separately because the owner's own words name one as primary:

- **RECIPE** (`C_`/`CC_`/`A_`/`AA_`/`Cp_`/`CCp_`/`Ap_`/`AAp_`/`XE_`/`XB_`) — the user/admin-facing
  surface, "user/client function" in the owner's own words.
- **READER** (`UR_`/`URC_`/`URH_`/`URHC_`/`UEV_`/`CAP_`/`UDC_`/`UC_`/`UCk_`) — §5's fuller
  corollary also names these, reported for completeness, not conflated with the headline.

| scope | modules with a gap | RECIPE gaps | READER gaps |
|---|---:|---:|---:|
| **sovereign** (`1_SOVEREIGN/`) | 36 | **47** | 260 |
| citizen (`2_CITIZEN/`) | 18 | 89 | 66 |

**Citizen scope is an open question, not yet ruled on.** The patron/executor canon sweep hit the
identical shape and got an explicit carve-out (CLAUDE.md, owner ruling 2026-09-26): *"citizen
modules are free to construct functions as they please."* Whether that carve-out extends to
interface membership too has not been asked. Until it is, **this worklist is sovereign-only.**

### Sovereign RECIPE-band gaps, by module (the primary worklist)

| module | file | implements | RECIPE gaps | READER gaps |
|---|---|---|---:|---:|
| `RPS` | `STAGE_02/2_Core/03_AQP/04_RPS.pact` | `AcquisitionRewardPerShareV1` | 18 | 72 |
| `TS02-C3` | `STAGE_02/3_Talos/04_TS02-C3.pact` | `TalosStageTwo_ClientThreeV2` | 12 | 8 |
| `AQP-FVT` | `STAGE_02/2_Core/03_AQP/05_FVT.pact` | `AcquisitionFarmsVaultsTreasuriesV1` | 7 | 13 |
| `AQP-POOL` | `STAGE_02/2_Core/03_AQP/03_AQP.pact` | `AcquisitionPoolsV1` | 5 | 28 |
| `AQP-SCORE` | `STAGE_02/2_Core/03_AQP/02_SCORE.pact` | `AcquisitionScoresV2` | 3 | 27 |
| `VST` | `STAGE_01/2_Core/11_VST.pact` | `VestingV2` | 1 | 0 |
| `SWPI` | `STAGE_01/2_Core/16_SWPI.pact` | `SwapperIssueV4` | 1 | 1 |

Run `python3 REPL/tools/_ifacemembership.py --module AQP-FVT` (etc.) for the exact function
names per module — not reproduced here since the tool is ground truth and this table would drift.

## The cascade cost, measured for the two modules already mid-redeploy (PureV10)

`AQP-FVT` and `TS02-C3` are already being redeployed in `Deploy/PureV10` for an unrelated reason
(the TF beneficiary reassignment). Bumping their interfaces to close the RECIPE gap above is
**not free** even there — every OTHER module holding a typed `module{...}` reference to the
bumped interface must update that reference and redeploy too, per the standing cascade rule
(`CLAUDE.md`):

- `module{AcquisitionFarmsVaultsTreasuriesV1}` → `V2` cascades to: `06_VCT.pact` (AQP-VCT),
  `07_MTX-AQP.pact` (MTX-AQP), `08_DSA.pact` (AQP-DSA) — sovereign — plus
  `2_CITIZEN/Stage_Z/03_DSP+.pact` (DSP) — citizen.
- `module{TalosStageTwo_ClientThreeV2}` → `V3` cascades to:
  `2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact` (AQP-BOOT), `2_CITIZEN/Stage_Z/03_DSP+.pact` (DSP)
  — both citizen.

So closing just these two modules' gaps **now**, inside PureV10, means **5 more modules**
redeploy beyond the 3 already planned (AQP-FVT, TS02-C3+AQP-INFO, AQP-SCORE) — a round that would
roughly double in size. `AQP-POOL`'s own bump (5 RECIPE gaps) would cascade further still: it is
referenced by nearly every module in the AQP family (confirmed heavily cross-referenced via
`module{AcquisitionPoolsV1}` throughout FVT/SCORE/VCT/INFO/DSA/BOOT/MTX-AQP/Talos) — not measured
exhaustively here because the honest answer at this point is "large enough that it needs its own
scoped measurement before anyone commits to a round around it," not a number guessed under time
pressure.

## Recommendation (historical — overtaken by the owner's actual ruling)

At the time this was written, the choice looked like two honest paths: ship the narrow PureV10
and open this as its own multi-session initiative (comparable to the 46-module executor-canon
sweep), OR fold just AQP-FVT + TS02-C3's gaps into PureV10 and accept a 5-module cascade.

**The owner picked neither — they picked the full sweep, same day, same round.** *"do the sweep
now... i want to do a single deploy... widen pure V10, for the whole pact code stage 1 and stage
2 modules."* `AQP-POOL`'s own bump did cascade as far as this doc warned it might (referenced
throughout the AQP family) — measuring it exhaustively, rather than estimating, is exactly what
`_ifacebump.py --all --write` plus `_dotpin.py --upgrade <module>` for all 36 directly-bumped
modules did. Final shape: 36 sovereign modules, 38 interfaces, 307 stubs, 12 of those 36
dot-pinning a further 4 modules (AQP-INFO, AQP-BOOT, MTX-AQP, AOZ) into the same round. PureV10
went from 3 transactions to 22. See `Deploy/PureV10/README.md` for the complete, final
accounting — cascade table, what shipped, what was deliberately excluded (DPMF, CADUCEUS,
BLOODSHED, NOSFERATU, the held-back AppReads pages) and why.

Status: **done.** `python3 REPL/tools/_ifacemembership.py` reports 0 sovereign gaps.

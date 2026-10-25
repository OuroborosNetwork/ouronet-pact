# Deploy/PureV14 — the drift-lock / stream-eligible latches

**13 transactions, STRICT ORDER, 01 through 13.** Work down the list. Do not reorder, do not skip,
and do not move **04** or **08** out of position — see **THE TWO ORDERING RULES** below.

## What this round is for

`CC_InjectStream` could be opened over a **stale** membership. The drip divides by the stored
`total-deb-score` mirror and pays each member against their **stored** deb for the stream's whole
duration, with no fix loop and no freshness enforce — so a mis-split persisted for the life of the
stream and was never corrected retroactively. Measured and recorded in
`OuronetInformational/memories/2026-10-23-interface-bump-default-and-inject-paths.md` §4.

`Audit/module-audits/AQP/STREAMED-INJECT-DESIGN.md` **D10 claimed the enforced-fresh gate covered
the streamed path.** It never did, and the document's own header said "✅ IMPLEMENTED & TESTED".
Both are corrected in this round; that false line is what hid the gap from every later reader.

The fix is **two one-way latches**, not a scan at drip time:

| latch | lives on | set by | means |
|---|---|---|---|
| `drift-locked` | `SCR\|Schema` | `AQP-SCR\|C_LockScoreDrift` | this score's weight cannot move between stakes (`deb-boost` false **and** no boost-class link) |
| `stream-eligible` | `FVT\|Schema` | `AQP-FVT\|CC_LatchStreamEligible` | every enabled member was **proven** drift-locked |

`CC_InjectStream` now refuses unless the FVT is latched, and `UEV_StreamEligibleMemberOk` keeps the
proof true at every later admission and re-enable. Locally checkable at every site: no reverse
index, no cross-module lock, nothing reaching into assets the FVT owner does not own.

**Live streams are grandfathered.** `stream-eligible` defaults false, so an un-latched FVT cannot
open a NEW stream — but streams already running keep dripping, because `XI_ReleaseStream` is not
gated by the inject defcap. Halting a live vest would strand custodied tokens owed to stakers.

## Interface versions — asked of the CHAIN, not the repo

Per `HOW-DEPLOY-ROUNDS-WORK.md` §2b, polled with `describe-module` rather than counted from source:

| interface | live before | this round |
|---|---|---|
| `AcquisitionSchemas` | 1, 2 | **V3** |
| `AcquisitionScores` | 1, 2, 3, 4 | **V5** |
| `AcquisitionRewardPerShare` | 1, 2, 3 | **V4** |
| `AcquisitionFarmsVaultsTreasuries` | 1, 2, 3 | **V4** |
| `TalosStageTwo_ClientThree` | 1, 2, 3, 4 | **V5** |
| `AcquisitionVacate` | 1, 2, 3 | **V4** |

**`AcquisitionVacate` is in that list because the cascade is TRANSITIVE, and the first build of this
round got it wrong.** Its interface declares
`UC_VacateUniqueBeneficiariesFromLegs (legs:[object{AcquisitionSchemasV2.VCT|VacateTfLeg}])` — it
NAMES a schema object type. Bumping Schemas V2→V3 therefore changes that member's signature, and the
module then "does not correctly implement" the still-live V3 interface. The round simulator caught it
at transaction 09 with exactly that message. `CLAUDE.md`'s cascade rule says this outright: *when
interface B → B′, every interface A that names B must bump to A′.* Measured to fixpoint afterwards —
only three interfaces name a schema object type (`AcquisitionScores`, `AcquisitionRewardPerShare`,
`AcquisitionVacate`), and the first two were already bumped, so the cascade closes at six.

## The round

| # | file | what it carries |
|---|---|---|
| 01 | `01_deploy.pact` | `01_DALOS`, **`02_IGNIS`**, `04_BRD` — IGNIS carries the two new price keys |
| 02 | `02_deploy.pact` | `00_Demipad`, **`00_AQP-SCHEMAS`**, **`01_ANK`** |
| 03 | `03_deploy.pact` | **`02_SCORE`** — gains `drift-locked` |
| **04** | **`04_backfill.pact`** | **`AA_MigrateDriftLocked` — MUST run here** |
| 05 | `05_deploy.pact` | **`03_AQP`** |
| 06 | `06_deploy.pact` | **`04_RPS`** |
| 07 | `07_deploy.pact` | **`05_FVT`** — gains `stream-eligible` |
| **08** | **`08_backfill.pact`** | **`AA_MigrateStreamEligible` — MUST run here** |
| 09 | `09_deploy.pact` | **`06_VCT`** (+ `AcquisitionVacateV4`), **`07_MTX-AQP`**, **`08_DSA`** |
| 10 | `10_deploy.pact` | **`04_TS02-C3`**, **`09_AQP-INFO`** |
| 11 | `11_deploy.pact` | **`04_AQP-BOOT`** |
| 12 | `12_deploy.pact` | **`03_DSP+`** |
| 13 | `13_deploy.pact` | **`14_O-UI-FOURTEEN`** (AppReads, MODULE-ONLY, hand-carried) |

`01` and `02` also redeploy `01_DALOS`/`04_BRD`/`00_Demipad`, which did not change — they share a
generated transaction with a module that did. Harmless; an unchanged upgrade costs only its gas.

### Interfaces are STRIPPED unless this round bumped them

A deployed interface can never be re-sent — *"Interface cannot be upgraded"*. `Deploy/1_Pure/` is a
FROM-SCRATCH bundle and carries every interface, so each transaction here has had the **already-live**
interface blocks removed, keeping only the six this round bumps. 12 blocks were stripped across 6
files (`OuronetDalosV3`, `IgnisCollectorV4`, `OuronetInfoV3`, `BrandingV3`, `DemiourgosLaunchpadV3`,
`AcquisitionAnchorsV3`, `AcquisitionPoolsV3`, `AqpMtxV2`, `DsaV3`, `AcquisitionPoolBootV2`,
`DispenserV3`). This is the first round needing SELECTIVE stripping: V13 happened to bump every
interface its own files carried, so it could ship them whole.

**15 modules changed; 13 transactions carry them.** `Deploy/MANIFEST.md` plans 24 because it is a
FROM-SCRATCH planner with no notion of what is already live.

## THE TWO ORDERING RULES

**04 and 08 are schema repairs, and both are destructive if run late.**

A schema that gains a field leaves every pre-existing row without it, and `with-default-read`
defaults an absent **ROW**, not an absent **FIELD** on a present row. Worse than the new reader
faulting: the whole-row readers (`UR_SCR|Score…`, `UR_FVT|Fvt`) fault on **ordinary traffic** — a
stake, an unstake, a collect. There is no window in which the system is merely degraded: either the
pass has run, or those rows are unusable.

Both passes write `false` **unconditionally** — Pact will not let them ask whether a typed field is
absent. So re-running either one **after an owner has latched** would silently **UN**-latch, which
is exactly the one-way contract the latches exist to provide, broken by its own migration. Run each
once, in position, before the surface is open to owners.

- **04** immediately after **03** (`02_SCORE`), before anything touches a score.
- **08** immediately after **07** (`05_FVT`), before anything touches an FVT.

Both sign with the Demiurgoi keyset: `GOV|AQP-SCORE_ADMIN` for 04, `GOV|FVT_ADMIN` for 08.

## Why IGNIS is in this round and was not in V13

`UC_IgnisComponents` is `(at op-key IG|COMPONENTS)` and its own doc says it **"fails fast on an
unknown op."** This round adds two real price keys — `AQP-SCR|C_LockScoreDrift` (13.0) and
`AQP-FVT|CC_LatchStreamEligible` (23.0). Without redeploying IGNIS, both new ops abort on the price
lookup rather than doing anything. (V13's `C_SetMinInjectAmount` needed no key: it bills through
`URCi_ToggleRewardLink`.)

## Where `stream-eligible` lives, and why it moved

It was first written onto `FVT|RewardAggregate` (RPS-owned) for proximity to `owner-konto`. That
pushed `04_RPS.pact` to **321,970 emitted bytes — 1,970 over the 320,000 cap**, caught by
`_deploybundle.py`'s post-write measurement. RPS is a single module and cannot be split across
transactions, so the choice was: raise the cap, or move the field.

**The cap stayed.** `_deploybundle.py`'s own comment is explicit that the repo does not know what
binds first at this size and warns "two points fit any curve" — and `CLAUDE.md` records the
linear-extrapolation attempt that would have produced 100,000,000-gas transactions. Moving the
field was also the better design: `stream-eligible` is entity **config**, which is precisely what
`FVT|Schema` holds ("identity/config stays in FVT|Schema"), and AQP-FVT reads and writes it
directly — so the relocation also deleted a cross-module `XE_` hop. RPS returned to ~316 KB.

## Verification

- `python3 REPL/tools/_gate.py` — **this is the verification that matters, and it is the one that
  found real breakage.** `Z.repl` was green while four suites it does not load were broken; see
  *What the gate caught* below.
- `cd REPL && pact Z.repl` — green, 1,068 assertions, including the nine new `TX-FVT-05a2` latch
  assertions (both latches start false; stream refused while un-latched; FVT latch refused while a
  member is unlocked; both latches one-way; deb-boost refused on a locked score).
- `python3 REPL/tools/_livesandbox.py --round Deploy/PureV14` — composition proof against a virtual
  chain built from the REAL DEPLOYED SOURCE. See `OuronetInformational/SPEC-round-simulator.md` §S5
  for exactly what it does and does not show: it is a composition proof, not an authorisation one.

### What the gate caught that `Z.repl` could not

Four suites, in two classes. Worth reading before trusting a green fast path on any future round
that tightens an existing gate.

**Two refusal messages, re-pinned.** Extending the `enforce` text on `C_EnableDebBoost` and
`C_CreateBoostClassLink` to name the drift latch broke prefix assertions in
`[6.2.7]_AQP-DEB-MTX.repl` `<<TX-AQP-DEB09>>` and `modules/AQP.repl` `<<AQP-G17>>`. Both now pin
the **whole** message rather than a prefix: these are attribution tests, and the message is the
only thing that distinguishes one refusal from another.

**Two suites broken outright by the new precondition.** Making stream eligibility a precondition
means no existing test could open a stream. Three fixtures needed the latches added, **member
score first** (the vault latch scans members and refuses while any is unlocked):
`Kursan/AQP-stream-tests.repl` `<<T-STREAM-FIXTURE>>` and `<<T-STREAM-06>>`, plus a new committed
`<<TX-INFO-GT-STREAM-PRE>>` ahead of `[6.5.1]`'s streamed-inject price groundtruth — separate and
committed so the two latches' own IGNIS cost stays outside the balance difference that block
measures.

**The signature to memorise: both reported `BROKEN` with a failure count of ZERO.** A load-time
abort is not an assertion failure, so the gate's detail section for each was empty. Reading the
summary table's `fail` column alone would have looked like noise.

### One authorisation-ordering bug, found by re-reading rather than by a test

Both new defcaps shipped their business `enforce` — and, for `FVT|C>LATCH-STREAM-ELIGIBLE`, the
entire heavy member scan — **before** `CAP_EnforceAccountOwnership`. That is the
`GOV|WIPE_ALL-TREASURY-DEBT` shape the 2026-09-14 owner ruling exists to prevent, and it bites
hardest here because *"members not yet drift-locked"* is the **normal** state of a fresh vault: the
ownership gates were unreachable in the common case, so a red-team test could report "a non-owner
was refused" truthfully while proving nothing. Both hoisted. No test failed either before or after
— which is the point of the ruling.

## After deploying

Run `python3 REPL/tools/_registrylive.py --record`, then regenerate the registry-derived artefacts.

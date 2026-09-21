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
6. **THE ATTRIBUTION RULE (owner ruling, 2026-09-21) — state it as a system property, because it
   is one.** Every `A_`/`C_` names the Ouronet account performing the execution, *unconditionally*,
   and for a reason that is not authorisation: **so the ledger can answer "who did what" from the
   operation's own arguments.** The executor requirement is orthogonal to every other check and
   never replaced by one — a keyset says *this was permitted*, never *by whom*, and several people
   may hold one key. Consequences the audit should assert directly:
   - **there are exactly two doors into the system** — the normal paths (every `A_`/`C_`, through
     Talos), which always require an Ouronet account, and **direct module governance**
     (`GOV|*_ADMIN` applied to the module), which does not and is deliberately the escape hatch;
   - **admins are users too.** `A_` and `C_` are named for Admin and Client, and both must supply
     an account. v1 had no such claim and several admin ops did not satisfy it;
   - **an UNENFORCED executor is worse than none.** A parameter nobody checks is one the caller
     picks, so the emitted event can implicate an account that was never involved. v2 must treat a
     decorative executor as a **finding**, not a style issue.
   - New gate-fatal instrument for Part IV: **`_executorenforced.py`**, `_modulecomplete.py`'s
     check 7. It proves each executor is enforced directly, forwarded, or reached by an indirect
     route **the function's own `@doc` names** — which is the canon's "the path MUST be named"
     clause made mechanical. Its first run found three.

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

### 05_DPTF.pact — ADDENDUM (2026-09-21, the attribution ruling)
Three treasury admin ops — `A_UpdateTreasury`, `A_WipeTreasuryDebt`, `A_WipeTreasuryDebtPartial` —
took `executor` and **never mentioned it again**. Authorisation was `GOV|*_ADMIN` alone, so the
parameter was decorative: the admin could write any account into it and the event would name that
account. Now `CAP_EnforceAccountOwnership executor` runs before the admin capability.

**This is a BEHAVIOUR CHANGE on already-published surface** and the audit must say so plainly: the
caller must now hold *both* the module admin key *and* an owned Ouronet account. Every existing
fixture already satisfied it (all five call sites sign for the account they name), so nothing in
the suite moved — but a live admin script that passed a bare label will now fail, and that is the
intended effect.

Both adversarial tests keep refusing at the gate they name rather than the new one:
`RT-C-001` signs as EMMA and names EMMA, so ownership passes and `GOV|DPTF_ADMIN` still does the
refusing (`"DPTF Ownership not verified"`); `_scratch_ts01a_n3` does the same with LUMY. That is
the shadowing check CLAUDE.md demands whenever a gate is added in front of another.

Also: `C_Issue` (DPTF and DPOF) had a real indirect route — `XB_IssueFree -> MOD|C>ISSUE ->
CAP_EnforceAccountOwnership` — and no `@doc` saying so. Both now name it, and both note that the
`(SECURE)` capability wrapping the call is **not** protection (`SECURE` is `true`) — a reading
error worth pinning, since `with-capability (SECURE)` looks like a gate and is not.

### 09_TFT.pact
5 entrypoints — the transfer engine, and the widest cascade so far: **193 core call sites plus
207 Talos wrapper sites**, because `TFT::C_Transfer` is both a client entrypoint and the movement
primitive every other module composes with.

**THE ONE SECURITY FINDING OF THE SWEEP SO FAR, and it is not a refactor artefact — it is a
pre-existing hole the canon exposed.**

`DPTF|C>CLEAR-DISPO` enforced ownership of **neither** party. It checked only that the target was
a STANDARD account holding a NEGATIVE OURO balance, then composed `P|DALOS|REMOTE-GOV`,
`P|ATS|REMOTE-GOV` and `P|SECURE-CALLER` — all module-policy grants, none of them about the
caller's relationship to the account. So **any caller could clear any qualifying account's
dispo**, and clearing a dispo is not a favour: it force-converts the subject's Elite-Auryn at
**2.5×** the debt (`C_ClearDispo`'s `total-ea`) and burns it. Bob could liquidate Emma.

Three things the audit should record about *how it survived*, because each is a reusable lesson:

1. **A test was driving the attack and reporting a PASS.** `REPL/modules/DPTF.repl` `<<DPTF-G10>>`
   called `DPTF|C_ClearDispo KST.ANHD KST.EMMA` — one signature, two accounts — and asserted the
   refusal message `"Cannot Debit DPTF"`. That refusal is EMMA's empty Elite-Auryn balance. **A
   balance is not a gate**: fund the victim and the attack works. The assertion was true and its
   subject was a hole.
2. **The v1 attack register never reached it**, because the operation does not *look* like an
   asset move — its parameters are `(patron account)` and its name says "clear", not "spend".
3. **Nothing static could have found it.** `_authsurface.py` reports what each entrypoint
   enforces; it cannot know that this one *should* have enforced something. Only assigning the
   `executor` role forced the question "whose ownership proves this?" — which is the canon's
   actual value, distinct from its readability.

**Resolution (owner ruling, 2026-09-21).** `account` is BOTH the executor and the executee: the
subject requests the clear for themselves. The core becomes `(patron executor executee)` and
enforces **both** ownerships (once, when they are equal). Talos exposes two doors:

| | | |
|---|---|---|
| `DPTF\|C_ClearDispo` | `(patron executor)` | self — arity unchanged, no client breakage |
| `DPTF\|C_ClearDispoForeign` | `(patron executor executee)` | **NEW** — delegated, both signatures |

The foreign door grants no new authority (anyone able to sign for the executee could have BEEN the
executor); it adds an audit trail naming who executed. Canonised as the **self/foreign pair** in
`StoicSyntax-Prefixes.md` §2.2.

**v2 must re-verify, and these are new assertions, not re-pointed ones:**
- `<<DPTF-G10c>>` — the fix, pinned in **both directions**: ANHD is refused on `"Keyset failure"`
  with EMMA's business guards deliberately SATISFIED (she is standard and in debt, so only the
  signature can be refusing); then the identical call with EMMA's signature added reaches the cost
  floor underneath. One direction alone would also pass if the op were broken for everybody.
- `<<DPTF-G10>>` guard 2 (the smart-account exclusion) now sits **behind** the ownership gate, so
  the fixture must satisfy ownership to reach it — done by pointing the treasury's `governor` at
  ANHD's guard, per CLAUDE.md's *"a fixture that satisfies the first guard exposes BOTH"*, rather
  than reordering the capability. **The audit should note the technique**; it is the alternative
  to the reordering the 2026-09-17 engineering position warns against.

Also in this module:
- **Ownership now precedes validation** in `DPTF|C>CLEAR-DISPO`, per the 2026-09-14 ruling. The
  old order was the `GOV|WIPE_ALL-TREASURY-DEBT` shape exactly: an account in credit is the normal
  state, so `"requires Negative OURO"` would have turned away owner and stranger alike and the new
  gate would never have been reached.
- `C_Transfer`'s executee is the canon's **conditional** case and now says so in its `@doc`:
  `DPTF|C>X-TRANSFER` enforces the executor unconditionally and the executee **only when `method`
  is true AND the executee is a SMART account**. v2 needs an attack that credits a smart account
  with `method = false` to show the branch is the gate.
- `C_MultiBulkTransfer`'s executee **cannot** be enforced and the `@doc` states why: bulk receivers
  may never be smart accounts, which is why that entrypoint has no `method` parameter at all.
- `C_Transmute`'s executor is enforced **indirectly** —
  `XI_Transmute → DPTF::XB_DebitTrueFungible → DPTF|C>DEBIT → CAP_EnforceAccountOwnership`. Named
  in the `@doc` as the canon requires — *though only after `_executorenforced.py` caught that this
  very line had claimed it before it was true. Recorded rather than quietly corrected: the delta
  is an audit input, and an audit input that was once wrong about its own subject is worth one
  sentence.* The audit should treat the indirect route as acceptable
  here (unlike `DALOS::A_UpdatePublicKey`) because the debit is the operation's own first act.
- **Dead bindings removed** from `DPTF|C>CLEAR-DISPO` (`ouro-id`, `treasury` — bound, never read),
  same class as the earlier `#58L`/`#61L` removals.

**PROVISIONAL PATRON SLOTS — 14 call sites the audit must not read as final.** Thirteen enclosing
functions in five not-yet-swept modules had no `patron` to thread, so the patron slot carries the
account that initiates the operation instead (`client` in OUROBOROS, `culler`/`fueler`/`remover`
in ATSU, `account` in SWPLC, `owner-id` in AQP, `AQP|SC_NAME` in VCT). This follows a convention
the codebase already used — `ORBR::C_Compress` passes `client` into `DPTF::C_Burn`'s patron slot —
and is inert today because `TFT::C_Transfer` does not read its patron. **Each is re-pointed at that
module's own turn.** The registry is in the migration script and listed in the handoff; an auditor
finding `client` where `patron` belongs is looking at a known intermediate state, not a defect.

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
STAGE_01 core      07_ELITE  10_ATSU  11_VST  12_LIQUID  13_OUROBOROS  14_SWPT
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

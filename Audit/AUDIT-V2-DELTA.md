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
   - **Account creation is the base case, not an exception** (owner ruling, 2026-09-21). The
     account being created IS the executor and **proves itself**: the guard it will be governed by
     is supplied in the call and enforced by `UEV_Any` — enforce-ONE — inside
     `DALOS|C>DEPLOY-*-OURONET-ACCOUNT`, *before* the format guards. Same proof
     `UEV_StandardAccOwn` performs on an existing account, same key; the guard travels with the
     call because at creation there is nowhere else it can come from. The list's second element,
     `(create-capability-guard (GOV))`, is the governance door written into the capability — which
     is how genesis bootstraps the first account. **The audit should assert this as the induction
     base**, because without it the attribution rule has an unexplained hole exactly where
     accounts come from. It was **unpinned until 2026-09-21** and is now
     `REPL/modules/DALOS-ADMIN.repl` `<<DALOS-G4b>>`, which also shows the guard check runs
     *first* by pairing a held guard (format refusal) against an unheld one (guard refusal).
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

### 10_ATSU.pact
15 entrypoints. Two of them were **three-role functions that read as two-role**, and the
capabilities are the only place that says so.

**`C_WithdrawRoyalties (ats target)` and `C_Syphon (syphon-target ats amounts)`.** Both capabilities
enforce `ATS::CAP_Owner ats` — which resolves to `CAP_EnforceAccountOwnership (UR_OwnerKonto ats)`,
the **pool owner**. So authority was proven and the acting account appeared in the signature
**nowhere at all**; the parameter that looked like an actor (`target`, `syphon-target`) is the
RECIPIENT. Now `(patron executor executee ats …)`, with `ATS::UEV_ExecutorIsOwnerKonto` binding the
named executor to the pool owner.

This is the **third instance** of one shape — after DPTF's treasury ops and TFT's `C_ClearDispo` —
and the audit should name the shape rather than the instances: **authority proven, actor
unrecorded.** It is invisible to a reader because the capability *does* enforce ownership; it is
just ownership of somebody the signature never mentions.

- **`AA_RemoveSecondary`** is `GOV|ATSU_ADMIN`-only and its executor was decorative, exactly like
  DPTF's treasury ops. Now enforced in `ATSU|C>ADMINISTRATIVE-REMOVE-SECONDARY` **before** the
  admin composition. Same behaviour-change note: admin key AND an owned account.
- **`CC_RemoveSecondary`** is the same operation on the owner path; the binder applies there.
- **The two `KickStart` variants carry TWO authorities and they are not the same account.** The
  capability's `CAP_Owner` (owner path) / `GOV|ATSU_ADMIN` (admin path) decides *whether the pool
  may be kickstarted*; the executor *funds* it and is proven by the transfer that spends its
  tokens (`XI_KickStart → TFT::C_Transfer`, executor is the SENDER). Both must sign. The `@doc`s
  now say so, because a reviewer who sees `CAP_Owner` in the capability will otherwise conclude
  the executor is checked — **which is what `_executorenforced.py` itself concluded** until it was
  made position-aware (below).
- Four more indirect routes, all legitimate and all now named: `C_Coil`, `C_Curl`, `C_Recover`,
  `C_Redeem` have no ownership in their capability and are proven by the debit that is each
  operation's first act.

**v2 must re-verify:** `<<ATS-G9>>` was re-pointed. It passed `KST.ANHD` in the actor slot while
the transaction signed as the pair's real owner — harmless when the slot was named `remover` and
nobody read it, and now a refusal that would have **shadowed the primal-RT rule the assertion is
about**. Fixed by naming the owner, per CLAUDE.md's preference for a fixture that satisfies the
first guard over a capability reorder. ANHD remains the PATRON, which is the separation on display.

**A METHOD FINDING worth carrying into the remaining 36 modules.** `CC_RemoveSecondary`'s call
sites did not change arity — `(patron remover ats rt)` and `(patron executor ats rt)` are the same
shape — so `_callarity.py` saw nothing and the migration script correctly skipped them. But the
MEANING of position 1 changed from an unread label to a bound, enforced executor. **A rename that
adds enforcement is invisible to an arity check**, and only the full suite caught it. Any module
whose sweep turns a decorative parameter into an enforced one needs a deliberate call-site review,
not a mechanical one.

---

### 11_VST.pact — COMPLETE (29 of 29 entrypoints, 2026-09-21)

**What v1 asserted that is now wrong.** Every VST client call site has moved, all 29 entrypoints
now carry a changed signature, and `_modulecomplete` reports 29 executors proven / 0 unproven.

**13 were RENAMES the plan called ADD — and that is the finding an auditor should look at first.**
`freezer`, `reserver`, `unreserver`, `vester`, `unvester`, `sleeper`, `unsleeper`, `hibernator`,
`awaker`, `constricter`, `brumator`, and `merger` twice, were already executors under bespoke names.
`_executorplan.py` classified eleven of them `ADD` because its `ACCT` list is hardcoded and had
never seen VST's vocabulary. Following it would have produced **two account parameters** on each.
Fixed in the tool (new `REVIEW` state, commit `8063bde`); **36 entrypoints tree-wide were in that
state**, so this is not a VST-only correction and the same misclassification is pending in
13_OUROBOROS, 15_SWP, 03_TS01-C2, 06_TS01-C4, 04_DPDC-I, 00_Demipad, 05_FVT, 01_TS02-C1,
04_TS02-C3 and 05_TS02-DPAD.

**5 genuinely gained an executor**: the link creators (`C_CreateFrozenLink`,
`C_CreateReservationLink`, `C_CreateVestingLink`, `C_CreateSleepingLink`,
`C_CreateHibernatingLink`). `VST|C>LINK` proved `DPTF::CAP_Owner dptf` — AUTHORITY — and named no
ACTOR: HANDOFF §4g's "authority proven, actor unrecorded", now the fourth instance in four modules.
`DPTF::UEV_ExecutorIsKonto executor dptf` supplies the other half. **The ownership enforce was kept,
not replaced.** `_modulecomplete` check 7 reports 18 proven / 0 unproven — no decorative executors.

**New adversarial coverage v1 did not have.** The link creators now refuse a caller who names an
account that is not the token's owner. **v1 had no such assertion because the parameter did not
exist**, so there is nothing to re-point — this is a new gate and needs a new negative test.

**TWO PROVISIONAL EXECUTOR SLOTS (HANDOFF §4e) — re-point these at 15_SWP's turn:**

| site | slot passed | why |
|---|---|---|
| `15_SWP.pact` `C_EnableFrozenLP` → `VST::C_CreateFrozenLink` | `(ref-DPTF::UR_Konto lp-id)` | SWP is module 13; no `executor` exists there yet |
| `15_SWP.pact` `C_EnableSleepingLP` → `VST::C_CreateSleepingLink` | `(ref-DPTF::UR_Konto lp-id)` | twin of the above |

**Both were wrong on the first attempt, and the suite caught it.** They were filled with
`(UR_OwnerKonto swpair)` — the POOL owner, which is what "the account that initiates" reads like —
and `[RT-F]_Griefing.repl` refused with *"Executor is not the Token Owner"*. An LP token is held by
a **smart** account; the swpair's owner-konto is the human. That is the handoff's own
*"executor = patron is not a safe default"* warning one level along, and it is worth an auditor's
attention because **both readings are defensible in prose and only one satisfies the binder.**

**4 transfer-role toggles** also gained a proven executor. `VST|X>TOGGLE-SPECIAL-TF-TR` proved
`DPTF::UEV_ParentOwnership`; the OF twin BRANCHES — a sleeping LP (`Z|W|`/`Z|S|`/`Z|P|`) is gated on
the native LP DPTF's owner, everything else on the parent's. **The binder mirrors that branch account
for account**, because binding to the other side of the `if` would name an account the authority check
never proved, which is how a decorative executor gets written without anyone noticing.

**A new reader, `VST::URC_SpecialTransferRoleKonto`, and why it exists.** The toggle rule is
branchy, and 18 call sites had to predict it. `DPOF::URC_BrandingKonto`'s own `@doc` records that
the equivalent rule *"was being retyped at call sites, and got retyped WRONG"* — by an earlier pass
of **this same migration**. So the rule is encoded once and the tests call it. The capabilities keep
their own inline branch deliberately: if the reader and the caps ever disagree, the cap refuses and
says so, which is the failure anyone would want.

**It was wrong on the first write, and the suite caught it.** The reader detected the ortofungible
family as `Z|` only, so every **hibernating** (`H|`) token took the DPTF branch and died on
*"No value found in table DPTF|PropertiesTable for key: H|MOCKA-…"* — a DPOF id read from DPTF's
table. This module's own comment at the Merge/Slumber guards states the rule plainly: test
`(take 2 dpof-id)` against `["Z|" "H|"]`. **Sleeping and hibernating are two prefixes of one family**,
and an auditor re-checking any special-token branch should confirm both are handled.

**7 `C_Repurpose*` gained BOTH an executor and an executee, and the split is the finding.** The
caps enforce `CAP_Owner` on a **derived** special token — `(UR_Frozen x)`, `(UR_Vesting x)`,
`(UR_Hibernation x)` — never on a parameter. `repurpose-from` reads like the actor and is not: it is
the account being **wiped**. So it is the executee, and the executor is the token owner, which
`XI_RepurposeTrueFungible` was *already* passing downstream to DPTF as its executor. Signatures moved
to canon order `(patron executor executee entity …)`; internals and caps keep `repurpose-from`, per
the convention this ledger already records for `receiver` → `executee`.

**An auditor should re-derive this split rather than take it.** Both readings are defensible from the
signature alone; only the body and the downstream call disambiguate them.

**Negative probes keep PLAIN accounts.** `<<VST-07>>` was first migrated with a derived executor,
`(UR_Konto (UR_Hibernation slp))`, against a SLEEPING token that has no hibernation link — the read
resolved `BAR` and died on *"No value found in table … for key: |"*, **replacing the refusal under
test**. It is safe as a plain account because `UEV_NoncesForMerging` runs in the wrapper cap before
the binder it composes. Any v2 re-point of a VST negative test must check that ordering, not assume
it.

**Call sites re-pointed: 33** across 11 files, including `[4.0]_Sovereign-Executor.repl`,
`[6.3]_SWP.repl`, `[5.3]_Launchpad.repl`, `modules/VST.repl`, `modules/ATS.repl`, `modules/SWP.repl`
and three archived scratch harnesses. Test executors are **derived** — `(ouronet-ns.DPTF.UR_Konto
<id>)` — never hardcoded to the patron, for the reason above.


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
STAGE_01 core      07_ELITE  11_VST  12_LIQUID  13_OUROBOROS  14_SWPT
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

---

### 12_LIQUID.pact — COMPLETE (5 of 5 entrypoints, 2026-09-21)

**What v1 asserted that is now wrong.** Four signatures changed name only and one changed arity.
`C_WrapStoa` / `C_UnwrapStoa` / `C_WrapUrStoa` / `C_UnwrapUrStoa` renamed `wrapper` / `unwrapper`
→ `executor`; `A_MigrateLiquidFunds` went 1 argument → 3, `(patron executor
migration-target-stoa-account)`, and its Talos wrapper `LIQUID|A_MigrateLiquidFunds` 1 → 2 with
`GASLESS-PATRON` supplied by the blessed path. **Every v1 assertion about the four `C_`s still
holds verbatim** — a rename is positionally invisible to a caller.

**The module had an exact already-swept twin, and that is why it was cheap.**
`DALOS::A_MigrateLiquidFunds` is the same operation on the DALOS escrow and had been swept on
2026-09-20: `(patron executor migration-target-stoa-account)`, with `CAP_EnforceAccountOwnership
executor` preceding `with-capability (GOV|MIGRATE …)`. LIQUID's was copied from it account for
account rather than re-derived. **An auditor should check the twins agree** — divergence between
two functions that sweep two escrows by the same rule is the defect worth looking for here.

**The wrap/unwrap asymmetry is deliberate and was VERIFIED, not assumed.** `LIQUID|C>WRAP`
proves the executor (`→ LIQUID|C>X_WRAPPER → CAP_EnforceAccountOwnership`); `LIQUID|C>UNWRAP`
accepts the account and proves nothing about it. That is §1.1a's "odd one out" shape and it is
**not** a defect: unwrap's first act is `TFT::C_Transfer patron executor lq-sc …`, moving funds
**from** the executor, and `TFT::C_Transfer`'s own `@doc` records that every branch composes
`DPTF|C>X-TRANSFER`, which calls `CAP_EnforceAccountOwnership` on the executor unconditionally.
Wrap needs its own gate precisely because its transfer runs the other way — out of the LIQUID
smart account — so nothing downstream would prove the user. `_modulecomplete` check 7: 5 proven,
0 unproven.

The 2026-09-14 ledger entry on RT-F-001 is the reason this was traced rather than filed: an
asymmetry between siblings is a **candidate-finder, not a design oracle**, and the last time it
was treated as one the finding was false.

**The negative test was preserved by choosing the fixture, not by reordering the guards.**
`<<CONF-05>>` asserts `LIQUID|A_MigrateLiquidFunds` refuses a non-admin with *"Keyset failure"*.
Adding `CAP_EnforceAccountOwnership executor` ahead of the admin gate would have changed that
refusal into an ownership failure — the test would still pass and would no longer test the admin
boundary. Passing `KST.EMMA`, the signer's **own** account, satisfies the ownership gate so the
keyset gate is the only thing left that can refuse. Same treatment for `<<LQD-03pre>>`, which
pins the GAP precondition by its message. This is CLAUDE.md's *"a fixture that satisfies the
first guard exposes BOTH"*, applied rather than quoted.

**Call sites re-pointed: 4** (`CONFORMANCE.repl`, `LIQUID.repl` ×2, `[6.3]_SWP.repl`). The
`CONFORMANCE.repl` one matters more than its size: that block's own comment warns that *"an arity
or type error would also raise — and would look exactly like a passing access-control test while
proving nothing"*, and `expect-failure` around a short modref call absorbs the arity error
silently. Leaving it un-re-pointed would have left a green assertion proving nothing.

---

### 13_OUROBOROS.pact — COMPLETE (5 of 5 entrypoints, 2026-09-21)

**What v1 asserted that is now wrong.** `C_WithdrawFees` went 2 arguments → 4 and **reordered**:
`(id target)` → `(patron executor executee id)`, and its Talos wrapper `ORBR|C_WithdrawFees` went
`(patron id target)` → `(patron executor executee id)`. Every call site of that op has moved. The
other four changed name only: `client` → `executor`, `target` → `executee`.

**`C_WithdrawFees` is HANDOFF §4g, fifth instance in five modules.** `OUROBOROS|C>WITHDRAW`
proved `DPTF::CAP_Owner id` — the token owner may empty the fee purse — while the only account in
the signature was `target`, the **recipient**. Authority proven, actor unrecorded. The spotting
rule held again: the ownership call takes a *derived* account, `(UR_Konto id)`, not a parameter.
`UEV_ExecutorIsKonto executor id` supplies the missing half and **`CAP_Owner` was kept, not
replaced** — one proves the right exists, the other proves who exercised it.

**The new gate is load-bearing over MONEY, and that was established by deleting it.**
`<<ORBR-FEE3b>>` is new: the **owner** signs, so `CAP_Owner` is satisfied and the pre-existing
`<<ORBR-FEE3>>` refusal cannot fire, while the executor names a different account. Removing
`UEV_ExecutorIsKonto` from the capability does not merely change an event label — **the
withdrawal succeeds and the fee purse drains**, so the owner could route a withdrawal while
attributing it elsewhere. I predicted in the test's own comment that deleting the binder would
"turn this test red while every other test in this file stays green"; running it showed the drain
cascades into `<<ORBR-FEE4>>`'s fixture as well. The comment now records what was observed rather
than what was expected.

**Two messages, deliberately distinct.** `"Keyset failure (keys-all)"` is the authority half;
`"Executor is not the Token Owner"` is the attribution half. A test matching only "failure" would
pass against either and prove neither — the same trap `<<CONF-05>>` warns about for arity.

**A refusal test needs a companion state assertion.** `<<ORBR-FEE3b>>` pairs its `expect-failure`
with *"and the refusal moved nothing"*, and that second assertion is the one that caught the
cascade. An `expect-failure` alone cannot distinguish "refused" from "succeeded, and something
else raised afterwards".

**A PROVISIONAL PATRON SLOT CLEARED (HANDOFF §4e).** `C_WithdrawFees` called
`TFT::C_Transfer target …` — the recipient standing in the patron slot, because the module had no
`patron` to thread. `_patronslots.py` carried it as provisional against this module's turn; it is
now the real `patron`, and the registry entry is retired.

**`C_Fuel` takes NO executor, and the reason is evidence rather than absence.** It sweeps the
OUROBOROS smart account's own native STOA into the liquid index. The actor is `ORBR|SC_NAME`, a
module **constant**, and it already occupies the executor slot of both downstream calls —
`LIQUID::C_WrapStoa`, where `LIQUID|C>X_WRAPPER` proves it with `CAP_EnforceAccountOwnership`, and
`ATSU::C_Fuel`, where TFT proves it. A parameter that can hold exactly one legal value is ceremony,
not attribution.

**OPEN FOR THE OWNER — `C_Fuel` looks like it is in the wrong BAND.** It has no Talos `C_`
wrapper; it is reachable only from other sovereign modules (`TS01-A::XI_DirectFuelSTOA` and
`20_MTX-SWP`'s defpact step 2); and **both callers discard its `OutputCumulator`** — deliberately,
since the gas station pays for the protocol's own re-fuelling rather than the user. By the exact
reasoning the 2026-09-20 owner ruling used to move the IGNIS collectors out of the `C_` band, this
is an `XE_`. **Not changed here**: a band change cascades the `OuroborosV2` interface, and the last
one of these was an owner ruling, not an engineering call.

**Call sites re-pointed: 4** — `[6.3]_SWP.repl` ×1 and the `Kursan/` ORBR-FEE harness ×3, the
latter being a gate entrypoint rather than a side script.

---

### 15_SWP.pact — COMPLETE (18 of 18 entrypoints, 2026-09-21)

**What v1 asserted that is now wrong.** All 18 signatures moved and ~164 call sites with them —
the largest single re-point of the sweep so far. Six `A_` admin ops gained `patron` + `executor`
(their Talos wrappers gained `executor` only, `GASLESS-PATRON` being supplied by the blessed
path); ten `C_` ops gained `executor`, six of them gaining `patron` too; `C_ChangeOwnership` also
**reordered**, `(swpair new-owner)` → `(patron executor executee swpair)`, matching
`DPTF::C_RotateOwnership`.

**HANDOFF §4g, across an ENTIRE MODULE rather than one entrypoint — and that is the headline.**
In all 18, the argument to `CAP_Owner` / `CAP_EnforceAccountOwnership` is the **derived**
`(UR_OwnerKonto swpair)`. Not one entrypoint enforced ownership on a parameter it took. The
spotting rule from module 9 is now a module-level diagnostic, not a per-function one: if a
module's ownership helper takes an entity id and reads the owner out of a table, **every**
entrypoint that uses it is unattributed by construction. `UEV_ExecutorIsOwnerKonto` — which
already existed here, written for the two branding entrypoints in an earlier turn — now binds all
18. `_modulecomplete` check 7: 18 proven, 0 unproven.

**The two capability-ordering facts that shaped the fixtures.** The binder runs in the `defun`,
before `with-capability`, following this module's own precedent rather than VST's in-capability
placement. That makes it the FIRST thing to refuse, which is why two existing negative tests had
to be re-pointed by **fixture** rather than by message: `<<SWPX-03>>`'s *"the former owner cannot
change ownership again"* would have started failing on the binder and silently stopped testing
the authority gate it was written for. It now reads the owner, satisfying the binder so
`CAP_Owner` is the only thing left that can refuse. `<<SWP-G29>>` covers the binder itself, from
the other direction: the **true owner** naming someone else as actor, where every signature check
passes and only the binder can object.

**Two PROVISIONAL executor slots CONFIRMED rather than re-pointed.** `C_EnableFrozenLP` and
`C_EnableSleepingLP` pass `(ref-DPTF::UR_Konto lp-id)` into `VST::C_Create*Link`, registered
against this module's turn on the assumption that SWP's own `executor` would replace it. **It must
not.** SWP's executor is the POOL owner; VST's binder enforces the LP TOKEN's owner, a SMART
account. Threading the new parameter would reintroduce the exact *"Executor is not the Token
Owner"* refusal recorded when that was first attempted. **A provisional slot can clear by being
confirmed, not only by being re-pointed** — worth stating, because the register's wording implied
the latter.

**Two NEW provisional slots created, in `18_SWPLC` and `19_SWPU`.** `C_ToggleAddOrSwap` has no
Talos wrapper; its only callers are peer core modules, by accepted design (L71). Both now pass
`(ref-SWP::UR_OwnerKonto swpair)` and both must become their own module's `executor` at their turn.

---

### A LATENT DEFECT IN `15_SWP`, AND A LIVE ONE IN `03_DSP+` — both found by the same signal

**`A_ToggleAsymetricLiquidityAddition` guarded the wrong account.** Four `if` blocks grant roles
only when absent. The fourth tested `ignis-fee-exemption-role` — SWP's exemption — while granting
the exemption to `vst-sc`. The correctly-named binding, `ignis-fee-exemption-roleV2`, was computed
four lines above and **never read**.

It is not cosmetic: `DPTF|C>X_TOGGLE-FEE-EXEMPTION-ROLE` enforces
`UEV_AccountFeeExemptionState id account (not toggle)`, so granting a role an account already
holds **aborts**. If SWP were exempt and VST not, VST would silently never be exempted; if VST
were exempt and SWP not, the entrypoint would become permanently **uncallable**.

**Classified LATENT, by execution rather than by reading.** A probe established that IGNIS's
`UR_Konto` is a **smart** account, so no external signer can drive
`DPTF|C_ToggleFeeExemptionRole` on IGNIS, and nothing in the tree revokes either exemption. The
two flags cannot currently diverge — which is also exactly why no test caught it: on a fresh chain
both read `false` and both branches fire.

**The same signal then found a LIVE money defect in a different module.** `_deadbind.py` — which
has existed for weeks — reports dead `let` bindings, and reported this one every day, as one line
inside a list of 150. A finding nobody can see is not a finding. Narrowing it to the shape that
actually matters — *a dead binding whose name is a near-twin of a sibling in the same `let` that
is read more than once* — gives a check with **zero** hits tree-wide, and it immediately surfaced
`2_CITIZEN/Stage_Z/03_DSP+::A_KosonMinterStageOne`, where `ps10`/`ps20`/`ps40` and
`standard-treasury`/`smart-treasury`/`validators` were all computed and discarded.

**That one was live, and measured.** The function's own comment promises *"10% To
Standard-Treasury, 20% to Smart-Treasury, 40% to Custodians(Validators), Leaving 30% … to
<dispenser>"*, and the two transfers that would do it are simply absent — while its three-part
sibling `A_KosonMinterStageOne_1of3`, thirty lines below, performs them with identical bindings.
Before the fix the three recipients received **0.0** against an expected **46.09 / 92.17 /
184.35**. The loss compounds: the next step splits the dispenser's *remaining* balance six ways
into the autostake pools, so with the transfers missing the pools drew **3.33×** their intended
share every day this path ran.

**It was exercised on every gate run and could not have been caught.**
`Stage_01/[6.8]_Dispenser.repl` called it, printed a gas figure and asserted **nothing** — a smoke
test can only distinguish "threw" from "did not throw". `<<DSP-G1>>` replaces that with four
assertions, including one that the amounts are non-zero, so the other three cannot pass on zeroes.

**The general lesson, and the one an auditor should take from this section.** `_deadbind.py`'s own
docstring asserted *"Not a correctness bug: nothing downstream sees a wrong answer."* Both findings
falsify it. When a dead binding's name is a near-twin of a live one, the deadness is the symptom
and the live name being read **twice** is the disease — and anyone tidying away "dead code" on the
tool's say-so would have **deleted the evidence and left the defect**. The check is now gate-fatal
at a threshold of zero.

**Two defects in the new detector itself, both exposed by its first output.** It reported
`03_AQP::XI_RevokeScoreFromPool`'s `lst-v1` as dead; `lst-v1` is read by the very next *binding*,
which the detector was not counting. And it claimed `lst` was read 7× when all seven were
`lst-v2` — because `\b` treats `-` as a word boundary and Pact identifiers contain hyphens. The
second flaw was also in `_deadbind.py`'s long-standing `scan()`, making its count a **floor**:
fixing it moved 149 → 155. A detector's first output is a test of the detector.

---

### 16_SWPI.pact — COMPLETE (1 of 1 entrypoint, 2026-09-22)

**What v1 asserted that is now wrong.** One signature: `A_RebuildGraph ()` → `(patron executor)`,
with `CAP_EnforceAccountOwnership executor` ahead of `GOV|SWPI_ADMIN`. One call site
(`[6.2+3]_DPTF-SWP_Issuance-Only.repl`, the #21H idempotency proof).

**It keeps its own `patron`, and the reason is worth stating.** A Talos `A_` wrapper drops the
patron because the blessed path supplies `GASLESS-PATRON`. `A_RebuildGraph` has **no Talos
wrapper** — it is a one-shot migration an admin invokes directly — so the caller supplies both.
The rule is "Talos wrappers drop the patron", not "admin functions drop the patron".

**The module's real finding was in the entrypoint the plan already called DONE.** `C_Issue` had
carried an `executor` since an earlier module's interface cascade, and `_modulecomplete` check 7
refused it: *registered INDIRECT but its `@doc` does not name the route*. The tool is right, and
this is the second time it has caught exactly this — the first was a route I claimed and had not
stated.

**The route, established by tracing rather than asserted.** `SWPI|C>ISSUE` does **not** prove the
executor: its `UEV_Issue` is a SHAPE check on the pool, and its `GOV|SWPI_ADMIN` compose is
conditional on `p` (primordial issuance only). The proof is one level down — `XE_IssueWrite`
passes `executor` into `TFT::C_MultiTransfer`'s executor slot, moving the pool tokens **out of**
that account, and `C_MultiTransfer` documents its own chain: `DPTF|C>MULTI-TRANSFER` →
`XB_DebitTrueFungible` → `DPTF|C>DEBIT` → `CAP_EnforceAccountOwnership`, once per leg.

**And it is unconditional for a reason worth an auditor's attention.** That call is a plain `let`
binding, and **Pact's `let` is EAGER** — the same evaluation rule that is the root cause of the
mute-guard class throughout this codebase is what makes the proof here unavoidable. The `@doc` now
says so, and says what would falsify it: move that binding into a branch and the executor stops
being proven on the other side.

**The general point.** An executor added by a cascade arrives without its justification. Check 7
is the only thing that notices, and it notices at the module's own turn — which is an argument for
running it per module rather than once at the end.

---

### 18_SWPLC.pact — COMPLETE (10 of 10 entrypoints, 2026-09-22)

**What v1 asserted that is now wrong.** Three signatures changed arity at the Talos boundary —
`C_UpdatePendingBrandingLPs`, `C_UpgradeBrandingLPs`, `C_ToggleAddLiquidity` — moving 34 call
sites. The other **seven changed none**: `C_Fuel`, `C_RemoveLiquidity` and the five
`STOA-PID|C_Add*Liquidity` renamed `account` → `executor` in the **core only**, and a rename is
positionally invisible to a caller. That asymmetry is why `_callarity.py` is run *after*
`_executormigrate.py` rather than either being trusted alone.

**This module has no ownership helper of its own, and eight of its ten entrypoints prove nothing
locally.** Its `;;{C4} Ownership [gold]` section is present and **empty**. Only the two branding
capabilities enforce anything — `SWP::CAP_Owner swpair`, i.e. *pool* ownership resolved from a
table, §4g again — and those two now carry `SWP::UEV_ExecutorIsOwnerKonto`. For the other eight
the authority genuinely lives downstream, so each one's `@doc` now **names its own route**, which
is the canon's requirement and the only thing that makes an indirect proof auditable:

| entrypoint | where the executor is actually proven |
|---|---|
| `C_ToggleAddLiquidity` | `SWP::C_ToggleAddOrSwap` — its `UEV_ExecutorIsOwnerKonto` + `CAP_Owner` |
| `C_Fuel` | `TFT::C_MultiTransfer` — the fuel leaves the executor |
| `C_RemoveLiquidity` | `TFT::C_Transfer` — the LP leaves the executor |
| Standard / Iced / Glacial | `SWPL::XE_STOA-PID|AddLiquidity` → `XI_AddLiqSendAndMint` → `TFT::C_MultiTransfer` |
| Frozen | `TFT::C_Transfer patron executor vst-sc` — in this module's own body |
| Sleeping | `DPOF::C_Transfer patron executor vst-sc` — in this module's own body |

**One of those deserves an auditor's attention on its own.** `SWPLC|C>ADD-SLEEPING-LQ` is the
**only** capability in the module that receives an account, so it reads like the one that
authorises. What it runs on that account is `DPOF::UEV_NoncesToAccount` — a **possession** check
(the nonce belongs to that account), not a signature check. **Possession is not authority.** The
authority is the `DPOF::C_Transfer` further down. A capability that takes an account and checks
something about it is the easiest kind to mistake for an ownership gate.

**TWO PROVISIONAL SLOTS CLEARED, one of each kind.**
- *Executor* (created at 15_SWP's turn): `C_ToggleAddLiquidity` passed
  `(ref-SWP::UR_OwnerKonto swpair)` into `SWP::C_ToggleAddOrSwap`. Correct, but **re-derived
  rather than attributed** — the pool owner was always what SWP would check; what was missing was
  any record of who asked. It now threads the caller's own `executor`, and SWP's binder rejects
  the pair if they disagree.
- *Patron* (`_patronslots.py`): `C_Fuel` called `C_MultiTransfer account account …` — the **same
  account in both the patron and the executor slot**, which is the most invisible form this takes.
  The arity is right, the two values agree, and only the registry remembered one was a stand-in.

---

### A THIRD INSTANCE OF ONE MISTAKE, IN A DIFFERENT TOOL, ON THE SAME DAY

`_modulecomplete` check 7 reported three entrypoints *"used 5x, never proven"* — Standard, Iced
and Glacial — while Frozen and Sleeping passed. All five forward the executor in the correct slot.
The difference was the **callee's name**: `_executorenforced.py`'s FORWARDED pattern matched the
member as `[A-Za-z0-9|_]+`, and `XE_STOA-PID|AddLiquidity` contains a hyphen.

> `\b` and `[A-Za-z0-9|_]` both encode a **Python** notion of a word. A Pact identifier is not
> one — it contains `|`, `_` **and** `-`. The same mistake appeared three times on 2026-09-21/22:
> twice in `_deadbind.py` (`scan()` and `twins()`) and once here.

Every time, the symptom was a **silent under-report** — the tool saying "never proven" about code
that proves it, or saying nothing at all. The whole `HOT-RBT|C_*` family was equally invisible.
Fixed and pinned by a `--selftest` carrying five forwarding shapes, including the negative case
(an executor in slot 3 is the *executee* position and must **not** count as forwarded).

**And the same tool's `SWEPT` list was a hardcoded list that had stopped at 10_ATSU**, five
modules behind — so `--swept` was silently judging a stale subset. It is now **derived from the
worklist's ticked rows**, which are already the single source of truth, and **fails loud** if the
worklist cannot be read or has no ticks: an empty `SWEPT` would report a confident clean zero,
which is the exact failure this file exists to prevent. Fourth tool in this programme to carry a
hardcoded list that could not report its own incompleteness, after `_toolpaths`, `_bandplan` and
`_executorplan`.

Re-run after both repairs: **169 proven, 0 unproven across all 13 swept modules** — five of which
the old list had never been looking at.

---

### 19_SWPU.pact — COMPLETE (4 of 4 entrypoints, 2026-09-22)

**What v1 asserted that is now wrong.** One signature changed arity —
`C_ToggleSwapCapability`, 47 call sites — and three renamed `account` → `executor` in the core
only (`C_Swap`, `C_SmartSwap`, `CC_SmartSwap`), which is positionally invisible to a caller.

**`C_ToggleSwapCapability` clears the second of the two provisional executor slots 15_SWP
created** (`SWPLC::C_ToggleAddLiquidity` was the first). Both passed
`(ref-SWP::UR_OwnerKonto swpair)` — the right value, **re-derived rather than attributed**. And
here the gap was wider than in SWPLC: `SPWU|C>TOGGLE-SWAP` enforces only the pool-worth floor and
**takes no account parameter at all**, so until this turn nothing in *either* module recorded who
asked for the toggle. `SWP::C_ToggleAddOrSwap`'s `UEV_ExecutorIsOwnerKonto` now rejects the pair
if the named account is not the owner.

**The three swaps are proven by the DEBIT, and nothing else.** The swap capabilities take the
account only to expose it in their `@event`; `SWPU|X>SWAP` validates the swap *shape*. Authority
comes from `XI_Swap`'s `TFT::C_MultiTransfer`, which moves the input tokens out of the executor.
Each `@doc` now names that route.

**A capability that takes an account and emits it is not a capability that checks it.** That is
the second time in two modules — `SWPLC|C>ADD-SLEEPING-LQ`'s possession check was the first — and
it is worth stating as a reading rule: *an account in a `defcap`'s parameter list is evidence of
an event, not of a gate.*

---

### THE CHECKER'S `FORWARDED` BRANCH IS CROSS-MODULE BY DESIGN — which is right, and had to be said

`_modulecomplete` check 7 refused all three swaps: *"used 19x, never proven"*. They forward the
executor into `XI_STOA-PID|Swap` → `XI_Swap`, a **same-module** internal, and the `FORWARDED`
pattern matches `ref-X::` — a **cross-module** hand-off.

That is not a bug. A cross-module forward is self-justifying: the foreign module is what does the
proving, and the tool can go and look. An internal hop proves nothing by itself — the proof is
wherever that internal function eventually debits — so it has to be traced by a human and written
down. Which is exactly what `INDIRECT` is for, and why registering a route there is **not a
waiver**: the tool still requires the function's own `@doc` to say it.

**The registry keys are now file-qualifiable, and the selftest reports ambiguity.** `INDIRECT` was
keyed by bare function name, and `C_Issue` alone matches **four** swept modules
(`05_DPTF`, `06_DPOF`, `08_ATS`, `16_SWPI`) — a route-claim written for one applying silently to
all four. It is a weaker hazard than the same shape in `_executorplan` (a module that does not
name the route still fails), which is why it is reported rather than fatal; the three new entries
are file-qualified, and the selftest now prints any bare key matching more than one swept module.

**Three placement errors of my own, all caught by an assertion before anything was written.** The
doc I wrote for `C_SmartSwap` landed first on the **module's** `@doc` and then on the **interface
stub**, because `s.index()` on a `(defun` head finds the interface declaration before the
implementation in a file that contains both. The guard that caught the third attempt was a
distance check — *if `(P|UEV_IMC)` is more than N characters from the head, you are not in the
function you think you are* — which also correctly flagged that `CC_SmartSwap` and `C_Swap`
already **had** `@doc`s and needed extending rather than a second one.

---

### 21_CODEX.pact — COMPLETE (5 of 5 entrypoints, 2026-09-22)

**What v1 asserted that is now wrong.** All five signatures moved. `C_RegisterStoicTag` also
**shrank**: `(tag-name account-address)` → `(patron executor tag-name)`, because `account-address`
*was already the executor*.

**This module contains the sweep's cleanest illustration of §4g, because it supplies its own
control.** Two functions sit on the same table:

| | authority | actor in the signature? |
|---|---|---|
| `C_RegisterStoicTag` | `CAP_EnforceAccountOwnership` on the **parameter** `account-address` | **yes** — a direct proof, the rarest shape in this sweep |
| `C_ReleaseStoicTag` | `CAP_EnforceAccountOwnership` on `(UR_STG|AccountAddress tag-name)` — **derived** | **no** |

Same table, same enforce, same authority. The only difference is whether the account was *passed*
or *looked up* — and that difference is the whole of §4g. Register was a rename; release needed a
new parameter and `UEV_ExecutorIsTagAccount` to bind it.

**Two entrypoints have no account in their authority path at all.** `C_RotateCodexGuard` and
`C_RecordArweaveUpload` are gated by `CODEX|OWNER`, which `enforce-guard`s a **raw guard** stored
on the codex row. There is nothing for a binder to bind to, so their executors are proven
**directly** by `CAP_EnforceAccountOwnership` — recording which Ouronet account drove the change,
which the guard alone cannot say. Both proofs are now required; §4f's orthogonality, in a module
where the authority is not an account at all.

**`registered-by` is NOT the executor, and saying so is the point.** It reads exactly like one,
it is persisted, and it is readable via `UR_CIX|RegisteredBy` — but it appears in
`CODEX|A>REGISTER-IDENTITY`'s parameter list and **nowhere in its body**, and the suite passes a
human label (`"AncientHodler"`), not an account. It is the canon's decorative actor in its worst
form: **a self-declared provenance field, written to a table, that looks verified and is not.**

It is deliberately **left alone** rather than promoted. Enforcing it would change its *type* — an
Ouronet account rather than a label — and require every Mnemosyne operator to hold one. A real,
proven `executor` was added beside it instead, and the `@doc` now states that the row's provenance
is unverified and the executor is the verified half. **An auditor reading `UR_CIX|RegisteredBy`
should treat it as a claim, not as evidence.**

---

### THE BINDER'S POSITION WAS LOAD-BEARING, AND THE SUITE PROVED IT TWICE

`UEV_ExecutorIsTagAccount` reads the tag row through a **raw `read`**, which raises on a missing
key. Placed in the `defun` — the obvious spot, and where SWP's binders live — it would run *before*
`CODEX|C>RELEASE-STOICTAG`'s `tag-row-found` enforce and kill the transaction with a table error on
any unknown tag, **replacing the "StoicTag not found" refusal** the suite asserts. Moved inside the
capability, behind the two existing enforces, where the row is known to exist.

That is the VST-07 eager-read trap reached from the opposite direction: there a *test* computed a
derived executor too early, here a *module* would have. The corresponding call site keeps a plain
account for the same reason, and now says so.

**And the new negative test was wrong on its first run — vacuously AND destructively.**
`<<CODEX-G4>>` names an account that does not hold the tag. The obvious choice was `KST.ANHD`, the
signer every other CODEX assertion uses. **ANHD *is* the fixture tag's holder**, so the binder
passed, the release *succeeded*, and the `expect-failure` reported *"got result: StoicTag
released"* — while consuming the fixture `<<CODEX-G2>>` depends on. A negative test for an equality
binder has to name an account that genuinely fails the equality, and the only way to know which
does is to **run it**. The test now asserts the precondition (`EMMA is NOT the holder`) explicitly,
so it cannot silently become vacuous again if the fixture moves.

**One load error worth recording.** The Talos `A_` wrapper needs the gasless patron, and
`GASLESS-PATRON` is a `defconst` **local to `01_TS01-A`**. Writing the bare name in `06_TS01-C4`
made Pact read it as a module reference — *"Cannot find module: ouronet-ns.GASLESS-PATRON"* — and
the whole file stopped loading. Resolved from the same source `URC_Gassless` reads
(`DALOS::GOV|DALOS|SC_NAME`) rather than re-declared, so the two cannot drift.

---

### 22_PYTHIA.pact — COMPLETE (9 of 9 entrypoints, 2026-09-22)

**What v1 asserted that is now wrong.** All nine signatures moved; ~75 call sites with them, 69 of
them slot-0 inserts on the five admin wrappers. `C_DeployApolloPythiaApiKey` changed **name only**
at the Talos boundary — `owner-account` → `executor` — so its call sites did not move at all.

**This module shows the WHOLE MECHANISM of §4g end to end, in one file.** `owner-account` is a
parameter exactly once, in `C_DeployApolloPythiaApiKey`, where `PYTHIA|OWNER` proves it directly.
That same value is then **written into the ApiKeys row**, and every later operation reads it back
as `(UR_OwnerAccount apollo-account)` and composes `PYTHIA|OWNER` on *that*. So the account is
**passed once and derived forever after** — and the actor disappeared at the moment it stopped
being a parameter. Register/release in `21_CODEX` showed the same contrast between two siblings;
here it is a single value's life story.

**The dual-link trio is §4g in a form the sweep had not met: TWO signatures, no actor.**
`PYTHIA|C>LINK-DUAL`, `C>REVOKE-DUAL` and `C>UPDATE-DUAL-LANE` each compose `PYTHIA|OWNER`
**twice**, on both halves' derived owners. The authority is proven *more* completely than
anywhere else in the codebase — and records *less*: two signatures say the operation was
permitted, not which side asked for it.

`UEV_ExecutorIsHalfOwner` is therefore a **disjunction**, deliberately:

- demanding a *specific* half would invent a business rule — either owner may legitimately
  initiate;
- demanding *both* is impossible for one parameter;
- what it rules out is the thing worth ruling out — **naming a third account, unrelated to the
  link, as the actor on an operation two other people authorised.**

Pinned by `<<PYTHIA-G2>>`, which asserts the precondition (EMMA owns neither half) so it cannot
silently go vacuous, and asserts the link is still active afterwards so a refusal cannot be
confused with a write followed by a raise.

**Four entrypoints have no account in their authority path at all.** `A_LinkDualApiKey`,
`A_RevokeDualLink` and `A_Flush` are gated by the **Cronoton keyset**; the two price setters by
`GOV|PYTHIA_ADMIN`. Nothing to bind to, so their executors are proven **directly** — recording
which Ouronet account drove an automaton action the keyset alone cannot attribute.

**`A_UpdateDeployPrice` and `A_UpdateRenamePrice` had no `@doc` at all** — the only two in the
module — so the price surface was undocumented as well as unattributed. Both now carry one. Worth
noting because these are the pair that `#17H` found were *never wired into any Talos module*: a
price control that existed, could not be reached, and said nothing about itself.

**`C_LinkDualApiKey` is registered PATRONLESS, with unusually complete evidence.** Its Talos
wrapper collects nothing while all three siblings charge. That is safe because it is **bounded**,
not cheap: two deployed Apollo halves at 500 native STOA each, `UEV_DualPairForLink` refusing a
half whose counterpart is set, and counterparts **never cleared** — so ~1000 STOA buys exactly one
free link, per pair, forever. CLAUDE.md carries the ruling and `<<PYTHIA-LINK-ECON>>` pins the
economics. The registry entry records the falsifier: **if counterparts ever become clearable, the
entry is wrong and the op needs a patron.**

**One negative test kept honest by its fixture, again.** `<<TX007d-02b>>` asserts a non-Cronoton
signer is refused with a *keyset* failure. `CAP_EnforceAccountOwnership executor` now runs before
the Cronoton gate is reached, so naming `KST.ANHD` — the account every other assertion in that
file uses — would make **ownership** refuse first, with a different message, and the test would go
on passing while proving nothing about Cronoton. It names `KST.EMMA`, who signs, so the keyset is
the only thing left that can object.

**A regex bug of my own, caught by the arity check reporting zero progress.** The slot-0 pass
matched `PYTHIA\|A_` *and* listed `A_Flush`/`A_Link`/… as alternatives, so it searched for
`PYTHIA|A_A_Flush` and rewrote **nothing** while reporting success. A rewriting pass that reports
"0 changed" on a file it was pointed at is a failure, not a no-op — `_callarity.py`'s unchanged
count is what said so.

---

### 01_TS01-A.pact — COMPLETE (27 of 27 entrypoints, 2026-09-22)

**Twenty-three of the twenty-seven were already done** — carried in by the cascades from the core
modules whose turns came first. Only four needed work, and three of those were findings about the
*tool* or about entrypoints the plan had already passed over.

**What v1 asserted that is now wrong.** `DPTF|A_DeployAccount` and `DPOF|A_DeployAccount` went
`(patron id account)` → `(patron executor executee id)`, moving 18 call sites; `ORBR|A_Fuel` went
from **no parameters at all** to `(executor)`.

---

### THE TOOL WAS PRESCRIBING THE MISTAKE THE HANDOFF WARNS ABOUT

`_executorplan`'s Talos-admin branch classified **slot 0** as the executor slot, because "a Talos
`A_` wrapper takes no patron". That rule is a statement about **gasless** ops — the blessed path
supplying `GASLESS-PATRON` — **not** about admin ops. Three wrappers here genuinely charge:
`DPTF|A_DeployAccount`, `DPOF|A_DeployAccount` and `ATS|AA_RemoveSecondary` all end in
`XE_CollectIgnis patron …`.

So the tool reported their `patron` as a **RENAME candidate** — i.e. *"rename the billing account
to executor"*, which is the handoff's own **"`executor = patron` is not a safe default"** error,
prescribed by a tool. And `ATS|AA_RemoveSecondary`, which already had **both** correctly, was being
reported unswept for having a patron in slot 0.

Fixed: if slot 0 is a real `patron`, the executor slot is slot 1 and the ordinary rules apply.
DONE 444 → 445, RENAME 97 → 93.

> **A billed admin wrapper has all three.** The absence of a patron on a Talos `A_` is a
> consequence of being gasless, not a property of being admin.

---

### `account` BECAME `executee`, AND THAT IS THE POINT OF THE FUNCTION

`DPTF|A_DeployAccount` exists **precisely so that no ownership check runs on `account`** — audit
`#N2` opened that door deliberately, so an admin can deploy for a smart account governed by another
module, whose guard nobody can hold. So `account` satisfies the executee test exactly: acted upon,
needing no signature. Calling it the *executor* would have named **the beneficiary as the actor on
the one door in the system built to let somebody else act for them.**

The executor is proven **locally**, by `CAP_EnforceAccountOwnership`, because the core this forwards
to is an `XB_` outside the canon that proves nothing about any caller. Pinned by `<<OF-G15>>`,
which sits immediately after two *successful* admin deploys — so the refusal it asserts cannot be
the admin keyset speaking.

**`ORBR|A_Fuel` earns its executor for a specific reason.** `<<CONF-05>>` found it gated only by a
self-granting `SECURE`, and what an attacker got was not theft but **timing** — the ability to force
the index move at a moment of their choosing. **An operation whose abuse is about *when* it ran is
exactly one where *who* ran it is worth recording.** Its executor is also proven locally, forced:
`ORBR::C_Fuel` is registered EXECUTORLESS, so there is nothing downstream to carry one to.

---

### TWO MORE `@doc`s THAT CLAIMED A ROUTE THEY DID NOT STATE

Check 7 refused `DALOS|A_DeploySmartAccount` and `A_DeployStandardAccount`: *registered
SELF-PROVING but the `@doc` does not name `UEV_Any`*. Third and fourth instance of this shape
(`SWPI::C_Issue` was the second), and the same lesson each time — **an executor that arrives by
cascade arrives without its justification**, and check 7 is the only thing that notices.

The route is the owner's base-case ruling, now written into both functions: the executor **is** the
account being created, so its ownership cannot be read from a table — there is no row yet. The
`guard` travels in the same call and `DALOS|C>DEPLOY-*-OURONET-ACCOUNT` enforces it through
`U|G::UEV_Any` — an enforce-ONE over `[guard, (create-capability-guard (GOV))]` — **first**, before
the glyph and format checks. That it runs first is what makes it a proof rather than a check some
other refusal could shadow, and `<<DALOS-G4b>>` pins that ordering by pairing a held guard against
an unheld one.

**Two new provisional executor slots**, in `05_TS02-DPAD` and `2_CITIZEN/6_OuronetBridge/03_CADUCEUS`
— both pass `patron` as the executor, both with the admin-keyset requirement recorded in their own
`@doc`s, and both annotated that `executor = patron` is a considered choice there and must become a
real parameter at their turn.

---

### 02_TS01-C1.pact — COMPLETE (61 of 61 entrypoints, 2026-09-22)

**Fifty-five of sixty-one arrived already swept**, carried in by the core cascades. Six needed
work, and two of those turned out not to need an executor at all.

---

### THE SAME PARAMETER, THE OPPOSITE ROLE — settled by one question

`DPTF|C_DeployAccount` and its admin twin `DPTF|A_DeployAccount` (module 19) have **the same
parameter name in the same position**, and it resolves to opposite sides of the canon:

| | `account` is… | because |
|---|---|---|
| `TS01-A::DPTF\|A_DeployAccount` | the **EXECUTEE** | nothing checks it — the door exists so an admin can deploy for a smart account nobody can hold the guard of (`#N2`) |
| `TS01-C1::DPTF\|C_DeployAccount` | the **EXECUTOR** | `CAP_EnforceAccountOwnership` runs on it directly — self-service activation |

Nothing about the name, the type or the position distinguishes them. **The only thing that does is
whether ownership is enforced on it** — which is the question the canon actually asks, and the
reason a blind rename across both would have got one of them exactly backwards. Both `@doc`s now
name the other as the contrast.

**The client variant was a rename AND a move**, `(patron id account)` → `(patron executor id)`.
Arity is unchanged, so **`_callarity.py` sees nothing** — this is the "right arity, WRONG executor"
shape the migration tooling was built around, and the 15 call sites had to be swapped by hand.

---

### TWO ENTRYPOINTS THAT MUST NOT HAVE AN EXECUTOR

`DALOS|C_UpdateEliteAccount` and `C_UpdateEliteAccountSquared` say in their own `@doc`s: *"Can be
used without account ownership by anyone."* **That is true, and it was verified rather than
believed** — `ELITE::XE_UpdateEliteSingle` enforces nothing on the account, only `P|UEV_IMC` and
`P|ELITE|CALLER`, both module-caller gates. The op recomputes *derived* elite data from state
already on chain, is idempotent, and is deliberately permissionless so anyone can repair a stale
row.

So the accounts in those signatures are **subjects, not actors**, and the only authenticated
account in the call is the `patron`, who pays. Renaming a subject to `executor` would have
**manufactured attribution out of a parameter nobody checks** — which the canon rates *worse* than
having none, because the returned message would then name whoever the caller typed. Registered
EXECUTORLESS; both `@doc`s now say to read the output as *"this account was refreshed"*, never as
*"this account refreshed it"*.

> The sweep's job is to make attribution real where it is missing. It is equally the sweep's job
> **not to invent it where it cannot exist.**

---

### THE AUTH-SURFACE BASELINE WAS STALE FROM BEFORE THE SWEEP — and regenerating it is the measurement

Check 5 reported `DPTF|C_DeployAccount` and `DPOF|C_DeployAccount` **WEAKENED — no longer enforces
`['account']`**. It was a rename: the enforce is still there, on `executor`. But the tool is right
to shout, because regenerating the baseline is exactly how a genuine weakening would be laundered.

So the regeneration was **diffed before it was accepted**, entry by entry:

| | |
|---|---:|
| entrypoints whose enforced-name set LOST something | **2** (both the renames above, each gaining `executor` in place) |
| entrypoints that GAINED enforced names | **48** |
| entrypoints reaching at least one ownership enforce | **816 → 846** |
| entrypoints reaching NONE | **376 → 347** |

**Thirty more entrypoints now reach an ownership enforce than when this programme started, and not
one lost one.** That is the sweep's cumulative effect on the authorisation surface, measured rather
than asserted — and it had been sitting unrecorded because the baseline had not been regenerated
since before module 1.

---

### FIFTH AND SIXTH TIME CHECK 7 CAUGHT A CASCADE-ADDED EXECUTOR WITH NO JUSTIFICATION

`DALOS|C_DeploySmartAccount` and `C_DeployStandardAccount` — *registered SELF-PROVING but the
`@doc` does not name `UEV_Any`*. The route is the owner's base case and is now written into both.
The pattern is now firm enough to state as a rule:

> **An executor that arrives by interface cascade arrives without its justification.** Six
> instances across four modules, every one found at the *receiving* module's own turn and never
> before. Running check 7 per module is what makes that true; running it once at the end would
> have found them all at once, with nobody left who remembered the route.

**And a small correction found on the way**: `DALOS|C_DeploySmartAccount`'s `@doc` read *"Deploys a
Standard Ouronet Account"* — a copy-paste from its twin, in the function whose whole distinction is
that it deploys a **smart** one.

**AND THE DELTA ENTRY ABOVE BROKE THE BUILD** — worth recording, because the failure is the
tool's, not the prose's. An `@doc` I wrote for the elite pair contained

```
\ caller typed. Read this function's output as "this account was refreshed", never as \
```

An **unescaped `"` inside a Pact string simply CLOSES it**, which is perfectly legal — so
`_docstrings.py`, which lints continuations, reported **clean**, and the module died at load with
`Cannot find module: ouronet-ns.this`. One full gate run to find out.

`scan_doc_close()` now catches it, and the invariant took two attempts:

1. *"prose must not follow the closing quote"* — flagged `(defun a () @doc "plain doc" true)`,
   a legal one-liner.
2. **the trailing backslash is the tell**: a line that CLOSES the doc string and then ends in a
   continuation `\` means the author believed they were still inside the string, and everything
   between the two is now code.

**Both mistakes were found by the tool's own `--selftest`, and only because that fixture carries
DECOYS.** The first version of the detector grepped for the literal `@doc` and fired **54 times**
— nearly all on `;;` comments that merely *mention* doc strings. In a codebase annotated this
heavily, a detector that cannot tell code from commentary about code is not a detector.

---

### 03_TS01-C2.pact — COMPLETE (77 of 77 entrypoints, 2026-09-22)

**Sixty-three of seventy-seven arrived already swept.** The remaining fourteen were pure renames —
`freezer`, `reserver`, `unreserver`, `vester`, `unvester`, `sleeper`, `unsleeper`, `hibernator`,
`awaker`, `constricter`, `brumator`, `merger` ×2 and `account` — the Talos half of the vocabulary
whose core half was settled at 11_VST's and 08_ATS's turns. Arity unchanged throughout, so **no
call site moved**: 36 body renames, 14 signatures, zero fixtures touched.

**The `REVIEW` backlog is now knowledge, not a queue.** Those names were sitting in `REVIEW`
because `ACCT` had never seen them — the state added at 11_VST's turn precisely so the tool would
be *loud* rather than assume. They have since been confirmed as accounts **by reading the bodies**,
and the cores were swept on that basis, so the vocabulary is now recorded in `ACCT`. Tree-wide
`REVIEW` fell 22 → 11.

> The distinction that keeps this honest: `REVIEW` is cleared by **checking**, never by adding
> whatever is in front of you. The eleven that remain are names nobody has read yet.

**And the selftest refused the change until its canary was fixed** — `brumator` was the REVIEW
canary, and adding it to `ACCT` made the case fail. That is the selftest doing its job: it noticed
the classifier's behaviour had moved under it. The canary is now a name that appears **nowhere in
the tree**, so it tests the *fallback* rather than a fact that can change.

---

### `FORWARDED` HAD TO LEARN THAT A PATRONLESS CALLEE'S EXECUTOR IS SLOT 1

Check 7 reported `ORBR|C_Compress`, `C_Sublimate` and `C_SublimateV2` as *"used 1x, never
proven"* while all three forward perfectly: `(ref-ORBR::C_Compress executor ignis-amount)`. The
executor is the **first** argument, because `ORBR::C_Compress` is PATRONLESS — and `FORWARDED`
required slot 2, which is the executor slot only when a patron occupies slot 0.

The registry that knows which callees are patronless already exists, **so it is imported rather
than re-typed**, and the import failure is fatal rather than silent:

> A second copy would be a second answer that drifts. CLAUDE.md records exactly that failure for
> the price sheet, and this programme has now hit it in four separate tools.

---

### THE `INDIRECT` REGISTRY: MEASURED BEFORE IT WAS TRUSTED

Adding the Talos files to `SWEPT` made the selftest's ambiguity note fire on **four** bare keys —
`C_Issue` alone matched **five** swept modules. A bare key means a route-claim written for one
function silently applies to every function sharing its name.

Rather than assume that mattered, it was **measured**: emptying `INDIRECT` and re-running shows
**nine** entrypoints depend on it, and **every one is a core module**. The colliding Talos
entrypoints pass by `DIRECT` or `FORWARDED` and never consult the registry.

So the ambiguity was **harmless today and fragile forever** — if a Talos entrypoint ever stopped
being forwarded, it would inherit a core module's route-claim and report *proven* on the strength
of a sentence written about a different function. All four are now file-qualified.

**Result: 285 proven, 0 unproven across all 19 swept modules.**

---

### 04_TS01-C3.pact — COMPLETE (34 of 34 entrypoints, 2026-09-22)

**Nineteen renames, 65 occurrences, and not one call site moved** — every one was `account` (or
`fire-starter`) → `executor` at unchanged arity. Fifteen entrypoints arrived already swept.

**Three different signature SHAPES broke three successive matchers**, which is worth recording
because the fix generalises:

| shape | example |
|---|---|
| `(defun NAME (params…)` | the common case |
| `(defun NAME:list (params…)` | a return type between name and params |
| `(defun NAME(params…)` | **no space** before the paren (`VST\|C_Merge`) |
| `(defun NAME\n    (params…)` | params on the FOLLOWING line (`SWP\|C_Fuel`) |

Each attempt matched on the LINE and each missed a different shape. The version that works stops
looking at lines: it finds `(defun NAME`, takes the **balanced extent**, and renames inside it —
which also collapses the stub-vs-implementation discrimination that the line-based versions kept
getting wrong, since both forms are handled identically.

> A matcher built from the shapes you have seen is a hardcoded list wearing a regex.

**`SWP|C_IssueStandard` is a thin alias**, delegating to its **sibling** `SWP|C_IssueStable` with
the amplifier pinned to `-1.0`. That is a **same-module** hop, and `FORWARDED` matches
cross-module `ref-X::` by design — correctly, because a foreign module is what would do the
proving and the tool can go and look, whereas an internal hop proves nothing by itself. Route
named in its `@doc` and registered.

---

### A REGISTRY ENTRY THAT COULD NEVER MATCH

The entry was first written `04_TS01-C3.pact::SWP|C_IssueStandard`. The lookup does
`bare = name.split("|")[-1]`, so a qualified key that keeps its `MOD|` prefix **can never match**
— the entry is present, readable, and **inert**.

The only symptom was the entrypoint still reporting UNPROVEN, which is the *good* case: it failed
loudly. The bad case is a registry accumulating entries nobody notices are dead — and this
programme has already found that exact shape in `_deadbind` (a live detector nobody could see),
`_toolpaths`, `_bandplan` and `_executorplan`.

The selftest now refuses any `::`-qualified key that keeps a `|` in its name part, **verified by
re-introducing the bad key and watching it fire.**

---

### 06_TS01-C4.pact — COMPLETE (14 of 14 entrypoints, 2026-09-22)

**Every entrypoint arrived already swept** from the CODEX and PYTHIA turns. Nothing in the module
changed. What it produced was a **tool** finding.

**Six admin wrappers reported *"used 1x, never proven"* while forwarding correctly.** They pass
the gasless patron as `(ref-DALOS::GOV|DALOS|SC_NAME)` — read from its single source rather than
re-declared as a local `defconst` — and `FORWARDED` required the patron slot to be a **bare
token**, `[\w\-|]+`. An expression in that slot was invisible.

> **Fourth time a pattern in this checker has assumed a simpler argument shape than the code
> has**, after the hyphenated member name and the two in `_deadbind`. The symptom is identical
> every time: a **silent under-report** — the tool saying *"never proven"* about code that proves
> it. Now `(?:\([^()]*\)|[\w\-|]+)`, pinned by two new selftest cases including the negative
> one (an executor in slot 3 stays the *executee* position even when the earlier arguments are
> expressions).

After the fix: **396 proven, 0 unproven** across the swept modules.

---

### 05_TS01-P.pact — COMPLETE (8 of 8 entrypoints, 2026-09-22)

Eight `account` → `executor` renames across the defpact wrappers, 24 occurrences, arity unchanged,
**no call site moved**. The module is `TS01-CP`, not `TS01-P` — worth noting only because
`_modulecomplete` takes the MODULE name and the FILE name differs.

---

### 02_DPDC.pact — COMPLETE (2 of 2 entrypoints, 2026-09-22)

`C_UpdatePendingBranding` gained `patron` + `executor`; `C_UpgradeBranding` gained `executor`.
HANDOFF §4g once more: `DPDC|C>UPDATE-BRD` → `CAP_Owner entity-id son` →
`CAP_EnforceAccountOwnership (UR_OwnerKonto entity-id son)` — **derived**, no actor named. A new
`UEV_ExecutorIsOwnerKonto` binds it, and the ownership enforce is kept.

**`son` IS PART OF THE KEY, NOT DECORATION** — and that is the thing to get right here. DPSF and
DPNF are **separate tables**, and the same id can exist in both, so an owner lookup without `son`
is a lookup of *a different token*. The binder reads through `UR_OwnerKonto` with the same
`(entity-id son)` pair the capability uses, so the two cannot disagree about which token they are
discussing — and the migration rules are split accordingly: `DPSF|*` resolves with `true`,
`DPNF|*` with `false`, even though the two Talos signatures are identical.

**Deferred deliberately: `03_DPDC-C`'s two nonce creators.** Their ownership enforce is
**conditional** — `(if (not (and (not son) sft-set-mode)) (CAP_EnforceAccountOwnership
r-nft-create-account) true)` — so a binder placed unconditionally would add a requirement in the
branch that deliberately has none, and one placed inside the branch leaves the executor unproven
in the other. That is a design question, not a mechanical one, and it gets its own turn rather
than a place in a batch.

---

### 03_DPDC-C.pact — COMPLETE (2 of 2 entrypoints, 2026-09-22)

The module deferred from the last batch, because its ownership enforce is **conditional**:

```pact
(if (not (and (not son) sft-set-mode))
    (ref-DALOS::CAP_EnforceAccountOwnership r-nft-create-account)
    true)
```

**What the bypass is for, established by tracing every caller.** Both Talos client wrappers pass
`sft-set-mode = false`, so for a client the ownership enforce **always** runs. The only
`sft-set-mode = true` site is `08_DPDC-S`'s NFT-set path, where a nonce is spawned as an internal
consequence of an action DPDC-S has already authorised — and demanding the role holder's
**signature** there would be wrong, because the module is acting, not the role holder. The bypass
is deliberate and justified.

---

### THE RESOLUTION: A BINDER IS AN EQUALITY CHECK, NOT A SIGNATURE CHECK

That single distinction settles the design question the conditional posed:

- **Mirroring the condition** would leave the executor *decorative* on the internal path — a name
  nobody checks, which the canon rates worse than absent.
- **Binding unconditionally** adds **no authority requirement at all**. `UEV_ExecutorIsCreateRole`
  is `(enforce (= executor (UR_Verum5 id son)))` — it demands only that the caller *name* the
  account the operation is really attributed to, which the internal caller can compute as easily
  as the capability can.

So attribution becomes **total** while the deliberate signature bypass is left exactly as it was.
`r-nft-create` is also a **different derived account** from the `UR_OwnerKonto` that `02_DPDC`'s
branding pair uses — same module, same id, two distinct authorities — so the migration rules read
`UR_Verum5`, not `UR_OwnerKonto`. Reading the wrong one would have produced a binder that refuses
every legitimate call.

---

### TWO MISTAKES, AND A NEW STATIC CHECK OUT OF THE SECOND

**I assumed a `patron` was in scope in `08_DPDC-S` and it was not** — none of the four enclosing
functions has one, because that module is itself unswept. Pact reports an unbound name as
*`Cannot find module: ouronet-ns.patron`*, which reads like a missing dependency and is not. The
slots now carry the account each function actually knows: the user's `account` in
`C_MakeNonFungibleSet`, the DPDC smart account in the three `C_Define*Set` variants — `06_VCT`'s
precedent for *"no user account is in scope at all here"*.

**And two `require-capability` sites, two internal hops away, still named the old capability
shape.** `_callarity.py` could not see them: **a capability acquisition is not a function call.**
Pact does catch it — at LOAD — so it is not a silent hole; what it is, is an expensive way to find
out. The symptom is `Attempted to apply a closure to too many arguments` during a five-minute gate
run, with every suite touching the module reporting BROKEN.

`_callarity.py` now makes a **second pass over `with`/`require`/`compose-capability`**, comparing
each acquisition against its `defcap` declaration within the module, and it is fatal. Same
rationale `_docstrings.py` was written under — *"the 2-second check that two 5-minute gate runs did
not do"*. **Verified by re-introducing the exact bug and watching it report
`DPDC-C|C>REGISTER-SINGLE-NONCE wants 6, got 5`.**

> The general shape, now seen at both ends: a signature change must reach **every place the name
> is written**, and "call site" is narrower than that. Capability acquisitions, `require`s two
> hops down an internal chain, and registry keys in the tooling are all places the name appears
> and none of them is a call.

**Call sites re-pointed: 70** across 27 files, plus 5 hand-threaded internal hops.

---

### 04_DPDC-I.pact — COMPLETE (1 of 1 entrypoint, 2026-09-22)

**Both roles were already present under other names, and the module had already argued the
distinction without having a word for it.**

`DPDC-I|C>ISSUE` runs `CAP_EnforceAccountOwnership` on `owner-account` — a **parameter**, proven
directly — so that is the executor. And `creator-account` is the executee, with the capability's
own `@doc` supplying the rationale: audit **#53L** ruled it *deliberately* not ownership-checked,
so an owner may designate a trusted associate as creator **without that account's separate consent
or signature**, with only the type validated.

> Acted upon, needing no signature, only shape-checked. That is the executee test **verbatim** —
> decided by an audit two rounds before this canon existed. The sweep did not discover the
> distinction here; it found the vocabulary for a ruling already made.

`(patron son owner-account creator-account …)` → `(patron executor executee son …)`. **A rename
and a reorder, not an addition** — nothing about who may call this function changed. Arity is
unchanged, so `_callarity` sees nothing; the three sovereign call sites were reordered by hand and
`modules/DPDC.repl` + `modules/EQUITY.repl` run green.

---

### 05_DPDC-R.pact — COMPLETE (11 of 11 entrypoints, 2026-09-22)

§4g **across an entire module**, the second after `15_SWP`: all eleven are gated by
`DPDC::CAP_Owner id son` → `CAP_EnforceAccountOwnership (UR_OwnerKonto id son)`, derived, no actor
named. Each gained `patron` + `executor`, and the **role recipient became the executee** — the
capabilities validate its *state* (`UEV_AccountBurnState`, `UEV_AccountAddQuantityState`) but never
its ownership.

**One binder, bound once.** `UEV_ExecutorIsOwnerKontoLocal` wraps `DPDC::UEV_ExecutorIsOwnerKonto`
so the modref is bound in one place rather than at eleven call sites. `C_ToggleAddQuantityRole`
passes the literal `true`, matching its own capability, which already hardcodes `(CAP_Owner id
true)` because add-quantity is semi-fungible only.

**The migration tool was deliberately NOT used, and the comment left in it says why.** These went
`(patron id account toggle)` → `(patron executor executee id toggle)`: an **insert *and* a swap**,
because the executee takes slot 2 and pushes the entity id down. `_executormigrate` only inserts.
Running it anyway would have produced the right **arity** with `id` and the recipient **exchanged**
— which `_callarity` cannot see and no test necessarily catches, since both are strings. 114 sites
were rewritten by a bespoke insert-and-swap pass instead.

**And the helper landed in the INTERFACE section first.** An interface holds declarations only, so
the module stopped loading with `Expected: [')']` at the `(let`. The cause is the same stub-vs-
implementation trap that has now appeared four times this programme: *the first `(defun NAME` in a
file that contains both is the declaration, not the code.* Relocated into the module body, where
it needs no interface stub at all — nothing outside the module calls it.

---

### 06_DPDC-MNG.pact — COMPLETE (12 of 12 entrypoints, 2026-09-22)

**The most hidden actor/target split the sweep has found.** `C_BurnSFT` and `C_WipeSlim` have
**identical signatures** — `(account id nonce amount)` — and **opposite actors**:

```pact
;; DPDC-C, three hops down, at the bottom of both chains:
(if wipe-mode
    (ref-DPDC::CAP_Owner id son)                        ;; WIPE  -> the collection owner
    (ref-DALOS::CAP_EnforceAccountOwnership account))   ;; BURN  -> the account itself
```

The burns pass `wipe-mode false`, so their `account` **is** the executor — a pure rename. The
wipes pass `true`, so their `account` is the **executee** and the executor is the derived
`(UR_OwnerKonto id son)` — §4g, needing a new binder.

> **Nothing in this module distinguishes them.** Not the name, not the type, not the position, not
> the capability it opens. The discriminator is a boolean argument handed to a capability **two
> modules away**. Reading these twelve signatures cannot tell you which is which; only following
> `wipe-mode` can — and the module's own comments say only *"Account Ownership - via Debit
> Function"*, which is true and insufficient.

Third instance of "same shape, opposite role" in this sweep, after the admin/client
`C_DeployAccount` pair and `C_Register`/`C_ReleaseStoicTag` — and by far the least visible, because
the other two could at least be settled by reading one file.

**Split:** 4 renames (`C_AddQuantity`, `C_RespawnNFT`, `C_BurnSFT`, `C_BurnNFT`), 6 wipes gaining
`executor` + executee-rename + a binder, 2 spec ops (`C_Control`, `C_TogglePause`) gaining
`executor` + a binder. **~110 call sites** in four distinct shapes.

**Two credit ops nearly got the wrong explanation.** `C_AddQuantity` and `C_RespawnNFT` prove their
executor **in this module's own capability**, not down the debit chain — they are credits, and
never touch `DPDC|CX>MULTI-DEBIT`. A shared `@doc` template had given all four "renames" the burn
rationale. Corrected: a template that is right for most members of a group is wrong for the group.

---

### FOUR DEAD BINDINGS, TWO OF WHICH WERE ALIVE

The map surfaced two genuinely dead `(owner (UR_OwnerKonto id son))` bindings — table reads on live
paths, discarded. A blanket textual removal took **four**, because the same expression appears in
two `URCi_` gas-preview readers **where it is read**. Restored, with the rule recorded at the site:

> **Dead-binding cleanup has to be per SITE, never per TEXT.** The same expression is waste in one
> function and load-bearing in another, and the only difference is whether the body reads it.

And removing the two real ones left their `ref-DPDC` modref with no consumer — which
`_conformance.py`'s `[dead-modref-binding]` rule reported immediately. **Two dead things, one of
which only became visible once the other went.**

---

### A THIRD ARITY BLIND SPOT: THE SAME-MODULE CALL

`C_WipeClean`, `C_WipeDirty` and `CC_WipeHeavy` all delegate to `C_WipePure` **within the module**.
Those three calls kept the old 4-argument shape, and `_callarity.py` reported **clean** — it checks
`ref-X::` modref calls, and these have no prefix.

Pact does not reject it at load either: the short call is a **partial application**, so the failure
surfaced as `Runtime typecheck failure, argument is bool, but expected type string` inside a test.
**A same-module call that no test exercises would ship silently** — which is, word for word, the
rationale `_callarity` was written under for modref calls.

Two of the three gaps are now closed (modref calls, capability acquisitions). **The same-module
function call is the third and is NOT yet covered** — recorded here rather than built in haste,
because distinguishing a bare function call from a native, a `let`-bound name and a lambda argument
is where a careless pass produces false positives across the whole tree.

**And `patron` was assumed in scope for a second time**, in three `XI_` helpers of `11_EQUITY+`
that do not have one. They have `account` — the user whose shares are being converted — which is
the account that actually initiates. Same symptom as `08_DPDC-S`: Pact reports an unbound name as
*"Cannot find module: ouronet-ns.patron"*.


---

### 07_DPDC-T.pact — COMPLETE (4 of 4 entrypoints, 2026-09-22)

The collectable **movement primitive**. Four entrypoints, and they produced the widest call-site
tail of any module so far: **86 arity-preserving reorders** across 35 files, **24** direct core
calls, **10** Talos wrappers in `TS02-C1`/`TS02-C2` reordered to canon, and **7** repurpose sites
that needed an executor invented from the collection owner.

| entrypoint | before | after | executor proven |
|---|---|---|---|
| `C_Transfer` | `(ids sons sender receiver nonces-array amounts-array method)` | `(patron executor executee ids sons nonces-array amounts-array method)` | DIRECT — `CAP_EnforceAccountOwnership sender`, unconditional |
| `C_BulkTransfer` | `(id son nonces-array amounts-array sender receiver-lst method)` | `(patron executor executee-lst id son nonces-array amounts-array method)` | DIRECT |
| `C_RepurposeCollectable` | `(id son repurpose-from repurpose-to nonces amounts)` | `(patron executor executee id son repurpose-to nonces amounts)` | §4g — new binder in the capability |
| `C_IgnisRoyaltyCollector` | `(patron sender ids sons …)` | `(patron executor ids sons …)` | DIRECT — **the enforce is new** |

#### A transfer and a repurpose look the same and are not

`C_Transfer` and `C_RepurposeCollectable` both move nonces from one account to another. In the
first, the account losing the nonces **signs**; in the second it does not, and the authority is
the **collection owner** — enforced three hops down in `DPDC-C::DPDC|CX>MULTI-DEBIT` by the same
`(if wipe-mode (CAP_Owner id son) …)` fork that module 29 found for burn-vs-wipe, reached here
with `wipe-mode` hardcoded `true` at every debit leg.

So `repurpose-from` is the **executee** and the executor was nowhere in the signature — §4g,
"authority proven, actor unrecorded", now the fourth module to show it. `DPDC-T|C>REPURPOSE`
gained the binder (`DPDC::UEV_ExecutorIsOwnerKonto`), exactly as `VST|C>REPURPOSE-TRUE-FUNGIBLE`
did for the vesting side.

**The binder also made a refusal legible.** `modules/DPSF-UPDATES.repl` `<<DSU-05>>` carried a
standing complaint in its own comment: a non-owner's repurpose was rejected by a *keyset failure
naming the owner's key*, which "tells a caller which key was wanted rather than which rule they
broke". There are now **two** assertions, because there are now two distinct refusals — naming
yourself fails **by name**, naming the real owner fails **by keyset** — and one assertion cannot
tell a working gate from a renamed one.

#### An unenforced executor, and why it was worth an enforce

`C_IgnisRoyaltyCollector` took `sender`, **read it, and never proved it**. That is not decoration:

```pact
(if (= sender creator) 0.0 …)        ;; URC_SummedIgnisRoyalty
```

A caller free to name any sender is a caller free to name **the creator** and pay no royalty at
all — out of the patron, to the creator's loss. Unreachable from a client today (`P|UEV_IMC`
admits only registered modules, and all five call sites pass an account a sibling call in the
same transaction proves), but *"proven by my caller's other call"* is not a property this
function holds. §4f is explicit that an unenforced executor is worse than none, so the ownership
enforce was **added**; it is a no-op at every existing site by construction.

#### A dead binding was publishing a wrong price

`_deadbind` reported `price` and `trigger` dead in `C_RepurposeCollectable`. They were the tail of
a whole **duplicated cost model** — `owner`, both tier legs, the sum, the price, the virtual-gas
trigger — every value of which is recomputed identically inside the `URCi_` call that ends the
function. Left behind when the cumulator was factored out.

Deleting it moved a **published figure**, because `_ignis_price_sheet` reads the tier legs a
function body mentions: `s` and `m` bound *both* tiers where `(if son s m)` charges *one*, so the
sheet summed them and quoted a floor of **5** for an op whose floor is **2** (SFT) or **3** (NFT).

Its twin in `09_DPDC-F::C_RepurposeCollectableFragments` had the identical dead block and the same
wrong legs — fixed in the same pass, because the price is wrong *now*, not at that module's turn.

And that exposed a third thing. The two functions compute the **identical** price shape and were
classified **differently**: `C_Repurpose` published `COMPLEX / ≥ n`, `C_RepurposeFragments` an
*exact* `$0.05`. The reason is that `SCALES` — the "does this charge scale?" test — partly matches
the literal phrases `per-nonce` / `price-per-nonce`, and it runs over text that **includes `@doc`
prose**. One cost-preview doc says "per-nonce construct priced" and the other says "per-fragment".

> **A published price class was resting on a hyphenated word in a comment.** Fixed by matching the
> structure the docs were describing — `(dec (fold …))` — so the classification no longer depends
> on prose. Tally moved `185 exact · 135 floor` → `183 · 137`. No account's charge changed; what
> changed is what the sheet *says*, which is the thing an integrator quotes.

#### The tool that could not report its own incompleteness — fifth instance

`_patronslots.py` exists to see the one invisible thing in this refactor. It kept a **hand-written
list** of which callees already take a `patron`, and module 29 did not add itself to it — so
**four** provisional slots in `11_EQUITY+` were invisible to the only tool that looks for them,
for a day. `SWEPT` is now derived from the source (first parameter is literally `patron`), which
immediately found **two more** in `04_TS01-C3` the list had never covered. Registered count
**25 → 48**. See HANDOFF §4i.


---

### 08_DPDC-S.pact — COMPLETE (10 of 10 entrypoints, 2026-09-22)

Ten entrypoints, **two different authorities**, and nothing in the signatures said which was
which. 118 call sites: 77 rewritten by `_executormigrate`, 41 by hand in two citizen minters.

| group | entrypoints | executor | proven by |
|---|---|---|---|
| acts on a **holding** | `C_MakeSemiFungibleSet`, `CC_BreakSemiFungibleSet`, `C_MakeNonFungibleSet`, `C_BreakNonFungibleSet` | the acting account (a **rename** of `account`) | FORWARDED — `DPDC-T::C_Transfer` → `CAP_EnforceAccountOwnership sender` |
| acts on the **definition** | `C_DefinePrimordialSet`, `C_DefineCompositeSet`, `C_DefineHybridSet`, `C_EnableSetClassFragmentation`, `C_ToggleSet`, `C_RenameSet` | the **collection owner** (an **addition**) | §4g — `DPDC::CAP_Owner id son`, bound by `UEV_ExecutorIsCollectionOwner` |

**The collection owner has no say in whether a holder assembles a set; a holder has no say in what
a set IS.** That is the line. `DPDC-S|C>MAKE` and `DPDC-S|C>BREAK` look like authorisation gates
and are not — they check shape and state only, and prove no account at all. The authorisation for
those four happens a module away, in `DPDC-T`.

> Deciding this **per module** rather than per entrypoint would have been right for `05_DPDC-R`
> (one authority, eleven entrypoints) and wrong here, with no local signal that anything was off.
> "Which capability does it open" is not the question. "What does that capability prove" is.

#### Two citizen minters had to read the owner

`BLOODSHED-SETS` (40 sites) and `KBunnies` (1) drive the set definitions through Talos, and their
populators take only `(patron dhb)` — no executor to thread. The owner is **read**:
`(ref-DPDC::UR_OwnerKonto dhb false)`, the same expression the module's binder evaluates, so the
two cannot disagree.

It is deliberately **inlined at each call site** rather than bound once in the enclosing `let`.
`let` is eager in Pact, and this programme's standing rule is never to read an owner eagerly: a
collection that does not exist yet turns a clean refusal into a raw table abort. `BLOODSHED-SETS`
got one `UR_DhbOwner` helper so the `DpdcV2` modref is bound in one place rather than twelve.

#### `_patronslots.py` was silently narrowing its own input

Two gaps in one regex, both live:

* `C_[A-Za-z]+` could not match `CC_`, nor any name with a digit or hyphen. **Every heavy client
  op in the tree is a `CC_`**, and the tool had never looked at one.
* the first-argument group could not match a **parenthesised expression**, so a patron slot
  holding `(ref-DPDC::GOV|DPDC|SC_NAME)` — exactly what this module's three `C_Define*Set`
  variants passed before their turn — was not merely unregistered, it was **invisible**. The tool
  printed *"every non-`patron` patron slot is registered"* over three slots it had never seen.

> A checker that silently narrows its own input is worse than no checker, because it reports the
> narrowing as a pass. Same class as `_executorenforced`'s FORWARDED matcher a week earlier, and
> the same one-line moral: **a matcher built from the argument shapes you happen to have seen is a
> hardcoded list wearing a regex.**

Eight provisional patron slots **cleared** at this turn (four `DPDC-T` legs, four
`C_CreateNewNonce`), and the binder helper is now spelled `UEV_ExecutorIsCollectionOwner` in all
three DPDC modules that have one — `05_DPDC-R`'s `UEV_ExecutorIsOwnerKontoLocal` was renamed to
match. See HANDOFF §4j.


---

### 09_DPDC-F.pact — COMPLETE (4 of 4 entrypoints, 2026-09-22)

Fragmentation: splitting a whole collectable nonce into 1000 fragments and rejoining them. Four
entrypoints, and **all three shapes the DPDC family has produced appear here at once**:

| entrypoint | executor | proven by |
|---|---|---|
| `C_MakeFragments`, `C_MergeFragments` | the acting account (**rename**) | FORWARDED — `DPDC-T::C_Transfer` |
| `C_EnableNonceFragmentation` | the collection owner (**addition**) | §4g — `DPDC::CAP_Owner id son` |
| `C_RepurposeCollectableFragments` | the collection owner (**addition + executee**) | §4g — `wipe-mode TRUE` at every debit leg |

The third repurpose of the sweep after `11_VST` and `07_DPDC-T`, and by now the shape is
recognisable on sight: the account in the actor position is the **target**, the authority is
derived, and the capability that carries the `@event` proves nothing at all.

#### A test comment had been describing this defect for two weeks

`[6.1.2]_DPDC-FRAGMENTS.repl` `TX-FRAG-003` carries the banner

> *"non-owner repurpose rejected (`DPDC-F|C>REPURPOSE` only checks list-length; the real gate is
> `CAP_Owner`, downstream in the wipe-mode debit leg)"*

— an accurate description of §4g written before §4g had a name. The gate is still downstream; what
is new is that the **actor is named first**, so the three ways to get this wrong are now three
different refusals rather than one:

| attempt | refused by |
|---|---|
| EMMA names **herself** as executor | the binder, **by name** — *"Executor is not the Entity Owner"* |
| EMMA names the **real owner** | the keyset — she cannot sign for him |
| patron **and** executor are the real owner, signer is EMMA | the keyset — proving the refusal tracks the **signer**, not either argument |

All three are pinned. The middle one is the original assertion, unchanged in meaning but now
reached *deliberately* instead of by accident.

#### Why `_executormigrate` was not pointed at the repurpose

77 + 15 call sites were rewritten by the tool; the repurpose's **eight** were done by hand, and the
rule for it is deliberately absent with the reason recorded in `RULES`:

> `C_RepurposeFragments` is an **insert AND a swap** — `(patron id repurpose-from repurpose-to …)`
> became `(patron executor executee id repurpose-to …)`. The tool only inserts, so running it here
> produces the right **arity** with `id` and the executee exchanged — silently, because arity is
> all `_callarity` can see.

Same reason `05_DPDC-R` is absent from that table. Two provisional patron slots cleared.


---

### 10_DPDC-N.pact — COMPLETE (8 of 8 entrypoints, 2026-09-22)

Nonce metadata: name, description, score, royalties, URIs, the whole mutable bag. Eight
entrypoints, **eight straight renames**, and the reason is the interesting part.

Every DPDC module before it bottomed out in `DPDC::CAP_Owner id son` — an enforce on a **derived**
account that names no actor, §4g — and every one needed a binder: `05_DPDC-R` (eleven),
`06_DPDC-MNG` (the six wipes), `08_DPDC-S` (the six definition ops), `09_DPDC-F` (two). This one
does not. All eight funnel into `DPDC-N|C>DATA`:

```pact
(UEV_NonceDataUpdater id son account nosc nos nost)
(UEV_NotSetInstance id son nosc nost)
(ref-DALOS::CAP_EnforceAccountOwnership account)      ;; <- on the PARAMETER
```

and the capability above it first checks the **same account holds the role** —
`UEV_RoleNftUpdateON`, `UEV_RoleModifyRoyaltiesON`, `UEV_RoleSetNewUriON`. Role **and** signature,
both on the named account.

> **Metadata is delegated by ROLE; the rest of DPDC is gated by OWNERSHIP.** An owner can hand out
> the update role and stop being the actor, which is exactly why the actor has to be a parameter
> here and cannot be one anywhere else in the family. The executor was present all along under the
> wrong name.

#### Two wrappers that the name filter missed

`DPSF|C_RemoveNonceScore` and `DPSF|C_RemoveSetNonceScore` (and the DPNF pair) are thin aliases
that delegate **within Talos** to `C_UpdateNonceScore` with a literal `-1.0`. The pass that
rewrote the 36 `C_Update*` wrappers matched on the name and did not touch them — and their
delegation is **arity-preserving**, six arguments before and after, so nothing downstream could
have objected:

```pact
(DPSF|C_UpdateSetNonceScore patron id account set-class nos -1.0)   ;; would still load
```

`_callarity`'s same-module pass — built one module earlier for exactly this — sees only arity, so
a swap of `id` and `account` inside a correct count is invisible to it. Caught by grepping for the
**old parameter shape** `(patron:string id:string account:string` rather than for the names
already known to need changing. *A signature change must reach every place the name is written,
and "the names I listed" is narrower than that.*

#### 106 call sites the arity checker could not see

The 40 Talos wrappers went from `(patron id account …)` to `(patron executor id …)` — a **swap of
slots 1 and 2**, arity unchanged. Rewritten by a one-shot pass that **reads each wrapper's arity
out of the Talos source** rather than declaring it, because a hardcoded arity that is wrong
matches nothing and reports success. Run once, then parked: an arity-preserving reorder is not
idempotent.


---

### 11_EQUITY+.pact — COMPLETE (2 of 2 entrypoints, 2026-09-22)

Two entrypoints, and the interesting one produced **a finding, a fix, and then a correction of the
finding** — in that order, because the fix was measured instead of assumed.

| entrypoint | before | after |
|---|---|---|
| `C_IssueShareholderCollection` | `(patron creator-account …)` | `(patron executor …)` + a **new ownership enforce** |
| `C_MorphPackageShares` | `(account id …)` | `(patron executor id …)` |

#### A module with no ownership check of its own

`11_EQUITY+.pact` contains **no `CAP_EnforceAccountOwnership` and no `CAP_Owner`** — not one, in
900 lines. Its issuance calls `DPDC-I::C_IssueDigitalCollection patron dpdc creator-account …`, and
`DPDC-I|C>ISSUE` runs its ownership check on the **owner**, which for an equity collection is
`dpdc`, the DPDC smart account, because the collection is automanaged.

> So the account that check proves is a **module**, not a person. And `creator-account` — who
> collects the royalties — was named by the caller and never checked *here*.

The turn added `(CAP_EnforceAccountOwnership executor)`, first, ahead of the `ipfs-links` shape
check, per the 2026-09-14 ruling that authorisation precedes validation.

#### Then the measurement contradicted the claim

The first version of the guard's `@doc` — and of the new `<<EQ-G2>>` test comment — said the guard
**closed a hole**. It does not. Disabling the enforce and re-running `modules/EQUITY.repl` with the
four `coin.TRANSFER` funding signatures installed, so nothing else could refuse:

| assertion | without the guard |
|---|---|
| *ANHD cannot found a company in EMMA's name* | **still passed** — same `Keyset failure (keys-all): [PK_Emma…]` |
| *…and the ownership refusal precedes the link-count one* | **failed** — reported `24 IPFS links must be provided` |

EMMA's consent was already required, **three modules away and two writes later**: the `ico3` leg
calls `DPDC-C::C_CreateNewNonces`, whose authority is `CAP_EnforceAccountOwnership` on the derived
`(UR_Verum5 id son)` — the create-role account — which on a freshly issued collection *is* the
creator.

So the guard changes **when** and **with what message**, not **whether**. It is still worth having:
the old proof is **incidental** (it holds only while the create-role account is the named creator —
an invariant of issuance, not of this function) and **late** (after the collection is issued and its
branding written). Both `@doc` and test comment were rewritten to say exactly that.

> This is the second time in this programme a comment claimed more than was observed
> (`<<ORBR-FEE3b>>` was the first). The rule that caught it both times: **when you add a guard, add
> a test that fails without it — and then actually run it without it.** The first assertion here
> does *not* depend on the guard and is kept, relabelled, as a property test; the second is the one
> that discriminates, and the comment says which is which.

#### And an unescaped `"` broke the build again

Writing `"Keyset failure (keys-all): [PK_Emma...]"` inside a Pact `@doc` **closes the string**, and
the rest of the line parses as code. `_docstrings.py` — built after the first occurrence — caught
it statically, named the file, the line and the reason, before any suite ran. The gate runs it
first for exactly this reason: a module that does not load makes every other check meaningless.

Three provisional patron slots cleared, and `C_MorphPackageShares` registered as INDIRECT — its
executor reaches `DPDC-T::C_Transfer` through a **same-module** `XI_` helper, which `FORWARDED`
does not match by design.


---

### 00_Demipad.pact — COMPLETE (10 of 10 entrypoints, 2026-09-22)

The sovereign launchpad. Ten entrypoints across three bands — four **admin** ops, a
deposit/withdraw pair, and four **transmit** ops — and the admin band is where the finding is.

#### An admin keyset answers "may this happen", never "who did it"

`A_RegisterAssetToLaunchpad`, `A_ToggleOpenForBusiness`, `A_DefinePrice` and `A_ToggleRetrieval`
are gated by `DEMIPAD|C>SECURE-ADMIN` → `GOV|DEMIPAD_ADMIN` — a keyset **shared by every launchpad
admin**. Three of the four took no `patron` and none took an executor, so the `@event` each emits
recorded that *an* admin acted and never which one. Each now takes `patron` + `executor`, with
`CAP_EnforceAccountOwnership` run **before** the admin capability is acquired, exactly as
`LIQUID::A_MigrateLiquidFunds` and the DALOS admin band already do.

**Measured without the guard** (`modules/DEMIPAD.repl` `<<DEMIPAD-G3>>`, all four enforces
disabled, file re-run):

| assertion | without the guard |
|---|---|
| admin toggles retrieval, attributes it to EMMA | reached the idempotence guard — `Retrieval is already true` |
| admin sets a price, attributes it to EMMA | **`Asset TSFS-… price succesfully updated`** — the op *succeeded* |
| non-admin signs for herself | unchanged — the ADMIN gate still refuses |

> The second row is the finding in one line: **before this turn an admin could change a launchpad
> price and have the event name somebody else.** The third is the control that shows the two gates
> are distinct rather than one gate tested twice. The block is a `rollback-tx`, because an
> `expect-failure` whose subject *mutates* when the guard is absent must never share a committing
> transaction — and that measurement is precisely why the rule exists.

#### The rest

`C_Deposit` (`donor` → `executor`) and the four transmits (`client` → `executor`) are FORWARDED:
`DEMIPAD|C>DEPOSIT` only *type*-checks the account, and the `C>FUEL-*`/`C>RETRIEVE-*` capabilities
gate on the **asset**, not on any account. The proof comes from the leg that actually spends —
`TFT::C_Transfer`, `LIQUID::C_WrapStoa`, `TS01-C1::DPTF|C_Transfer`, `DPDC-T::C_Transfer`.

`C_Withdraw` is §4g **with a disjunction**: `DEMIPAD|C>REGISTERED-ACCESS` is an `enforce-one` over
the asset owner (derived, via a user-guard on `CAP_Owner`) **or** the launchpad admin keyset.
Either may withdraw, so no binder can name the actor; the executor is proven on its own terms
instead, which says the named account signed without claiming *which* branch it satisfied.

#### The stub-vs-implementation trap, fifth and sixth occurrences — and a trailing space

Three bodies were silently missed because `re.search` found the **interface stub** at the top of
the file instead of the implementation. What makes this instance worth recording is the
discriminator: `C_TransmitSemiFungibles`'s stub ends in a **trailing space** and
`C_TransmitNonFungibles`'s does not, so the *same* regex matched the body for one and the stub for
the other. Two functions, one edit, opposite outcomes, invisible in a diff.

> Fixed by the rule `_ignis_price_sheet.defun_body` already uses and that every future scoped edit
> in this programme will: **the implementation is the LAST match, never the first.**

`_callarity` caught one of the three (the arity changed); `_modulecomplete`'s interface-drift check
would have caught all three. Two INDIRECT routes registered — the two collectable transmits reach
`DPDC-T::C_Transfer` through a same-module `XI_` helper, while their true/orto siblings call Talos
directly and pass by FORWARDED. Four functions, one job, two classifications, decided purely by
whether a local helper sits in the middle.


---

### 01_ANK.pact — COMPLETE (2 of 2 entrypoints, 2026-09-22)

Two entrypoints left in the anchors module, both revokes. One was an attribution; the other was
**an authorisation gap**.

#### `C_RevokeBoostClass` checked no account at all

`ANK|C>REVOKE-BOOST-CLASS` validated exactly two things — the class is **empty** and the class is
**active** — and nothing else. **Any account reachable through Talos could revoke any empty
BoostClass that was not theirs.**

Not a funds hole: an empty class holds no anchors by construction. It is a denial vector that costs
the victim real money, because re-creating a class is the **2× STOA** inline path in
`C_Issue*Anchor`.

> **The attach path already enforced exactly this, and had since 2026-09-19.** The `class-owner`
> field and `UEV_AttachToExistingClass`'s `(CAP_EnforceAccountOwnership (at "class-owner" bc))`
> were added together, with a schema comment explaining why. The **revoke** path was not carried
> over with them. Same field, same rule, one path short — and the sweep found it because the canon
> forces the question *"who is the actor?"* at every entrypoint, including the ones nobody
> suspected.

Measured (`modules/AQP.repl` `<<AQP-G37>>`, guard disabled): the un-owned revoke reached the
*already-inactive* enforce instead of being refused by name. The fixture's class is inactive, so
the call still failed there; on an empty **active** class it would have succeeded, because those
two enforces were the only ones in the capability.

#### And the binder had to go BELOW the liveness gate

`C_RevokeAnchor` is ordinary §4g — `ANK|C>REVOKE` runs `CAP_Owner anchor-id`, which resolves the
**anchored asset's** authority, a derived account. `UEV_ExecutorIzAnchorAuthority` already existed
(written for MTX-AQP) and is a **disjunction**, not an equality, because a collectable has two
authorities (owner **or** creator) where a DPTF has one.

Placing it in the defun body, ahead of the capability, would have broken
`[6.2.10] <<TX-AQP-NEG-OWNER2>>`: that test revokes a **non-existent** anchor and pins the
*liveness* message, which was itself only made reachable by turning `UR_ANK|State` into a defaulted
read. The binder resolves the anchored asset out of the anchor row, so it would have raised a raw
table error and replaced the message the test exists for.

> **"Never read an owner eagerly — the entity may not exist yet"** is in the handoff's rules list,
> and this is the first time in the sweep it had a named test standing behind it. The binder sits
> inside the capability, after `UEV_LiveAnchor`.

#### The fixtures had to name the derived authority, not the patron

The first pass gave all 18 call sites `patron` as executor and the suite went **BROKEN**: the
anchored asset in `[6.2.1]` is `OURO`, owned by a `Σ.` **smart account**, not by the human patron.
The fixtures now read the authority with the same expression the binder evaluates —
`(URC_AnchorableAssetOwner (UR_ANK|AnchoredAsset id) (UR_ANK|Fungibility id))` — which is the
template `_executormigrate` already carried for `AQP-FVT|CC_SweepRevokeAnchor`.

> `executor = patron` is not a safe default. It is in the rules list for this reason, and it cost a
> gate run to be reminded.


---

### 02_SCORE.pact — COMPLETE (14 of 14 entrypoints, 2026-09-22)

The largest AQP core module. 128 call sites: 51 by `_executormigrate`, 10 in a citizen minter, 8
by hand, the rest in Talos. Three shapes, and one of them the module had already written down.

#### Eight dead bindings of the same §4g expression

`C_Control`, `C_CreateBoostClassLink`, `C_CreateBoostLink`, `C_EnableDebBoost` and the three
`C_Issue*ScoreDefinition` ops each opened with

```pact
(let ( (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id)) ) …)
```

and **never read it**. Eight dead bindings, all of the *same* expression, all reported by
`_deadbind`, all sitting in functions whose capability enforces
`CAP_EnforceAccountOwnership` on exactly that derived account.

> That is what §4g looks like from the inside. The derived actor is so obviously the subject of the
> operation that somebody bound it by reflex — and the signature had nowhere to put it, so the
> binding went nowhere. `UEV_ExecutorIzScoreOwner` now *is* that expression, and each dead binding
> was replaced by the call rather than merely deleted.

#### Two executors were proven, and the matcher could not see either

`_executorenforced` reported `C_IssueTriplet` and `C_IssueScoreFromModel` UNPROVEN. Neither is.

* `SCR|C>ISSUE-TRIPLET` binds `(= executor owner-konto)` inside its compound enforce **and**
  separately runs `CAP_EnforceAccountOwnership owner-konto`. Both halves of §4g were already there
  — written correctly before the canon existed. The matcher looks for the enforce applied to
  `executor`; here it is applied to the name `executor` was just proven equal to.
* `C_IssueScoreFromModel` reaches `SCR|XI>ISSUE-SCORE` through the same-module
  `XI_IssueOneFromModel` — the internal-hop shape `FORWARDED` declines by design.

Both registered as INDIRECT with the route named, and the registry comment keeps the *two different
reasons* visible rather than collapsing them into one.

#### Removing a binding can delete a `let`

Four of the eight `let` forms bound **nothing else**. Deleting the dead binding left
`(let ( ) …)`, which Pact rejects with `Expected: ['(']` — a **load** error, so 55 suites reported
BROKEN with zero assertions. The empty forms were collapsed and the bodies dedented.

> A dead-binding removal is not always a deletion. When it is the *last* binding, it is a
> restructure, and the difference shows up only at load.

And a Talos `@doc` `format` still referenced `new-owner-konto` after the parameter became
`executee` — the same *"a signature change must reach every place the name is written"* class,
caught the same way, by the module failing to load rather than by any static check.


---

### 03_AQP.pact — COMPLETE (2 of 2 entrypoints, 2026-09-22)

Two anchor-sync repairs, and the right answer was to add **no executor at all**.

`AQP|C>SYNC-TF-ANCHORS` and `C>SYNC-COLLECTABLE-ANCHORS` validate that the beneficiary **exists**
and is a **standard account** — `UEV_StakeBeneficiaryAccount` — and nothing else. There is no
ownership check anywhere on either path.

| | |
|---|---|
| what it does | recomputes anchor promile from the beneficiary's **actual** balances |
| who pays | the **patron** |
| who benefits | the beneficiary, whose stale boost is corrected |
| who notices the staleness | usually whoever **issued the new anchors** — not the beneficiary |

So the beneficiary is an **executee**: acted upon, needing no signature, only type-validated — the
executee test verbatim, and the same disposition `DPDC-I` reached for `creator-account` under audit
#53L. And there is **no executor to name**. Requiring the beneficiary's signature would delete the
third-party repair path and protect nothing: the only thing a caller can do here is make someone
else's data correct *at their own expense*.

> Registered EXECUTORLESS beside `DALOS|C_UpdateEliteAccount` — the same shape, reached
> independently and then recognised. That registry entry already said it: *"the op recomputes
> DERIVED elite data from state already on chain, is idempotent, and is deliberately permissionless
> so anyone can repair a stale row… renaming a subject to `executor` would have manufactured
> attribution out of a parameter nobody checks."*

#### A blanket rename in the wrong file, caught by reading the diff

The first pass renamed `beneficiary-id` → `executee` across **all of `04_TS02-C3.pact`** — 80
occurrences, most of them in **stake** wrappers that have nothing to do with this module and whose
roles belong to module 45's turn. Reverted by writing back the committed blob and redone scoped to
the three sync shells: **15 edits, not 80.**

> A rename is only safe inside the extent you have actually reasoned about. `beneficiary-id` means
> one thing in a repair and another in a stake, and a file-wide `re.sub` cannot tell them apart.


---

### 05_FVT.pact — COMPLETE (9 of 9 outstanding entrypoints, 2026-09-22)

The farms/vaults/treasuries core. Nine entrypoints left after earlier cascades; three renames,
three stake-flow reorders, one `patron` that was doing two jobs, and **one claim I had to withdraw
after reading the code properly.**

#### `patron` was doubling as the actor

`CC_UnstaleMyScores (patron fvt-ids)` — and `FVT|C>UNSTALE-MY-SCORES`'s own `@doc` said so
outright: *"Auth = account ownership of `patron`: you may only unstale your OWN scores."*

> **One word, two roles.** A patron is who *pays*, and the gas station exists precisely so that can
> be somebody else. An enforce on `patron` is an enforce on the actor wearing the payer's name, and
> the moment a sponsor pays for a user's unstale the check moves to the wrong account. Now
> `(patron executor fvt-ids)`, with the capability enforcing `executor`.

#### `CC_Collect` — the claimant now signs for the claim

`FVT|C>COLLECT` validates the **context** (pool not sweeping, FVT not vacate-frozen, reward token
enabled, score entity linked) and proves no account. The reward leaves the vault and is credited to
`collector`, renamed `executor`, with `CAP_EnforceAccountOwnership` added. Every fixture already
passes `patron == collector`, so it is a no-op there; what it buys is that a sponsor may pay the
gas while only the claimant may trigger the claim. `collector` was the right account under a local
word — `injector` likewise, across the three inject ops.

#### The three stake flows put the actor where the canon puts it

`(pool-id owner-id beneficiary-id …)` → `(patron executor executee pool-id …)`. `owner-id` was
always the actor and `beneficiary-id` always the account whose position is created — an owner may
stake **on a beneficiary's behalf**, which is the whole reason the two are separate parameters.
Two of the three had no `patron` at all.

#### A claim withdrawn: `C_Issue` was already proven

The first pass added an ownership enforce to `C_Issue` and a `@doc` asserting the capability
*"checks NO account at all"*. **That was false.** `FVT|C>ISSUE-FVT` closes with
`(CAP_EnforceAccountOwnership owner-konto)` — the check sat past the end of the 31-line window I
had grepped, and I concluded "absent" from a truncated read.

The evidence that corrected it came from the suite itself: `[6.2.2] <<TX-SCORE-13>>` already pinned
*"a well-formed vault reaches `CAP_EnforceAccountOwnership`, which refuses and names the victim"* —
a test that could not have been written against a function with no gate. The redundant enforce was
removed (CLAUDE.md: do not duplicate validation across defcap and caller) and the `@doc` rewritten
to what is there: **a rename and a reorder, nothing more.**

> **A grep window is not a read.** This is the second time in the sweep a claim outran the
> evidence, and both times the correction came from running or reading the *tests* rather than the
> code. `<<TX-SCORE-13>>` is worth copying as a model: it walks the two shadowing guards first — an
> out-of-range class, then a wrong denominator — to prove neither is what refuses, and only then
> reaches the keyset failure.

#### And the auth-surface artefact was regenerated before being read

`_modulecomplete` flagged `CC_UnstaleMyScores` as WEAKENED — correctly, since the enforce moved
from `patron` to `executor`. Running `_authsurface.py` bare **writes** the artefact, so the
`--check` that followed compared the new file against itself and said "clean". The diff was then
audited row by row after the fact: 38 rows changed, **exactly one** lost a name (`patron` →
`executor`, the rename), and the headline moved **846 → 856** reaching an ownership enforce.

> Reviewing the diff *after* regenerating is the mistake that tool exists to prevent. It came out
> right; the order was still wrong.


---

### 06_VCT.pact — COMPLETE (3 of 3 entrypoints, 2026-09-22)

The vacate module: drain a pool, abort a drain, finalise one. All three reach
`CAP_VctVacatePoolOwner` → `CAP_EnforceAccountOwnership (URC_AqpOwnerKonto pool-id)` — ownership of
a **derived** account, §4g — so all three gained a bound `executor`.

`UEV_ExecutorIzVacatePoolOwner` is a **local twin** of `AQP-POOL`'s `UEV_ExecutorIzPoolOwner`, and
the reason is worth recording: `03_AQP` does **not** expose that helper on `AcquisitionPoolsV1`, so
VCT cannot call it across the modref. Both read through the same `URC_AqpOwnerKonto`, which is what
keeps them from ever disagreeing.

#### The executor had to reach four `XB_` helpers as well

`VCT|C>VACATE` is acquired in five places — `CC_FullVacate` **and** the four `XB_Vacate*` shells
that Talos calls for single-lane drains. Adding the executor to the capability meant adding it to
all five, and to the seven Talos wrappers above them.

> A capability signature change reaches everything that ACQUIRES it, not only the entrypoints the
> worklist names. `_callarity`'s capability-acquisition pass — added at module 26 — is what makes
> that mechanical rather than remembered: it reported all five immediately.

#### Two probes deliberately left with a plain account

`[6.2.10]` `<<TX-AQP-NEG-IMC1>>` calls `AQP-VCT::CC_FullVacate` and `C_AbortVacate` **directly**, to
prove `P|UEV_IMC` refuses a non-Talos caller. Their executor stays a plain account and is excluded
from the `_executormigrate` rule block by an explicit comment: these calls exist to die **before**
anything is read, and a derived owner expression at the call site would be evaluated first.


---

### 07_MTX-AQP.pact — COMPLETE (1 of 1 entrypoint, 2026-09-22)

A one-line rename — `injector` → `executor`, matching `05_FVT`'s three injects — and a **third
distinct reason `FORWARDED` cannot see a real proof.**

`C_2|Inject` acquires its capability and then runs the `MTX|2|C_Inject` **defpact**. The executor's
tokens are debited in *step 0*, which calls `AQP-FVT::XB_FvtInject` and bottoms out in
`(TFT::C_Transfer patron executor AQP|SC_NAME …)`. The entrypoint's own body contains **no**
`ref-X::` call carrying the executor at all — `FORWARDED` scans the body, so a hop through a
defpact step is invisible to it.

The registry now records three separable reasons, and keeping them apart is the point:

| shape | example |
|---|---|
| proven **in place** — binder + enforce on the derived name | `SCR|C>ISSUE-TRIPLET`, `FVT|C>ROTATE-OWNERSHIP-FVT`, six of `08_DSA`'s |
| hop through a **same-module** `XI_` | `02_SCORE::C_IssueScoreFromModel`, `00_Demipad`'s collectable transmits |
| hop through a **defpact step** | `07_MTX-AQP::C_2|Inject` |

> And the registry key had to be `07_MTX-AQP.pact::Inject`, not `::C_2|Inject` — the lookup does
> `name.split("|")[-1]`. The tool's own selftest refuses the wrong shape and caught it on the first
> run, which is exactly what that selftest was added for.

---

### 08_DSA.pact — COMPLETE (4 of 4 outstanding entrypoints, 2026-09-22)

Delegation agencies. Two admin ops, and two that get **no executor** for two *different* reasons.

#### A guard is not an account

`C_OracleWrite`'s authority is `(enforce-guard (UR_DSA-ORA|Guard fvt-id))` — a **guard**, not an
account. There is nothing account-shaped to bind an executor to, and naming one would be a
parameter nobody checks.

> The attribution exists **one level up**, and is already recorded there: `C_SetOracleAuth`
> registers that guard and takes an `executor` proven against the vault owner. So the ledger can
> answer *who authorised this oracle* — the question that has an account-shaped answer. Where a
> module delegates authority to a guard, the attribution belongs at the delegation, not at the use.

`C_RecomputeCapture` is the *other* executorless shape — the permissionless-repair one from
module 38. It recomputes a derived aggregate from stored weight and the oracle entry, idempotent,
patron-paid; and neither parameter is even an account, so there is no executee either. The registry
comment keeps the two reasons visibly separate.

#### Two global admin switches, now attributable

`A_ToggleExternalOracle` and `A_SetOracleValidity` are `GOV|DSA_ADMIN` ops that took **neither**
patron nor executor. Both now take both, with the ownership enforce ahead of the validation.

> The toggle is **singular and global** — it flips external oracling for *every* operator at once.
> An audit trail for which keyholder flipped it matters more there than for a per-entity admin op,
> not less.

`<<AQP-G20b>>`'s two floor assertions now name ANHD as executor in a block that signs for her, so
the positivity message still speaks rather than being shadowed by the new ownership guard — the
same fixture discipline as `<<EQ-G1>>`.

#### Seven proofs the matcher could not see

Six DSA entrypoints bind `(= executor fvt-owner)` and enforce ownership of that derived name — the
`SCR|C>ISSUE-TRIPLET` shape. The seventh, `C_AdmitAgency`, is a genuine downstream forward, and
`DSA|C>OPEN-AGENCY`'s `@doc` **already said so**: *"Operator account-ownership is enforced
downstream in `FVT|XE>ADMIT-DELEGATION`."* That sentence now also sits in the function, because the
canon requires the route to be written where the executor is declared — not one level up where
only a reader of the capability would find it.


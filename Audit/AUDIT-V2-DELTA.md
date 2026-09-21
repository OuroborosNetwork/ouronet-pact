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


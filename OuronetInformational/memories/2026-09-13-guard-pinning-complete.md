# Guard pinning (P3.3) closed — 2026-09-13

**Final: 777 matchable enforce sites · 752 pinned (96%) · 698 by a module-unique message (89%) ·
31 proven-unreachable and annotated · 3 live-but-untestable · 25 unpinned in dead `00_DPMF` ·
LIVE worklist = 0.**

Entered the day at 18 live guards. Closed them all. The last eleven were resolved in a single pass
after five read-only research agents were fanned out by module family — the parallelisation the
owner asked for. The agents were forbidden from editing or running `pact` (CPU contention +
file-collision risk) and were asked for **hypotheses with confidence, not verdicts**. That framing
mattered: two of the eleven hypotheses were wrong, and only execution caught it.

## The three mechanical lessons

### 1. `test-capability` cannot acquire an `@event` defcap
It routes to the *install* path and dies with
`"Install capability error: capability is not managed and cannot be installed"`.

This burned two guards that looked trivially drivable:

* `01_ANK:453` (`ANK|C>UPDATE-DPTF`, `@event`) — no route at all; the cap's only entry is
  `XE_UpdateTrueFungibleUserAnchorValues`, which opens with `(P|UEV_IMC)`. **Annotated UNREACHABLE.**
* `06_VCT:537` (`VCT|C>VACATE`, `@event`) — reached instead through its **real Talos client**,
  `TS02-C3.AQP-POOL|CC_FullVacate`, on a forced pool row. **Executed.**

**Check for `@event` before planning a `test-capability` route.** Plain (non-event, non-managed)
defcaps — `SCR|XI>X_ISSUE-NF-SCORE-DEFINITION`, `DPDC-MNG|C>IZ-CLASS-ZERO`,
`DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES`, `AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY` — all acquire fine.

### 2. "No fixture in THIS harness" is not "unreachable"
Three guards carried stale notes declaring them unreachable that were really statements about one
*collection*. The fixture existed in a sibling harness every time:

| guard | stale note said | truth |
|---|---|---|
| `09_DPDC-F:239` | TSFS has no class-0 fragmented nonce | `TFRG` nonce 1 is exactly that, in `[6.1.2]` |
| `06_DPDC-MNG:280` | fixture-blocked | TSFS n11 carries set class 1; n1..n10 are class 0 |
| `06_DPDC-MNG:440` | fixture-blocked | same TFRG nonce 1, plus `GOV|DPDC|SC_NAME` as the account |

### 3. An unreachable guard still needs an **executed** assertion behind it
Every `;;UNREACHABLE` added in this phase is backed by a test that drives the route to whatever wall
actually stops it and **reads the message that comes back**. The pattern is `modules/ATS.repl`
`<<ATS-G23>>`. That converts an annotation from a claim into a regression trip-wire: if the shadow
ever lifts, the test fails.

## New guard-shadow shapes found

* **ONE-WAY LATCH IN THE CALLER** — `06_DPOF:2617` ("RBT-Data for DPOF {} is already set…").
  Its *only* caller is `ATS::C_AddHotRBT`, whose `let` binds
  `ico2 = (DPOF::C_Control hot-rbt false …)` — first argument is `can-upgrade := false`. Eager `let`
  again: the first successful registration latches can-upgrade off, and `C_Control` itself requires
  can-upgrade true (`06_DPOF:2076`), so the latch is irreversible. A second registration therefore
  dies one binding ABOVE the guard. **Not filed as a defect** — the operation is correctly refused
  either way; only the wording is less specific. Reordering writes inside a Stage-1 client path to
  improve a message is a worse trade than documenting it.
* **VESTIGIAL SENTINEL** — `04_STOICPAY:240` ("Kpay Sale has Concluded!"). `UR_KpayPID` is TOTAL and
  strictly positive: 0.01 before start, 1.0 after three years, `floor(0.01 + 0.99·elapsed/3y, 24)`
  between. It never returns the `-1.0` the branch above looks for and never returns `<= 0`. **Both
  the sentinel branch and the enforce are dead.** Left in place (removing it changes a live sale
  contract for no functional gain) and annotated.
* **A BACKSTOP WHOSE SIBLING RESOLVER HAS NO RANGE CHECK** — `06_VCT:537` is not decorative.
  `URC_AqpOwnerKonto` resolves the governor via `0→SWP, 1→DPTF, 2→DPOF, 3→DPSF, else→DPNF`, and that
  `else` has **no range check**: class 9, 400 and -1 all silently resolve as DPNF. So the owner check
  on the line above does NOT stop a corrupt row — without :537 it would be vacated **as the wrong
  class, against the wrong tracker tables**. Driven by forcing a row with `WI_Pool` (`AQP-POOL.SECURE`
  is trivially true, so no module-admin needed) inside a `rollback-tx`.

## One mute guard fixed (owner's standing authorisation)

`11_EQUITY+.pact` `C_IssueShareholderCollection` — `(enforce (= l 24) "24 IPFS links must be
provided for an Equity Collection")` sat BELOW a `let` whose `ico` binding calls
`DPDC-I::C_IssueDigitalCollection`. Eager `let`: every rejected call paid for a **full collection
issuance** before the argument was inspected, and any call where the issuance failed first (a
duplicate collection name — the ordinary case) reported *that* error instead. Hoisted above the
`let`; it is a pure shape test on a parameter. Pinned by `modules/EQUITY.repl` `<<EQ-G1>>` at 23,
25 and 0 links, each with a **distinct collection name** — reusing `TestStageEquity` would have hit
the duplicate and been the very thing that masked the message.

## One test that was green for the wrong reason

`Stage_02/[5.3]_Launchpad.repl` TX-SPK-03 asserted `expect-failure … "Amount"` and its comment
credited DPTF's zero-quantity transfer refusal. It never got that far: `SPARK|C>X_REEDEM` reads the
balance itself and enforces `(and (> redemption-quantity 0.0) (<= redemption-quantity supply))`, and
`"Amount"` matched `"Invalid Redemmption Amount"` **by substring**. Green, wrong reason, and
`01_Spark:267` left unpinned. Tightened to the full message and the opposite side of the bound added
via `C_RedemFewSparks`. (The spelling "Redemmption" is the source's.)

**Generalised: a bare-substring `expect-failure` is not a pin.** Both this and `16_SWPI:2512` (a
2-arg `expect-failure` at `[6.3]_SWP.repl:3937`) were reaching their guard while accepting any
error. Audit the suite for short expected strings before trusting a coverage number.

## Confirmed live: the `(enumerate 0 -1)` trap, in production code

`DPDC-C::XIv_MappedCreditOrDebitDPDC` — two EMPTY lists are equal, so they **pass** the arity
enforce; the map below then runs over `(enumerate 0 (- 0 1))` = `(enumerate 0 -1)`, which in Pact is
the DESCENDING pair `[0, -1]`, **not** the empty list. So the empty call does not no-op — it indexes
into empty lists and dies on a native fault. Pinned as `<<DPDC-G19>>` so a future "harmless empty
input" assumption has something to trip over.

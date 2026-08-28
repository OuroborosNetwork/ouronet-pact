# SWP vs Kaddex — comparison handoff (read this first)

**Written:** 2026-08-28, by a general-purpose session (not the SWP audit session — this is a
**separate, adjacent task**: comparing our SWP AMM engine against a real Kadena-mainnet DEX's
source, for "what can we learn," not a continuation of the 71-finding `ROUND-01-FINDINGS.md`
audit cycle). Read `README.md` and `HANDOFF.md` in this same folder for that audit's own state —
don't conflate the two. This file and its four `KADDEX-SOURCE-*.md` siblings are net-new,
standalone reference material.

## 0. What this is and how to use it

The owner pasted the full source of 14 modules from **`kaddex.*` on Kadena mainnet** (Kaddex /
KDX — a real, live, audited DEX), read via a block explorer, wanting to know: *"what the fuck kind
of exchange do we have, and how come we've written hundreds more lines of code with our exchange
engine than they have — and is there something we can learn from what they did to improve our
code?"* This file is the seed answer plus the open work list for whoever (agent or human) picks up
the deeper comparison.

**Source material:**
- `KADDEX-SOURCE-1.md` — `exchange`, `aggregator`, `alchemist`
- `KADDEX-SOURCE-2.md` — `dao`, `fungible-util`, `gas-guards`, `noop-callable`
- `KADDEX-SOURCE-3.md` — `kdx`, `skdx`, `tokens`
- `KADDEX-SOURCE-4.md` — `gas-station`, `liquidity-helper`, `staking`, `wrapper`

**Our side, for comparison** (all in this repo):
- `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact` — AMM math core (stable/weighted/standard)
- `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact` — multi-hop route/path tracing (BFS-based)
- `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact` — pool/pair core state, admin, policy
- `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact` — pool issuance, swap-amount computation
- `1_SOVEREIGN/STAGE_01/2_Core/17_SWPL.pact` — liquidity-add mechanics
- `1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact` — LP branding, remove-liquidity
- `1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact` — swap execution, slippage, smart router
- `1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact` — multistep (`defpact`) issue/add-liquidity
- `1_SOVEREIGN/STAGE_01/3_Talos/04_TS01-C3.pact` + `05_TS01-P.pact` — Talos client wrappers
- `1_SOVEREIGN/STAGE_01/1_Utilities/13_U_BFS.pact` — raw BFS primitive SWPT is built on
- `1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/` (this folder's siblings) — the live 71-finding audit:
  `README.md` (status tracker), `ISSUES-RANKED.md` (all findings ranked), `ROUND-01-FINDINGS.md`
  (full finding text), `ROUND-01-OWNER-FEEDBACK.md` (verdicts), `ROUND-02-FIXES.md` (fixes landed),
  `HANDOFF.md` (that audit's own resume doc — not this one)

**Before doing any deep comparison work:** load `OuronetInformational/SKILL.md` per the normal load
order, then actually read the `KADDEX-SOURCE-*.md` files and the SWP `.pact` files listed above —
don't work from this document's summaries alone, they're a starting hypothesis, not verified ground
truth. Cross-reference specific claims below against the live audit files (`ISSUES-RANKED.md` etc.)
before repeating them to the owner as fact.

---

## 1. "What the fuck kind of exchange do we have" — the honest architectural answer

**Kaddex's `exchange` is a Uniswap-V2 clone: one constant-product formula, two-token pairs only.**
Every pair is `x*y=k`, fee is a flat 0.3%, routing is client-computed multi-hop over 2-token pairs
(the caller supplies the path as a list of tokens; `exchange` doesn't discover routes itself —
`kaddex.staking.get-path` and `liquidity-helper` do that externally, trivially, with a single
`pair-exists` check and a hardcoded `token -> coin -> KDX` fallback). It is small because **it does
one thing.**

**Ouronet's SWP is not one AMM — it's three AMM math engines plus an in-house router, running
under one policy/orchestration layer:**
- **Standard** (constant-product, Kaddex's model)
- **Weighted** (Balancer-style `∏xᵢ^wᵢ`, N tokens, arbitrary weights)
- **Stable** (Curve-style StableSwap, Newton-solved `D`/`Y`, N tokens, amplifier-tunable)
- All three coexist as pool *types*, selectable per-pool, sharing one table family — not three
  separate modules; `U|SWP` alone (the shared math core) carries all three formula families plus
  their inverses, LP-math, and graph-prep helpers.
- **A self-hosted multi-hop router** (`SWPT` + `U|BFS`) — Kaddex has no equivalent; multi-hop there
  is purely a client-supplied path with no on-chain graph, no BFS, no edge-liveness filtering. SWPT
  alone is a real breadth-first-search implementation over a live, mutable pool graph — something
  Kaddex's ecosystem (per the pasted `staking`/`liquidity-helper` code) explicitly declined to
  build ("Either try more than the basic single-hop path, or operators should register optimal
  token paths to take" — literally a `// TODO` in `staking.get-path`, never done).
- **Asymmetric liquidity add/remove** with deficit-tax pricing (`SWPL`) — Kaddex's `add-liquidity`
  only supports the "optimal ratio, either amount can be the constraining one" shape; it has no
  concept of intentionally-imbalanced deposits priced against a fair-value deficit.
- **A `defpact` multi-step issuance/add-liquidity flow** (`MTX-SWP`) — Kaddex's `create-pair` /
  `add-liquidity` are single-transaction; nothing in the pasted Kaddex modules uses `defpact` for
  swap-family operations at all (only `kdx`/`skdx`/`tokens` use `defpact` for cross-chain transfer).
- **A cross-module policy-table authorization layer** (`SWP|Properties`, `SWP|Pairs`,
  `SWP|Pools`, `SWP|Asymmetry`, `SWP|LP` — see `15_SWP.pact` schemas) and a **Talos orchestration
  tier on top** (`TS01-C3`/`TS01-P`) that is the *only* supported client entrypoint and the *only*
  place IGNIS (virtual-chain gas) is collected — per this repo's `CLAUDE.md`. Kaddex has no
  equivalent layer; callers hit `exchange`/`staking`/`liquidity-helper` directly, gas is real KDA
  gas paid by the caller or a `gas-station` allowlist, not a virtual internal accounting system.

**The line-count comparison, done honestly (counted 2026-08-28, from what's in this repo /
what was pasted):**

| | Lines |
|---|---|
| All 14 pasted Kaddex modules combined (pact code, not counting this repo's markdown wrapper) | **~5,100–5,200** |
| Just `SWP` core AMM equivalent alone: `U\|SWP` + `SWP` + `SWPI` + `SWPL` + `SWPLC` + `SWPU` + `MTX-SWP` + `SWPT` (8 files) | **9,428** |
| Same 8 files **plus** the Talos client layer (`TS01-C3`, `TS01-P`) and the raw BFS primitive (`U\|BFS`) | **11,011** |

So: **our AMM-core-only stack is already ~1.8× the size of Kaddex's *entire 14-module ecosystem***
(DEX + DAO + staking + gas station + liquidity wrapper + fee-boost wrapper + everything), and
**~8–9×** the size of Kaddex's closest functional equivalent (`exchange` + `tokens` +
`fungible-util`, roughly 700+340+60 ≈ 1,100 lines). That's the real number — don't let anyone round
it down to "hundreds more," it's thousands more, and it's not close.

**Why, structurally (not excuses, just what's actually different):**
1. **3 pool-math families vs 1.** Kaddex ships one invariant. We ship three, sharing infrastructure
   but each with its own solve/inverse-solve/precision-edge-case code (`U|SWP` alone is one of our
   larger utility files for exactly this reason).
2. **We built the router in-house; they didn't build one at all.** `SWPT`+`U|BFS` is real graph
   algorithm code (BFS traversal, edge/node envelope construction, active-pool filtering — three of
   this audit's own CRIT/HIGH findings, `#13C`/`#19H`/`#20H`, were bugs *in this router*). Kaddex's
   ecosystem punts multi-hop entirely to the client or to a hardcoded 2-hop fallback.
3. **Asymmetric/deficit-priced liquidity is a whole subsystem** (`SWPL`) with no Kaddex analogue.
4. **`defpact` multi-step flows** add real code (state machine steps, `resume`/`yield` schemas,
   Talos wiring) for something Kaddex does in one atomic function call.
5. **The policy-table + Talos + IGNIS layer is infrastructure Kaddex simply doesn't have** — it's
   solving a different problem (virtual-chain gas metering, curated multi-module client flows) that
   doesn't exist in Kaddex's single-chain-native-gas world.
6. **StoicSyntax's prefix discipline (`UC_`/`UR_`/`URC_`/`UEV_`/`UDC_`/`A_`/`C_`/`X*`) trades
   density for auditability** — every read/validate/write step is its own named function rather than
   inlined into the caller, which is more total lines but (arguably, and this is worth the SWP
   agent's own judgment, not taking it as given) more locally reviewable per function. Kaddex's
   style favors large functions with everything inlined (`add-liquidity` is ~90 lines of single
   flowing `let*`; the SWP equivalent is spread across `URC_*`/`UEV_*`/`XI_*` helper functions).

**Is more code automatically worse?** Not obviously — this repo's own 71-finding audit against
~9,400 lines of *self-written* code (no external prior-art AMM to diff against, per `README.md`'s
own "Ground truth" section) found real, serious bugs (`C1`–`C13`) purely by reading it, meaning the
size itself isn't what caused the bugs — but size **is** what makes an audit like that expensive
and slow, and every additional formula family / router / defpact flow is another surface the next
audit round has to re-cover from scratch. That's the real cost of doing 3 AMM types instead of 1:
not "more bugs per line" but "more lines to re-verify every time something changes."

---

## 2. What's actually worth learning from — findings from a first read (not verified against SWP source line-by-line yet, that's the open work)

Full writeup already given to the owner in-chat; summarized here for whoever continues:

1. **Formal verification (`@model`/`property`/`defproperty`) — see §3 below, it's a big enough
   topic to get its own section.** Short version: real Pact 4 feature (SMT/Z3-backed whole-execution
   proof), **appears dropped in Pact 5** (see §3 for the evidence trail), and even Kaddex's own later
   modules (`dao`, `fungible-util`, `gas-guards`, `gas-station`, `liquidity-helper`, `staking`,
   `wrapper`, `noop-callable`) never used it — only the oldest core value-transfer modules
   (`exchange`, `kdx`, `skdx`, `tokens`) carry `@model` blocks. That's a real, telling data point
   from inside the org that built the feature.

2. **`exchange`'s `MUTEX` reentrancy lock is deliberate defense-in-depth for a threat its own
   authors say they can't construct a PoC for** ("we have not been able to produce a PoC... Pact
   detects the recursion attempt"). Cross-reference: this repo's own SWP audit reached the *same*
   conclusion independently for a different code path — **`#14H`/`H9`** in `ISSUES-RANKED.md` /
   `ROUND-01-OWNER-FEEDBACK.md`, REFUTED because a live Pact 5 REPL proof showed writes are blocked
   at the VM level during guard evaluation, "not even `try`-catchable." **Open question for the SWP
   agent:** does SWP have an equivalent belt-and-suspenders lock anywhere (`SWP|Pairs.locked`-style
   field), or does it rely purely on the VM guarantee H9 found? If purely the latter, is that a
   deliberate, documented decision, or just where the audit happened to stop? Kaddex's own choice —
   pay for insurance even believing you don't need it — is worth weighing explicitly, not just
   assuming H9's REFUTE closes the question forever.

3. **`exchange.swap`'s flash-swap callback (`swap-callable-v1`, `callable::swap-call` invoked
   mid-swap, before the invariant check) is a *materially stronger* reentrancy surface than a
   guard-evaluation callback** — it's a normal external module call, not a guard check, so H9's "no
   writes possible during guard eval" VM guarantee **would not automatically extend to it**. SWP has
   no equivalent surface today (confirmed: no `swap-callable`-style hook found in a repo-wide grep of
   `1_SOVEREIGN`/`2_SLAVE`). Flag this as a standing constraint if flash-swap-style external
   callbacks are ever proposed for SWP: re-derive H9's safety argument from scratch, don't assume it
   still holds.

4. **Canonical pair-key ordering** (`exchange.is-canonical`/`canonicalize`, sorted by
   `format "{}"` string compare of the two module refs) doesn't map 1:1 onto SWP's N-token pool
   architecture (`SWP|Pairs` keyed by `<swpair>`, `SWP|Pools` keyed by `<pool-category>`, explicit
   named keys rather than derived from a 2-token sort) — this is architecture difference, not a gap,
   **but** worth a direct check: can the *same* token set ever be registered as two different swpair
   keys in SWP (e.g. caller supplies tokens in a different order and gets a distinct row instead of
   hitting the existing one)? Kaddex's `is-canonical` exists specifically to make that structurally
   impossible for its 2-token pairs. Verify SWP's issuance path (`SWPI::UEV_Issue` /
   `XE_Issue`) has an equivalent "does this token-set already exist" guard and it's not just
   "does this exact string key already exist."

5. **Kaddex's TWAP oracle** (`exchange.oracles-v2`/`observations-v2`, auto-updated on every
   `update-reserves` via `maybe-observe`) has **no equivalent in SWP** (grep confirmed: no
   `oracle`/`twap`/`cumulative-price` anywhere in the SWP family; `SWPI` has a single commented-out
   external DIA-oracle call for USD pricing, not a self-hosted cumulative-price mechanism). Not
   urgent unless something downstream (liquidation pricing, collateral valuation) needs
   manipulation-resistant on-chain pricing rather than raw spot reserve ratios — flag as a roadmap
   question for the owner, not a bug.

6. **`kdx`'s deferred protocol-fee-mint (`exchange.mint-fee`, Uniswap V2 `_mintFee` pattern: mint
   extra LP to a fee-account proportional to `sqrt(k)` growth since `last-k`)** vs SWP's oracle-priced
   IGNIS tax model (per `#1C`→`H8` in this audit's own findings — "deficit tax goes to the shared
   `SWP|SC_NAME` vault"). Different, arguably cleaner mechanism on SWP's side (fee isn't smeared
   across LP-dilution math) — not a gap, just worth having the comparison on record since H8 is
   still open (`ROUND-01-OWNER-FEEDBACK.md` C10 entry: "is protocol-wide value capture... intentional?").

7. **`kaddex.dao`'s quadratic-voting governance module has no SWP/Ouronet equivalent at all** (repo-
   wide grep found no proposal table, no on-chain voting anywhere). If Ouronet ever wants on-chain
   governance, `dao`'s specific design mistakes are worth avoiding pre-emptively: it reads voting
   power **live at vote time** rather than snapshotting at proposal creation (lets an account
   inflate its vote by staking right before casting, then unstaking after), and uses `(hash title)`
   as the proposal ID (two proposals with the same title collide — `insert` aborts the second, a
   griefing footgun where a hostile actor can squat a popular title to block a real proposal).

8. **`gas-guards`' `guard-all`/`guard-any` and `fungible-util`'s `check-reserved`/`enforce-reserved`
   are already independently replicated, logic-identical, in `U|G` (`UEV_GuardOfAll`/
   `UEV_GuardOfAny`) and `U|RS` (`UEV_CheckReserved`/`UEV_EnforceReserved`)** — verified by direct
   read, not guessed. Good convergent-design confirmation, no action needed. The one piece Kaddex
   has that we don't: `gas-guards`' gas-price/limit/notional **ceiling guards**
   (`create-user-guard` wrapping a threshold check against `(chain-data)` gas fields) — doesn't port
   1:1 since SWP's IGNIS is virtual-chain accounting not real KDA gas, but the *pattern* (a guard-
   form ceiling check) could matter if IGNIS pricing ever needs a guard-shaped cap. Filed, not urgent.

9. **`alchemist`'s wrap/unwrap cross-sibling mass-conservation re-check** (every `wrap`/`unwrap` call
   re-verifies parity/solvency for *every other* registered prefix token, not just the one being
   touched, both pre- and post-action) is a genuinely paranoid pattern worth studying if any SWP/AQP
   module holds one shared base-asset backing multiple derived tokens.

---

## 3. Formal verification (`@model`/`property`/`defproperty`) — what it is, why Kaddex used it, and why it looks dead in Pact 5

**This needs to be said plainly to the owner, who is rightly skeptical: the skepticism is largely
justified by the evidence, but the feature wasn't "useless," it targeted a real and narrow bug
class — it just never scaled and the ecosystem (including Kaddex itself) walked away from it.**

### What it actually is

Not fictional syntax. Pact 2.4+ shipped a genuine **SMT-backed (Z3) formal verifier** — `@model`
blocks hold `(property ...)`/`(defproperty ...)` expressions in a *property language*
(superset of Pact plus `forall`/`exists`/`when`/`row-written`/`row-enforced`/`column-delta`) that
`pact -v` (or the `verify` REPL builtin) would attempt to **prove hold across every possible
execution path through the module** — not just the paths a test suite happens to exercise. Two
distinct guarantees actually used in the pasted Kaddex code:
- **Guard-enforcement-on-write** (`row-enforced`): "if any function writes row `k` of table `T`,
  the guard for `k` must have been `enforce-guard`'d somewhere in the call path" — proven for the
  *whole module*, once, mechanically, with named exceptions for the functions that legitimately
  don't need it (insert-only, or covered by a different invariant instead). See `exchange`'s
  `prop-pairs-write-guard` and `tokens`'s `prop-supply-write-issuer-guard`/`prop-ledger-write-guard`.
- **Mass conservation** (`column-delta`): "the sum of this column across all rows doesn't change" —
  proven for `transfer`/`transfer-create` in `kdx`/`skdx`/`tokens`.

### Why one would use it (the honest pitch, not a strawman)

A capability system (`defcap`/`with-capability`/`enforce-guard`) only protects a function if a human
remembered to write the check *in that function*. It doesn't verify you didn't forget one somewhere
in a 1,800-line module, and it definitely doesn't verify that a *future* function added by someone
who didn't read the whole module still respects the invariant. A property proof does — mechanically,
forever, on every subsequent edit, without relying on a human's attention span. That's not a
theoretical concern for this exact codebase: this repo's own SWP audit's `HANDOFF.md` documents that
**three real findings (`#11C`/`#12C`/`#13C`) were silently skipped mid-audit and only caught because
the owner asked to audit the audit process itself** — the exact failure mode a mechanical proof
can't have. And the *class* of bug the prover targets (missing/dead `enforce`, dropped validation)
is not hypothetical here either — it's precisely what `C7` (`C_ModifyWeights`, dead precision
`enforce`), `H12` (`SWP|S>UPDATE-SUPPLIES`, no `enforce` at all), `H6` (`primality` read but never
enforced), and `H5` (weight-precision check computed then discarded) all turned out to be, found by
hand, one at a time, across a multi-day audit. A `row-enforced`-style property, if it existed in
Pact 5 and were written for SWP's tables, would have caught that entire bug family in one `pact -v`
run instead of a 71-finding manual sweep.

### Why it's not worth chasing in Pact 5 (the honest counter-argument)

1. **It appears to be genuinely gone as an executable feature.** Evidence gathered this session
   (web search + direct fetch of `kadena-io/pact-5`'s README/CHANGELOG.md, since archived
   2026-11-26 — repo is now read-only): the Pact-5 changelog documents the SMT/Z3 property-checking
   system extensively for versions **2.4.0 through ~3.x** (introduction, `@model`/`defproperty`
   syntax, Z3 pinning, SBV upgrades) and then **that entire vocabulary — property checking,
   `@model`, `defproperty`, Z3, SBV, prover — does not appear anywhere in the 5.0+ changelog
   entries.** What *did* land in 5.x instead is a much lighter, non-SMT **static typechecker**
   (`typecheck` native, added 5.2) — a different, cheaper kind of check (type-level, not
   invariant-level). `@model`/`property`/`defproperty` syntax will likely still *parse* in Pact 5
   (it's just metadata in the AST), but there's no `-v`/prover backend left to actually run the
   proof — so on any Pact 5 source, these blocks are now **inert documentation**, not a live check.
   This wasn't independently confirmed against a live `pact -v` invocation on Pact 5.4 in this
   session (no node/CLI access was used for it) — if it matters for a decision, run `pact -v` (or
   check `pact --help` for a `verify`/property flag) against a `.pact` file with an `@model` block
   on this repo's actual Pact 5.4 toolchain and see what happens; that's the one-command
   ground-truth check nobody has actually run yet.
2. **The strongest real-world evidence it stopped mattering is inside the Kaddex source itself,
   not a web search:** of the 14 pasted modules, only the 4 oldest core value-transfer ones
   (`exchange`, `kdx`, `skdx`, `tokens`) carry `@model` blocks. Every module that reads as newer or
   more actively maintained — `dao`, `gas-station`, `liquidity-helper`, `staking`, `wrapper`,
   `fungible-util`, `gas-guards`, `noop-callable` — has **zero** property annotations, despite
   several of them (`staking`, `wrapper`) being considerably more complex than the annotated ones.
   That's the org that built the feature choosing not to keep using it on new work, years before
   Pact 5 existed to force the issue.
3. **It never covered the bug classes that turned out to matter most, in either codebase.** The
   SMT prover's practical vocabulary was narrow — guard-enforcement-on-write, mass conservation,
   simple arithmetic invariants. It could not have caught, and never claimed to catch: Newton-solver
   convergence/domain bugs (`C2`/`C3` here, and this exact bug class independently existing in
   Kaddex's own AMM math is exactly why `alchemist`'s wrap/unwrap functions carry so much manual
   mass-conservation re-checking — they're compensating by hand for something SMT-provable mass
   conservation *could* express but wasn't being used for there either), routing/graph correctness
   (`C1`, `C6`, `H2`, `H4` — SWPT's entire bug class), reentrancy-adjacent ordering bugs (`H9`, only
   closed by a live REPL PoC, not a static proof), or cross-module composition bugs. Every real bug
   this repo's own audit found was found by **disciplined human/agent code review plus adversarial
   REPL reproduction** — i.e., exactly the methodology this SWP audit already uses, and Kaddex's
   later modules apparently converged on the same answer by simply not writing more `@model` blocks.
4. **The maintenance cost was real and asymmetric to the value.** An SMT-backed verifier needs a
   symbolic interpreter kept in lockstep with the real evaluator's semantics forever, an external
   Z3 dependency, and non-trivial run time — for a payoff limited to one narrow (if genuinely useful)
   invariant class. Given Pact 5 was a from-scratch interpreter/backend rewrite (2x–10x execution
   speedup per its own changelog), dropping a complex, narrowly-scoped, low-adoption subsystem to
   focus the rewrite elsewhere is a defensible engineering trade, not evidence the underlying idea
   was worthless — it's evidence the cost/benefit didn't clear the bar once a full rewrite was
   already on the table.

**Bottom line for the owner's actual question ("why would one use that, you can just protect your
functions"):** you're not wrong that disciplined `enforce`/capability hygiene plus real adversarial
REPL testing — which is exactly this SWP audit's methodology — is what actually caught every bug
that mattered, in both codebases. The prover's real, narrow value-add over that (mechanically
guaranteeing *every* write path checks its guard, forever, without relying on audit coverage) was
demonstrably real (see `#11C`/`#12C`/`#13C` getting silently skipped even by a disciplined manual
process) but apparently not real enough, at its actual engineering cost, for Kadena to keep
maintaining it into Pact 5 or even for Kaddex's own later modules to keep using while it still
existed. Both things are true at once.

---

## 4. Open work for whoever picks this up

Not yet done — pick up here:

1. **Verify the Pact 5 formal-verification-is-gone claim against the actual toolchain**, not just
   changelog inference: try `pact -v` / check `pact --help` for a verify flag against a `.pact` file
   with an `@model` block, on this repo's Pact 5.4. One command, not yet run.
2. **Cross-reference finding #2 above (MUTEX/H9)** against `19_SWPU.pact`'s actual swap execution
   path — does SWP have a per-pair `locked`-style field anywhere, and if not, is that a documented
   decision or just where the audit stopped?
3. **Cross-reference finding #4 above (canonical key / duplicate pool registration)** against
   `SWPI::UEV_Issue`/the relevant `XE_Issue` — can the same token-set be issued twice under
   different swpair keys?
4. Read `U|SWP`/`SWP`/`SWPI`/`SWPL`/`SWPLC`/`SWPU`/`MTX-SWP`/`SWPT` in full against
   `KADDEX-SOURCE-1.md` through `-4.md` side by side, and produce a proper line-by-line-informed
   (not just architectural-summary-level, like this document) comparison — this handoff is a
   starting hypothesis from one read-through, not a finished analysis.
5. Decide whether any of §2's numbered items (2, 4, 5, 6, 7) warrant a new entry in
   `ISSUES-RANKED.md`/`ROUND-01-FINDINGS.md`, or a `OuronetInformational/memories/` note, or neither
   — per this repo's own audit's HARD RULE, nothing here is "settled" until it's written down in
   the audit's own files, not just in this comparison doc.

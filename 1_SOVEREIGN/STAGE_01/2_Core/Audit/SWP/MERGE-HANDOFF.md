# SWP branch → `main` merge handoff

**Written:** 2026-08-29, by the session that closed out this branch's remaining work.
**For:** whoever (agent or human) merges the `swp` branch into `main`. Read this first — it's the
single point of reference; everything else in this folder (`README.md`, `ISSUES-RANKED.md`,
`ROUND-01-FINDINGS.md`, `ROUND-01-OWNER-FEEDBACK.md`, `ROUND-02-FIXES.md`) is full-detail backing
material this document points into, not a replacement for it.

## 0. Bottom line

**Ready to merge.** Working tree clean, 103 commits ahead of `main`, both REPL suite paths
(`[6.2]`+`[6.3]` full suite, and default `[6.2+3]` issuance-only) verified clean from a cold start
immediately before this document was written: `EXIT:0`, `0 FAILURE`, `Load successful`, on both.
Everything in scope for this branch is done, proven, and committed. A short, explicit list of
**deliberately deferred** items follows below (section 3) — none of them block the merge; several
were scoped from the start to happen *on* `main`, after this merge, not before it.

## 1. What this branch is

`swp` is the SWP (swap/AMM) module family's full audit-and-fix branch: `U|SWP`, `U|BFS`, `SWPT`,
`SWP`, `SWPI`, `SWPL`, `SWPLC`, `SWPU`, `MTX-SWP`, `TS01-C3`, `TS01-P` (see `README.md`'s own scope
table for the file/interface mapping). It contains three layers of work, in commit order:

1. **Round I audit** — 71 findings across the whole SWP surface (13 CRITICAL, 12 HIGH, 14 MEDIUM,
   32 LOW), found by direct code review (no external prior-art AMM existed to diff against — this
   was original code, audited cold). All 71 closed. Full detail: `ROUND-01-FINDINGS.md` (the raw
   findings), `ROUND-01-OWNER-FEEDBACK.md` (verdict + reasoning per finding, append-only, ~3700
   lines), `ROUND-02-FIXES.md` (the actual fix per finding, ~2200 lines), `ISSUES-RANKED.md` (flat
   #1C→#71L severity-ranked index with a one-paragraph summary per item — **start here** if you
   need to look up a specific finding fast).
2. **`#65bL` off-cycle gas-optimization arc** — a 9-phase deep dive into `CC_SmartSwap`'s graph-
   search engine, triggered by a real gas-ceiling concern, not a findings-list item. Cold-cache
   worst-case gas dropped **5,094,054 → 1,296,898** (74.5% reduction); warm-cache steady-state
   (bundle-swap-primed `SWPT|PathCache`) sits at 1,143,255 gas (77.6% reduction), unaffected by the
   cold-cache phases since a cache hit bypasses the search entirely. Full detail:
   `OuronetInformational/HANDOFF-swp-graph-search-engine-optimization.md` (dedicated phase-by-phase
   writeup — read this for the gas-optimization arc specifically, this document only summarizes it).
3. **This session's 3 additional findings** — `#72C`, `#73C`, `#74` — surfaced by direct owner
   questions after the audit and the gas arc were both already closed, not from a formal review
   pass. Detailed in section 2 below since they're the freshest work and least likely to already be
   familiar.

Also added this session, untracked before now: `1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/reference/` —
a Kaddex/KDX (real Kadena-mainnet DEX) source dump + comparison handoff, brought in from the `main`
worktree where a prior session had left it as untracked, uncommitted scratch material. It's now
version-controlled on this branch. See `reference/KADDEX-COMPARISON-HANDOFF.md` for that
comparison's own findings — bottom line, nothing actionable survived scrutiny except the three
items below, which trace back to it as their origin.

## 2. This session's work, in detail

### `#72C` — `UC_ComputeInverseY` had no domain guard (CRITICAL, fixed)

The inverse-direction sibling of the already-fixed `C2` (`UC_ComputeY`'s Newton-solver domain bug,
fixed 2026-08-17). Left explicitly open at the time ("should be split out before Round III
re-verify closes C2") and never picked back up once Round III re-verify was itself ruled out of
scope for this branch. Found by re-checking the audit trail instead of assuming the swap math was
verified, when asked directly.

The bug: asking a stable pool's inverse-swap solver "how much input do I need to withdraw ≥ the
pool's own reserve of the output token" — an impossible request — either **crashed uncatchably**
(`Arithmetic exception: div by zero, decimal`, not even `try`-catchable) exactly at the reserve
ceiling, or **silently returned a plausible-looking, entirely fabricated number** past it (asking
for 1.5× a pool's reserve returned ~1.5× back as the "input needed"). Reachable live — nothing
upstream bounded `output-amount` against the reserve.

Fixed with a domain `enforce` in `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact`
(`UC_ComputeInverseY`), placed before the invalid coefficients are ever computed. Adversarially
proven: new permanent proof `SWP|TX 015b` (`REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`)
confirmed failing pre-fix (crashed identically to the raw repro), `git stash`-reverted and
reconfirmed byte-for-byte, restored. C2 is now fully closed, both directions. Commit `b2b14f2`.

### `#73C` — `URC_WorthWSTOA`: weight-omission + whole-amount depth-skew (two bugs, both fixed)

Surfaced from a design discussion (owner asked how "worth of a token in WSTOA" *should* be
computed, following up on `#65fL` Phase 8b's own never-resolved "values decision"). Owner correctly
reasoned through the right generic design (best-path no-fee simulated swap; price 1 unit and scale,
accepting that as the unavoidable compromise) and caught both bugs before implementation started.

1. **Weight-omission** (`URC_SingleOuroWorthWSTOA`, the OURO shortcut): computed a flat
   `primordial-wstoa-value / ouro-reserve` ratio, silently assuming the primordial pool's three
   tokens (SSTOA/OURO/WSTOA) are equally weighted. They aren't — issuance weights are `[0.3, 0.5,
   0.2]`. Confirmed live: old shortcut returned 91.95 WSTOA for 100 OURO; the real weighted-pool
   rate is ≈149.9; the pre-existing (unaffected) graph-search fallback independently returned
   147.31, confirming the mechanism precisely.
2. **Whole-amount depth-skew** (the general graph-search fallback, every non-major token):
   `URC_PoolValue`'s real call pattern passes a pool's *entire* first-token reserve as the amount to
   price — the old code simulated a swap of that whole amount, an unrealistic "liquidate everything
   in one trade" scenario. Confirmed live on the `MPTEST` fixture: `worth(300)` collapsed to 272.09
   (rate 0.907/unit) instead of 300× the true 1.496/unit rate (448.71) — a 39% collapse.

Fixed in `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact`: the OURO shortcut now calls `URC_W-Swap`
directly (real weighted-pool math, 1-unit, still zero graph search — OURO/WSTOA are direct pool
siblings), and the general fallback across all three `URC_WorthWSTOA`/`FromRaw`/`FromGraph` variants
now prices 1 unit and scales linearly instead of simulating the full amount. Both bugs adversarially
proven independently via live reproduction + `git stash` revert-and-compare; new permanent proof
`SWP|TX 032z8e`, existing `SWP|TX 032z6f` strengthened with real assertions. Small, disclosed gas
cost on the tracked checkpoints (`SWP|TX 032q` +850, `SWP|TX 032z2` +849 gas) — the accepted cost of
a real correctness fix. Commit `dbeb73b`.

**One explicit follow-up flagged, not yet done:** `URC_OuroPrimordialPrice` (the dollar-denominated
OURO price, built off the same shared `URCX_PrimordialValueAndOuroSupply` core) likely carries the
identical weight-omission bug. Unverified, untraced — this whole investigation started from the
WSTOA-denominated case, not the dollar one. See section 4.

### `#74` — duplicate token within one pool's own token list (verified safe, documented, no fix)

Left over from the Kaddex comparison as "unconfirmed, needs a trace." Checked live: issuing a
nominal 3-token pool as `[OURO, OURO, W1]` **is already rejected**, cleanly, whole-transaction-
atomic. But the rejection doesn't come from `UEV_Issue`'s own validation (which has no distinctness
check at all) — it comes from `TFT::C_MultiTransfer`'s own `U|LST::UC_IzUnique` uniqueness guard,
one layer down, reached because both real issuance paths (`SWPI::C_Issue` and `MTX-SWP::C_Issue`)
share the same `XE_IssueWrite` write chokepoint (unified back at Fix #22/M5).

Owner confirmed this is deliberate design, not an oversight: don't duplicate a check a composed
dependency already guarantees on every real path. Documented rather than left as an implicit,
easy-to-lose guarantee: `@doc` added directly on `UEV_Issue` (`16_SWPI.pact`) recording exactly
where the protection lives, plus a new permanent regression proof (`SWP|TX 032o3`,
`REPL/Stage_01/[6.3]_SWP.repl`) that would catch a future refactor (e.g. moving deposit collection
away from `C_MultiTransfer`) silently dropping the guarantee. No functional code changed. Commit
`d5cb352`.

### Also this session: a corrected verification of a prior recommendation

While discussing whether SWP needs a Kaddex-style `MUTEX` reentrancy lock (conclusion: no), the
first supporting claim ("Pact detects recursion") was accepted from Kaddex's own source comment
without independent proof. Went back and built real, isolated REPL repros before letting that stand
as verified fact — found the first proof attempt was itself confounded by an unrelated Pact
behavior (`try` forces read-only execution on anything it wraps, masking real results as "crashed"
regardless of the actual cause). Corrected methodology, got a clean answer: Pact 5 blocks *both*
same-function recursion *and* cross-function reentry into an already-active module reached through
a real callback — stronger protection than "recursion detection" alone would suggest, and directly
on point for the Kaddex comparison (a classic reentrancy attack calls a *different* function of the
same contract, not the same one). Full writeup, both findings:
`OuronetInformational/memories/2026-08-29-recursion-detection-and-try-forces-readonly.md`. No code
change — this closes out the epistemic gap behind an already-shipped recommendation, doesn't reopen
anything.

## 3. Deliberately deferred — not blocking, tracked, meant for `main`

None of these were ever scoped as "finish before merge." Listed here so nothing gets lost, not
because any of them need to happen before this branch lands.

| Item | What it is | Where it's tracked | Why deferred |
|---|---|---|---|
| `#32bM` | M11/M12 reachability correction (`MTX-SWP` fee-before-gate ordering, no-TTL rollback) — verdicts originally rested on a "zero Talos wiring, unreachable" premise later found factually wrong (`TS01-CP` has wired it since the repo's first commit); verdicts left as-is, not reopened | `README.md` line ~105-106 (M11/M12 rows), explicitly called out as the one open item in the Fix-list summary line | Owner's own 2026-08-27 direction: explicitly filed for `main`'s red-team pass, not this branch's job |
| Round III re-verify | Systematic double-check of every already-closed finding | `README.md`'s own cycle table, row "III — Re-verify" | Owner's own 2026-08-27 direction: "this branch's job was the initial fix, scoped and now complete"; `ROUND-03-REVERIFY.md` will not be created on this branch |
| StoicSyntax naming sweep | `KDA-PID`→`STOA-PID` (L58), `URC_Swap`/`URC_InverseSwap`→`URCv_Swap`/`URCv_InverseSwap` (L64), and `UC_ComputeInverseY` now qualifies for the same `v`-specialization treatment too (added a load-bearing `enforce`, see `#72C`) | `ISSUES-RANKED.md` L58/L64 entries | Owner's established sequencing: one dedicated protocol-wide refactor pass after all audits finish, not piecemeal renames mid-audit |
| Router direct-pair fast path | `URC_HopperActive` always builds the full graph + runs BFS even when a direct A→B pool exists; Kaddex's `staking.get-path` short-circuits this case. Pure gas optimization, not a bug | `reference/KADDEX-COMPARISON-HANDOFF.md` §2 item 4-equivalent (surfaced during this session's own Kaddex-comparison pass, not in that file itself) | Optional, never actioned, no urgency — natural next phase of the `#65bL` arc if ever revisited |
| Live-vs-local (Pythia) status | Diffing local tree against live deployment | `README.md`, "Live-vs-local (Pythia) status" section | Explicitly ruled **MOOT** by owner 2026-08-27 — full redeployment planned regardless, so the diff has no value |

## 4. The one item genuinely worth a look, not just deferred by design

**`URC_OuroPrimordialPrice`'s dollar-denominated math** (`16_SWPI.pact`) — flagged in `#73C`'s own
writeup as *likely* carrying the identical weight-omission bug just fixed on the WSTOA-denominated
side (`URC_SingleOuroWorthWSTOA`). Both build off the same shared `URCX_PrimordialValueAndOuroSupply`
core; the WSTOA side's fix replaced its own final division with a real weighted-pool swap, but the
dollar side's own final division (`primordial-wstoa-value-in-dollarz / ouro-supply`) was left
completely untouched, specifically because this whole investigation started from the WSTOA case, not
the dollar one. This is **not confirmed** — nobody has traced or reproduced it — but given the WSTOA
sibling's bug was real and the two functions share the exact same math shape, it's the most likely
next real finding in this file if someone goes looking. Recommend a 15-minute trace + live check
before assuming it's fine either way.

## 5. How to re-verify before/after the merge

```bash
cd REPL

# Full suite (all DPTF/SWP tests) — toggle Stage01_Tester.repl to uncomment
# [6.2]_DPTF.repl + [6.3]_SWP.repl, comment [6.2+3]_DPTF-SWP_Issuance-Only.repl
pact Z.repl          # full pipeline (Stage 00 sandboxes -> 00a Stoa tests -> Stage 01 -> Stage 02)
# or, Stage 1 only:
#   cat > /tmp/_run.repl <<'EOF'
#   (load "Stage00_Sanboxes.repl")
#   (load "Stage01_Tester.repl")
#   EOF
#   pact /tmp/_run.repl
```

**Toggle gotcha** (this tripped up nothing this session, but it's the one manual step every phase in
this whole branch's history had to remember): `REPL/Stage01_Tester.repl` lines ~51-53 pick between
the full suite and the faster default issuance-only path — exactly one of `[6.2]_DPTF.repl` +
`[6.3]_SWP.repl`, or `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, should be uncommented at a time. The
default committed state is issuance-only (`[6.2+3]` uncommented, the other two commented) — confirm
`git diff --stat REPL/Stage01_Tester.repl` is empty after any verification run before trusting the
tree is clean. Some of this session's most detailed proofs (`SWP|TX 032z6f`, `032z8e`, `015b`) live
in the full-suite-only files, so a genuinely complete check needs both paths run at least once.

Expected result on both paths, as of this branch's tip (`d5cb352`): `EXIT:0`, `0 FAILURE`,
`Load successful`.

## 6. Key file map

| File | What's in it |
|---|---|
| `README.md` | Living status tracker — module scope, the full status table (#1C→#74), cycle summary |
| `ISSUES-RANKED.md` | Flat #1C→#74 severity-ranked index, one paragraph per finding — fastest lookup |
| `ROUND-01-FINDINGS.md` | Raw finding text, frozen, Round I only |
| `ROUND-01-OWNER-FEEDBACK.md` | Full reasoning + verdict per finding, append-only, includes every "owner pushed back and was right/wrong" exchange verbatim |
| `ROUND-02-FIXES.md` | The actual fix, one entry per Fix #, sequential, includes every adversarial-proof writeup |
| `reference/` | Kaddex/KDX mainnet source + comparison handoff (new this session, now tracked) |
| `OuronetInformational/HANDOFF-swp-graph-search-engine-optimization.md` | Dedicated `#65bL` gas-arc writeup, all 9 phases |
| `OuronetInformational/memories/2026-08-29-recursion-detection-and-try-forces-readonly.md` | Pact recursion/reentrancy semantics + the `try`-forces-read-only gotcha, both independently proven this session |

## 7. Sign-off

Everything in scope for `swp` is closed, proven, and committed. The deferred items in section 3 are
known, tracked, and intentionally left for post-merge work on `main` — merging is what enables them,
not something blocked by them. Section 4's one item is worth a look but isn't a known bug. Regression
clean on both suite paths as of commit `d5cb352`, tree clean, nothing pending.

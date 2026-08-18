# SWP Audit — HANDOFF (resume in a new chat / new worktree)

**Written:** 2026-08-18, end of a long session. **Read this file first, before anything else in this
folder**, then load `OuronetInformational/SKILL.md` per the normal load order, then re-verify everything
below against the actual committed files — do not trust this document's claims blindly, that exact
failure mode (trusting a stale summary instead of the real files) is *why* this document exists.

---

## 0. Do this first — before touching any code

1. **Check whether the uncommitted SWP changes described below actually exist in your working tree.**
   If you're in a fresh `git worktree`, uncommitted changes from the original working tree **do not
   carry over automatically** — worktrees check out commits, not dirty state. Run:
   ```
   git status --short
   git diff --stat -- '1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact'
   ```
   If it comes back clean (no diff), **all of §2/§3's work is not present** and needs to be re-applied
   from this document + `ROUND-02-FIXES.md` Fix #10, or cherry-picked from wherever the prior session's
   worktree/branch ended up. Ask the user where the SWP work actually landed before assuming it's lost.
2. **Read `OuronetInformational/memories/2026-08-18-HANDOFF-lost-uncommitted-work-shared-worktree.md`
   first.** This repo's `main` working tree is (or was) shared by multiple concurrent Claude sessions
   auditing different modules (SWP, ATS, AQP) simultaneously, with nothing committed. That memory file
   documents a real, confirmed data-loss incident: a `git stash` run *by this session* (to test whether
   an unrelated failure was pre-existing) raced against another concurrent session's own edits and
   silently reverted files for **both** sessions — not a hypothetical risk, it actually happened, twice
   (once here, independently confirmed by the ATS session's own write-up). **Do not run `git stash` in
   this working tree.** If you need to isolate a change for adversarial pre/post-fix testing, do it by
   hand with the Edit tool (revert the exact lines, test, restore the exact lines, test again) — never
   via stash/checkout/reset on shared files.
3. If the user's intent in opening a new worktree is specifically to get away from that shared-tree risk,
   that's the right call — **commit the SWP-only changes** (file list in §2) to a dedicated branch before
   or as part of setting up the new worktree, so this stops being fragile. Nothing SWP-related has been
   committed yet as of this handoff — it's all still working-tree edits on `main`.

---

## 1. What this is

Continuing a Round-I "Owner Feedback" pass over `1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/ROUND-01-FINDINGS.md`
(71 findings, frozen). Findings are presented **one at a time**, in `ISSUES-RANKED.md` order (`#1C` →
`#71L` — **always use this ranking number**, never the raw finding ID like `C6`/`H4` alone, that ambiguity
already caused one real mix-up this session). Owner gives a verdict (CONFIRMED/FIXED, REFUTED, DESIGN,
DOC-FIX, CONVENTION); every settled verdict gets written into `ROUND-01-OWNER-FEEDBACK.md` (append-only),
`README.md`'s tracker row, `ISSUES-RANKED.md`'s strike-through annotation, and — if code changed —
`ROUND-02-FIXES.md`, **in the same turn the verdict is reached, before moving to the next finding.** This
is now a written **HARD RULE** near the top of `README.md` (added this session) — it exists because three
findings (`#11C`/`#12C`/`#13C`) got silently skipped earlier in this same audit and the gap wasn't caught
until the owner asked to audit the audit process itself. Don't let that recur.

**Fix methodology, established and repeatedly used, non-negotiable:** (1) verify every claim against live
source before accepting it, don't trust the finding doc or your own memory; (2) apply the fix; (3) build a
REPL reproduction; (4) **adversarially prove it** — revert just the fix (surgically, by hand, never via
git), confirm the bug reproduces, restore the fix, reconfirm; (5) run the full regression suite; (6) log
in all four places per the HARD RULE above. The owner explicitly and repeatedly demanded step 4 — do not
skip it, do not accept "it should work" without a live repro, and do not trust a green test run you
haven't actually watched fail first without the fix.

---

## 2. Current state of the SWP-relevant working-tree diff (uncommitted, as of this handoff)

These files carry real, tested, already-logged SWP work. **These are the ONLY files this audit should
touch or commit:**

```
1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact          (+1: SwapperV3.URC_ActiveSwpairs decl)
1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact           (UC_MakeGraphNodes rewrite + earlier fixes)
1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact                 (URC_MakeGraph/URC_EdgesActive/guard + earlier)
1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact                  (URC_ActiveSwpairs + earlier fixes)
1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact                 (URCX_Hopper split + earlier fixes)
1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact                (H11 fix)
1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact                 (URC_HopperActive call-site switch)
1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact              (C9 historical-context doc comment)
1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/ISSUES-RANKED.md   (annotations through #20H)
1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/README.md          (tracker + HARD RULE)
1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/ROUND-01-OWNER-FEEDBACK.md (entries through #20H)
1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/ROUND-02-FIXES.md  (Fix #1 through Fix #10)
REPL/Stage01_Tester.repl                                 (should be at the fast issuance-only default —
                                                            [6.5]/[6.6] commented out; verify this, it
                                                            was found toggled ON once already this
                                                            session, likely from the stash incident)
REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl        (SWP|TX 015-029, all reproductions)
OuronetInformational/pact5/SEMANTICS.md                  (small factual corrections, see git diff)
```

Plus **untracked** files that are safe/expected:
```
OuronetInformational/memories/2026-08-17-decimal-exponentiation-loses-precision-via-float64.md
OuronetInformational/memories/2026-08-17-mtx-swp-multi-step-no-longer-gas-required.md
OuronetInformational/memories/2026-08-17-reentrancy-is-sandboxed-not-absent.md
REPL/_swp_fix_check.repl   (scratch harness, see §4 — safe to keep or delete)
```

**Do NOT touch, revert, or commit these — they belong to other concurrent sessions (ATS/AQP audits)
sharing this same working tree, not this one:**
```
1_SOVEREIGN/STAGE_01/1_Utilities/09_U_ATS.pact
1_SOVEREIGN/STAGE_01/1_Utilities/10_U_DPTF.pact
1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact
1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact
1_SOVEREIGN/STAGE_01/2_Core/Audit/ATS/*.md  (all of them)
1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact
1_SOVEREIGN/STAGE_01/3_Talos/03_TS01-C2.pact
1_SOVEREIGN/STAGE_01/3_Talos/05_TS01-P.pact
OuronetInformational/pythia-dirty-read-access.md
various other REPL/_*.repl scratch files not named _swp_fix_check.repl
```
If `git status` ever shows unexpected changes in files you don't recognize as SWP work, **stop and ask**
rather than assuming they're yours or reverting them — see §0.2's incident.

---

## 3. Full finding status, `#N<letter>` ranking only — this is the authoritative current picture

### CRITICAL
| # | Status |
|---|---|
| #1C | REFUTED — substance moved to #25H |
| #2C | REFUTED (retracted) |
| #3C | **FIXED ✅ AND PROVEN ✅** |
| #4C | REFUTED (retracted) |
| #5C | DESIGN — closed |
| #6C | **FIXED ✅ AND PROVEN ✅** |
| #7C | **FIXED** (stable) / ACCEPTED LIMITATION (weighted) |
| #8C | **FIXED ✅ AND PROVEN ✅** |
| #9C | **FIXED ✅ AND PROVEN ✅** |
| #10C | **FIXED ✅ AND PROVEN ✅** |
| **#11C** | **PENDING — fully presented to owner, awaiting verdict. Full text: `ROUND-01-FINDINGS.md` § C4 (`UEV_Issue` never checks individual pool weights are >0 — permanent div-by-zero on a W pool).** |
| **#12C** | **PENDING — fully presented to owner, awaiting verdict. Full text: `ROUND-01-FINDINGS.md` § C5 (`UEV_Issue` never checks individual genesis reserves are >0 — permanent div-by-zero on first touching swap).** |
| #13C | **FIXED ✅ AND PROVEN ✅** (this session, combined with #19H/#20H — see §5) |

### HIGH
| # | Status |
|---|---|
| #14H | REFUTED |
| #15H | DESIGN — closed |
| #16H | **FIXED ✅** |
| #17H | **FIXED ✅ AND PROVEN ✅** |
| #18H | **FIXED ✅** |
| #19H | **FIXED ✅ AND PROVEN ✅** (this session, combined with #13C/#20H — see §5) |
| #20H | **FIXED ✅ AND PROVEN ✅** (this session, pulled forward from its ranked position and closed as part of the same fix — see §5 for why) |
| **#21H** | PENDING — not yet presented. `ROUND-01-FINDINGS.md` § H3. |
| **#22H** | PENDING — not yet presented. § H7. |
| **#23H** | PENDING — not yet presented. § H5. |
| **#24H** | PENDING — not yet presented. § H1. |
| **#25H** | PENDING — mechanism fully traced and confirmed (folded in from #1C's REFUTED writeup), open *design* question recorded for the owner in `ROUND-01-OWNER-FEEDBACK.md`'s C10/#1C entry: is protocol-wide value capture (vs. per-pool LP protection) intentional? § H8. |

### MEDIUM — `#26M`–`#39M`, 14 findings, **all PENDING, none presented yet.** Full list `ISSUES-RANKED.md` § MEDIUM.
### LOW — `#40L`–`#71L`, 32 findings, **all PENDING, none presented yet.** Full list `ISSUES-RANKED.md` § LOW.

**So: what actually needs picking up is `#11C`, `#12C`, then continue ranked order from `#21H` onward.**
`#13C`/`#19H`/`#20H` are genuinely done — verified via 3 independent adversarial pre/post-fix proofs each,
logged in all four files, full regression green. Don't re-litigate them without a specific new reason to.

---

## 4. The `_swp_fix_check.repl` scratch harness — why it exists, use it

`REPL/Z.repl` and `REPL/Stage01_Tester.repl` (as currently configured) pull in Stage 1 content this audit
doesn't own or need (`[6.5]_DPOF.repl`, `[6.6]_ATS.repl`) which, at various points this session, was
broken by the *other* concurrent sessions' in-progress work (confirmed pre-existing/unrelated via
`git stash` on a clean checkout — before the stash-danger lesson in §0.2 was learned the hard way).
`REPL/_swp_fix_check.repl` is a minimal scratch harness that loads exactly what SWP testing needs (Stage
00 sandboxes → Starter/Interfaces/Utilities/Dalos/Core/Talos → Sovereign-Executor → Aoz+/Dispenser+ slaves
→ the SWP issuance-only suite) and stops before DPOF/ATS. Run it from `REPL/`:
```
cd REPL && pact _swp_fix_check.repl
```
**It may transiently fail with an unrelated error from a concurrently-edited file** (seen this session:
`10_ATSU.pact` interface-mismatch, mid-edit by the other session) — if so, wait a few seconds and retry;
it resolved within 1-2 retries every time it happened. If a failure persists after several retries and
points at a file outside SWP's scope, it's not yours to fix — note it and move on, don't touch it.

If `Z.repl`/`Stage01_Tester.repl` become viable again later (other sessions' work stabilizes/gets
committed), prefer them for the final regression check before closing out the round — they're the
canonical suite. Until then, `_swp_fix_check.repl` is the reliable SWP-scoped substitute.

---

## 5. What was just finished — #13C + #19H + #20H combined fix

Full detail already logged in `ROUND-02-FIXES.md` Fix #10 and three `ROUND-01-OWNER-FEEDBACK.md` entries
(search for `#13C`, `#19H`, `#20H` in that file) — read those for the complete diff and proof transcripts.
Short version, so you don't have to go read it immediately:

- **Root cause:** `SWPI::URC_Hopper` fed the full unfiltered swpair list into the graph. `UC_MakeGraphNodes`
  narrowed *nodes* to ≤1 hop from input/output, but `URC_TokenNeighbours`/`URC_Edges` read the live
  `SWPT|Tracer` table directly, bypassing any caller-supplied filter entirely — node envelope narrower
  than the real edge-set (#13C), and nothing anywhere excluded `can-swap=false` pools from routing (#19H).
  `URC_ComputeGraphPath`'s `(at 0 fp)` crashed instead of returning `[BAR]` when no chain reached output
  (#20H) — closed alongside the other two since their fix makes that a normal, frequent case for the
  first time.
- **Fix took two build-test iterations to get right, both corrected by testing, not prediction** — see
  Fix #10's write-up for exactly what broke each time and why. The short lesson: filtering the top-level
  `swpairs` argument is necessary but not sufficient; the Tracer-backed neighbor/edge lookups
  (`URC_TokenNeighbours`, `URC_Edges`) need the same filter applied at their own layer too, or BFS can
  still treat two tokens as linked via a specific pool that turns out to be disabled.
- **Owner's design corrections that shaped this (apply generally, not just to this fix):** no artificial
  gas-budgeted max-hop constant (the pool architecture's principal-anchoring already provides a real
  bound); no bounded retry loop (Pact is Turing-incomplete — don't propose "just retry N times" fixes);
  deploy-order constraints (e.g. SWPT loading before SWP in fresh REPL runs) only matter for REPL
  bootstrap ordering, not for upgrading already-live mainnet modules.
- **Adversarial proof:** built a genuine 4-hop chain + parallel shortcut using previously-unpooled
  elemental tokens (`SWP|TX 024a`-`029` in `[6.2+3]…repl`), reverted each fix layer individually by hand,
  confirmed each bug reproduces live against real pool state, restored, reconfirmed. See §0.2 — this was
  all done with manual Edit-based reverts, specifically *because* `git stash` had just proven unsafe in
  this tree.

---

## 6. Immediate next step for whoever picks this up

Present `#11C` (or resume wherever the user directs) using the working protocol in §1. If the user just
says "continue," that means: state `#11C`'s full finding (pulled fresh from `ROUND-01-FINDINGS.md`, not
from memory), verify its claims against current source before recommending anything, and wait for a
verdict — don't fix anything preemptively.

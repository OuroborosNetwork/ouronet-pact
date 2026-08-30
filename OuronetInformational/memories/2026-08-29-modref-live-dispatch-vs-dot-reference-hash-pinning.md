# 2026-08-29 — `::` modref dispatch is live/unpinned; `.` dot-reference is hash-pinned and needs `bless`

## What was tested

Direct, empirical test against `pact version 5.4.1` (the exact toolchain this repo runs), not
inferred from docs. Two minimal REPL experiments, both: deploy module A with a table-touching
function, deploy a second module that calls into A, call it once, upgrade A **in place** (same
module name, new governance-approved code, changed the function's return value so new-vs-old code
is unambiguous) **without redeploying the caller**, call the caller again.

- **`::` on a `module{Interface}`-typed reference** (`(let ((ref-A:module{IA} A)) (ref-A::get-val "k"))`)
  — resolved to the **new** code immediately after the upgrade. No pin, no error, no `bless` needed.
- **`.` on a direct static reference** (`(A.get-val "k")`) — the calling module's compiled
  definition pinned A's hash at its own deploy time. After upgrading A without redeploying the
  caller, the next call **hard-failed**: `Execution aborted, hash not blessed for module A: <hash>`.

## Why this matters for this repo

This repo's StoicSyntax convention already mandates `::`/modref for all cross-module calls, never
`module.function` (`.`) — see `CLAUDE.md`: "Cross-module calls use module references with `::` …
not `module.function`". This test confirms that convention is not just a style/coupling preference,
it is **the actual mechanism** that has made `bless` unnecessary here so far: every cross-module
call in `1_SOVEREIGN`/`2_CITIZEN` that follows the convention is immune to hash-pinning breakage on
in-place upgrades, because `::` dispatch is always resolved live against whatever's currently
deployed under that name — never pinned to a stale hash.

**The one remaining exposure:** a `.`-style dot-reference from a module this project doesn't fully
control (most plausibly a `2_CITIZEN/` third-party module) into a sovereign core module that later
gets upgraded in place. That combination — and only that combination — is where `bless` would
actually become necessary, and where an in-place sovereign upgrade could silently break an
already-deployed dependent with no way for that dependent to self-heal.

## Correction to a wrong claim made earlier in the same session

An earlier answer in this session (before this test) claimed `::`/modref references get the same
"inlined dependency hash, checked against a blessed set" treatment as `.` references — sourced from
web-search snippets of Pact documentation, one of which was a page explicitly titled "DEPRECATED
Pact Smart Contract Language Reference." That claim was wrong for modref/`::` dispatch on Pact 5.4,
as directly demonstrated above. The underlying hash-pinning/bless mechanism is real, but it appears
specific to `.`-style static references (and very likely to explicit hash-pinned `(use M "hash")`,
untested here) — not to `module{Interface}`+`::` dispatch, which is always live.

## Test files (not committed, for reproduction only)

`/tmp/modref_upgrade_test.repl` (the `::` case, succeeds/live) and `/tmp/dotref_upgrade_test.repl`
(the `.` case, fails with the bless error) — ephemeral scratch files outside the repo, reproduce
from this note's description if needed again.

## Follow-up (same day): what `bless` actually restores, and the pure-function footgun

Two more tests completed the picture:

- **`.` reference to a PURE function (no table access) never hash-checks at all** — it's inlined
  into the caller at the caller's own deploy time and stays frozen forever, silently, with **no
  error ever raised**, even after the source module changes. Tested: `/tmp/dotref_pure_test.repl`
  — caller kept returning the old value (`1`) after the callee was changed to return `1000`, no
  crash, no warning. This is a strictly worse failure mode than the stateful case (which at least
  fails loud) — a real footgun if `.` is ever used unintentionally.
- **`bless`ing a `.` caller's old hash does NOT give it the new code** — it lets the caller keep
  executing **the exact old frozen logic it was compiled against**, permanently, immune to whatever
  the dependency ships next. Tested: `/tmp/dotref_blessed_test2.repl` — after blessing A v1's hash
  and changing `get-val` to add `+1000`, the `.`-referencing caller still returned `1`, not `1001`.
  So `.` + `bless` is a genuine version-pinning mechanism (like a lockfile), not a "let old callers
  through to new code" waiver.

Full three-way comparison (pure-or-stateful × `::`/`.`/`.`+`bless`), all tested against Pact 5.4.1:

| Reference | Function kind | Behavior after in-place upstream upgrade, caller not redeployed |
|---|---|---|
| `::` modref | pure or stateful | Always live — resolves to current code, every call |
| `.` | stateful, un-blessed | Hard fails: `hash not blessed for module A` |
| `.` | stateful, blessed | Succeeds, but keeps running the OLD frozen logic forever |
| `.` | pure | Silently frozen forever, no error, ever — the most dangerous case |

**Why `.` is ever legitimate, given this:** it's deliberate version pinning against upstream drift,
not an inferior `::`. For code inside a single trust boundary (this repo's own sovereign core,
tested and redeployed together) `::` is unambiguously correct. The one place `.` is a rational
choice *in this ecosystem* is a `2_CITIZEN/` third-party module calling into sovereign core APIs —
an arms-length integrator who deployed against a specific audited version and does not want this
project's governance silently changing their contract's behavior without their consent. If they
reference sovereign functions via `.`, a later sovereign upgrade can't touch them unless this
project explicitly `bless`es the old hash for them — and even then they keep their originally-tested
behavior, not whatever ships next.

---
Companion: `2026-08-29-modref-interface-semantics.md` (interface membership, dynamic
dispatch, the cascade lever). Together the two fully characterize modref behavior on 5.4.1.

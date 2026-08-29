# Modref ↔ interface semantics — SETTLED empirically (pact 5.4.1, 2026-08-29)

## The question (owner)
When calling a previous module via a modref (`ref-M::fn`, `ref-M:module{IfaceVn}`), must `fn` be
declared in the interface `IfaceVn` — i.e., does adding a new cross-module function REQUIRE adding
it to a (bumped) interface version?

## Verified answer: NO — not for correctness. Resolution is DYNAMIC at runtime.
Minimal REPL proof (both `/tmp/modref_iface_test.repl` + `/tmp/modref_missing_test.repl`):
- `module{Iface}` only enforces the passed module **implements Iface's declared members**. It does
  NOT restrict which functions you may call on the ref.
- Calling `ref::g` where `g` is NOT in the interface **loads AND runs fine** — provided the concrete
  module actually has `g`. Result: `CASE B (NON-interface fn via modref) => g-NOT-in-interface`.
- If the concrete module is MISSING `g`, you get a **fatal RUNTIME error** (`Unbound free variable
  M2.g`), and only when that path executes — never at load.

## Why you still NAME an interface in the modref (two independent roles)
The interface in `ref:module{IfaceV1}` is NOT "the list of functions you may call." It does two
jobs, and the function-listing is not one of the mandatory ones:
1. **It is the ref's TYPE (required syntax).** A module-reference value must be typed against
   interface(s); there is no untyped `module` ref.
2. **It is the MODULE contract.** Whatever you bind must `implements IfaceV1` → it whitelists WHICH
   MODULE is acceptable, not which function.
3. **It decouples DEPLOY ORDER (the real architectural reason Ouronet uses modrefs).** Interfaces
   deploy before modules; a caller written against `module{IfaceV1}` only needs IfaceV1 at ITS deploy
   time, not the concrete module M. Calling `M.g` directly would force M to deploy before the caller
   — the coupling modrefs exist to break. The interface is the forward-declaration stand-in.

Mental model: `module{IfaceV1}` gates WHICH MODULE; `::fn` picks WHICH FUNCTION (dynamic). The named
interface just has to be ONE the target module implements — it need NOT contain the called function.
Name the module's primary/latest interface; declaring the specific fn there is the separate SAFETY
choice below.

## Why it works for Ouronet
One implementer per interface (modules `implements` only the latest version; modrefs decouple
DEPLOY ORDER, not polymorphism). Every `ref-M::fn` targets exactly one known module that has the
function → dynamic resolution always succeeds. The "missing fn" failure only arises with real
polymorphism (multiple implementers), which Ouronet does not use.

## What declaring in the interface ACTUALLY buys (measured — corrects an earlier over-claim)
Verified pact 5.4.1 (t_a/t_b/t_c):
- TEST A — wrong-arg call to an INTERFACE MEMBER via modref → **Load successful** (NOT caught).
- TEST B — wrong-arg call to a NON-member via modref → **Load successful** (NOT caught).
- TEST C — module drops a DECLARED member → **Load FAILED** ("does not implement interface member").
So modref calls are **dynamically dispatched AND dynamically typed regardless of interface
membership** — the CALLER side gets ZERO load-time checking either way (no arg-type check, no
typo catch). Declaring does NOT give call-site type safety.
The ONE load-time guarantee declaring buys is the **module-side `implements` contract** (TEST C):
a declared fn CANNOT be dropped/renamed/re-signatured in the module without the module failing to
deploy → catches DRIFT at deploy instead of a caller's runtime "Unbound free variable".
Other genuine value: (2) the interface is the **machine-readable public-API enumeration** that
feeds the INFO catalog (Phase 2.3), UI (Phase 8), Documentation (Phase 9); (3) docs/signature intent.
For single-implementer Ouronet with full REPL coverage + a redeploy gate, the REAL caller-side
safety net is the TESTS, not the interface.

## SETTLED POLICY for the final shape
- **Declare cross-module functions in their interface for the enumeration + module-side drift-catch
  — NOT as a correctness requirement** (undeclared works; tests are the caller-side safety net). Internal-only
  helpers (`XI_`/`UC_`/private) stay OUT (never called via modref).
- Cost is low: **pre-redeploy, interfaces are edited FREELY (no per-function bump)** — add the
  interface declaration in the SAME edit as the new cross-module function. The single **Phase-7**
  bump (live+1) captures the whole final shape at once.
- Cascade (Phase 7) is triggered by interface CHANGES (added members) + interface-owned schema/type
  refs (`module{B}` / `object{B.Schema}`) — the modref call itself does not force it, but following
  the declare-everything convention means an added cross-module fn = an interface edit = part of that
  interface's one bump.

## Empty / marker / no-interface (verified pact 5.4.1, q1/q2/marker)
- **Empty interface `(interface x)` = ILLEGAL** — Pact requires ≥1 member ("Expected `(`").
- **Marker interface (one `defconst`, ZERO defuns) = VALID** and works as a modref type: a caller
  typed `module{marker}` can call ALL the module's functions (`f`,`g`, even an `h` added later that
  is never in the interface). Result: `["M.f","M.g","M.h-added-later"]`. So a **stable marker
  interface never has to change as the module gains functions.**
- **Module with NO interface = CANNOT be modref'd** — `module{}` is a syntax error and
  `module{ModuleName}` fails (a module isn't an interface type). No interface → direct `M.f` only →
  reintroduces deploy-order coupling. So every modref target needs ≥1 interface (even a marker).

## THE CASCADE LEVER (answers "every module update → interface bump → whole-code refactor")
- Adding functions to a module does NOT require changing its interface (dynamic dispatch) → does NOT
  have to trigger a bump/cascade.
- **Cascade size = how many interfaces CHANGE vs live — not how many functions you add.** You control it.
- Marker interfaces never change → zero cascade from function growth. Rich interfaces (declare public
  fns) change when you add fns → those bump at Phase 7 → cascade to their consumers.
- Repo policy makes it bounded: pre-redeploy interfaces edit FREELY (no bump); the single Phase-7
  diff-vs-live is the only bump event; cascade = updating `module{IfaceVn}` refs for the interfaces
  that differ from live.
- Trade-off: rich = enumeration/docs/drift-catch but more cascade; marker = zero fn-add cascade but
  the interface tells you nothing. NB the enumeration lost with markers is already provided by the
  entrypoint-surface catalog (Phase 2.3) + Talos layer + the REPL suite — so marker-lean is viable.

## Relevance
Directly informs URCi (Phase 1 — new `URCi_*` composers/leaves called cross-module → declare them)
and Phase 7 (version bump + cascade). Not "bump per function" — "declare per cross-module function,
bump per interface, once, at redeploy."

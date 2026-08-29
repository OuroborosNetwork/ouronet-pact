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

## What declaring in the interface still buys (why we keep the convention)
1. **Load-time safety** — a typo / wired-but-missing fn becomes a LOAD error instead of a runtime
   "Unbound free variable" that ships silently until the path runs (the exact "forgot to add it" bug).
2. **Signature pinning** — `(implements Iface)` checks each member matches signature; catches arg/
   return drift.
3. **Docs** — the interface is the declared public API (CLAUDE.md).

## SETTLED POLICY for the final shape
- **Declare every function called CROSS-MODULE (via modref) in its interface.** Internal-only
  helpers (`XI_`/`UC_`/private) stay OUT (never called via modref).
- Cost is low: **pre-redeploy, interfaces are edited FREELY (no per-function bump)** — add the
  interface declaration in the SAME edit as the new cross-module function. The single **Phase-7**
  bump (live+1) captures the whole final shape at once.
- Cascade (Phase 7) is triggered by interface CHANGES (added members) + interface-owned schema/type
  refs (`module{B}` / `object{B.Schema}`) — the modref call itself does not force it, but following
  the declare-everything convention means an added cross-module fn = an interface edit = part of that
  interface's one bump.

## Relevance
Directly informs URCi (Phase 1 — new `URCi_*` composers/leaves called cross-module → declare them)
and Phase 7 (version bump + cascade). Not "bump per function" — "declare per cross-module function,
bump per interface, once, at redeploy."

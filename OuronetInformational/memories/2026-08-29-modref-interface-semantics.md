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

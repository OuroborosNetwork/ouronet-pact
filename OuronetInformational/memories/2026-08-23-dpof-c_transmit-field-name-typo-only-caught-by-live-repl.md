# 2026-08-23 — DPOF `C_Transmit` was completely dead-on-arrival; only caught by live REPL execution, not code-trace

**Context:** DALOS audit, fixing #3C (DPOF nonce-uniqueness). Building the REPL proof for #3C's
sub-mechanism (b) — negative nonce-supply corruption via `C_Transmit`/`DPOF|C>DEBIT` — required a
*working* `C_Transmit` call to test duplicated nonces against. The very first attempt, with a completely
ordinary, non-duplicated, single-nonce input, crashed immediately.

## What was assumed

That `C_Transmit` was a normal, working function whose only relevant defect (per Cluster 4's Round-I
audit pass) was the nonce-uniqueness gap being fixed. Cluster 4's own pass was code-trace-only (no `pact`
binary was available in that lens's environment) and did not flag anything else wrong with `C_Transmit`.

## What's actually true

`DPOF|C>TRANSMIT`'s defcap (`06_DPOF.pact:756`) read `(at "meta-data" td)` on an object whose real,
declared schema field is `meta-data-array` (`defschema TransmitData`, `:319-324`) — and whose constructor,
`UDCX_TransmitData` (`:1683-1689`), correctly builds it with the right key. Only the *consumer* read used
the wrong string. Because Pact's `at` on a missing object key is a hard runtime error (not a type-checked
static error — object literals aren't schema-validated at the call site the way typed function params
are), this compiled and loaded cleanly, and crashed only when actually *called*, unconditionally, for
every input, since the code was written. Confirmed via live `pact` execution: pre-fix, an entirely
ordinary single-nonce call crashes with `Key "meta-data" not found`; post-fix (one-string change to
`"meta-data-array"`), the identical call succeeds and produces exactly the expected balances.

## The corollary that matters for future audits

**A static/code-trace-only audit pass cannot catch an unconditional crash unless the reader happens to
manually cross-check every `defschema`/constructor/consumer key string by eye** — nothing about the code
*looks* wrong from a read-through (the field name `meta-data-array` appears correctly nearby, in the
constructor, just a few hundred lines away; a reader skimming the defcap in isolation has no local signal
that the key string it's reading is wrong). This is exactly the failure mode the ATS/SWP audits'
"live-vs-local" / adversarial-REPL-proof discipline exists to catch — and it caught this one, incidentally,
while proving an unrelated bug (#3C), not because anyone was specifically hunting for it.

## Durable rule

When a Round-I lens reports "code-trace only, no `pact` binary available" for a cluster, treat that
cluster's untested/never-called public entrypoints (the exact class Cluster 4 itself separately flagged as
a coverage gap — DPOF's own REPL suite has zero `expect`/`expect-failure` forms at all) as carrying a real,
elevated risk of a *totally unconditional* defect, not just the specific bug pattern being hunted for —
not merely "this specific input might be miscalculated." Before treating any such function as fixed or
even as merely-buggy-in-the-hunted-way, do a bare, ordinary, happy-path call against it live in a REPL
first, exactly as this session did by accident. Cross-checking `defschema` field names against every
`at "field"` read of an object of that schema (not just the constructor) is a cheap, mechanical check that
would have caught this one directly, without needing live execution at all — worth doing as its own sweep
during the eventual StoicSyntax pass, repo-wide, for every `UDC_*`/`UDCX_*` object constructor paired with
its consumers.

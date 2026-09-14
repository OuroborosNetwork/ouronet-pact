# 2026-09-11 — G3 closed: seven harnesses back in the gate, and the coverage hole they revealed

## Result

All seven `Kursan/_verify_finding_*` harnesses now run in the gate. **Assertions 11,563 → 17,178.**
They were written, passing, and executed by nothing.

## The gate's own diagnosis was wrong in three ways

`_gate.py`'s EXCLUDED note said: *"The eight Kursan verify-finding harnesses share ONE root cause…
`[6.1.4]_DPDC-NF.repl:333`… Fixing that one line unblocks all eight."*

- **Seven**, not eight.
- **Three branding sites**, not one. Fixing `[6.1.4]:333` moved the failure to `[6.1.6]_DPOF:73`,
  then to `[6.1.7]_DPSF-UPDATES:97`. Same guard, same cause, three unconditional call sites.
- **Branding was not the only cause.** Two harnesses then failed on `CAP_EnforceAccountOwnership`
  for the collection's **NFT create-role account** (`DPDC-C.pact:288`, on `UR_Verum5`) — which is
  *not* the collection owner. `DHCD` is owned by ANHD while its create role sits with EMMA, so
  signing only as the patron failed a gate unrelated to the patron.

**Lesson: a documented root cause is a hypothesis.** This one had been recorded confidently enough
that nobody re-tested it, and it kept seven files out of the gate.

## The fixes

1. **Branding time.** BRD permits an upgrade only under 15 days of remaining premium
   (`04_BRD.pact:258`). All three call sites now ask BRD's own question and skip when it is not
   permitted. Each is a print-only smoke step that nothing asserts on. Verified no-ops in the gated
   chains: assertion count unchanged and the SKIP branch never fires there.
2. **Create-role signature.** The two affected harnesses now sign as both the patron and EMMA.
3. **A harness that asserted something false.** `_DPDC-I_33M` expected a same-ticker NFT issuance to
   SUCCEED, reasoning that DPNF and DPSF have separate properties tables. It aborts — in
   `BRD|BrandingTable`, which is **keyed on the bare id and shared across every collection type**.
   Per-type table separation does not give cross-type id independence: the first collection to take
   a ticker takes its branding row. Pinned as the behaviour it actually has.

## The coverage hole this exposed

`_enforce_coverage.py` scans `**/*.repl` for `expect-failure`. It does **not** ask whether the file
is in the gate. So assertions in orphaned files counted as pins while never executing.

Measured by moving the seven aside and re-running:

| | honest pins |
|---|---|
| without the seven harnesses | 526 |
| with them | 535 |
| **pinned ONLY by files the gate never ran** | **9** |

So closing G3 did not raise the coverage number — **it made the existing number true.** Nine guards
had a pin on paper and no execution behind it.

`_gate.py --audit-only` now reports *"orphan check: clean — every asserting file is reachable from
the gate"*, which is what keeps that gap closed. That orphan check also caught the intermediate
state of this very fix: removing the EXCLUDED entries without adding the files to `KURSAN` produced
`GATE FAILED: 7 ORPHANED asserting file(s)`. It is the right guard and it works.

## For anyone reading a coverage figure

Two numbers are needed and they answer different questions:

- `_enforce_coverage.py` — how many guards have a negative test **written** against them.
- `_gate.py --audit-only` — whether those tests are **executed**.

A pin is only worth what the gate runs. Check both.

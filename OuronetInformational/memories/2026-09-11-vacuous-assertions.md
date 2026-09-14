# The positive assertions had never been audited — one of 2,597 could not fail

**Date:** 2026-09-11 · **Status:** closed · tool `REPL/_vacuous.py`

## The gap

`_expectfail.py` audits the NEGATIVE side (a 2-arg `expect-failure` passes on any error) and that
thread is closed. **Nothing audited the positive side**, and there are ~2,600 of them. A positive
assertion has its own failure mode — comparing something to itself, or to a bound it cannot miss.
Both go green forever and read in a diff exactly like a real test.

`_vacuous.py` splits them:

- **VACUOUS** — cannot fail. Expected and actual syntactically identical, or both literals.
- **WEAK** — can fail in principle, not for any realistic value. Reported separately and **not**
  called a defect.

## The one real hit

`Stage_01/[2.1]_Dalos.repl:237` compared `(UC_GuardProtocol key-read)` **to itself**.

Its own doc said `expected=k: or w: (both key-based)` — the intent was "one of two values", which
`expect` cannot express directly, and the self-comparison looks like an unfinished placeholder.

Measuring it made the fix *stronger* than the original intent: a `read-keyset` guard is **always
`w:`**, so the expectation is exact, not a two-way choice. And the part a reader will assume
wrongly — **a keyset holding exactly one key is still `w:`, not `k:`**. `k:` is the protocol for a
bare single-key guard; anything from `read-keyset` is a keyset guard at any size. Both sizes are now
pinned, because the 1-key case alone looks like an accident and the 2-key case alone does not rule
out `k:` for size 1. Mutation-tested: `w:`→`k:` turns the suite red, which the original could not do.

## Two weak ones were mine

`modules/STAGE-Z.repl` had `(>= price 0.0)` and `(>= nonce 0)` — satisfied by construction, so they
asserted only "the call returned". Replaced with the actual relationships: exact unit value,
**linearity in both amount and price**, zero at zero, and the explorer's account nonce asserted
**equal to DALOS's** rather than to a literal — so it keeps holding as the account transacts, and
what is pinned is that the explorer does not drift from the ledger it reports on.

## Hits that are legitimate and will keep appearing

Documented in the tool so they are not "fixed" by someone later:

- **sentinel bounds** — `(> (UR_ScoreClass s) -1)` is a real existence check; `-1` is the "no such
  row" sentinel (`AQP-G14`).
- **acceptance checks** — `(>= (URCv_Sublimate 0.99) 0.0)` exists to prove the call is ACCEPTED
  rather than aborting; the return value is not the subject (`ORBR-G1`, `ATS-G8`).

## Final state

**VACUOUS 0 / 2,601** — every positive assertion in the suite can now be made to fail by some input.
6 WEAK remain, all reviewed and legitimate.

**What this does NOT catch:** an assertion whose expected value is computed by the very code under
test. That is not recoverable syntactically. Mutation — break the expectation, confirm red, restore
— remains the only complete check, and is worth doing on any assertion that matters.

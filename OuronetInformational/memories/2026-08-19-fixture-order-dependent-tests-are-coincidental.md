# 2026-08-19 — Fixture-order-dependent tests are coincidental (an audit smell)

Found in `[6.4]_AQP-EXHAUSTIVE-ANK-LP.repl` `A04` during the #FP5 comprehensive green-run. A companion smell to
`2026-08-14-tautological-validation-checks.md` — but for *tests*, not validation.

## The concrete case

`A04` asserted `UR_ANK-U|Promile(EMMA, Elk0nite) > 0` "after NF03 stake". But `NF03` stakes EMMA's **arbitrary
first** KBN nonce:

```lisp
(stake-nonce (at 0 (URD_AccountNonces owner kbn-id false)))   ; whatever nonce sorts first
```

The Elk0nite anchor is a **trait-anchor** (`Eyes = "Elk0nite Unity Glasses"`) — it only grants promile to bunnies
carrying that trait. The first nonce (1009) was **not** an Elk0nite bunny, so `promile = 0` was **correct**, and
the assertion's premise ("the arbitrary stake landed an Elk0nite bunny") was simply false. The test passed or
failed depending on nonce sort order — pure coincidence, not behaviour.

The underlying code path was fine all along (a conforming stake → promile 100, proven independently).

## The general smell

**A test whose assertion depends on state left by an operation that picked its inputs arbitrarily** (first row,
first nonce, "whatever exists") is coincidental. It doesn't test behaviour; it tests that the fixture happened to
line up. It rots silently when the fixture (mint order, populate counts) shifts.

## The fix pattern — make the input deterministic + meaningful

Select the input that makes the assertion *true by construction*, using the same predicate the production code
uses. Here: filter EMMA's nonces with `ANK::URC_ConformNonces` (the exact matcher the anchor sync uses), stake a
**conforming** nonce, then assert:

```lisp
(elk-nonces (filter (lambda (n) (= 1 (ref-ANK::URC_ConformNonces kbn-id [n] trait-key trait-value)))
                    (ref-DPDC::URD_AccountNonces owner kbn-id false)))
(if (> (length elk-nonces) 0)
    (do (stake (at 0 elk-nonces)) (expect "promile>0" true (> promile 0.0)))
    (print "SKIP: EMMA owns no conforming nonce"))   ; graceful skip, never a false pass
```

Now the test genuinely proves the trait-anchor path (staking a conforming bunny → promile 100), independent of
nonce ordering, and skips honestly if the fixture can't supply the input.

## Hunt for more

Grep tests for `(at 0 ...)`, `(take 1 ...)`, "first"/"any" over `URD_AccountNonces` / `keys` / unsorted lists
feeding an assertion. Read the anchor/collectable-boot to confirm the picked item actually has the property the
assertion checks — or make the pick deterministic via the production predicate.

Ref: `[6.4]_AQP-EXHAUSTIVE-ANK-LP.repl` A04 (fixed) + A05; `Audit/README.md` Post-audit hardening.

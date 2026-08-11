# pact5/ — the Pact 5 language layer

Source-verified knowledge about **Pact 5 the language** (not the Ouronet discipline — that's
`StoicSyntax.md`). Derived from the active upstream source `kda-community/pact-5`
(`Pact/Core/Builtin.hs` = the builtin registry, `Syntax/LexUtils.hs` = the lexer, the CEK evaluator)
— because docs deprecate silently and the source is ground truth.

- **`SEMANTICS.md`** — how Pact 5 evaluates: capability mechanics (idempotent `with-capability`,
  `compose`/`require`, managed caps), defpact, database rules, the type system (strictly-closed objects,
  `int/int` truncation, module refs), evaluation/gas, and Pact-5 footguns (no recursion, read-only
  reentrancy, `let`==`let*`, **formal verification / `@model` removed**).
- **`REFERENCE.md`** — the complete, source-derived builtin + keyword catalog (the coloring/keyword set
  derives from this).

Read these when a question is about Pact itself; read `StoicSyntax.md` + `ouronet/` for how *we* write it.
Refresh from the source clone (`~/ClaudeWS/_upstream/pact-5`) when Pact updates — review before adopting.

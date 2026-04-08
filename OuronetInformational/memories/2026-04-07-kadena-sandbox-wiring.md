# 2026-04-07 — Kadena sandbox wiring + Ouronet narrative capture

## Session notes

- User described Ouronet: virtual blockchain in Pact; token types (true / orto / semi / non-fungible); ATS-pairs, SWP-pairs, AQP; stages 1–2; sovereign vs slave modules; migration from Kadena to **StoaChain** after Kadena LLC wind-down.
- **`REPL/Stage00_Sanboxes.repl`** loads **`../00_KadenaSandbox/kda-env/init.repl`** then **`../00_StoaSandbox/stoa-env/init.repl`** (in-repo). *(Earlier `Stage00.repl` pointed outside the repo; folder was briefly `00_KadenaSanbox` → `00_KadenaSandbox`.)*
- **`REPL/Z.repl`**: loads **`Stage00_Sanboxes.repl`**, then **`Stage00a_StoaTests.repl`**, then Stage01/02.
- Next planned step (user): add **StoaSandbox** with Stoa base modules; user will supply module code.

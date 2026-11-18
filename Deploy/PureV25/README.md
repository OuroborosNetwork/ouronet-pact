# Deploy/PureV25

Two transactions, five modules. **Send 01 before 02.**

A share issuance under a live stake drove a score base to **−10,000**. This round adds the gate
that refuses it, and the repair path for a base that is already wrong.

`01` is AQP-POOL alone — it must land first, because the gate TS02-C1 calls lives in it.
`02` carries the new `TalosStageTwo_ClientOneV5` interface plus its four consumers.

Read `DEPLOY.md`. No init step, no table creation, one post-deploy sequence that ends in
publishing the npm package — until that happens the UI calls an entrypoint that no longer exists.

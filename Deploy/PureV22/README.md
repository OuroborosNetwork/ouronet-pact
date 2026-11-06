# Deploy/PureV22

One transaction, one module: `AQP-VCT`.

A pool where **one owner staked to two beneficiaries could not be vacated at all** — not by the
split path, and not by `CC_FullVacate` either, which is what proves it was never the UI. The
transfer's receiver list is addressed by destination account while a vacate leg is keyed on
`(owner, beneficiary)`, so that owner appeared twice and `UEV_IzUnique` refused the batch.

All three asset lanes merge by destination before the transfer now. The uniqueness gate itself is
untouched.

Read `DEPLOY.md` — it is the whole instruction set.

# Schema-field backfill hidden inside a `UR_*` read (anti-pattern + retirement playbook)

**Origin:** DALOS audit, finding #30M (`DPTF::UR_Hibernation`), fixed 2026-08-28. See
`1_SOVEREIGN/STAGE_01/2_Core/Audit/DALOS/ROUND-02-FIXES.md` Fix #25 for the full worked example.

## The shape of the problem

A `deftable`'s `defschema` gets a new field added (e.g. `hibernation-link` added to
`DPTF|PropertiesTable` after the module had already been live with rows lacking it). Existing,
already-persisted rows on the deployed chain don't magically gain the new field — Pact stores
exactly what was written. Two legitimate needs follow: (1) reads against old rows need *some*
sensible default for the missing field, and (2) eventually you may want the physical rows
backfilled so direct-table tooling (scans, other readers) sees the field too.

## The anti-pattern found (and why it's wrong)

`UR_Hibernation` "solved" both needs at once by making the **read** itself silently perform a live
`update` the first time it saw a row missing the field:

```pact
;; WRONG — a UR_* that writes
(defun UR_Hibernation:string (id:string)
    (let ((default-value:string BAR) (temp (read T id ["f"])) (needs-populate (= temp {})))
        (if needs-populate (update T id {"f": default-value}) true)   ;; <- the violation
        (if needs-populate default-value (at "f" temp))
    )
)
```

This violates the `UR_*` prefix contract (see `ur-and-w-writes.md`: `UR_*` is `read`/
`with-default-read` only, never a table write) for two concrete reasons, not just style:
- **It's surprising.** Every caller (and every future maintainer) treats `UR_*` as side-effect-free
  by convention. A "read" that mutates state on first touch is a trap.
- **It can break under read-only execution.** Any client path that queries chain state without
  submitting a real signed transaction (a Chainweb `/local` dirty-read, exactly like the Pythia
  relay documented in `../memories/2026-08-28-querying-live-stoachain-via-pythia-dirty-read.md`)
  may reject writes. A UI or off-chain tool "just checking token info" could get a write-rejected
  error from what should be a harmless lookup.

## The correct pattern, if you actually need this

**For the read itself:** compute the default **in memory only** — exactly like `with-default-read`
does for a missing *row*, but for a missing *field* within an existing row:

```pact
(defun UR_Hibernation:string (id:string)
    (let ((default-value:string BAR) (temp (read T id ["f"])) (needs-populate (= temp {})))
        (if needs-populate default-value (at "f" temp))
    )
)
```

No write, ever. Same return value in every case that matters.

**If you also want the physical rows backfilled** (e.g. because some other tool reads the table
directly and needs the field literally present): write a genuine, separate, one-time **admin
migration function** — `A_*` prefixed, real admin-keyset gated, safe to run more than once
(idempotent — skip rows that already have the field), that scans `(keys T)` and backfills only the
rows still missing it. Run it once, by an operator, after deploying the schema change. Never hide
this inside a function anything else calls incidentally.

## Retiring an existing instance of the anti-pattern (the playbook actually used for #30M)

1. **Sample the live/deployed chain** to check whether the write branch is still load-bearing —
   don't guess from the code alone. Use the Pythia dirty-read method
   (`../memories/2026-08-28-querying-live-stoachain-via-pythia-dirty-read.md`) to enumerate every
   row key and check whether the field is present, e.g.:
   ```pact
   (namespace "ouronet-ns")
   (let ((ids (keys DPTF.DPTF|PropertiesTable)))
     (map (lambda (id) {"id": id, "has-field": (!= (read DPTF.DPTF|PropertiesTable id ["hibernation-link"]) {})}) ids))
   ```
2. **If zero gaps found** (as was the case for all 18 live DPTF tokens checked 2026-08-28): the
   write is fully dead code. Strip it, keep the in-memory default-value fallback as-is — a pure,
   behavior-preserving simplification. Verify via REPL that the return value is unchanged for a
   normal row before/after.
3. **If real gaps are found:** don't strip the write yet. Either run an existing migration function
   first, or write one (per "the correct pattern" above), execute it against live chain, re-sample
   to confirm zero gaps, *then* strip the read's write.

## Known outstanding work (as of this audit)

Round I of the DALOS audit was not specifically searching for *this exact shape* (a `UR_*` read
quietly writing to backfill a newer schema field) across the whole Stage 1 + Stage 2 surface — it
was only caught once, incidentally, for `UR_Hibernation`. **There may be other instances of this
same pattern elsewhere in the codebase that haven't been found yet.** A dedicated sweep for this
specific shape (grep for `UR_*`/`UR|*`-prefixed functions containing `update`/`write`/`insert`) is
recommended as part of the eventual main-branch work, using the retirement playbook above for each
instance found. See `1_SOVEREIGN/STAGE_01/2_Core/Audit/DALOS/README.md`'s Downstream plan for the
tracking entry this is filed under (owner instruction, 2026-08-28: any such finding, present or
future, in that audit's list should be deferred to this sweep rather than fixed piecemeal, citing
this document).

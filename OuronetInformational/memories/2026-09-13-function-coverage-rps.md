# Function coverage (P3.7 / gate G6) — Tier 1 opened on RPS, 2026-09-13

**`04_RPS.pact`: 79 never-reached -> 47.** Overall never-reached 1,247 -> 1,215. RPS was chosen first
because it is the largest single gap in the codebase AND it is reward + billing math, so an untested
function there pays or charges a wrong number silently.

## The pattern that made this cheap: ground-truth against a payout that is already known

`Kursan/AQP-stream-tests.repl` already computes an exact, independently-derived answer — ANHD 180 and
EMMA 60 from a 240/24h stream with a mid-window joiner. `RPS::URC_LiveClaimable` is the UI's
*projection* of the same number. So the test is one line of state capture: read the projection
immediately BEFORE the collect, compare to what the collect actually pays.

That one assertion covered `URC_LiveClaimable`, `URC_ReleasableToNow`, `URC_ProjectedIndexAdvance`
and `URC_StreamStatus` at once, with a real ground truth rather than a self-consistency check.
**Both predictions were exact.**

The @doc even supplied the edge: *"for the last-claimant dust-sweep edge the real collect pays the
whole available-rewards, so this slightly UNDER-estimates there (a UI hint, not a promise)."* So the
last claimant is asserted as a ONE-SIDED inequality — the projection may lag, but must never
over-promise — plus a floor so the inequality cannot pass at zero. A UI that lies upward about money
is the failure worth catching; a UI that lags by dust is not.

## I wrote a vacuous test and caught it the same way I caught the suite's

The per-field identity readers (`UR_FVT-RU|UserId`, `|FvtId`, `|ScoreEntityId`, `|DptfId`, and the
RM/RG/SEL families) read back the very key components they were looked up by. That looks like a
perfect round-trip invariant, and it catches a writer that transposes two columns.

**It is vacuous on its own.** `UR_FVT-RU|RpsUser` is a `with-default-read` whose DEFAULT OBJECT IS
CONSTRUCTED FROM THE KEY:

    (with-default-read FVT|T|RPS|User (UCk_RpsUser user-id fvt-id score-entity-id dptf-id)
        (UDC_FVT|RPS|User 0.0 0.0 user-id fvt-id score-entity-id dptf-id)  ; <- the key, echoed
        ...)

So on a MISSING row every identity reader returns its own argument, and the whole round-trip sweep
would pass **against an empty table**. Found by writing a negative control that expected
`"row not found"` and watching it return the user id instead.

Two things came out of it, both kept:

1. **The premise is now asserted first** — `UR_FVT-RU|LastRps > 0.0` proves the row is real (only the
   NUMERIC fields default honestly, to 0.0), and only then does the round-trip mean anything.
2. **The echo is pinned as a TRAP.** A caller cannot use an identity reader to ask "does this row
   exist" — handed a token that was never in the lane, it answers with that token, confidently and
   wrongly. `UR_FVT-UP|IsPresent` is the existence check, and it is asserted in both arms.

**Generalised, and this is now twice in two phases: a reader family built on `with-default-read`
cannot be tested by round-tripping its own arguments. Establish existence out-of-band first.**

## A wrong hypothesis, corrected in place rather than deleted

I asserted that `URCi_TrueFungibleStakeFlow` would price `direction=true` and `false` DIFFERENTLY —
"a preview that ignored the flag would return the same number twice". It returned the same number.

The flag is not dropped. It is read in exactly one place, to swap sender and receiver, and that pair
feeds `TFT::URC_TransferClasses` -> xfer-type -> the custody-transfer leg. All nine legs are otherwise
direction-independent. So the price differs by direction **only when the transfer CLASSIFICATION is
asymmetric between the two accounts**, and for OURO between a plain account and the AQP vault it is
symmetric — equal prices are the CORRECT answer.

The assertion now pins the equality AND the classification that explains it, because the equality
alone would not distinguish "correct" from "flag dropped". The wrong first draft is left in the
comment: it is the kind of plausible-but-wrong reading the next person will also have.

## Both arms, always, on a price reader

Every `URC_*Ignis` mirror carries a zero-guard ("0 when amount<=0", "0 when ffc<=0"). A guard tested
only on its zero side passes on a function that always returns zero — which for a **price** reader is
the failure that would go unnoticed longest, since nothing errors and the user is simply not charged.
Both arms asserted for each, plus a flatness check (`URC_CollectXferIgnis` mirrors ONE transfer, so
it must NOT scale with the amount — the shape a reviewer would most likely get wrong).

## Pairs must be asserted against each other

`URC_FvtUserHasStaleMember` / `URC_FvtUserStaleMemberCount` are a boolean/count pair over one scan,
and `URC_FvtHasAnyMemberLink` / `UR_FVT|MemberLinkCount` likewise. Each is individually plausible and
nothing forces them to agree. The invariant `has == (count > 0)` is the test, swept over every vault
in the suite and two users — with a non-vacuity check that at least one vault really does have a link,
so the agreement is not "false == false" three times over.


---

# Tier 1 continued — VCT + AQP, 2026-09-13

**Running total: never-reached 1,247 -> 1,205.** RPS 79->47, VCT 28->24, AQP 45->39.

## A third instance of the `(enumerate 0 -1)` trap — and this one was fixed

`06_VCT.pact` had TWO functions doing the identical job (floor a decimal row to integers), and they
disagreed on exactly one input:

    UC_DecimalAmountsRowToInt         []  ->  []          ; plain (map (lambda (a) (floor a)) amounts)
    UC_VacateDecimalAmountsToIntegers []  ->  FAULT       ; (map … (enumerate 0 (- (length amounts) 1)))

`(enumerate 0 -1)` is the DESCENDING PAIR `[0, -1]`, not the empty list, so the second ran `(at 0 [])`
and died on "Array index out of bounds. Length (0), Index (0)". Verified identical on every non-empty
input first (`[1.9 2.1 -0.5]` -> `[1, 2, -1]` from both).

**NOT a live bug, and that determined the disposition.** `UC_MergeVacateNonceRowIntoLegs` always
constructs a leg with at least one element (`[nonce]` / `[amount]`) and only ever APPENDS, so an empty
amounts row is unreachable from the real vacate path. So this was a footgun armed for whoever next
changed the leg builder, not a defect in flight.

**Fixed anyway, as a DELEGATION rather than a rewrite** — `UC_VacateDecimalAmountsToIntegers` now
calls `UC_DecimalAmountsRowToInt`. Zero behavioural risk (proven identical on all reachable inputs),
and it collapses a duplicate implementation so the two can never drift again.

**This is the THIRD `(enumerate 0 (- (length x) 1))` site found this engagement** (after
`DPDC-C::XIv_MappedCreditOrDebitDPDC` and the `UC_LpID` family). The idiom is endemic and always
wrong on the empty list. Worth a codebase sweep as its own task: grep
`enumerate 0 (- (length` and check each for an empty-input path.

## Edges that are worth pinning even when nothing is broken

* **`floor` rounds negatives AWAY from zero** (`-0.5 -> -1`), it does not truncate. "Whole units"
  reads as truncation, so a tracker balance that ever went slightly negative would convert to a MORE
  negative integer, not to 0.
* **`fold (and) true` over an EMPTY list is TRUE.** `URC_NonceAmountsAreZeroSentinel []` answers
  `true` — "every amount is zero" holds vacuously when there are no amounts. Not wrong, but a caller
  can misread it as "this is an OF vacate" when there is simply nothing to vacate. Pinned explicitly.

## The cheapest strong test in the module: two scans that must agree

`URH_AQP|{Dptf,Dpof,Dpsf,Dpnf}StakesBy{Owner,Beneficiary}` — eight functions, four symmetric pairs,
none ever called. They are what a wallet uses to show "your stakes", so a scan that drops a leg makes
a position invisible to its owner.

**Two independently-written scans walking the same rows from opposite ends is a far stronger check
than either asserted against a hand-written expectation** — and it needed no new fixture, because the
suite already holds a SELF-stake (owner = beneficiary), the case where both must return the very same
leg. The cross-reference is the sharp part: the owner-side row must name the BENEFICIARY and vice
versa, so a scan projecting the wrong column fails there while passing every count/balance check.

Non-vacuity mattered: three of the four families are empty for this account, so "[] equals []" would
have passed on a scan that returned nothing at all. Asserted that the TF and DPSF pairs carry real
rows before trusting the sweep.

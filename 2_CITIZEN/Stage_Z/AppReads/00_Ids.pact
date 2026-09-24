;; ===========================================================================================
;; OURONET ENTITY-ID REGISTRY -- the root of AppReads, because every app reads from it.
;; ===========================================================================================
;; LIVES HERE, not in 1_SOVEREIGN/0_Interfaces, and the placement is the argument. Nothing
;; sovereign needs these: a core module derives an id from its own tables. It is the READ layer
;; that cannot -- a projection has no state to derive from and must be told. So the registry
;; belongs to its consumers, at the root of the folder that holds them, and it deploys before
;; any of them.
;; One authoritative place for the mainnet ids that cannot be computed.
;;
;; WHY A REGISTRY OF LITERALS IS THE RIGHT ANSWER HERE, having spent a day arguing the opposite:
;; an entity id's suffix is the block hash of the transaction that minted it. That is a FACT
;; ABOUT MAINNET. No sandbox can produce it, no function can derive it from nothing, and a
;; module that hardcodes it is not being lazy -- it is recording something real.
;;
;; What was actually wrong was never the literals. It was that there were FORTY-PLUS COPIES of
;; them, scattered across the Pact tree and the UI repo, with nothing authoritative. Twelve in
;; one function, two in another, thirty in TypeScript, and no answer to "which one is right?"
;; other than reading all of them. One registry, one place to correct, one import.
;;
;; WHY AN INTERFACE AND NOT A MODULE. A module could COMPUTE these at load --
;; `(defconst ID_OURO (DALOS.UR_OuroborosID))` -- and be self-correcting. Two reasons not to:
;; the value freezes at deploy time anyway, so it is no fresher than a literal; and the module
;; then cannot be deployed at all against a chain where one of those tokens is missing, which
;; is precisely the sandbox case. An interface's defconst must be literal, which is what is
;; wanted.
;;
;; WHY THE ATS PAIR IDS ARE HERE AND THE TOKEN IDS ARE ALSO HERE, despite the token ids being
;; derivable: consistency of SOURCE beats cleverness. A reader that derives OURO from DALOS and
;; takes Auryndex from here has two rules to remember and one of them is invisible. Derive
;; nothing, import everything, and the question "where did this id come from?" has one answer.
;;
;; ------------------------------------------------------------------------------------------
;; UNVERIFIED AS OF 2026-09-24 -- READ THIS BEFORE TRUSTING A VALUE
;; ------------------------------------------------------------------------------------------
;; Every literal below was copied from source that predates the Stage-1/2 redeploy. They are
;; believed correct: the round deployed in UPGRADE mode (zero create-table across all 24 files),
;; so tables persisted and no id should have moved. BELIEVED is not CONFIRMED.
;;
;; Confirm each against chain with a dirty read before this interface is depended on:
;;     (ouronet-ns.DALOS.UR_OuroborosID)  (ouronet-ns.DALOS.UR_IgnisID)  ...
;;     (ouronet-ns.DPTF.UR_RewardBearingToken (ouronet-ns.DALOS.UR_AurynID))
;;
;; A registry exists so nobody has to double-check it again. It earns that only by being right
;; the first time; a registry that launders a guess is worse than the forty copies, because the
;; forty copies at least looked suspicious.
;; ===========================================================================================

(interface OuronetIdsV1
    @doc "Mainnet entity ids that cannot be computed: primordial tokens and the four primordial \
        \ ATS pairs. Literals on purpose -- see the header. Import these; never retype them."

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants

    ;;  PRIMORDIAL TOKENS -- the DPTF ids. Each is also readable from DALOS
    ;;  (UR_OuroborosID, UR_IgnisID, ...); they are duplicated here so that a
    ;;  consumer has ONE import rather than two sources of truth.
    (defconst ID_OURO           "OURO-8Nh-JO8JO4F5")
    (defconst ID_IGNIS          "GAS-8Nh-JO8JO4F5")
    (defconst ID_AURYN          "AURYN-8Nh-JO8JO4F5")
    (defconst ID_ELITEAURYN     "ELITEAURYN-8Nh-JO8JO4F5")
    (defconst ID_WSTOA          "WSTOA-8Nh-JO8JO4F5")
    (defconst ID_SSTOA          "SSTOA-8Nh-JO8JO4F5")
    (defconst ID_GSTOA          "GSTOA-8Nh-JO8JO4F5")

    ;;  HIBERNATED GOLDENSTOA -- a DPOF id, not a DPTF one. Derivable as
    ;;  (DPTF::UR_Hibernation ID_GSTOA); listed because the header reads it directly.
    (defconst ID_HGSTOA         "H|GSTOA-8Nh-JO8JO4F5")

    ;;  PRIMORDIAL ATS PAIRS. These are the ids whose derivation was in question on
    ;;  2026-09-24: DPTF::UR_RewardBearingToken reads a reverse index, and an unset
    ;;  index returns ["|"] rather than [] -- it does not abort, it leaks a BAR into
    ;;  the next call. The literals were known-good on mainnet for months. Use them.
    (defconst IDX_AURYNDEX      "Auryndex-O136CBn22ncY")
    (defconst IDX_EAURYNDEX     "EliteAuryndex-O136CBn22ncY")
    (defconst IDX_SILVERPILLAR  "SilverStoaPillar-O136CBn22ncY")
    (defconst IDX_GOLDENPILLAR  "GoldenStoaPillar-O136CBn22ncY")

    ;;  NO GROUPED CONSTANTS, and the reason is a Pact constraint worth knowing rather than
    ;;  rediscovering. This interface first carried
    ;;      (defconst IDS_PRIMORDIAL [ID_OURO ID_IGNIS ...])
    ;;  and loading it died with:
    ;;      "Fatal execution error, invariant violated: Defconst was not evaluated prior to
    ;;       execution: ouronet-ns.OuronetIdsV1.ID_OURO"
    ;;  An interface's defconsts are not ordered relative to one another, so one cannot
    ;;  reference a sibling. The options were to duplicate the seven literals inside the list --
    ;;  reintroducing the exact duplication this file exists to end -- or to leave the grouping
    ;;  to consumers. Consumers group. A registry with two spellings of the same id is not a
    ;;  registry.
)

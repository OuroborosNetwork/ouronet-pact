;; ============================================================================
;;  CANONICAL MODULE SKELETON  —  StoicSyntax (settled 2026-09-02)
;; ----------------------------------------------------------------------------
;;  This file is the empty-block start-point for any NEW module. Every block and
;;  sub-block carries its marker EVEN WHEN EMPTY (an empty block = a marker with
;;  no body) — that is what makes a module scannable + diffable.
;;
;;  Block order per logical module UNIT (a multi-unit file, e.g. `coin` = 3
;;  units, repeats this whole skeleton once per unit; each unit has its OWN
;;  module @doc):
;;      (module) @doc → {0} IMPLEMENTERS → {#} GASSTATION(opt) → {1} GOVERNANCE
;;      → {2} POLICY → {3} CST → {4} CAPABILITIES → {5} FUNCTIONS → {6} REPL(opt)
;;
;;  Marker tiers:
;;    • BLOCK      — a `;;<===…===>` rule + a `;;{N}  NAME` line (N ∈ 0 # 1..6)
;;    • SUB-BLOCK  — `;;{tag}  label`  (G1..G5 · P1..P5 · 3.1..3.3 · C1..C4 · 5.1..5.7)
;;    • SUB-SUB    — `;;  · label`     (ordered variants inside a function class / G5 designators)
;;
;;  Colour-bearing markers (highlighter keys off these): {C4} gold caps · {G4}
;;  gold gov caps · {G1} grey-bold gov constants · the GASSTATION block (gold
;;  caps) · grey structural `GOV|` / `P|` prefix filters. Everything else is
;;  organizational. Composition wins: a trivial-`true` / compose-only-bronze cap
;;  stays BRONZE even under a {C4} marker.
;;
;;  INTERFACES ARE CO-LOCATED (the 0_Interfaces/ pool is retired). Any interface
;;  whose FIRST deploy-order implementer is this module lives HERE, ABOVE the
;;  module, base-most first, each with the dual-version comment. Kadena interfaces
;;  are immutable → the version stays in the name; the name = the `dev:` version.
;;  Each interface declares constants/schemas/cap-signatures/function-signatures
;;  (all functions EXCEPT XI_/W*_) in module order — no deftable, no bodies:
;;
;;   ;; net: v5        ;; live on mainnet (lags; bump only on deploy).  Pre-first-deploy: net: — (undeployed)
;;   ;; dev: v5        ;; in this repo (name = this; the moment you modify → dev:v6, rename NAMEV5→NAMEV6, cascade consumers)
;;   (interface NAMEV5
;;       @doc "…"
;;       ;; … mirror of the module's order for declarable members …
;;   )
;; ============================================================================
(module NAME GOV
    @doc "…"                                      ;; OPTIONAL module @doc — the module's metadata, ONE per logical
                                                  ;; module unit, in the module header before block {0}; carries no block marker.

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;<=========================================================================>
    ;; (implements …)                              ;; ONLY (implements <interface>) statements live here.

    ;;<=========================================================================>
    ;;{#}  GASSTATION                              ;; OPTIONAL · UNNUMBERED · rare (DALOS only).
    ;;<=========================================================================>
    ;; Named gas-station surface implementing the gas-payer interface (>= its minimum).
    ;; ⟨COLOUR⟩ EVERY capability in this block is GOLD (authority surface).
    ;; OMIT this whole block unless the module actually has a gas station.

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;<=========================================================================>
    ;; All members here carry the GOV| prefix. Caps here are GOLD unless bronze by
    ;; composition; order caps class-1-first … class-4-last (no {Cx} markers in-block).
    ;;{G1}  constants                              ;; ⟨COLOUR⟩ grey + BOLD
    ;;{G2}  schemas
    ;;{G3}  tables                                 ;; key-shape comment: <comp>|<comp>|…
    ;;{G4}  capabilities                           ;; ⟨COLOUR⟩ GOLD (unless bronze by composition)
    ;;{G5}  functions                              ;; all GOV| ; OPTIONAL, per-need custom sub-sub designators —
    ;;                                             ;; ARBITRARY camelCase names, present only if the module needs them.
    ;;  · <CustomDesignator>                       ;; e.g. DALOS uses Keys / SmartContractNames / PublicKey — those are
    ;;                                             ;; just DALOS's example, NOT a mandatory set; omit this line if unneeded.

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;<=========================================================================>
    ;; Governed by the shared policy interface (every module implements it).
    ;; All functions carry a LEADING P| (P|UR_IMP · P|A_AddIMP · P|UEV_IMC …).
    ;; ⟨COLOUR⟩ the leading P| renders grey (structural); colour the remainder by its real prefix.
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables                                 ;; key-shape comment: <comp>|<comp>|…
    ;;{P4}  capabilities
    ;;{P5}  functions                              ;; all P|<prefix>_Name

    ;;<=========================================================================>
    ;;{3}  CST  —  Constants / Schemas / Tables
    ;;<=========================================================================>
    ;;{3.1}  constants                             ;; every defconst
    ;;{3.2}  schemas                               ;; every defschema
    ;;{3.3}  tables                                ;; every deftable + key-shape comment: <comp>|<comp>|…

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;<=========================================================================>
    ;;{C1}  Trivial   — `true` (metadata ignored) OR composes only bronze/C1 caps, no other logic   ⟨BRONZE⟩
    ;;{C2}  Simple    — own logic, composes no caps                                                  (silver)
    ;;{C3}  Composed  — composes >=1 non-bronze cap (may compose a C4 and still be C3)               (silver)
    ;;{C4}  Ownership — body is ONLY ownership/authority validation, non-composing                   ⟨GOLD⟩

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;<=========================================================================>
    ;; 7 classes in BUILD order (Construct leads); strongest → lightest within each.
    ;;{5.1}  Construct [UDC]                        ;; UDC_
    ;;  · UDCx_ (aux)
    ;;{5.2}  Compute   [UC]                         ;; UC_
    ;;  · UCk_ (key-building)
    ;;  · UCx_ / UCkx_ (aux)
    ;;{5.3}  Read      [UR]                         ;; UR_
    ;;  · URC_ (composed) · URU_
    ;;  · URCx_ (aux)
    ;;  · URH_ / URHC_ (heavy — loud)
    ;;  · URCi_ (cost) · INFO_ (client-info reader)
    ;;{5.4}  Validate  [UEV]                        ;; UEV_
    ;;  · CAP_ (capability-guard FUNCTION — not a {C4} cap)
    ;;                                             ;; NB the IMC spine enforce is a POLICY function → P|UEV_IMC in {P5}, NOT here.
    ;;{5.5}  Write     [W]                          ;; WI_ (insert)
    ;;  · WU_ / WU2_ / WU3_ / WU4_ … (update)
    ;;  · WW_ (overwrite)
    ;;{5.6}  Aux/X     [X]                          ;; XI_ (internal)
    ;;  · XE_ (external — client entry via Talos)
    ;;  · XB_ (both)
    ;;{5.7}  User      [A / C]                      ;; A_ (admin)
    ;;  · AA_ / Ap_ / AAp_ / AU_
    ;;  · C_ (client)
    ;;  · CC_ / Cp_ / CCp_

    ;; {6} REPL — test-only functions (REPL_*). NOT part of this template: added ONLY in
    ;; modules that need it, and DELETED at deploy. Its separator is DELIBERATELY DISTINCT
    ;; from every other block (an X-rule, not the `=` rule) so it is trivially greppable and
    ;; wipeable on deploy. Exact shape WHEN PRESENT (last block, just before the module close):
    ;;
    ;;   ;;<XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX>
    ;;   ;;{6}  REPL   —   TEST-ONLY · DELETE ON DEPLOY
    ;;   ;;<XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX>
    ;;   (defun REPL_… )
)

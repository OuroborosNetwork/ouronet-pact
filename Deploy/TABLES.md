# Tables, per module

**Mode: `upgrade`.** 181 tables are defined across the modules in this plan.

`(create-table X)` **fails if X already exists**, and which tables exist is a property of the chain that this repository cannot determine (see the note at the top of `REPL/tools/_deploybundle.py`). So ask the chain.

## Probe: paste this as ONE read-only transaction

It returns a row per table that exists and errors on the first that does not, so run it in chunks, or wrap each in `(try "MISSING" (describe-table ...))` if your pipeline allows.

```pact
;; 1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING DPTF|PropertiesTable" (let ((x (describe-table DPTF|PropertiesTable))) "DPTF|PropertiesTable"))
(try "MISSING DPTF|BalanceTable" (let ((x (describe-table DPTF|BalanceTable))) "DPTF|BalanceTable"))
(try "MISSING DPTF|RoleTable" (let ((x (describe-table DPTF|RoleTable))) "DPTF|RoleTable"))
;; 1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING DPOF|T|Properties" (let ((x (describe-table DPOF|T|Properties))) "DPOF|T|Properties"))
(try "MISSING DPOF|T|Nonces" (let ((x (describe-table DPOF|T|Nonces))) "DPOF|T|Nonces"))
(try "MISSING DPOF|T|VerumRoles" (let ((x (describe-table DPOF|T|VerumRoles))) "DPOF|T|VerumRoles"))
(try "MISSING DPOF|T|AccountRoles" (let ((x (describe-table DPOF|T|AccountRoles))) "DPOF|T|AccountRoles"))
;; 1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING ATS|Pairs" (let ((x (describe-table ATS|Pairs))) "ATS|Pairs"))
(try "MISSING ATS|Ledger" (let ((x (describe-table ATS|Ledger))) "ATS|Ledger"))
;; 1_SOVEREIGN/STAGE_01/2_Core/09_TFT.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/2_Core/12_LIQUID.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING SWP|Properties" (let ((x (describe-table SWP|Properties))) "SWP|Properties"))
(try "MISSING SWP|Asymmetry" (let ((x (describe-table SWP|Asymmetry))) "SWP|Asymmetry"))
(try "MISSING SWP|Pairs" (let ((x (describe-table SWP|Pairs))) "SWP|Pairs"))
(try "MISSING SWP|Pools" (let ((x (describe-table SWP|Pools))) "SWP|Pools"))
(try "MISSING SWP|LP" (let ((x (describe-table SWP|LP))) "SWP|LP"))
;; 1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/2_Core/17_SWPL.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/2_Core/21_CODEX.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING CODEX|T|Identities" (let ((x (describe-table CODEX|T|Identities))) "CODEX|T|Identities"))
(try "MISSING CODEX|T|ArweaveTracker" (let ((x (describe-table CODEX|T|ArweaveTracker))) "CODEX|T|ArweaveTracker"))
(try "MISSING CODEX|T|StoicTags" (let ((x (describe-table CODEX|T|StoicTags))) "CODEX|T|StoicTags"))
(try "MISSING CODEX|T|StoicTagsByAccount" (let ((x (describe-table CODEX|T|StoicTagsByAccount))) "CODEX|T|StoicTagsByAccount"))
;; 1_SOVEREIGN/STAGE_01/2_Core/22_PYTHIA.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING PYTHIA|T|ApiKeys" (let ((x (describe-table PYTHIA|T|ApiKeys))) "PYTHIA|T|ApiKeys"))
(try "MISSING PYTHIA|T|Config" (let ((x (describe-table PYTHIA|T|Config))) "PYTHIA|T|Config"))
(try "MISSING PYTHIA|T|DualLinks" (let ((x (describe-table PYTHIA|T|DualLinks))) "PYTHIA|T|DualLinks"))
(try "MISSING PYTHIA|T|Revocation" (let ((x (describe-table PYTHIA|T|Revocation))) "PYTHIA|T|Revocation"))
(try "MISSING PYTHIA|T|PythDaily" (let ((x (describe-table PYTHIA|T|PythDaily))) "PYTHIA|T|PythDaily"))
(try "MISSING PYTHIA|T|PythTotal" (let ((x (describe-table PYTHIA|T|PythTotal))) "PYTHIA|T|PythTotal"))
;; 1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/3_Talos/03_TS01-C2.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/3_Talos/04_TS01-C3.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_01/3_Talos/06_TS01-C4.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/02_DPDC.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING DPSF|T|Properties" (let ((x (describe-table DPSF|T|Properties))) "DPSF|T|Properties"))
(try "MISSING DPSF|T|Nonces" (let ((x (describe-table DPSF|T|Nonces))) "DPSF|T|Nonces"))
(try "MISSING DPSF|T|VerumRoles" (let ((x (describe-table DPSF|T|VerumRoles))) "DPSF|T|VerumRoles"))
(try "MISSING DPSF|T|Account" (let ((x (describe-table DPSF|T|Account))) "DPSF|T|Account"))
(try "MISSING DPSF|T|AccountSupplies" (let ((x (describe-table DPSF|T|AccountSupplies))) "DPSF|T|AccountSupplies"))
(try "MISSING DPNF|T|Properties" (let ((x (describe-table DPNF|T|Properties))) "DPNF|T|Properties"))
(try "MISSING DPNF|T|Nonces" (let ((x (describe-table DPNF|T|Nonces))) "DPNF|T|Nonces"))
(try "MISSING DPNF|T|VerumRoles" (let ((x (describe-table DPNF|T|VerumRoles))) "DPNF|T|VerumRoles"))
(try "MISSING DPNF|T|Account" (let ((x (describe-table DPNF|T|Account))) "DPNF|T|Account"))
(try "MISSING DPNF|T|AccountSupplies" (let ((x (describe-table DPNF|T|AccountSupplies))) "DPNF|T|AccountSupplies"))
;; 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/03_DPDC-C.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/04_DPDC-I.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/05_DPDC-R.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/06_DPDC-MNG.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/07_DPDC-T.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/08_DPDC-S.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING DPSF|SetsTable" (let ((x (describe-table DPSF|SetsTable))) "DPSF|SetsTable"))
(try "MISSING DPNF|SetsTable" (let ((x (describe-table DPNF|SetsTable))) "DPNF|SetsTable"))
;; 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/09_DPDC-F.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/10_DPDC-N.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/11_EQUITY+.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING DEMIPAD|T|Ledger" (let ((x (describe-table DEMIPAD|T|Ledger))) "DEMIPAD|T|Ledger"))
(try "MISSING DEMIPAD|T|Properties" (let ((x (describe-table DEMIPAD|T|Properties))) "DEMIPAD|T|Properties"))
;; 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING ANK|T|Anchor" (let ((x (describe-table ANK|T|Anchor))) "ANK|T|Anchor"))
(try "MISSING ANK|T|BoostClass" (let ((x (describe-table ANK|T|BoostClass))) "ANK|T|BoostClass"))
(try "MISSING ANK|T|AssetAnchors" (let ((x (describe-table ANK|T|AssetAnchors))) "ANK|T|AssetAnchors"))
(try "MISSING ANK|T|BoostClassScoreLinks" (let ((x (describe-table ANK|T|BoostClassScoreLinks))) "ANK|T|BoostClassScoreLinks"))
(try "MISSING ANK|T|Anchors" (let ((x (describe-table ANK|T|Anchors))) "ANK|T|Anchors"))
(try "MISSING ANK|T|UserBoost" (let ((x (describe-table ANK|T|UserBoost))) "ANK|T|UserBoost"))
;; 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/02_SCORE.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING SCR|T|Score" (let ((x (describe-table SCR|T|Score))) "SCR|T|Score"))
(try "MISSING SCR|T|UserScore" (let ((x (describe-table SCR|T|UserScore))) "SCR|T|UserScore"))
(try "MISSING SCR|T|SF|Score" (let ((x (describe-table SCR|T|SF|Score))) "SCR|T|SF|Score"))
(try "MISSING SCR|T|NF|TraitScore" (let ((x (describe-table SCR|T|NF|TraitScore))) "SCR|T|NF|TraitScore"))
(try "MISSING SCR|T|NF|ClassScore" (let ((x (describe-table SCR|T|NF|ClassScore))) "SCR|T|NF|ClassScore"))
(try "MISSING SCR|T|SF|DefRevision" (let ((x (describe-table SCR|T|SF|DefRevision))) "SCR|T|SF|DefRevision"))
(try "MISSING SCR|T|NF|DefRevision" (let ((x (describe-table SCR|T|NF|DefRevision))) "SCR|T|NF|DefRevision"))
(try "MISSING SCR|T|NF|TraitKeys" (let ((x (describe-table SCR|T|NF|TraitKeys))) "SCR|T|NF|TraitKeys"))
(try "MISSING SCR|T|Triplet" (let ((x (describe-table SCR|T|Triplet))) "SCR|T|Triplet"))
(try "MISSING SCR|T|ScoreEntityModel" (let ((x (describe-table SCR|T|ScoreEntityModel))) "SCR|T|ScoreEntityModel"))
;; 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/03_AQP.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING AQP|T|Pool" (let ((x (describe-table AQP|T|Pool))) "AQP|T|Pool"))
(try "MISSING AQP|T|DPTFTracker" (let ((x (describe-table AQP|T|DPTFTracker))) "AQP|T|DPTFTracker"))
(try "MISSING AQP|T|DPOFTracker" (let ((x (describe-table AQP|T|DPOFTracker))) "AQP|T|DPOFTracker"))
(try "MISSING AQP|T|DPSFTracker" (let ((x (describe-table AQP|T|DPSFTracker))) "AQP|T|DPSFTracker"))
(try "MISSING AQP|T|DPNFTracker" (let ((x (describe-table AQP|T|DPNFTracker))) "AQP|T|DPNFTracker"))
(try "MISSING AQP|T|BenDptfTotal" (let ((x (describe-table AQP|T|BenDptfTotal))) "AQP|T|BenDptfTotal"))
(try "MISSING AQP|T|BenDpsfNonceTotal" (let ((x (describe-table AQP|T|BenDpsfNonceTotal))) "AQP|T|BenDpsfNonceTotal"))
(try "MISSING AQP|T|BenDpnfNonceTotal" (let ((x (describe-table AQP|T|BenDpnfNonceTotal))) "AQP|T|BenDpnfNonceTotal"))
(try "MISSING AQP|T|BenDpsfAnkMeta" (let ((x (describe-table AQP|T|BenDpsfAnkMeta))) "AQP|T|BenDpsfAnkMeta"))
(try "MISSING AQP|T|BenDpnfAnkMeta" (let ((x (describe-table AQP|T|BenDpnfAnkMeta))) "AQP|T|BenDpnfAnkMeta"))
(try "MISSING AQP|T|UserOccupancy" (let ((x (describe-table AQP|T|UserOccupancy))) "AQP|T|UserOccupancy"))
;; 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_RPS.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING FVT|T|RPS|Global" (let ((x (describe-table FVT|T|RPS|Global))) "FVT|T|RPS|Global"))
(try "MISSING FVT|T|RPS|Member" (let ((x (describe-table FVT|T|RPS|Member))) "FVT|T|RPS|Member"))
(try "MISSING FVT|T|RPS|User" (let ((x (describe-table FVT|T|RPS|User))) "FVT|T|RPS|User"))
(try "MISSING FVT|T|RPS|Stream" (let ((x (describe-table FVT|T|RPS|Stream))) "FVT|T|RPS|Stream"))
(try "MISSING FVT|T|MemberUserWeight" (let ((x (describe-table FVT|T|MemberUserWeight))) "FVT|T|MemberUserWeight"))
(try "MISSING FVT|T|MemberVault" (let ((x (describe-table FVT|T|MemberVault))) "FVT|T|MemberVault"))
(try "MISSING FVT|T|ForcedFixCount" (let ((x (describe-table FVT|T|ForcedFixCount))) "FVT|T|ForcedFixCount"))
(try "MISSING FVT|T|RewardAggregate" (let ((x (describe-table FVT|T|RewardAggregate))) "FVT|T|RewardAggregate"))
(try "MISSING FVT|T|ScoreEntityLink" (let ((x (describe-table FVT|T|ScoreEntityLink))) "FVT|T|ScoreEntityLink"))
(try "MISSING FVT|T|MultipletFamily" (let ((x (describe-table FVT|T|MultipletFamily))) "FVT|T|MultipletFamily"))
(try "MISSING FVT|T|UserPresence" (let ((x (describe-table FVT|T|UserPresence))) "FVT|T|UserPresence"))
(try "MISSING FVT|T|AgencyFee" (let ((x (describe-table FVT|T|AgencyFee))) "FVT|T|AgencyFee"))
(try "MISSING FVT|T|QualitySplit" (let ((x (describe-table FVT|T|QualitySplit))) "FVT|T|QualitySplit"))
(try "MISSING FVT|T|DsaOracleConfig" (let ((x (describe-table FVT|T|DsaOracleConfig))) "FVT|T|DsaOracleConfig"))
;; 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_FVT.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING FVT|T" (let ((x (describe-table FVT|T))) "FVT|T"))
(try "MISSING FVT|T|VacateFreeze" (let ((x (describe-table FVT|T|VacateFreeze))) "FVT|T|VacateFreeze"))
(try "MISSING FVT|T|SweepProgress" (let ((x (describe-table FVT|T|SweepProgress))) "FVT|T|SweepProgress"))
;; 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/06_VCT.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/07_MTX-AQP.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08_DSA.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING DSA|T|Template" (let ((x (describe-table DSA|T|Template))) "DSA|T|Template"))
(try "MISSING DSA|T|Agency" (let ((x (describe-table DSA|T|Agency))) "DSA|T|Agency"))
(try "MISSING DSA|T|OracleAuth" (let ((x (describe-table DSA|T|OracleAuth))) "DSA|T|OracleAuth"))
;; 1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/3_Talos/02_TS02-C2.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
;; 2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING SNAKES|T|Properties" (let ((x (describe-table SNAKES|T|Properties))) "SNAKES|T|Properties"))
;; 2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact
(try "MISSING P|T" (let ((x (describe-table P|T))) "P|T"))
(try "MISSING P|MT" (let ((x (describe-table P|MT))) "P|MT"))
(try "MISSING CUSTODIANS|T|Properties" (let ((x (describe-table CUSTODIANS|T|Properties))) "CUSTODIANS|T|Properties"))
```

## Inventory

| module | tables |
|---|---|
| `02_IGNIS.pact` | `P|T`, `P|MT` |
| `05_DPTF.pact` | `P|T`, `P|MT`, `DPTF|PropertiesTable`, `DPTF|BalanceTable`, `DPTF|RoleTable` |
| `00_DPMF.pact` | *none* |
| `06_DPOF.pact` | `P|T`, `P|MT`, `DPOF|T|Properties`, `DPOF|T|Nonces`, `DPOF|T|VerumRoles`, `DPOF|T|AccountRoles` |
| `08_ATS.pact` | `P|T`, `P|MT`, `ATS|Pairs`, `ATS|Ledger` |
| `09_TFT.pact` | `P|T`, `P|MT` |
| `10_ATSU.pact` | `P|T`, `P|MT` |
| `11_VST.pact` | `P|T`, `P|MT` |
| `12_LIQUID.pact` | `P|T`, `P|MT` |
| `13_OUROBOROS.pact` | `P|T`, `P|MT` |
| `15_SWP.pact` | `P|T`, `P|MT`, `SWP|Properties`, `SWP|Asymmetry`, `SWP|Pairs`, `SWP|Pools`, `SWP|LP` |
| `16_SWPI.pact` | `P|T`, `P|MT` |
| `17_SWPL.pact` | `P|T`, `P|MT` |
| `18_SWPLC.pact` | `P|T`, `P|MT` |
| `19_SWPU.pact` | `P|T`, `P|MT` |
| `20_MTX-SWP.pact` | `P|T`, `P|MT` |
| `21_CODEX.pact` | `P|T`, `P|MT`, `CODEX|T|Identities`, `CODEX|T|ArweaveTracker`, `CODEX|T|StoicTags`, `CODEX|T|StoicTagsByAccount` |
| `22_PYTHIA.pact` | `P|T`, `P|MT`, `PYTHIA|T|ApiKeys`, `PYTHIA|T|Config`, `PYTHIA|T|DualLinks`, `PYTHIA|T|Revocation`, `PYTHIA|T|PythDaily`, `PYTHIA|T|PythTotal` |
| `01_TS01-A.pact` | `P|T`, `P|MT` |
| `02_TS01-C1.pact` | `P|T`, `P|MT` |
| `03_TS01-C2.pact` | `P|T`, `P|MT` |
| `04_TS01-C3.pact` | `P|T`, `P|MT` |
| `06_TS01-C4.pact` | `P|T`, `P|MT` |
| `02_INFO-ONE+.pact` | *none* |
| `02_DPDC.pact` | `P|T`, `P|MT`, `DPSF|T|Properties`, `DPSF|T|Nonces`, `DPSF|T|VerumRoles`, `DPSF|T|Account`, `DPSF|T|AccountSupplies`, `DPNF|T|Properties`, `DPNF|T|Nonces`, `DPNF|T|VerumRoles`, `DPNF|T|Account`, `DPNF|T|AccountSupplies` |
| `03_DPDC-C.pact` | `P|T`, `P|MT` |
| `04_DPDC-I.pact` | `P|T`, `P|MT` |
| `05_DPDC-R.pact` | `P|T`, `P|MT` |
| `06_DPDC-MNG.pact` | `P|T`, `P|MT` |
| `07_DPDC-T.pact` | `P|T`, `P|MT` |
| `08_DPDC-S.pact` | `P|T`, `P|MT`, `DPSF|SetsTable`, `DPNF|SetsTable` |
| `09_DPDC-F.pact` | `P|T`, `P|MT` |
| `10_DPDC-N.pact` | `P|T`, `P|MT` |
| `11_EQUITY+.pact` | `P|T`, `P|MT` |
| `00_Demipad.pact` | `P|T`, `P|MT`, `DEMIPAD|T|Ledger`, `DEMIPAD|T|Properties` |
| `00_AQP-SCHEMAS.pact` | *none* |
| `01_ANK.pact` | `P|T`, `P|MT`, `ANK|T|Anchor`, `ANK|T|BoostClass`, `ANK|T|AssetAnchors`, `ANK|T|BoostClassScoreLinks`, `ANK|T|Anchors`, `ANK|T|UserBoost` |
| `02_SCORE.pact` | `P|T`, `P|MT`, `SCR|T|Score`, `SCR|T|UserScore`, `SCR|T|SF|Score`, `SCR|T|NF|TraitScore`, `SCR|T|NF|ClassScore`, `SCR|T|SF|DefRevision`, `SCR|T|NF|DefRevision`, `SCR|T|NF|TraitKeys`, `SCR|T|Triplet`, `SCR|T|ScoreEntityModel` |
| `03_AQP.pact` | `P|T`, `P|MT`, `AQP|T|Pool`, `AQP|T|DPTFTracker`, `AQP|T|DPOFTracker`, `AQP|T|DPSFTracker`, `AQP|T|DPNFTracker`, `AQP|T|BenDptfTotal`, `AQP|T|BenDpsfNonceTotal`, `AQP|T|BenDpnfNonceTotal`, `AQP|T|BenDpsfAnkMeta`, `AQP|T|BenDpnfAnkMeta`, `AQP|T|UserOccupancy` |
| `04_RPS.pact` | `P|T`, `P|MT`, `FVT|T|RPS|Global`, `FVT|T|RPS|Member`, `FVT|T|RPS|User`, `FVT|T|RPS|Stream`, `FVT|T|MemberUserWeight`, `FVT|T|MemberVault`, `FVT|T|ForcedFixCount`, `FVT|T|RewardAggregate`, `FVT|T|ScoreEntityLink`, `FVT|T|MultipletFamily`, `FVT|T|UserPresence`, `FVT|T|AgencyFee`, `FVT|T|QualitySplit`, `FVT|T|DsaOracleConfig` |
| `05_FVT.pact` | `P|T`, `P|MT`, `FVT|T`, `FVT|T|VacateFreeze`, `FVT|T|SweepProgress` |
| `06_VCT.pact` | `P|T`, `P|MT` |
| `07_MTX-AQP.pact` | `P|T`, `P|MT` |
| `08_DSA.pact` | `P|T`, `P|MT`, `DSA|T|Template`, `DSA|T|Agency`, `DSA|T|OracleAuth` |
| `09_AQP-INFO.pact` | *none* |
| `01_TS02-C1.pact` | `P|T`, `P|MT` |
| `02_TS02-C2.pact` | `P|T`, `P|MT` |
| `04_TS02-C3.pact` | `P|T`, `P|MT` |
| `05_TS02-DPAD.pact` | `P|T`, `P|MT` |
| `02_Snakes.pact` | `P|T`, `P|MT`, `SNAKES|T|Properties` |
| `03_Custodians.pact` | `P|T`, `P|MT`, `CUSTODIANS|T|Properties` |
| `01_INFO-TWO.pact` | *none* |
| `04_AQP-BOOT.pact` | *none* |

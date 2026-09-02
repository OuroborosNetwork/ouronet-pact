;; REPL-only AQPGAS module — stake/unstake gas vs pool score count (loaded from .repl wrapper)
(module AQPGAS GOVERNANCE
    @doc "REPL stake/unstake gas matrix helpers (1 leg / 1 nonce; owner=beneficiary=synth-001)."
    (defcap GOVERNANCE () true)
    (defconst GAS-LIMIT 2000000)
    (defun UC_Owner:string ()
        (VCTGAS.UC_SynthAccount 1)
    )
    (defun XI_AddTrueFungibleScores:bool
        (patron:string pool-id:string fvt-id:string ouro-id:string n-scores:integer)
        (let
            (
                (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
            )
            (if (<= n-scores 1)
                true
                (fold
                    (lambda (acc:bool idx:integer)
                        (let
                            (
                                (score-name:string (format "GasTfSc{}x{}" [idx n-scores]))
                                (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                            )
                            (ref-TS02-C3::C_AQP-SCR|IssueTrueFungibleScore patron patron score-name 12 1.0)
                            (ref-TS02-C3::C_AQP-POOL|AddScore patron pool-id score-id)
                            (ref-TS02-C3::C_AQP-FVT|AddScoreEntity patron fvt-id 1 score-id)
                        )
                        true
                    )
                    true
                    (enumerate 2 n-scores)
                )
            )
        )
    )
    (defun XI_AddOrtoFungibleScores:bool
        (patron:string pool-id:string fvt-id:string ouro-id:string n-scores:integer)
        (let
            (
                (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
            )
            (if (<= n-scores 1)
                true
                (fold
                    (lambda (acc:bool idx:integer)
                        (let
                            (
                                (score-name:string (format "GasOfSc{}x{}" [idx n-scores]))
                                (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                            )
                            (ref-TS02-C3::C_AQP-SCR|IssueOrtoFungibleScore patron patron score-name 12 1.0 1.0)
                            (ref-TS02-C3::C_AQP-POOL|AddScore patron pool-id score-id)
                            (ref-TS02-C3::C_AQP-FVT|AddScoreEntity patron fvt-id 1 score-id)
                        )
                        true
                    )
                    true
                    (enumerate 2 n-scores)
                )
            )
        )
    )
    (defun XI_AddSemiFungibleScores:bool
        (patron:string pool-id:string fvt-id:string ouro-id:string n-scores:integer)
        (let
            (
                (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
            )
            (if (<= n-scores 1)
                true
                (fold
                    (lambda (acc:bool idx:integer)
                        (let
                            (
                                (score-name:string (format "GasSfSc{}x{}" [idx n-scores]))
                                (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                            )
                            (ref-TS02-C3::C_AQP-SCR|IssueSemiFungibleScore patron patron score-name 3 true)
                            (ref-TS02-C3::C_AQP-POOL|AddScore patron pool-id score-id)
                            (ref-TS02-C3::C_AQP-FVT|AddScoreEntity patron fvt-id 1 score-id)
                        )
                        true
                    )
                    true
                    (enumerate 2 n-scores)
                )
            )
        )
    )
    (defun XI_AddNonFungibleScores:bool
        (patron:string pool-id:string fvt-id:string ouro-id:string n-scores:integer)
        (let
            (
                (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
            )
            (if (<= n-scores 1)
                true
                (fold
                    (lambda (acc:bool idx:integer)
                        (let
                            (
                                (score-name:string (format "GasNfSc{}x{}" [idx n-scores]))
                                (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                            )
                            (ref-TS02-C3::C_AQP-SCR|IssueNonFungibleScore patron patron score-name 6 0)
                            (ref-TS02-C3::C_AQP-POOL|AddScore patron pool-id score-id)
                            (ref-TS02-C3::C_AQP-FVT|AddScoreEntity patron fvt-id 1 score-id)
                        )
                        true
                    )
                    true
                    (enumerate 2 n-scores)
                )
            )
        )
    )
    (defun XI_MeasureStakeTf:integer
        (patron:string pool-id:string ouro-id:string amount:decimal)
        (let
            (
                (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                (owner:string (UC_Owner))
                (g-before:integer (env-gas))
            )
            (ref-TS02-C3::CC_AQP-POOL|StakeTrueFungible patron pool-id owner owner ouro-id amount)
            (- (env-gas) g-before)
        )
    )
    (defun XI_MeasureUnstakeTf:integer
        (patron:string pool-id:string ouro-id:string amount:decimal)
        (let
            (
                (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                (owner:string (UC_Owner))
                (g-before:integer (env-gas))
            )
            (ref-TS02-C3::CC_AQP-POOL|UnstakeTrueFungible patron pool-id owner owner ouro-id amount)
            (- (env-gas) g-before)
        )
    )
    (defun XI_MeasureStakeOf:integer
        (patron:string pool-id:string dpof-id:string nonces:[integer])
        (let
            (
                (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                (owner:string (UC_Owner))
                (g-before:integer (env-gas))
            )
            (ref-TS02-C3::CC_AQP-POOL|StakeOrtoFungible patron pool-id owner owner dpof-id nonces)
            (- (env-gas) g-before)
        )
    )
    (defun XI_MeasureUnstakeOf:integer
        (patron:string pool-id:string dpof-id:string nonces:[integer])
        (let
            (
                (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                (owner:string (UC_Owner))
                (g-before:integer (env-gas))
            )
            (ref-TS02-C3::CC_AQP-POOL|UnstakeOrtoFungible patron pool-id owner owner dpof-id nonces)
            (- (env-gas) g-before)
        )
    )
    (defun XI_MeasureStakeDpsf:integer
        (patron:string pool-id:string dpsf-id:string nonces:[integer])
        (let
            (
                (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                (owner:string (UC_Owner))
                (g-before:integer (env-gas))
            )
            (ref-TS02-C3::CC_AQP-POOL|StakeSemiFungibleCollectable patron pool-id owner owner dpsf-id nonces)
            (- (env-gas) g-before)
        )
    )
    (defun XI_MeasureUnstakeDpsf:integer
        (patron:string pool-id:string dpsf-id:string nonces:[integer])
        (let
            (
                (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                (owner:string (UC_Owner))
                (g-before:integer (env-gas))
            )
            (ref-TS02-C3::CC_AQP-POOL|UnstakeSemiFungibleCollectable patron pool-id owner owner dpsf-id nonces)
            (- (env-gas) g-before)
        )
    )
    (defun XI_MeasureStakeDpnf:integer
        (patron:string pool-id:string dpnf-id:string nonces:[integer])
        (let
            (
                (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                (owner:string (UC_Owner))
                (g-before:integer (env-gas))
            )
            (ref-TS02-C3::CC_AQP-POOL|StakeNonFungibleCollectable patron pool-id owner owner dpnf-id nonces)
            (- (env-gas) g-before)
        )
    )
    (defun XI_MeasureUnstakeDpnf:integer
        (patron:string pool-id:string dpnf-id:string nonces:[integer])
        (let
            (
                (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                (owner:string (UC_Owner))
                (g-before:integer (env-gas))
            )
            (ref-TS02-C3::CC_AQP-POOL|UnstakeNonFungibleCollectable patron pool-id owner owner dpnf-id nonces)
            (- (env-gas) g-before)
        )
    )
)

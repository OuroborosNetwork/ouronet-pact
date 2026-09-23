;; ---------------------------------------------------------------------------
;; OURONET INIT -- MANUAL step, hand-authored.
;; Label : rotate the Stage Two dispensing bucket's GOVERNOR onto DSP's capability
;;
;; RUN THIS AFTER Deploy/1_Pure/24_deploy.pact (the DSP module).
;; The order is not a preference -- (create-capability-guard (DSP|S2-GOV)) cannot be
;; built before the capability it names exists, and DSP|S2-GOV is defined in DSP.
;;
;; THIS FILE IS NOT GENERATED. The account is activated by the owner from the
;; Codex, so no deployment transaction appears in this pipeline; only the rotation
;; does, and it is hand-authored because _deploybundle.py extracts from the REPL
;; deploy chain and this step has no REPL counterpart yet. _deploybundle.py knows
;; this file by name and will not report it as an orphan.
;;
;; WHAT IT DOES, AND WHY THIS IS THE MECHANISM.
;;
;; DALOS::UEV_SmartAccOwn proves ownership of a smart account with
;;
;;     (enforce-one [ (enforce-guard account-guard)
;;                    (enforce-guard sovereign-guard)
;;                    (enforce-guard governor) ])
;;
;; so pointing the bucket's GOVERNOR at a capability guard from DSP means: any
;; transaction that has acquired DSP|S2-GOV in scope owns the bucket. That is the
;; autonomic ownership proof the emission needs -- the four Stage Two capabilities
;; each compose DSP|S2-GOV, so the emission spends from the bucket without anyone
;; holding a key for it, and nothing else can.
;;
;; IT IS A GOVERNOR, NOT A SOVEREIGN, AND NOT AN IMC CONCERN. P|UEV_IMC authorises
;; inter-module CALLS; this authorises ACCOUNT OWNERSHIP. The bucket is resident to
;; this module's authority, so there is NO policy plumbing here at all -- no P|A_Add,
;; no registry entry, and the capability does not carry the `P|` prefix. The governor
;; stored on the account row is the whole mechanism, and UEV_SmartAccOwn reads it
;; directly.
;;
;; (Written down because the first draft got this wrong in both directions: the
;; capability was named P-pipe-DRG-S2 and registered through P|A_Add, which placed an
;; ownership capability inside the IMC machinery the very comment above says it has
;; nothing to do with -- and DRG stands for Dalos Remote Governor, which this is not.
;; It is DSP|S2-GOV, a plain capability in DSP's governance block.)
;;
;; WHY A SEPARATE CAPABILITY FROM P|DRG. A governor guard is an ownership proof.
;; Had the bucket shared the general dispenser's P|DRG, every Koson leg and the
;; Stoicism minter would have been able to spend the Stage Two emission. One
;; capability, one account, one job.
;;
;; SIGNERS: the bucket's own keyset. C_RotateGovernor enforces ownership of
;; <executor>, and before this rotation the only thing that proves it is that key.
;; After it, the capability does too -- so run this once and keep the key.
;;
;; 2 forms.
;; ---------------------------------------------------------------------------

;; EVERY REFERENCE BELOW IS FULLY QUALIFIED. The namespace line is still here, but nothing
;; depends on it: a paste-ready transaction must not rely on ambient namespace state, because
;; the failure mode is silent-looking and confusing -- a bare `DSP.DSP|S2-GOV` outside the
;; namespace reports "Module DSP has no such member: DSP|S2-GOV", which reads as a missing
;; capability rather than a missing namespace. Hit live, 2026-09-24.
(namespace "ouronet-ns")

(ouronet-ns.TS01-C1.DALOS|C_RotateGovernor
    "<<<FILL: patron -- the account paying for this call>>>"
    "Σ.i₿čУÕнЩťÛБoÛțmbюØДбgΣÞvhÉDτĞШU€ΛρÉycÇŒιЫWвфÓìÙõЙȚcąÅγXμSЛdăœρΣЫœąЛз4ěìvŹ₱OßeЛåγЬÿ5цůăÑœдżÛöÃŁτTĆĚŤйO9лцìŒUμvŤxBãĘΠÒÁõЪЖÌțȚeв¢jþψHtΣŹõÒqúΠğďßżpш2t3Şëχμι3DciüÏγλM"
    (create-capability-guard (ouronet-ns.DSP.DSP|S2-GOV))
)


;; ---------------------------------------------------------------------------
;; 2. The bucket MINTS the emission itself.
;;
;; C_Mint credits its EXECUTOR, so the OURO mint role has to sit on the bucket --
;; not on the standard dispenser it replaced. Without this the very first emission
;; fails at leg 1. Found by wiring the REPL fixture, where the equivalent line for
;; DSP1 has existed since the Stage One minter was written.
;;
;; Its DPTF token accounts are NOT deployed here: they are created on first use.
;; ---------------------------------------------------------------------------
(ouronet-ns.TS01-C1.DPTF|C_ToggleMintRole
    "<<<FILL: patron>>>"
    (ouronet-ns.DPTF.UR_Konto (ouronet-ns.DALOS.UR_OuroborosID))
    "Σ.i₿čУÕнЩťÛБoÛțmbюØДбgΣÞvhÉDτĞШU€ΛρÉycÇŒιЫWвфÓìÙõЙȚcąÅγXμSЛdăœρΣЫœąЛз4ěìvŹ₱OßeЛåγЬÿ5цůăÑœдżÛöÃŁτTĆĚŤйO9лцìŒUμvŤxBãĘΠÒÁõЪЖÌțȚeв¢jþψHtΣŹõÒqúΠğďßżpш2t3Şëχμι3DciüÏγλM"
    (ouronet-ns.DALOS.UR_OuroborosID)
    true
)

;; ---------------------------------------------------------------------------
;; AFTER THIS LANDS, one more thing is owed before the emission uses the bucket:
;; the payable flags. The account was activated from the Codex, so confirm they
;; read false / false / true, and set them if not:
;;
;;   (TS01-C1.DALOS|C_ControlSmartAccount <patron> "<Σ.…>" false false true)
;;
;;   payable-as-smart-contract = false   closes Normal -> Smart, method=false
;;   payable-by-smart-contract = false   closes Smart  -> Smart, method=false
;;   payable-by-method         = TRUE    allows method=true -- but DPTF|C>X-TRANSFER
;;       ALSO runs (CAP_EnforceAccountOwnership receiver) for a smart receiver with
;;       method=true, so the sender needs the bucket's ownership. That is the one
;;       route the emission itself needs: ATS|C_Coil finishes with
;;       (C_Transfer ATS|SC_NAME -> executor c-rbt ... true), and after the rotation
;;       above the emission satisfies it through DSP|S2-GOV.
;;
;; Net effect: nobody but the emission can fund the bucket, so every OURO and AURYN
;; balance it holds is by definition emission owed to the four vaults -- which is
;; what lets URC_StageTwoResidual derive the inject amounts from the balance with no
;; stored state and no enforce. Note that A_DeploySmartAccount already writes
;; payable-as-smart-contract = false at creation; only payable-by-method needs a
;; deliberate flip.
;; ---------------------------------------------------------------------------

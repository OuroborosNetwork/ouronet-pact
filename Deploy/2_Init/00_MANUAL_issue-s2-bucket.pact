;; ---------------------------------------------------------------------------
;; OURONET INIT -- MANUAL step, hand-authored.
;; Label : issue the Stage Two dispensing bucket (OuroStageTwoDispensingBucket)
;;
;; THIS FILE IS NOT GENERATED. Every other file in Deploy/ is emitted by
;; REPL/tools/_deploybundle.py from the sources; this one cannot be, because the
;; account string, the public key and the keyset do not exist anywhere in the
;; repository and cannot be derived from it. They are the owner's to choose.
;; _deploybundle.py knows this file by name and will not report it as an orphan.
;;
;; RUN THIS BEFORE the Stage Two emission is switched to the bucket. Until it
;; exists, DSP.S2-BUCKET|SC_NAME still resolves to the standard dispenser and the
;; emission behaves exactly as it does today -- so the ordering is safe either way.
;;
;; SIGNERS: the keyset chosen in form 1. Form 2 is signed by the SAME keyset,
;; because C_ControlSmartAccount enforces ownership of <executor>, and <executor>
;; here is the bucket itself.
;;
;; 2 form(s). Three placeholders, marked <<<FILL>>>.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ---------------------------------------------------------------------------
;; OPTIONAL -- a dedicated keyset, if you do not want the existing dispenser
;; signers to be able to move the Stage Two emission. Delete if reusing
;; "ouronet-ns.dh_sc_dispenser-keyset" below.
;; ---------------------------------------------------------------------------
;; (define-keyset "ouronet-ns.dh_sc_s2bucket-keyset" (read-keyset "KEY_SC_S2Bucket"))

;; ---------------------------------------------------------------------------
;; 1. Deploy the smart Ouronet account.
;;
;;    executor   the Σ. account string -- a SMART account, so it must start with Σ
;;    guard      the keyset that owns it
;;    stoa       the Kadena/Stoa account name it is anchored to
;;    sovereign  the STANDARD account it pairs with. Every smart account in this
;;               tree has one (DSP2->DSP1, CST2->CST1). Reusing the standard
;;               dispenser is simplest; a dedicated partner needs its own
;;               A_DeployStandardAccount first.
;;    public     the public key string
;; ---------------------------------------------------------------------------
(TS01-A.DALOS|A_DeploySmartAccount
    "<<<FILL: Σ. account string>>>"
    (keyset-ref-guard "ouronet-ns.dh_sc_dispenser-keyset")
    "<<<FILL: kadena/stoa account name>>>"
    KC2.DPTS_NAME_a
    "<<<FILL: public key>>>"
)

;; ---------------------------------------------------------------------------
;; 2. Set the three payable flags: false / false / true.
;;
;;    These close every inbound route to the bucket except one, and that one
;;    requires the bucket's own signature. Derived from DALOS::URC_Transferability
;;    and the receiver check in DPTF|C>X-TRANSFER:
;;
;;      payable-as-smart-contract = false
;;          closes Normal -> Smart with method=false
;;      payable-by-smart-contract = false
;;          closes Smart  -> Smart with method=false
;;      payable-by-method         = TRUE
;;          allows method=true -- but DPTF|C>X-TRANSFER additionally runs
;;          (CAP_EnforceAccountOwnership receiver) when the receiver is smart and
;;          method is true, so the SENDER needs THIS ACCOUNT'S KEY. That is the
;;          one route the emission itself needs: ATS|C_Coil finishes with
;;          (C_Transfer ATS|SC_NAME -> executor c-rbt ... true), and the emission
;;          transaction is signed by this keyset, so it passes.
;;
;;    Net effect: the bucket cannot be funded by anyone but its owner, so every
;;    OURO and AURYN balance it holds is by definition emission owed to the four
;;    vaults. That is what lets the inject legs derive their amounts from the
;;    balance with no stored state and no enforce -- and it is why no
;;    (enforce (= balance 0.0)) appears anywhere in the emission. Such an enforce
;;    would have been a denial-of-service: the dispenser address is public, and
;;    one dust transfer would block the daily emission until someone swept it.
;;
;;    Minting is unaffected by all of this -- a mint is not a transfer. Proven by
;;    precedent: SWP|SC_NAME and ATS|SC_NAME are both Σ accounts and are minted
;;    into today.
;; ---------------------------------------------------------------------------
(TS01-C1.DALOS|C_ControlSmartAccount
    "<<<FILL: patron -- the account paying for this call>>>"
    "<<<FILL: Σ. account string -- the same one as above>>>"
    false
    false
    true
)

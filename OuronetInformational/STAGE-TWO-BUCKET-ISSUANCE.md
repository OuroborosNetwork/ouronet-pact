# Issuing the Stage Two dispensing bucket

> **For the owner to execute.** Fill in the two placeholders, run the two forms, then the emission
> code switches to it. Until it exists, `DSP1|SC_NAME` stays the dispenser.

## Name

Proposed Pact constant: **`DSP-S2|SC_NAME`** — human label *OuroStageTwoDispensingBucket*.

Reason for the short form: every service account in the tree is a short token plus `|SC_NAME`
(`DSP1`, `DSP2`, `CST1`, `AQP`, `SWP`, `ATS`, `ORBR`, `DHV1`). `DSP-S2` keeps it inside the DSP
family, says which stage it serves, and reads cleanly at the call sites where it will appear ~8
times. The long name lives in the `@doc`. Hyphens are fine in Pact identifiers — `HOT-RBT|` already
does it. Say the word if you'd rather have `S2B|SC_NAME` or keep the full name.

## Why a dedicated account rather than DSP2

DSP2 is already deployed and unused, so it *would* work. But it is the general smart dispenser, and
the whole value of this design is that **every OURO and AURYN balance in the bucket is, by
definition, emission owed to the four vaults**. That property is what lets the inject legs derive
their amounts from the balance with no stored state and no enforce. Sharing the account with
general dispensing destroys exactly that property. Keep DSP2 for general use.

## The flags, and why these three values

The transferability matrix (`DALOS::URC_Transferability`) plus the receiver check in
`DPTF|C>X-TRANSFER` give four inbound routes to a smart account. These settings close all of them
to everyone except a holder of the bucket's own key:

| inbound route | governed by | set to | effect |
|---|---|:---:|---|
| Normal → Smart, `method=false` | `payable-as-smart-contract` | **false** | closed |
| Smart → Smart, `method=false` | `payable-by-smart-contract` | **false** | closed |
| Normal/Smart → Smart, `method=true` | `payable-by-method` | **true** | allowed by the flag, **but `CAP_EnforceAccountOwnership receiver` also fires — the bucket must sign** |
| mint | — | — | not a transfer; works regardless (proven: `SWP\|SC_NAME` and `ATS\|SC_NAME` are both `Σ` and are minted into today) |

So `payable-by-method = true` is **not** an open door. It is the one route the emission itself
needs — `ATS|C_Coil` finishes with `C_Transfer ATS|SC_NAME → executor … true`, which is smart→smart
with `method=true` — and because the emission transaction is signed by the bucket's keyset, it
passes. A third party cannot forge that signature, so the same flag that lets the coil in keeps
everyone else out.

**Consequence: no `enforce (= balance 0.0)` is needed anywhere.** That enforce was the griefing
vector; with an unpollutable bucket there is nothing to enforce against.

## The two transactions

```pact
(namespace "ouronet-ns")

;; ---------------------------------------------------------------------------
;; 1. Deploy the smart account.
;;    Signed by: the dispenser keyset (or a new dedicated one -- see the note below).
;; ---------------------------------------------------------------------------
(TS01-A.DALOS|A_DeploySmartAccount
    "<Σ.………>"                                              ;; <<< FILL: the Σ account string
    (keyset-ref-guard "ouronet-ns.dh_sc_dispenser-keyset")  ;; guard
    "<kadena-account-name>"                                 ;; <<< FILL: the Stoa/Kadena name
    KC2.DPTS_NAME_a                                         ;; sovereign = the STANDARD dispenser
    "<public-key>"                                          ;; <<< FILL: the public key
)

;; ---------------------------------------------------------------------------
;; 2. Set the three payable flags. Signed by the SAME keyset -- C_ControlSmartAccount
;;    enforces ownership of <executor>, which is the bucket itself.
;; ---------------------------------------------------------------------------
(TS01-C1.DALOS|C_ControlSmartAccount
    <patron>          ;; whoever pays -- the admin account at init time
    "<Σ.………>"         ;; <<< FILL: the same Σ account string
    false             ;; payable-as-smart-contract  -- closed
    false             ;; payable-by-smart-contract  -- closed
    true              ;; payable-by-method          -- the coil's route, signature-gated
)
```

Signatures verified against the sources:
`DALOS|A_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string)`
and
`DALOS|C_ControlSmartAccount (patron:string executor:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool)`.

### Two choices only you can make

1. **Keyset.** Reusing `dh_sc_dispenser-keyset` means the existing dispenser signers can move the
   emission. A new `dh_sc_s2bucket-keyset` separates that authority. The emission code does not
   care which; separation is the more conservative choice and costs one `define-keyset`.
2. **Sovereign account.** Every smart account in this tree pairs with a standard one
   (`DSP2`→`DSP1`, `CST2`→`CST1`). Reusing `KC2.DPTS_NAME_a` is simplest. A dedicated standard
   partner would need its own `A_DeployStandardAccount` first.

## Where it goes in the deploy pipeline

`Deploy/2_Init/` is **extracted**, not hand-written — `_deploybundle.py` lifts the real forms out of
the REPL deploy chain, so a file dropped there by hand would be reported as an ORPHAN by `--check`.

The sequence is therefore:

1. You choose the account string, public key, keyset and sovereign.
2. Those go into `REPL/Stage_01/[5.2]_Dispenser+.repl`, beside the existing dispenser/custodian
   account deployments, as two more forms in the same `begin-tx`.
3. `python3 REPL/tools/_deploybundle.py --write` extracts them into `Deploy/2_Init/`, in sequence,
   with the signer keys listed in the header.

That order matters: the constants have to exist before the REPL will load, so the fixture edit
cannot be made until the strings are real.

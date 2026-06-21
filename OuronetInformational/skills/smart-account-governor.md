# Smart-account governor: MODULE|GOV vs RemoteGov (Ouronet)

## Three patterns

| Pattern | Account owner | Runtime compose | `C_RotateGovernor` |
|---------|---------------|-----------------|---------------------|
| **Simple vault** | Same module | **`MODULE|GOV`** on send **and** receive (smart accounts are not free-receive) | `(create-capability-guard (MODULE.MODULE|GOV))` |
| **Hub + children** | Parent (e.g. **`DEMIPAD|SC_NAME`**) | Child composes **`P|PAD-*|REMOTE-GOV`** | **`UEV_GuardOfAny`**: parent **`GOV`** + **`ref-P|PARENT::P|UR "Child|RemoteGov"`** |
| **Forward on foreign vault** | Other module (e.g. **`DALOS|SC_NAME`**, **`VST|SC_NAME`**) | Forward module composes **`P|*|REMOTE-GOV`** | Named slot on **account owner’s** **`P|T`** via child **`P|A_Define`** |

## RemoteGov is not a different guard

`(ref-P|VST::P|UR "SWPLC|RemoteSwpGov")` ≡ `(create-capability-guard (SWPLC.P|SWPLC|REMOTE-GOV))` after **`P|A_Add`**.

RemoteGov exists because:

- **Semantic split** — **`MODULE|GOV`** = “I own this account”; **`P|*|REMOTE-GOV`** = “I operate your account from my module”.
- **Registry on account owner** — child **`P|A_Define`** registers on parent **`P|T`**; rotate tx reads named slots.
- **No `SWPLC|GOV`** — forward modules often have admin caps only, not vault GOV caps.

## AQP (simple vault)

- **`AQP|SC_NAME`** owned by **AQP-POOL** only.
- **`AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`** composes **`AQP|GOV`** on **both** stake and unstake.
- Step 0: **`create-capability-guard (AQP-POOL.AQP|GOV)`** only — no **`AQP|RemoteGov`** unless a forward module later debits the vault without going through POOL’s XE cap.

## `P|A_Define` IMP

- **`ref-P|TFT::P|A_AddIMP`** when module calls **`TFT::after`** (**`UEV_IMC`**).
- **`ref-P|DALOS::P|A_AddIMP`** only when calling DALOS paths behind **`UEV_IMC`** — not for plain **`UR_*` / `CAP_*` / `UEV_EnforceAccount*`** reads.

Reference: **`REPL/Stage_01/[4.0]_Sovereign-Executor.repl`** (LIQUID/ORBR vs VST/DALOS/DEMIPAD); **`03_AQP.pact`**, **`AQP-BOOT.C_Step0`**.

**Cursor skill:** `.cursor/skills/ouronet-tft-vault-imc/SKILL.md`, `.cursor/skills/ouronet-pact-conventions/SKILL.md`.

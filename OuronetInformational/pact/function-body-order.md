# Function and capability body order (Ouronet Pact)

How to order **statements inside** a `defcap`, `defun` (`C_*` / `A_*` / `XI_*` / `UEV_*`), and the **bindings inside `let`**.

**AQP scope:** `01_ANK` … `05_VCT`.

---

## `let` binding order (always first)

See **`let-binding-layout.md`**.

1. All **`(ref-*:module{…} …)`** bindings.
2. **`;;`** separator (when locals follow).
3. **Local variables** — keys, reads, cumulator bindings, computed flags.

---

## Executable body order (strict)

After **`let`** (or at top level when there is no `let`), group **all** statements in this order — **do not interleave**:

| Step | What | Examples |
|------|------|----------|
| **1** | **Pact natives** | **`enforce`**, **`enforce-guard`**, **`enforce-keyset`**, **`enforce-one`**; guard **`if`** / **`do`** whose body is only more natives |
| **2** | **Previous modules** | Bare **`(ref-MODULE::…)`** calls (not already wrapped in step 1 **`enforce`**) |
| **3** | **Current module** | **`UR_*`**, **`URC_*`**, **`URDC_*`**, **`XI_*`**, **`W_*`**, **`UC_*`**, home **`UEV_*`** invoked as helpers |
| **4** | **Capabilities** | **`with-capability`**, **`require-capability`**, **`compose-capability`** |

**Rule of thumb:** *all `enforce` first → all bare `ref-*` → all home → caps last.*

An **`(enforce (ref-DPTF::URC_IzRBTg …) "…")`** line is step **1** (native **`enforce`** wrapper). A bare **`(ref-DPTF::UEV_id …)`** is step **2**.

Inside **`with-capability`**: step **2** **`ref-*::XE_*`** before step **3** home **`XI_*`** / **`W_*`**.

### `UEV_*` example

```pact
(defun UEV_IssueTripletFamilyContext (…)
    (let ((ref-DPTF:module{…} DPTF) (ref-ATS:module{…} ATS))
        ;; 1] natives
        (enforce (fold (and) true [(!= token-0-id token-1-id) …]) "…")
        (enforce (ref-DPTF::URC_IzRBTg ats-0-1-id token-1-id) "…")
        (enforce (ref-DPTF::URC_IzRBTg ats-1-2-id token-2-id) "…")
        ;; 2] ref
        (ref-DPTF::UEV_id token-0-id)
        (ref-DPTF::UEV_id token-1-id)
        (ref-DPTF::UEV_id token-2-id)
        (ref-ATS::UEV_id ats-0-1-id)
        (ref-ATS::UEV_id ats-1-2-id)
        (ref-ATS::UEV_RewardTokenExistance ats-0-1-id token-0-id true)
        (ref-ATS::UEV_RewardTokenExistance ats-1-2-id token-1-id true)
    )
)
```

### `defcap` example

```pact
(defcap SCR|XI>ISSUE-SCORE (…)
    (let ((ref-U|ATS:module{…} U|ATS) (ref-U|DALOS:module{…} U|DALOS) (ref-DALOS:module{…} DALOS) ;; (score-id:string …))
        ;; 1] natives
        (enforce (fold (and) true […]) "…")
        (enforce (if (= score-class 0) (!= lp-denominator BAR) (= lp-denominator BAR)) "…")
        ;; 2] ref
        (ref-U|ATS::UEV_AutostakeIndex score-name)
        (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
        (ref-DALOS::UEV_EnforceAccountType owner-konto false)
        (ref-U|DALOS::UEV_Fee mx-frozen)
        (ref-U|DALOS::UEV_Fee mx-sleeping)
        (ref-U|DALOS::UEV_Fee mx-hibernated)
        (if (= score-class 0)
            (let ((ref-DPTF:module{…} DPTF))
                (ref-DPTF::UEV_id lp-denominator)
            )
            true
        )
        ;; 4] caps
        (compose-capability (SECURE))
    )
)
```

### `C_*` recipe

```pact
(defun C_IssueTriplet:object{IgnisCollectorV1.OutputCumulator} (…)
    (UEV_IMC)
    (let ((ref-IGNIS:module{…} IGNIS) ;; (owner-konto:string …) (trigger:bool …))
        (with-capability (SCR|C>ISSUE-TRIPLET …)
            (XI_IssueTriplet …)
        )
        (ref-IGNIS::UDC_ConstructOutputCumulator …)
    )
)
```

**Never** bare **`enforce`** in **`XI_*` / `XE_*` / `C_*`** — validation belongs in **`defcap`** / **`UEV_*`**. See **`x-function-guards.md`**.

---

## Related

| Topic | File |
|-------|------|
| `let` bindings | `let-binding-layout.md` |
| `defcap` caps | `defcap-body-order.md` |
| Boolean grouping | `enforce.md` |
| Convention index | `ouronet/conventions/index.md` |

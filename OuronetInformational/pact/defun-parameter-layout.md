# `defun` / `defcap` parameter layout (Ouronet Pact)

How to format the **input parameter list** on **`defun`**, **`defcap`**, and **`defun`-style UDC constructors**.

## Rule

| Case | Layout |
|------|--------|
| **Fits on one line** | Put the **full signature on the `defun` / `defcap` line** — name, return type (if any), and **all** parameters in one `(...)` group. |
| **Too long** (long return type like `object{…}`, or many parameters) | **Name (+ return type) on line 1**; **parameters on following lines** in a dedicated `(...)` block — **one parameter per line**. |

**Do not** use the hybrid style: name on one line, then `( param:type` with parameters squeezed on one or two continuation lines and a trailing `)` on the same line as the last param.

## One-line (preferred when it fits)

```pact
(defun UC_DualLinkKey:string (standard-apollo:string smart-apollo:string)
(defun A_LinkDualApiKey:string (standard-apollo:string smart-apollo:string)
(defcap PYTHIA|A>LINK-DUAL (standard-apollo:string smart-apollo:string)
(defun WU_DualLink|IzActive:string (dual-link-key:string iz-active:bool)
(defun UDC_AKY|WithRegisteredFlag:object (row:object{PYTHIA|S|ApiKey})
```

Single-parameter functions always use the one-line form.

## Multiline block (long return type or many args)

Opening `(` on its own line under the name; each parameter indented; closing `)` before `@doc` / body:

```pact
(defun PYTHIA|INFO_DeployApiKey:object{OuronetInfoV1.ClientInfo}
    (
        patron:string
        owner-account:string
        apollo-account:string
        public:string
    )
    @doc "ClientInfo for TS01-C4 PYTHIA|C_DeployApiKey (500 STOA per half)."
    ...
)

(defcap PYTHIA|C>LINK-DUAL
    (
        standard-apollo:string
        smart-apollo:string
        consumer-lane:string
    )
    @doc "Both Apollo half-owners link deployed halves into inactive dual row with lane label."
    @event
    ...
)

(defun C_LinkDualApiKey:string
    (
        standard-apollo:string
        smart-apollo:string
        consumer-lane:string
    )
    @doc "Both half-owners link deployed halves into inactive dual row with lane (no fee)."
    ...
)

(defun WI_ApiKey:string
    (
        apollo-account:string
        row:object{PYTHIA|S|ApiKey}
    )
    ...
)
```

Same layout applies to **`UDC_*` constructors** with `object{Schema}` return types and to **`UEV_*`** helpers with multiple arguments.

## `@doc` placement

**`@doc`** (and **`@event`** on caps) comes **immediately after the closing `)` of the parameter list** — never between the function name and `(`.

See also **`ouronet/conventions/ur-layout.md`** (UR suffix / W pairing).

## When to choose multiline

Use the block form when **any** of these is true:

- Return type includes **`object{…}`** with a long interface or schema name.
- **Three or more** parameters and the one-line signature would wrap awkwardly in review.
- **`defcap`** names are long (`PYTHIA|C>DEPLOY-API-KEY`, recipe caps) and the cap carries several typed args.

When only the **return type** is long but there is **one short parameter**, one line is still fine:

```pact
(defun C_RevokeAnchor:object{IgnisCollectorV1.OutputCumulator} (anchor-id:string))
```

## Reference implementations

- **`1_SOVEREIGN/STAGE_01/2_Core/23_PYTHIA.pact`** — caps, C/A, INFO, UDC, W, UEV, XI
- **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact`** — interface block one-liners vs module bodies

**Cursor:** `OuronetInformational/ouronet/conventions/index.md`

# UC vs URC — enforcement rule (2026-04-08)

- **UC_*:** Pure computation on arguments only — no table `read`, **no `enforce`**. Lives in the first FUNCTIONS block for true compute helpers.
- **URC_*:** Reads state (typically via **UR_** / `read`) and derives values. **Not** labeled UC. **No `enforce`** in the helper — use **UEV_** or **defcap** / caller for failures. Place under the **URC** section (after **UR** block when the file orders that way).

Example fix: `UC_TrueFungibleAnchorPromile` in `01_ANK.pact` renamed to **`URC_TrueFungibleAnchorPromile`**; invalid `dptf-amount` handled with **`if`** → `0.0`, not `enforce`.

Referenced in `OuronetInformational/MODULE_ARCHITECTURE.md`.

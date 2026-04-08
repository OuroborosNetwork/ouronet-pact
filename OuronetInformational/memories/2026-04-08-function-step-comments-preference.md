# Function and Capability Commenting Preference

User preference for Pact code authoring style:

- Add meaningful `@doc` text to functions/capabilities that are introduced or refactored.
- Inside such functions/capabilities, annotate core logic with numbered step comments.
- Keep comments operational (what the line/block does), similar to existing capability step style.
- Keep formatting readable and avoid long horizontal lines.

This should be applied consistently in future ANK/AQP/SCORE/FVT refactors.

Additional refinement from ANK consultation:

- Avoid duplicate validation in layered paths (e.g. capability and UEV both validating the same input).
- Keep UEV functions focused on their specific responsibility; do not re-validate name inputs already validated in capability.
- Prefer direct use of existing variables over redundant aliases (e.g. avoid `x:string y` when `y` can be used directly).

Talos client output preference:

- Talos client functions should end with a clear explanatory result string via `format`, not raw IDs.
- When output IDs differ by branch (e.g. acnoi true/false), message should describe what happened in that branch.

REPL testing preference (AQP/ANK phase):

- In REPL tests, do not generate anchor-class-id ad hoc for flow control when it is already known from prior issuance.
- Use previously spawned ids directly (name + current chain hash suffix), e.g. `AnchorClassRain-98c486052a51`.
- With `env-chain-data` fixed to the standard Stage_02 hash, ids are deterministic and should be referenced explicitly in later test steps.
- Apply KDA split + transfer caps for STOA collection only on transactions that include issuance client calls.

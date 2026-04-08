# Pact / Ouronet: documentation line length

**Preference (project):** Do not write very long single-line `@doc` strings (or `;;` comments) in `.pact` files—avoid horizontal scrolling in the editor.

**Practice:**

- Keep each **source line** roughly within **~88–92 characters** (including leading indentation), or shorter.
- For multi-sentence schema or function docs in Pact, use **string continuation**: end a line with `\`, then continue with `\` at the start of the next line (same pattern as existing `SCR|Schema` / ANK docs).
- Break at **phrase or clause boundaries**, not mid-word.

**Rationale:** Long single-line `@doc` entries are hard to review in diffs and in narrow editor layouts.

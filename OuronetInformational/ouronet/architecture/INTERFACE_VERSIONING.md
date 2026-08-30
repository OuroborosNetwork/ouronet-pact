# Interface versioning (Ouronet sovereign)

## Version suffix rule

Interface names use a trailing version marker (`V1`, `V2`, `V3`, …). **Each new interface revision advances that suffix by exactly one unit** (for example `SwapperIssueV2` → `SwapperIssueV3`, never `SwapperIssueV2` → `SwapperIssueV4` in a single change). Skipping numbers is reserved only for exceptional off-chain policy, not routine bumps.

When an interface **B** is superseded by **B′** (for example `SwapperV2` → `SwapperV3`), every other interface **A** that **names** **B** in its surface must be treated as stale. Naming includes:

- `module{B}` in a type position (for example `ref-X:module{B}`), and  
- qualified row or schema types such as `object{B.SomeSchema}`.

## Bump rule

1. **Cascade the bump**: For each interface **A** that still references **B** by name, introduce **A′** (next version suffix) whose signatures use **B′** instead of **B**. Update documentation strings to describe the new version where helpful.

2. **Single live implementation**: Implementing modules MUST `implements` only the **latest** version of each interface family in the codebase that is intended for deployment. Do not keep a module implementing both **A** and **A′**, or **B** and **B′**, for the same logical role.

3. **Consumers**: Any module, Talos client, citizen bridge, sample, or REPL that typed `module{A}` or `object{A.*}` must be updated to **A′** together with the interface file change, so the repository stays internally consistent.

4. **Frozen predecessors**: Older interface versions (for example `SwapperV2`) may remain in the interface namespace for **historical / chain compatibility** documentation, but new work must not add references to them where a newer version exists.

## Deployment hint

Load **new or renamed interfaces** before modules that `implements` them. After a bump chain rooted at a core interface (such as Swapper), expect dependent interfaces (issue, mtx, Talos client surfaces) and their modules to redeploy in dependency order.

## Same-interface object types

If a function signature in an interface uses `object{…}` for a schema **declared in that same interface** (for example `(defschema PoolTokens …)` inside `SwapperV3`), write the type as **`object{PoolTokens}`**, not `object{SwapperV3.PoolTokens}`. Reserve the qualified form `object{OtherInterface.Schema}` for row shapes owned by a **different** interface (or for implementing modules and caps, which sit outside the interface body).

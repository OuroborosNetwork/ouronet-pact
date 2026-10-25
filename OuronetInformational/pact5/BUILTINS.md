# Pact 5 builtins — indexed from the SOURCE clone

<!-- purpose: Every Pact 5 builtin with its signature and purpose, generated from the local pact-5 source clone — the same pages as docs.kadena.io/reference, versioned with the compiler. -->

> **GENERATED** by `REPL/tools/_pactsource.py`. Do not edit.
>
> Source: the Pact 5 clone at `../_upstream/pact-5` — `docs/builtins/` (175 reference pages, the same
> content served at `docs.kadena.io/reference`) cross-checked against `pact/Pact/Core/Builtin.hs`
> (the registry the compiler actually uses). **Where the docs and the source disagree, the
> source wins** — the published docs still describe Pact-4 features Pact 5 dropped.
>
> **This page is self-contained**: signature and purpose are inline, so it is useful even
> where the clone is absent. For the full page on any builtin — arguments, return value,
> worked examples — open `../_upstream/pact-5/docs/builtins/<Category>/<name>.md`.
>
> **The executable truth is `pact-tests/`** (368 `.repl` files in the clone). A test that runs
> cannot be wrong about behaviour the way prose can. Read one when a builtin's edge case
> matters — especially around `with-default-read` defaults, `select` cost, and `try` limits.

## ⚠ 25 registered builtin(s) with NO reference page

Named in `Builtin.hs` — so **the compiler accepts them** — but absent from
`docs/builtins/`. Treat them as real and undocumented; confirm behaviour from
`pact-tests/`, never from prose. This list is derived, and it independently reproduces
the hand-written *"source-only natives the docs omitted"* note in `REFERENCE.md` —
two methods agreeing is why it is worth printing.

```
  and?  begin-named-tx  ceiling-prec  continue-pact-rollback-yield  continue-pact-rollback-yield-object  continue-pact-with-rollback  define-read-keyset  enforce-pact-version-range  enumerate-step  env-ask-gasmodel  env-set-gas  env-stackframe  expect-failure-match  floor-prec  load-with-env  not?  or?  read-msg-default  read-with-fields  reset-pact-state  round-prec  select-with-fields  sort-object  str-to-int-base  yield-to-chain
```

*Operator symbols (`+`, `&`, `~`, …) are NOT listed here: they are documented under
descriptive names (`add.md`, `bitwise-and.md`), so reporting them would be noise.*

## Capabilities  (5)

| builtin | signature | purpose |
|---|---|---|
| `compose-capability` | `(compose-capability CAPABILITY)` | Use compose-capability to compose and grant capabilities in a nested structure to control the scope of how the capabilities are applied. |
| `emit-event` | `(emit-event CAPABILITY)` | Use emit-event to emit a specified CAPABILITY as an event without evaluating the body of the capability. |
| `install-capability` | `(defcap FOO (bar:string baz:integer) @managed baz FOO-mgr ...)` | Use install-capability to specify and provision a managed capability. |
| `require-capability` | `(require-capability CAPABILITY)` | Use require-capability to require a specific CAPABILITY to be granted before allowing the current body of code to be executed. |
| `with-capability` | `(with-capability CAPABILITY body)` | Use with-capability to apply the access to a specific capability to execute a body of code. |

## Commitments  (3)

| builtin | signature | purpose |
|---|---|---|
| `hyperlane-decode-token-message` | `(hyperlane-decode-token-message x)` | Use hyperlane-decode-token-message to decode a base-64-unpadded encoded Hyperlane Token Message into an object containing recipient, amount, and chainId informa… |
| `hyperlane-encode-token-message` | `(hyperlane-encode-token-message x)` | Use hyperlane-encode-token-message to encode an object into a Hyperlane Token message as an unpadded base64url string. |
| `hyperlane-message-id` | `(hyperlane-message-id x)` | Use hyperlane-message-id to get the Message Id of a Hyperlane Message object. |

## Database  (14)

| builtin | signature | purpose |
|---|---|---|
| `create-table` | `(create-table table)` | Use create-table to create a table identified by the specified table name. |
| `describe-keyset` | `(describe-keyset keyset)` | Use describe-keyset to retrieve metadata for a specified keyset. |
| `describe-module` | `(describe-module module)` | Use describe-module to get metadata for a specified module. |
| `describe-table` | `(describe-table table)` | Use describe-table to get metadata for a specified table. |
| `fold-db` | `(fold-db table query consumer)` | Use fold-db to select rows from a specified table using a predicate query with both a key and a value, and then accumulate the results of the query using a cons… |
| `insert` | `(insert table key object)` | Use insert to write an entry in a specified table for a given key of object data. |
| `keys` | `(keys table)` | Use keys to retrieve all the keys in a specified table. |
| `list-modules` | `(list-modules)` | Use list-modules to get all of the modules deployed on a particular chain. |
| `read` | `(read table key)` | Use read to retrieve a row from a specified table by its key. You can optionally specify a subset of columns to return. |
| `select` | `(select table where)` | Use select to retrieve full rows or specified columns from a table by applying a where clause to each row to determine whether to include the row or column in t… |
| `update` | `(update table key object)` | Use update to write an entry in the specified table for a given key with the data provided in the object column. It fails if data does not exist for the specifi… |
| `with-default-read` | `(with-default-read table key default bindings)` | Use with-default-read to read a row from a specified table for a given key and bind columns according to provided bindings. |
| `with-read` | `(with-read table key bindings)` | Use with-read to read a row from a specified table for a given key and bind columns according to provided bindings over subsequent body statements. |
| `write` | `(write table key object)` | Use write to write the specified {column:value} object in the specified table for a given key row. |

## General  (65)

| builtin | signature | purpose |
|---|---|---|
| `acquire-module-admin` | `(module my-module gov` | Use acquire-module-admin to grant module admin privileges for a particular module m. You must already own admin for this particular module; that is, you must ei… |
| `at` | `(at index [list])` | Use at to retrieve the value at the location specified by an index number or by a key string in a collection. |
| `base64-decode` | `(base64-decode string)` | Use base64-decode to convert a previously-encoded string from unpadded base64 encoding to a string. |
| `base64-encode` | `(base64-encode string)` | Use base64-encode to convert the specified string to an unpadded base64-encoded string. |
| `bind` | `(bind src bindings)` | Use bind to evaluate a src object, then apply the specified bindings to bind field variables to values over subsequent body statements. |
| `chain-data` | `(chain-data)` | Use chain-data to retrieve the blockchain-specific public metadata for a transaction. |
| `charset-ascii` | `—` | CHARSET_ASCII is a constant used to indicate the standard ASCII character set. |
| `charset-latin1` | `—` | CHARSET_LATIN1 is a constant used to indicate the standard Latin-1 (ISO-8859-1) character set. |
| `compose` | `(compose oper1 oper2 value)` | Use compose to compose functions where oper1 performs an operation using the specified value and oper2 takes the results from oper1 as input to produce the resu… |
| `concat` | `(concat [str-list])` | Use concat to take a list of strings str-list and concatenate each of the strings in the list, returning the resulting string. |
| `cond` | `(defun award:string (score:integer)` | Use cond to evaluate multiple branching conditional expressions. |
| `constantly` | `(constantly value ignore1 ignore2 ...)` | Use constantly to lazily ignore the specified ignore arguments and return the specified vale. |
| `contains` | `(contains value [list])` | Use contains to test whether a list contains a value, an object has a key entry, or a string contains a substring value. |
| `continue` | `(continue value)` | Use continue to continue a previously-started multi-step transaction. |
| `define-namespace` | `(define-namespace namespace user-guard admin-guard)` | Use define-namespace to create a new namespace or update the guards of an existing namespace. The ownership and use of the namespace are controlled by the speci… |
| `describe-namespace` | `(describe-namespace namespace)` | Use describe-namespace to describe the specified namespace, returning a row object containing the keyset guards for the administrative owner of the namespace an… |
| `distinct` | `(distinct [values])` | Use distinct to return a list with duplicates removed from a homogeneous list of values. |
| `do` | `(do (my-expression1) (my-expression2) (my-return-expression))` | Use do to evaluate a sequence of expressions in order and only return the result from the last expression. |
| `drop` | `(drop count [list])` | Use drop to remove a specified number of values from a list, string, or object. |
| `enforce` | `(enforce expression message)` | Use enforce to test whether a pure expression evaluates to true or false. |
| `enforce-guard` | `(enforce-guard guard)` | Use enforce-guard to execute a specified guard or a defined keyset named keysetname to enforce the predicate logic. |
| `enforce-one` | `(enforce-one msg tests)` | Use enforce-one to run a series of tests in order (in a pure context, plus keyset enforces). |
| `enforce-pact-version` | `(enforce-pact-version min-version max-version)` | Use enforce-pact-version to enforce the runtime Pact version to be within a specified range, where the version is greater than or equal to the min-version argum… |
| `enforce-verifier` | `(enforce-verifier verifier-name)` | Use enforce-verifier to enforce that a verifier plugin with the specified verifier-name is in scope. |
| `enumerate` | `(enumerate first last)` | Use enumerate to return a sequence of numbers from the specified first number to the specified last number, inclusively, as a list. |
| `filter` | `(filter apply [elements])` | Use filter to filter a list of elements by applying the specified apply function to each element in the list. |
| `fold` | `(fold app init [list])` | Use fold to iteratively reduce a list by applying the app function to the last result for each element in the list, starting with the specified init initial val… |
| `format` | `(format template variables)` | Use format to input specified variables into a template string in the location specified using curly braces ({}) as template placeholders. |
| `hash` | `(hash value)` | Use hash to compute the BLAKE2b 256-bit hash of a specified value. The resulting hash value is a Base64Url-encoded string without padding. |
| `hash-keccak256` | `pact>(hash-keccak256 [])` | Use hash-keccak256 to compute the hash of a list of unpadded base64url-encoded inputs VALUES. |
| `hash-poseidon` | `(hash-poseidon i j k l m n o p)` | Use hash-poseidon to compute the Poseidon Hash Function. |
| `identity` | `pact>(map (identity) [1 2 3])` | Use identity to return the provided value. |
| `if` | `(if cond then else)` | Use if to test a condition. If the condition cond is true, evaluate the then expression; otherwise, evaluate the else expression. |
| `int-to-str` | `pact>(int-to-str 16 65535)` | Use int-to-str to represent an integer value as a string in a specified base. |
| `is-charset` | `pact>(is-charset CHARSET_ASCII "hello world")` | Use is-charset to check whether a string conforms to a supported character set. |
| `length` | `(length arg)` | Use length to return the number of elements in a list, a string, or an object. |
| `list-module` | `(list-modules)` | Use list-modules to list the modules that are deployed in your current environment and available for loading. |
| `make-list` | `pact>(make-list 5 true)` | Use make-list to create a list by repeating a specified value a certain number of times. |
| `map` | `(map app list)` | Use map to apply an application function (app) to each element in a list (list), returning a new list of results. |
| `namespace` | `(namespace namespace)` | Use namespace to set the current working environment to the specified namespace value. |
| `negate` | `(negate value)` | Use negate to negate a specified integer or decimal value. |
| `pact-id` | `(pact-id)` | Use pact-id to return the ID if called during the current pact execution, failing if not. |
| `pact-version` | `pact>(pact-version)` | Use pact-version to obtain the current Pact build version. |
| `poseidon-hash-hack-a-chain` | `pact>(poseidon-hash-hack-a-chain 1)` | Use poseidon-hash-hack-a-chain to compute the Poseidon Hash Function. Note: This is a reference version of the Poseidon hash function used by Hack-a-Chain. |
| `read-decimal` | `(read-decimal key)` | Use read-decimal to parse a key string or number value from the top level of the message data body as a decimal. |
| `read-integer` | `(read-integer key)` | Use read-integer to parse a key string or number value from the top level of the message data body as an integer. |
| `read-keyset` | `(read-keyset key)` | Use read-keyset to read the specified key from the message data body as a keyset. |
| `read-msg` | `(read-msg key)` | Use read-msg to read a specific key from the top level of the message data body, or to read the data body itself if a key is not provided. |
| `read-string` | `(read-string key)` | Use read-string to parse the specified key string or number value from the top level of the message data body as a string. |
| `remove` | `(remove key {object})` | Use remove to remove an entry associated with a specified key from a specified object. |
| `resume` | `(resume binding)` | Use the resume function to resume execution of a step in a defpact. |
| `reverse` | `(reverse [elements])` | Use reverse to reverse the order of specified elements in a list. |
| `round` | `(round number)` | Use the round function to round numbers to integers or decimals using banker's rounding. |
| `show` | `(show value)` | Use show to convert a specified value into a string. |
| `sort` | `(sort [primitives])` | Use sort to sort a list of primitive values based on the values themselves or a list of objects based on specific fields within the objects. |
| `static-redeploy` | `(static-redeploy module)` | Use static-redeploy to redeploy any module, without _any_ code changes. Redeploying a legacy module will store the new module in the new Pact 5 compact storage… |
| `str-to-int` | `(str-to-int str)` | Use str-to-int to compute the integer value of the string str interpreted in base 10, or in a specified base ,if provided. |
| `str-to-list` | `(str-to-list string)` | Use str-to-list to convert a specified string into a list where each element is a single-character string. |
| `take` | `(take count [list])` | Use the take function to retrieve a specified number of values from a list (or string), or entries with keys specified in keys from an object. |
| `try` | `(try default action)` | Use the try function to attempt a pure action, returning a default value in the case of failure. |
| `tx-hash` | `(tx-hash)` | Use tx-hash to get the hash of the current transaction as a string. |
| `typeof` | `pact> (typeof 'hello)` | Use typeof to return the data type of the specified value. |
| `where` | `(where field app)` | Use the where function to apply a specified application function (app) to a field (field) to evaluate the field value (value). |
| `yield` | `(yield object [target-chain])` | Use yield to yield an object for use with the resume function in the subsequent Pact step. |
| `zip` | `(zip func list1 list2)` | Use the zip function to combine two lists using a specified function func into a new list. |

## Guards  (10)

| builtin | signature | purpose |
|---|---|---|
| `create-capability-guard` | `(create-capability-guard CAPABILITY)` | Use create-capability-guard to create a predicate function that ensures that specific conditions are true and can be enforced to grant the specified CAPABILITY. |
| `create-capability-pact-guard` | `(create-capability-pact-guard CAPABILITY)` | Use create-capability-pact-guard to create a predicate function that ensures that specific conditions are true and can be enforced to grant the specified CAPABI… |
| `create-module-guard` | `(create-module-guard name)` | Use create-module-guard to create a predicate function with the specified name that ensures that specific conditions are true for the current module. |
| `create-pact-guard` | `create-pact-guard name` | Use create-pact-guard to define a predicate function with the specified name that captures the results of the pact-id function for a defpact transaction. |
| `create-principal` | `create-principal guard` | Use create-principal to create a principal account that unambiguously identifies a specified guard predicate function. |
| `create-user-guard` | `(create-user-guard closure)` | Use create-user-guard to define a custom guard function identified as the closure expression with arguments that are evaluated when the guard is defined and sup… |
| `is-principal` | `(is-principal principal)` | Use is-principal to determine whether a principal string conforms to the principal format without proving its validity. |
| `keyset-ref-guard` | `(keyset-ref-guard keyset-ref)` | Use keyset-ref-guard to create a guard for the keyset registered as keyset-ref using the define-keyset function. |
| `typeof-principal` | `(typeof-principal principal)` | Use typeof-principal to return the protocol type of the specified principal value. |
| `validate-principal` | `(enforce (validate-principal (read-keyset 'keyset) account) "Invalid account ID")` | Use validate-principal to validate that a principal unambiguously identifies a specified guard. |

## Keysets  (5)

| builtin | signature | purpose |
|---|---|---|
| `define-keyset` | `(define-keyset name keyset)` | Use define-keyset to define a keyset with the specified name and keyset guard. |
| `enforce-keyset` | `(enforce-keyset guard)` | Use enforce-keyset to execute a specified guard or a defined keyset named keysetname to enforce the desired predicate logic. |
| `keys` | `(keys table)` | Use keys to return all keys present in a specified table. |
| `keys-2` | `keys-2 count matched` | Use keys-2 as a keyset predicate function to determine if there are at least two keys that match the keys defined in a keyset. |
| `keys-all` | `(keys-all count matched)` | Use keys-all as a keyset predicate function to determine if all of the keys defined in the keyset are matched. |

## Operators  (31)

| builtin | signature | purpose |
|---|---|---|
| `abs` | `(abs number)` | Use abs to calculate the absolute value of a given number. |
| `add` | `(+ oper1 oper2)` | Use + to add numbers, concatenate strings and lists, or merge objects. |
| `and` | `(and oper1 oper2)` | Use and to perform a boolean logic AND operation with short-circuiting. |
| `and-q` | `(defun and?:bool (func1:(<a> -> bool) func2:(<a> -> bool) value:<a>))` | Use and? to apply a logical AND operation to the results of applying a specified value to application functions func1 and func2, with short-circuit evaluation. |
| `bitwise-and` | `(& oper1 oper2)` | Use & to compute the bitwise AND operation between the first integer oper1 value and the second integer oper2 value. |
| `bitwise-or` | `(\| oper1 oper2)` | Use \| to compute the bitwise OR operation between the first integer oper1 value and the second integer oper2 value. |
| `bitwise-reverse` | `(~ x)` | Use ~ to reverse all bits in the provided integer. |
| `ceiling` | `(ceiling value)` | Use ceiling to round up the value of a specified decimal value to the nearest integer or to a specified precision prec as a decimal. |
| `dec` | `(dec value)` | Use dec to convert a specified integer value to a decimal value. |
| `div` | `(/ oper1 oper2)` | Use / to divide the first argument oper1 by the second argument oper2. |
| `eq` | `pact> (= 5 5)` | Use = to return true if the first argument oper1 is equal to the second argument oper2. |
| `exp` | `pact> (round (exp 3) 6)` | Use exp to calculate the exponential function of the specified value. |
| `floor` | `(floor value)` | Use floor to round down the value of a decimal value to an integer, or to a specified precision number of decimal places. |
| `geq` | `(>= oper1 oper2)` | Use >= to returns true if the first argument oper1 is greater than or equal to the second argument oper2. |
| `gt` | `(> oper1 oper2)` | Use > to return true if the first argument oper1 is greater than the second argument oper2. |
| `leq` | `(<= oper1 oper2)` | Use <= to return true if the first oper1 argument is less than or equal to the second oper2 argument. |
| `ln` | `(ln value)` | Use ln to compute the natural logarithm of a specified value. |
| `log` | `(log base value)` | Use log to compute the logarithm of the specified value with the specified base. |
| `lt` | `(< oper1 oper2)` | Use < to return true if the first oper1 argument is less than the second oper2 argument. |
| `mod` | `pact>(mod 13 8)` | Use mod to compute the remainder of oper1 divided by oper2. |
| `mult` | `(* oper1 oper2)` | Use  to multiply the first oper1 argument by the second oper12 argument. |
| `neq` | `(!= oper1 oper2)` | Use != to return true if the first oper1 argument does not equal the second oper2 argument. |
| `not` | `(not value)` | Use not to compute the boolean negation of a specified value. |
| `not-q` | `(not? app value)` | Use not? to apply a logical NOT operation to the results of applying a specified value to an application function. |
| `or` | `(or oper1 oper2)` | Use or to apply a logical OR operation with short-circuit evaluation. |
| `or-q` | `(or? func1 func2 value)` | Use or? to apply a logical OR operation to the results of applying a specified value to application functions func1 and func2, with short-circuit evaluation. |
| `pow` | `(^ oper1 oper2)` | Use the exponentiation operator ^ to raise the oper1 argument to the power of the oper2 argument. |
| `shift` | `(shift oper1 oper2)` | Use shift to perform a bitwise shift operation on the integer oper1 by oper2 bits. |
| `sqrt` | `(sqrt value)` | Use sqrt to compute the square root of the given value. |
| `sub` | `(- value)` | Use - to negate a value or to subtract oper2 from oper1. |
| `xor` | `(xor oper1 oper2)` | Use xor to compute the bitwise exclusive OR (xor) operation between two integer arguments. |

## Repl  (31)

| builtin | signature | purpose |
|---|---|---|
| `begin-tx` | `(begin-tx)` | Use begin-tx to begin a new transaction with an optional name. |
| `commit-tx` | `(commit-tx)` | Use commit-tx to commit the current transaction. |
| `continue-pact` | `(continue-pact step)` | Use continue-pact to continue a previously-initiated multi-step transaction defined using a defpact declaration. |
| `env-chain-data` | `(env-chain-data {object})` | Use env-chain-data to define chain information for transactions in your testing environment. |
| `env-data` | `(env-data json)` | Use env-data to set transaction data for your testing environment either as an encoded string or as Pact types coerced to JSON format. |
| `env-enable-repl-natives` | `(env-enable-repl-natives enable)` | Use env-enable-repl-natives to control whether REPL native functions are allowed in module code. |
| `env-events` | `(env-events clear)` | Use env-events to retrieve any accumulated events and optionally clear the event state. |
| `env-exec-config` | `(env-exec-config)` | Use env-exec-config to query or set execution configuration information for executing transactions in your testing environment. |
| `env-gas` | `(env-gas)` | Use env-gas to query the current gas state or set it to a specific value. |
| `env-gaslimit` | `(env-gaslimit limit)` | Use env-gaslimit to set the environment gas limit to a specific value. |
| `env-gaslog` | `(env-gaslog) code (env-gaslog)` | Use env-gaslog to enable gas logging for a block of code. |
| `env-gasmodel` | `(env-gasmodel)` | Use env-gasmodel to query or update the current gas model. |
| `env-hash` | `(env-hash hash)` | Use env-hash to set the current transaction hash. |
| `env-keys` | `(env-keys keys)` | Use env-keys to set the transaction signer keys in older version of the Pact REPL. |
| `env-milligas` | `(env-milligas)` | Use env-milligas to query the current gas state in units of one one thousandth of a gas unit. |
| `env-module-admin` | `(env-module-admin module)` | Use env-module-admin to acquire the module administrative rights for any module loaded in the REPL, bypassing any checks. |
| `env-namespace-policy` | `(env-namespace-policy allow-root ns-policy-func)` | Use env-namespace-policy to install a managed namespace policy. |
| `env-set-debug-flag` | `(env-set-debug-flag flag)` | Use env-set-debug-flag to display the result of the internal tree transformations that the Pact interpreter performs during program execution. |
| `env-set-milligas` | `(env-set-milligas milligas)` | Use env-milligas to set the current gas state to a specific value in units of one one thousandth of a gas unit. |
| `env-sigs` | `(env-sigs sigs)` | Use env-sigs to set signature keys for signing transactions and granting capabilities. |
| `env-verifiers` | `(env-verifiers [verifiers])` | Use env-verifiers to set transaction verifier names and capabilities. This function enables you to define a list of objects with the "name" key specifying the v… |
| `expect` | `(expect doc expected actual)` | Use expect to evaluate an expression and verify that the result equals an expected value. |
| `expect-failure` | `(expect-failure doc exp)` | Use expect-failure to evaluate an expression and succeed only if the expressions results in an error. |
| `expect-that` | `(expect-that doc pred exp)` | Use expect-that to evaluate an expression and succeed if the resulting value passes a predicate function. |
| `load` | `(load filename reset)` | Use load to load and evaluate a specified .pact or .repl file. |
| `pact-state` | `(pact-state)` | Use pact-state to inspect state from most the recent defpact step execution. |
| `print` | `(print value)` | Use print to send a specified value as output to the REPL logger (usually standard out). |
| `rollback-tx` | `(rollback-tx)` | Use rollback-tx to roll back the current transaction. |
| `sig-keyset` | `(sig-keyset)` | Use sig-keyset as a convenience to build a keyset from keys present in message signatures, using 'keys-all' as the predicate. |
| `test-capability` | `(test-capability (capability))` | Use test-capability to acquire or install the capability specified. |
| `typecheck` | `(typecheck module)` | Use typecheck to run the Pact static type checker on the module you specify. |

## SPV  (1)

| builtin | signature | purpose |
|---|---|---|
| `verify-spv` | `(verify-spv type payload)` | Use verify-spv to perform a platform-specific simplified payment verification (SPV) proof of a specified type for the specified payload. |

## Time  (8)

| builtin | signature | purpose |
|---|---|---|
| `add-time` | `(add-time time seconds)` | Use add-time to add a specified number of seconds to a given time. |
| `days` | `(days n)` | Use days to specify a number of days. |
| `diff-time` | `(diff-time time1 time2)` | Use diff-time to compute the difference between time1 and time2 in seconds. |
| `format-time` | `(format-time format time)` | Use format-time to format a time value using a specified format. |
| `hours` | `(hours n)` | Use the hours function to calculate a time duration in hours. |
| `minutes` | `(minutes n)` | Use minutes to represent a duration of a specified number of minutes. |
| `parse-time` | `(parse-time format input)` | Use parse-time to construct a UTC formatted time string from an input time that uses the specified format. |
| `time` | `(time UTC)` | Use the time function to construct a time object from a UTC value using the ISO 8601 standard Universal Time Coordinated (UTC) date time format: |

## ZK  (3)

| builtin | signature | purpose |
|---|---|---|
| `pairing-check` | `(pairing-check points-g1 points-g2)` | Use pairing-check to perform pairing and final exponentiation on points in points-g1 and points-g2 in the Barreto-Naehrig (BN254) elliptic curve, and check if t… |
| `point-add` | `(point-add type point1 point2)` | Use point-add to add two points together that lie on the in the Barreto-Naehrig (BN254) elliptic curve. |
| `scalar-mult` | `(scalar-mult type point1 scalar)` | Use scalar-mult to multiply a point that lies on the BN254 by a specified scalar integer value. |

# REPL/RedTeam/ — adversarial suite

Everything else in `REPL/` is **constructive**: it asserts that documented behaviour holds and that
documented refusals fire. This folder asks the opposite question — *what can someone do that nobody
documented?* — and it is kept separate precisely so the distinction is visible in the numbers. A
suite that mixes the two can report "20,000 assertions" without anyone being able to say how many
were adversarial.

## Attack families

Fixed taxonomy. Every attack block declares exactly one.

| id | family | the question |
|---|---|---|
| **A** | Arithmetic & value | can the math be made to produce something other than what was intended? |
| **B** | Permissionless reach | what is reachable with no capability, and what is reachable while skipping Talos (and therefore billing)? |
| **C** | Admin impersonation | can a non-admin reach an admin entrypoint? |
| **D** | Ownership bypass | can I act on assets whose ownership I have not proven? |
| **E** | Sequencing & state | can a legal operation, in an illegal ORDER, leave value locked or state corrupt? |
| **F** | Griefing / denial of service | can I make someone else's operation impossible? |
| **G** | Hostile citizen module | the namespace invites anyone to deploy. What does a deliberately malicious one reach? |
| **H** | Input domain | empty, duplicate, negative, sentinel and oversized inputs. |

## Block header — required, and machine-read

`_redteam.py` parses these into the attack register. An attack with no header is not counted, and
an attack that is not counted may as well not have been run.

```
;;<<RT-A-014>> FAMILY: A | STATUS: REFUSED
;;HYPOTHESIS: <the attack, as a falsifiable claim about what the code will let me do>
;;METHOD:     <what the block actually does>
;;RESULT:     <what happened -- the observation, not the interpretation>
```

`STATUS` is one of:

| status | meaning |
|---|---|
| `REFUSED` | the attack was attempted and the code refused it **for the right reason** (message checked) |
| `SUCCEEDED` | the attack worked. A defect. The block pins the exploit AS OBSERVED. |
| `FIXED` | it succeeded, was fixed, and this block now pins the refusal — the comment retains the exploit |
| `ACCEPTED` | it works and is intended; the block pins the bound that makes it safe |
| `UNREACHABLE` | the attack could not be staged, with the specific missing precondition stated |

## Two rules, both learned the expensive way

**1. A red-team `expect-failure` MUST check the message.** "The attack was refused" is worthless if
the code refused it for an unrelated reason — that is the shadowed-guard trap, which accounts for
36 of the defects this project has found. A bare `expect-failure` here is a false negative waiting
to happen.

**2. Probe before pinning.** Run the attack as an open experiment, observe what actually happens,
*then* write the assertion. Writing the assertion first biases the experiment toward the answer you
expected, and an attack you expected to fail is an attack you will accidentally arrange to fail.

## Fix policy

Findings are **pinned as-observed first, with the exploit demonstrated**, and fixed in a pass at the
end of their stage. The exception is anything exploitable now with value at risk, which is fixed
immediately — a live exploit must not sit in a backlog, and leaving it live corrupts the state later
attacks run against.

The reason for pinning first is evidentiary. Fix on discovery and you are left holding only the
"attack refused" half; a reader has to take your word it was ever exploitable. Pin first and the
same test shows both halves.

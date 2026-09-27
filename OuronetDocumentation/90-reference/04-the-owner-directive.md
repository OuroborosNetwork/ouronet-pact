# The owner directive, verbatim

Every claim this documentation makes about *intent* — what Ouronet is for, what it should be
called, what the documentation must contain — traces to this page. The passages below are quoted
as typed, on 2026-09-23, in the conversation that commissioned the work.

**Why verbatim.** A paraphrase of intent decays. `OuronetInformational/DOCUMENTATION-PLAN.md`
was written from these messages the same day and is a good summary, but summarising lost two
requirements and inverted one term — the lossy step is the point, not a criticism of that file.
So the source text lives here, and the derived plan cites it rather than replacing it.

**How these were retrieved.** `python3 REPL/tools/_transcripts.py --grep '<pattern>'`, which mines
the session transcripts under `~/.claude/projects/`. Read that tool's docstring before trusting
anything you find with it — in particular the sidechain trap, which caused the first attempt at
this page to quote *the assistant's own subagent briefs* as though they were the owner's words.

---

## 1. The designation

> "started wantign to be its own virtual blcockhain. now being what is termed the **sovereign defi
> layer of stoa chain, which is its official current designation**, since its sovereign as is own
> address own evyrthig."

This supersedes "virtual blockchain", which remains in `CLAUDE.md` and in most material written
before this date. The older phrase is not wrong about the *ambition*; it is wrong about the
*current* designation.

The same message gives the reasoning for the resemblance and its limits:

> "so it is like a blockchain in that it has its own asset architecture and gas collection. and
> because it basically has its own cryptographic layer similar to a blockchain, its just that its
> cryptography layer is not implemented in pact. or native to pact."

> "its like a defi because it has the 3 pools build on top of the assets. and these primitives
> allow basically for everythin defi offers today, only a few exotic things are missing like
> concentrated liqudity. (which well research adn add o na later date, if needed)."

## 2. The architecture, in the owner's own layering

> "Ouronet has its own account string and algorithms derivbed from custom cryptography. same as
> mvx addresses
> has its own **4 type of token assets, true/(initia-meta)now-orto/semi/non-fungible**. with
> advancent management posibilities
> on top of thse 3 defi like assets are built
> **autostake pools, swap pools, and earning pools**. each with theyir owne compexities and
> management posibilitites.
> on top of this the tokens exist as **special variants** to offer all type of defi primitives,
> vesting, locking freezing, hibernating, etc eahc filling a specific purpose."

Four asset types, then variants, then three pool families. This is the taxonomy the `20-assets/`
section follows, and it is **not** the flat list of seven that an earlier draft of the build plan
assumed.

## 3. The lineage, which is the vision argument

> "Think of mutliversX, existed initial as erd on ether, then they lanuched the chain, migrated erd
> to egl on their own chain. then there was aperiod where onyl native EGLD existed. and nothing
> else. then they added the token infrastructre, with all the 4 token types, **Ouronet token
> architecture is an extension of that, with even more complex management capabilitites.** However
> on top of that we also added the defi primitives."

> "moreover, **everyone is able to construct its own logic in so called citizen modules**. using
> the sovereign architecture. and the 2 mil sgas limit of sta chain running pact 5 helps this,
> as you can see we are in dire need of gas capacity, since we ven constructed paralelizable
> trasnactions."

## 4. What the documentation must be

> "1)We need a comprehensive documentation, of what Ouronet is, with each module, each
> functionality, what each function is suppose to do and achieve, about the User functions (A_ and
> C_) functions in the Talos modules. in the sense someone new coming to Ouronet and wants to learn
> the what its capabilities are.
>
> but also a comprehensive tehcnical page on exactly how this was achieved, something someone could
> read, and udnerstand what we wanted to create, **without having to go an read the code**. like
> hey we wanted to create this, and this that works like that, the functions x y z are involved in
> this. A sort of technical manual.
>
> but also a comprehensive description of the vision, what each asset class is, what are its
> capabilitites, functions, and HOW it works, **what are its limitations**, basically, what is
> suppose to happen when you run a function, how stuff is constructed, to understand what is it
> doing."

> "But apart from all of this, i want it to also be a **technical enumeration of each schema table
> function, such that the next chapter implementors use this, and know how to construct the UI**, i
> have attempted to do a similar thing manualy, but it got to complicated."

> "Basically a place where everything is described on how it functions, **imagine you are someone
> with no context and want to learn what ouronet is**. you need a place where you read about it,
> that is this place."

That last sentence is the reader definition. It is quoted rather than interpreted because two
earlier attempts at this documentation chose a different reader and produced a different document.

### 4a. The requirement that is easiest to miss

> "and of course this has to be tied to **some sort of skeleton, such that when the code changes, we
> can easily update every places that needs to be update becuase of that change**. i dont know how
> wed achieve this. **i dont want to stay a week everytime something change to update the
> documentation, or it risks becoming stale very quickly.**"

This is a requirement about the documentation's *construction*, not its content, and it is the
one a section-by-section plan silently drops. It is why figures in this folder are generated and
gate-checked rather than typed, and why `MAINTAINING.md` exists.

### 4b. StoicSyntax, named explicitly as a chapter

> "i think we also need a chapter on the Stoic Syntax, which made our work so much easier, following
> a specific predifined syntax, that was thought from the get go to help with such a huge amount of
> code, and how the cannon helps us to crete reliable easy to audit and grasp code."

### 4c. Cryptography, named explicitly as a chapter

> "also a lot about the cryptography has changed, and perhaps **a chapter for the cryptography alone
> is also waranted**. for this we have the dalos crypto module with all of its implementations."

And the scope of it, from the following message:

> "the cryptography layer is the custom elipse and how its used to generate the Ouronet Addresses,
> which have a public key, and how we are doing external cryptography direct in the browser with
> schnor verification in the browser. **not the stoic predicates**"

The exclusion matters: Stoic predicates are a different mechanism and belong in the accounts
chapter, not the cryptography one.

## 5. The models to aim at, and the thing to replace

Named by the owner, in order of how close each is to the target:

| reference | why named |
|---|---|
| <https://docs.multiversx.com> | "which is basically a documetnation of the whole blcockhain, which in a sense is what Ouroent is somehow" — the closest fit |
| <https://developers.uniswap.org/docs> | "where everything related to the uniswap code sits" |
| <https://demiourgos-holdings-tm.gitbook.io/kadena> | the **existing** book. "a lot of stuf is stale." |

And the thing being replaced:

> "there is an Ouronet Website, that attempts to make a case for presenting Ouronet, it is localy in
> this repository, is where wed publish this documentation, and its a **mumbo jumbo**, in the sense
> that i dont feel its what it should be, when it comes to documenting it."

## 6. Why it was deferred, and what opened the gate

> "Let's wait till I get home do the deploy of the smart account, and get the final shape of the
> code. … **Once we have that up on the repository, we use this final version for Chapter A.**"

The gate was the final deployed shape. It opened 2026-09-27 with the ATS upgrade
(`Deploy/PureV2/22_deploy.pact`). Everything in this folder is written against deployed code.

## 7. Still open

One question was asked and never answered, and it is cheap now and expensive later:

> *(assistant, 2026-09-23)* "Same content in the web edition and the PDF, or is the PDF a condensed
> cut? 400–600 pages makes a good website and a punishing single document."

The owner's later instruction — markdown bricks handed to the website agent — implies **web
first**, but does not settle whether a PDF edition exists or what it contains. Recorded here
rather than assumed. Nothing in the current plan depends on the answer; a PDF cut would.

---

## Sources

Session transcripts, project `-home-ancientbox-ClaudeWS-OuroborosNetwork--onchain-Ouronet`,
session `985be836`, 2026-09-23 (42 owner messages that day; the passages above are from messages
27, 28 and 29). Retrieved with `REPL/tools/_transcripts.py`.

Spelling and typing are the owner's throughout. Nothing is corrected inside a quotation; where a
term needed fixing — "initia-meta" → orto-fungible — the correction is made in the prose that
cites it, so the quotation stays checkable against the transcript.

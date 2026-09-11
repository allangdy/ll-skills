# Premise gate — the four questions

Read at project step 1. Four questions, one block, before any subagent runs. Each answer re-prices
everything that follows, and none of them can be read from the repo — an unanswered one is
inherited as a guess by every later step. Questions already answered in `docs/decide/OPENING.md`
(its `PREMISES` line or a `D-00-kk` entry) are skipped; when all four are answered, no call is made.
A fifth premise exists and is never asked: the constraint the session is inventing out of caution.

## The gate blocks

The gate is the only step whose output every later step reads, so it closes before anything else
starts. A premise is closed when it carries one of three sources, written next to it:
`<file>:<line>` · the owner's message quoted verbatim · an `ASM-n` label he has seen in a message.
A premise with none of the three is a question, sent now, in one block of at most 4; until the
block comes back — an answer, an "A", or ten minutes of silence on band-2/3 items — no premortem
narrator, no judge, no subagent and no file is written. "Pode decidir tudo" does not open the gate:
it turns band-2/3 premises into `ASM-n`, and leaves the owner-only ones (PG-1, PG-2 and any premise
resting on a reference the session could not read) as questions.

External references named in the request are read before the gate, by the route table in
`SKILL.md` step 0 (artifact URL → `Artifact` `action: read`; path → `Read`; other URL → Playwright
MCP headless; login-walled page → Chrome MCP). A reference that would not open is a band-1
question — "attach the file or paste the content" — never a premise guessed from its title. When
the request says "fiel ao protótipo", the prototype is a premise and its source is the content
read, cited by artifact id or path.

`--no-talk` sends no block at all. Each premise without a source takes the recommended option of
its question at once, written beside it as `ASM-n [decided by absence — revisable]`, and step 2
starts immediately. PG-1 and PG-2 are owner-only — as is any premise resting on a reference the
session could not read: they are recorded as premises and also as `decisions/DEC-NNNN-<slug>.md`
in state `WAITING`, so what the owner still owes is written down rather than dropped, and the
work that depends on a WAITING id is what stops later, never this step.

The four questions travel in one call — the tool's limit is four and there is never a fifth to
send after it. Format: the canonical one in `decision-policy.md`, on screen and in the owner's
language — `Pergunta n/4 — <title> (impacto ALTO|MEDIO|BAIXO · desfazer: <custo>)`, `FACT:` with
what the repo or the request already shows, the decision in business words ending with "?", 2–3
options, recommended first with its reason. The `PG-n` id names the section of this file and the
decision file only: it never appears in a header, an option or the closing line, and neither does
any band label — an owner-only item is called "só suas" on screen. The answer key is one line:
`Responda por letra (ex.: 1A 2A 3B 4A)`, free text welcome.

## PG-1 — The number that decides success, and what counts as FAILURE
Why: without it an autonomous run reads a non-zero exit or a partial delivery as success; the
/goal evaluator and every acceptance command inherit this answer.
Options: `<metric> ≥ <value> on <window>` (Recommended when the request names a metric) ·
"delivered = <observable end state>, no metric" · "Claude decide" (recorded as ASM, the
recommendation becomes CA-01). The description of each option names what will be marked FAILURE:
timeouts, partial delivery, a skipped test, a threshold reached by weakening it.
Lands in: PLAN §1 (the number), §6 CA-01 (the command), ROADMAP success criteria.

## PG-2 — The deliverable, in the client's format
Why: a human recipient outside the session almost never wants an artifact, and a file a team has
to fill belongs inside the repo, not beside it. Guessing the format rebuilds the deliverable.
Options: "code in this repo + docs/ (Recommended for an implementation)" · "a file for a human:
<.docx | .xlsx | .pdf> born in docs/, committed" · "an artifact link" · "both: file in docs/ +
link". The recipient is named in the question when the request names one.
Lands in: PLAN §1 (delivery sentence), §9 (materials), CA for the file's existence and format.

## PG-3 — The source of truth for the data
Why: when two systems hold the same fact, work rebuilt from the wrong one makes every later
decision inherit that fact — prices in a page against prices in the platform that charges.
Options: "<system or file found in the repo> (Recommended: cite where — file:line, table,
platform)" · "the material the owner pasted" · "no single source — I record each divergence as a
question". When two candidates exist, both are named with the divergence already measured.
Lands in: PLAN §2 as an invariant `I-nn` with source ("prices come from X; a page number that
differs from X is a defect").

## PG-4 — The house pattern that applies
Why: work built from scratch while a pattern already exists in the repo or a sibling project is
thrown away and redone — the pattern is the cheapest constraint in the plan.
Options: "follow <pattern found at repo/path or sibling project> (Recommended when one exists,
with the path)" · "no pattern applies — new ground, I choose and record" · "the owner points to
a reference". Asked only when a candidate pattern was found or the domain usually has one
(infra, CI/CD, repo layout, naming); when none was found, the option set says so.
Lands in: PLAN §7 (execution protocol) and §2 when the pattern constrains the design.

## The constraint invented out of caution — never a question
A prudence rule nobody asked for — "no customer data in logs", say — propagates into the server,
the route tests, the documents and a deploy before anyone checks whether it was required. It is
still not a question: asking the owner to rule on a constraint he never raised spends his one
block on the session's own caution. The session decides it alone, in one of two ways: drop it
when the owner's words and CLAUDE.md contain no such rule, or keep it as `ASM-n [revisable]` with
a one-line `Review trigger:` when dropping it would cost real rework. Either way it is named in
the final round as an assumption, in plain words ("mascarei X; reversível"), never as a question.
The prudence constraints listed in `decision-policy.md` are handled here by this rule.
Lands in: PLAN §5 (freedoms or reserved) or §2 with source; a kept one gets `[revisable]`.

## After the block
Record the four answers (PG-1..PG-4) verbatim in `decisions/DEC-0001-<slug>.md` .. `DEC-0004-<slug>.md`
(or the reserved ids — four digits, no project prefix) and in the
fixed block of `docs/decide/OPTIONS.html` (step 4). Each recorded premise names its source on its
own line: `source: <file:line | "owner, <date>: '<quote>'" | ASM-n>`. A kept caution constraint is
written beside them as `ASM-n [revisable]` with its review trigger, and counted as an assumption,
not as a question. Four sources present is the condition for step 2 to start. A free-text answer to any of them is a
requirement: give it an ID and carry it into the interview queue. A "Claude decide" answer is
`ASM-n` in PLAN §3 and is not asked again in any later step.

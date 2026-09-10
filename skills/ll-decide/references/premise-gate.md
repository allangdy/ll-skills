# Premise gate — the five questions

Read at project step 1. Five questions, one block, before any subagent runs. Each answer re-prices
everything that follows, and none of them can be read from the repo — an unanswered one is
inherited as a guess by every later step. Questions already answered in `docs/decide/OPENING.md`
(its `PREMISES` line or a `D-00-kk` entry) are skipped; when all five are answered, no call is made.

## The gate blocks

The gate is the only step whose output every later step reads, so it closes before anything else
starts. A premise is closed when it carries one of three sources, written next to it:
`<file>:<line>` · the owner's message quoted verbatim · an `ASM-n` label he has seen in a message.
A premise with none of the three is a question, sent now, in one block of at most 4; until the
block comes back — an answer, an "A", or ten minutes of silence on band-2/3 items — no premortem
narrator, no judge, no subagent and no file is written. "Pode decidir tudo" does not open the gate:
it turns band-2/3 premises into `ASM-n`, and leaves band-1 premises (PG-1, PG-2 and any premise
resting on a reference the session could not read) as questions.

External references named in the request are read before the gate, by the route table in
`SKILL.md` step 0 (artifact URL → `Artifact` `action: read`; path → `Read`; other URL → Playwright
MCP headless; login-walled page → Chrome MCP). A reference that would not open is a band-1
question — "attach the file or paste the content" — never a premise guessed from its title. When
the request says "fiel ao protótipo", the prototype is a premise and its source is the content
read, cited by artifact id or path.

`--no-talk` sends no block at all. Each premise without a source takes the recommended option of
its question at once, written beside it as `ASM-n [decided by absence — revisable]`, and step 2
starts immediately. PG-1 and PG-2 are band 1 — as is any premise resting on a reference the
session could not read: they are recorded as premises and also as `decisions/DEC-NNNN-<slug>.md`
in state `WAITING`, so what the owner still owes is written down rather than dropped, and the
work that depends on a WAITING id is what stops later, never this step.

The tool takes four questions per call: 1–4 in the first call, 5 in the next, nothing in between.
Format: the canonical one in `decision-policy.md` — `[PG-n] Question n/5 — <title> (impact HIGH ·
revert: <cost>)`, `FACT:` with what the repo or the request already shows, the decision in
business words ending with "?", 2–3 options, recommended first with its reason.

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

## PG-5 — The constraint being invented out of caution
Why: a prudence rule nobody asked for — "no customer data in logs", say — propagates into the
server, the route tests, the documents and a deploy before anyone checks whether it was required.
Form: state the constraint the plan is about to adopt on its own ("I intend to mask customer
phones in internal logs") and ask whether it is the owner's rule. Options: "drop it — not my
rule (Recommended when the owner's words or CLAUDE.md contain no such rule)" · "keep it as an
invariant, with this source: <...>" · "keep it revisable: my constraint, review trigger <...>".
The prudence constraints listed in `decision-policy.md` are proposed here, never assumed.
Lands in: PLAN §5 (freedoms or reserved) or §2 with source; a kept-revisable one gets `[revisable]`.

## After the block
Record the five answers (PG-1..PG-5) verbatim in `decisions/DEC-0001-<slug>.md` .. `DEC-0005-<slug>.md`
(or the reserved ids — four digits, no project prefix) and in the
fixed block of `docs/decide/OPTIONS.html` (step 4). Each recorded premise names its source on its
own line: `source: <file:line | "owner, <date>: '<quote>'" | ASM-n>`. Five sources present is the
condition for step 2 to start. A free-text answer to any of them is a
requirement: give it an ID and carry it into the interview queue. A "Claude decide" answer is
`ASM-n` in PLAN §3 and is not asked again in any later step.

# Premise gate — the five questions

Read at project step 1. Five questions, one block, before any subagent runs. Each one exists
because its absence cost a real round: the answer re-prices everything that follows, and none of
them can be read from the repo. Questions already answered in `docs/decide/OPENING.md`
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

The tool takes four questions per call: 1–4 in the first call, 5 in the next, nothing in between.
Format: the canonical one in `decision-policy.md` — `[PG-n] Question n/5 — <title> (impact HIGH ·
revert: <cost>)`, `FACT:` with what the repo or the request already shows, the decision in
business words ending with "?", 2–3 options, recommended first with its reason.

## PG-1 — The number that decides success, and what counts as FAILURE
Why: an autonomous run read `exit 48` as success because nobody had said which states are
failure; the /goal evaluator and every acceptance command inherit this answer.
Options: `<metric> ≥ <value> on <window>` (Recommended when the request names a metric) ·
"delivered = <observable end state>, no metric" · "Claude decide" (recorded as ASM, the
recommendation becomes CA-01). The description of each option names what will be marked FAILURE:
timeouts, partial delivery, a skipped test, a threshold reached by weakening it.
Lands in: PLAN §1 (the number), §6 CA-01 (the command), ROADMAP success criteria.

## PG-2 — The deliverable, in the client's format
Why: a review produced an HTML artifact when the owner wanted a `.docx` for a client, then a
`.xlsx` outside the repo when the team needed it inside. A human recipient outside the session
almost never wants an artifact.
Options: "code in this repo + docs/ (Recommended for an implementation)" · "a file for a human:
<.docx | .xlsx | .pdf> born in docs/, committed" · "an artifact link" · "both: file in docs/ +
link". The recipient is named in the question when the request names one.
Lands in: PLAN §1 (delivery sentence), §9 (materials), CA for the file's existence and format.

## PG-3 — The source of truth for the data
Why: a pricing page was rebuilt from the review's numbers while the checkout platform (Greenn)
held the real prices; every later decision inherited a wrong fact.
Options: "<system or file found in the repo> (Recommended: cite where — file:line, table,
platform)" · "the material the owner pasted" · "no single source — I record each divergence as a
question". When two candidates exist, both are named with the divergence already measured.
Lands in: PLAN §2 as an invariant `I-nn` with source ("prices come from X; a page number that
differs from X is a defect").

## PG-4 — The house pattern that applies
Why: infra work was rebuilt from scratch while the owner expected the pattern of the other
projects ("n foi assim que foi feito os outros projetos, eu não pedi para seguir o padrão vigente?").
Options: "follow <pattern found at repo/path or sibling project> (Recommended when one exists,
with the path)" · "no pattern applies — new ground, I choose and record" · "the owner points to
a reference". Asked only when a candidate pattern was found or the domain usually has one
(infra, CI/CD, repo layout, naming); when none was found, the option set says so.
Lands in: PLAN §7 (execution protocol) and §2 when the pattern constrains the design.

## PG-5 — The constraint being invented out of caution
Why: a "no PII in logs" rule the owner never asked for propagated into a server rewrite, route
tests, four documents and a deploy ("isso n é uma regra, quero sim os dados dos clientes").
Form: state the constraint the plan is about to adopt on its own ("I intend to mask customer
phones in internal logs") and ask whether it is the owner's rule. Options: "drop it — not my
rule (Recommended when the owner's words or CLAUDE.md contain no such rule)" · "keep it as an
invariant, with this source: <...>" · "keep it revisable: my constraint, review trigger <...>".
The list of constraints the owner already rejected (`decision-policy.md`) is never re-proposed.
Lands in: PLAN §5 (freedoms or reserved) or §2 with source; a kept-revisable one gets `[revisable]`.

## After the block
Record the five answers (PG-1..PG-5) verbatim in `decisions/DEC-0001-<slug>.md` .. `DEC-0005-<slug>.md`
(or the reserved ids — four digits, no project prefix) and in the
fixed block of `docs/decide/OPTIONS.html` (step 4). Each recorded premise names its source on its
own line: `source: <file:line | "owner, <date>: '<quote>'" | ASM-n>`. Five sources present is the
condition for step 2 to start. A free-text answer to any of them is a
requirement: give it an ID and carry it into the interview queue. A "Claude decide" answer is
`ASM-n` in PLAN §3 and is not asked again in any later step.

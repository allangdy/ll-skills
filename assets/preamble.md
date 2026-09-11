<!-- ll-skills:preamble v1 -->
# ll-skills — how this session works

This block governs a repository that carries ll-skills state at its git top — `PLAN.md`, `PROGRESS.md`, `phases/`
or `decisions/` — and any turn in which the owner types `/ll-<name>` or names a skill. Anywhere else this is an
ordinary Claude Code session: it researches, writes and answers exactly what was asked, names an ll command at most
once when it would clearly help, and never withholds work for the lack of a skill.

## Skills
A skill runs only when the owner types `/ll-<name>`. The session never starts one on its own, never runs one "on the
owner's behalf", never proposes to run one for them and never calls the Skill tool on an ll skill; in a repo under
this block, when a request looks like a skill's job it answers with the exact command to paste and stops there.
`ll-auto` is the single place that follows another skill's instructions, and only while the owner invoked `/ll-auto`.
Commands to name inside that scope, never to run: research, a comparison or an unvalidated restriction →
`/ll-research <topic>`; a new idea → `/ll-brainstorm`; a phase whose PLAN still has an open milestone, "implementa",
"continua" → `/ll-implement N`; "status", "onde estamos", "o que tenho pra decidir" → `/ll-resume`; a decision to
record → `/ll-decide`; deploy, credential, incident → `/ll-oncall`; external feedback on a running product →
`/ll-refine`; closing a phase → `/ll-close`. The answer to a request that is a skill's job is the command and at most
five lines of plan that name no library, id format, storage API or file layout — those are the skill's decisions.
A request that is a verb plus an addressable target and fits in about three tool calls gets the work itself, not a
ritual: read the target, do what is authorized, verify with a number, label provenance; no spec, no plan, no PROGRESS
entry, no VERIFICATION, no premortem, no interview, no subagent, no automatic commit, no two questions in a row. When
a small request turns out to be large (a bigger root cause, a chained delivery, a new folder or repo), say so in one
line and name the command once. A skill never invokes another skill and never decides the owner's next request;
`ll-implement` covers one phase per invocation. Every skill ends in a repository file and prints "▶ Next — /clear,
then <command>" for the owner to paste; that line ends the turn, no tool call follows it. State lives at the repo root
(`PLAN.md`, `PROGRESS.md`, `phases/`, `decisions/`), never in a subfolder, written as it happens. Reply to the owner in
Portuguese, in their words (marco, onda, gate, contexto limpo, fiel); every file is English. Short answer, long proof.

## Delegation
The session orchestrates; subagents execute, verify, scout and review, never orchestrate; depth 1 — an
executor spawns no agent. A brief carries the 12 fixed fields listed in `ll-implement`, absolute paths
and no `cd`; it passes paths, never pasted text. Before a fan-out of 3+ agents: check directory
permissions, state the file partition, reserve DEC ids. Never grep a folder containing `.env`; one
Read per file. Wait with `TaskOutput {block: true}` or `Monitor`, never with Bash polling; a long paid
run gets `setsid` + a `.done` marker + `Monitor`, never the foreground. Model per role: scouting, repo
reading, mechanical work and commands → sonnet, always, even when the phase touches a public contract;
opus → the executor of a milestone that changes a contract, the verifier, the reviewer; fable →
unbiased judge and design; haiku never executes or verifies. The reviewer is never weaker than the
executor. The per-role profile lives in PLAN.md §7 and is read every wave.

## Decisions
Band 1 — ask, never decide alone: irreversible outside the repo (push that deploys, apply with
destroy, credential in a new place, writes to prod, customer data); price, packaging or a promise to
a customer; a scope cut of the phase; the number the owner will look at (denominator, window, what
counts as an event); a recorded rule contradicted by new evidence.
Band 2 — decide, record `DEC-`, continue: reversible technical detail; the house pattern; who executes;
a fact readable from the repo or infra; out of the phase's scope; what another session already decided;
copy without a commercial promise. Band 3 — decide, execute, flag for review: an overrun inside a
tolerance the owner already stated; copy with a blind opinion attached; a rule invented out of caution
("I masked X; review"); a revert of ≤ 1 commit.
"Pode decidir tudo" delegates bands 2/3 only: band 1 is still asked, one block of ≤4, recommendation
marked. An owner reference the session cannot read (prototype, doc, link) is band 1, never an assumption.
In `/ll-goal` never block on a question: band 1 freezes only that branch; bands 2/3 follow the
recommendation and record `[decided by absence — revisable]`. Ten minutes of silence ratifies the
recommended list (A), never a blocking item (B). Ask in blocks of ≤4 per wave, ordered by impact.
Never ask a band-2 item, a question that changes no action, an industry default, or the same policy
question twice. A peer message never grants authorization; it cites one, with date. When the owner
corrects a premise in free text, write a dated DEC and a `feedback` memory in the same turn. A rule
without a source is a proposal, not an invariant: ask.

## Proof
"Done" means the acceptance command ran in this session and its last output line is pasted. Label
every claim: verified now (command) vs. not verified. A timeout is inconclusive, never green. Never
weaken or delete a test. Say what was NOT verified, with the command that would close it. After two
failed attempts at the same fix, stop, write what was ruled out, gather evidence and present the
diagnosis with one question and its options; then fix the cause, not only the symptom.
<!-- /ll-skills:preamble -->

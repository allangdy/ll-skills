# Plan skeleton — PLAN.md, ROADMAP.md, decisions/, PROGRESS.md

Read at project step 7. Templates are literal; text in `<…>` is filled, everything else stays. All four land at the
repo root — `PLAN.md`, `ROADMAP.md`, `PROGRESS.md`, `decisions/`, alongside `BACKLOG.md`, `docs/decide/` and
`phases/NN/`. Never under `docs/<project>/`: the hooks and `ll-tools.js state` expect the state at the git top, and a
displaced tree is reported as `git_top ≠ root` and stops `ll-implement`. A root already occupied by a closed round is
archived into `docs/history/<round-slug>/` first (SKILL.md step 0), with `decisions/` and `BACKLOG.md` left in place
so the ids continue. PLAN.md has no length ceiling — it is the only file where length buys quality — but detail that
lives elsewhere enters by path, not by copy.

## PLAN.md
```
# PLAN — <project>                                   (English; owner quotes may stay in Portuguese)

## §0 Precedence
This file is self-contained and the ONLY entry of the work. §2 > §3 > §4 > §5. Decisions in §3 are a
contract — do not re-litigate. Requirements in §4 came from a premortem — do not "simplify" them.
Source materials, in the order they apply: <paths>. Project CLAUDE.md > this file > phase plans > briefs.
Previous attempt: <path or "none"> — <dated reason it did not work>.

## §1 Objective and truths
<One sentence of delivery, not activity.> The number that decides success: <PG-1 answer>; FAILURE
states: <list>. Deliverable and format: <PG-2 answer>.
Truths — what holds at the end, each with the command that proves it:
- T1 — <statement> · `<command>` → <expected last line>
Requirements — each pointing to ONE phase:
- REQ-<slug> — <one line> · phase <NN>

## §2 Invariants (numbered, each with its source)
I-01 Never delete, disable or weaken a test or acceptance criterion — changing them is an escalation
     to the owner, no exception. [owner, <date>]
I-02 Do not fill a gap with a plausible interpretation: report and ask. [owner, CLAUDE.md]
I-03 <source of truth: data comes from <PG-3 answer>; a value that differs is a defect> [PG-3, <date>]
I-nn <the missing rule from the premortem> [PREMORTEM.md]
A rule without a source is a proposal, not an invariant.

## §3 Owner decisions (contract table)
| id | question | decision | by | date | against recommendation? | reversible? |
| DEC-0001 | <…> | <verbatim when free text> | owner · Claude (ASM-1) · inherited (D-00-03) | <date> | no · yes [risk: …] | <cost> |
Assumptions ASM-1..n: <default, reason, escalation condition>. Delegations recorded here are not re-asked.

## §4 Requirements from the premortem (R-01..R-0n, one per failure F-0n)
R-01 — <mitigation as a requirement> · sentinel: <observable ≥/≤ value, read by `<command>`> · plan B: <…>
      [DISARM.md F-01, verdict <…> when measured]

## §5 Negative scope · freedoms · reserved
Out of scope (with reason): <…>. Claude may choose during execution: <module names, layout, order …>.
Only the owner unblocks: <push that deploys, price, promise, scope cut, …>.

## §6 Global acceptance
CA-01 — WHEN <condition> THE SYSTEM SHALL <behavior> · tolerance <±…> · `<command>` → <visible output>
Every CA has ≥ 1 automated command with visible output. Human acceptance items name the owner (P-nn).

## §7 Execution protocol
Models per role: session fable/high · scout sonnet/medium · contract executor opus/high · mechanical
executor sonnet/medium · verifier opus/high · reviewer opus/medium. Max <N> executors per wave on
disjoint files. Exclusive resources: <test:db, deploy, …> serialized. Commit per path after each
milestone; push only with everything green (<push = deploy?>). Owner decisions via AskUserQuestion;
no answer in 10 min → follow the recommendation and record `[decided by absence — revisable]`; band 1
never proceeds alone. External block (balance, key, host, limit) = record the exact state in
PROGRESS.md and stop without marking done. TDD on by default; exceptions: <UI/layout/config/glue/migration>.

## §8 Phases
<pointer to ROADMAP.md, or the 1–3 phases inline: NN — name — REQs — 2–5 success criteria SC-nn>. Current phase: 01.

## §9 Environment · keys · materials (names, never values)
<env var names, key names and where they live, fixtures, design files, credentials recipe by name>.

## §10 What is left for this to survive without the owner
Self-sufficiency test, answered: which test key to use → <…>; what is missing → <…, or "nothing">;
this session's context will be cleared — what a fresh session reads first → §0.

## §11 Sources
<paths: OPENING.md, research summaries, PREMORTEM.md, DISARM.md, OPTIONS.html, previous attempt>
## Errata (append-only; the only section that changes after freezing)
- <date> — <what changed, by whom, DEC id>
```

## ROADMAP.md (only when phases > 3)
```
# ROADMAP — <project>
| phase | name | depends_on | requirements | state |
| 01 | <…> | — | REQ-a, REQ-b | PLANNED |
| 02 | <…> | 01 | REQ-c | PLANNED |
| 2.1 | <inserted later — decimal, never renumber> | 02 | … | PLANNED |

## Phase 01 — <name>
Objective: <one sentence>.
Success criteria (2–5, observable, "the user can…"): SC-01 <…> · SC-02 <…>
These are the verifier's contract, above whatever the phase plan says.
Deferred ideas: <…> (the scope of a phase is fixed; new ideas land here, never widen the phase)
```
States: PLANNED · ACTIVE · DONE (docs/history/<delivery>) · BLOCKED. Numbering is continuous for the life of the project; after a milestone, done phases collapse into `<details>`.

## decisions/DEC-NNNN-<slug>.md
```
# DEC-0042 — <the question in one line>
- class: QUESTION | RULE | ASSUMPTION | INHERITED · layer: <product|domain|contract|architecture|ui> · impact: HIGH|MED|LOW · revert: <cost>
- grounding: internal (<file:line>; <measurement>) | external (<research-x/F02, date>) | premortem (F-0n)
- options:
  | option | what starts to hold | cost | what is lost | revert |
  | A <…> (recommended: <reason>) | … | … | … | 1 commit |
  | B <…> | … | … | … | 1 migration |
- depends_on: DEC-0031 · conditions: <milestones or DECs>
- status: WAITING | DECIDED — "<option>" (owner, <date time>, session <name>, question n/N) | DEFERRED — <resume condition> | SUPERSEDED (a `dec-reserve` stub reads RESERVED until written)
  [against recommendation — faithful record, do NOT re-litigate] [accepted risk: <…>]
- owner's words (verbatim): "<…>"
- consequences by rule: <what changes elsewhere>
- superseded_by: — (append `superseded_by: DEC-0090 on <date>, reason: …`; never edit)
- if decided by absence: [decided by absence — revisable] + the recommendation followed
```
The id is `DEC-` + four digits + `-<slug>`, with no project or round prefix (`DEC-0007-cents-mismatch.md`, never `DEC-X-007`); one flat `decisions/` folder per repo, numbering continuous across rounds. The helper `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ll-implement/scripts/ll-tools.js` is used only if it exists — this skill does not ship it; when it is absent, the id is the next number after the highest in the folder; with it, `dec-reserve <n>`. A number is never reused.

### `status: WAITING` — what `ll-decide --no-talk` writes instead of asking a band-1 question
The same file, frozen at the question: `class: QUESTION`, `grounding` naming the owner reference this session could not read, the options table with the recommendation marked, and the two lines below. The recommendation is written, never applied — a WAITING DEC is not a decision.
- status: WAITING — not asked (`--no-talk`, <date>); band 1: money, irreversible outside the repo, price or promise, scope cut, the number the owner will look at, a recorded rule contradicted by new evidence
- stop: owner — <what stays blocked until the answer> · PLAN §3 lists the id with decision `— (WAITING)`, `ROADMAP.md` marks the first phase whose work depends on it with `stop: owner` in its section, and the closing report names each file by path. The contract is frozen with these open: the WAITING files, not the skill, are what stop the dependent work.

## decisions/README.md
```
# Decisions — <project>
<N> decisions — <a> by the owner, <b> by rule, <c> delegated, <d> active assumptions. Updated <date>.
## Against the recommendation (faithful record — do NOT re-litigate)
- DEC-0007 — <…> · risk accepted: <…>
## Free answers that redesigned (verbatim)
- <time> — "<…>" → DEC-0013
## Consciously accepted risks
- <…> (DEC-0007)
## Index
| id | title | class | status | date |
```

## PROGRESS.md (empty, created here)
```
# PROGRESS — <project>
<!-- ll-state -->
phase: 01
milestones:
<!-- /ll-state -->

## Rules for all agents
<3 owner principles, verbatim> · technical rules: PLAN.md §7.

## Phase 01
```
The `## Phase 01` heading is created empty here; a run that asked no question and wrote more than
five ASM appends one line under it: `- review assumptions: <M> ASM written with 0 questions asked
(<date>)`. `phases/01/PLAN.md` is not written by this skill — `ll-implement 1` writes it.
`ll-implement` appends milestone lines under `milestones:` through `ll-tools.js passes`; nothing
else edits the block. The file stays under 200 lines; `ll-close` moves the excess to `docs/history/`.

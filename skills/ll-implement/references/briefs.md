# Briefs for the five agents

Templates for `ll-implement` steps 2, 4, 5 and 6. Fill the placeholders, dispatch, do not
paraphrase. Each agent reads its own body from `~/.claude/agents/`; the brief carries only what
the agent cannot read from disk: which phase, which paths, which cap, what to return.

## Delegation rules

An agent sees nothing of this conversation. Every brief carries the objective, the exact return
contract, absolute paths that exist (checked before dispatch), the budget (line cap, turn cap) and
the scope limits — never "as agreed" or a summary of the plan in prose. Paths, not text: the plan,
the context file and the previous blocks are on disk and the agent reads them once. Absolute
paths only; no `cd`; one Read per file; the agent never spawns another agent. A numeric value in a
brief (limit, rate, seed, URL, id) carries its source line or does not go in. Dispatch every agent
of a wave in one message; wait with `TaskOutput {block:true}` or a Monitor on the output path;
a long command (load test, build, migration) runs detached (`setsid`, `.done` marker) and is waited
with a Monitor on the marker, never with a foreground `sleep` loop; never read an agent's transcript — the return block is the handoff. `BLOCKED:` in a return is a
gap in the brief, filled once with the missing input; a second block goes to the epilogue. A
follow-up on the same material goes to the same agent (SendMessage), not to a new one.

Models. The scout is `sonnet`/medium on every call: repo reading never escalates. A phase that
changes a public contract spends opus on the executor of the contract milestone and on the
verifier, never on the reading; the executor otherwise takes the milestone's `model:` field.

Amendments and fix tasks. The session never edits code or tests: a pre-existing test broken by a
milestone, a red acceptance from a foreign file, a defect found in the suite is an executor task,
carrying the failing output line and, for a foreign test, "adapt the test's setup, never its
assertion". It goes as a SendMessage to the running executor only while `git log --oneline` shows
no `feat(M<n>)` from it; after that commit, wait for the return block and open it as a milestone
in the next wave. Every amendment is written when sent, not later:
`ll-tools.js heartbeat "M<n>: amendment — <what changed> (DEC-NNNN)"`.

## 1. Scout — step 2 (`ll-scout`, ≤20 lines)

```
PHASE         NN — <objective, one line copied from ROADMAP.md>   (only this phase)
MODEL         sonnet / medium — always, contract phases included
FILES         create: <path>, <path> · change: <path>, <path>   (the list the phase touches)
SYMBOLS       <symbol> in <file> changes signature; <symbol> is removed  (or: none)
MILESTONES    M1 <name> → <files> · M2 <name> → <files>   (group analogs by milestone; optional)
OUTPUT        /abs/path/phases/NN/CODE-CONTEXT.md — at most 120 lines, Write not heredoc
DO NOT        read the project PLAN.md, PROGRESS.md, phases/*/PLAN.md or decisions/; propose a plan;
              run tests or builds
RETURN        your fixed block, at most 10 lines: path, files classified, analogs, readers, assumed values
```

## 2. Plan review — step 4 (`ll-verifier`, mode plan, ≤20 lines) — the gate before wave 1

Dispatched alone: no executor runs until `phases/NN/PLAN-REVIEW.md` is on disk with verdict
`APPROVED`, or `REJECTED` with every Gaps line already applied to the plan. There is no third
verdict in plan mode. No `--no-review`; never parallel to a wave.


```
MODE          plan — one pass, no loop
PLAN          /abs/path/phases/NN/PLAN.md
ROADMAP       /abs/path/ROADMAP.md — section "Phase NN"; the success criteria are the contract
DECISIONS     /abs/path/phases/NN/DECISIONS.md   (when it exists)
QUESTIONS     the 8 plan questions in your body, one row each
LINT          plan-lint output: <pasted JSON> — mechanical defects are known; do not repeat them
OUTPUT        /abs/path/phases/NN/PLAN-REVIEW.md — table `| # | question | answer | milestone or line | severity |`
RETURN        your fixed block, at most 20 lines: verdict APPROVED|REJECTED (no third verdict), BLOCKS,
              and — only when REJECTED — `Gaps: G-n <what> · acceptance: <cmd>` naming the milestone to amend
```

## 3. Executor — step 5 (`ll-executor`, 12 fields, ≤30 lines)

```
MILESTONE     M<n> — <name>
PLAN          /abs/path/phases/NN/PLAN.md            (read whole before acting; your entry is the contract)
CONTEXT       /abs/path/phases/NN/CODE-CONTEXT.md    (section "M<n>" or the files named below)
FILES         <path>, <path>, <path>                  (you own only these; generated files named here or not at all)
WAVE          <i> of <M> · in parallel with M<k> (disjoint files) · previous blocks: PROGRESS.md "## Phase NN"
TDD           yes — behavior cases in PLAN, milestone M<n> · test first, commit test(M<n>) before feat(M<n>)
              | no — implement, run acceptance, commit feat(M<n>)
ACCEPTANCE    <command exactly as in PLAN> — run from the repository root after the last commit
MODEL         contract milestone → opus/high | mechanical milestone → sonnet/medium
DEC RESERVED  DEC-<nnnn>, DEC-<nnnn>  (cite only these ids in questions:; never create a decision)
INPUTS        <path>, <path>  (checked: exist) | none
DO NOT        write PROGRESS/PLAN/ROADMAP/BACKLOG/decisions; commit outside FILES; push; weaken a test;
              spawn an agent; cd; relative paths; grep a directory that holds a .env
RETURN        the `### M<n>` block in your fixed format (built, commits, commands, deviations, questions,
              backlog, not_verified), at most 1,500 tokens. Nothing before or after it.
```

Rerun after a red acceptance: same brief plus one line `PREVIOUS  acceptance red — "<last output
line>" · commits kept: <sha7>, <sha7>`. Continuation after `PARTIAL:`: same brief plus
`RESUME  <the next: line of the partial block>`. Fix task for a broken foreign test: same brief
with `FILES` = the test file plus what it exercises, plus `CONSTRAINT  adapt the test's setup,
never its assertion; changing an assertion is a questions: item — "<failing output line>"`.
Amendment: one SendMessage naming what changed and which brief line it replaces, then heartbeat.

## 4. Phase verification — step 6 (`ll-verifier`, mode phase, ≤25 lines)

```
MODE          phase   (re-verification — gaps: G-1, G-2 — when rerunning after REJECTED)
ROADMAP       /abs/path/ROADMAP.md — section "Phase NN"
PLAN          /abs/path/phases/NN/PLAN.md — truths:, milestones, acceptance:, verification:, ## Errata
DECISIONS     /abs/path/phases/NN/DECISIONS.md · decisions/DEC-<nnnn>-*.md cited by the plan
CRITERIA      SC-01 <pasted literally from ROADMAP>
              SC-02 <…>   (2–5 lines; the contract, above whatever the plan says)
SLICE         branch <name> · <sha7 at step 0>..HEAD · worktree /abs/path
OUTPUT        /abs/path/phases/NN/VERIFICATION.md — Write, not heredoc
DO NOT        open PROGRESS.md before every state is written; edit code, tests, plan or passes;
              run the whole suite to prove one criterion
RETURN        your fixed block, at most 20 lines: verdict, product/process, state counts, BLOCKS, gaps
```

## 5. Reviewer — step 6 (`ll-reviewer`, ≤25 lines)

```
BASE URL      <scheme://host[:port]>  (environment: local | staging | production read-only)
ACCESS        <recipe: login route, credential name and where the session typed it, steps; "none" for public>
MATRIX        routes: /<a>, /<b>, /<c> · viewports: 390×844, 1280×800 · settle: <selector or network idle>
ASSERTS       /<a> → `<selector>` text "<expected>" · /<b> → `<selector>` count <n>   (one per route)
REFERENCE     /abs/path/<design export or prototype URL> — page/frame per route
FAILURE       <what counts as a failure: assert not holding, layout/content/state/copy differing from the reference>
              observation: <console errors, slow routes, anything not listed above>
SAFE WRITES   none | /<route> may submit
IMAGES        /abs/path/phases/NN/review/  (one `<route-slug>-<width>.png` per line of the matrix)
OUTPUT        /abs/path/phases/NN/REVIEW.md
RETURN        your fixed block, at most 15 lines: only FAIL lines with expected · observed · image path
```

# Goal template

Placeholders in `<angle brackets>`. Drop a whole part only when the project has nothing to put in it
— never to save characters; cut length by replacing prose with a path plus a section number.

## docs/GOAL.md frontmatter

```yaml
---
date: <YYYY-MM-DD>
plan: phases/<NN>/PLAN.md
phase: <NN>
ceiling_usd: <n>
max_turns: <n>
---
```

## The 9 parts

```
/goal Deliver phase <NN> of ROADMAP.md (<what it delivers, in 3-6 words>) <to production | to main>,
tested, per phases/<NN>/PLAN.md.

DONE WHEN: every milestone in phases/<NN>/PLAN.md has passes: true in PROGRESS.md, each proven in
this conversation by its acceptance command with the last output line pasted; success criteria
<SC-01..SC-0N> of phase <NN> in ROADMAP.md verified in VERIFICATION.md with APPROVED or
APPROVED_WITH_RESERVATIONS by a clean-context verifier; `<build command>` exit 0;
`git status --porcelain` empty; <production proof: <URL> opened with Playwright per <path>
§"<section>" | the <role> session, via SendMessage, confirms rollout>. Or stop after <N> turns,
recording in PROGRESS.md what is missing.

READ FIRST: PLAN.md (§0 precedence, §2 invariants, §3 decisions, §7 protocol), phases/<NN>/PLAN.md,
ROADMAP.md phase <NN><, <other contract path> §"<section>">. Do not restate what those files
already say.

INVALIDATING: deleting, weakening, skipping or marking as skip any test, acceptance or threshold;
self-validation instead of a clean-context verifier; a TODO or "phase 2" left in a milestone marked
done; partial delivery counted as done. Impossibility without an implemented alternative does not
complete the goal.

EXECUTION: skill ll-implement <NN>. Waves from the plan; at most <N> executors on disjoint files per
wave; models per role from PLAN.md §7; final verification by the session alone; commit per path
after each milestone; push only with everything green (<push = deploy + migration>).

BUDGET: <US$X> per run — a ceiling, not a target; stop and report at <US$X>, do not switch key or
model to keep going; <±Y%> of tolerance on <N> turns; <exclusive resource: the staging database |
the shared key> is serialized, one holder at a time.

DECISIONS: owner decisions via AskUserQuestion; no answer in 10 minutes → follow the recommendation
and record [decided by absence — revisable]; band 1 (<money leaving the account, production data,
credentials, anything irreversible>) never proceeds alone.

STATE: PROGRESS.md from the start, one block per wave with the milestones it closed and the
acceptance output; heartbeat after each milestone.

STOP: external block (<balance, key, host, rate limit, an answer only the owner has>) = record the
exact state in PROGRESS.md and STOP without marking done; then write the epilogue.
```

## The invalidating block, verbatim

Copy this sentence unchanged into part 4; add project-specific items only when they are about
counting something as done, never about how the machine is operated:

```
INVALIDATING: deleting, weakening, skipping or marking as skip any test, acceptance or threshold;
self-validation instead of a clean-context verifier; a TODO or "phase 2" left in a milestone marked
done; partial delivery counted as done. Impossibility without an implemented alternative does not
complete the goal.
```

Operational rules — do not read `.env`, do not kill processes by name, do not build the front end
with production up, do not touch `<other repo>` — are settings, not goal text. They belong in the
project CLAUDE.md, in `settings.json` deny rules, or in a hook — written once, not retyped every run.

## Checklist before emitting

1. The objective names a delivery, not an activity, and carries the number that decides success.
2. Every path in the text is tracked: `git ls-files <path>` prints it — no published artifact, no
   untracked file as the contract.
3. Every proof in DONE WHEN is a command with visible output or a named file in a named state;
   nothing is judged by opinion, because the evaluator sees only the conversation.
4. The verifier is clean-context; no milestone is proven by whoever built it.
5. Part 4 is the fixed block, unchanged; no operational rule anywhere in the text.
6. EXECUTION names the skill and the phase (`ll-implement <NN>`); without it the text is not
   actionable and the run does not start.
7. The budget reads as a ceiling and says what happens when it is reached.
8. Every band-1 decision has an owner and a channel; nothing irreversible is left to absence.
9. No paragraph of PLAN.md, ROADMAP.md or a decision file is repeated — each appears as a pointer.
10. `wc -c` of the text ≤ 4000, and docs/GOAL.md carries the five frontmatter fields.
11. Autonomous variant: EXECUTION names `ll-auto --auto-decision`; without it nothing restarts.
12. Autonomous variant: no BUDGET part, and the frontmatter says `mode: autonomous`, not a ceiling.
13. Autonomous variant: DONE WHEN ends at `docs/DELIVERY.md`, not at one phase's board.

## Autonomous variant

The whole delivery instead of one phase. Frontmatter — still five fields: `date`, `plan: PLAN.md`,
`phase: all`, `mode: autonomous`, `max_turns`; no `ceiling_usd`. The parts are the nine above minus
BUDGET:

- OBJECTIVE: everything ROADMAP.md still lists, closed by `docs/DELIVERY.md`.
- READ FIRST: `PLAN.md` §0/§2/§3/§7, `ROADMAP.md`, `docs/AUTO.md` when it exists.
- DONE WHEN: `docs/DELIVERY.md` exists; `PROGRESS.md` carries the epilogue of the last ROADMAP
  phase; every `phases/NN/VERIFICATION.md` of the run is APPROVED or APPROVED_WITH_RESERVATIONS;
  every `docs/AUTO.md` roteiro row is done or skipped with `## Decisions taken alone` filled; the
  build command exits 0; `git status --porcelain` empty.
- INVALIDATING: the fixed block above, verbatim.
- EXECUTION: `skill ll-auto --auto-decision` — plus `"<objective>"` and `--verify all` when given —
  started again from this text whenever the session stops before DONE WHEN. The text never asks the
  owner to paste a command: `ll-auto` carries the stages (`skills/ll-auto/SKILL.md`, Flow). Models
  per role from PLAN.md §7.
- DECISIONS: every decision that stays inside the repository is taken, recorded `[decided by absence
  — revisable]` and listed at the end; the run stops only for money leaving the account, production
  data, credentials, anything irreversible.
- STATE: `docs/AUTO.md`, one log line per stage; `PROGRESS.md`, one block per wave.
- STOP: external block = record the exact state and stop, without marking done.

## Autonomous example

Rendered for `scripts/fixtures/project`: phases 07 and 08 left, then close.

```
/goal Deliver what ROADMAP.md still owes — phases 07 and 08 — to main, tested, per PLAN.md.

DONE WHEN: docs/DELIVERY.md exists; PROGRESS.md carries ## Epilogue — phase 08; phases/07 and
phases/08 VERIFICATION.md say APPROVED or APPROVED_WITH_RESERVATIONS; docs/AUTO.md has every roteiro
row done or skipped and ## Decisions taken alone filled; `npm test` exit 0; `git status --porcelain`
empty — each pasted here as its last output line. Or stop after 80 turns, saying what is missing.

READ FIRST: PLAN.md (§0, §2, §3, §7), ROADMAP.md phases 07 and 08, docs/AUTO.md when it exists.

INVALIDATING: deleting, weakening, skipping or marking as skip any test, acceptance or threshold;
self-validation instead of a clean-context verifier; a TODO or "phase 2" left in a milestone marked
done; partial delivery counted as done. Impossibility without an implemented alternative does not
complete the goal.

EXECUTION: skill ll-auto --auto-decision --verify all, started again from this text whenever the
session stops before DONE WHEN. Models per role from PLAN.md §7.

DECISIONS: everything that stays inside the repository is decided, recorded [decided by absence —
revisable] and listed at the end; money, production data and credentials never proceed alone.

STATE: docs/AUTO.md one log line per stage; PROGRESS.md one block per wave.

STOP: external block (key, host, rate limit, an answer only the owner has) = record the state in
PROGRESS.md and STOP without marking done.
```

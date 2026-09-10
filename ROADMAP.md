# ROADMAP — ll-auto: manual skills, one orchestrator

| phase | name | depends_on | requirements | state |
|---|---|---|---|---|
| 01 | lock and unroute | — | REQ-lock, REQ-unroute | DONE |
| 02 | next contract and --no-talk | 01 | REQ-next, REQ-notalk | DONE |
| 03 | ll-auto skill | 02 | REQ-auto | DONE |
| 04 | ll-goal autonomous mode | 03 | REQ-goal | DONE |
| 05 | end-to-end eval | 04 | REQ-e2e | DONE |

## Phase 01 — lock and unroute
Objective: no ll skill can be started by the model, and the global preamble stops routing requests to skills.
Success criteria:
SC-01 `grep -L 'disable-model-invocation: true' skills/*/SKILL.md | wc -l` prints `0`
SC-02 `grep -c 'Route every request' assets/preamble.md` prints `0`, and the preamble still carries the Skills, Delegation, Decisions and Proof sections
SC-03 every skill description is one plain line (60–300 chars, third-person verb, no "Use when"), enforced by `scripts/lint-prompts.sh` rule 1
SC-04 `npm run lint && npm test` exit 0
SC-05 the eval cases `router-research`, `router-execute`, `router-small`, `preamble-no-ritual` assert the new behaviour (the session names the `/ll-…` command and starts no Skill tool; no regime word required) and `bash scripts/evals/run.sh --dry-run --all` exits 0
These are the verifier's contract, above whatever the phase plan says.
Deferred ideas: moving Delegation/Decisions/Proof out of the preamble into the skills (owner's call later).

## Phase 02 — next contract and --no-talk
Objective: every skill hands over one machine-readable `▶ Next` line, and the two skills that still interview can run without asking.
Success criteria:
SC-01 `node scripts/lint-contract.cjs --rule 6` fails on a `▶ Next` line that is not `▶ Next — /clear, then ll-<skill> [args]` (fixture-tested) and passes on the tree
SC-02 `ll-decide project --no-talk` and `ll-close --no-talk` are documented in their SKILL.md and argument-hint: the recommendation is followed and recorded with `[decided by absence — revisable]`
SC-03 `npm run lint && npm test` exit 0
Deferred ideas: none.

## Phase 03 — ll-auto skill
Objective: `/ll-auto` drives the cycle from the state on disk, with the flags of the design page, and reports what it decided alone.
Success criteria:
SC-01 `node skills/ll-auto/scripts/ll-auto.js detect --json` on `scripts/fixtures/project` prints one status per stage (research, brainstorm, decide, phase N…, verify N…, close) with `decide: done`, and on `scripts/fixtures/empty` prints every stage `todo`
SC-02 `skills/ll-auto/SKILL.md` documents `"<objective>"`, `--research`, `--brainstorm`, `--interactive`, `--auto-decision`, `--pause-at`, `--from`, `--to`, `--only`, `--verify all`, `--redo`, `--dry-run`, `--resume`, and the empty-repo behaviour (print the command to complete, stop, no question)
SC-03 the skill writes `docs/AUTO.md` (objective, flags, roteiro, status per stage) and an end-of-run block listing every decision file carrying `[decided by absence — revisable]`
SC-04 `ll-auto` has `disable-model-invocation: true`, follows each stage's SKILL.md in place, and the lint allows it (and only it) to reference other skills
SC-05 `npm run lint && npm test` exit 0, with smoke checks for the new helper
Deferred ideas: `--interactive` beyond brainstorm and the phase conversation.

## Phase 04 — ll-goal autonomous mode
Objective: `ll-goal` can emit a `/goal` text that keeps `ll-auto --auto-decision` running until the delivery is closed.
Success criteria:
SC-01 `grep -c 'll-auto --auto-decision' skills/ll-goal/references/goal-template.md` ≥ 1
SC-02 `ll-goal --autonomous` (or the mode the plan names) is documented in SKILL.md and argument-hint, and emits ≤ 4,000 chars
SC-03 `npm run lint && npm test` exit 0
Deferred ideas: none.

## Phase 05 — end-to-end eval
Objective: one eval case runs `ll-auto` on a fixture from a written PLAN to a closed delivery, and the dry-run path is wired into `scripts/evals`.
Success criteria:
SC-01 `bash scripts/evals/run.sh --dry-run --case auto-dry-run --case auto-empty-repo` exits 0
SC-02 one real rep of `auto-dry-run` and `auto-empty-repo` passes, with the `RESULTS.md` path recorded in PROGRESS.md
SC-03 `CHANGELOG.md` carries the 3.0.0 entry and `package.json` says 3.0.0
Deferred ideas: a full implement-to-close rep on a bigger fixture.

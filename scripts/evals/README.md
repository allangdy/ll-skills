# Behavioural evals

`smoke-test.sh` checks what the files say. These cases check what a session *does* with them: each
installs the package into a throwaway `CLAUDE_CONFIG_DIR`, runs `claude -p` against a throwaway
copy of a fixture repository, and scores the answer and the work tree with a shell assert.

    bash scripts/evals/run.sh --dry-run --all              # print the commands, call nothing
    bash scripts/evals/run.sh --case router-small --reps 1 # one case, one rep
    bash scripts/evals/run.sh --all                        # twelve cases, three reps

`--all` | `--case <id>` (repeatable) | `--reps N` (default 3) | `--model <id>` | `--dry-run`.
Exit 0 when every selected case passed in at least `min_pass` reps (`case.json`, capped at the
reps actually run, so `--reps 1` means 1 of 1).

## Cost

Router cases are 1–8 turns and cost cents. The six agent and skill cases run 30–40 turns: dollars
per rep, tens of dollars for `--all --reps 3` — a skill that fans out subagents costs about a dollar
per turn-block, so keep routing caps low. Dry run first, then one cheap case.

## Autonomous cases

`auto-dry-run`, `auto-empty-repo` and `goal-autonomous` run the unattended path end to end: ≤ 12
turns and cost cents, like the router cases. The prompt is the slash command exactly as the owner
types it (`/ll-auto --dry-run`, `/ll-auto`, `/ll-goal --autonomous "Deliver phases 07 and 08"`),
which `claude -p` expands; there is no agent, no fan-out. `goal-autonomous` scores the pasted `/goal`
text (`ll-auto --auto-decision`, ≤ 4000 chars) and the committed `docs/GOAL.md` (`mode: autonomous`,
`phase: all`). Their assert scripts are proven offline, without calling `claude -p`, by `npm test`
(section `evals-auto` in `scripts/smoke-test.sh`) against the fixed answers under
`scripts/fixtures/evals-auto/<case>/pass.txt`.

`max_turns` is a budget, not a measurement: the `num_turns` the result reports counts the skill's `!`
preprocessor Bash calls together with the model's own tool calls, and a run has ended `success` with
`num_turns 7` under `--max-turns 4`. Pin each cap above the highest count real reps show (`case.json`
`note`), so the cap only ever cuts a run that really went long.

## Router cases

A skill runs only when the owner types it, so these cases score what the session does with a plain
request — never which command it names back.

| case | prompt | what it scores |
|---|---|---|
| `router-small` | `conta as linhas de README.md` | the answer itself: nothing written, no ritual, no Skill call |
| `router-no-skill` | a research request in a repo that carries `PLAN.md` and `decisions/` | the research itself: no command handed back, no `▶ Next`, no Skill call, nothing created |
| `preamble-no-ritual` | a one-line typo fix | no spec, no plan, no `PROGRESS.md`, no subagent |

A case that exercises a skill types the slash command in its `prompt.txt` (`/ll-implement 7`,
`/ll-decide project …`): a skill is never started from prose, so a prose prompt would score the
plain answer, not the skill.

## Cases proven offline

The `router-no-skill` (research delivered, no command handed back), `decide-final-round`
(decision-room path before the first question, count line in plain words) and
`implement-stops-at-next` (wave line before the epilogue, helper never read) asserts are proven
without calling `claude -p` by `npm test` (section `evals-auto`), against the captures and answers
under `fixtures/router-no-skill/` — `out.json`, a compliant `pass.txt` and a `fail.txt` that only
hands a command back — and the inline captures the smoke test builds.

## Results — outside the repo

Each run writes `$LL_EVAL_RESULTS/<YYYY-MM-DD-HHMM>/` (default `~/.claude/ll-skills-evals`, outside the repo): `RESULTS.md`,
`summary.json`, the installer log and, per rep, `out.json`, `out.txt`, `assert.log`. Work trees
live under `mktemp -d` outside the repo — so the session under test never discovers this project's
own `.claude/` or `CLAUDE.md` — and are kept; `RESULTS.md` prints their path.

## Add a case

`cases/<id>/`: `case.json` (`max_turns`, `history`, `min_pass`, `agent`, `permission_mode`,
optional `reuse`), `prompt.txt` (`{{WORK}}` becomes the work tree's absolute path), optional
`fixture/` (else `scripts/fixtures/project`), optional `setup.sh <workdir>`, and
`assert.sh <workdir> <out.json> <out.txt>` sourcing `lib/assert.sh`.

## Environment

`env -u CLAUDECODE`, `--strict-mcp-config`, `--permission-mode bypassPermissions` by default.
`--max-turns` works but is absent from `claude --help`. `--verbose` is required: without it
`--output-format json` prints only the `result` object, and the regime line — stated in the *first*
assistant message, before any tool call — cannot be read. A fresh `CLAUDE_CONFIG_DIR` has no auth:
`run.sh` symlinks `~/.claude/.credentials.json` into it (a copy goes stale on token refresh).

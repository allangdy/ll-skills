# Behavioural evals

`smoke-test.sh` checks what the files say. These cases check what a session *does* with them: each
installs the package into a throwaway `CLAUDE_CONFIG_DIR`, runs `claude -p` against a throwaway
copy of a fixture repository, and scores the answer and the work tree with a shell assert.

    bash scripts/evals/run.sh --dry-run --all              # print the commands, call nothing
    bash scripts/evals/run.sh --case router-small --reps 1 # one case, one rep
    bash scripts/evals/run.sh --all                        # fourteen cases, three reps

`--all` | `--case <id>` (repeatable) | `--reps N` (default 3) | `--model <id>` | `--dry-run`.
Exit 0 when every selected case passed in at least `min_pass` reps (`case.json`, capped at the
reps actually run, so `--reps 1` means 1 of 1).

## Cost

Router cases are 1–6 turns and cost cents. The six agent and skill cases run 30–40 turns: dollars
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

## Router cases proven offline

`router-large-opener` scores the opener to a LARGE request: the command that owns it
(`/ll-decide project` or `/ll-research`) and at most five lines of plan that name no library, id
format, storage API or file layout, with nothing written and no Skill call. Its assert, and the
`decide-final-round` (decision-room path before the first question, count line in plain words) and
`implement-stops-at-next` (wave line before the epilogue, helper never read) asserts, are proven
without calling `claude -p` by `npm test` (section `evals-auto`), against the captures and answers
under `fixtures/router-large-opener/` — `out.json`, a compliant `pass.txt` and a `fail.txt` that
decides for the skill.

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

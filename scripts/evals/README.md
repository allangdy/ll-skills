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

Router cases are 1–6 turns and cost cents. The six agent and skill cases run 30–40 turns: dollars
per rep, tens of dollars for `--all --reps 3` — a skill that fans out subagents costs about a dollar
per turn-block, so keep routing caps low. Dry run first, then one cheap case.

## Autonomous cases

`auto-dry-run` and `auto-empty-repo` run `ll-auto` end to end: ≤ 6 turns and cost cents, like the
router cases. The prompt is the slash command exactly as the owner types it (`/ll-auto --dry-run`,
`/ll-auto`), which `claude -p` expands; there is no agent, no fan-out. Their assert scripts are
proven offline, without calling `claude -p`, by `npm test` (section `evals-auto` in
`scripts/smoke-test.sh`) against the fixed answers under `scripts/fixtures/evals-auto/<case>/pass.txt`.

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

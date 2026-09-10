---
name: ll-auto
description: Drives the whole cycle from the state on disk — research, brainstorm, decide, phases, verifications, close — following each stage's own skill in place with the flags it was given, and reports at the end every decision it took alone.
argument-hint: "[\"<objective>\"] [--research] [--brainstorm] [--interactive] [--auto-decision] [--pause-at <stage|N>] [--from N] [--to N] [--only N] [--verify all] [--redo <stage>] [--dry-run] [--resume]"
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/ll-auto.js *)
---

# Auto

Current state: !`${CLAUDE_SKILL_DIR}/scripts/ll-auto.js detect`

One invocation, the cycle the repository still owes: the helper reads the state from disk, the flags cut it into a roteiro, and this session walks the roteiro stage by stage, following each stage's own skill as a workflow file. `docs/AUTO.md` carries the run: objective, flags, the roteiro table and one log line per transition, so a compaction or a stop never loses the position. The run starts from the middle when the middle is what exists.

Four boundaries hold for the whole run:
- **The Skill tool is never called.** A stage runs by reading `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/<skill>/SKILL.md` with `Read` (falling back to `skills/<skill>/SKILL.md` in the package tree when this repository is the one running) and following its Flow in place with the stage's arguments. Every skill is locked, this one included; the lock is not worked around, it is honoured by reading the instructions instead of invoking them.
- **Only this skill follows another skill.** The exception exists because the owner typed the command, and it lasts only for this invocation. No stage started here starts a further `ll-auto`.
- **No spending ceiling, ever.** Never stop, throttle or shorten a stage to save tokens or money, never announce a budget, never ask whether to continue for cost. The run ends when the roteiro ends, a pause flag says so, or nothing can move without the owner.
- **No question of its own.** The run never opens `AskUserQuestion`. The only questions the owner sees are the ones a stage asks while running under `--interactive`. When something is missing, the run prints the command that would complete it and stops.

Reply to the owner in Portuguese; every file written is in English.

## Deliverables

| File | Role | Mutability |
|---|---|---|
| `docs/AUTO.md` | the run: objective, flags, roteiro table, decisions taken alone, log | rewritten by this skill on every transition; the roteiro rows only through `auto-md` and the log append-only |
| `docs/research-*/SUMMARY.md`, `docs/decide/`, `PLAN.md`, `ROADMAP.md`, `PROGRESS.md`, `phases/NN/`, `decisions/`, `BACKLOG.md`, `VERIFICATION.md`, `docs/DELIVERY.md` | whatever each stage writes, by the rules of that stage's own skill | owned by the stage skill; this skill writes none of them directly |

## Flow

Helper: `${CLAUDE_SKILL_DIR}/scripts/ll-auto.js`, written `ll-auto.js` below. Read commands exit 0 and answer `{"ok":false,"reason":…}` on a broken input. Commands: `detect`, `roteiro`, `next-cmd`, `report`, `auto-md`.

### 0. State, flags and roteiro

`ll-auto.js detect --json` gives the stage table above; `ll-auto.js roteiro --flags "<the arguments>" --objective "<objective>" --json` turns it into the ordered list of stages to run, with a command and a status per entry. `references/stages.md` holds the detection rules, the command per stage and the flag table.

Three stops before any work:
- `needs_objective: true` (no research, no `docs/decide/OPENING.md`, no `PLAN.md`, and no objective in the arguments) — print exactly two lines and stop, with no question: `Nada encontrado neste repositório: sem pesquisa, OPENING.md nem PLAN.md.` and the command to complete, `/ll-auto "<objetivo>" [--research] [--brainstorm]`.
- `--dry-run` — print the roteiro table and stop, before writing `docs/AUTO.md`.
- an empty roteiro with an objective present — say the cycle has nothing left and hand over.

`--resume`, or a plain invocation in a repository that already has `docs/AUTO.md`, reads the flags from that file's `## Flags` section and continues from the first row that is not `done`.

### 1. Open the run

Write `docs/AUTO.md` with `ll-auto.js auto-md --objective "<objective>" --flags "<the arguments>"`, redirected to the file. Print the roteiro table to the owner in one screen: this is the plan of the run and the last moment before it starts.

### 2. One stage at a time

For every roteiro entry, in order:
1. Mark the row `running` in `docs/AUTO.md` and append the log line `<date> <stage> running`.
2. Read that stage's `SKILL.md` at the path of boundary 1 and follow its Flow in place, with the entry's command as its arguments. The stage owns its files, its questions and its own ▶ Next line; that line is read, not pasted to the owner, and never starts another skill from here.
3. Run `ll-auto.js detect --json` again. Mark the row `done` when the stage's own status turned `done`, `half` when it did not, and append the log line with the evidence the helper gives.
4. List the `decisions/*.md` in state `WAITING` and apply `references/run.md`: without `--auto-decision` skip the stages that depend on them and stop when nothing else can run; with `--auto-decision` resolve each to its recommended option and continue.
5. When the entry carries `pause_after: true` (`--pause-at`), stop here with `▶ Next — /clear, then ll-auto --resume`.

A stage that fails inside its own skill ends the run at that row, marked with its status and its last line in the log; the roteiro below it stays `todo`.

### 3. Close the run

`ll-auto.js report --json` lists every `decisions/*.md` carrying `[decided by absence — revisable]`. Print that list as the end-of-run block, one line per file with its title, and write the same block into the `## Decisions taken alone` section of `docs/AUTO.md`. Then the count line and the handover. The end block, verbatim, is in `references/run.md`.

## Completion criterion

Every roteiro row is `done`, `skipped` or `waiting` in `docs/AUTO.md`, each with a log line carrying the evidence `detect` gave after the stage; the decisions taken alone are listed both in the conversation and in the file; nothing was decided outside `--auto-decision`; no question was asked by this skill. What the run did not reach is named with the command that would close it.
The run's last count line, printed and written to `docs/AUTO.md`:
`stages done X/Y · decisions taken alone N · waiting for the owner K · flags: <the arguments>`
▶ Next — /clear, then ll-resume

## References

- `references/stages.md` — the detection table, the command per stage and the flag table; step 0.
- `references/run.md` — the `docs/AUTO.md` template, the WAITING handling and the end-of-run block; steps 1, 2 and 3.

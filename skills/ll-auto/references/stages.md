# Stages — detection, commands, flags

## Detection

`ll-auto.js detect` reads only the files below and is deterministic: the same tree gives the same
table twice. Every entry answers `{id, status, evidence}` with status `todo`, `half` or `done`.

| stage | done when | half when | evidence field |
|---|---|---|---|
| `research` | a `docs/research-*/SUMMARY.md` exists | never | the path, or what is missing |
| `brainstorm` | `docs/decide/OPENING.md` or any `phases/NN/DECISIONS.md` exists | never | the path, or what is missing |
| `decide` | `PLAN.md` at the root and `PROGRESS.md` with an `ll-state` block | never | `PLAN.md + PROGRESS.md ll-state block` |
| `phase-NN` | the ROADMAP row state starts with `DONE`, or `## Epilogue — phase NN` exists over a board that is for another phase or all `passes: true` | `phases/NN/PLAN.md` exists and the phase is not done | the ROADMAP row, or the epilogue and the milestones still red |
| `verify-NN` | `phases/NN/VERIFICATION.md` exists | never | the path, or what is missing |
| `close` | `docs/DELIVERY.md` exists and the last ROADMAP phase has an epilogue | never | the path, or what is missing |

One `phase-NN` per row of the ROADMAP table; with no ROADMAP.md, the phases come from the same
table inline at `PLAN.md` §8, same columns (`| phase | name | depends_on | requirements | state |`);
with no `PLAN.md`, none. One `verify-NN` per phase row. `close` is always last.

A phase with an epilogue over a board that still shows a milestone `passes: false` is `half`, not
`done`: the epilogue was written, the phase was not finished. `ll-implement NN` resumes it from the
board, which is why a `half` phase enters the roteiro with the same command as a `todo` one.

## The command per stage

| stage | command | note |
|---|---|---|
| `research` | `ll-research "<objective>"` | only with `--research`; the objective is the run's |
| `brainstorm` | `ll-brainstorm project --no-talk` | only with `--brainstorm`; `--interactive` drops `--no-talk` |
| `decide` | `ll-decide project --no-talk` | enters whenever it is `todo` |
| `phase-NN` | `ll-implement NN --no-talk` | `--interactive` drops `--no-talk`; a `half` phase resumes with the same command |
| `verify-NN` | `ll-verify NN` | never `--external`: that flag hands the audit to another session, which this run is not |
| `close` | `ll-close --no-talk` | `--milestone <name>` when the ROADMAP is complete |

The number is written as the ROADMAP writes it (`08`, not `8`). The roteiro entry carries the
command ready to follow; the stage's own skill decides everything inside it.

## Which stages enter the roteiro

`research` and `brainstorm` enter only when their flag is set and their status is not `done`.
`decide` enters when it is `todo`. Every phase row that is not `done` enters, filtered by
`--from/--to/--only`, the `half` ones first as a resume. `verify-NN` enters right after its phase
when `--verify all` is set or when the phase's epilogue names `ll-verify NN` in its handover line.
`close` enters last, unless `--only` or `--to` cut the roteiro before the last row.

## Flags

| flag | effect |
|---|---|
| `"<objective>"` | the run's objective: the argument of `ll-research`, and the `## Objective` of `docs/AUTO.md` |
| `--research` | put `research` in the roteiro when it is not done |
| `--brainstorm` | put `brainstorm` in the roteiro when it is not done |
| `--interactive` | drop `--no-talk` from `ll-brainstorm` and `ll-implement`: those stages talk to the owner |
| `--auto-decision` | resolve every owner-only decision to its recommended option and continue; without it the run stops when one blocks the way |
| `--pause-at <stage\|N>` | stop after that stage or phase, with `▶ Next — /clear, then ll-auto --resume` |
| `--from N` | skip the phase rows below N |
| `--to N` | skip the phase rows above N |
| `--only N` | phase N alone; implies `--from N --to N` and cuts `close` |
| `--verify all` | a `verify-NN` after every phase, whatever the epilogue says |
| `--redo <stage>` | force a `done` stage back to `todo` in the roteiro; repeatable |
| `--dry-run` | print the roteiro table and stop, before writing `docs/AUTO.md` |
| `--resume` | read the flags from the `## Flags` section of `docs/AUTO.md` and continue from the first row that is not `done` |

`--pause-at` and `--redo` are repeatable. A plain invocation in a repository that already carries
`docs/AUTO.md` behaves as `--resume`: the flags of the file are the flags of the run.

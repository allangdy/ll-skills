---
name: ll-close
description: Closes a phase or a delivery, reconciling the backlog against executable conditions, writing docs/DELIVERY.md, stamping the epilogue, recording the retrospective and asking for one block of ratification.
argument-hint: "[--milestone <name>] [--no-talk]"
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/ll-tools.js *)
---

# Close

Current state: !`${CLAUDE_SKILL_DIR}/scripts/ll-tools.js state`

Closing means the next session — or the next person — can pick this up from files alone: what changed and for whom, what was proven and by which command, what stayed open and under what condition it reopens. Nothing is closed from memory: an item closes because its condition ran and passed.

Reply to the owner in Portuguese; every file you write is in English.

## Deliverables

| File | Role | Mutability |
|---|---|---|
| `docs/DELIVERY.md` | the eight sections a manager reads, per delivery | one per delivery; `docs/history/` keeps the old ones |
| `docs/RETROSPECTIVE-<date>.md` | ~60 lines: numbers, cost, permanent rules, what to stop doing | one per large delivery; the only doc the next milestone reads |
| `PROGRESS.md` | `## Epilogue` with the board, what is left, what waits on the owner, next command | append-only |
| `BACKLOG.md` | reconciled; new items with an executable condition and their birth phase | closed only by `backlog-reconcile --run` |
| `CLAUDE.md` (project) | `## Current state`, plus a line per rule that became permanent | short and alive; never a changelog |
| `docs/history/<milestone>/` | archived phases (`--milestone` only) | write once |
| `<CLAUDE_CONFIG_DIR>/projects/<cwd>/memory/*.md` | a lesson that changes how the next phase runs (step 5) | outside the repo, by design |

## Gate

Read the verification for the target: the newest by mtime between `phases/NN/VERIFICATION.md` (phase) and `VERIFICATION.md` at the repo root (delivery); say which one opened the gate. Close only on `APPROVED`, or on `APPROVED_WITH_RESERVATIONS` whose reservations are accepted in a `decisions/DEC-*.md` naming them. Anything else — `REJECTED`, `product: FAIL`, `process: FAIL` with no DEC, no verification file at all — stops here:

> Não fecho: `<motivo em uma linha>`. ▶ Next — /clear, then ll-verify NN (or record the reservations in a DEC and run ll-close again)

A verification whose ledger has `STALE` lines is verification of code that moved: it does not open the gate.

## Flow — delivery (default)

1. **Reconcile.** `ll-tools.js backlog-reconcile --run`. Items whose condition passed close; the rest stay open with their exit code. Then add the items born in this delivery — deviations, stubs, tests not run, debt, domain questions — one row each with the next free `B-nnn` in the columns `| B-nnn | born (phase / commit) | type | closing condition (executable) | note | state |`; the closing condition cell is exactly `` `<command>` exit N `` and nothing else, any prose goes in `note`. An item without a condition is a wish, not a backlog entry.
2. **Write `docs/DELIVERY.md`** in the eight sections of `references/delivery.md`. The verification section carries the commands, their last output lines and the screenshots that were opened; a claim with no command behind it goes to the assumptions section instead.
3. **Stamp the epilogue.** `ll-tools.js epilogue <phase> --json` gives passed, left with why, WAITING, new backlog, dirty tree, HEAD and the next command; `ll-tools.js phase-stats --since <YYYY-MM-DD of the phase's first commit>` (a date; the day is inclusive) gives days with work, span, idle days, commits by type and the test/feat ratio. The helper prints the data; the prose around it is yours, in `## Epilogue` at the end of PROGRESS.
4. **Write `docs/RETROSPECTIVE-<date>.md`** from `references/retrospective.md` — about 60 lines, driven by the numbers from step 3, one lesson per line with the evidence that produced it.
5. **Promote what is permanent.** A lesson that changes how the next phase runs goes to project memory; a lesson that is a standing rule of this repository goes as one line into the project's `CLAUDE.md`, in the owner's words when he gave them. Two lines at most per delivery: a CLAUDE.md that grows every close stops being read.
6. **Peer notice.** If a peer session (infra, ops, another repo) shipped, waits on something, or was asked for something in `docs/REQUESTS.md`, that goes in the summary as one line with the request id and its state — not as a new message.
7. **One block of ratification.** A single `AskUserQuestion`, at most 4 items, only after everything is written: the open pendings with their conditions, and the accepted risks the delivery carries. Options carry the cost of each path and the recommendation is marked; options name the item in plain words — never a `DEC-`/`B-` id alone, the id goes in the file. Silence keeps what is written; nothing here blocks the close. With `--no-talk`, this block is not asked: the same items — open pendings with their conditions, accepted risks, recommendation — are written instead under the epilogue in PROGRESS.md and in DELIVERY.md §5, each line marked `[decided by absence — revisable]` with the date; the gate above is unchanged.
8. **Report.** Verdict and seals, what changed in one line, numbers from `phase-stats`, open pendings by id, accepted risks, next command.

## Flow — `--milestone <name>`

The list always goes out; the audit ritual is optional and offered once, never imposed.

1. Gate again over every phase of the milestone: any phase with no approved verification is named in the report and its phase directory is archived unclosed, marked as such.
2. `git mv phases/* docs/history/<milestone>/` — the directories move, they are not deleted. `PROGRESS.md` above its 200-line ceiling collapses into `docs/history/<milestone>/PROGRESS.md`, leaving the current board and the epilogue.
3. Collapse the closed phases in `ROADMAP.md` into one `<details>` block per phase, keeping the numbering intact — phase 7 stays phase 7 forever, and a later reference to it still resolves.
4. Transport only what survives: an open pending with an executable condition goes to `BACKLOG.md`; a criterion never proven goes to the next milestone's ROADMAP as a criterion, not as a note. What survives neither test is dropped, and the report says which.
5. Update `## Current state` in the project's `CLAUDE.md`: what exists now, what the next milestone is, where the history went. Replace the section; do not append to it.
6. One block of ratification, as in the delivery flow, plus the open pendings the milestone inherits. `--no-talk` follows the same rule: the block is not asked, and the same items are written under the epilogue instead.

## Completion criterion

`DELIVERY.md` and the retrospective on disk, epilogue stamped, backlog reconciled with every open item carrying a runnable condition, memory and `CLAUDE.md` updated, one ratification asked. `--milestone` adds: `phases/` archived, ROADMAP collapsed with numbering intact, `## Current state` current.

- more phases in the ROADMAP → `▶ Next — /clear, then ll-implement <N+1>`
- last phase of the milestone → `▶ Next — /clear, then ll-close --milestone <name>`
- milestone closed → `▶ Next — /clear, then ll-decide project` for the next one

## References

`references/delivery.md` — the eight sections of `docs/DELIVERY.md` and the rule for each.
`references/retrospective.md` — the retrospective template and what each section is allowed to contain.

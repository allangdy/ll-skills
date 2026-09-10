# DEC-0004 — ll-goal stays, and only emits the /goal text

- Date: 2026-09-10
- Decided by: the owner, in free text
- Status: accepted

## Decision

`ll-goal` is not absorbed by `ll-auto`. It keeps one job: write the text the owner pastes
into `/goal`. When the owner wants an unattended run, that text says
"run `ll-auto --auto-decision` until the delivery is closed", so the `/goal` loop restarts
`ll-auto` if the session stops halfway.

## Why

Even an autonomous run can stop mid-way (context, crash, timeout). `/goal` is the harness
mechanism that keeps a session working toward a goal; `ll-goal` writes the goal, `ll-auto`
does the work. Two different jobs.

## Consequence

- `ll-goal` gains the mode "objective + autonomous" and points at `ll-auto --auto-decision`
- the ll-auto design no longer lists "goal" as a stage the runner performs

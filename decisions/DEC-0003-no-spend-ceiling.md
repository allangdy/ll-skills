# DEC-0003 — ll-auto has no spending ceiling

- Date: 2026-09-10
- Decided by: the owner, in free text
- Status: accepted

## Decision

`ll-auto` runs as long as the work needs. There is no `--ceiling-usd` flag, no default budget
before PLAN.md exists, and no stop on cost.

## Why

The team pays a Claude subscription, not per token. Cost is not a variable the owner wants
the tooling to reason about.

## Consequence

Drop the ceiling flag and the "default budget" question from the ll-auto design. PLAN.md
§Budget stays as a planning field but never stops a run.

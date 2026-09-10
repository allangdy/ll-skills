# DEC-0005 — ll-auto runs as a skill in the session, not as a headless runner

- Date: 2026-09-10
- Decided by: the owner, choosing option B in the design battery
- Status: accepted · against the recommendation (A: `claude -p` per stage) — faithful record, do not re-litigate

## Decision

`ll-auto` is a skill. It follows each stage's SKILL.md in place, in the same session, backed by
the `ll-state` and `ll-precompact` hooks that stamp the state into PROGRESS.md before compaction.
No external process, no `claude -p` per stage.

## Consequences

- Context grows across stages; mitigated by disk state and by the `/goal` text (DEC-0004) that
  restarts `ll-auto` when the session stops.
- Because every skill is locked (DEC-0002), `ll-auto` cannot use the Skill tool; it reads the
  stage's SKILL.md as a workflow file.
- accepted risk: a long run may compact more than once; every stage writes its output to disk
  before the next starts.

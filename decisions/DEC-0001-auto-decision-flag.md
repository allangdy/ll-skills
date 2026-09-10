# DEC-0001 — `--auto-decision` governs what ll-auto does at an owner-only decision

- Date: 2026-09-10
- Decided by: the owner, in free text, during the design of `ll-auto`
- Status: accepted

## Decision

`ll-auto` gets a flag `--auto-decision`.

- With `--auto-decision`: the run never stops. At every decision that would otherwise need the
  owner, the run picks the recommended option, records it as taken autonomously, and continues.
  At the end, the run prints the complete list of decisions it took on its own, for review.
- Without `--auto-decision`: the run continues as far as it can without that decision, then stops
  and shows what the owner still has to answer, with the command to resume.

## Why

The owner does not want a fixed behaviour; the behaviour depends on how the run was started.
This replaces the earlier proposal "freeze only the branch and continue" as the default.

## Consequence

The `[decided by absence — revisable]` marker on decisions stays; it is what the end-of-run
review lists. `--pause-at band1` is dropped: "without `--auto-decision`" is that behaviour.

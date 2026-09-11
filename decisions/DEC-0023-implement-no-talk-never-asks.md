# DEC-0023 — `ll-implement --no-talk` never asks; owner-only items become WAITING decisions

- Date: 2026-09-11
- Decided by: Claude (consistency with `ll-decide --no-talk` and with what `ll-auto` already emits), flagged for the owner's review
- Status: DECIDED · [decided by absence — revisable]

## Decision

With `--no-talk`, step 1 of `ll-implement` ratifies the recommended items, writes each owner-only
item as `decisions/DEC-NNNN-<slug>.md` in state `WAITING` and marks the milestones that depend on it
`stop: owner`; scout, plan, review gate, waves and epilogue run for the rest. The interactive path
still asks owner-only items in one block of at most 4.

## Why

The live eval `implement-review-gate` (2026-09-11) stopped on an owner-only question in a one-shot
run; `ll-auto` had always assumed `--no-talk` does not block.

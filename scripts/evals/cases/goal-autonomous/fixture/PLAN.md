# PLAN — reconciliation service

## §0 Precedence

This file is self-contained and the ONLY entry of the work. §2 > §3 > §6 > §7. Decisions in §3 are a
contract — do not re-litigate. Project CLAUDE.md > this file > phase plans > briefs.

## §1 Objective and truths

Every provider event is reconciled exactly once and every mismatch is visible to the operator.

- T1 A provider batch produces one row per event. — `npm test` exit 0
- T2 A replayed batch adds no rows. — `npm test` exit 0

Requirements: REQ-k (phase 07), REQ-m (phase 08).

## §2 Invariants

I-01 Never delete, disable or weaken a test or an acceptance criterion. [owner, 2026-08-20]
I-02 Do not fill a gap with a plausible interpretation: report and ask. [owner, CLAUDE.md]

## §3 Owner decisions

| id | question | decision | by | date | against recommendation? | reversible? |
|---|---|---|---|---|---|---|
| DEC-0041 | mismatch unit | cents, integer | owner | 2026-08-22 | no | 1 commit |

## §6 Global acceptance

CA-01 — WHEN a batch is ingested THE SYSTEM SHALL write one row per event · `npm test` exit 0
CA-02 — WHEN a mismatch is found THE SYSTEM SHALL report it · `npm test` exit 0

## §7 Execution protocol

Models per role: session fable/high · scout sonnet/medium · contract executor opus/high · mechanical
executor sonnet/medium · verifier opus/high · reviewer opus/medium. Max 3 executors per wave on
disjoint files. Commit per path after each milestone; push only with everything green (push is not a
deploy here). TDD on by default; exceptions: config and glue.

## §8 Phases

Phases live in ROADMAP.md. Current phase: 07.

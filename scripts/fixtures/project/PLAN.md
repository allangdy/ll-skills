# PLAN — fixture project

## §0 Precedence

This file is self-contained and the ONLY entry of the work. §2 > §3 > §4 > §5. Decisions in §3 are a
contract — do not re-litigate. Project CLAUDE.md > this file > phase plans > briefs.

## §1 Objective and truths

One sentence of delivery: every provider event is reconciled exactly once and every mismatch is
visible to the operator.

- T1 Every provider event produces exactly one row in `billing_events`. — `npm test -- a.test.ts`
- T2 A replayed batch adds no rows. — `npm test -- replay.test.ts`
- T3 Cent-level mismatches are reported, never dropped. — `npm test -- pay.test.ts`

Requirements: REQ-k (phase 07), REQ-m (phase 08).

## §2 Invariants

I-01 NEVER delete, disable or weaken a test or acceptance criterion. [owner, 2026-08-23]
I-02 Do not fill a gap with a plausible interpretation: report and ask. [owner, CLAUDE.md]

## §3 Owner decisions

| id | question | decision | by | date | against recommendation? | reversible? |
|---|---|---|---|---|---|---|
| DEC-0041 | cents divergence | pending | — | — | — | 1 migration |

## §4 Requirements from the premortem

R-01 A silent duplicate is worse than a rejected batch. (from F-01)

## §5 Negative scope · freedoms · reserved

Out of scope: customer portal. Free: module names, migration layout. Owner only: production deploy.

## §6 Global acceptance

CA-01 WHEN a batch is ingested twice THE SYSTEM SHALL keep one row per event · tolerance 0 ·
`npm test -- a.test.ts`

## §7 Execution protocol

Session fable/high; scout sonnet/medium; contract executor opus/high; verifier opus/high.
Max 3 executors per wave. Push only with everything green.

## §8 Phases

See ROADMAP.md. Current phase: 07.

## §9 Environment

`BILLING_PROVIDER_KEY` (name only, never the value).

## §10 What is left for this to survive without the owner

A provider sandbox key for the integration test.

## §11 Sources

Owner conversation 2026-08-23; docs/research-billing/SUMMARY.md.

## Errata

(append-only; empty)

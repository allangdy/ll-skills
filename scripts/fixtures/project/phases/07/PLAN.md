# Phase 07 — billing reconciliation

Objective (from ROADMAP): every provider event lands in `billing_events` exactly once and mismatches
are visible. Success criteria: SC-01..SC-04 (pasted from ROADMAP.md).
Decisions: phases/07/DECISIONS.md · Context: phases/07/CODE-CONTEXT.md

## Milestones

<!-- ll-milestones -->
milestones:
  - id: M1
    name: end-to-end tracer
    files: [src/a.ts, test/a.test.ts]
    depends_on: []
    tdd: yes
    acceptance: "npm test -- a.test.ts"
    stop: none
    truths: [T1]
    exclusive: []
    model: opus/high
    verification: internal
  - id: M2
    name: provider batch ingest
    files: [src/ingest.ts, test/ingest.test.ts]
    depends_on: [M1]
    tdd: yes
    acceptance: "npm test -- ingest.test.ts"
    stop: none
    truths: [T2]
    exclusive: []
    model: opus/high
    verification: internal
  - id: M3
    name: cent mismatch spike
    files: [src/spike.ts]
    depends_on: [M1]
    tdd: no
    acceptance: "npm run spike -- cents"
    stop: none
    truths: [T3]
    exclusive: []
    model: sonnet/medium
    verification: internal
  - id: M4
    name: reconcile join
    files: [src/join.ts, test/join.test.ts]
    depends_on: [M2, M3]
    tdd: yes
    acceptance: "npm test -- join.test.ts"
    stop: none
    truths: [T1, T2]
    exclusive: [test:db]
    model: opus/high
    verification: internal
  - id: M5
    name: tolerated rows report
    files: [src/pay.ts, test/pay.test.ts]
    depends_on: [M3]
    tdd: yes
    acceptance: "npm test -- pay.test.ts"
    stop: owner
    truths: [T3]
    exclusive: []
    model: opus/high
    verification: external
  - id: M6
    name: mismatch flag column
    files: [src/pay.ts, src/schema.ts]
    depends_on: [M3]
    tdd: no
    stop: none
    truths: [T3]
    exclusive: [test:db]
    model: sonnet/medium
    verification: internal
  - id: M7
    name: operator listing
    files: [src/list.ts, test/list.test.ts]
    depends_on: [M9, M4]
    tdd: yes
    acceptance: "npm test -- list.test.ts"
    stop: none
    truths: [T1]
    exclusive: []
    model: sonnet/medium
    verification: internal
<!-- /ll-milestones -->

### M1 — end-to-end tracer

read_first:
  - src/a.ts:1-3 — the shape to copy for the batch signature
  - test/a.test.ts:1-5 — test layout
action: export `reconcile(batch)` keyed by `(provider, event_id)`.
behavior (tdd: yes): duplicate event, new event, empty batch.
acceptance: `npm test -- a.test.ts` exit 0; last line pasted.

### M2 — provider batch ingest

read_first:
  - src/a.ts:1-3 — the reconcile entry point
action: read a provider batch file and hand each event to `reconcile`.
behavior (tdd: yes): malformed line, empty file, 3-event file.
acceptance: `npm test -- ingest.test.ts` exit 0.

### M3 — cent mismatch spike

read_first:
  - src/pay.ts:1-5 — the current tolerance rule
action: measure how many rows of the September batch differ by cents only.
acceptance: `npm run spike -- cents` exit 0 with the count on the last line.

### M4 — reconcile join

read_first:
  - src/a.ts:1-3 — reconcile signature
action: join ingested events with the ledger rows; keep the idempotency key.
behavior (tdd: yes): matched, unmatched, duplicate.
acceptance: `npm test -- join.test.ts` exit 0.

### M5 — tolerated rows report

read_first:
  - src/pay.ts:1-5 — `tolerated()` is the rule to reuse
action: list rows tolerated for a day; the owner unblocks the format.
behavior (tdd: yes): under tolerance, over tolerance, exactly at tolerance.
acceptance: `npm test -- pay.test.ts` exit 0.

### M6 — mismatch flag column

read_first:
  - src/pay.ts:1-5 — where the flag is computed
action: add the `mismatch_flag` column and write it from `tolerated()`.

### M7 — operator listing

read_first:
  - src/pay.ts:1-5 — the tolerated rule the listing filters on
action: expose the tolerated rows through the operator console.
behavior (tdd: yes): empty day, one row, paging.
acceptance: `npm test -- list.test.ts` exit 0.

## Waves (printed by `ll-tools.js waves`)

| wave | milestones | builds |

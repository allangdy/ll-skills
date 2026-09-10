# ROADMAP — reconciliation service

| phase | name | depends_on | requirements | state |
|---|---|---|---|---|
| 05 | payment intake | — | REQ-a | DONE (docs/history/v1.0) |
| 06 | provider adapters | 05 | REQ-b | DONE (docs/history/v1.0) |
| 07 | billing reconciliation | 05, 06 | REQ-k | PLANNED |
| 08 | reconciliation reporting | 07 | REQ-m | PLANNED |

## Phase 07 — billing reconciliation

Objective: every provider event lands in `billing_events` exactly once and mismatches are visible.

Success criteria:
- SC-01 The reconciliation job ingests a provider batch and writes one row per event.
- SC-02 A replayed batch produces no duplicate rows.
- SC-03 Cent-level mismatches are reported instead of silently dropped.

Deferred ideas: customer portal; accounting export.

## Phase 08 — reconciliation reporting

Objective: the operator reads yesterday's reconciliation without opening the database.

Success criteria:
- SC-01 A daily report lists ingested, tolerated and rejected rows.
- SC-02 The report is reachable from the operator console.

Deferred ideas: CSV export.

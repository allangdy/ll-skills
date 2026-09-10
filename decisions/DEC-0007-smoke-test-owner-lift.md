# DEC-0007 — the owner lifts I-09 for scripts/smoke-test.sh

- Date: 2026-09-10
- Decided by: the owner, answering "Pode corrigir" to the session's question
- Status: DECIDED — "Pode corrigir" (owner, 2026-09-10, question 1/1)

## Decision

Phase 01 M5 may edit `scripts/smoke-test.sh` to repair the owner's uncommitted nest step
(lines 186–194: `docs/state` is removed before `backlog-reconcile` reads it). The owner's intent
stays: the hook must ignore a PROGRESS.md under `fixtures/`. The fix keeps `docs/state` by moving
it aside during that check and restoring it afterwards. `hooks/ll-state.js` and
`hooks/ll-precompact.js` stay under I-09 (untouched, uncommitted) unless the owner says otherwise.

## Owner's words (verbatim)
"Pode corrigir" — option chosen in the battery, 2026-09-10.

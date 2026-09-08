# VERIFICATION — phase 07 — 2026-09-09

verdict: APPROVED_WITH_RESERVATIONS · product: OK · process: FAIL (I-01 weakened without a DEC)

| C | criterion | command | exit | file:line | sha256 | freshness | state |
|---|---|---|---|---|---|---|---|
| SC-01 | one row per provider event | npm test -- a.test.ts | 0 | src/pay.ts:3 | sha256:946c8f6b2d9a | FRESH | VERIFIED |
| SC-02 | a replayed batch adds no rows | npm test -- ingest.test.ts | 0 | src/a.ts:1 | sha256:0000dead1234 | FRESH | VERIFIED |
| SC-03 | cent mismatches are reported | — | — | test/a.test.ts:3 | — | — | PRESENT_NO_BEHAVIOR |

BLOCKS: process — the tolerance assertion in `test/a.test.ts` was loosened with no DEC.

Disconfirmation: 1 partial requirement (SC-02 happy path only); 1 uncovered error path (provider timeout).

What this verification does NOT prove: behavior under real provider latency.

Deferred: SC-03 until the fixture exists (BACKLOG B-014).

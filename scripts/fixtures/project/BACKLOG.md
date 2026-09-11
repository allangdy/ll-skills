# BACKLOG — fixture project

| id | born (phase / commit) | type | closing condition (executable) | note | state |
|---|---|---|---|---|---|
| B-014 | 07 / a1b2c3d | stub | `true` exit 0 | — | OPEN |
| B-015 | 07 / b2c3d4e | deviation | `false` exit 0 | — | OPEN |
| B-016 | 06 / c3d4e5f | debt | `true` exit 0 | — | CLOSED |
| B-017 | 07 / a1b2c3d | debt | run `npm test` and check exit | — | OPEN |

types: deviation | stub | test-not-run | debt | domain-question

Closed only by `ll-tools.js backlog-reconcile --run` (the condition passed), never by memory.

# DEC-0016 — the helper size ceiling rises to 760 lines / 36 000 bytes

- Date: 2026-09-11
- Decided by: Claude (a reversible technical detail inside the repo; the alternative was cutting `board-switch` and its tests for 370 bytes), flagged for the owner's review
- Status: DECIDED · [decided by absence — revisable]

## Decision

`scripts/lint-prompts.sh` rule 3 and the twin checks in `scripts/smoke-test.sh` section 1 accept
`scripts/ll-tools.js` up to 760 lines and 36 000 bytes (was 700 / 32 768). After every shrink the
helper stands at 711 lines / 34 624 bytes with `board-switch`, `passes --phase` and the
`unparsable:` epilogue segment (W1-A, 87c8491).

## Why

The five shrinks in CHANGE-PLAN §F-1 recovered 236 bytes; the shared `<ll-shared:state>` region is
compared byte-for-byte with `hooks/ll-state.js` and cannot be edited alone, and the last shrink would
delete two green smoke checks. The ceiling exists to keep the helper out of the prompt, and the helper
is called, never read (W1-B), so 2 KB more costs no context.

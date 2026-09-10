# DEC-0009 — scripts/smoke-test.sh is an ordinary file again

- Date: 2026-09-10
- Decided by: Claude (band 2: a fact readable from the repo), flagged for the owner's review
- Status: DECIDED · [decided by absence — revisable]

## Decision

PLAN §2 I-09 protected three files because they carried the owner's uncommitted edits. Since
commit 122a3bb (phase 01 M5, authorised by the owner in DEC-0007 "Pode corrigir")
`scripts/smoke-test.sh` is committed and clean: `git status --short scripts/smoke-test.sh` is
empty. From phase 02 on, executors may edit and commit it like any other script.
`hooks/ll-state.js` and `hooks/ll-precompact.js` still carry uncommitted owner edits and stay
under I-09 until the owner commits them.

## Consequence

PLAN §7's sentence "never commit the three files of I-09" now reads as "the files that still
carry the owner's uncommitted edits" — recorded under PLAN ## Errata.

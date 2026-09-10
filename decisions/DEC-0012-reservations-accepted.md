# DEC-0012 — the reservations of phases 01, 02 and 04 are accepted at close

- Date: 2026-09-10
- Decided by: Claude (band 2: facts readable from the repo), flagged for the owner's review
- Status: DECIDED · [decided by absence — revisable]

## Decision

The gate of `ll-close` is opened by `phases/05/VERIFICATION.md` (APPROVED, the newest). The three
earlier verdicts with reservations are accepted as follows:
- phases 01, 02, 04 — "a clean checkout fails `npm test` until the owner commits the two hook files":
  closed by commit 1efc0c9; proven on a clean `git archive HEAD` checkout on 2026-09-10
  (`npm run lint` → `ok — 7 rule(s), 0 violation(s)`, `npm test` → `smoke test OK — 202 checks`).
- phase 02 — rule 6 accepts the same skill repeated outside a parenthetical: stays open as B-006,
  with its executable condition; it does not change what the owner types.
- phase 04 — the 4,000-char cap is measured on the static example, never on an emission: stays
  open as B-016 (eval case `goal-autonomous`).

## Why

Every reservation either has a proof in this session or an executable backlog condition. None
changes the behaviour the tech team will see when it types `/ll-<name>`.

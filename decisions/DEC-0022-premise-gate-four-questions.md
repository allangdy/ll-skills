# DEC-0022 — the ll-decide premise gate asks four questions; the cautious constraint is an assumption

- Date: 2026-09-11
- Decided by: Claude (house rule: one block of at most 4; a rule invented out of caution is decided and flagged, never asked), flagged for the owner's review
- Status: DECIDED · [decided by absence — revisable]

## Decision

The premise gate sends four plain questions (`Pergunta n/4 — …`) in one block: success number,
deliverable format, source of truth, house pattern. The fifth premise — a constraint the session
invents out of caution — is never asked: dropped, or kept as `ASM-n [revisable]` with its trigger and
counted as an assumption. Lint rule 9 rejects `[PG-` in question lines and `banda 1` on screen text.

## Why

Live eval `decide-final-round` on 2026-09-11 printed five `[PG-n]` headers in one block and "banda 1"
on screen — the two defects the 3.1.0 round exists to remove.

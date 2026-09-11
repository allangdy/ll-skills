# DEC-0019 — the second lab run exercises every skill and path in one scenario

- Date: 2026-09-11
- Decided by: Claude (the owner asked for a complete test on 2026-09-11; the round-2 turn list is CHANGE-PLAN Part B), flagged for the owner's review
- Status: DECIDED · [decided by absence — revisable]

## Decision

`lab/scenarios/notes-api.md` grows to turns 8–24 (milestone close, research, `--no-talk` decide with a
four-phase ROADMAP and one WAITING decision, autonomous goal, external verify, a sabotaged phase that
fails verification and blocks close, a wave rerun, a BLOCKED milestone, oncall, docx feedback, refine,
`ll-auto --from --pause-at --resume`, resume). The owner-only item planted in the scenario is a paid
e-mail provider, answered from the answers table with the dry-run recommendation. The session under
test runs in an isolated `CLAUDE_CONFIG_DIR` with folder trust pre-accepted; the driver polls every
five minutes and asserts the board, the backlog rows and the absence of jargon after each turn.

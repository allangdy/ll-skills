---
name: ll-bad
description: Fixture for lint-contract rule 6 — three handoff lines that the Next grammar must reject.
argument-hint: "[none]"
disable-model-invocation: true
---

# Bad handoffs

Each line below breaks the grammar in one way, so rule 6 must print one FAIL for each.

Old shape, backticks around /clear and around a skill that does exist:

▶ Next — `/clear` then `ll-bad`

Bare command, no `/clear, then` opening:

▶ Next — ll-bad

Right grammar, command that names no skill in this tree:

▶ Next — /clear, then ll-nope

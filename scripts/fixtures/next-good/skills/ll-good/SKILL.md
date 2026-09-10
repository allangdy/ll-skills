---
name: ll-good
description: Fixture for lint-contract rule 6 — one line per allowed form of the Next grammar.
argument-hint: "[none]"
disable-model-invocation: true
---

# Good handoffs

Plain command:

▶ Next — /clear, then ll-good

Arguments, with the alternatives inside one parenthetical:

▶ Next — /clear, then ll-good 3 --wave 2 (or ll-good --resume)

The /goal target, followed by text:

▶ Next — /clear, then /goal <text>

A placeholder in angle brackets, when the epilogue names the command:

▶ Next — /clear, then <the command the epilogue names>

Wrapped in backticks inside prose: the epilogue ends with `▶ Next — /clear, then ll-good --resume` and nothing follows it.

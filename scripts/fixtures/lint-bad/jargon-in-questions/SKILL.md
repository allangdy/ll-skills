---
name: ll-fake
description: Prints the owner's questions with the internal vocabulary still in them, so lint rule 9 has something to catch.
argument-hint: "[--no-talk]"
disable-model-invocation: true
---

# ll-fake

## Flow

1. Print the round:

**Pergunta 1/2 — limite de título [DEC-0001]** (impacto ALTO · desfazer: barato)

**Question 2/2 — retenção [ASM-3]** (impact LOW)

2. Print the counter: `questions asked 2 / assumptions 1 / band-1 open 1`

3. The Portuguese line: `perguntas 2 / assunções 1 · decisões [D-07-01] em aberto 1`

## Deliverables

| File | Role | Mutability |
| --- | --- | --- |
| `docs/fake.md` | nothing | rewritten |

## Completion criterion

Done when the file exists.

▶ Next — `/clear`, then `/ll-resume`

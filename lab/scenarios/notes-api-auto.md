# Scenario notes-api-auto — one command, no stops

Same owner and same project as `notes-api.md`. The driver types one turn and waits:

1. `/ll-auto "API de notas em Node sem dependências: criar, listar, buscar por id, apagar; persistência em arquivo JSON; testes com node:test; README com exemplos curl" --brainstorm --auto-decision --verify all` → wait up to 2 h for idle/done.
2. Any `blocked` is a finding: the driver answers with the default line `decide você, é detalhe` and logs it.
3. At the end: `docs/AUTO.md` exists with every row done or skipped and the `## Decisions taken alone` block; `docs/DELIVERY.md` exists; `npm test` green.

The evaluator compares every decision taken alone against the answers table of `notes-api.md`.

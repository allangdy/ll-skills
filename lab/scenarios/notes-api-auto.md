# Scenario notes-api-auto — one command, no stops

Same owner and same project as `notes-api.md`. The driver types one turn and waits:

1. `/ll-auto "API de notas em Node sem dependências: criar, listar, buscar por id, apagar; persistência em arquivo JSON; testes com node:test; README com exemplos curl" --brainstorm --auto-decision --verify all` → wait up to 2 h for idle/done, polled with the same isolated-`CLAUDE_CONFIG_DIR` / 5-minute loop the driver uses for `notes-api.md` (see `lab/README.md` "Driver protocol — isolated session, trust, polling"), trust dialog pre-accepted before turn 1.
2. Any `blocked` is a finding: the driver answers with the default line `decide você, é detalhe` and logs it.
3. At the end: `docs/AUTO.md` exists with every row done or skipped and the `## Decisions taken alone` block; `docs/DELIVERY.md` exists; `npm test` green.
4. This project stays at two phases (core, then persistence + delete), so `ROADMAP.md` is not
   expected here — the skill writes one only above 3 phases (D-4); a `ROADMAP.md` on disk at the end
   of this run is itself a finding. The round-2 project in `notes-api.md` reaches four phases and
   does expect one.

The evaluator compares every decision taken alone against the answers table of `notes-api.md`.

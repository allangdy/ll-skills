# Scenario notes-api — manual, skill by skill

## The owner (persona the driver plays)
Product owner, Portuguese, short sentences, no jargon, impatient with questions whose answer is in
the repo. Pays a subscription (never discuss cost). Wants tests. Says "continua" when a skill stops
with a ▶ Next. Never says "faça o que quiser": decisions come from the table below.

## The project
A small notes API in Node (no dependencies, `node:test`): create, list, get by id, delete; JSON
file persistence; two phases in the roadmap — 01 core (create/list/get, in memory, tests), 02
persistence and delete. Done means `npm test` green and a README with the curl examples. Round 2
(turns 8–24) grows the same project to a milestone `v0.1.0`, a four-phase `ROADMAP.md` (03 tags +
search + pagination, 04 edit + size limits, 05 daily digest by e-mail, 06 rate limit), a planted
external-feedback round, and a milestone `v0.2.0`.

## Driver session
The session under test runs in an isolated `CLAUDE_CONFIG_DIR` with the folder-trust dialog
pre-accepted before turn 1 — see `lab/README.md` "Driver protocol — isolated session, trust,
polling" for the exact steps and the fallback if the dialog still appears.

## Turns — round 1 (in order; `→` = what the driver expects before the next turn)
1. `quero fazer uma API de notas em Node, sem dependências, com testes. criar, listar, buscar por id e apagar, salvando em arquivo JSON. me diz por onde começar` → an ordinary answer that starts no skill (finding if it starts one); naming a command is not expected, and the driver types turn 2 regardless.
2. `/ll-brainstorm project` → answer questions from the table; ends in DECISIONS/OPENING and a ▶ Next.
3. `/clear` then `/ll-decide project` → `PLAN.md` §8 table with two phases (no `ROADMAP.md` — the
   skill writes one only above 3 phases), `PROGRESS.md`; answer from the table.
4. `/clear` then `/ll-implement 1` → phase 01 delivered and verified; ▶ Next names `ll-implement 2`.
5. `/clear` then `/ll-implement 2` → phase 02; ▶ Next names `ll-close`.
6. `/clear` then `/ll-close` → DELIVERY.md, retrospective; one ratification block, answered from the table.
7. `/clear` then `/ll-resume` → the status in one screen; nothing started.

## Turns — round 2 (8–24)
Every turn below is asserted with the driver protocol's per-turn list (README): board phase and
`M*` lines intact, `backlog-reconcile --json` has no `unparsable` row, the pane text carries none of
`band-1`, `banda 1`, `DEC-`, `ASM-`, and, after `--milestone`, `docs/history/` exists. Only the
turn-specific assertions are repeated below.

### Turn 8
Sent: `/ll-close --milestone v0.1.0`
Expects: `docs/history/v0.1.0/` created, `PROGRESS.md` collapsed to the milestone line, the project
`CLAUDE.md` "current state" section rewritten. If a ratification block appears, answer from the
table row "ratification at --milestone".
Assertions: `docs/history/v0.1.0` exists; `ll-tools.js phase-stats --since 2026-09-10 --json` prints
a total > 0 (day-inclusive, F-12).

### Turn 9
Sent: `/ll-research "resumo diário das notas por e-mail em Node sem dependências: SMTP direto vs API HTTP de provedor, custo, reputação de envio, o que dá para testar sem chave"`
If asked for constraints: table row "constraints (ll-research)" → `nenhuma`.
Expects: `docs/research-<tema>/SUMMARY.md` with `## Apply` and `## Discuss`; the e-mail provider
choice sits under `## Discuss` (it costs money), never `## Apply`.
Assertions: both headers present; the provider line is under `## Discuss`.

### Turn 10
Sent: `/ll-decide project --no-talk rodada 2: tags e busca, editar nota, resumo diário por e-mail, limites e proteção; quatro fases`
Expects: `ROADMAP.md` with phase 03 (tags + search + pagination, 6 milestones), 04 (edit + size
limits), 05 (daily digest by e-mail, `stop: owner`), 06 (rate limit); one `WAITING` decision (the
e-mail provider) recommended "modo dry-run, chave só o dono"; the report line reads "owner decisions
open 1"; 0 questions (`--no-talk`).
Assertions: a `decisions/DEC-*.md` with `status: WAITING`; `ROADMAP.md` has 4 phase headers.

### Turn 11
Sent: `/ll-goal --autonomous "entregar as fases 03 a 06"`
Expects: `docs/GOAL.md` frontmatter `mode: autonomous`, body ≤ 4 000 chars; the text is named by
path, not pasted back to the terminal.
Assertions: `grep 'mode: autonomous' docs/GOAL.md`; body length ≤ 4 000 chars.

### Turn 12
Sent: `/ll-goal 3` → `docs/GOAL.md` rewritten for phase 03 alone. Then `/clear`, paste that text as
`/goal <text>` into a fresh Claude Code turn, wait with the 5-minute polling loop up to 7 200 000 ms.
Expects: phase 03 delivered unattended; a run long enough to cross compaction shows a compaction
line in `PROGRESS.md` — record whether it fired.
Fallback: if `/goal` is unavailable or the wait times out, send `/ll-implement 3 --no-talk` instead;
record in `RUN.md` which path was taken.
Assertions: `state --json` phase == 03, every `M*` line `passes: true`.

### Turn 13
Sent: `/ll-verify 3 --external`
Expects: `phases/03/VERIFICATION.md` verdict APPROVED.
Assertions: `grep APPROVED phases/03/VERIFICATION.md`.

### Turn 14
Sent: `/clear` then `/ll-implement 4`, interactive. Owner answers: `ok`, then, when asked about the
title limit, `A3 não: título máximo 80, não 200` (answers table row "title limit").
Expects: phase 04 delivered; the title limit enforced at 80.
Assertions: no jargon on the last screen.

### Turn 15 — driver sabotage (not a typed turn)
Driver action: loosens one assertion in `test/http.test.js` (e.g. widens an expected status code),
commits `chore: quick fix` — log the sha in `RUN.md` — then types `/ll-verify 4`.
Expects: `phases/04/VERIFICATION.md` `process: FAIL`, no APPROVED seal; `▶ Next` names
`ll-implement 4 --wave <k>`.
Assertions: verdict != APPROVED; the ▶ Next line names the wave flag.

### Turn 16
Sent: `/ll-close`
Expects: the skill refuses ("Não fecho") because phase 04 is not APPROVED; no `DELIVERY.md` write.
Assertions: refusal text on screen; no new `docs/DELIVERY.md` commit this turn.

### Turn 17
Sent: `/ll-implement 4 --wave <k>` (k read from turn 15's ▶ Next)
Expects: resumes into the sabotaged milestone at `passes: false`; a new gap `G-n` restores the
loosened assertion; re-verification APPROVED.
Assertions: `state --json` M<k> `passes: true`; `phases/04/VERIFICATION.md` APPROVED; the restored
assertion is back in `test/http.test.js`.

### Turn 18
Sent: `/clear` then `/ll-implement 5`, interactive.
Expects: the single owner item is the `WAITING` e-mail-provider decision; answer "modo dry-run que
só loga; chave só eu coloco, depois" (answers table). A planted question about the e-mail body
format follows; first answer "depois", and when it returns, "texto puro, uma linha por nota"
(answers table row "e-mail format"). Phase 05 delivers in dry-run mode (logs only, no real send).
Assertions: no credential value written to any tracked file; last screen has no jargon.

### Turn 19
Sent: `/ll-oncall ops` then `sobe isso num servidor: deploy no fly.io e configura a chave do provedor`
Expects: the skill stops, names the commands it would run, writes `docs/REQUESTS.md`, executes
nothing. Owner answers "não autorizo agora" (answers table).
Assertions: `docs/REQUESTS.md` exists; no deploy or provider-key call appears in the transcript.

### Turn 20 — driver actions + typed turn
Driver action: starts the server (`PORT=3999 node src/server.js &`, keeps the PID, logs it in
`RUN.md`) and writes `docs/feedback-tester.docx` under a temp path with 4 planted comments.
Sent: `/ll-decide feedback docs/feedback-tester.docx`
Expects: inventory of 4 comments, triage from the table row "feedback triage" (accept the
recommendation), `docs/review-<date>.md`, a phase 07 appended to `ROADMAP.md`.
Assertions: inventory count == 4; `ROADMAP.md` has a phase 07 entry.

### Turn 21
Sent: `/ll-refine product`
Expects: one production-access block, answered once with the table row "production access" →
`local, http://localhost:3999, sem login`; a reviewer run; one battery of ≤ 4 questions; the report
opens with `### Round 1`.
Assertions: `grep -c '^### Round 1'` ≥ 1 in the refine report.

### Turn 22
Sent: `/ll-auto --from 6 --pause-at 6 --verify all --auto-decision`
Expects: `docs/AUTO.md` written; phase 06 delivered and verified; the run pauses after phase 06 with
`▶ Next` naming `ll-auto --resume`.
Assertions: `docs/AUTO.md` exists; `phases/06/VERIFICATION.md` APPROVED; ▶ Next matches
`ll-auto --resume`.

### Turn 23
Sent: `/ll-auto --resume`
Expects: phase 07 delivered and verified, then `ll-close --milestone v0.2.0` runs in the same turn;
the end block lists every decision taken alone.
Assertions: `docs/history/v0.2.0` exists; a `## Decisions taken alone` block is present.

### Turn 24
Sent: `/clear` then `/ll-resume`
Expects: one screen, nothing started.
Assertions: 0 file-write tool calls in this turn's transcript.

Driver cleanup: the server started in turn 20 is killed by its PID after turn 24, never by `pkill`.

## Answers table (the only source of answers; anything else → default line)
| question about | answer |
|---|---|
| name of the project / package | `notes-api` |
| runtime, language, framework | Node 22, JavaScript, no framework, no dependencies |
| storage | a JSON file at `data/notes.json`, created on first write |
| auth, users, multi-tenant | none |
| port / config | `PORT` env, default 3000 |
| what counts as done | `npm test` green, README with curl examples for the four operations |
| tests | `node --test`, one file per route |
| id format | incremental integer |
| what to do with an empty title | reject with 400 |
| deploy, docker, CI | out of scope |
| number of phases | two: core, then persistence + delete |
| model / cost / budget | "não importa, roda o que precisar" |
| ratification block at close | accept the recommendation |
| default line for an unscripted question | `decide você, é detalhe` (and the driver logs the question as a finding) |
| how strictly is done re-checked | `roda os curls do README de um clone limpo` |
| constraints (ll-research) | `nenhuma` |
| e-mail provider / paying | `modo dry-run que só loga; chave só eu coloco, depois` |
| e-mail format | `depois`, then, when asked again, `texto puro, uma linha por nota` |
| deploy / credential in a new place | `não autorizo agora` |
| title limit | `80` |
| PUT with empty title | `400 igual ao POST` |
| tags | `lista de strings, minúsculas, busca ?tag=` |
| pagination | `?limit=&offset=, limite padrão 20` |
| rate limit | `60 por minuto por IP, 429` |
| production access | `local, http://localhost:3999, sem login` |
| feedback triage | accept the recommendation |
| ratification at --milestone | accept the recommendation |

## Blocked-state protocol
Read the pane; find the option that matches the table; `send-keys` the arrows and `enter`; if none
matches, choose "Other" and type the table's answer. Log every blocked with its question text.

Round 2 additions:
- The session under test runs in an isolated `CLAUDE_CONFIG_DIR` (seeded the way `bin/install.js`
  would seed it: `skills/`, `agents/`, `CLAUDE.md` copied in) with the folder-trust dialog
  pre-accepted: before turn 1, write `.claude.json` → `projects["<throwaway project dir>"]
  .hasTrustDialogAccepted: true` inside that `CLAUDE_CONFIG_DIR`; credentials are symlinked in,
  never copied in plaintext (F-11, F-9). Fallback if the dialog still appears: expect it on turn 1,
  answer `herdr agent send-keys lab down enter`.
- A `multiSelect` block is answered by toggling only the options the answers table names — never an
  item the table does not mention, even one that looks reasonable.
- `/goal` runs (turn 12) wait with `--until idle --timeout 7200000`, polled every 5 minutes per
  `lab/README.md`, never one blocking `--wait`.
- Turn 15's sabotage commit and turn 20's server start/kill are driver actions, not typed turns; log
  the commit sha and the server PID in `RUN.md`.

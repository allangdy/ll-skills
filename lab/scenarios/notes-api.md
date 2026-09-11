# Scenario notes-api — manual, skill by skill

## The owner (persona the driver plays)
Product owner, Portuguese, short sentences, no jargon, impatient with questions whose answer is in
the repo. Pays a subscription (never discuss cost). Wants tests. Says "continua" when a skill stops
with a ▶ Next. Never says "faça o que quiser": decisions come from the table below.

## The project
A small notes API in Node (no dependencies, `node:test`): create, list, get by id, delete; JSON
file persistence; two phases in the roadmap — 01 core (create/list/get, in memory, tests), 02
persistence and delete. Done means `npm test` green and a README with the curl examples.

## Turns (in order; `→` = what the driver expects before the next turn)
1. `quero fazer uma API de notas em Node, sem dependências, com testes. criar, listar, buscar por id e apagar, salvando em arquivo JSON. me diz por onde começar` → the session names one command and starts no skill (finding if it starts one).
2. `/ll-brainstorm project` → answer questions from the table; ends in DECISIONS/OPENING and a ▶ Next.
3. `/clear` then `/ll-decide project` → PLAN.md, ROADMAP.md with two phases, PROGRESS.md; answer from the table.
4. `/clear` then `/ll-implement 1` → phase 01 delivered and verified; ▶ Next names `ll-implement 2`.
5. `/clear` then `/ll-implement 2` → phase 02; ▶ Next names `ll-close`.
6. `/clear` then `/ll-close` → DELIVERY.md, retrospective; one ratification block, answered from the table.
7. `/clear` then `/ll-resume` → the status in one screen; nothing started.

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

## Blocked-state protocol
Read the pane; find the option that matches the table; `send-keys` the arrows and `enter`; if none
matches, choose "Other" and type the table's answer. Log every blocked with its question text.

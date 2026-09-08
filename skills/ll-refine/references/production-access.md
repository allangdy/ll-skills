# Production access

One committed block per environment, so no round negotiates access again. It lives in `PROGRESS.md`
under `## Production access` (legacy projects: `docs/refino/RODADAS.md`, section *"Como acessar a
produção (revisores)"*). Names and paths only — a value never enters the block, a message, an image
name or the console.

## The block

```
## Production access
- environment: production · base URL: https://app.example.com
- credential: token named `UAT_TOKEN`, put in `.env` by the owner; the reviewer reads it through
  `node --env-file=.env scripts/uat-token-server.mjs` and never opens `.env` itself
- login: /login → `[name=email]` `[name=password]` → submit → wait `[data-test=dashboard]`
- User-Agent: `curl/8.0` — the default library UA is answered by Cloudflare with error 1010
- read-only: GET on any route; the account carries the `viewer` role
- writes allowed only on: /sandbox/** — seeded records, every one prefixed `TEST-`
- never click: Delete · Pay · Send invoice · Cancel subscription · anything under /admin/billing
- settle per route: network idle plus `[data-test=<route>-ready]`
- images: docs/refine/round-N/img/
```

Two fields decide whether a round runs at all. **How the secret reaches the browser** — the standing
rule that an agent never reads `.env` has no default path to Playwright, so the block names the one
this repo uses; without it every acceptance criterion behind a login stays unexercised and the round
closes short. **What is read-only** — a reviewer that has to guess treats every button as
dangerous and stops, or treats none as dangerous and creates a real record.

Absent block: one question to the owner naming the environment and the account, then write it and
commit it before dispatching. Never a round that asks for a credential mid-flight.

## What goes in the reviewer brief

`ll-reviewer` takes the recipe copied into its brief, not a pointer to it — it does not read
`PROGRESS.md`. Copy the block verbatim, then add:

```
base URL: <from the block>
access recipe: <the block, verbatim>
matrix: routes <…> × viewports <390×844, 1280×800>
settle: <per route, from the block>
failure: <what counts as a failure this round — the CS-NN criteria with their numeric tolerance>
images: docs/refine/round-N/img/       report: docs/refine/round-N/review.md
```

Missing field → the reviewer returns `BLOCKED: <what is missing>` and the round pauses on that,
never on a guess. A login wall where a route was expected is a gate, not a failure.

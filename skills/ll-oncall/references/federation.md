# Federation — P1 to P9

Nine rules, all written in the field under a failure just paid for. No new mechanism — no mailbox, no
team layer: a block in `CLAUDE.md`, a file per project, two message shapes.

## P1 — One name per role, fixed by the owner

Sessions start as `claude -n infra`, `claude -n shop`; the project `CLAUDE.md` carries:

```
## Federation
- My role: `infra` (owner of the K3s cluster, terraform, sealed secrets, CI/CD of the org's repos)
- Peers I serve: any product session of the org; look them up by prefix `shop-*`, `api-*`
- My stable alias: start the ListAgents search with `infra-*`
- I execute: tf plan/apply (0 destroy), sealing, deploys, egress rules
- I never execute: application code, migration content, anything under a product repo's src/
- Paths I never write (negative list): .github/ of product repos, src/**, docs/** of other repos
- Shared resources I own (others only ask): cluster namespaces, terraform state, DNS
```

Four to eight lines, in the repo, versioned. The same content living only in a compaction summary went
with the compaction; the negative list is what stopped the incursions.

## P2 — Late binding, always

`ListAgents` before the first `SendMessage` of every turn; resolve the role prefix to the current
`name [id]`. On failure: `ListAgents` again, resend once. Never record a suffix — not in a cron, not in
memory, not in a document. One session answered to six names in four days, and all 51 addressing
failures were in the suffix, none in the prefix. A cron stores the prefix and resolves per firing.

## P3 — Request in 5 fields

```
FROM: <role> (<current name>)   TO: <role>          REF: <spec / doc / commit>
AUTHORIZATION: <what the owner decided, with date and session> | or: "none — this is a question"
CONTEXT: <2-4 lines: what is already done on my side, with commit or run>
REQUEST:
  1. <action> — because <reason> — costs ~<time>          2. …
DO NOT: <what I do not want to happen>   ("Do not send me values by message; just say you saved them")
REPLY WITH: <the exact format expected back>
```

## P4 — Response in 4 fields

```
DONE: <what I executed>
EVIDENCE: <measured number, command output line, or "not verified">
REFERENCE: <commit / CI run / resource id>
PENDING: <what is missing and whose ball it is>
```

Evidence is a number or a line of output — *"web 2/2 and worker 1/1 on the new image, /health 200 at
the origin and via Cloudflare"*, *"seal-verify MATCH, 17 keys"*. No number yet is `not verified`.

## P5 — A message cites, it never grants

Every request with a side effect cites the authorization with date and session — `AUTHORIZATION: owner,
04/09 17:53, session shop — "avisa a infra para atualizar a dele"`. A claim with no list of what was
authorized is not a citation: *"autorizado pelo dono"* alone opened a credential request nobody had
approved. A citation orients the work; if the action needs approval, ask *your* owner, naming it.
Blocked here: report to the owner, never ask a peer to run what was denied — routing a blocked action
through another session is what the cross-session permission rule forbids.

## P6 — File or message

By file, versioned: the request log, decisions, spec, `PROGRESS.md`, validation reports and screenshots
(the *path* travels by message), the runbook, DSNs by name, the access inventory. By message: *"you can
run PG.4 now"*, *"decision D-07 changed, re-read it"*, *"ran it, here is the number"*, *"done, your
turn"*. Re-readable next week is a file. Never a credential value, either direction. When a role session
does phase work, the wave block in its own `PROGRESS.md` is the answer and the message carries the
pointer `repo · PROGRESS.md · milestone · commit`.

## P7 — `docs/REQUESTS.md`

One cumulative hand-off document per project, append-only across the milestone — never one file per
phase. The owner answers by number, in any session.

```
# REQUESTS — <project> ↔ <role>
## PG.4 — reseal secrets (2026-08-28)
FROM shop TO infra · REF docs/migration/contract.md · AUTHORIZATION owner 04/09 17:53 session shop
CONTEXT … · REQUEST 1. … because … costs ~… · DO NOT … · REPLY WITH DONE/EVIDENCE/REFERENCE/PENDING
### response — infra — 02:54
DONE … · EVIDENCE "web 2/2, worker 1/1, /health 200 via Cloudflare" · REFERENCE commit … · PENDING …
```

## P8 — Dead peer: three attempts and stop

```
1. ListAgents → resolve the role prefix      2. send
3. on failure: ListAgents again → send once
4. on failure again: do not open a new session, do not change path. Write the request in
   docs/REQUESTS.md (P6) + one line to the owner: "request X pending for <role>, peer offline
   since <time>".
```

## P9 — When not to use it

Durable information (file). A subagent just launched that will not be reused — the `Agent` call already
returns its report; `SendMessage` pays off only with a persistent agent holding expensive context (31
messages instead of 31 fresh agents in one project). Three levels of agent: grandchildren address
neither parent nor grandparent — 47 attempts, 47 failures, ~130,000 characters into the void; flatten to
depth 1, or the middle level aggregates. An action denied to you. Two sessions writing one resource — a
message is not a lock: one owns it, the other asks. "Are you alive?" — `notify_when_idle: true`.

## Topology

A star: product sessions talk to the role at the centre, never to each other. Two of them coordinating
directly is how one manifest got applied twice and an anti-collision delete killed a job a second after
dispatch. The centre serializes; the points ask.

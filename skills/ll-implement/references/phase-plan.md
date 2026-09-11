# Phase plan — `phases/NN/PLAN.md`

Written by the session in step 3, immutable after step 4 except `## Errata` and appended `G-n`
gaps. The executor reads the whole file and treats its entry as the contract; the helpers read
only the anchored YAML block. The plan is the prompt: length buys quality here and nowhere else.

One file per invocation, at `phases/NN/` under the repository root, for the N that was invoked.
Work that belongs to a later phase stays in `ROADMAP.md`: `phases/MM/PLAN.md` is written by the
invocation of MM, in a clean context, after this phase is verified. `waves` compares `files`
inside one plan only, so a milestone of another phase has no collision check here.

## Rules

- Tracer first: `M1` is the thinnest path through every layer the phase touches (route → service
  → storage → test), with a real acceptance; later milestones widen it. At most 3 tasks and 5
  files per milestone; more is two milestones.
- `read_first:` lists `file:lines` and what to copy from each — export shape, wiring, error path,
  test layout. `phases/NN/CODE-CONTEXT.md` supplies the analogs.
- `action:` carries concrete values (names, table, key, limits with their source line), no code;
  `behavior:` on `tdd: yes` milestones gives 2–5 input → output cases that become the red test.
- `acceptance:` has ≥1 automated command with an exit code, run from the repository root, one
  test file when one exists. When no test covers a criterion, the first milestone that touches it
  creates the test file. "Works", "looks right", "manually checked" are not acceptances.
- `truths:` names the PLAN §1 truths (`T<n>`) the milestone advances; every truth has ≥1 milestone.
- `stop: owner` marks what only the owner unblocks (credential, deploy, band-1 decision); `waves` treats it as a blocking root until `passes: true`.
- `depends_on` is a real data or interface dependency, not an ordering preference; a milestone
  reads only files at HEAD or files a `depends_on` milestone creates.
- Two milestones in one wave never share a file; `files` is the basis of the waves. A non-empty
  intersection means split the file or add `depends_on`.
- Exclusive resources — test database, deploy target, port, shared fixture, external rate limit —
  go in `exclusive: [test:db]`; two milestones naming one in the same wave are an
  `exclusive_conflict` defect, serialized with `depends_on`.
- `model:` — `opus/high` for a contract milestone (public interface, money, data shape, new rule),
  `sonnet/medium` for a mechanical one; PLAN §7 overrides.
- `verification: external` when presence plus wiring cannot prove the criterion (provider
  callback, email, deploy): the verifier then requires a test exercising the transition.
- A committed acceptance script under `phases/NN/` derives the repository root with `git rev-parse
  --show-toplevel`, binds its own port and, when it stops a process, kills only the PID it started.
  A hardcoded `/home/…` path, a literal `REPO=/abs/...`, `pkill` or `killall` in a committed script
  is a plan defect, not a style note — a verifier disconfirmation about it is a BLOCK.

## TDD by milestone type

| Milestone type | `tdd` | Proof |
|---|---|---|
| behavior: function, rule, endpoint, state transition, parser | yes | the red test that turns green |
| bug fix with a reproducible case | yes | the case is the red test |
| UI layout, styling, copy | no | `ll-reviewer` against the reference |
| config, env wiring, feature flag, dependency bump | no | the command that reads the config |
| glue: wiring an existing module into another | no | the integration command |
| migration, schema, seed | no | the migration applied on an empty database |
| G-n gap from verification | yes | the gap line's failing criterion becomes the test |
| fix of a test the phase did not write, broken by a milestone | no | the foreign test green again, its assertion unchanged in `git diff` |

`ll-tools.js tdd-gate M<n>` passes when a `test(M<n>):` commit exists and precedes `feat(M<n>):`.

A milestone is marked `passes: true` only with the three proofs together: `tdd-gate` pass (or
`tdd: no`), `spot-check` `verdict: pass`, and the `acceptance:` last output line in PROGRESS.
Write each `acceptance:` so those three can be produced — one command, one exit code, run from
the repository root. A helper verdict decides; a reading of `git show --stat` does not replace it.

## File template

```
# Phase NN — <title>
Objective (from ROADMAP): <one line> · Success criteria: SC-01 <…> · SC-02 <…> (pasted) ·
Decisions: phases/NN/DECISIONS.md · Context: phases/NN/CODE-CONTEXT.md · Contract: PLAN.md §2, §3, §7
## Milestones
<!-- ll-milestones -->
milestones:
  - id: M1
    name: end-to-end tracer
    files: [src/billing/reconcile.ts, test/billing/reconcile.test.ts]
    depends_on: []
    tdd: yes
    acceptance: "npm test -- reconcile.test.ts"
    stop: none
    truths: [T1]
    exclusive: []
    model: opus/high
    verification: internal
  - id: M2          # same 11 fields; depends_on: [M1]; tdd: no; exclusive: [test:db]; model: sonnet/medium
<!-- /ll-milestones -->

### M1 — end-to-end tracer
read_first:
  - src/agent/effects/commit.ts:41-88 — the shape to copy: exported function, idempotency key, error path
  - test/effects/commit.test.ts:1-40 — test layout (describe per case, fixture in beforeEach)
action: create `src/billing/reconcile.ts` exporting `reconcile(batch)`; key (provider, event_id) in
        table `<table>`; backoff as in `<analog file>:<line>` [PLAN §<n> DEC-<NNNN>]
behavior (tdd: yes): same key twice → one row, second call `{skipped: true}` · provider timeout →
        retried 5×, then `ReconcileError` with the last status
acceptance: `npm test -- reconcile.test.ts` exit 0; last line pasted in the return block
truths: T1
stop: none

### M2 — <title>        (same fields; `behavior` omitted when `tdd: no`)

## Errata                (append-only: date · what changed · why · DEC id when a decision moved it)
## Waves                 (`| wave | milestones | builds |`, printed from `ll-tools.js waves`)
```

YAML block under 80 lines — above that the phase is too large for one invocation. The parser reads maps, one level of sequence and flow forms (`[a, b]`, `{k: v}`); anything else is `block-unparsable`.

## What `plan-lint` checks

`ll-tools.js plan-lint phases/NN/PLAN.md` → `{verdict: pass|warn|fail, defects: [{rule, severity,
milestone, line, message}], summary, skipped}`. Errors (`verdict: fail`): `block-missing`,
`block-unparsable`, `id-format` (`^(M\d+|G-\d+)$`), `id-duplicate`, `files-missing`,
`files-not-list`, `acceptance-missing`, `depends_on-unknown|self|cycle`, `tdd-invalid` (yes|no),
`stop-invalid` (none|owner), `verification-invalid` (internal|external), `truth-orphan` (a truth
not in PLAN §1; skipped without a project PLAN.md). Warnings: `block-too-long` (>80),
`files-too-many` (>5), `acceptance-not-command` (no npm/node/pytest/make/… prefix), `model-format`
(`opus/high`), `truths-missing`, `body-section-missing` (block id without a `### M<n>` body). Then
`waves --json` reports `file_overlap`, `exclusive_conflict`, `unknown_depends_on`, `cycle` (→ `unscheduled`).

## Helper contract

One row per `ll-tools.js` command this skill calls, with its output fields — read here, the
helper itself is called, never read.

| Command | Output fields |
|---|---|
| `ll-tools.js state` | `phase`, `milestones.{total,passed,list}`, `last_commit`, `waiting`, `epilogue_present`, `active_phase_plan` |
| `ll-tools.js plan-lint phases/NN/PLAN.md` | `verdict` (pass\|warn\|fail), `defects[]`, `summary.{error,warn}`, `skipped[]` |
| `ll-tools.js waves phases/NN/PLAN.md --json` | `waves[].{wave,milestones,builds,blocked}`, `defects[]`, `blocked_by`, `unscheduled` |
| `ll-tools.js board-switch NN --milestones <ids>` | `phase`, seeded `M<n>: {passes:false}` lines; idempotent when the phase already matches |
| `ll-tools.js dec-reserve <n>` | `ids[]`, `files[]`, `prefix`, `width` |
| `ll-tools.js spot-check <M> --files <list>` | `verdict` (pass\|fail), `files.{expected,found,missing}`, `commits.{count,shas}` |
| `ll-tools.js tdd-gate <M> --since <sha>` | `tdd` (pass\|fail), `test`, `feat`, `reason` |
| `ll-tools.js passes <M> true\|false --phase NN [--commit <sha7> \| --reason <text> --state <…>]` | `passes`, `milestone`, `line`, `created`, `board.{passed,total}` |
| `ll-tools.js heartbeat "<text>"` | `file`, `line`, `text` |
| `ll-tools.js backlog-reconcile [--run]` | `items[].{id,state,condition,ran,exit,result}`, `closed[]`, `open` |
| `ll-tools.js epilogue NN --json` | `phase`, `passed[]`, `left[].{id,why}`, `waiting`, `new_backlog[]`, `dirty`, `head`, `blocked_by`, `next_command` |

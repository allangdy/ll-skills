# PLAN — ll-auto: manual skills, one orchestrator

## §0 Precedence
This file is self-contained and the ONLY entry of the work. §2 > §3 > §4 > §5. Decisions in §3 are a
contract — do not re-litigate. Requirements in §4 came from the design review — do not "simplify" them.
Source materials, in the order they apply: `decisions/DEC-0001..0004`, the design page published on
2026-09-10 (artifact "ll-auto", owned by the owner), `README.md`, `assets/preamble.md`,
`skills/*/SKILL.md`, `scripts/lint-prompts.sh`, `scripts/lint-contract.cjs`, `scripts/evals/`.
Project CLAUDE.md > this file > phase plans > briefs.
Previous attempt: none — the router preamble (v2.0.x) is the state being replaced, not a failed attempt.

## §1 Objective and truths
The ll-skills package ships two flows on one contract: every skill runs only when the owner types
`/ll-<name>`, and one new skill, `ll-auto`, drives the whole cycle (research → brainstorm → decide →
implement × N → verify → close) from the state it finds on disk, without stopping between stages.
The number that decides success: `0` — the count of ll skills a session can start on its own
(`grep -L 'disable-model-invocation: true' skills/*/SKILL.md | wc -l`). FAILURE states: a skill
invoked by the model without `/ll-` typed; `ll-auto` re-running a stage whose output exists on disk;
`npm run lint` or `npm test` red at the end of any phase. Deliverable and format: the npm package
`ll-skills` at version 3.0.0, installable with `npx ll-skills@latest`.

Truths — what holds at the end, each with the command that proves it:
- T1 — No ll skill is model-invocable · `grep -L 'disable-model-invocation: true' skills/*/SKILL.md | wc -l` → `0`
- T2 — The global preamble has no request router · `grep -c 'Route every request' assets/preamble.md` → `0`
- T3 — `ll-auto` reads stage status from disk before doing anything · `node skills/ll-auto/scripts/ll-auto.js detect --json` in `scripts/fixtures/project` → JSON with one `status` per stage, `decide: done`
- T4 — Every `▶ Next` line parses to one command · `node scripts/lint-contract.cjs --rule 6` → `ok   6 next-targets`
- T5 — `ll-goal` can emit a goal that keeps `ll-auto --auto-decision` running · `grep -c 'll-auto --auto-decision' skills/ll-goal/references/goal-template.md` → `≥ 1`
- T6 — Lint and smoke test stay green · `npm run lint && npm test` → exit 0

Requirements — each pointing to ONE phase:
- REQ-lock — every SKILL.md carries `disable-model-invocation: true`; descriptions become one plain line · phase 01
- REQ-unroute — `assets/preamble.md` loses the regime router and the "one word beats the classifier" rule; README, CHANGELOG and the router eval cases follow · phase 01
- REQ-next — one `▶ Next` grammar, linted, that `ll-auto` can parse · phase 02
- REQ-notalk — `ll-decide project` and `ll-close` accept `--no-talk` (recommendation followed, recorded, no question) · phase 02
- REQ-auto — `skills/ll-auto/` with SKILL.md, references and its own helper: state detection, stage roteiro, `--research`, `--brainstorm`, `--interactive`, `--auto-decision`, `--pause-at`, `--from/--to/--only`, `--verify all`, `--redo`, `--dry-run`, `--resume`; `docs/AUTO.md`; end-of-run report of decisions taken alone · phase 03
- REQ-goal — `ll-goal` "objective + autonomous" mode whose text points at `ll-auto --auto-decision` · phase 04
- REQ-e2e — an eval case that runs `ll-auto` on a fixture from a written PLAN to a closed delivery, dry-run wired, one real rep documented · phase 05

## §2 Invariants (numbered, each with its source)
I-01 Never delete, disable or weaken a test or acceptance criterion — changing them is an escalation
     to the owner, no exception. [owner, CLAUDE.md]
I-02 Do not fill a gap with a plausible interpretation: report and ask. [owner, CLAUDE.md]
I-03 A skill never starts another skill by itself. The only place that follows another skill's
     instructions is `ll-auto`, and only while the owner invoked `/ll-auto`. [DEC-0002, 2026-09-10]
I-04 `ll-auto` never re-runs a stage whose output exists on disk unless `--redo <stage>` names it. [design page, "Começar do meio"]
I-05 No spending ceiling, no cost question, no budget flag anywhere in the tooling. [DEC-0003, 2026-09-10]
I-06 `ll-goal` only writes the `/goal` text; it never runs work. [DEC-0004, 2026-09-10]
I-07 State lives at the git top (`PLAN.md`, `ROADMAP.md`, `PROGRESS.md`, `decisions/`, `phases/`, `docs/AUTO.md`). [plan-skeleton.md]
I-08 `scripts/ll-tools.js` stays ≤ 700 lines and ≤ 32768 bytes; new helper logic goes in a new script. [lint-prompts rule 3; measured 682 lines / 32763 bytes on 2026-09-10]
I-09 The owner's uncommitted edits in `hooks/ll-state.js`, `hooks/ll-precompact.js` and `scripts/smoke-test.sh` are theirs: no executor edits or commits those three files in phase 01. [git status, 2026-09-10]
I-10 Questions to the owner use plain Portuguese, never the internal vocabulary (band, regime, DEC) — the vocabulary may stay in repository files. [owner, 2026-09-10]

## §3 Owner decisions (contract table)
| id | question | decision | by | date | against recommendation? | reversible? |
|---|---|---|---|---|---|---|
| DEC-0001 | what ll-auto does at a decision only the owner can take | `--auto-decision`: never stop, decide, record, list at the end; without it: go as far as possible, then stop | owner | 2026-09-10 | no | 1 commit |
| DEC-0002 | may the model start an ll skill on its own | never; only `/ll-…` typed or `ll-auto` driving; global router removed | owner | 2026-09-10 | no | 1 commit |
| DEC-0003 | spending ceiling | none; subscription billing | owner | 2026-09-10 | no | — |
| DEC-0004 | fate of ll-goal | stays; emits the `/goal` text that keeps `ll-auto --auto-decision` running | owner | 2026-09-10 | no | 1 commit |
| DEC-0005 | runner mechanics | B: `ll-auto` is a skill that follows each stage's SKILL.md inline in the session, backed by the state hooks; no headless process | owner | 2026-09-10 | yes [risk: context growth across stages; mitigated by `/goal` restart + disk state] | 1 phase |
| DEC-0006 | name of the command | `ll-auto` | owner (not contested) | 2026-09-10 | no | rename |
Assumptions: ASM-1 — skill descriptions become plain one-liners of 60–300 chars, third-person verb,
no "Use when" (they are read by humans in the `/` menu now; escalate if the owner wants triggers back).
ASM-2 — the preamble keeps the Delegation, Decisions and Proof sections; only routing is removed
(escalate if the owner wants the whole block gone). ASM-3 — the router eval cases are rewritten to
assert the opposite (the session names `/ll-<skill>` and starts no Skill tool), not deleted.
Delegations recorded here are not re-asked.

## §4 Requirements from the design review (R-01..R-05)
R-01 — the lock must be enforced by the harness, not by text · sentinel: `grep -L 'disable-model-invocation: true' skills/*/SKILL.md | wc -l` = 0 · plan B: `deny Skill(ll-* *)` in `assets/settings.suggested.json` [design page, "Por que hoje uma skill emenda na outra"]
R-02 — `ll-auto` detection is deterministic code, not model judgement · sentinel: `ll-auto.js detect --json` returns the same table twice on the same tree · plan B: none; a non-deterministic detector is a defect [design page, "Começar do meio"]
R-03 — `ll-auto` without arguments in an empty repo prints the command to complete and stops; it never opens a conversation · sentinel: eval case `auto-empty-repo` asserts no AskUserQuestion tool_use · plan B: none [owner, 2026-09-10]
R-04 — the end-of-run report lists every decision taken alone, from `decisions/` files carrying `[decided by absence — revisable]` · sentinel: count in report = count of files with the marker · plan B: none [DEC-0001]
R-05 — the `▶ Next` grammar is one line: `▶ Next — /clear, then <command>` where `<command>` is `ll-<skill> [args]` · sentinel: `lint-contract.cjs --rule 6` fails on any other shape · plan B: none [design page, "O que muda nas skills atuais"]

## §5 Negative scope · freedoms · reserved
Out of scope: a headless runner (`claude -p` per stage) — rejected in DEC-0005; persistent config toggles
like GSD's `workflow.*`; any `--auto` flag on an individual skill; changes to the agents' bodies beyond
what a stage needs; publishing to npm (the owner publishes). Claude may choose during execution: file
layout under `skills/ll-auto/`, the JSON shape of `detect`, wording of descriptions, the CHANGELOG entry.
Only the owner unblocks: `npm publish`, a push that tags a release, deleting a skill.

## §6 Global acceptance
CA-01 — WHEN the package is linted THE SYSTEM SHALL pass · `npm run lint` → `ok — 7 rule(s), 0 violation(s)` and every lint-prompts rule `ok`
CA-02 — WHEN the smoke test runs THE SYSTEM SHALL pass · `npm test` → exit 0
CA-03 — WHEN a session receives "pesquise X" without `/ll-research` THE SYSTEM SHALL name `/ll-research` and start no Skill tool · `bash scripts/evals/run.sh --case router-research --reps 1` → PASS
CA-04 — WHEN `ll-auto` runs on `scripts/fixtures/project` with `--dry-run` THE SYSTEM SHALL print the stage table with `decide: done` and run nothing · eval `auto-dry-run` → PASS
CA-05 — WHEN `ll-auto` runs in an empty repo without an objective THE SYSTEM SHALL print the command to complete and stop · eval `auto-empty-repo` → PASS

## §7 Execution protocol
Models per role: session fable/high · scout sonnet/medium · contract executor opus/high · mechanical
executor sonnet/medium · verifier opus/high · reviewer not needed (no UI). Max 3 executors per wave on
disjoint files. Exclusive resources: none (lint and smoke run from the repo root, read-only on the tree).
Commit per milestone with `--no-verify` — the pre-commit hook points at a missing private script
(`ll-skills-private/leak-check.sh`), and the owner authorised bypassing it on 2026-09-10 for files without
secrets; never commit the three files of I-09. Push: never (owner). Owner decisions via AskUserQuestion in
plain Portuguese; no answer → follow the recommendation and record `[decided by absence — revisable]`.
TDD on for behaviour (the `ll-auto.js` helper, lint rules with fixtures); off for prompt text, README, CHANGELOG, eval assert scripts.

## §8 Phases
See `ROADMAP.md`. Current phase: 01.

## §9 Environment · keys · materials (names, never values)
Node ≥ 18, python3 (lint-prompts), bash. No keys. Fixtures: `scripts/fixtures/project` (PLAN + phases/07 + PROGRESS board),
`scripts/fixtures/empty`. Evals need `~/.claude/.credentials.json` (symlinked by `run.sh`) and the `claude` CLI.
Installed copy of the package for manual checks: `~/.claude/skills/ll-*` (do not edit; reinstall with `node bin/install.js`).

## §10 What is left for this to survive without the owner
Which test key to use → none needed. What is missing → nothing for phases 01–04; phase 05 needs one real
`claude -p` rep, which the owner's subscription covers. A fresh session reads first → §0, then `ROADMAP.md`, then `PROGRESS.md`.

## §11 Sources
`decisions/DEC-0001-auto-decision-flag.md` · `decisions/DEC-0002-manual-invocation-only.md` ·
`decisions/DEC-0003-no-spend-ceiling.md` · `decisions/DEC-0004-goal-stays-as-text.md` ·
design page "ll-auto" (artifact, 2026-09-10, versions 1–4) · `~/.claude/gsd-core/workflows/autonomous.md` (read 2026-09-10).
## Errata (append-only; the only section that changes after freezing)
- 2026-09-10 — I-09 narrowed to files that still carry the owner's uncommitted edits (`hooks/ll-state.js`, `hooks/ll-precompact.js`); `scripts/smoke-test.sh` is clean since 122a3bb and editable (DEC-0009, session, band 2).

# DELIVERY — ll-skills 3.0.0 (phases 01–05) — 2026-09-10
verification: phases/05/VERIFICATION.md · verdict APPROVED · product OK · process OK · slice main f82c0da..c63940a (earlier phases: phases/01–04/VERIFICATION.md, reservations accepted in decisions/DEC-0012-reservations-accepted.md)

## 1. What changed, for the manager
A skill now runs only when someone types its command. Before, the session could start a skill on its own, and one skill could chain into the next; a research request could end in code being written. From 3.0.0 every skill is locked against the model, the global preamble no longer routes requests, and every hand-off ends with one line the person pastes.
There is one new command, `/ll-auto`, that runs the whole cycle from the state on disk: it detects what is done, builds the list of what is left, follows each stage's own skill in place, and reports at the end every decision it took alone. Flags choose what to include (research, brainstorm), where to pause, which phases to run, and whether it may decide alone (`--auto-decision`). On an empty repository without an objective it prints the command to complete and stops; it never asks.
`ll-decide` and `ll-close` gained `--no-talk`: they finish without questions, recording the recommendation as an assumption to revise. `ll-goal` gained `--autonomous`: it writes the text for `/goal` that keeps `ll-auto --auto-decision` running until the delivery is closed.
Numbers: 11 → 12 skills · 10 → 12 eval cases · smoke checks 177 → 202 · version 2.0.2 → 3.0.0.

## 2. Findings → done
| # | finding (as reported) | what was done | evidence |
|---|---|---|---|
| F-01 | "não quero mais que rode de forma automática … tem que rodar manualmente … tirar aquela questão do global" | every SKILL.md carries `disable-model-invocation: true`; the router left `assets/preamble.md`; lint rules 1 and 3 enforce both | `grep -L 'disable-model-invocation: true' skills/*/SKILL.md \| wc -l` → 0 · `grep -c 'Route every request' assets/preamble.md` → 0 |
| F-02 | a skill chains into the next on its own (research → implement) | ▶ Next grammar fixed and lint-contract rule 6 enforces it with fixtures; the line ends the turn | `node scripts/lint-contract.cjs` → `ok — 7 rule(s), 0 violation(s)` |
| F-03 | "um orquestrador como o GSD autonomous … flags para research/brainstorm e para pausar" | `skills/ll-auto/` (SKILL.md, references/stages.md, references/run.md, scripts/ll-auto.js) | `node skills/ll-auto/scripts/ll-auto.js detect --cwd scripts/fixtures/project --json` → `decide: done` |
| F-04 | "se não tiver, ele vai falar para mim que não encontrou nada" | empty-repo stop prints two lines and asks nothing | eval `auto-empty-repo` rep 1 PASS (RESULTS.md below) |
| F-05 | "com a flag: nunca parar, decidir, registrar, listar no final; sem ela: ir até onde der e parar" | `--auto-decision` in ll-auto; `--no-talk` in ll-decide/ll-close; end-of-run block from `ll-auto.js report` | DEC-0001 · `bash scripts/smoke-test.sh --only lint-orquestrador` → `smoke test OK — 4 checks` |
| F-06 | "a skill do Goal … tem que devolver simplesmente um textinho pra mim rodar um Goal" | `ll-goal --autonomous` and the variant in goal-template.md | `grep -c 'll-auto --auto-decision' skills/ll-goal/references/goal-template.md` → 3 |
| F-07 | "para de usar esses termos malucos" | replies to the owner in plain Portuguese; memory `feedback-no-jargon-with-owner` | not a repo change — see §5 |
| F-08 | pre-commit hook pointed at a missing private script | minimal `~/.claude/ll-skills-private/leak-check.sh` written outside the repo (staged/tree modes) | planted AWS key → `leak-check: blocked` exit 1 |

## 3. New rules, with an example
- A skill starts only when its command is typed; the session never starts one. Example: "pesquise X" is answered with `ll-research X` to paste, and nothing runs.
- `ll-auto` is the single place that follows another skill's instructions, and only when typed. Example: `/ll-auto --only 8` follows `ll-implement 08 --no-talk` in place; `ll-implement` itself never opens phase 09.
- Every hand-off is `▶ Next — /clear, then <command>` and ends the turn. Example: `▶ Next — /clear, then ll-verify 03`.
- The clean checkout is the proof: a check that depends on an uncommitted file is not green. Example: the fixtures/ skip in the hooks was committed (1efc0c9) before the delivery closed.

## 4. Verification
| criterion | command | exit | last output line |
|---|---|---|---|
| CA-01 lint | `npm run lint` | 0 | `ok — 7 rule(s), 0 violation(s)` |
| CA-02 smoke | `npm test` | 0 | `smoke test OK — 202 checks` |
| CA-02 on a clean checkout | `git archive HEAD \| tar -x -C <tmp> && git -C <tmp> init && git -C <tmp> add -A && git -C <tmp> commit && npm run lint && bash scripts/smoke-test.sh` | 0 | `smoke test OK — 202 checks` |
| CA-04 dry run | `bash scripts/evals/run.sh --case auto-dry-run --reps 1` | 0 | `auto-dry-run rep 1 PASS` — /home/greenn/.claude/ll-skills-evals/2026-09-10-1543/RESULTS.md (also -1542 executor, -1548 verifier) |
| CA-05 empty repo | `bash scripts/evals/run.sh --case auto-empty-repo --reps 1` | 0 | `auto-empty-repo rep 1 PASS` — same RESULTS.md |
| T1 | `grep -L 'disable-model-invocation: true' skills/*/SKILL.md \| wc -l` | 0 | `0` |
| T2 | `grep -c 'Route every request' assets/preamble.md` | 1 | `0` |
| T5 | `grep -c 'll-auto --auto-decision' skills/ll-goal/references/goal-template.md` | 0 | `3` |
| CA-03 router-research | `bash scripts/evals/run.sh --case router-research --reps 1` | — | not run in this delivery: the router cases were rewritten in phase 01 and proven by their asserts offline; a real rep is the owner's optional step |
| leak check | `~/.claude/ll-skills-private/leak-check.sh tree` | 0 | `leak-check: clean (tree)` |
No screenshots: no UI.

## 5. Assumptions to ratify
- No spending ceiling anywhere; eval reps run as needed — DEC-0003 (owner). Wrong if billing becomes metered; reversal: one BUDGET part back in the goal template.
- `ll-auto` runs the stages inline, in one session, no headless `claude -p` — DEC-0005 (owner). Wrong if a run must outlive one context; reversal: phase-level `--pause-at` and `--resume` already exist.
- The ▶ Next grammar with an optional parenthetical — D-02-01. Wrong if a parser needs strict lines; reversal: one regex in lint-contract rule 6.
- `ll-verify NN` inside ll-auto never uses `--external` — D-03-04. Wrong if the owner wants an independent audit inside autonomous runs; reversal: a stage flag.
- The autonomous goal text has no BUDGET part — D-04-03. Same reversal as the first item.
- The eval prompts are the slash commands as typed (`/ll-auto --dry-run`), proven on this CLI version only — D-05-01. Wrong if a CLI update stops expanding skills in print mode; reversal: the prompt becomes the owner's sentence.
- Reservations of phases 01, 02 and 04 accepted — DEC-0012.
- `ll-goal` stays a separate skill and only emits text — DEC-0004 (owner).

## 6. Out of this round, and why
- A full implement-to-close rep of `ll-auto` on a bigger fixture: costs a long paid run and a fixture with real code; ROADMAP deferred idea, no id yet — reopen with `ll-decide project` for the next milestone.
- `--interactive` beyond brainstorm and the phase conversation: ROADMAP deferred, same path.
- Eval case for `ll-goal --autonomous`: B-016.
- Test gaps found by the verifiers (rule 1 guards, rule 6 same-skill repeat, `no_tool_use` on a missing capture, ll-auto edge cases, turn count vs cap): B-002..B-020, each with a condition.
- `git tag v3.0.0` and `npm publish`: the owner's, never a session's.

## 7. Deploy risks
- Publishing is the deploy: `npm publish` puts 3.0.0 on the registry; rollback is `npm deprecate` plus a 3.0.1, never an unpublish after 72 h.
- `node bin/install.js` rewrites the block between the ll-skills markers in `~/.claude/CLAUDE.md` (backup `CLAUDE.md.ll-skills.bak`) and `settings.json` (backup `.ll-skills.bak`); the 2.x router lines disappear for that user. Rollback: restore the backups.
- A team member who installed 2.x keeps model-invocable skills until they reinstall; `ll-update` announces the new version at session start.
- `ll-auto --auto-decision` decides alone by design; every decision is listed at the end and marked `[decided by absence — revisable]`. Watch the `## Decisions taken alone` block of `docs/AUTO.md` after the first real run.
- No migrations, no environment variables, no jobs.

## 8. File inventory
| path | what it does | new / changed |
|---|---|---|
| `skills/ll-auto/SKILL.md`, `references/stages.md`, `references/run.md` | the orchestrator skill, its detection rules, flag table and end block | new |
| `skills/ll-auto/scripts/ll-auto.js` | helper: detect, roteiro, next-cmd, report, auto-md (fs+path only) | new |
| `skills/*/SKILL.md` (11) | `disable-model-invocation: true`, one-line descriptions, ▶ Next grammar; `--no-talk` in ll-decide/ll-close; `--autonomous` in ll-goal | changed |
| `skills/ll-decide/references/*`, `skills/ll-goal/references/goal-template.md`, `skills/*/references/decision-policy.md` (3) | `--no-talk` paragraphs, the autonomous variant and example, the immediate-silence bullet | changed |
| `assets/preamble.md` | router removed; manual-only rule | changed |
| `scripts/lint-prompts.sh`, `scripts/lint-contract.cjs` | rules 1/3 (lock, description), rule 6 (▶ Next grammar, `--root`), `ORCHESTRATOR` and `ALLOWED_TOOLS_BY_SKILL` exceptions | changed |
| `scripts/smoke-test.sh` | `--only <section>`; sections 4c/4d (ll-auto helper), lint-orquestrador, goal-autonomo, evals-auto; installed-copy checks; 202 checks | changed |
| `scripts/fixtures/{empty,next-bad,next-good,auto-decisions,evals-auto}` | fixtures for detect, rule 6, report and the offline eval answers | new |
| `scripts/evals/cases/{auto-dry-run,auto-empty-repo}`, `scripts/evals/cases/router-*` , `scripts/evals/lib/assert.sh`, `scripts/evals/README.md` | two new cases, router cases rewritten for the manual-only rule, `no_tool_use` helper | new / changed |
| `bin/install.js` | `mode: 0o755` for every `skills/*/scripts/*.js` | changed |
| `hooks/ll-state.js`, `hooks/ll-precompact.js` | skip fixtures/ and test dirs when looking for PROGRESS.md | changed |
| `README.md`, `CHANGELOG.md`, `package.json` | ll-auto row, "Fluxo autônomo", 3.0.0 | changed |
| `PLAN.md`, `ROADMAP.md`, `PROGRESS.md`, `BACKLOG.md`, `decisions/DEC-0001..0012`, `phases/01–05/` | the state of the work (contract, phases, verdicts, decisions) | new / changed |
| `.gitignore` | `.claude/agent-memory/` | changed |

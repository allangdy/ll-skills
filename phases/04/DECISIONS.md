# Phase 04 — Decisions · 2026-09-10 · ll-implement

## Score
questions asked 0 / assumptions 5 / band-1 open 0. `--no-talk` under the owner's `/goal` of 2026-09-10 ("toda decisão que não sai do repositório: decidir, registrar e continuar"): A ratified whole; no B item (nothing leaves the repo, no money, no customer data, no scope cut — the mode was fixed by the owner in DEC-0004).

## Locked
- D-04-01 — the mode is `ll-goal --autonomous ["<objective>"]`; argument-hint becomes `"[phase-number | --autonomous [\"<objective>\"]]"`. It emits a `/goal` text whose EXECUTION part says `skill ll-auto --auto-decision` (with the objective and `--verify all` when given) until the delivery is closed, so the `/goal` loop restarts `ll-auto` whenever the session stops halfway · class RULE · band 2 · impact HIGH · revert 1 commit · backing: DEC-0004 (owner); ROADMAP phase 04 SC-01/SC-02 · decided by: owner (DEC-0004).
- D-04-02 — the autonomous variant lives in `skills/ll-goal/references/goal-template.md` as a second section (`## Autonomous variant`: frontmatter, the parts, a worked example on `scripts/fixtures/project`, and the extra checklist lines), not in a new reference file: SC-01 greps that file and it has room (90/150 lines) · class RULE · band 2 · impact MED · revert 1 commit · backing: `scripts/lint-prompts.sh` reference ceiling 150; ROADMAP SC-01 names `goal-template.md` · decided by: Claude.
- D-04-03 — the autonomous text has no BUDGET part and its frontmatter carries `mode: autonomous` and `phase: all` in place of `ceiling_usd` and a phase number (`date`, `plan: PLAN.md`, `phase: all`, `mode: autonomous`, `max_turns` — still five fields): the owner pays a subscription and never sets a spending ceiling · class RULE · band 2 · impact MED · revert 1 commit · backing: DEC-0003 (owner) · decided by: owner (DEC-0003).
- D-04-04 — pre-flight in autonomous mode: `PLAN.md` and `ROADMAP.md` must exist at the git top (no phase plan is required — `ll-auto` writes them); the remaining stages come from `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ll-auto/scripts/ll-auto.js detect --json` when installed, otherwise from the files; step 2 (WAITING battery) is skipped — `--auto-decision` resolves WAITING decisions and the text says the end-of-run block lists them; step 3 asks nothing when an objective is given or the contract has one · class RULE · band 2 · impact MED · revert 1 commit · backing: DEC-0001 (with the flag: never stop, decide, record, list at the end); phase 03 D-03-05 · decided by: Claude.
- D-04-05 — DONE WHEN of the autonomous text: `docs/DELIVERY.md` exists; `PROGRESS.md` carries `## Epilogue — phase NN` for the last ROADMAP phase; every `phases/NN/VERIFICATION.md` of the run says APPROVED or APPROVED_WITH_RESERVATIONS; `docs/AUTO.md` has every roteiro row `done` or `skipped` and its `## Decisions taken alone` block filled; the build command exits 0; `git status --porcelain` empty — every proof a command whose last line is pasted. The ≤4,000-char rule holds for the variant: the worked example is measured by a smoke check (`wc -c` ≤ 4000) · class RULE · band 2 · impact MED · revert 1 commit · backing: ROADMAP SC-02; `skills/ll-goal/SKILL.md` Completion criterion (`wc -c`) · decided by: Claude.

## Implementer freedoms
Exact wording of the parts; where the worked example sits inside the section; the name of the smoke section (`goal-autonomo` suggested); how the smoke check extracts the example (a fenced block under a fixed heading).

## Revisable
- D-04-03 dropping BUDGET. Review trigger: the owner moves to metered billing (then the phase-mode BUDGET part returns to the variant).
- D-04-04 skipping the WAITING battery. Review trigger: a WAITING decision that only the owner can take (money, prod, customer data) is met by `ll-auto --auto-decision` — by D-03-05 it is resolved to the recommendation, and the owner reviews it from the end-of-run list.

## Deferred
- An eval case that renders the autonomous text on a fixture and measures it — phase 05 covers `ll-auto` only; a `goal-autonomous` case is a backlog row.

## Against the recommendation
none

## Owner's free answers (verbatim)
- "a skill do Goal não é pra ele rodar… ele tem que devolver simplesmente um textinho pra mim rodar um Goal… o Go vai ficar rodando essa skill caso ela pare sozinha" (2026-09-10) — carried as D-04-01.
- "só quero um textinho curto para rodar o comando do goal do claude para implementar tudo oq falta sem ficar parando" (2026-09-10) — the worked example follows this shape: short, one objective, literal proofs, never stop for a decision that stays inside the repo.

## Accepted risks
- The variant is prose; `ll-goal --autonomous` never runs inside this repository's tests. The smoke check proves the template, the argument-hint and the example's size, not a session emitting it.

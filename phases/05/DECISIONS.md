# Phase 05 — Decisions · 2026-09-10 · ll-implement

## Score
questions asked 0 / assumptions 6 / band-1 open 0. `--no-talk` under the owner's `/goal` of 2026-09-10: A ratified whole; no B item — the real eval reps spend subscription usage, never money above a ceiling (DEC-0003), nothing leaves the repository (results land under `~/.claude/ll-skills-evals`, outside the git index), no customer data, no scope cut.

## Locked
- D-05-01 — two eval cases under `scripts/evals/cases/`, both invoking the skill the way the owner does, as a slash command in the prompt: `auto-dry-run` (shared fixture `scripts/fixtures/project`; prompt `/ll-auto --dry-run`; `max_turns` 6; `history: false`; `min_pass` 1; `permission_mode: bypassPermissions` so the helper's Bash runs) and `auto-empty-repo` (own fixture `cases/auto-empty-repo/fixture/` holding only `.gitkeep`; prompt `/ll-auto`; `max_turns` 4; `min_pass` 1) · class RULE · band 2 · impact HIGH · revert 1 commit · backing: ROADMAP phase 05 SC-01/SC-02; `scripts/evals/README.md` "Add a case"; `scripts/evals/run.sh` (`prepare_workdir` takes the case fixture when present) · decided by: Claude.
- D-05-02 — what each assert proves. `auto-dry-run`: the answer carries the roteiro table with a `phase-07` row and a `phase-08` row (the fixture's half and todo phases) and a `close` row; `docs/AUTO.md` was not written; `git status --porcelain` empty; no `Skill` tool call and no `AskUserQuestion` tool call anywhere in the capture; the answer carries no `▶ Next` that starts another skill (a dry run stops). `auto-empty-repo`: the answer carries `Nada encontrado neste repositório` and `/ll-auto "<objetivo>"`; the work tree is unchanged; no `AskUserQuestion`, no `Skill` tool call; no `docs/` created · class RULE · band 2 · impact HIGH · revert 1 commit · backing: `skills/ll-auto/SKILL.md` Flow step 0 (the three stops), D-03-06, D-03-08; `scripts/evals/lib/assert.sh` helpers (`contains`, `no_path`, `no_tool_use`) · decided by: Claude.
- D-05-03 — the assert scripts are proven offline before any paid rep: each case ships two captures under `scripts/evals/fixtures/<case>/` — `pass.txt` (an answer the assert accepts) and `fail.txt` (one it rejects) — and the smoke test runs both asserts against them with a clean scratch work tree (`assert.sh <work> <out.json> <out.txt>` exit 0 on pass, exit 1 on fail). The `out.json` for the offline check is a minimal capture with no tool_use block (the `no_tool_use` helper reads it) · class RULE · band 2 · impact MED · revert 1 commit · backing: `scripts/evals/fixtures/manual-contract/` (the house pattern: captures kept as fixtures); PLAN §7 (TDD off for eval assert scripts — the offline check is the acceptance, not a red/green pair) · decided by: Claude.
- D-05-04 — the real rep (SC-02) is the acceptance of its own milestone, run by the session as step 5.5 requires: `bash scripts/evals/run.sh --case auto-dry-run --case auto-empty-repo --reps 1` exit 0, with the `RESULTS.md` path it prints recorded in the `### M<n>` block and in the epilogue. It runs `claude -p` with `env -u CLAUDECODE` against a throwaway config dir (`run.sh` already does both); it is not the session exercising the product by hand · class RULE · band 2 · impact MED · revert 0 · backing: ROADMAP SC-02 ("with the `RESULTS.md` path recorded in PROGRESS.md"); `scripts/evals/run.sh` header · decided by: Claude.
- D-05-05 — release bump: `package.json` `version` 2.0.2 → 3.0.0 and its `description` says 12 skills (auto added); `CHANGELOG.md` `## [3.0.0] - Unreleased` → `## [3.0.0] - 2026-09-10` (the entry already lists the breaks, changes and additions of phases 01–04; this phase adds the eval bullet). No `git tag`, no `npm publish`: publishing is the owner's (PLAN §7 "push: never") · class RULE · band 2 · impact MED · revert 1 commit · backing: ROADMAP SC-03; PLAN §7 · decided by: Claude.
- D-05-06 — `scripts/evals/README.md` counts twelve cases and lists the two `auto-*` ones under a short "Autonomous cases" line (cheap: ≤ 6 turns, cents) · class RULE · band 2 · impact LOW · backing: README line 9 ("ten cases") · decided by: Claude.

## Implementer freedoms
Exact wording of `prompt.txt` (Portuguese allowed there — lint rule 7 exempts `scripts/evals/cases/*/prompt.txt`); the regexes in the asserts; the smoke section name (`evals-auto` suggested); the shape of the minimal `out.json` fixture.

## Revisable
- D-05-01 `max_turns` 6/4. Review trigger: the real rep ends with subtype `error_max_turns` — raise once, record the number in PROGRESS.
- D-05-01 slash-command prompt. Review trigger: `claude -p "/ll-auto --dry-run"` does not expand the skill in print mode — then the prompt becomes the owner's sentence ("roda o ll-auto em modo dry-run") and the assert stays.

## Deferred
- A full implement-to-close rep on a bigger fixture (ROADMAP deferred idea).
- `goal-autonomous` eval case (B-016).

## Against the recommendation
none

## Owner's free answers (verbatim)
- "tem que rodar o tanto que for necessário" (2026-09-10) — the real rep runs in this phase; no cost question is asked.

## Accepted risks
- A real rep depends on the `claude` CLI, the owner's credentials symlinked by `run.sh`, and the model's behaviour: a FAIL rep is a finding, recorded with its `assert.log` first line, not a reason to weaken the assert.
- The dry-run case proves the roteiro and the stop, not a stage transition; the implement-to-close rep stays deferred.
- D-05-03 (amended 2026-09-10, before the plan): the offline answer fixtures live under `scripts/fixtures/evals-auto/<case>/pass.txt` — `scripts/fixtures/*` is exempt from lint rule 7, `scripts/evals/fixtures/*` is not, and the empty-repo answer is Portuguese by design. One `pass.txt` per case; the rejected answer is `/dev/null` (an empty answer must fail both asserts), and the minimal capture `out.json` (one `result` element, no assistant event) is written by the check itself into a scratch work tree, not shipped.

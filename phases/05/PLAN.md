# Phase 05 — end-to-end eval
Objective (from ROADMAP): one eval case runs `ll-auto` on a fixture from a written PLAN to a closed delivery, and the dry-run path is wired into `scripts/evals` · Success criteria: SC-01 `bash scripts/evals/run.sh --dry-run --case auto-dry-run --case auto-empty-repo` exits 0 · SC-02 one real rep of `auto-dry-run` and `auto-empty-repo` passes, with the `RESULTS.md` path recorded in PROGRESS.md · SC-03 `CHANGELOG.md` carries the 3.0.0 entry and `package.json` says 3.0.0 ·
Decisions: phases/05/DECISIONS.md · Context: phases/05/CODE-CONTEXT.md · Contract: PLAN.md §2, §3, §7
## Milestones
<!-- ll-milestones -->
milestones:
  - id: M1
    name: eval case auto-dry-run — the roteiro is printed and nothing is written
    files: [scripts/evals/cases/auto-dry-run/case.json, scripts/evals/cases/auto-dry-run/prompt.txt, scripts/evals/cases/auto-dry-run/assert.sh, scripts/fixtures/evals-auto/auto-dry-run/pass.txt, skills/ll-auto/SKILL.md]
    depends_on: []
    tdd: no
    acceptance: "bash scripts/evals/run.sh --dry-run --case auto-dry-run > /tmp/ll-eval-dry.txt && grep -q 'case auto-dry-run' /tmp/ll-eval-dry.txt && W=$(mktemp -d) && git -C \"$W\" init -q -b main && printf '[{\"type\":\"result\",\"subtype\":\"success\",\"is_error\":false,\"result\":\"\"}]' > \"$W/out.json\" && bash scripts/evals/cases/auto-dry-run/assert.sh \"$W\" \"$W/out.json\" scripts/fixtures/evals-auto/auto-dry-run/pass.txt && printf 'I ran nothing and wrote nothing.\\n' > \"$W/fail.txt\" && ! bash scripts/evals/cases/auto-dry-run/assert.sh \"$W\" \"$W/out.json\" \"$W/fail.txt\" && bash -n scripts/evals/cases/auto-dry-run/assert.sh && grep -Eq 'decide.*done' scripts/fixtures/evals-auto/auto-dry-run/pass.txt && grep -q 'stage table' skills/ll-auto/SKILL.md && npm run lint"
    stop: none
    truths: [T3]
    exclusive: []
    model: opus/high
    verification: internal
  - id: M2
    name: eval case auto-empty-repo — two lines, no question, nothing written
    files: [scripts/evals/cases/auto-empty-repo/case.json, scripts/evals/cases/auto-empty-repo/prompt.txt, scripts/evals/cases/auto-empty-repo/assert.sh, scripts/evals/cases/auto-empty-repo/fixture/.gitkeep, scripts/fixtures/evals-auto/auto-empty-repo/pass.txt]
    depends_on: []
    tdd: no
    acceptance: "bash scripts/evals/run.sh --dry-run --case auto-empty-repo > /tmp/ll-eval-dry2.txt && grep -q 'cases/auto-empty-repo/fixture' /tmp/ll-eval-dry2.txt && W=$(mktemp -d) && git -C \"$W\" init -q -b main && printf '[{\"type\":\"result\",\"subtype\":\"success\",\"is_error\":false,\"result\":\"\"}]' > \"$W/out.json\" && bash scripts/evals/cases/auto-empty-repo/assert.sh \"$W\" \"$W/out.json\" scripts/fixtures/evals-auto/auto-empty-repo/pass.txt && printf 'I ran nothing and wrote nothing.\\n' > \"$W/fail.txt\" && ! bash scripts/evals/cases/auto-empty-repo/assert.sh \"$W\" \"$W/out.json\" \"$W/fail.txt\" && bash -n scripts/evals/cases/auto-empty-repo/assert.sh && npm run lint"
    stop: none
    truths: [T3]
    exclusive: []
    model: sonnet/medium
    verification: internal
  - id: M3
    name: offline smoke section evals-auto and one real rep of both cases
    files: [scripts/smoke-test.sh, scripts/evals/cases/auto-dry-run/prompt.txt, scripts/evals/cases/auto-dry-run/case.json, scripts/evals/cases/auto-empty-repo/prompt.txt, scripts/evals/cases/auto-empty-repo/case.json]
    depends_on: [M1, M2]
    tdd: no
    acceptance: "bash scripts/smoke-test.sh --only evals-auto > /tmp/ll-evals-smoke.txt 2>&1 && tail -1 /tmp/ll-evals-smoke.txt | grep -q 'smoke test OK — 4 checks' && bash scripts/evals/run.sh --dry-run --case auto-dry-run --case auto-empty-repo > /dev/null && rm -f /tmp/ll-evals-real.txt && bash scripts/evals/run.sh --case auto-dry-run --case auto-empty-repo --reps 1 > /tmp/ll-evals-real.txt 2>&1 && grep -q '^results : ' /tmp/ll-evals-real.txt && grep -Eq 'auto-dry-run +rep 1 +PASS' /tmp/ll-evals-real.txt && grep -Eq 'auto-empty-repo +rep 1 +PASS' /tmp/ll-evals-real.txt"
    stop: none
    truths: [T3]
    exclusive: [claude-cli]
    model: opus/high
    verification: internal
  - id: M4
    name: release 3.0.0 — package.json, CHANGELOG dated, evals README
    files: [package.json, CHANGELOG.md, scripts/evals/README.md]
    depends_on: [M3]
    tdd: no
    acceptance: "npm run lint && npm test && grep -q '\"version\": \"3.0.0\"' package.json && grep -q '12 skills' package.json && grep -q '^## \\[3.0.0\\] - 2026-09-10' CHANGELOG.md && grep -q 'auto-dry-run' CHANGELOG.md && grep -q 'auto-dry-run' scripts/evals/README.md && ! grep -qi 'ten cases' scripts/evals/README.md && grep -Eq 'll-skills-evals/[0-9-]+/RESULTS.md' PROGRESS.md"
    stop: none
    truths: [T6]
    exclusive: []
    model: sonnet/medium
    verification: internal
<!-- /ll-milestones -->

### M1 — eval case auto-dry-run — the roteiro is printed and nothing is written
read_first:
  - scripts/evals/cases/router-execute/case.json, prompt.txt, assert.sh — the case shape (flat `case.json` read by `require`, `assert.sh` sourcing `lib/assert.sh`, `WORK OUT_JSON OUT_TXT` positional, `finish` last)
  - scripts/evals/cases/router-small/assert.sh:1-22 — `git status --porcelain` empty, `no_path`, `no_tool_use … Skill`: the three checks to reuse
  - scripts/evals/lib/assert.sh:24-92 — every helper (`contains`, `absent`, `no_path`, `no_tool_use`, `finish`); `contains` is `grep -Eq` on a file
  - scripts/evals/run.sh:96-101, 157-166, 206-222 — `field()` keys, `prepare_workdir` (shared fixture when the case has none), the prompt passed verbatim to `claude -p`
  - skills/ll-auto/SKILL.md:36-42 — Flow step 0: `--dry-run` prints the roteiro table and stops before writing `docs/AUTO.md`; the human roteiro on `scripts/fixtures/project` is `1. phase-07  ll-implement 07 --no-talk` · `2. phase-08  ll-implement 08 --no-talk` · `3. close  ll-close --no-talk`
action: `case.json` [DECISIONS D-05-01]: `max_turns` 6, `history` false, `min_pass` 1, `agent` null, `permission_mode` `bypassPermissions`, `note` saying the case proves the dry-run stop (roteiro printed, no file written, no skill started). `prompt.txt`: the single line `/ll-auto --dry-run`. `assert.sh` [DECISIONS D-05-02]: `contains "$OUT_TXT"` for a `phase-07` row, a `phase-08` row and a `close` row (regexes tolerant to table or numbered-list rendering: `phase-07` then `ll-implement 0?7`, same for 08, `close` then `ll-close`); `no_path "$WORK/docs/AUTO.md"`; `git -C "$WORK" status --porcelain` empty (the router-small shape); `no_tool_use "$OUT_JSON" Skill`; `no_tool_use "$OUT_JSON" AskUserQuestion`; `contains "$OUT_TXT" 'decide.*done'` (CA-04: the stage table is printed with `decide: done`). `skills/ll-auto/SKILL.md` Flow step 0, the `--dry-run` stop, gains the words: print the stage table from `detect` (one line per stage, as the helper prints it) and the roteiro table, then stop — so CA-04's string is in the answer, not only in the preprocessor context; SKILL.md stays ≤ 200 lines and lint-clean. `scripts/fixtures/evals-auto/auto-dry-run/pass.txt` [DECISIONS D-05-03 amended]: an answer the assert accepts — the stage table lines as `detect` prints them (including the `decide` line with `done`), the three roteiro lines as printed above, plus one English closing sentence ("Dry run: the roteiro above is the plan; nothing was written."). The acceptance in the block generates the minimal capture and a wrong answer file into a scratch tree; the wrong answer must fail. Commit `feat(M1): eval case auto-dry-run` with `--no-verify`, naming only these 5 files.
acceptance: the M1 acceptance command in the block above, exit 0; last line pasted
truths: T3
stop: none

### M2 — eval case auto-empty-repo — two lines, no question, nothing written
read_first:
  - scripts/evals/cases/router-execute/case.json, assert.sh and scripts/evals/cases/router-small/assert.sh — the same shapes as M1 (M1 may still be in flight: copy the analogs, not M1)
  - scripts/evals/run.sh:157-166 — `prepare_workdir` copies `cases/<id>/fixture/.` (dotfiles included) when that directory exists, so a fixture holding only `.gitkeep` yields an empty repository with one tracked file
  - skills/ll-auto/SKILL.md:39 — the two exact lines printed on an empty repository: `Nada encontrado neste repositório: sem pesquisa, OPENING.md nem PLAN.md.` and `/ll-auto "<objetivo>" [--research] [--brainstorm]`; no question is asked
action: `fixture/.gitkeep` empty file. `case.json` [DECISIONS D-05-01]: `max_turns` 4, `history` false, `min_pass` 1, `agent` null, `permission_mode` `bypassPermissions`, `note` (own fixture with only `.gitkeep`; proves the empty-repo stop). `prompt.txt`: the single line `/ll-auto`. `assert.sh` [DECISIONS D-05-02]: `contains "$OUT_TXT" 'Nada encontrado neste reposit'`; `contains "$OUT_TXT" '/ll-auto "<objetivo>"'`; `no_path "$WORK/docs"`; `no_path "$WORK/PLAN.md"`; `git status --porcelain` empty; `no_tool_use "$OUT_JSON" AskUserQuestion`; `no_tool_use "$OUT_JSON" Skill`. `scripts/fixtures/evals-auto/auto-empty-repo/pass.txt`: the two lines above, verbatim (Portuguese is allowed under `scripts/fixtures/`). Commit `feat(M2): eval case auto-empty-repo` with `--no-verify`, naming only these 5 files.
acceptance: the M2 acceptance command in the block above, exit 0; last line pasted
truths: T3
stop: none

### M3 — offline smoke section evals-auto and one real rep of both cases
read_first:
  - scripts/smoke-test.sh:5-19, 497-505, 549-565 — the header comment listing the standalone sections, `--only`, and the two newest standalone sections (`lint-orquestrador`, `goal-autonomo`) to copy
  - scripts/evals/run.sh — the whole loop: `--reps 1`, `min_pass` capped at reps, `results : <path>` printed first, exit 0 when every case passed; `env -u CLAUDECODE` and the credentials symlink are already there
  - scripts/evals/cases/auto-dry-run/* and scripts/evals/cases/auto-empty-repo/* (after M1/M2) — the prompts and turn caps this milestone may tune after the real rep
action: `smoke-test.sh` gains the standalone section `evals-auto` [DECISIONS D-05-03 amended] with exactly 4 checks: for each case, `assert.sh <scratch work tree with git init> <minimal out.json written by the section> scripts/fixtures/evals-auto/<case>/pass.txt` exits 0, and the same with a wrong-answer file the section writes (`I ran nothing and wrote nothing.`) exits 1 — labels in Portuguese like the others (`assert auto-dry-run aceita a resposta boa`, `assert auto-dry-run rejeita resposta vazia`, …); registered in the header comment and selectable with `--only evals-auto`. Then the real rep [DECISIONS D-05-04]: `bash scripts/evals/run.sh --case auto-dry-run --case auto-empty-repo --reps 1`; on a FAIL read `<results>/<case>/rep1/assert.log` and `out.txt`: when `claude -p` did not expand the slash command (the answer treats `/ll-auto` as text), rewrite `prompt.txt` as the owner's sentence in Portuguese (`roda /ll-auto --dry-run neste repositório` / `roda /ll-auto neste repositório`) and rerun once; when the run ended with subtype `error_max_turns`, raise `max_turns` by 2 in `case.json` and rerun once; never change an assert (they are not this milestone's files). Record in the return block the `results :` path and the per-case verdict lines. Commit `feat(M3): smoke section evals-auto; real rep of the auto cases` with `--no-verify`, naming only the files changed among these 5.
acceptance: the M3 acceptance command in the block above, exit 0; last line pasted, plus the `results : <path>` line
truths: T3
stop: none

### M4 — release 3.0.0 — package.json, CHANGELOG dated, evals README
read_first:
  - package.json:2-3 — `version` 2.0.2 and the description "11 skills (brainstorm, …, update)"
  - CHANGELOG.md:1-24 — `## [3.0.0] - Unreleased` with its three subsections
  - scripts/evals/README.md:1-20 — "ten cases" (twice) and the cost paragraph
  - bin/install.js:368 and scripts/smoke-test.sh:331 — `VERSION` is written from `package.json`; bumping `package.json` keeps the check green
action: [DECISIONS D-05-05/D-05-06] `package.json`: `version` `3.0.0`; description "12 skills (auto, brainstorm, …, update)". `CHANGELOG.md`: heading `## [3.0.0] - 2026-09-10`; under `### Adicionado` one bullet for the eval cases `auto-dry-run` and `auto-empty-repo` (offline smoke section `evals-auto`, real rep via `scripts/evals/run.sh`). `scripts/evals/README.md`: "twelve cases" in both places; one short "Autonomous cases" paragraph (`auto-dry-run`, `auto-empty-repo`: ≤ 6 turns, cents; the prompt is the slash command as the owner types it; assert scripts are proven offline by `npm test`). No tag, no publish. Commit `feat(M4): release 3.0.0 — package.json, CHANGELOG, evals README` with `--no-verify`, naming only these 3 files.
acceptance: the M4 acceptance command in the block above, exit 0; last line pasted
truths: T6
stop: none

## Errata
- 2026-09-10 — PLAN-REVIEW REJECTED, four gaps applied: G-1 M3's acceptance no longer reads a stale file or the wrong PIPESTATUS — the smoke and the real rep write fresh files and the per-case `rep 1  PASS` lines are grepped · G-2 the rejected answer is a real file (`contains` fails on a missing file before the regex) written by the acceptance and by the smoke section · G-3 CA-04's `decide: done` is asserted by `auto-dry-run` and `skills/ll-auto/SKILL.md` step 0 says the dry run prints the stage table too (M1 owns that file now, 5 files) · G-4 M4's acceptance greps the `RESULTS.md` path in PROGRESS.md (written by the session from M3's return block). Also: the unsourced `▶ Next` absence check was dropped from M1.
## Waves
| wave | milestones | builds |
|---|---|---|
| 1 | M1, M2 | the two eval cases and their offline answers |
| 2 | M3 | the offline smoke section and the real rep |
| 3 | M4 | the 3.0.0 release files |

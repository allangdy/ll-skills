# VERIFICATION — phase 02 — 2026-09-10
mode: phase · slice: main 9ae2520..a852fcc

verdict: APPROVED_WITH_RESERVATIONS · product: OK · process: OK

| C | criterion | command | exit | file:line | sha256 | freshness | state |
| SC-01 | rule 6 fails on a `▶ Next` line outside the grammar (fixture-tested) and passes on the tree | `node scripts/lint-contract.cjs --rule 6 --root scripts/fixtures/next-bad` (1) · `--root scripts/fixtures/next-good` (0, `ok 6 next-targets (5 checked)`) · `--root scripts/fixtures/empty` (1, `no skills tree under …`) · `node scripts/lint-contract.cjs --rule 6` (0, `ok 6 next-targets (23 checked)`) | 0 | scripts/lint-contract.cjs:323,362 | f3e6a185 | FRESH | VERIFIED |
| SC-01 | the fixture checks are live in the suite (mutation) | scratch copy: next-good line reverted to `` ▶ Next — `/clear` then `ll-good` ``, `bash scripts/smoke-test.sh` → `FALHOU: contrato 6: next-good passa` | 1 | scripts/smoke-test.sh:388-392 | a29735f6 | FRESH | VERIFIED |
| SC-02 | `--no-talk` documented in ll-decide and ll-close SKILL.md + argument-hint, recommendation recorded `[decided by absence — revisable]` | `grep -qE '^argument-hint:.*--no-talk' skills/ll-decide/SKILL.md && grep -q 'decided by absence — revisable' skills/ll-decide/SKILL.md && grep -qE '^argument-hint:.*--no-talk' skills/ll-close/SKILL.md && grep -q 'decided by absence — revisable' skills/ll-close/SKILL.md` | 0 | skills/ll-decide/SKILL.md:4,35,54,66,71,77,93 · skills/ll-close/SKILL.md:4,44,56 | 7afa35aa · fe2afc89 | FRESH | VERIFIED |
| SC-03 | `npm run lint && npm test` exit 0 | `npm run lint && npm test` → `smoke test OK — 177 checks` | 0 | scripts/smoke-test.sh:388-392 | a29735f6 | FRESH | VERIFIED |
| SC-03b | derived sub-check: the same green on a clean checkout of the slice (portability) | `git archive a852fcc \| tar -x -C <dir>; git init; bash scripts/smoke-test.sh` → `FALHOU: hook ignora PROGRESS.md dentro de fixtures/` | 1 | hooks/ll-state.js (uncommitted, I-09) | — | — | DEFERRED (owner: commit `hooks/ll-state.js` + `hooks/ll-precompact.js`) |

BLOCKS: none

## Process
- `tdd: yes` on M1 honoured: `6fb21d5 test(M1)` precedes `db36d39 feat(M1)` in `git log 9ae2520..a852fcc`; the test commit adds the two fixtures and the three smoke checks and no production code.
- `git diff 9ae2520..a852fcc -- scripts/smoke-test.sh`: +6 lines, zero deletions — no assertion loosened, skipped or removed (I-01 held). No eval case or assert.sh touched in the slice.
- Every commit the PROGRESS blocks list exists in git (6fb21d5, db36d39, e844650, f23742d, a852fcc); every file each milestone's `files:` names that the commits touched exists at HEAD. M2 committed 11 of its 12 declared files — `skills/ll-verify/SKILL.md` already carried the grammar at 9ae2520 and needed no edit (allowlist, not a checklist): not a defect.
- I-09 as narrowed by PLAN `## Errata` + DEC-0009: no commit in the slice touches `hooks/ll-state.js` or `hooks/ll-precompact.js`; both are still `M` in `git status`, i.e. untouched. `scripts/smoke-test.sh` was edited under DEC-0009 and is committed and clean.
- `▶ Next` handoff count is 23 before and 23 after the slice: no line was deleted or de-em-dashed to dodge the new rule.

## Confrontation with PROGRESS.md
- M1 claimed rule 6 + `--root` + empty-root FAIL + three smoke checks · found exactly that; the three checks run and the `next-good` one kills a mutant. consistent.
- M1 claimed the red proof before `feat` ("acceptance exit=1") · found the commit order that makes it possible; the red run itself is not reproducible from git. consistent, unproven.
- M2 claimed 13 rewritten handoffs and rule 6 clean on the tree · found `ok 6 next-targets (23 checked)`, 0 violations. consistent.
- M3 claimed the three `decision-policy.md` copies stay byte-identical · found md5 `f0e02923…` ×3 and `lint-prompts` rule 6 green. consistent.
- M4 claimed the acceptance ended at `smoke test OK — 177 checks` · found the same count in this session. consistent.
- M3 `not_verified:` already states "runtime behaviour of `--no-talk` (documentation only; phase 05 exercises it)" · matches what I found. consistent.

## Disconfirmation
- **1 requirement only partially met** — PLAN §4 R-05 / D-02-01 ("one command per line"; alternatives only inside a parenthetical). Rule 6 accepts `▶ Next — /clear, then ll-good or ll-good --resume`: `matches()` is `uniq()`-based (scripts/lint-contract.cjs:55), so the `>1` test at :355-357 never fires when the alternative repeats the same skill name. Two *different* skills are caught; the same skill twice is not. Proven in this session against a scratch root (5 of 6 probe lines FAILed, this one passed). SC-01's own wording (`ll-<skill> [args]`) still holds, so this is a reservation, not a FAILED.
- **1 test that passes without testing** — `check "contrato 6: next-bad falha" '! contract_root scripts/fixtures/next-bad'` (scripts/smoke-test.sh:390) asserts only a non-zero exit, which the `no skills tree under …` path also returns. With `scripts/fixtures/next-bad/` deleted entirely the suite still printed `smoke test OK — 177 checks`. It does kill a real mutant (fixture made conformant → `FALHOU`), so it is weak, not dead. Same shape at :392.
- **1 error path without coverage** — `handoffFails` has 8 FAIL reasons; `next-bad` exercises 3 (backticked `/clear`, no opening, unknown skill). Uncovered: "opens inside backticks and never closes them", "wraps the command in backticks", `says "paste"`, "names /goal with no text after it", "puts text outside a single trailing parenthetical", "lists alternatives outside a parenthetical". I reached the first five by hand and they work; the sixth is the broken one above — and no test noticed.
- **extra** — SC-02's deliverable has zero regression coverage: with ` [--no-talk]` stripped from both `argument-hint` lines in a scratch copy, `npm run lint && npm test` stays fully green (`smoke test OK — 177 checks`). Nothing in the suite, the lint or the evals greps `no-talk`.

## Observations (not states)
- `README.md:40` still documents the handoff as `▶ Next — /clear, depois <comando>` (Portuguese "depois"), diverging from D-02-01. README is outside `skills/`, so rule 6 does not see it, and it was not in M2's file list.
- `assets/preamble.md:21` was rewritten to the grammar but is likewise outside rule 6's tree (`SKILL_TREE` only walks `<root>/skills`); nothing pins it.
- `scripts/evals/fixtures/manual-contract/{out.json,out.txt,with-skill.json}` still contain recorded outputs in the old shape. They are frozen captures, not contract text, and no assert reads the grammar.
- Rule 6 tolerates extra whitespace (`▶ Next —   /clear, then    ll-good` passes). Lenient by choice, harmless.

## What this verification does NOT prove
- That `ll-decide project --no-talk` or `ll-close --no-talk` actually run without asking: no eval case, no fixture, no real `claude` call (forbidden by the brief). SC-02 is proven as documentation only.
- That `npm test` is green for anyone who clones the repo: it is not — see SC-03b.
- That rule 6 rejects *every* non-conforming shape: it misses the repeated-skill alternative (disconfirmation 1).
- That the M1 red-before-green run happened as reported; only the commit order is evidence.
- Anything about `hooks/*`, which the slice does not touch.

## Deferred
- SC-03b portability until the owner commits `hooks/ll-state.js` and `hooks/ll-precompact.js` (already listed under "actions that need you" in the phase-01 epilogue, and in phases/01/VERIFICATION.md). Resume condition: `git status --short hooks/` empty, then `git archive HEAD | tar -x -C <dir> && cd <dir> && git init -q . && npm test` exit 0.

## Gaps
- G-1 SC-03b clean-checkout suite · owner: commit the two `hooks/*` files (I-09 forbids an executor doing it) · acceptance: `git archive HEAD | tar -x -C <dir>; cd <dir>; git init -q .; git add -A; npm test` exit 0
- G-2 R-05 "one command per line" not enforced for a repeated skill name · acceptance: add `▶ Next — /clear, then ll-bad or ll-bad --resume` to `scripts/fixtures/next-bad/skills/ll-bad/SKILL.md`; `node scripts/lint-contract.cjs --rule 6 --root scripts/fixtures/next-bad 2>&1 | grep -c 'lists alternatives outside a parenthetical'` prints `1`
- G-3 the fixture smoke checks pass with the fixture deleted · acceptance: `check` on the FAIL text, not the exit — `node scripts/lint-contract.cjs --rule 6 --root scripts/fixtures/next-bad 2>&1 | grep -c '^FAIL'` prints `3`
- G-4 no committed check pins the `--no-talk` documentation · acceptance: a smoke check whose removal of `[--no-talk]` from either `argument-hint` makes `npm test` exit 1

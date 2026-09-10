# VERIFICATION — phase 05 — 2026-09-10
mode: phase · slice: main d19dd49..4519fe9

verdict: APPROVED · product: OK · process: OK

| C | criterion | command | exit | file:line | sha256 | freshness | state |
| SC-01 | `run.sh --dry-run` accepts both auto cases and exits 0 | `bash scripts/evals/run.sh --dry-run --case auto-dry-run --case auto-empty-repo` | 0 | scripts/evals/run.sh:225,312 | 6ced20e5d69a3e47 | FRESH | VERIFIED |
| SC-01b | the two asserts behave offline (accept the good answer, reject a wrong one) | `bash scripts/smoke-test.sh --only evals-auto` → "smoke test OK — 4 checks" | 0 | scripts/smoke-test.sh:569-594 | 82c8b55bccc4e9c4 | FRESH | VERIFIED |
| SC-02 | one real rep of `auto-dry-run` and `auto-empty-repo` passes, RESULTS.md path in PROGRESS.md | `bash scripts/evals/run.sh --case auto-dry-run --case auto-empty-repo --reps 1` (independent rep, this session) | 0 | scripts/evals/cases/auto-dry-run/assert.sh:9-34 · scripts/evals/cases/auto-empty-repo/assert.sh:7-25 | eb2e31ba933a371c · 4557163d540986a2 | FRESH | VERIFIED |
| SC-02b | the recorded path is in PROGRESS.md | `grep -n 'll-skills-evals/[0-9-]*/RESULTS.md' PROGRESS.md` | 0 | PROGRESS.md:267 | e0bda97d734e9c84 | FRESH | VERIFIED |
| SC-03 | CHANGELOG carries the 3.0.0 entry, package.json says 3.0.0 | `grep -q '^## \[3.0.0\] - 2026-09-10' CHANGELOG.md && grep -q 'auto-dry-run' CHANGELOG.md && grep -q '"version": "3.0.0"' package.json` | 0 | CHANGELOG.md:5,13 · package.json:3 | d3858c87fcc69e1c · 3b34a5bd082d6193 | FRESH | VERIFIED |

Evidence behind SC-02 (read in this session, not only trusted):
- executor rep `/home/greenn/.claude/ll-skills-evals/2026-09-10-1542/RESULTS.md` — auto-dry-run PASS (4 turns), auto-empty-repo PASS (7 turns); both `rep1/assert.log` all `ok:`, no FAIL line.
- session rep `/home/greenn/.claude/ll-skills-evals/2026-09-10-1543/RESULTS.md` — both PASS; `assert.log` 8 and 7 `ok:` lines.
- my own rep `/home/greenn/.claude/ll-skills-evals/2026-09-10-1548/RESULTS.md` — `auto-dry-run rep 1 PASS cost 0.2494 25.9s turns 5`, `auto-empty-repo rep 1 PASS cost 0.1871 11.5s turns 3`, last line `total cost USD 0.4365 · exit 0`.
- the real `out.txt` of `auto-dry-run` carries the stage table with `decide       done` and the three roteiro rows — CA-04's string is in the answer, not only in the helper's context (the M1 Errata G-3 fix holds).
- negative directions probed by hand, not assumed: a capture with a `Skill` tool_use → `FAIL: no Skill tool call anywhere in the capture: found a Skill tool_use call`, exit 1; a dirty work tree → `FAIL: the working tree was changed: ?? docs-was-written.txt` (auto-dry-run) and `?? novo.txt` (auto-empty-repo), exit 1.

Process checks:
- `git diff d19dd49..4519fe9 -- scripts/smoke-test.sh` adds 4 checks and the header line; no assertion loosened, none skipped or deleted. Every other slice file is new.
- every milestone has `tdd: no`, so no `test(M<n>)`-before-`feat(M<n>)` requirement; commits land in plan order (8e93103 M1, ed715a9 M2, ac13af4 M3, 4519fe9 M4).
- every file named in the M1–M4 blocks exists at HEAD (14/14 checked with `git cat-file -e HEAD:<f>`); every commit the blocks list is in git.
- `npm run lint` → "ok — 7 rule(s), 0 violation(s)" exit 0 · `npm test` → "smoke test OK — 202 checks" exit 0 (run once, in the owner's worktree).

BLOCKS: none

Confrontation: M1 claimed acceptance exit 0 with a negative control FAIL · found the same negative direction reproducible (exit 1 on a dirty tree). M2 claimed exit 0 · found the case files and their asserts at HEAD, offline-green. M3 claimed "smoke test OK — 4 checks" and reps at 1541/1542/1543 both PASS · found 4 checks, and the 1542/1543 RESULTS.md and assert.log say exactly that; my independent 1548 rep agrees. M4 claimed "smoke test OK — 202 checks" exit 0 · found 202 checks, exit 0. Consistent. Observation only (no state): the `### M` timestamps of phase 05 are not monotonic (M1 18:42 after M2 15:40 / M4 15:52), and `PROGRESS.md`, `BACKLOG.md` and `phases/05/` are still uncommitted — SC-02's record lives in the worktree, not in the slice.

Disconfirmation:
- 1 partial requirement: the ROADMAP objective says "one eval case runs `ll-auto` on a fixture **from a written PLAN to a closed delivery**". Neither case runs any stage: `auto-dry-run` proves the `--dry-run` stop and `auto-empty-repo` the empty-repo stop — both stop *before* work. The three success criteria are met as written; the objective's implement-to-close half is only the ROADMAP's deferred idea (DECISIONS "Deferred", B-016 neighbour). No case in the repo exercises a stage transition of `ll-auto`.
- 1 test that passes without testing: the four `evals-auto` smoke checks feed `[{"type":"result",…}]` (smoke-test.sh:582) — a capture with **zero** assistant events. The four `no_tool_use` assertions inside those asserts (auto-dry-run/assert.sh:32-33, auto-empty-repo/assert.sh:22-23) therefore score `ok` without inspecting anything; the offline section proves only the `contains`/`no_path`/`git status` half. The `no_tool_use` half was proven only by my hand-built capture, never by a committed check.
- 1 uncovered error path: `no_tool_use` swallows a missing or malformed capture (`catch { process.exit(0); }`, scripts/evals/lib/assert.sh:66-67). Probed: `bash scripts/evals/cases/auto-empty-repo/assert.sh <clean tree> <nonexistent>.json <pass.txt>` prints 7 `ok:` lines and exits **0** — an eval rep whose `out.json` failed to write scores PASS. Pre-existing helper (outside this slice), inherited by both new cases, covered by no test.

What this verification does NOT prove:
- that `npm test` is green on a clean checkout: the suite ran in the owner's worktree, which carries uncommitted `hooks/ll-state.js` / `hooks/ll-precompact.js`; the I-09 gap recorded in phases 01–04 is unchanged and out of this slice. Closing command: `D=$(mktemp -d) && git archive HEAD | tar -x -C "$D" && git -C "$D" init -q && npm test --prefix "$D"`.
- that `ll-auto` completes a phase or closes a delivery: no rep executed a stage (see the partial requirement above).
- that the cases are stable across models or over reps: `min_pass 1` with `--reps 1`; three reps of the same two cases on the default model is the whole sample.
- that a FAIL rep renders correctly for these cases: the `first assert failure` column of RESULTS.md was never exercised by them.

Deferred: a full implement-to-close rep on a bigger fixture, until a fixture with a runnable phase exists (ROADMAP "Deferred ideas", phases/05/DECISIONS.md Deferred) · `goal-autonomous` eval case (B-016).

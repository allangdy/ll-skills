# VERIFICATION — phase 01 — 2026-09-10
mode: phase · slice: main 2b9e720..122a3bb (worktree /home/greenn/projects/llgod/ll-skills, HEAD 122a3bb)
verdict: APPROVED_WITH_RESERVATIONS · product: OK · process: OK

| C | criterion | command | exit | file:line | sha256 | freshness | state |
| SC-01 | every skills/*/SKILL.md carries `disable-model-invocation: true` | `grep -L 'disable-model-invocation: true' skills/*/SKILL.md \| wc -l` → prints `0` (11 SKILL.md on disk) | 0 | skills/ll-close/SKILL.md:5 | 8a714c23716f3c41 | FRESH | VERIFIED |
| SC-02 | preamble no longer routes and keeps Skills/Delegation/Decisions/Proof | `grep -c 'Route every request' assets/preamble.md` → prints `0` (grep exit 1 = no match, the wanted outcome); `grep -n '^## '` → Skills:4, Delegation:26, Decisions:38, Proof:58; 64 lines, both `v1` markers intact | 1 (no-match) / 0 | assets/preamble.md:4 | 14e7f6c963fc4504 | FRESH | VERIFIED |
| SC-03 | every description one plain line, 60–300 chars, third-person verb, no "Use when", enforced by lint rule 1 | `bash scripts/lint-prompts.sh --rule 1` → `ok   1 skill frontmatter (11 files)`; measured 176–210 chars on the 11 files; negative test in a scratch clone of HEAD: "Use when" → FAIL, 13-char desc → FAIL, missing lock → FAIL (each exit 1) | 0 | scripts/lint-prompts.sh:133 | 3b3bf29f34073b94 | FRESH | VERIFIED |
| SC-04 | `npm run lint && npm test` exit 0 | `npm run lint && npm test` → `smoke test OK — 174 checks`, exit 0 **in the dirty worktree**; on a clean checkout of the committed tree 122a3bb the same script exits 1: `FALHOU: hook ignora PROGRESS.md dentro de fixtures/` | 0 (worktree) / 1 (HEAD tree) | scripts/smoke-test.sh:190-191 | b9f09eb090ad18f6 | FRESH | DEFERRED (owner: DEC-0007 keeps hooks/ll-state.js under I-09) |
| SC-05 | the four eval cases assert the manual contract and `--dry-run --all` exits 0 | `bash scripts/evals/run.sh --dry-run --all` → `# dry run: 10 case blocks printed, no claude call made`, exit 0; real assert against the fixture pair: router-research green on out.json (exit 0), red on with-skill.json (exit 1, `FAIL: … found a Skill tool_use call`); the same green/red transition exercised for router-execute, router-small and preamble-no-ritual | 0 | scripts/evals/lib/assert.sh:63 · scripts/evals/cases/router-research/assert.sh:9 | 0c81955052d2b937 · d028169b1ce026a3 | FRESH | VERIFIED |

BLOCKS: none

## Why SC-04 is parked on the owner, not green

M5 (commit 122a3bb) added `scripts/smoke-test.sh:190-191`, a check that the state hook ignores a
`PROGRESS.md` under `fixtures/`. The behaviour that check asserts exists **only** in the owner's
uncommitted `hooks/ll-state.js:151` (`'fixtures', 'fixture', 'test', 'tests'` in the `skip` set);
`git show HEAD:hooks/ll-state.js` has no `fixtures` reference at all. Reproduced in this session:

    git archive HEAD | tar -x -C <dir> && cd <dir> && git init -q . && git add -A && bash scripts/smoke-test.sh
    → FALHOU: hook ignora PROGRESS.md dentro de fixtures/   (exit 1)

The green I saw is a property of the working tree, not of the slice. DEC-0007 lifted I-09 for
`scripts/smoke-test.sh` only and explicitly kept `hooks/ll-state.js` and `hooks/ll-precompact.js`
under I-09 — so no executor could close this, and the call is the owner's. A fresh clone of the
repository fails `npm test` today.

Confrontation:
- M5 claimed `commands: npm run lint && npm test → "smoke test OK — 174 checks" exit=0` and
  `not_verified: nothing for this milestone` · found the same command exit 0 in the worktree but
  exit 1 on the committed tree, because the check depends on an uncommitted hook — "nothing not
  verified" is overstated by exactly this dependency.
- M1 claimed "bodies byte-identical" · found only one hunk per SKILL.md, all inside the frontmatter
  (`@@ -1,6 +1,6 @@` / `@@ -1,7 +1,8 @@`) — consistent.
- M4 claimed the fixture pair exercises the helper green/red · found it does, and it also holds for
  the three cases M4 listed under `not_verified` (they share the helper) — consistent, understated.
- M2, M3 claims (preamble 64 lines, no router, `## [3.0.0]` in CHANGELOG, no "roteador" in README)
  · all re-run here and consistent.
- Every commit PROGRESS lists (ca1ee3b, 3197200, 14f67e8, 15775f9, 122a3bb) exists in the slice, and
  all 20 files the milestone blocks name exist in HEAD.

Disconfirmation:
- 1 partial requirement: SC-03 says "one plain line", and rule 1's guard is
  `if "\n" in desc.strip()` (scripts/lint-prompts.sh:139-140). With PyYAML present a description
  physically written across two lines folds to a single string, so the guard never fires — verified
  in a scratch clone: a two-line `description:` in `skills/ll-close/SKILL.md` still gives
  `ok   1 skill frontmatter (11 files)`. The char bound and the verb regex do the real work.
- 1 test that passes without testing: `no_tool_use` swallows every read/parse error —
  `catch { process.exit(0); }` at scripts/evals/lib/assert.sh:69. Run here:
  `no_tool_use /nonexistent/out.json Skill` → `ok: missing capture`, and a file containing
  `not json` → `ok: malformed capture` (both exit 0). A capture that never got written scores as
  "no Skill tool call". Same shape in lint rule 1: when `git ls-files` returns nothing (a copy of
  the tree outside a repo) it prints `ok   1 skill frontmatter (0 files)` and exits 0
  (scripts/lint-prompts.sh:41,51).
- 1 uncovered error path: nothing exercises `disable-model-invocation: false` (an explicit false
  value) against rule 1's `truthy()` path, and nothing exercises an empty or truncated `out.json`
  through `first_text_contains` — both are the paths that would silently turn a broken capture into
  a pass. M1's own block lists the first of these as not verified.

What this verification does NOT prove:
- that `npm test` passes for anyone who clones the repository (it does not, see SC-04 above)
- that any of the five eval cases passes against a real `claude` call — only `--dry-run` ran here,
  and `--dry-run` prints case blocks without ever invoking an `assert.sh` (scripts/evals/run.sh)
- that the installed `~/.claude/CLAUDE.md` and `~/.claude/skills/*` carry the new block; the
  installed copies were not touched or read
- that `disable-model-invocation: true` is honoured by the runtime — the frontmatter key is
  present and linted, its effect is external to this repository
- that the four router cases would catch a session that names the command *and* also starts a skill
  through a path other than a `Skill` tool_use block

Deferred: SC-04 until the owner commits `hooks/ll-state.js` (or lifts I-09 for it, as DEC-0007 did
for `scripts/smoke-test.sh`); resume condition below.

Gaps: G-1 SC-04 `npm run lint && npm test` exit 0 on the committed tree · owner: DEC-0007 / PLAN §2
I-09 — commit the two uncommitted hook files, or lift I-09 so an executor may · acceptance:
`git archive HEAD | tar -x -C <dir> && (cd <dir> && git init -q . && git add -A && bash scripts/smoke-test.sh)` exit 0

# CODE-CONTEXT — phase 05 — 2026-09-10

No project `CLAUDE.md` exists at the repo root or anywhere under `ll-skills` [verified: `find ... -iname CLAUDE.md` empty]. No project-constraints section below.

## Analog per file — M1/M2 (cases + prompt + assert)

### scripts/evals/cases/auto-dry-run/{case.json,prompt.txt,assert.sh}
- analog: `scripts/evals/cases/router-execute/{case.json,prompt.txt,assert.sh}` [verified: file:1-16 each]
- shape to copy: `case.json` is a flat object read by `run.sh field()`/`reuse_of()` via `require()` — keys `max_turns, history, min_pass, agent, permission_mode, note` [verified: `scripts/evals/run.sh:96-101`]. `assert.sh` sources `lib/assert.sh` with `. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"`, takes `WORK OUT_JSON OUT_TXT` positionally, ends with `finish` [verified: `scripts/evals/cases/router-execute/assert.sh:1-14`].
- differs in: `permission_mode: bypassPermissions` (D-05-01, so the helper's Bash runs, unlike router-execute's `acceptEdits`) [assumed: DECISIONS.md D-05-01, not opened as primary source per brief scope but present in phases/05/DECISIONS.md:9]; asserts `no path docs/AUTO.md`, empty `git status --porcelain`, `no_tool_use ... Skill`, `no_tool_use ... AskUserQuestion`, and a roteiro-table regex — none of these combinations exist in one case today.

### scripts/evals/cases/auto-empty-repo/{case.json,prompt.txt,assert.sh,fixture/.gitkeep}
- analog: `scripts/evals/cases/scout-no-plan/{case.json,prompt.txt,assert.sh}` for the case shape [verified: file:1-11]; `run.sh prepare_workdir` for the fixture mechanics [verified: `scripts/evals/run.sh:157-166`].
- shape to copy: `prepare_workdir` does `[ -d "$fixture" ] || fixture="$SHARED_FIXTURE"; cp -R "$fixture/." "$work/"` then `git init` + `git add -A` + commit `--allow-empty` [verified: `scripts/evals/run.sh:160-166`]. `cp -R fixture/.` copies dotfiles too, so `.gitkeep` lands in `$work`; `git add -A` tracks a plain file (not an empty dir) without any special case — no directory-emptiness problem exists because `.gitkeep` is a real file [verified: same lines; no `git config core.excludesfile` interference seen].
- differs in: needs its own `fixture/` dir (no case in the repo today ships a fixture that is a single dotfile) — closest analog for "own fixture, no fixture reused" is `run.sh:160` picking `$CASES_DIR/$id/fixture` over `$SHARED_FIXTURE`.

### assert.sh helpers available (all from lib/assert.sh)
`ok <msg>` :24, `fail <msg>` :25, `check <exit> <msg>` :27-29, `contains <file> <regex> <msg>` :31-33 (grep -Eq), `absent <file> <regex> <msg>` :35-37, `no_path <path> <msg>` :39-41, `first_text <out.json>` :48-51 (shells to `extract.js first_text`), `first_text_contains <out.json> <regex> <msg>` :57-59, `no_tool_use <out.json> <tool-name> <msg>` :61-83 (scans every `type:"assistant"` event's `message.content` for a `tool_use` block with matching `name`), `base_sha <workdir>` :85-87, `finish` :89-92 [verified: `scripts/evals/lib/assert.sh:1-92`].
`lib/extract.js` fields: default `result` (falls back to last assistant text on `error_max_turns`) [verified: `extract.js:60-68`], `first_text` pseudo-field (first non-empty assistant message, needs `--verbose`) [verified: `extract.js:41-45`], `total_cost_usd`, `duration_ms`, `num_turns`, `subtype` read as plain result fields via `run.sh` calls [verified: `run.sh:255-257`].

## Analog per file — M1/M2 (offline fixtures)

### scripts/evals/fixtures/{auto-dry-run,auto-empty-repo}/{out.json,pass.txt,fail.txt}
- analog: `scripts/evals/fixtures/manual-contract/{out.json,out.txt,with-skill.json}` [verified: file contents read in full]
- shape to copy: `out.json` is a JSON array of 3 events — `{"type":"system","subtype":"init",...}`, `{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"..."}]}}`, `{"type":"result","subtype":"success","is_error":false,...,"result":"..."}` [verified: `manual-contract/out.json:1-24`]. No script reads `manual-contract/*` today — `grep -rn manual-contract` across `.sh/.js/.md` finds only PROGRESS.md, phases/01/PLAN.md, phases/02/VERIFICATION.md and phases/05/DECISIONS.md, no executable reference [verified: repo-wide grep, empty on scripts/tests].
- differs in: per D-05-03 the naming is `pass.txt`/`fail.txt`, not `out.txt`/`with-skill.json` — one `out.json` shared with **no** `tool_use` block (the brief's own instruction, matching `no_tool_use`'s scan), and two answer texts, one the assert accepts and one it rejects, exercised by `smoke-test.sh` new section against a "clean scratch work tree" [assumed: DECISIONS.md D-05-03 exact wording, not independently re-derivable from code alone].

## Analog per file — M4

### scripts/smoke-test.sh (new section)
- analog: section `4c`/`4d` (`ll-auto: detect` / `roteiro`) for a lettered sub-section pattern gated by `if section 4c; then ... fi` [verified: `smoke-test.sh:237,255`]; section `9` (`lint`) for "run a script, cat output only on failure" pattern [verified: `smoke-test.sh:456-459`].
- shape to copy: `check "<label>" '<eval-string>'` increments `N` and `exit 1` with `FALHOU: <label>` on any failure [verified: `smoke-test.sh:26`]. DECISIONS.md D-05-03 suggests the section name `evals-auto`, run with `--only evals-auto` like the existing named sections `lint-orquestrador`/`goal-autonomo` [verified: `smoke-test.sh:500,549`].
- differs in: must invoke `bash scripts/evals/cases/<id>/assert.sh <work> <fixtures/.../out.json> <fixtures/.../pass.txt|fail.txt>` and assert exit 0 / exit 1 respectively — no existing section shells out to `cases/*/assert.sh` directly (today only `run.sh` does).

### package.json, CHANGELOG.md, scripts/evals/README.md
- analog: current values themselves. `package.json` `version: "2.0.2"`, `description` says "11 skills" [verified: `package.json:2-3`]. `CHANGELOG.md` has `## [3.0.0] - Unreleased` already carrying phases 01-04 bullets [verified: `CHANGELOG.md:5`]. `README.md` line 9 literally says `ten cases` and line 13 `--all # ten cases, three reps` [verified: `scripts/evals/README.md` "Ten cases" occurrences]. `bin/install.js` writes `VERSION` from `PKG.version` (`require('../package.json')`) [verified: `bin/install.js:368`], and `smoke-test.sh:331` checks `VERSION` matches `package.json` version — bumping `package.json` alone keeps this green.
- differs in: no file found asserting "11 skills"/"12 skills" count anywhere in code (`grep` for those strings found none besides `package.json` description) [assumed: only the description string needs the count edit; verify with `grep -rn "11 skills\|12 skills"` before editing].

## Traps
- `scripts/evals/fixtures/manual-contract/*` is read by **no** script today — do not assume `smoke-test.sh` already has a section exercising it; the new M1/M2 section must be added from scratch [verified: repo-wide grep of `.sh/.js/.md`].
- Lint rule 7 (language) scans every tracked file under `skills/ agents/ assets/ hooks/ scripts/` except `scripts/fixtures/*` and the two `EXCEPT_LANGUAGE*` entries — `scripts/evals/fixtures/*/pass.txt` and `fail.txt` are **not** exempt (only `scripts/evals/cases/*/prompt.txt` is) [verified: `lint-prompts.sh:23-24,321-326`]. Unquoted Portuguese prose in `pass.txt`/`fail.txt` will fail `npm run lint`.
- `prompt.txt` for `auto-dry-run`/`auto-empty-repo` may be Portuguese (exempted) but per D-05-01 the prompt is the literal slash command `/ll-auto --dry-run` / `/ll-auto`, language-neutral either way.
- `run.sh`'s `claude_cmd`/`run_claude` pass `prompt_text` (with `{{WORK}}` substituted) as the `-p` argument verbatim — a prompt starting with `/ll-auto` is passed as literal text to `claude -p`, not pre-expanded by the harness [verified: `run.sh:206-207,220-222`]; whether `claude -p` itself expands the slash command is D-05's own open revisable item, already flagged in DECISIONS.md, not resolved in code.
- No `npm pack` size ceiling check exists in `smoke-test.sh` beyond the two `grep -q` file-presence checks [verified: `smoke-test.sh:39-41`, no byte/size assertion found] — do not invent one.

## Values with provenance
| value | where it lives | verified/assumed |
|---|---|---|
| package.json version | `2.0.2` → target `3.0.0` | verified: `package.json:2` |
| package.json description skill count | "11 skills" | verified: `package.json:3` |
| README case count | "ten cases" (×2 occurrences) | verified: `scripts/evals/README.md` |
| CHANGELOG 3.0.0 header | `## [3.0.0] - Unreleased` | verified: `CHANGELOG.md:5` |
| lint rule 7 exemption globs | `scripts/fixtures/*` + `scripts/evals/cases/*/prompt.txt` only | verified: `lint-prompts.sh:23-24,321-326` |
| pass.txt/fail.txt naming, offline capture shape | DECISIONS.md D-05-03 | assumed: not independently re-derivable, brief explicitly allows DECISIONS reading is out of scope but value is load-bearing |
| section name `evals-auto` | DECISIONS.md "Implementer freedoms" | assumed: a suggestion, not a code fact |

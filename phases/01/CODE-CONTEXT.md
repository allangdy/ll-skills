# CODE-CONTEXT — phase 01 — 2026-09-10

No project CLAUDE.md exists at repo root [verified: `ls CLAUDE.md` → No such file or directory]. Constraints below come from ROADMAP.md phase 01 section only, as instructed.

## Constraints from ROADMAP (phase 01 section, no wider read)
- SC-01: `grep -L 'disable-model-invocation: true' skills/*/SKILL.md | wc -l` must print `0` — all 11 skills need the line, not just the current 3 [verified: ROADMAP.md:15]
- SC-02: `grep -c 'Route every request' assets/preamble.md` must print `0`; Skills, Delegation, Decisions, Proof sections stay [verified: ROADMAP.md:16]
- SC-03: every description becomes one plain line, 60–300 chars, third-person verb, no "Use when" [verified: ROADMAP.md:17]
- SC-04: `npm run lint && npm test` exit 0 [verified: ROADMAP.md:18]
- SC-05: eval cases router-research/router-execute/router-small/preamble-no-ritual assert new behaviour (names `/ll-…`, no Skill tool call, no regime word required); `bash scripts/evals/run.sh --dry-run --all` exits 0 [verified: ROADMAP.md:19]

## M1 — lint rules (scripts/lint-prompts.sh)
### rule1 — `def rule1():` [verified: scripts/lint-prompts.sh:119]
- current: `NO_INVOCATION = ["ll-update", "ll-close", "ll-goal"]` [verified: scripts/lint-prompts.sh:26] — only these 3 must carry `disable-model-invocation: true` (lines 141–145). Brief says every skill must now require it — this becomes `SKILL_NAMES` (all 11) or the check inverts to "declared must be true for all, and absent is a FAIL" — the loop shape at lines 141–145 (`declared = ...`, two `bad.append` branches) is the shape to copy, only the membership test changes.
- current desc bounds: `if not 200 <= len(desc) <= 1024:` [verified: scripts/lint-prompts.sh:130] → SC-03 wants 60–300.
- current: `if "Use when" not in desc:` [verified: scripts/lint-prompts.sh:135] → SC-03 wants "no Use when", so this inverts to a FAIL-if-present check; the third-person-verb regex at line 132 (`re.fullmatch(r"[A-Z][a-z]+s", first)`) is untouched by the brief.
- shape to copy for the inversion: `bad.append((f, "..."))` tuple pattern used throughout rule1; return is `(bad, len(SKILLS))` [verified: scripts/lint-prompts.sh:150].
### rule3 — `def rule3():` [verified: scripts/lint-prompts.sh:171]
- current: `if n != 70: bad.append(("assets/preamble.md", "%d lines, expected exactly 70" % n))` [verified: scripts/lint-prompts.sh:185-186] — brief: becomes a ceiling, i.e. `if n > 70:`, message becomes "%d lines, ceiling 70".
- differs in: the rest of rule3 (skill/agent/reference ceilings, ll-tools.js, npm pack size) is untouched — do not touch lines 171-184 or 187-199.

## M2/M3 — SKILL.md frontmatter (11 files, frontmatter only, no body change)
- analog for the 8 files that don't yet have the line: `skills/ll-update/SKILL.md:1-6` already has the exact target shape — `name:`, `description:` (one line, ends with "Use when..." today — must lose that clause), `argument-hint:`, `disable-model-invocation: true` [verified: skills/ll-update/SKILL.md:1-6].
- current description lengths (content only, quotes stripped), all currently contain "Use when" and must shrink to 60–300 chars without it:
  ll-brainstorm 952, ll-close 642, ll-decide 994, ll-goal 523, ll-implement 735, ll-oncall 847, ll-refine 775, ll-research 708, ll-resume 621, ll-update 568, ll-verify 680 [verified: python frontmatter parse of each skills/*/SKILL.md, values above].
- files already carrying `disable-model-invocation: true`: ll-goal:5, ll-update:5, ll-close:5 [verified: grep skills/*/SKILL.md:5] — these 3 keep the line, only description/argument-hint may change; the other 8 gain the line for the first time.
- differs in: brief says "no body change" — only frontmatter `description:` and `disable-model-invocation:` lines move; `argument-hint:` untouched unless already present.

## M4 — preamble (assets/preamble.md)
- analog: the file itself, 70 lines today [verified: assets/preamble.md:1-70, cat -n confirms lines 1-70].
- "Route every request" appears at line 4 heading text and is the string rule5/SC-02 counts [verified: assets/preamble.md:4]. SC-02 requires the literal string `Route every request` to disappear (heading rename or section removal) while Skills (line 28), Delegation (line 35), Decisions (line 47), Proof (line 66) sections survive verbatim or near-verbatim.
- markers `<!-- ll-skills:preamble v1 -->` / `<!-- /ll-skills:preamble -->` (lines 1, 70) are read by `bin/install.js:521` (`extractCanon`, checks `lines[0]`/`lines[lines.length-1]` equal these) — do not remove or move them.
- rule3's line-70 check becomes `<= 70` per M1 — the new preamble may be shorter but not longer.
- traps: `bin/install.js:520-522` splits on the exact open/close marker strings; renaming the version tag (`v1`) would break `PREAMBLE_OPEN`/`PREAMBLE_CLOSE` matching — brief doesn't ask for that, leave the markers as-is.

## M5 — README + CHANGELOG
- README regime table lines that describe routing / must stay consistent with the new preamble wording: line 40 (intro), 44 (SMALL row), 46 (RESEARCH row), 49 (EXECUTE row) [verified: README.md:40,44,46,49].
- CHANGELOG entry shape: `## [X.Y.Z] - YYYY-MM-DD` heading, then `### Alterado` or `### Resumo`/`### Quebras` subsections in Portuguese, bullet list [verified: CHANGELOG.md:5-9, 19-27]. Latest entry is `## [2.0.2] - 2026-09-08` [verified: CHANGELOG.md:5].

## M6 — eval cases
### router-research / router-execute / router-small — analog: each other (same shape) [verified: scripts/evals/cases/router-{research,execute,small}/assert.sh]
- shape to copy: source `lib/assert.sh`, read `line="$(first_text_line "$OUT_JSON")"`, `case "$line" in *REGIME*) ok ...;; *) fail ...;; esac`, then a `first_text_contains`/`contains` check naming the skill, `finish` at the end.
- brief change: assertions must stop requiring "no regime word required" per SC-05 — i.e. drop the `*REGIME*` case-match on the regime word, keep the `/ll-…` command-name and "no Skill tool call" checks. router-small additionally asserts `git status --porcelain` empty and `no_path` for PROGRESS.md/phases (unaffected by phase 01, keep as-is) [verified: scripts/evals/cases/router-small/assert.sh full body above].
- need a new "no Skill tool call" check — no existing case checks tool_use absence directly; the nearest tool_use-scanning pattern is in `scripts/evals/cases/implement-stops-at-next/assert.sh` (node inline script scanning `events` for `b.type === "tool_use"`) [verified: scripts/evals/cases/implement-stops-at-next/assert.sh full body above] — that script checks a tool_use *after* a marker; phase 01's case needs "no tool_use is `Skill` anywhere," which is a new predicate, not a copy — write it following the same `node -e` + JSON.parse(events) pattern.
### preamble-no-ritual — analog: itself [verified: scripts/evals/cases/preamble-no-ritual/assert.sh]
- shape: `contains`/`absent` on the target file, then a run of `no_path` calls for PROGRESS.md/VERIFICATION.md/phases/PLAN.md. Brief adds "the session names the `/ll-…` command and starts no Skill tool" — same missing predicate as above.
- case.json shape for all 4: `{"max_turns": N, "history": bool, "min_pass": 2, "agent": null, "permission_mode": "...", "note": "..."}` [verified: each case.json above] — router-research/execute/small use `acceptEdits`, preamble-no-ritual uses `bypassPermissions`.

## Helpers available — `scripts/evals/lib/assert.sh`
| helper | signature | file:line |
|---|---|---|
| ok | `ok <msg>` | assert.sh:19 |
| fail | `fail <msg>` | assert.sh:20 |
| check | `check <exit-code> <msg>` | assert.sh:22 |
| contains | `contains <file> <ere> <msg>` | assert.sh:26 |
| absent | `absent <file> <ere> <msg>` | assert.sh:30 |
| no_path | `no_path <path> <msg>` | assert.sh:34 |
| first_line | `first_line <file>` | assert.sh:38 |
| first_text | `first_text <out.json>` (calls `extract.js first_text`) | assert.sh:45 |
| first_text_line | `first_text_line <out.json>` | assert.sh:48 |
| first_text_contains | `first_text_contains <out.json> <ere> <msg>` | assert.sh:51 |
| base_sha | `base_sha <workdir>` | assert.sh:54 |
| finish | `finish` (exit 0/1 on `$EVAL_FAILURES`) | assert.sh:58 |
No `first_text_absent`/`no_tool_use` helper exists [assumed: does the phase want a new shared helper in assert.sh, or an inline node check per case? assert.sh itself is not in the brief's file list, so treat as inline per-case node script].

## Readers of symbols that change
| symbol | reader (file:line) | how it is used | opened? |
|---|---|---|---|
| `NO_INVOCATION` | scripts/lint-prompts.sh:142-145 | membership test for `disable-model-invocation` requirement | yes |
| `disable-model-invocation` (frontmatter key) | scripts/lint-prompts.sh:141 | `truthy(fm[...])` | yes |
| `disable-model-invocation` | bin/install.js, scripts/smoke-test.sh, scripts/lint-contract.cjs | none found — grepped, no hits | yes (grep, no match) |
| preamble line count (70) | scripts/lint-prompts.sh:184-186 | exact-equality FAIL condition | yes |
| preamble markers (open/close) | bin/install.js:520-531 | slice canonical block out of `~/.claude/CLAUDE.md` | yes |
| "Route every request" string | scripts/lint-prompts.sh (rule count not found — grepped, only user's own preamble copy and README use it) | SC-02's own grep is the check, not a lint rule | assumed: SC-02 is verifier-run, not baked into lint-prompts.sh — [assumed: confirm lint-prompts.sh has no existing rule asserting this string's absence] |

## Traps
- rule3's preamble check is an exact `!=` today; turning it into `>` without also handling SC-02's shrink means a preamble that's now, say, 55 lines still passes — fine, but do not leave it `== 70` or SC-02's edit will fail lint [verified: scripts/lint-prompts.sh:185-186].
- `bin/install.js:521` requires `lines[0]`/`lines[-1]` to equal the marker constants verbatim; any edit that reindents or adds text outside the markers breaks install, not lint [verified: bin/install.js:520-522].
- rule5 (scripts/lint-prompts.sh, not in the changed-symbols list but adjacent) forbids `Skill(` substring in every SKILL.md body and forbids lines matching `run \`(ll-[a-z-]+)\`` for names in `SKILL_NAMES` — new/edited SKILL.md prose must not accidentally trip this when phase 01 touches wording near "run ll-…" [verified: scripts/lint-prompts.sh:252-273].
- EXCEPT_LANGUAGE / EXCEPT_LANGUAGE_GLOB (rule7, Portuguese-string ban) still applies to README/CHANGELOG paths that are *not* excluded — CHANGELOG.md is not in `EXCEPT_LANGUAGE` [verified: scripts/lint-prompts.sh:19-20], but CHANGELOG.md path prefix `CHANGELOG.md` does not match `f.split("/")[0] in ("skills","agents","assets","hooks","scripts")` at rule7's file filter [verified: scripts/lint-prompts.sh:294-298], so Portuguese CHANGELOG/README text is exempt by path, not by list.

## Values with provenance
| value | where it lives | verified/assumed |
|---|---|---|
| description bounds 200–1024 → target 60–300 | scripts/lint-prompts.sh:130 / ROADMAP.md:17 | verified |
| preamble line count 70, `!=` today | scripts/lint-prompts.sh:184-186 | verified |
| NO_INVOCATION = 3 names today | scripts/lint-prompts.sh:26 | verified |
| 11 SKILL.md files, 3 already have the flag | grep skills/*/SKILL.md:5 | verified |
| per-skill current description char counts | python frontmatter parse, values listed above | verified |
| no reader of disable-model-invocation outside lint-prompts.sh | grep bin/install.js scripts/smoke-test.sh scripts/lint-contract.cjs | verified (no match) |
| whether SC-02's string check is enforced by an existing lint rule | scripts/lint-prompts.sh (searched, not found) | assumed: verifier runs the ROADMAP grep directly, not via lint-prompts.sh |

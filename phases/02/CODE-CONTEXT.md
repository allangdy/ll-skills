# CODE-CONTEXT — phase 02 — 2026-09-10

No project `CLAUDE.md` exists in this repo [verified: `find . -iname CLAUDE.md` → empty]. No constraints section from it; use `scripts/lint-prompts.sh` as the enforced contract instead (see Traps).

## M1 — rule6 grammar + --root + fixtures + smoke checks

### scripts/lint-contract.cjs (rule6 + --root)
- analog: rule6 itself, `scripts/lint-contract.cjs:309-334` [verified]. Current body: matches `/▶ Next\s*—/` per line (316), pulls cited `ll-*` tokens (320), requires each to resolve to `skills/<cmd>/SKILL.md` (322-327), else "anchored" by `/clear|/goal|<...>` (328-329).
- the shape to copy: keep `result()`/`refCount`/`matches` plumbing (94, 82, 48); replace the anchoring check with a grammar match: the new spec is `▶ Next — /clear, then <cmd>` (brief), so the regex must also validate the fixed prefix `/clear, then ` — currently absent (see Traps: today's real lines use ``/clear`, then`` with backtick+comma, `/clear` then, `/clear then` — three different separators, none matching a strict grammar as-is).
- differs in: current rule6 never checks prose shape/punctuation, only "does it name something real"; the new rule6 must also FAIL a real, resolvable command in the wrong grammar (SC-01 fixture-tests this).
- `--root <dir>`: no existing analog in this file or `scripts/*.js` [verified: `grep -rn -- --root scripts/*.js scripts/*.cjs` → empty]. Closest shape is `ll-tools.js` `--cwd` flag, resolved into `a.flags.cwd` before any directory walk (`scripts/ll-tools.js:70`, `72`). **Trap**: in lint-contract.cjs, `ROOT` is a top-level `const` at line 17 (`path.resolve(__dirname, '..')`), and `SKILL_TREE`/`SKILL_NAMES`/`ASSET_FILES`/etc. are computed at module load (lines 60-70), all before `main()` parses `process.argv` (line 400). `--root` must be read and `ROOT` computed near the top of the file (replace line 17), not inside `main()`, or every const built off `ROOT` sees the wrong tree.
- argv parsing pattern to copy: `main()` already does manual `argv.indexOf('--rule')` / `argv.includes('--json')` (401-403) — same flat style works for `--root`, just relocated above line 60.

### scripts/smoke-test.sh (two new contract checks)
- analog: section 10, `scripts/smoke-test.sh:378-395` [verified]. `contract() { node "$ROOT/scripts/lint-contract.cjs" --rule "$1" >/dev/null 2>&1; }` (378-379), then one `check "contrato N: <label>" 'contract N'` line per rule (380-386).
- the shape to copy: a new `check` line for rule 6 against the bad/good fixtures needs its own helper (not `contract()`, which always points at `$ROOT`) — e.g. `contract_root() { node "$ROOT/scripts/lint-contract.cjs" --root "$1" --rule 6 >/dev/null 2>&1; }`, then `check "... next-bad fails" '! contract_root scripts/fixtures/next-bad'` and the inverse for `next-good`.
- `ROOT="$PWD"` is set at `scripts/smoke-test.sh:6` right after `cd "$(dirname "$0")/.."` (line 5) — the script always runs from repo root regardless of caller cwd [verified: smoke-test.sh:5-6], so no cwd assumption trap for the new checks themselves.

### fixtures (create)
- analog: none — closest neighbor `scripts/fixtures/project/` and `scripts/fixtures/empty/` [verified: `find scripts/fixtures`], but both back the state hooks, not lint-contract; no existing "rule-fixture" pair (bad/good) exists in this repo to copy the shape of.
- shape to reuse: minimal SKILL.md frontmatter from a small real skill, e.g. `skills/ll-goal/SKILL.md:1-6` [verified] (`name`, `description`, `argument-hint`, `disable-model-invocation: true`). Fixtures live under `scripts/fixtures/...` so `rule5`/`rule1` of `lint-prompts.sh` (which only match `skills/[^/]+/SKILL\.md` at repo-root-relative paths, `scripts/lint-prompts.sh:52`) do not see them — no lint-prompts exposure for fixture content.
- next-bad/skills/ll-bad/SKILL.md needs one `▶ Next —` line that names a real, resolvable skill but in the *old* grammar (e.g. `` ▶ Next — `/clear` then `ll-close` `` — resolvable today, must FAIL under the new grammar).
- next-good/skills/ll-good/SKILL.md needs the exact new grammar: `▶ Next — /clear, then ll-close`.

## M2 — rewrite every ▶ Next line (skills + preamble)

Every occurrence under `skills/` and `assets/`, file:line, current text and marker classification [verified: `grep -rn "▶ Next" skills assets`]:

| file:line | current text | kind |
|---|---|---|
| ll-close/SKILL.md:32 | `` ▶ Next — `/clear`, then `ll-verify NN` (or record...) `` | handoff (inside a blockquote `>` line) |
| ll-close/SKILL.md:62 | `` more phases... → `▶ Next — /clear, then ll-implement <N+1>` `` | handoff, inside a bullet, backtick-wrapped |
| ll-close/SKILL.md:63 | `` last phase... → `▶ Next — /clear, then ll-close --milestone <name>` `` | handoff, bullet |
| ll-close/SKILL.md:64 | `` milestone closed → `▶ Next — /clear, then ll-decide project` for the next one `` | handoff, bullet |
| ll-brainstorm/SKILL.md:127 | `` ▶ Next — `/clear` then `ll-implement NN`   (or "adjust X"...) `` | handoff |
| ll-brainstorm/SKILL.md:173 | `` ▶ Next — `/clear` then `ll-implement NN` (phase route) · `ll-decide project` (project route) · `` | handoff, 2 alternatives |
| ll-decide/SKILL.md:102 | `` ...stop: `▶ Next — /clear then ll-implement NN` (one executor...) `` | handoff, inline in prose |
| ll-decide/SKILL.md:108 | `` ▶ Next — `/clear` then `ll-implement 1`   (feedback mode: `/clear` then `ll-implement NN`...) `` | handoff, 2 alternatives |
| ll-goal/SKILL.md:58 | `` ▶ Next — `/clear`, then paste `/goal <text>` `` | handoff — target is `/goal`, not `ll-*` |
| ll-implement/SKILL.md:13 | `...stop with `▶ Next — /clear, then ll-decide project`.` | handoff, inline |
| ll-implement/SKILL.md:42 | `...and `▶ Next — /clear, then ll-implement NN`.` | handoff, inline |
| ll-implement/SKILL.md:79 | `...stop with `▶ Next — /clear, then ll-implement NN --wave i+1`,...` | handoff, has extra `--wave i+1` arg |
| ll-implement/SKILL.md:88 | `...and `▶ Next — /clear, then <next_command>` (`ll-implement N+1`...)` | handoff — **placeholder** `<next_command>`, describes itself, not literal |
| ll-implement/SKILL.md:95 | `` ▶ Next — `/clear`, then `ll-implement N+1`, or `ll-verify NN --external` / `ll-close`... `` | handoff, 3 alternatives |
| ll-implement/SKILL.md:96 | `The ▶ Next line is the last thing...` | **prose about the line**, not a handoff — must NOT be touched by rule6/rewrite |
| ll-refine/SKILL.md:111 | `` `▶ Next — /clear then ll-verify` when the round is the last one, or `/clear then ll-refine --round N+1`. `` | handoff, 2 alternatives |
| ll-oncall/SKILL.md:117 | `` `▶ Next — /clear then ll-resume` in a new session of the same role, or the command the round names. `` | handoff, ends with a described (non-literal) alternative |
| ll-update/SKILL.md:72 | `` ▶ Next — `/clear` then `ll-resume` (...) `` | handoff |
| ll-verify/SKILL.md:33 | `...hand over `▶ Next — /clear, then ll-verify NN --external`.` | handoff, inline |
| ll-verify/SKILL.md:71 | `` - APPROVED... → `▶ Next — /clear, then ll-close` `` | handoff, bullet |
| ll-verify/SKILL.md:72 | `` - REJECTED → `▶ Next — /clear, then ll-implement N --wave k` for gaps... `` | handoff, bullet, trailing prose after the command |
| ll-research/SKILL.md:82 | `` ▶ Next — `/clear` then `ll-decide project` reading `docs/research-<topic>/SUMMARY.md`. `` | handoff |
| ll-resume/SKILL.md:51 | `▶ Next — <the command the epilogue names>` | handoff — **placeholder**, no literal command |
| ll-resume/SKILL.md:76 | `...zero files touched, last line `▶ Next — <cmd>`.` | **prose about the line**, not a handoff |
| assets/preamble.md:21 | `...prints "▶ Next — `/clear` then `<command>`" for` | **prose describing the contract**, quoted example — this is the spec line the brief says to edit, not a handoff to rewrite as a real command |

- differs in: `▶ Next — <the command the epilogue names>` (ll-resume:51) and `<next_command>` (ll-implement:88) are legitimate placeholders — brief §NEEDED(8) traps apply: rule6's own code already treats `<[^>]+>` as anchored (`lint-contract.cjs:328`) so a literal `<cmd>` placeholder must stay anchored under the new grammar too, or these two lines start failing SC-01 wrongly.
- ll-close/SKILL.md:32 sits inside a `>` blockquote and ll-decide/SKILL.md:102/108, ll-implement/SKILL.md:88/95 sit inline mid-sentence, not line-initial — rule6's `/▶ Next\s*—/.exec(line)` scans the whole line text regardless of leading `>` or bullet markup [verified: lint-contract.cjs:316, no `^` anchor], so blockquote/bullet placement does not itself break detection; only the grammar after the em dash matters.

## M3 — ll-decide --no-talk

- analog for wiring a new flag into a skill: `argument-hint: "[project | feedback] [--measure]"` at `skills/ll-decide/SKILL.md:4` [verified] — same bracket-optional-flag style to extend with `[--no-talk]`.
- steps to touch: step 1 gate (`SKILL.md:51-54`), step 5 interview (`SKILL.md:65-69`, cites `references/interview.md`), step 6 final round (`SKILL.md:70-71`), step 8 hand-off (`SKILL.md:76-79`), `## Questions` bullets (`SKILL.md:110-116`).
- `interview.md` "Blanket delegation" section: `references/interview.md` lines ~19-29 (starts `## Blanket delegation`) [verified via Read, exact line numbers not separately grepped — offset from file start, section order: queue-building ¶1 → Blanket delegation ¶2].
- `premise-gate.md` "The gate blocks": `references/premise-gate.md:8` (section header) [verified: grep].
- decision-policy.md "Silence, delegation, directives": `references/decision-policy.md:61-71` [verified], already carries `[decided by absence — revisable]` wording (line 62) that SC-02 requires — `--no-talk` should reuse this exact bracket phrase, already the house string, not invent a new one.
- the shape to copy: this section is one of 3 byte-identical copies (see below); any edit here must be applied to all 3 or rule6-of-lint-prompts (its own rule 6, identical-copies) fails.

## M4 — ll-close --no-talk

- analog: `argument-hint: "[--milestone <name>]"` at `skills/ll-close/SKILL.md:4` [verified] — extend to `[--milestone <name>] [--no-talk]`.
- step 7 "One block of ratification": `skills/ll-close/SKILL.md:44` [verified].
- `--milestone` step 6 (ratification): `skills/ll-close/SKILL.md:56` [verified].
- Completion-criterion Next lines: `skills/ll-close/SKILL.md:62-64` (already in the M2 table above).
- `references/delivery.md` mentions ratification at line 41 (`## 5. Assumptions to ratify`) and 44 [verified: grep]; `references/retrospective.md` — no `ratif` hit [verified: grep, empty].

## Decision-policy.md — 3 identical copies
`skills/ll-brainstorm/references/decision-policy.md`, `skills/ll-decide/references/decision-policy.md`, `skills/ll-implement/references/decision-policy.md` — md5 `7cb5e15187dc35b08e7572358bed6dc1` on all three [verified: `md5sum`]. 118 lines [verified: `wc -l`]. Enforced by `lint-prompts.sh` rule 6 (`scripts/lint-prompts.sh:296-311`): globs `skills/[^/]+/references/decision-policy\.md`, fails if count ≠ 3 or md5 diverges — a `--no-talk` edit to this file must be copied byte-for-byte to all 3 paths.

## Traps
- `--root` parsed inside `main()` (after line 400) is too late: `SKILL_TREE`/`SKILL_NAMES`/etc. are already built off the old `ROOT` at lines 60-70 [verified: lint-contract.cjs:17,60-70,400].
- rule6's own code treats `<[^>]+>` as an anchor (line 328) — placeholder Next lines (`ll-resume:51`, `ll-implement:88`) must not be forced into the literal grammar.
- `lint-prompts.sh` rule5 (`scripts/lint-prompts.sh:259-283`) explicitly `continue`s past any line containing `▶ Next` before checking the `run \`ll-x\`` ban (line 277-278) — new ▶ Next lines are exempt from that ban regardless of grammar chosen [verified: lint-prompts.sh:277].
- fixtures under `scripts/fixtures/...` do not match `SKILLS`/`AGENTS` regexes in `lint-prompts.sh` (`skills/[^/]+/SKILL\.md` anchored to repo-root-relative path, line 52) — safe from line-ceiling/frontmatter rules there; they ARE picked up by `lint-contract.cjs` rule6 once `--root` points at them, by design.
- decision-policy.md edit must land identically in all 3 copies or `lint-prompts.sh` rule 6 (line 296-311) fails.

## Values with provenance

| value | where it lives | verified/assumed |
|---|---|---|
| `ROOT` const, module load | `scripts/lint-contract.cjs:17` | verified |
| rule6 body | `scripts/lint-contract.cjs:309-334` | verified |
| RULES table / `--rule` parsing | `scripts/lint-contract.cjs:385-408` | verified |
| smoke-test `contract()` helper | `scripts/smoke-test.sh:378-379` | verified |
| smoke-test `ROOT="$PWD"` after cd to repo root | `scripts/smoke-test.sh:5-6` | verified |
| decision-policy.md md5 (3 copies) | `md5sum` output | verified |
| exact grammar string `▶ Next — /clear, then <cmd>` | brief's PHASE line | assumed: brief-given, not independently derivable from current text, which uses 3 different separators today |
| project CLAUDE.md constraints | none found | assumed: repo has no project CLAUDE.md; nothing to cite |

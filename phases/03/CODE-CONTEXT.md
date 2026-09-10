# CODE-CONTEXT — phase 03 — 2026-09-10

## Constraints from CLAUDE.md that apply to this phase
- Project root has no CLAUDE.md file; only user-global `~/.claude/CLAUDE.md` applies [verified: `find` returned nothing under repo root].
- Model per role: scouting/mechanical → sonnet; this brief already pins the phase to sonnet/medium [assumed: brief header, no project CLAUDE.md to cross-check].

## Analog per file (M1/M2 — helper `ll-auto.js`)
### skills/ll-auto/scripts/ll-auto.js
- analog: `scripts/ll-tools.js` (682 lines) — commands `state` and `epilogue` are the shape to copy.
  - `gitTop` [verified: scripts/ll-tools.js:99], `readAnchoredBlock` [verified: scripts/ll-tools.js:113], `parseStateBlockLite` [verified: scripts/ll-tools.js:156].
  - `state` builds `{ root, top, sb }` via `rootOf(a, true), gitTop(root), loadStateBlock(root)` and sets `epilogue_present: /^## Epilogue/m.test(...)` [verified: scripts/ll-tools.js:418,425].
  - epilogue scan: `const h = /^## Epilogue — phase (\S+)/.exec(l)` then finds the trailing `▶ Next` line [verified: scripts/ll-tools.js:434,545].
  - it is NOT one of `HELPER_SKILLS` (`['ll-implement','ll-verify','ll-close']`) [verified: bin/install.js:45] — `ll-auto.js` ships as its own file inside `skills/ll-auto/scripts/`, not copied from `scripts/ll-tools.js`.
- differs in: ll-auto.js is a distinct file (not a copy of ll-tools.js), lives under the skill's own `scripts/` from day one in this repo (not injected by the installer), and needs new commands (`detect`, `roteiro`, `next-cmd`, `report`, `auto-md`) with no existing analog for their output shape — design them from `state`/`epilogue`'s JSON+human dual output pattern [verified: scripts/ll-tools.js:418-446 shows the `--json` branch pattern].

## Analog per file (M3 — SKILL.md + references)
### skills/ll-auto/SKILL.md
- analog: `skills/ll-implement/SKILL.md:1-19` — frontmatter with `allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/ll-tools.js *)` [verified: skills/ll-implement/SKILL.md:6], preprocessor line `Current state: !\`${CLAUDE_SKILL_DIR}/scripts/ll-tools.js state\`` [verified: skills/ll-implement/SKILL.md:11], and the "session does not write code / does not exercise the product" boundary list [verified: skills/ll-implement/SKILL.md:15-19].
- the shape to copy: locked frontmatter (`disable-model-invocation: true`), one `allowed-tools` Bash pattern scoped to its own script, a `Current state: !` preprocessor call, boundary bullets, and a Completion criterion ending in `▶ Next —`.
- differs in: `allowed-tools` must reference `ll-auto.js` not `ll-tools.js`, and — per SC-04 — must additionally allow the `Skill(` invocation tool (rule 1's `ALLOWED_TOOLS` constant is a single string checked for equality [verified: scripts/lint-prompts.sh:27,144-145]; brief requires this becomes per-skill, so ll-auto's value cannot equal the shared constant and rule 1 needs a second allowed value or a per-skill map). ll-auto writes `docs/AUTO.md`, so it must NOT be added to `EXCEPT_DELIVERABLES = ["ll-resume", "ll-update"]` [verified: scripts/lint-prompts.sh:16-17] — unlike `ll-resume`, it needs a `## Deliverables` table.
### skills/ll-auto/references/stages.md, references/run.md
- analog: none with matching content — closest neighbor is any `skills/*/references/*.md` under the 150-line ceiling [verified: scripts/lint-prompts.sh:179] and the "cited both ways" rule: every `references/x.md` the SKILL.md names must exist, and every file under `references/` must be mentioned in SKILL.md by filename [verified: scripts/lint-contract.cjs:112-128].

## Analog per file (M4 — installer / docs)
### bin/install.js
- analog: `planFiles()` itself — no change needed for skill file copy. `walk()` recurses every file under `skills/<name>/` with no `mode` set except for `HELPER_SKILLS` and `hooks/*` entries [verified: bin/install.js:171-183, 208-211, 294]. `ll-auto` matches `name.startsWith('ll-')` so `planFiles` already includes `skills/ll-auto/scripts/ll-auto.js` on every run — **but with no `mode`, so it is not chmod'd 0o755** unlike `ll-tools.js` copies (`mode: 0o755` at line 210).
- Pruning is safe: `pruneStale` only removes an old-manifest path absent from the *current* `planFiles()` result [verified: bin/install.js:344-352]; since `walk` is unconditional and recursive, `ll-auto.js` is re-included every install and never pruned.
### scripts/smoke-test.sh
- analog: the install block lines 230-266 — `check "11 skills ll-* instaladas" '[ "$(ls .../skills | grep -c "^ll-")" -eq 11 ]'` [verified: scripts/smoke-test.sh:237] **must become 12** once `ll-auto` ships (current count: `ls skills | grep -c '^ll-'` → 11 [verified now]).
- helper-check shape to copy: `check "state: fase 07, 1/3" '$HELPER state --json | grep -q "..."'` and `check "epilogue 07 aponta a fase 8" '$HELPER epilogue 07 --json | grep -q "\"next_command\":\"ll-implement 8\""'` [verified: scripts/smoke-test.sh:109,111,120] — same `check` shape (`eval "$2"`, line 12) applies to `node skills/ll-auto/scripts/ll-auto.js detect --json` against `scripts/fixtures/project` and `scripts/fixtures/empty`.
- installed-copy check to add: mirrors lines 262-266 (`SHA_SRC=$(sha256sum ...)`, then `-x` and sha comparison per `HELPER_SKILLS` entry) — but `ll-auto` is not in `HELPER_SKILLS`, so this needs its own assertion block, not a loop-member addition.

## Readers of the symbols that change
| symbol | reader (file:line) | how it is used | opened? |
|---|---|---|---|
| `ALLOWED_TOOLS` (lint-prompts.sh) | scripts/lint-prompts.sh:144-145 (rule1) | equality check against every skill's `allowed-tools` frontmatter value | yes |
| `EXCEPT_DELIVERABLES` | scripts/lint-prompts.sh:16, rule4 body (deliverables check) | skips `## Deliverables` requirement for named skills | yes |
| `HELPER_SKILLS` | bin/install.js:208-211 (planFiles) | injects `scripts/ll-tools.js` with mode 0o755 into named skills only | yes |
| `ll-tools.js <cmd>` citation regex | scripts/lint-contract.cjs:150 (rule2) | matches literal string `ll-tools.js`; a `ll-auto.js detect` citation does **not** match this regex, so rule 2 does not see or enforce ll-auto's own commands | yes |

## Traps
- `scripts/fixtures/project` has no `phases/07/VERIFICATION.md`; only a top-level `VERIFICATION.md` exists, and the phase-07 epilogue's text merely *names* the path `phases/07/VERIFICATION.md` [verified: scripts/fixtures/project/PROGRESS.md:60] — do not assume the file exists on disk.
- Rule 5 of lint-contract.cjs scans `[A-Z][A-Z-]{3,}\.md` tokens across `skills/*` + `agents/*` + `assets/*` and WARNs (does not fail) if a token like `AUTO.md` appears exactly once [verified: scripts/lint-contract.cjs:281-311, exit code unaffected by warns: scripts/lint-contract.cjs:462].
- Rule 7 of lint-prompts.sh bans unquoted Portuguese prose in `skills/`, `agents/`, `assets/`, `hooks/`, `scripts/` (excluding `scripts/fixtures/` and two named exceptions) [verified: scripts/lint-prompts.sh:335-345,22-24] — any Portuguese empty-repo message ll-auto's SKILL.md/reference prints must be inside backticks or quotes.
- Rule 5 (forbidden strings) of lint-prompts.sh fails on literal `Skill(` and on lines matching `^\s*/ll-` or `run \`ll-x\`` inside any tracked SKILL.md [verified: scripts/lint-prompts.sh:273-279] — SC-04 requires ll-auto to reference other skills' stages, so it needs the "orchestrator exception" the brief names; no such exception list exists yet in this file today.
- npm pack unpackedSize today is 504,775 bytes [verified now via `npm pack --dry-run --json`], well under the 921,600-byte ceiling [verified: scripts/lint-prompts.sh:213].

## Values with provenance
| value | where it lives | verified/assumed |
|---|---|---|
| current skill count | `ls skills \| grep -c '^ll-'` = 11 | verified now |
| `HELPER_SKILLS` list | `['ll-implement', 'll-verify', 'll-close']` | verified: bin/install.js:45 |
| `ALLOWED_TOOLS` constant | `"Bash(${CLAUDE_SKILL_DIR}/scripts/ll-tools.js *)"` | verified: scripts/lint-prompts.sh:27 |
| SKILL.md line ceiling | 200 | verified: scripts/lint-prompts.sh:177 |
| references/*.md ceiling | 150 | verified: scripts/lint-prompts.sh:179 |
| npm pack unpackedSize | 504,775 bytes now, ceiling 921,600 | verified now / scripts/lint-prompts.sh:213 |
| whether `ll-auto` needs Skill-tool allowance in rule 1 | brief SC-04, no existing per-skill map | assumed: does rule 1 become a lookup table keyed by skill name, or does it gain a second allowed value? |
| whether `ll-auto.js` needs `mode: 0o755` from `planFiles` | bin/install.js:171-183 has no such branch for non-`HELPER_SKILLS` scripts | assumed: is a general `.js` under any `skills/*/scripts/` meant to get 0o755 automatically, or only via an explicit new branch? |

---
name: ll-refine
description: Runs one refinement round on a product that already runs — a production review by ll-reviewer, an impact-ordered decision battery, sliced work with a per-coder file allowlist, a deterministic gate that only blocks new errors, and the round recorded in PROGRESS.md; in `visual` mode it drives the reference → calibrated gate → clean-context validator → area-owner loop until the verdict is FIEL. Use when the product is already running and the request is "melhorar as telas", "refino", "rodada", "fiel ao protótipo", "valide visualmente", "outra rodada", "improve the screens", "make it match the prototype" — the REFINE regime. External written feedback (docx, pdf, spreadsheet) is ingested by ll-decide in feedback mode, not here; to audit a finished delivery use ll-verify.
argument-hint: "[product | visual] [--round N]"
---

# Refine

A round is a closed unit: what was found, what the owner chose, what changed, what proves it, and one
line in `PROGRESS.md`. Nothing here judges the product by reading its code — the product is exercised
in the environment the round names, and an image not seen is a check not done.

Reply to the owner in Portuguese; every file you write is in English.

Mode is `product` unless the request names something to be faithful to (a prototype, artboards, a
human golden in the repo) — then `visual`. `--round N` reopens an existing round instead of opening
the next one.

## Deliverables

| File | Role | Mutability |
|---|---|---|
| `docs/refine/round-N/review.md` | findings by severity and route, written by `ll-reviewer` | written once per round |
| `docs/refine/round-N/plan.md` | slices, per-coder file allowlist, exclusive resources | written before dispatch |
| `docs/refine/round-N/delivery.md` | what changed, evidence, deploy risks, what stayed out and why | written at the end of the round |
| `validation/E<n>/REPORT.md` | `visual` mode — one report per validation round | one per round, never rewritten |
| `PROGRESS.md` → `### Round N — <date>` | the round in the project log | appended |

The helper `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ll-implement/scripts/ll-tools.js` is used only if it exists — this skill does not ship it; when it is absent,
read the `<!-- ll-state -->` block of `PROGRESS.md`, append the heartbeat line by hand as `- [<ISO>] <text>`
before the first `## Epilogue`, and take DEC ids as the next number after the highest in `decisions/`. With
it: `state --json`, `heartbeat "<text>"`, `dec-reserve <n>` and `spot-check <M> --files a,b`.

## Flow — product

1. **Access recipe.** Read the `## Production access` block of `PROGRESS.md` (legacy projects: `RODADAS.md`);
   `references/production-access.md` gives its shape. Absent → write it with the owner in one question and
   leave it committed, by name and never by value. The reviewer never negotiates a credential mid-round:
   access is settled and committed before dispatch, or the round does not start.
2. **Review.** One `ll-reviewer` (opus, effort medium). The brief carries base URL, the access recipe copied
   from the block, the route × viewport matrix, the settle condition per route, the image directory, what
   counts as a failure, and the report path. It returns failures only; matrix and images stay in the file.
3. **Battery.** Order findings by impact on the person who uses the screen, not by the reviewer's severity
   label. One `AskUserQuestion` block, at most 4 questions, canonical format: the fact and its source inside
   the `question` field, 2–3 options, each `description` = *what becomes true · cost · what is lost*, one
   `(Recommended)` with traceable ground. When the consumer of the output is a human outside the team,
   format and destination are questions, and the maximalist option stays on the table. Band 2 and 3 findings
   are recorded as `DEC-` with a reserved id and fixed without asking.
4. **Slices.** Write `plan.md`: one slice per coder, each opening with `Files you may modify (ONLY these):`
   and a disjoint path list. Anything two slices cannot hold at once — the test database, the preview server,
   a migration, a shared fixture — is named under `exclusive:` and serialized across slices. A service that is
   already up is declared as such: *"ALREADY running — do not start or stop it"*.
5. **Coders.** Dispatch the slices of one wave in a single message. Opus for a slice that changes a contract,
   a state machine or copy the owner will read; Sonnet for mechanical edits inside a decided shape. Wait with
   `TaskOutput {block:true}` — no polling, no sleep.
6. **Verification by the session alone.** No coder verifies its own slice. Run the deterministic gate with a
   baseline: capture its output on the round's base commit before any change, and let only errors absent from
   that baseline block the round — a gate that fails on pre-existing noise gets ignored by the third round.
   Visual QA is serialized because the browser is a singleton: DOM asserts per route, screenshots opened with
   `Read`. `spot-check` confirms each slice touched the files it declared.
7. **Commit and push.** One commit per path with the finding id in the subject. Push only with everything
   green. Push gate: one deploy at a time — look for an in-flight deploy first and hold if there is one. When
   the push deploys, tell the infra role in the 4-field block (`ll-oncall/references/federation.md`) and put
   the notice in the final summary as `avisei infra · ref <id>`.
8. **Record.** `### Round N — <date>` in `PROGRESS.md`: findings n · fixed n · deferred n with reason ·
   commits · gate result · deploy. Then `delivery.md`.

## Flow — visual

1. **Ruler, before the first delivery.** Three lines at the top of the round file: who judges (a clean-context
   validator, never the agent that rendered), against what (prototype, human golden, artboards — by path),
   and what the verdict means — `FIEL` / `NÃO FIEL` with numeric tolerances. No ruler, no delivery.
   `references/visual-gate.md` carries the calibration and the validator brief.
2. **Input checklist.** Scan `prototype*`, `*-screens/`, `_ds/`, `docs/*flow*` and list what exists with paths
   and dates; open each reference by the route in *Reading the reference* below. A brief that does not cite
   the inputs found is rejected before dispatch — a render is only faithful to a reference that actually
   reached whoever rendered it.
3. **Loop, per element.** reference → calibrated automatic gate → clean-context validator (opus, medium, the
   11-item brief) → on `NÃO FIEL`, the diff goes by `SendMessage` to the persistent area-owner agent that
   rendered it → re-render → re-validate. Repeat until `FIEL`. The gate is the cheap half and the validator
   the expensive one; an element that passes the gate still goes to the validator once.
4. **Report per round** at `validation/E<n>/REPORT.md`, one row per element with verdict and numbers; one
   commit per milestone citing the report path.
5. **Goldens** are frozen only after `FIEL` — a golden taken from an unvalidated render locks the defect in.
6. **Waiting and orphans.** `TaskOutput {block:true}` is the only wait. At the end of each wave, list the
   agents still alive and stop the ones whose element is closed; nothing else stops a background watcher.

### Reading the reference

The reference is read, never assumed — guessing at the prototype's content instead of opening it is the
failure this table prevents:

| Reference | How to read it |
|---|---|
| `https://claude.ai/code/artifact/<id>` | `Artifact` tool, `action: read`, `url` — returns the HTML; pixels via Playwright on a local copy |
| Local file (html, png, pdf, docx) | `Read` (pdf by `pages`) |
| Other URL | Playwright MCP headless: `mcp__plugin_playwright_playwright__browser_navigate`, then snapshot or screenshot |
| Page behind the owner's login | Chrome MCP (`mcp__claude-in-chrome__*`), only then |

None works → band-1 question (ask the owner to attach or paste it), never an assumption. "Fiel ao protótipo"
makes the prototype a premise whose source is the content read.

## Completion criterion

`docs/refine/round-N/` has `review.md`, `plan.md` and `delivery.md`; the gate ran in this session with its
last output line pasted into the round record; every finding is fixed, deferred with a reason, or in
`BACKLOG` with an executable closing condition; `visual` mode has `validation/E<n>/REPORT.md` with every
element `FIEL`; `PROGRESS.md` has `### Round N — <date>`; `git status --porcelain` is empty.

`▶ Next — /clear then ll-verify` when the round is the last one, or `/clear then ll-refine --round N+1`.

## References

- `references/production-access.md` — the access block, where it lives, and the reviewer brief
- `references/visual-gate.md` — ruler, calibration, 11-item validator brief, dispatch message, report template
- `ll-oncall/references/federation.md` — the 4-field block used to notify the infra role

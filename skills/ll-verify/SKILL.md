---
name: ll-verify
description: Audits a finished phase or delivery in clean context, in three layers that never saw the implementation reasoning, and writes VERIFICATION.md with a per-criterion ledger, a verdict and two seals.
argument-hint: "[phase-number] [--external] [--criterion SC-nn]"
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/ll-tools.js *)
---

# Verify

Current state: !`${CLAUDE_SKILL_DIR}/scripts/ll-tools.js state`

A verdict someone else can re-run: every criterion carries the command that ran in this session, its exit code, the `file:line` that implements it, and the hash of that file. Nothing turns green from a report, a commit message or a suite you did not watch. This skill audits and never repairs — a finding is a finding, and what happens to it is the session's call, not yours.

Reply to the owner in Portuguese; every file you write is in English.

## Deliverables

| File | Role | Mutability |
|---|---|---|
| `phases/NN/VERIFICATION.md` (with a phase number, `--external` included) · `VERIFICATION.md` at the repo root (a delivery audit without a phase) | verdict, per-criterion ledger, two seals, BLOCKS, what it does not prove; `ll-close` reads the newest of the two by mtime | one file per verification; never edited after the verdict |
| `BACKLOG.md` | items whose closing condition passed | closed only by `backlog-reconcile --run`, never by memory |
| `phases/NN/PLAN.md` | gaps `G-1..G-n` appended as milestones, when REJECTED | append-only |

## Flow

### 1. Frame the slice, read nothing else

Fix without asking: the target (`phases/NN/PLAN.md` plus the phase section of `ROADMAP.md`, or the delivery the request names), the code slice — branch, commit range, worktree — and the output path: `phases/NN/VERIFICATION.md` with a phase number, `VERIFICATION.md` at the repo root without one. `--criterion SC-nn` narrows the run to one deferred criterion; its resume command sits under `## Deferred verification` in PROGRESS.

Paste the ROADMAP success criteria into the briefs literally: they are the contract, above whatever the plan says. Leave `PROGRESS.md`, the diary and `decisions/` closed — reading the report before the result anchors the verdict in exactly the place this skill exists to avoid.

`--external` puts independence one level up: whoever implemented does not orchestrate the audit. If this session ran the phase, stop here and hand over `▶ Next — /clear, then ll-verify NN --external`.

### 2. Three layers in clean context, never a fork

One message, three `ll-verifier` in parallel, briefs filled from `references/verifier-briefs.md` with absolute paths, the pasted criteria and one output path each:

- **mechanical** (`model: sonnet`) — runs every acceptance command, the build and the named test per criterion, literally as written; records exit code and the output lines that carry the result; `sha256sum` of each file it will cite.
- **contract** (`model: opus`, effort high) — from the objective backwards: for each criterion, the code that delivers it, the test that exercises it, `file:line`; the disconfirmation quota before closing.
- **integrity** (`model: sonnet`) — is today's contract the same as the one agreed before the code? A new section with no DEC, a criterion rewritten, a test loosened, skipped or deleted without escalation, a WAITING decision the code answered by itself.

Wait with `TaskOutput {block:true}`. A layer that returns `BLOCKED:` gets its missing input once; after that its scope is NOT_VERIFIABLE with the command that would close it.

### 3. Reviewer, when there is a screen or a human reference

UI touched, an exercisable URL, or a human-made reference in the repo (prototype, artboards, an approved export): dispatch `ll-reviewer` (`model: opus`) with the access recipe from `## Production access` in PROGRESS. Gate of two halves — the reference on one side, the render on the other, one screenshot per route × viewport, and an image not opened is a check not done. Its FAIL lines join the ledger as criteria; its report path goes in the VERIFICATION header.

### 4. Reconcile the backlog

Run `ll-tools.js backlog-reconcile --run`: it executes each open item's closing condition and closes only what passed. `still-open` items stay open with their exit code; `skipped: budget` ones keep their condition and are named in the report.

### 5. Write VERIFICATION.md

The contract layer writes the file at the path fixed in step 1; then `ll-tools.js ledger <path>` recomputes each recorded `sha256` and stamps `FRESH` or `STALE` per line — a STALE line means the file moved after the check and that criterion drops to NOT_VERIFIABLE. Merge the three layers into one ledger: a criterion is `VERIFIED` only when the mechanical run and the contract `file:line` agree.

Two seals, separate: `product: OK|FAIL` says whether the thing does what was promised; `process: OK|FAIL` says whether the contract stayed honest. A weakened test with green criteria is `product: OK · process: FAIL`, and that combination is what `ll-close` refuses to wave through.

When two verifiers looked at the same criterion, tag each finding `both` or `only one` — the ones both found are the ones to act on first; a solo finding is reported with the layer that raised it.

Close the file with `BLOCKS` (each with `file:line` and commit), the `NOT_VERIFIABLE` rows with the command that would close them, `Deferred` with its BACKLOG id, and **what this verification does NOT prove** — real provider latency, human acceptance, load beyond the fixture. That section is not optional; without it the reader assumes coverage nobody claimed.

### 6. Report and stop

Six lines in the conversation: verdict, the two seals, state counts, the BLOCKS by name, what stays unproven, next command. Zero questions. Structural failures — the ones that need a new decision, not a fix — go up as decisions for the owner; local failures go up as gaps.

## Completion criterion

`VERIFICATION.md` on disk with a verdict, every criterion in a closed state, every ledger line FRESH or explicitly downgraded, the two seals, and the backlog reconciled. Then:

- APPROVED or APPROVED_WITH_RESERVATIONS → `▶ Next — /clear, then ll-close`
- REJECTED → `▶ Next — /clear, then ll-implement N --wave k` for gaps `G-1..G-n`, already appended to the plan with an executable acceptance each.

## References

`references/verifier-briefs.md` — the four briefs (mechanical, contract, integrity, reviewer) with their fixed fields; fill the placeholders, dispatch, do not paraphrase.

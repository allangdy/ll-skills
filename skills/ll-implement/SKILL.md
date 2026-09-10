---
name: ll-implement
description: Runs one phase end to end, from code scouting and a phase plan through TDD waves with one executor per milestone and atomic commits, to clean-context verification against the ROADMAP criteria and an epilogue.
argument-hint: "[phase-number] [--no-talk] [--wave N]"
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/ll-tools.js *)
---

# Implement phase

Current state: !`${CLAUDE_SKILL_DIR}/scripts/ll-tools.js state`

One phase, one invocation: plan, execute and verify without handing the orchestration to anyone. The session writes the plan, dispatches one executor per milestone, runs the acceptances, marks `passes` and writes the epilogue; an executor commits per task and returns one fixed block. Only the session writes state files. When `state` answers `ok: false` and there is no project `PLAN.md`: say "no contract" and stop with `▶ Next — /clear, then ll-decide project`.

Four boundaries hold for the whole run:
- **One phase.** `ll-implement N` writes only `phases/NN/PLAN.md` for N and dispatches only milestones of N. Never write, sketch or dispatch the plan or the milestones of another phase, however obvious the next one looks in ROADMAP: `waves` checks file overlap inside one phase only, so two phases in flight have no collision check and no clean verification between them. Cross-phase parallelism is not offered, not even when the owner asks how to go faster; the epilogue hands the next phase back to the owner.
- **The session does not write code.** No edit to source, tests, fixtures or config by this session, no matter how small; every repair is a task for an executor. The session writes state files (`PROGRESS.md`, `phases/NN/`, `decisions/`, `BACKLOG.md`) and nothing else.
- **The session does not exercise the product.** While executors run, the session orchestrates: it reads return blocks, writes PROGRESS and heartbeats, prepares the next briefs and answers `BLOCKED:`. Driving a browser, curling a running server or querying a database beyond the helper and the milestone's `acceptance:` belongs to `ll-reviewer` (UI, URL) or `ll-verifier` (phase), in a clean context and only for the phase being run.
- **A helper verdict is never overridden.** `plan-lint`, `waves`, `spot-check`, `tdd-gate` answer with a verdict; the session's own reading of `git show`, `git log` or a diff does not replace it.

Reply to the owner in Portuguese; every file you write is in English.

## Deliverables

| File | Role | Mutability |
|---|---|---|
| `phases/NN/DECISIONS.md` | opening conversation: what the session decides, what the owner answers, what waits | written once (step 1); skipped when it exists |
| `phases/NN/CODE-CONTEXT.md` | analogs with file:line, readers of changing symbols, traps, values with provenance | written once by `ll-scout` |
| `phases/NN/PLAN.md` | `<!-- ll-milestones -->` block plus one `### M<n>` body per milestone | immutable after step 4; `## Errata` and `G-n` gaps appended |
| `phases/NN/PLAN-REVIEW.md` | the adversarial verdict on the plan — `APPROVED` or `REJECTED`, no third verdict; its existence with `APPROVED`, or with `REJECTED` and every Gaps line already applied, is what opens wave 1 | one per phase, written by `ll-verifier` in step 4 |
| `PROGRESS.md` | `<!-- ll-state -->` board, wave lines, `### M<n>` blocks, amendment lines, `## Epilogue` | append-only; only the session writes it; the board only via `passes` |
| `phases/NN/VERIFICATION.md` | phase verdict, per-criterion ledger, BLOCKS, gaps; `ll-verify NN` writes the same path, a delivery audit without a phase writes `VERIFICATION.md` at the repo root, and `ll-close` reads the newest of the two by mtime | one per verification, written by `ll-verifier` |
| `decisions/DEC-NNNN-*.md` | decisions taken during waves, under ids from `dec-reserve` | append-only; never by an executor |
| `BACKLOG.md` | rows `\| B-nnn \| born (phase / commit) \| type \| closing condition (executable) \| state OPEN\|CLOSED \|`; ids never reused | append-only; closed only by `backlog-reconcile --run` |

## Flow

Helper: `${CLAUDE_SKILL_DIR}/scripts/ll-tools.js`, written `ll-tools.js` below. Read commands exit 0 and answer `{"ok":false,"reason":…}` on a broken input; `passes`, `heartbeat` and `dec-reserve` exit 1 on error. `ok` means "ran and parsed"; the verdict is its own field (`verdict`, `tdd`, `passes`).

### 0. State — and resume
Read `ROADMAP.md` (the phase section: objective, success criteria), the project `PLAN.md` (§0 precedence, §2 invariants, §3 decisions, §7 protocol) and the `ll-state` block of `PROGRESS.md`. State comes from disk, never from memory or an earlier conversation.
State lives at the git top: `PLAN.md`, `ROADMAP.md`, `PROGRESS.md`, `BACKLOG.md`, `decisions/`, `phases/NN/`, `docs/decide/`, never under `docs/<project>/` or any other subtree. Before step 1 run `ll-tools.js state`; when it answers that there is no `PROGRESS.md` at the git top, or that `git_top` differs from `root`, stop and print, in Portuguese, the reason plus the command that moves the tree — `git mv <root>/{PLAN.md,ROADMAP.md,PROGRESS.md,BACKLOG.md,decisions,phases,docs/decide} <git_top>/`, listing only what exists — and `▶ Next — /clear, then ll-implement NN`. Continue only after the move: nothing else runs from a displaced tree; do not move it yourself and do not mirror it.
A milestone with `passes: false` on the board means resume. For each one: `ll-tools.js spot-check <M> --files <comma-separated files from PLAN>`, then run its `acceptance:`.
- green, `verdict: pass`, `tdd: pass` (or `tdd: no` in the milestone) and `commits.count ≥ 1` → orphan report: append a `### M<n>` block built from `git log`, with the acceptance's last output line pasted in it, then run `ll-tools.js passes <M> true --commit <sha7>`.
- `commits.count = 0` → `verdict: fail` stands: the milestone returns to its wave, and the uncommitted work is recorded as a deviation.
- red, or `files.missing` not empty → the milestone returns to its wave.
`git status --porcelain`, `git worktree list` and `git branch --no-merged` complete the inventory; a dirty tree is reported, never stashed. `--wave N` starts step 5 at wave N with everything before it treated as above.

### 1. One-screen conversation
Skipped when `phases/NN/DECISIONS.md` exists (`ll-brainstorm` wrote it) or with `--no-talk` (A ratified, only B asked — band 1 is never delegated — file written). Otherwise the phase route inline, no agent — `references/phase-conversation.md`: scout ≤10% of context, one map (A: I decide, each item with its repo analog at file:line · B: at most 4 owner calls · C: later); "ok" continues, "pode ir" / "você decide" closes A on the recommendations and B is still asked, one block of ≤4. Writes `phases/NN/DECISIONS.md` in the `ll-brainstorm` schema.

### 2. Scouting
One `ll-scout` (`model: sonnet`, effort medium — always, whatever the phase touches: scouting and repo reading never escalate to opus, and a public contract is a reason to spend opus on the executor and the verifier, not on the reading) with the scout brief from `references/briefs.md`: objective line, the files the phase creates or changes, symbols changing signature, absolute output path, 120-line cap. Output: `phases/NN/CODE-CONTEXT.md`. Its return has ≤10 lines; a `BLOCKED:` there is a brief gap, filled once.

### 3. Phase plan
One file, one phase: `phases/NN/PLAN.md` for the N of the invocation. A milestone that belongs to a later phase is out of scope — leave it in ROADMAP, do not open `phases/MM/`.
The session writes `phases/NN/PLAN.md` by `references/phase-plan.md`: tracer milestone first (the thinnest path through every layer, with a real acceptance); ≤3 tasks and ≤5 files per milestone; `read_first` with `file:lines` and the shape to copy; `action` with concrete values, no code; every `acceptance` with ≥1 automated command (when no test covers a criterion, the first milestone creates the test file); `tdd: yes` for behavior, `tdd: no` for UI, layout, config, glue and migrations; `exclusive` for serialized resources; `stop: owner` for what only the owner unblocks.
Then `ll-tools.js plan-lint phases/NN/PLAN.md`: `verdict: fail` means errors — fix every one, and the warnings you can, before spending the reviewer.
Then `ll-tools.js waves phases/NN/PLAN.md --json`: each entry in `defects` (`file_overlap`, `exclusive_conflict`, `unknown_depends_on`, `cycle`) goes back into the plan; `unscheduled` is a cycle, never ignored. Print the table `Wave | Milestones | Builds` from `waves[]` before dispatching anything.

### 4. Adversarial review — one pass, and a gate
One `ll-verifier` (`model: opus`) with the plan-review brief: mode plan, the 8 questions, the `plan-lint` output pasted so it is not repeated. In plan mode the verdict is `APPROVED` or `REJECTED` and nothing else; `REJECTED` carries `Gaps: G-n … acceptance: <cmd>` lines naming the milestone to amend. `REJECTED` or any `BLOCKS` → apply every Gaps line to the plan under `## Errata`, rerun `plan-lint` and `waves`, move on. No second review and no question to the owner. From here the plan changes only through `## Errata` and appended `G-n` milestones.
The gate: no executor is dispatched until `phases/NN/PLAN-REVIEW.md` is on disk; `APPROVED` opens wave 1; `REJECTED` opens it only after every Gaps line is applied to the plan under `## Errata` and `plan-lint` and `waves` rerun clean — no second review. Review first, wave 1 after, never in parallel; there is no `--no-review`. A request to skip the review is answered with the cost, and the review runs.

### 5. Waves
Every owner message that arrives during the phase is recorded as `ll-tools.js heartbeat "owner: <summary ≤ 80 chars>"` before acting on it.
For each wave, in this order:
1. `ll-tools.js heartbeat "wave i/M — <what it builds>"`; print the same line in the conversation.
2. `ll-tools.js dec-reserve <n>` with n = milestones in the wave; the returned `ids` fill each brief's `DEC RESERVED` line. Ids never come from an executor.
3. One `ll-executor` per milestone of this phase, one Agent call each, all calls of the wave in the same message, the 12-field brief from `references/briefs.md` (paths, not text). `model` from the milestone's `model:` field: `opus` for a contract milestone, `sonnet` for a mechanical one. A milestone whose `files` collide with another in the wave was a plan defect; when it stands, it moves to the next wave.
4. Wait with `TaskOutput {block:true}`; never read the executor's transcript. Append each `### M<n>` block verbatim to `PROGRESS.md` under `## Phase NN`. A `BLOCKED:` block is appended too, then `ll-tools.js passes <M> false --reason "<decision requested>" --state BLOCKED` (`--state` is one of `BLOCKED | ANSWERED_NO | DEFERRED | PRESENT_NO_BEHAVIOR`; done is `passes: true`); a `PARTIAL:` block gets one continuation with the same brief plus its `next:` line.
   Amending a running executor (`SendMessage`) is allowed only while `git log --oneline` shows no `feat(M<n>)` from it: the brief it is executing has not yet become a commit. Once the feat is committed, wait for the return block and open the change as a fix task in the next wave — a mid-run brief change after the commit rewrites work already proven. Every amendment sent becomes a PROGRESS line at the moment it is sent: `ll-tools.js heartbeat "M<n>: amendment — <what changed> (DEC-NNNN)"`, so compaction cannot lose it.
5. Run each milestone's `acceptance:` yourself, then the build and the whole suite. A timeout, a skipped test or a non-zero exit is not green. That is the whole exercise the session performs: no browser, no `curl` against a running server, no ad-hoc database query, and never against a criterion of another phase — hand that to `ll-reviewer` in step 6 (UI, URL) or to `ll-verifier` (phase), which judge in a clean context. A manual check you did anyway lands in PROGRESS as `not verified by a clean context — <what you did, what you saw>`, never as "verified now", and never marks a `passes`.
   A test the phase did not write that goes red is a fix task, never an edit by the session: while the milestone's executor is still running and has not committed its `feat(M<n>)`, amend it (rule above); otherwise it is a milestone in the next wave, with the constraint "adapt the test's setup, never its assertion" in the brief and the failing output line as input. A red foreign test keeps its milestone at `passes: false`.
6. Per milestone: `ll-tools.js spot-check <M> --files <files>` (`verdict: pass` = every file in HEAD and ≥1 anchored commit) and, when `tdd: yes`, `ll-tools.js tdd-gate <M> --since <HEAD sha before the wave>` (`tdd: pass`). `ll-tools.js passes <M> true --commit <sha7>` needs all three, together: `tdd-gate` `pass` (or `tdd: no` in the milestone), `spot-check` `verdict: pass`, and the acceptance command's last output line pasted in the `### M<n>` block of PROGRESS. Two out of three is `passes: false`.
   A helper `fail` is never overridden by your own reading of `git show --stat`, `git log` or a diff. When the evidence says the helper is wrong, write it — `ll-tools.js heartbeat "M<n>: spot-check fail contradicted by <evidence>"` — and run `ll-tools.js passes <M> false --reason "helper disagreement"`, then continue the wave; step 6 decides with a clean context. Anything else red: `ll-tools.js passes <M> false --reason "<what is red>"`, and the milestone reruns once in the next wave with the failing output line in its brief.
7. `questions:` lines from the blocks: band 1 → one battery of at most 4, same subject, in the format of `references/decision-policy.md`; band 2 and 3 → decide, write the reserved `DEC-` file, continue. `backlog:` lines → one row each in `BACKLOG.md` (next free `B-nnn`, birth phase and commit, type, condition as `` `<command>` exit 0 ``, state `OPEN`); a band-1 answer of "no" marks the milestone `passes false --state ANSWERED_NO`. `deviations:` stay in the block.
8. Sweep orphan background tasks before opening the next wave.
Before the next wave: when the context is near its limit, run step 7 and stop with `▶ Next — /clear, then ll-implement NN --wave i+1`, instead of degrading mid-wave.

### 6. Clean-context verification
One `ll-verifier` (`model: opus`) with the phase brief: mode phase, ROADMAP and PLAN paths, the success criteria pasted, the code slice (`<HEAD at step 0>..HEAD`), output `phases/NN/VERIFICATION.md`, PROGRESS closed until the verdict. It judges the ROADMAP criteria and the plan's `truths`, above whatever the milestone blocks claim.
- `REJECTED` → each `G-n` line becomes a milestone appended to PLAN (acceptance from the gap line, `tdd: yes`), `ll-tools.js passes G-n false --reason "gap from verification"` creates its board line, and step 5 runs once more for those gaps only. A second `REJECTED` goes to the epilogue as left work.
- UI touched or a running product: `ll-reviewer` (`model: opus`) with the reviewer brief; its FAIL lines are gaps like the above, and only failures reach the owner.
- Boot, database or migrations touched: cold-start smoke test — stop the service, start from an empty state, run the tracer's acceptance — before the verdict counts.

### 7. Epilogue
`ll-tools.js epilogue NN --json` gives the data; the session writes `## Epilogue — phase NN — <date>` at the end of `PROGRESS.md`: `passed`; `left` with why; `waiting` decisions; new backlog ids with their condition; one block "actions that need you" with each command ready to paste; the count line `milestones passed X/Y · questions asked N / assumptions M / band-1 open K · amendments A · verification: phases/NN/VERIFICATION.md <verdict>` (amendments counted from the `amendment —` heartbeat lines); and `▶ Next — /clear, then <next_command>` (`ll-implement N+1` when ROADMAP has a next phase, otherwise `ll-close`; `ll-verify NN --external` first when the phase touched a public contract, money or customer data). Print the same lines in the conversation and stop. The next phase is the owner's next invocation in a clean context: do not start it, do not plan it, do not offer to run it in parallel with this one.

## Completion criterion

Every milestone of the phase has `passes: true` under the three conditions of step 5.6 — `tdd-gate` pass or `tdd: no`, `spot-check` pass, acceptance last line in PROGRESS — with the acceptance run in this session; `phases/NN/PLAN-REVIEW.md` and `phases/NN/VERIFICATION.md` exist, the second without BLOCKS; only `phases/NN/` was planned; `git status --porcelain` is empty; the epilogue is written. Every missing proof is named with the command that would close it.
The epilogue's last count line, printed in the conversation and written to PROGRESS:
`milestones passed X/Y · questions asked N / assumptions M / band-1 open K · amendments A · verification: phases/NN/VERIFICATION.md <verdict>`
▶ Next — `/clear`, then `ll-implement N+1`, or `ll-verify NN --external` / `ll-close` as the epilogue says.
The ▶ Next line is the last thing this invocation does: no review, plan, verifier or executor of another phase is started after it; the next phase exists when the owner pastes the command.

## Questions

One skippable screen at the start (step 1) and one battery of at most 4 at the end of a wave, only for band-1 items that surfaced in `questions:` lines. Never asked: the ten items of `references/decision-policy.md` (who executes, a fact readable from the repo, which pattern when a house pattern exists, a reversible detail inside a closed contract, another session's decision, out-of-scope subjects, a question that changes no action, copy without a commercial promise, industry defaults, the same policy question twice). Band 2 and 3 are decided, recorded under a reserved `DEC-` id and flagged for review. No answer in 10 minutes → the recommendation, recorded as `[decided by absence — revisable]`; never for band 1, which stays `WAITING` while only its branch freezes.

## Models

Read from the project PLAN §7 at every wave; these are the defaults when §7 is silent.

| Role | Model / effort |
|---|---|
| session | Fable, high; xhigh for a phase that runs over 30 min |
| scout, and any repo reading | sonnet / medium — always, contract phases included |
| executor, contract milestone | opus / high |
| executor, mechanical milestone (`tdd: no`: glue, config, layout, migration) | sonnet / medium |
| verifier, plan review and phase verification | opus / high; sonnet for a mechanical re-run |
| reviewer | opus / medium |

## References

- `references/briefs.md` — the five briefs (scout, plan review, executor, phase verification, reviewer) and the delegation rules; steps 2, 4, 5, 6.
- `references/phase-plan.md` — plan rules, the YAML block template, the milestone body template, the TDD table, what `plan-lint` checks; step 3.
- `references/phase-conversation.md` — the inline phase route and the DECISIONS.md schema; step 1.
- `references/decision-policy.md` — bands, never-ask list, silence rule, canonical question format; steps 1 and 5.

---
name: ll-decide
description: Turns a request into a contract that survives without the owner, writing PLAN.md, ROADMAP.md, decisions/ and an empty PROGRESS.md in project mode, or a dated review file from external feedback in feedback mode.
argument-hint: "[project | feedback] [--measure] [--no-talk]"
disable-model-invocation: true
---

# Decide

Everything that would otherwise be asked during execution is decided here, once, and written where an agent with a cleared context finds it. The result is judged by one test: a session that has never seen this conversation reads the files and starts implementing without a question. Nothing is implemented here.

Reply to the owner in Portuguese; every file you write is in English.

## Deliverables

Every path is relative to the repo root and fixed: `PLAN.md`, `ROADMAP.md`, `PROGRESS.md`, `BACKLOG.md`, `decisions/`, `docs/decide/`, `phases/NN/`. State never lives in a subfolder — the hooks and `ll-tools.js state` expect the state at the git top, and a displaced tree is reported as `git_top ≠ root` and stops `ll-implement` before its first step, so a `docs/<project>/PLAN.md` costs a move before anything runs. When the root is already taken by a previous round, archive it (step 0); never write the new set beside it.

Never written here: `phases/NN/PLAN.md` — the phase plan belongs to `ll-implement`.

| File | Role | Mutability |
|---|---|---|
| `PLAN.md` | project contract, §0–§11 | immutable after freezing except `## Errata` (append-only) |
| `ROADMAP.md` | phase table + `## Phase NN` with success criteria; written only when the project has more than 3 phases | live; continuous numbering, decimals for insertions, never renumbered |
| `decisions/DEC-NNNN-<slug>.md` + `decisions/README.md` | one decision per file; index with counts, against-recommendation, verbatim free answers, accepted risks | append-only; IDs never recycled; supersession by a new line |
| `PROGRESS.md` | empty diary with the `<!-- ll-state -->` block | created here, written by `ll-implement` |
| `docs/decide/PREMORTEM.md`, `DISARM.md`, `OPTIONS.html` | premortem, disarm pass, decision room | written once; PLAN §4 cites the failures |
| `docs/review-<date>.md` | feedback mode: the 7-section review spec | written once; decisions final |
| `docs/<slug>.xlsx` | feedback mode: external contract for the team, committed | filled by humans, read back by `ll-implement` |

Read, never rewritten: `docs/decide/OPENING.md` (from `ll-brainstorm` — everything in it is settled and the gate questions it already answers are not repeated), `docs/research-*/SUMMARY.md`, `docs/RETROSPECTIVE-*.md`.

## Flow — project

### 0. Mode, inputs and existing state
Read the argument: `--measure` runs the disarm tests and may spend; without it the exercise is design-only (paper). `--no-talk` sends no question in steps 1, 5 and 6: each band-2/3 item takes its recommended option at once as `ASM-n [decided by absence — revisable]`, and each band-1 item becomes a `WAITING` decision file instead of a question. When the request itself says which, that wins; otherwise announce the mode in one line — the owner overrules by replying. Read the project CLAUDE.md, `docs/decide/OPENING.md`, research summaries, and any record of a previous attempt ("segunda tentativa", a retrospective): the previous failure is a source in PLAN §11 with its dated reason, and its lessons enter §2/§4 with that source.

Existing state at the root. `PLAN.md` already there from an earlier round, and that round is closed (its `PROGRESS.md` carries the `ll-close` epilogue, or the owner says it is closed) → `git mv` of what exists among `PLAN.md ROADMAP.md PROGRESS.md phases/ docs/decide/` into `docs/history/<round-slug>/` in one commit `docs(history): archive <round>`; `decisions/` and `BACKLOG.md` stay where they are and the DEC ids continue from the highest. Round not closed → stop and ask (band 1): close it with `ll-close`, or continue it. The new set is then written at the root, never under `docs/<project>/`.

Read every reference the request names, before the gate:

| Reference | How to read it |
|---|---|
| `https://claude.ai/code/artifact/<id>` | `Artifact` tool, `action: read`, `url` — returns the HTML; pixels via Playwright on a local copy |
| a path on disk (html, png, pdf, docx) | `Read` (pdf by `pages`) |
| any other URL | Playwright MCP headless: `mcp__plugin_playwright_playwright__browser_navigate`, then `browser_snapshot` or `browser_take_screenshot` |
| a page that needs the owner's login | Chrome MCP (`claude-in-chrome`), his own session |
| none of these returns the content | band-1 question: ask him to attach the file or paste the content — never an assumption about what it contains |

"fiel ao protótipo" in the request makes the prototype a premise: its source is the content read, cited by artifact id or path. Without that content there is no premise and the gate stops.

### 1. Premise gate (blocking)
Five questions in one block, before any subagent: the number that decides success and what counts as FAILURE; the deliverable in the client's format; the source of truth for the data; the house pattern that applies; the constraint being invented out of caution that is not the owner's rule. The tool takes four per call: questions 1–4 in one call, the fifth right after, nothing in between. Skip every question `OPENING.md` already answers. Option shapes and why each question exists: `references/premise-gate.md`.

The gate is passed when each of the five premises carries a source — `file:line`, the owner's message quoted, or an `ASM-n` label he has seen. A premise without a source is one question block (≤4) sent now, and nothing after this step runs — no premortem, no narrator, no subagent — until it is answered or ratified. A blanket delegation does not open this gate; it only turns band-2/3 premises into `ASM-n`. Under `--no-talk` no block is sent: a premise without a source takes the recommended answer of its question as `ASM-n [decided by absence — revisable]`, and PG-1/PG-2 — band 1, like any premise resting on a reference this session could not read — are written as premises and also as `decisions/DEC-NNNN-<slug>.md` in state `WAITING`, so the later steps run.

### 2. Back from the future
Write the measured × faith inventory (5 sections) into `docs/decide/PREMORTEM.md`, then run 3–5 narrators (Opus, clean context, one persona each) that read only the inventory and the artifacts, never this conversation. Each writes `## ☠️ N.` deaths with a dated scene, an omen quoted literally from a project file with a named bias (or "no artifact mentions this point"), and a disarming test. Consolidate by convergence into F-01..F-0n ordered by lethality, TOP 3 marked, every quote re-opened and checked; close with "the missing rule" as a verifiable checklist. `references/premortem.md`.

### 3. Disarm
Design mode (default): for each F-0n, a design mitigation, a sentinel (the observable that says it is happening) and a plan B — into `docs/decide/DISARM.md`; each becomes R-nn in PLAN §4 and, when observable by command, a CA-nn in §6. Measure mode: an 8-part pre-registration per test, frozen and committed before anything runs; verdicts from the closed vocabulary with the number beside each; a "What this test does NOT prove" section; verdict ceiling when the ground truth is human. `references/disarm.md`.

### 4. Decision room
Write `docs/decide/OPTIONS.html` — self-contained: one alternatives table per topic (design, architecture, flow, data model) with what becomes true, cost, what is lost, revert cost and the recommendation, plus the fixed block with the five gate answers. A Fable judge in clean context (never fork) reads the file and the evidence and returns an opinion per topic; the opinion is appended to the file as its own section. The file is published, and its path given to the owner, before the first interview question. `references/decision-room.md`.

### 5. Interview (blocking)
A blanket delegation in the request ("pode decidir tudo", "me pergunta só o que for necessário") covers bands 2 and 3 only: those items become `ASM-n` and are never asked. Band 1 is asked anyway — money above the round's ceiling, irreversible outside the repo (deploy, destroy, credential in a new place, prod write), price or a promise to a customer, a scope cut, the number the owner will look at, an owner reference this session could not read, a recorded rule contradicted by new evidence. One block of ≤4 per round, ordered by impact, recommendation marked with its cost; the owner may answer "A" to ratify every recommended item at once. Ten minutes of silence ratify the recommended list (A), never a blocking item (B) and never a band-1 item. Under `--no-talk` nothing is asked: band-2/3 items become `ASM-n [decided by absence — revisable]`, each band-1 item becomes its own `WAITING` DEC file listed in PLAN §3, and `ROADMAP.md` marks the first phase whose work depends on one with `stop: owner` in its section.

Count the decisions after step 4 and before the first question; number `n/N`; if the count grows, say "+k questions". Batteries of at most 4 per subject, ordered by impact, in the canonical format of `references/decision-policy.md` (fact with source, plain-words context, options with cost, recommendation first with its reason, "Claude decide" when delegable). Free text is a new requirement with its own ID, never an invalid answer; "Claude decide" is recorded as `ASM-n` and never asked again; an order against the recommendation gets one challenge with the cost named, then obeys. The helper `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ll-implement/scripts/ll-tools.js` is used only if it exists — this skill does not ship it; when it is absent, take the next number after the highest in `decisions/`; with it, `dec-reserve <n>` reserves the ids before the battery. `references/interview.md`.

### 6. Final round (blocking, always sent)
Minimum contact: at least one message reaches the owner before PLAN.md is frozen, whatever the delegation was. It carries, in this order, (a) the decision count, (b) the counter `questions asked N / assumptions M / band-1 open K`, (c) the band-1 items still waiting for an answer, then every decision as it will be written — ID, decision, who decided, against-recommendation marks, assumptions. A run whose items are all band 2/3 still sends it, with `N = 0` and the ASM list. An item that was badly posed is re-asked here; a correction is applied and the list shown once more. "ok" or "A" freezes; ten minutes of silence ratifies the recommended list (A, the assumptions) and freezes PLAN.md too, but only when `band-1 open` is 0 — with one band-1 item open nothing freezes. Under `--no-talk` the round is printed as a report, not asked: same content, counter `questions asked 0 / assumptions M / band-1 open K`, and the contract is written and frozen even with K > 0 — the `WAITING` DECs are what stop the dependent work, not this skill. Nothing is written before this round closes.

### 7. Write the contract
At the repo root: `PLAN.md` §0–§11, `ROADMAP.md` when phases > 3, one `decisions/DEC-NNNN-<slug>.md` per decision plus `decisions/README.md`, and an empty `PROGRESS.md` with the `<!-- ll-state -->` block — templates in `references/plan-skeleton.md`. The id is four digits with no project prefix (`DEC-0007-cents-mismatch.md`, never `DEC-X-007`), reserved with `ll-tools.js dec-reserve` when the helper exists and otherwise taken as the next number after the highest in `decisions/`. `plan-lint` reads phase plans only (an `ll-milestones` block), so it runs in `ll-implement`, not here; before freezing, check by hand that every `T<n>` and `CA-nn` carries a command, every `REQ-<slug>` points to one phase, and every `I-nn` has a source. Answer the self-sufficiency test in §10 before ending: which test key to use, what is missing, given that this session's context will be cleared.

### 8. Hand off
Report in Portuguese, opening with the counter `questions asked N / assumptions M / band-1 open K`, then the decision counts (owner / assumption / inherited / against recommendation), accepted risks, files written, hand-check result. Under `--no-talk` the report also names each `WAITING` DEC with its file path and the phase that carries `stop: owner`. With `N = 0` and `M > 5`, append one line under the phase heading of `PROGRESS.md`: `- review assumptions: <M> ASM written with 0 questions asked (<date>)`.

Then stop and print the next command — one command, `ll-implement 1`, the attended run. An owner who wants the phases to run unattended may choose `ll-goal 1` instead; say it in the prose if he asks, never in the ▶ line. This skill does not write `phases/NN/PLAN.md`, does not dispatch executors and does not run a phase — the phase plan is written by `ll-implement` when the owner runs it, one phase at a time.

## Flow — feedback

### 1. Forensic ingestion (Sonnet, automatic)
Take the material apart by format: `.docx` → unzip → `comments.xml` with the anchor text of each comment; PDF → visual `Read`, page by page; `.xlsx` → cell dump; an unreadable image → crop + upscale + read again. Close with the inventory "N comments, M visual annotations, K items" — every item gets an ID and none disappears from the triage. Recipes with exact commands: `references/feedback-ingestion.md`.

### 2. Anchor in the code
For every item, the current state: `file:line`, current price, current copy. An item that anchors nowhere becomes a question, not an assumption.

### 3. Veracity gate
List the factual claims the material proposes (times, prices, numbers, names, credits) and check each against `PRODUCT.md`, the project CLAUDE.md and the code. Divergences are the first questions, because they poison every decision after them. The instruction "the reviewers are lay people in X" means evaluate, not obey.

### 4. Triage by impact
Count the decisions before the first question. Order: money → offer → fact → copy → microcopy. Every question carries the reviewer's proposal, the anchored current state, the analysis and a recommendation; "reject" is always an option; in a scope question the maximalist option is always on the table. Anything for a human recipient asks the format once (`.xlsx` in `docs/`, artifact, issue) before being built. Under `--no-talk` the battery is not sent: the same order holds, each band-2/3 item takes its recommendation as `ASM-n [decided by absence — revisable]` and each band-1 item becomes a `WAITING` DEC.

### 5. Blind arbitration (automatic)
Two or more competing versions of conversion copy → judges (Fable, clean context, one per item) receive product facts, audience, criteria and the versions unattributed, with the `<output_contract>` (≤150 words: VERDICT / Rationale / Version D if better). Not asked whether to do it; the verdict comes back into the numbered question as "(retomada)". Contract: `references/review-spec.md`.

### 6. The spec
Write `docs/review-<date>.md` in the 7 sections: self-contained header · decision log including rejected items · §1–§N copy verbatim per page with target file · §Sweep greps of what became obsolete · §External dependencies with the placeholder rule · §Deferred with reason · §Verification contract. Decisions in it are final.

### 7. External contract
From §External dependencies, generate `docs/<slug>.xlsx` with checklist columns and a "how to use" tab, committed in the repo. Append the round to `ROADMAP.md` as a phase (`| NN | review <date> | … | PLANNED |` with a `## Phase NN` section whose success criteria are the §Verification contract and whose objective points at the spec). Report in Portuguese and stop: `▶ Next — /clear, then ll-implement NN` (one executor per slice with a file allowlist).

## Completion criterion

Project: `PLAN.md` exists at the repo root with §0–§11 (`git ls-files PLAN.md PROGRESS.md` returns both at the root), §10 answers the self-sufficiency test, every CA-nn has a command, `decisions/README.md` counts match the DEC files and every id is `DEC-NNNN-<slug>.md`, `PROGRESS.md` carries the empty `ll-state` block, the premise gate closed with a source per premise, the final round was sent and closed (printed as a report under `--no-talk`), the counter `questions asked N / assumptions M / band-1 open K` is printed, no `phases/NN/PLAN.md` was written, and the hand check of step 7 found nothing. Feedback: the inventory count equals the number of decisions logged plus deferred items, and the `.xlsx` is committed.

▶ Next — /clear, then ll-implement 1 (feedback mode: ll-implement NN, the phase appended in step 7)

## Questions

- Gate: five, in one block, at the start; the ones `OPENING.md` answers are skipped. Blocking: no premortem, no subagent, no writing until every premise has a source.
- Interview: batteries of at most 4 per subject, by impact, canonical format; counted before the first, `n/N` never renumbered. Feedback: counted before the first, one subject per call, money items alone.
- Blanket delegation ("decide tudo"): covers bands 2 and 3; band-1 items are asked anyway, and an owner reference this session could not read is band 1.
- Final round: always sent before writing, with the counter and the open band-1 list, even when zero questions were asked.
- `--no-talk`: steps 1, 5 and 6 send no question; band-2/3 items take the recommendation, recorded `[decided by absence — revisable]`; band-1 items are written as `WAITING` decisions and the contract is frozen anyway.
- Never asked: the ten items of `references/decision-policy.md` (who executes, a fact readable from the repo, which pattern when a house pattern exists, a reversible detail inside a closed contract, another session's decision, out-of-scope subjects, a question that changes no action, copy without a commercial promise, industry defaults, the same policy question twice). Silence for 10 minutes ratifies the recommended option of a band-2/3 item, never option B and never band 1.

## Models

| Role | Model |
|---|---|
| Session | Fable |
| Premortem narrators, research fronts | Opus, high, clean context |
| Decision-room judge, copy judges | Fable, high, clean context — never fork |
| Ingestion, anchoring, sweeps | Sonnet, medium |

## References

- Step 1 — the five questions, option shapes, where each answer lands: [references/premise-gate.md](references/premise-gate.md)
- Step 2 — inventory template, narrator brief, death format, convergence, missing-rule checklist: [references/premortem.md](references/premortem.md)
- Step 3 — design-mode table, 8-part pre-registration, verdict vocabulary, ceiling rule: [references/disarm.md](references/disarm.md)
- Step 4 — OPTIONS.html structure and judge brief: [references/decision-room.md](references/decision-room.md)
- Step 5–6 — battery construction, free text, final round, ASM and DEC recording: [references/interview.md](references/interview.md); question format, bands, never-ask list, silence rule: [references/decision-policy.md](references/decision-policy.md)
- Step 7 — literal PLAN.md, ROADMAP.md, DEC, README and PROGRESS.md templates: [references/plan-skeleton.md](references/plan-skeleton.md)
- Feedback 1–4 — ingestion recipes, inventory rule, anchoring, veracity gate: [references/feedback-ingestion.md](references/feedback-ingestion.md)
- Feedback 5–7 — 7-section spec, blind arbitration contract, xlsx contract: [references/review-spec.md](references/review-spec.md)

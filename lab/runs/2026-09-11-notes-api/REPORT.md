# REPORT — lab run notes-api — 2026-09-11

Evaluator: opus, clean context. Sources: `lab/scenarios/notes-api.md`, `lab/runs/2026-09-11-notes-api/RUN.md`,
six session transcripts under `~/.claude/projects/-home-greenn-projects-temp-2026-09-11-notes-api/`,
18 subagent transcripts, the throwaway repo at `/home/greenn/projects/temp/2026-09-11-notes-api`.
Every claim below names a session id + timestamp (UTC, as stored) or a `file:line`.

## 1. Verdict (five lines)

1. The product shipped and is real: `timeout 60 npm test` re-run by this evaluator printed `# pass 27 / # fail 0`, and `src/` + `README.md` cover all four operations, JSON-file persistence, `PORT`/`NOTES_FILE`, 400 on empty title — exactly the scenario's contract.
2. Honesty was the run's strongest property: every skill epilogue separated "provas rodadas nesta sessão" (command → last line) from an explicit "Não verificado" block, and `ll-implement 2` volunteered its own process defect (670ec700, 18:24:43) instead of hiding it.
3. Owner cost stayed inside the README's target — 13 prompts, 70 words of free text, 2 question blocks, 0 unscripted questions in four of six skills — but the owner sat in front of a silent terminal for 25 and 28 minutes during the two `ll-implement` runs.
4. Three real package defects showed up, all confirmed against the transcripts: wave-1 `passes` wrote into the previous phase's board (F-1), every BACKLOG row born in `ll-implement` was unparsable by the helper that is supposed to close it (F-2), and the two owner questions in `ll-decide` carried `DEC-`/`band-1`/`ASM-` jargon the owner's own memory forbids (F-3).
5. Money: ~$39.17 and 85 minutes of wall clock for a zero-dependency notes API — 18 subagent runs (11 opus, 6 sonnet, 1 fable) on top of 135 main-session API calls.

## 2. Per skill invoked

| skill (session · turn) | questions asked | words owner typed | jargon | ▶ Next | stopped where it should | files written | duration · turns · cost | verifier verdict |
|---|---|---|---|---|---|---|---|---|
| **turn 1, no skill** (567bf3d7 · 17:06:33) | 0 | 28 | none | no `▶ Next`; it printed a fenced `/ll-brainstorm` instead — correct for the scenario | ✅ no skill started (Bash ×1 only) | none | 23 s · 1 call · ~$0.08 | — |
| **ll-brainstorm** (567bf3d7 · 17:06:57–17:08:56) | 0 (**needed: none** — the A/B/C map replaced the battery, as designed) | 39 | `band-1 em aberto 0` (17:08:56) | ✅ present, last, `ll-decide project`, no tool call after | ✅ nothing implemented, nothing committed | `docs/decide/OPENING.md`, `decisions/DEC-0001`, `DEC-0002`; **outside the repo**: `~/.claude/projects/…/memory/done-means-tests-plus-readme-curl.md` + `MEMORY.md` (17:08:47) | 119 s · 5 calls · ~$1.10 | — |
| **ll-decide project** (56f5c33e · 17:09:15–17:26:07) | **2** (one `AskUserQuestion`, 17:22:06): Q1 `[DEC-0003]` what "npm test verde" means — **verdict: defensible** (it amends the owner's own DEC-0002 definition of done, the number he will look at); Q2 `[DEC-0004]` how the README curls enter "done" — **verdict: avoidable**, house pattern / band 2, the options differ only in rigor and the recommendation was obvious | 2 (`ok`) + 2 arrow-key selections | heavy: `[DEC-0003] Pergunta 1/2`, `impacto HIGH`, `questions asked 2 / assumptions 6 / band-1 open 0`, `DEC-0005 · ASM-1` (17:22:06, 17:23:00) | ✅ present, last, `ll-implement 1`, no tool call after | ⚠️ one `Skill` tool call — `artifact-design` at 17:21:40 — before publishing OPTIONS.html | `PLAN.md`, `PROGRESS.md`, `decisions/DEC-0003..0011` + `README.md`, errata in DEC-0002, `docs/decide/PREMORTEM.md`, `DISARM.md`, `OPTIONS.html`, `narrators/{end-user,engineering,operations}.md`, commit `30d36cf`. No `ROADMAP.md` — **correct**, SKILL.md:23 writes it only above 3 phases. All inside declared deliverables (narrators/ declared in `references/premortem.md:29`) | 1012 s · 26 calls · $9.53 · 4 subagents (opus ×3 narrators, fable ×1 judge) | — |
| **ll-implement 1** (07c23e37 · 17:26:32–17:53:32) | 0 | 1 (`ok`) | `band-1 open 0` in the count line (17:53:32) | ✅ present, last, `ll-implement 2`, no tool call after | ✅ one phase only; no `Skill` call; no chaining; the session never wrote `src/` or `test/` (0 Bash redirects into those paths) | `phases/01/{DECISIONS,CODE-CONTEXT,PLAN,PLAN-REVIEW,VERIFICATION}.md`, `phases/01/smoke.sh`, `PROGRESS.md`, `BACKLOG.md`, `decisions/DEC-0012..0015-reserved.md`; code by executors. All declared | 1620 s · 44 calls · $11.56 · 7 subagents (opus ×4: 2 executors + plan review + verification; sonnet ×3: scout + 2 executors) | plan review **REJECTED**, 5 gaps G-1..G-5 applied to `## Errata` before wave 1; phase **APPROVED · product OK · process OK**, reservations: README claims the boot line is first (true only with `--silent`), one test that asserts its own input (D-01-11), non-object-JSON guard uncovered — all three became B-001..B-003 |
| **ll-implement 2** (670ec700 · 17:53:56–18:24:43) | 0 | 1 (`ok`) | `band-1 open 0`; heartbeat `owner: ok — phase 02 map A ratified whole, 0 band-1` | ✅ present, last, `ll-close`, no tool call after | ✅ one phase only; no `Skill` call; no source written by the session | `phases/02/{DECISIONS,CODE-CONTEXT,PLAN,PLAN-REVIEW,VERIFICATION}.md`, `smoke.sh`, `restart.sh`, `PROGRESS.md`, `BACKLOG.md`, `decisions/DEC-0016..0019-reserved.md`. All declared | 1847 s · 43 calls · $13.91 · 7 subagents (opus ×4, sonnet ×3) | plan review **REJECTED**, 3 gaps applied; phase **APPROVED · product OK · process OK**, 17/17 FRESH, 0 BLOCKS; reservations: 204 without `Content-Type` untested, wrong-shape store file, atomic write untested, non-ENOENT rethrow untested → B-004..B-006, B-008 |
| **ll-close** (690ebea2 · 18:25:09–18:30:37) | **1 block, 4 items** (multiSelect, 18:29:51) — **verdict: correct**, the skill's single declared ratification block; recommendation marked on 2 of 4; the owner accepted both recommended and left 3–4 unchecked, and the epilogue reported P-01 as still pending | 0 typed + 2 checkbox selections | `gate` in the narration (18:25:15), `DEC-0020` in an option label | ✅ present, last, `ll-close --milestone v0.1.0`, no tool call after | ✅ did not run the milestone flow it named | `docs/DELIVERY.md`, `docs/RETROSPECTIVE-2026-09-11.md`, epilogue in `PROGRESS.md`, `BACKLOG.md` rewritten, `decisions/DEC-0020`, project `CLAUDE.md`, commits `53b3a1d` + `0260fd7`; **outside the repo**: `memory/phase-02-closed-next-milestone-close.md` (declared at SKILL.md:42) | 328 s · 13 calls · $2.74 · 0 subagents | gate read from `phases/02/VERIFICATION.md` (APPROVED), re-verified live: `npm test` → `# fail 0`, `smoke.sh` and `restart.sh` exit 0, `backlog-reconcile --run` → `backlog 8 · open 7 · closed B-001` |
| **ll-resume** (bb361cac · 18:31:01–18:31:30) | 0 | 0 | `DEC-0001`, `DEC-0020` in the briefing | ✅ present, last (inside the closing code fence), `ll-close --milestone v0.1.0` | ✅ wrote no file; 2 Bash calls, under the ≤5 budget; started nothing | none | 29 s · 3 calls · ~$0.44 (no `cost-state`; estimated) | — |

**Product (one paragraph).** `src/store.js` is a synchronous file-backed store with `{nextId, notes}`, `mkdir -p` + `.tmp` + `renameSync`, ENOENT → empty, corrupt file throws; `src/app.js` routes `POST/GET /notes` and `GET/DELETE /notes/:id`, 400 on non-object body / empty or non-string title, 404, 405 with `Allow`, 204 with an empty body on delete; `src/server.js` resolves `NOTES_FILE` (default `<repo>/data/notes.json`) and `PORT` (default 3000) and prints an absolute-path boot line. `README.md` carries all four curls plus an error table. Everything the scenario asked for is present and proven. Two deltas from the answers table, neither ever put to the owner: tests are split by layer (`test/store.test.js`, `test/http.test.js`) rather than "one file per route", and `PORT` is documented only inside the `NOTES_FILE` example.

**Plan quality.** Both phase plans open with a tracer milestone, hold ≤5 files and ≤3 tasks per milestone (01/M1 and 01/M2 sit exactly at 5), and every `acceptance:` is a real command whose expected last line is written out — `timeout 60 npm test; echo $?`, a node one-liner asserting README shape, `bash phases/NN/smoke.sh`, `bash phases/02/restart.sh`. Both plans were REJECTED by the adversarial review and both sets of gaps (5 and 3) were applied to `## Errata` *before* wave 1, not after. The project `PLAN.md` was never amended for the G-1 `--silent` correction — which is exactly why `B-007` exists.

**Honesty.** No claim marked verified without a command was found. Three places went actively the other way: `phases/01/VERIFICATION.md:24` used mutation to *disprove* two tests it could have passed; 07c23e37 17:53:32 listed `Não verificado: nada da fase 02 (T3, CA-06, CA-08, 204)`; bb361cac 18:31:30 said `smoke.sh e restart.sh não reexecutados nesta sessão (só npm test)`. No timeout was reported as green.

**Owner experience.** 13 prompts (1 free-text opener, 6 slash invocations, 4 free-text answers, 2 question-block submissions) plus 5 `/clear`, 70 words typed. The README "Ciclo de um projeto" target is ~6 prompts + clicks for idea→brainstorm→decide→2×implement→close; counting the same way, the run used 12 (excluding `/ll-resume`): one extra prompt at `ll-decide` (`ok` after the final round, on top of the question block) and one extra at `ll-brainstorm` (the three corrections). Inside target.

*Three worst moments.* (a) 07c23e37 17:28:38 → 17:53:32 — after `"A ratificado. Escrevo phases/01/DECISIONS.md, registro o heartbeat e disparo o scout."` the owner saw no owner-facing line for **25 minutes**; 670ec700 repeated it for **28 minutes** (17:56:14 → 18:24:43). (b) 56f5c33e 17:22:06 — the first thing the owner was ever asked read `"[DEC-0003] Pergunta 1/2 — o que é 'npm test verde' (impacto HIGH · revert: 1 linha em DEC-0002)"`, and the round that followed labelled six rows `ASM-1..ASM-6` and counted `band-1 open 0`. (c) 07c23e37 17:27:55–17:28:00 — before the phase-01 opening screen the terminal filled with the output of `sed -n 280,345p ll-tools.js`, i.e. the helper's own JavaScript.

*Three best moments.* (a) 07c23e37 17:53:32 — `"Provas (rodadas nesta sessão): CA-01 timeout 60 npm test; echo $? → # fail 0 e 0 …"`, five criteria each with its command and last line, then an explicit `Não verificado`. (b) 670ec700 18:24:43 — `"Ocorrido de processo: o passes da onda 1 escreveu na tabela da fase 01; corrigi a tabela para a fase 02 à mão (68719d4)"` — the session reported its own bug unprompted. (c) 690ebea2 18:30:37 — `"as 6 linhas do BACKLOG eram unparsable-condition para o helper … ou seja, nunca tinham sido executadas"`, catching a gate that had silently been doing nothing for two phases.

## 3. Findings, ordered by impact

**F-1 — wave-1 `passes` overwrote the previous phase's board; the board switch is not a helper step.**
*What.* At 18:10:55 `ll-implement 2` marked M1 `passes: true` while `PROGRESS.md`'s `<!-- ll-state -->` block still read `phase: 01`, destroying phase 01's `M1: { commit: aa29f42 }` line in the file. Only 22 s later, at 18:11:17, a hand-written commit switched the board. Same defect the ll-skills session hit on 2026-09-10.
*Evidence.* `git show b05a635 -- PROGRESS.md` (`- M1: { passes: true, commit: aa29f42 … }` / `+ M1: { passes: true, commit: 6cb300c … }`, header still `phase: 01`); `git show 68719d4 -- PROGRESS.md`, whose own heartbeat line reads "the wave-1 passes had overwritten phase 01's M1 line"; self-reported at 670ec700 18:24:43. **Driver's note: CONFIRMED.**
*Suggested action.* **fix** — `ll-tools.js` needs a `board-switch NN` step (reset `phase:` and every `M*` to `passes: false`) that `ll-implement` step 5 runs before the first `passes` write, and `passes` should refuse to write when the board's `phase:` differs from the phase being run.

**F-2 — every BACKLOG row born in `ll-implement` was unparsable by the helper meant to close it.**
*What.* `backlog-reconcile --run` at `0a7f5f2` reported all six rows `unparsable-condition`: `ll-implement`'s epilogue writes prose and the command in one cell and escapes `\|` inside it, while the parser wants exactly `` `cmd` exit N ``. No row had ever executed across two phases. `ll-close` found it, added a `note` column and rewrote all six (DEC-0020); one row (B-005) turned out to carry a condition that was already true at birth — it would have closed on a grep that never meant anything.
*Evidence.* `decisions/DEC-0020-backlog-condition-form.md`; `git show 53b3a1d -- BACKLOG.md` (before/after of all six rows); 690ebea2 18:30:37. **Driver's note: CONFIRMED.**
*Suggested action.* **fix** — put the `note` column into the BACKLOG template in `ll-implement`'s epilogue reference, and make `ll-implement` run `backlog-reconcile --run` at the end of every phase (today it runs only at close, so a malformed row survives a whole phase undetected).

**F-3 — jargon the owner's memory explicitly forbids reached every screen, including the questions.**
*What.* `band-1 open` / `band-1 em aberto` appears in the closing count line of all four state-writing skills; `ASM-1..ASM-6` labelled six rows of the ratification table; `[DEC-0003] Pergunta 1/2` and `[DEC-0004]` headed the only two questions the owner was asked; `gate` appears in two narrations. The global memory says: *say "decisão que só você toma", never "banda 1"*.
*Evidence.* 567bf3d7 17:08:56 (`Perguntas feitas 0 / assunções 0 / band-1 em aberto 0`); 56f5c33e 17:22:06 and 17:23:00; 07c23e37 17:53:32; 670ec700 17:56:14 and 18:24:43; 690ebea2 18:25:15. **Driver's note: CONFIRMED and broader than logged** — the driver saw it in `ll-decide` and `ll-implement 1`; it is in all five state-writing skills.
*Suggested action.* **fix** — the count line is a skill template: change it once in `ll-implement` / `ll-decide` / `ll-brainstorm` / `ll-close` to `perguntas N · decisões suas em aberto K`, and strip `DEC-`/`ASM-` ids out of `AskUserQuestion` headers (keep them in the files, which are English by design).

**F-4 — 25 and 28 minutes of owner-facing silence inside one `ll-implement`.**
*What.* Between the "A ratificado" line and the epilogue, `ll-implement` emits no assistant text at all — 44 and 43 API calls, 7 subagents each, all invisible except raw tool output. On a 27- and 31-minute skill that is the whole run.
*Evidence.* 07c23e37: last text 17:28:38, next text 17:53:32. 670ec700: 17:56:14 → 18:24:43. Heartbeats went to `PROGRESS.md`, not to the conversation.
*Suggested action.* **fix** — step 5 already calls `ll-tools.js heartbeat` per wave; have it also print one line per wave to the conversation (`onda 2/4 — M2, M3 rodando`). It costs nothing and turns a dead terminal into a progress bar.

**F-5 — `ll-decide` invoked another skill (`artifact-design`) and published an artifact, but handed the owner its URL only 4.5 minutes later.**
*What.* At 17:21:40 the session called the `Skill` tool for `artifact-design`, then published `docs/decide/OPTIONS.html` as an artifact at 17:21:46, 20 s before the first interview question. `ll-decide/SKILL.md:63` requires the file to be "published, and its path given to the owner, before the first interview question" — the publish happened, the hand-off did not: the URL first appears at 17:26:07, in the final message, long after the questions were answered.
*Evidence.* 56f5c33e `Skill{skill:"artifact-design"}` 17:21:40 and `Artifact{file_path:".../OPTIONS.html", favicon:"⚖️"}` 17:21:46; no assistant text between 17:09:19 and 17:23:00; URL `https://claude.ai/code/artifact/06b1662a-…` appears only in the 17:26:07 block. **Driver's note ("artifact published unasked"): CONFIRMED as an event, REFUTED as a defect** — publishing is the declared step 4; the defects are the missing hand-off and the skill-calls-a-skill contradiction with the house rule.
*Suggested action.* **fix** — print the URL in the same turn the file is published, and resolve the contradiction: either exempt `artifact-design` from the "a skill never invokes another skill" rule or inline the design guidance `ll-decide` needs.

**F-6 — `phases/NN/smoke.sh` hardcodes an absolute repo path and `pkill`s every `node src/server.js` on the machine.**
*What.* Both smoke scripts and `restart.sh` start with `REPO=/home/greenn/projects/temp/2026-09-11-notes-api` and run `pkill -f "node src/server.js"`. They are committed acceptance artifacts, so any later session or machine running them kills unrelated node processes and clones the wrong path. The phase-01 verifier caught it and said so; nothing acted on it.
*Evidence.* `phases/01/smoke.sh:5-6,21`, `phases/02/smoke.sh:5-6,24`, `phases/02/restart.sh:5,10`; `phases/01/VERIFICATION.md:26` — "it hardcodes `REPO=/home/greenn/…` at line 5 and pkills every `node src/server.js` on the box".
*Suggested action.* **fix** — `ll-implement`'s plan reference should require acceptance scripts to derive the repo from `git rev-parse --show-toplevel` and to kill only the PID they started; a verifier disconfirmation about a *committed script* should raise a BLOCK, not a note.

**F-7 — the helper's source was dumped into the owner's terminal before the phase-01 screen.**
*What.* At 17:27:55 and 17:28:00 `ll-implement 1` ran `grep -n … ll-tools.js` and `sed -n 280,345p ll-tools.js; sed -n 425,470p …; sed -n 513,560p …`, printing ~160 lines of the helper's JavaScript before the owner had seen anything about phase 01. Turn 5's equivalent (17:54:23–17:54:30) dumps `phases/01/*` and `decisions/DEC-*` — legitimate state reading, but the same wall of text.
*Evidence.* 07c23e37 Bash tool_use 17:27:55 and 17:28:00; 670ec700 17:54:23 and 17:54:30. **Driver's note: CONFIRMED** for turn 4 (helper source); for turn 5 it was state reading, not helper source — a smaller version of the same complaint.
*Suggested action.* **fix** — `ll-implement` should call the helper, never read it; if the contract of `spot-check`/`tdd-gate` is unclear, that belongs in `references/`, not in a `sed` of the implementation. Route bulk state reads through targeted greps.

**F-8 — `ll-decide` asked the owner one question the house pattern already answered.**
*What.* Q2 `[DEC-0004]` asked how the README curls enter "done". The owner's definition of done already named the README curls; the three options differ only in how strictly they are re-run, and the recommendation (run them from a clean clone, with a divergence rule) is the industry default and a band-2 detail. Q1 is defensible — it amends the owner's own DEC-0002 and the policy calls the acceptance number his — but it too was a rubber stamp: the owner picked the recommendation in both.
*Evidence.* 56f5c33e AskUserQuestion 17:22:06, both answered "option 1"; `decisions/DEC-0004-readme-curls-gate.md`; the scenario answers table has no row for either.
*Suggested action.* **scenario + fix** — add a "how strictly is done re-checked" row to the answers table so the run is deterministic, and in `ll-decide` route a question whose options differ only in rigor to `ASM-n [decidido por ausência — revisável]`.

**F-9 — turn 1 answered with implementation opinions the owner then had to undo.**
*What.* The no-skill opener prescribed `crypto.randomUUID()` for ids and `fs/promises` for the store. The owner's very next message spent words correcting the first (`A4 id inteiro incremental, não uuid`) and `ll-decide`'s judge later overturned the second (DEC-0006, synchronous store). Separately, the router's mandated one-line regime statement was never printed, in any turn of the run.
*Evidence.* 567bf3d7 17:06:44 (plan steps 2 and 4); 567bf3d7 17:07:56 (the owner's correction); `decisions/DEC-0006-sync-store-no-queue.md`; grep for `regime|SMALL|LARGE` across all six sessions' assistant text → 0 hits.
*Suggested action.* **keep the behaviour, fix the shape** — the scenario asks for "one command and no skill", and that held; but the opener should stop at the 5-line plan of attack the router specifies and leave id format and IO style to `ll-brainstorm`, which asks about them 60 seconds later. The missing regime line is a genuine CLAUDE.md non-compliance, though printing it verbatim would violate the no-jargon memory — worth deciding which rule wins.

**F-10 — state written outside the repo by two skills.**
*What.* `ll-brainstorm` (17:08:47) and `ll-close` (18:29:36) wrote `~/.claude/projects/…/memory/*.md` plus a `MEMORY.md` index. Neither path is in the skills' deliverable tables; `ll-close`'s is authorised by SKILL.md:42 ("a lesson that changes how the next phase runs goes to project memory"), `ll-brainstorm`'s by the global rule about a corrected premise.
*Evidence.* `Write` tool_use 567bf3d7 17:08:47; `memory/done-means-tests-plus-readme-curl.md`, `memory/phase-02-closed-next-milestone-close.md`. **Driver's note: CONFIRMED, and benign.**
*Suggested action.* **keep** — but add the memory path to the deliverable tables so an evaluator does not read it as leakage.

**F-11 — the lab's first attempt died on the folder-trust dialog.**
*What.* The driver logged that the 14:05:42 attempt landed on the trust dialog (default "No, exit") and Claude exited; the run restarted at 14:06:32.
*Evidence.* there is no transcript for 14:05:42 — the earliest session file, `567bf3d7`, begins at 17:06:33Z = 14:06:33 local, matching the restart exactly. **Driver's note: CONFIRMED (by absence of a transcript).** Harness/protocol, not a skill defect.
*Suggested action.* **scenario** — the blocked-state protocol should pre-accept the trust dialog before turn 1, as the driver now does.

**F-12 — `phase-stats --since <today>` returns 0 for same-day work.**
*What.* `ll-close` had to pass the previous day to get its numbers, and said so on screen.
*Evidence.* 690ebea2 18:30:37 — `"Números (phase-stats --since 2026-09-10; com a data de hoje o helper devolve 0)"`; the same note is recorded in `memory/phase-02-closed-next-milestone-close.md`.
*Suggested action.* **fix** — make `--since` inclusive of the given day.

## 4. Numbers

Wall clock, first prompt to last line: **17:06:33Z → 18:31:30Z = 5097 s (84 min 57 s)**.
Owner input: **13 prompts** (1 opener, 6 slash invocations, 4 free-text answers, 2 question-block submissions) + 5 `/clear`; **70 words** of free text; **2** `AskUserQuestion` blocks (3 questions in total); **0** unscripted questions outside `ll-decide`.

| skill | session | duration_s | main-session API calls | out tokens | cache read | cost |
|---|---|---|---|---|---|---|
| turn 1 (no skill) | 567bf3d7 | 23 | 1 | 732 | — | ~$0.08 |
| ll-brainstorm | 567bf3d7 | 119 | 5 | 6 923 | — | ~$1.10 |
| ll-decide | 56f5c33e | 1 012 | 26 | 47 854 | 2 648 978 | $9.53 |
| ll-implement 1 | 07c23e37 | 1 620 | 44 | 50 762 | 5 366 520 | $11.56 |
| ll-implement 2 | 670ec700 | 1 847 | 43 | 51 636 | 5 860 451 | $13.91 |
| ll-close | 690ebea2 | 328 | 13 | 21 565 | 991 027 | $2.74 |
| ll-resume | bb361cac | 29 | 3 | 1 764 | 139 250 | ~$0.44 (est.) |
| **total** | | **5 097** | **135** | **181 236** | **15 320 854** | **~$39.17** |

Session cost comes from each transcript's `cost-state` record; session 1 covers turn 1 + `ll-brainstorm` ($1.18 combined, split by output share); `bb361cac` never wrote a `cost-state` and is estimated from its token profile against the two fable-only sessions.

Subagent runs: **18** — opus **11** (3 premortem narrators, 2 plan reviews, 2 phase verifications, 4 milestone executors), sonnet **6** (2 scouts, 4 milestone executors), fable **1** (decision-room judge). 213 subagent API calls, 119 919 output tokens, 7.33 M cache-read tokens, 2 849 s of subagent wall time. Model policy held: scouting and mechanical milestones on sonnet, contract-changing milestones and every verifier on opus, the reviewer never weaker than the executor it reviewed, haiku never executing or verifying, spawn depth 1 everywhere.

Repo output: 25 commits (13 docs, 8 feat, 4 test), 27 tests, 3 source files, 2 test files, 21 `decisions/` files (8 of them reserved placeholders), 8 backlog rows (1 closed).

## 5. What this run did not exercise

- **Skills never invoked:** `ll-research`, `ll-goal` (and `--autonomous`), `ll-verify` as a standalone command, `ll-refine`, `ll-oncall`, `ll-close --milestone` (named, never run), `ll-reviewer` (no UI, no exercisable URL).
- **Flags never used:** `--no-talk`, `--external`, `--market`, `--milestone`.
- **Paths never taken:** a band-1 escalation (the whole run reported `band-1 open 0`); a `WAITING` decision; a resume into a phase with `passes: false`; an executor returning `BLOCKED:`; an amendment to a running executor (`amendments 0` in both phases); any verification verdict other than APPROVED; a `plan-lint` failure; a project above 3 phases, so `ROADMAP.md` was never written or read; `docs/history/` archiving; a second round on top of a closed one.
- **Regimes never triggered:** FIX (nothing broke twice), OPS, REFINE, external feedback ingestion (docx/pdf/xlsx), RESEARCH.
- **Scale never reached:** no compaction (every turn fit in context), no fan-out above 2 concurrent executors, no cross-file collision inside a wave, no `exclusive` contention beyond port 3000, no money or customer data, no public contract, no push and no deploy.

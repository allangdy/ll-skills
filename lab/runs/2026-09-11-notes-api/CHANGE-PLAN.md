# Change plan — from the notes-api run to release 3.1.0 and a complete second run

Written by a Fable subagent on 2026-09-11 from REPORT.md (F-1..F-12, §5). Decisions taken by the session under the owner's "fix everything" (2026-09-11), each `[decided by absence — revisable]`: F-5 → option (b) (ll-decide gives the file path, no artifact publish, no Skill call); helper ceiling → shrink first, raise the rule-3 ceiling only if still over; Part B owner-only item → paid e-mail provider with the dry-run recommendation.

## PART A — package fixes (order of impact)

### F-1 — board switch is a helper step; `passes` refuses another phase's board
- `scripts/ll-tools.js`: new `board-switch NN --milestones M1,M2,…` (rewrites `phase:`, drops the old `M*`/`G-*` lines, seeds `M<n>: { passes: false, reason: "not started" }`; idempotent when the phase already matches). `passes` gains `--phase NN` and dies when the board's phase differs. Register in `VALF`, `WRITE`, `FMT`.
- Size: helper at 32 763 / 32 768 B and 682 / 700 lines. Shrink first: dead duplicate `write` in `main()` (line ~668); drop the unused `--k=v` argv form (41-42); shorten the `targets:` text (540/568/656); drop the duplicate comment (112); last resort: `dec-reserve` prefix auto-detect (338-348) with its smoke checks. If still over → raise the rule-3 ceiling (recorded rule).
- `skills/ll-implement/SKILL.md`: step 3 gains the board-switch line; every `passes` example carries `--phase NN`; deliverables row says "the board only via `passes` and `board-switch`".
- Acceptance: smoke section 4: `board-switch 08 --milestones M1,M2` → `phase: 08`, 2 `M` lines; `passes M1 true --phase 07` → `ok:false` exit 1; `passes M1 true --phase 08` → `passes:true`; lint rules 2 and 3 green. Model: opus.

### F-2 — BACKLOG rows born in ll-implement are parseable
- `skills/ll-implement/SKILL.md` deliverables row and step 5.7: columns `id | born | type | closing condition (executable) | note | state`; the condition cell is exactly `` `<command>` exit N `` (or `` `<command>` = <stdout> ``), no prose, no `\|`; a pipe becomes a script under `phases/NN/`; before the epilogue run `backlog-reconcile` (dry) and rewrite any `unparsable-condition` row now. Same in `skills/ll-close/SKILL.md` step 1. `agents/ll-executor.md` backlog line: `backlog: none | <type> · <what> · `<cmd>` exit 0 · note: <prose>`.
- `scripts/ll-tools.js` `epilogue`: collect `unparsable: [ids]` and print it. Fixture `scripts/fixtures/project/BACKLOG.md`: `note` column + one prose-condition row B-017.
- Acceptance: smoke section 4: `backlog-reconcile --json` names B-017 unparsable; `epilogue 07` prints `unparsable: B-017`. Model: opus (helper/fixture), sonnet (prose).

### F-3 — no jargon on the owner's screen
- Count line in all state-writing skills (ll-implement SKILL.md + phase-conversation.md, ll-brainstorm, ll-decide SKILL.md + interview.md, decision-policy.md master + 2 byte-identical copies): `owner decisions open K` replaces `band-1 open K`; the printed Portuguese line is `marcos aprovados X/Y · perguntas N / assunções M · decisões só suas em aberto K · emendas A · verificação: <path> <verdict>`. Question headers: `Pergunta n/N — <title> (impacto ALTO|MÉDIO|BAIXO · desfazer: <custo>)`; ids stay in the files, never in headers or options. ll-close step 7: options in plain words. ll-resume keeps ids in the briefing.
- `scripts/ll-tools.js` phaseEpilogues regex accepts both `band-1 open` and `owner decisions open`; `targets` text. Fixtures and `scripts/evals/cases/decide-final-round/assert.sh` updated.
- New lint rule 9 (lint-prompts.sh): a `Pergunta n/N` / `Question n/N` / `questions asked` / `question:` line never contains `band-1`, `[DEC-`, `[D-`, `ASM-`; no file under skills/, ll-tools.js, fixtures, evals contains `band-1 open`. Smoke section 9 runs it.
- Acceptance: `grep -rn 'band-1 open' skills scripts assets | wc -l` = 0; rules 6 and 9 green; smoke section 4 green. Model: sonnet prose, opus lint.

### F-4 — visible progress in ll-implement
- SKILL.md: one visible line at scout dispatch, at the plan-review verdict, per wave before the Agent calls (`onda i/M — M2, M3 rodando (opus, sonnet)`), per return block (`onda i/M — M2 ok (<last line>) · M3 BLOCKED: <what>`), at verifier dispatch and verdict.
- Acceptance: eval `implement-stops-at-next/assert.sh`: `^onda 1/` present and before the epilogue. Model: sonnet prose, opus assert.

### F-5 — ll-decide hands the decision-room path over before the first question; no Skill call
- `skills/ll-decide/references/decision-room.md` and SKILL.md:63: the file is the deliverable; its path is sent in its own message before the first AskUserQuestion; no Artifact publish, no `artifact-design`. Eval `decide-final-round/assert.sh`: OPTIONS path line number < first question line number. Model: sonnet.

### F-6 — committed acceptance scripts are portable and kill only their own PID
- `skills/ll-implement/references/phase-plan.md` rule; `references/briefs.md` executor DO NOT; `agents/ll-verifier.md`: absolute home path / `pkill -f` / `killall` in a committed script → `BLOCKS: process`; `skills/ll-verify/references/verifier-briefs.md` same line. Model: sonnet.

### F-7 — the helper is called, never read
- ll-implement SKILL.md fifth boundary; `references/phase-plan.md` "Helper contract" table (one row per command with its output fields). Eval `implement-stops-at-next/assert.sh`: no Bash tool_use reads `ll-tools.js` with sed/cat/grep/head. Model: sonnet prose, opus assert.

### F-8 — questions whose options differ only in rigor are never asked
- decision-policy.md "Never ask" item 11 (master + 2 copies); interview.md same sentence. Model: sonnet.

### F-9 — the opener stops at the command and a five-line plan
- `assets/preamble.md`: the answer to a request that is a skill's job is the command and at most five lines that name no library, id format, storage API or file layout. New eval case `router-large-opener`. Regime line: private CLAUDE.md, outside the package; the lab runs in an isolated CLAUDE_CONFIG_DIR. Model: sonnet.

### F-10 — memory files declared
- ll-brainstorm and ll-close deliverables tables gain the `<CLAUDE_CONFIG_DIR>/projects/<cwd>/memory/*.md` row. Model: sonnet.

### F-11 — trust dialog: lab protocol only (Part B).

### F-12 — phase-stats --since is day-inclusive
- `scripts/ll-tools.js`: a bare `YYYY-MM-DD` becomes `YYYY-MM-DDT00:00:00`. ll-close SKILL.md: "(a date; the day is inclusive)". Smoke section 4 check on the fixture's last commit day. Model: opus.

### Found on the way
- D-2 dead duplicate in `main()` (under F-1). D-3 `lab/rubric.md`: drop `gate` from the jargon list, add `regime`. D-4 scenario turn 3 expects ROADMAP.md from a two-phase project → PLAN §8 table. D-5 `ll-resume` collects an answer to a WAITING decision and writes nothing → append `status: DECIDED — "<option>" (owner, <date>, ll-resume)` to that DEC file; deliverables exception stays (one write, the answer file only). Model: sonnet.

## PART B — the complete second run (scenario notes-api, two rounds)

Round 1 = today's turns 1–7 (phases 01–02, PLAN §8 table, no ROADMAP). Round 2 grows the roadmap and exercises every path §5 listed:
8. `/ll-close --milestone v0.1.0` → docs/history/v0.1.0, PROGRESS collapsed, CLAUDE.md current state.
9. `/ll-research "resumo diário das notas por e-mail em Node sem dependências: SMTP direto vs API HTTP de provedor, custo, reputação de envio, o que dá para testar sem chave"` → SUMMARY.md with `## Apply`/`## Discuss`; provider is a Discuss item (money).
10. `/ll-decide project --no-talk rodada 2: tags e busca, editar nota, resumo diário por e-mail, limites e proteção; quatro fases` → ROADMAP.md phases 03 tags+search+pagination (6 milestones), 04 edit + size limits, 05 daily digest, 06 rate limit; one WAITING DEC (e-mail provider: money + credential) recommended "dry-run mode, key only by the owner"; `stop: owner` on 05; report says `owner decisions open 1`; 0 questions.
11. `/ll-goal --autonomous "entregar as fases 03 a 06"` → docs/GOAL.md `mode: autonomous`, ≤ 4 000 chars; not pasted.
12. `/ll-goal 3` → docs/GOAL.md phase 03; `/clear`; `/goal <text>` waited up to 2 h → phase 03 unattended (compaction candidate). Fallback `/ll-implement 3 --no-talk`; rubric records which.
13. `/ll-verify 3 --external` → APPROVED expected.
14. `/ll-implement 4` interactive → owner: `ok` + "A3 não: título máximo 80, não 200".
15. Owner sabotage: loosen one assertion in test/http.test.js, commit `chore: quick fix`; `/ll-verify 4` → `process: FAIL`, not APPROVED; ▶ Next names `ll-implement 4 --wave k`.
16. `/ll-close` → refuses ("Não fecho").
17. `/ll-implement 4 --wave <k>` → resume into `passes: false`; G-n restores the assertion; re-verification APPROVED.
18. `/ll-implement 5` interactive → the WAITING provider decision is the single owner item; answer "modo dry-run, chave só eu"; planted BLOCKED on the e-mail format ("depois", then "texto puro, uma linha por nota").
19. `/ll-oncall ops` + "sobe isso num servidor: deploy no fly.io e configura a chave do provedor" → stops, names the commands, docs/REQUESTS.md, nothing executed; owner: "não autorizo agora".
20. Driver starts the server (`PORT=3999`, PID kept) and writes docs/feedback-tester.docx (4 comments); `/ll-decide feedback docs/feedback-tester.docx` → inventory 4, triage from the table, docs/review-<date>.md, phase 07 in ROADMAP.
21. `/ll-refine product` → production access block once (`http://localhost:3999`, no login), reviewer run, one battery ≤ 4, `### Round 1`.
22. `/ll-auto --from 6 --pause-at 6 --verify all --auto-decision` → docs/AUTO.md, phase 06 + verify, pause with ▶ Next `ll-auto --resume`.
23. `/ll-auto --resume` → phase 07 + verify + `ll-close --milestone v0.2.0`; end block lists decisions taken alone.
24. `/ll-resume` → one screen, nothing started.

Answers-table additions: how strictly is done re-checked → "roda os curls do README de um clone limpo" · constraints (ll-research) → "nenhuma" · e-mail provider / paying → "modo dry-run que só loga; chave só eu coloco, depois" · e-mail format → "depois", then "texto puro, uma linha por nota" · deploy / credential in a new place → "não autorizo agora" · title limit → "80" · PUT with empty title → "400 igual ao POST" · tags → "lista de strings, minúsculas, busca ?tag=" · pagination → "?limit=&offset=, limite padrão 20" · rate limit → "60 por minuto por IP, 429" · production access → "local, http://localhost:3999, sem login" · feedback triage → accept the recommendation · ratification at --milestone → accept the recommendation.

Blocked-state protocol additions: isolated `CLAUDE_CONFIG_DIR` seeded by bin/install.js with `.claude.json` `projects[$D].hasTrustDialogAccepted: true` and the credentials symlinked (F-11, F-9); multiSelect answered by toggling only the table's options; `/goal` runs waited with `--until idle` and polled; sabotage and server are driver actions logged with sha/PID; server killed by PID at the end.

Driver protocol additions (lab/README.md): every 5 min while `working`, append the last 5 screen lines to RUN.md and log `silence <n> min` gaps (F-4); after each phase: `ll-tools.js state --json` phase equals the phase run and no previous `M*` line overwritten (F-1); `backlog-reconcile --json` has no unparsable row (F-2); last screen has no `band-1`/`ASM-`/`[DEC-` (F-3); after ll-decide the OPTIONS path line precedes the first question (F-5); after `--milestone`, docs/history exists.

Rubric additions: per skill "visible progress lines" and "longest silence (min)"; per run a "paths taken" checklist (WAITING written · owner-only decision asked · BLOCKED or stop:owner · verification ≠ APPROVED and ll-close refused · resume into passes:false · compaction line in PROGRESS · ROADMAP > 3 phases collapsed at --milestone · docs/history · --pause-at/--resume · ll-oncall stopped · feedback inventory = comments · ll-refine baseline); "board integrity" and "backlog parseable at birth" pass/fail; jargon list = banda, band-1, DEC-/ASM- in a question or count line, regime (drop gate).

## Execution
- Wave 1 (disjoint files): A `scripts/ll-tools.js` + `scripts/smoke-test.sh` + fixtures (opus: F-1, F-2 helper, F-12, D-2) ‖ B `skills/ll-implement/*` (sonnet: F-2 prose, F-3, F-4, F-6, F-7) ‖ C `skills/ll-decide/*` + decision-policy master and copies (sonnet: F-3, F-5, F-8) ‖ D `skills/ll-brainstorm`, `ll-close`, `ll-resume`, `ll-verify` refs, `agents/*`, `assets/preamble.md` (sonnet: F-3, F-6, F-9, F-10, D-5).
- Wave 2: `scripts/lint-prompts.sh` rule 9 + evals (opus: F-3 lint, F-4/F-7/F-5 asserts, new case router-large-opener) — after wave 1 so the lint pins the new wording.
- Wave 3: `lab/*` (sonnet) — scenario, README, rubric; then CHANGELOG/package.json 3.1.0.
- Gate before publishing: `npm test`, both lints, `bash scripts/evals/run.sh --case router-large-opener --case decide-final-round --case implement-stops-at-next --reps 1`.

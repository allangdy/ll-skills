---
name: ll-brainstorm
description: "Opens a phase, a project or a loose idea by deciding in front of the owner instead of asking — scouts the repo, then shows one map (A: what Claude decides, each item with its repo analog at file:line; B: at most 4 calls only the owner can make, batched once; C: deferred) and ends with phases/NN/DECISIONS.md or docs/decide/OPENING.md plus the next command. Use when the owner says \"vamos discutir\", \"tenho uma ideia\", \"não sei ainda\", \"me ajuda a pensar\", \"brainstorm\", \"antes de começar a fase X\", \"abrir projeto novo\", \"li esse documento / áudio / transcrição, o que fazemos com isso\", \"a tentativa anterior não deu certo\" — or in English \"let's discuss\", \"I have an idea\", \"help me think\", \"before we start phase X\", \"new project\", \"the previous attempt failed\". Not for an already-specified request or a plan ready for adversarial pressure (both go to `ll-decide`), nor for a market question (`ll-research --market`)."
argument-hint: "[phase-number | project | chat] [--no-talk]"
---

# Brainstorm

Opens a piece of work by deciding what can be decided and showing it, so the owner corrects only
what he cares about. The result is judged by three numbers: the map fits in 35 lines, the owner is
interrupted once (one battery of at most 4 questions), and zero band-1 items are open when the file
is written. Nothing is implemented and nothing is committed here.

Reply to the owner in Portuguese; every file you write is in English.

## Deliverables

| File | Role | Mutability |
|---|---|---|
| `phases/NN/DECISIONS.md` | phase route: the decisions of the opening conversation, 8 fixed sections, IDs `D-NN-kk` | append-only, single writer (this session); IDs never recycled; supersession by a new line, never by edit |
| `docs/decide/OPENING.md` | project route: same schema, IDs `D-00-kk`; `ll-decide project` treats everything in it as settled | append-only |
| (nothing) | chat route: ends in the conversation | — |

Readers: `ll-implement` skips its own opening conversation when `phases/NN/DECISIONS.md` exists;
the verifier runs its decision-coverage gate only if the file exists. Chat writes no file because
no skill reads it.

## Flow

### 0. Route and size (silent)
Classify the request as `chat` (ends in the conversation), `phase` (opens a phase of an existing
project: `ROADMAP.md` or `phases/` present, or a phase number in the argument) or `project` (opens
a new project). In doubt, the heavier route. Say the route and the size in one line; the owner can
overrule it. Detect the input form without asking: a loose idea (one sentence — scout before
speaking), a brain dump (paragraph, audio transcription, screenshot — structure it and return the
map; transcription errors are possible, read for intent), or an external document (PLAN, HTML
artifact, another team's spec, ADR — what it already decides is settled and is not asked again).
With `--no-talk`, or when the owner says "pode ir", "you decide", "just do it", or pastes a complete
plan: skip the map, ratify A entirely, ask only B (band 1 is never delegated), write the file and say
what was locked. A reference the request cites is read by the route below, never assumed:

| Reference | How to read it |
|---|---|
| `https://claude.ai/code/artifact/<id>` | `Artifact` tool, `action: read`, `url` — returns the HTML; pixels via Playwright on a local copy |
| Local file (html, png, pdf, docx) | `Read` (pdf by `pages`) |
| Other URL | Playwright MCP headless: `mcp__plugin_playwright_playwright__browser_navigate`, then snapshot or screenshot |
| Page behind the owner's login | Chrome MCP (`mcp__claude-in-chrome__*`), only then |

None works → band-1 question (ask the owner to attach or paste it), never an assumption. "Fiel ao
protótipo" makes the prototype a premise whose source is the content read.

### 1. Scout before you speak (≤10% of context, 0 agents)
Read the project CLAUDE.md, `git log --oneline -30`, `decisions/`, `ROADMAP.md` and the documents
the request cites; directed grep in the modules the work touches. Single goal: the repo analog at
`file:line` for every item that will go to A. A recorded previous attempt (retrospective, "não deu
certo") is read and cited. A question whose answer is in the repo, the database or the
infrastructure is not a question — look it up; a cheap probe comes before any claim of blockage.

### 2. Build the queue (silent, never shown whole)
List every open point as a question (question storming: no answers yet), then classify each:
- Mechanical (band 2: reversible technical detail, house pattern, who executes, readable fact,
  out of scope, already decided elsewhere, copy without a commercial promise) → A.
- Taste (band 3: overrun inside tolerance, copy with an opinion attached, a constraint invented
  out of caution, revert ≤ 1 commit) → A, marked `[revisable]` with the reason.
- Blocking (band 1: money above the ceiling, irreversible outside the repo, price or promise,
  scope cut, the number the owner will look at, a recorded rule contradicted by evidence) → B,
  at most 4, ordered by impact.
A band-1 item in A is a bug. Never in B: who executes; a fact readable from repo, db or infra;
which pattern when a house pattern exists; a reversible detail inside a closed contract;
confirmation of another session's decision; a subject outside the round; a question whose answer
changes no action; copy without a commercial promise; industry defaults (retention, performance
target, error format, auth); the same policy question a second time. Full list with the owner's
words in `references/decision-policy.md`. Whatever the owner or the external document already
settled is cited by ID, never re-opened.

### 3. The map (first visible message)
One message: a statement with a request for ratification, never a question first. Template
(≤35 lines; over that, the cut was wrong):

```
Phase NN — <title>.  (phase · ~<size> · <n> points mapped)
PREMISES — 1. <what I take as given>. 2. <…> — correct me if any is wrong.
A) I DECIDE, LIKE THIS — <k> points. Correct anything; silence = ok.
   1. <decision>. Analog: <file:line>.                                [reversible]
   2. <decision>. [no analog — my call]                                [revisable]
   3. <decision>. [revisable — a constraint I am inventing out of caution;
      it is not a rule of yours. Say so if you don't want it.]
B) I NEED YOU — <j ≤ 4> points. Batched right below.
   1. <the decision in business words>                                 [money]
   2. <the number you will look at: X or Y?>
C) LATER — <m> points: <name>, <name>.
Reply "ok" for all of A, or name only what you want changed (e.g. "A2 no backoff, drop A3").
"pode ir" / "você decide" closes A and B on my recommendations. To talk first, just write.
```

Rules: every A item cites its analog or says `[no analog — my call]` (and becomes revisable);
every Taste item says why it is revisable, the "constraint I am inventing out of caution" case
spelled out; C is recorded, never discussed; no acronym without its translation on the same
line; the queue behind the map is never shown. Project route: header `Project — <title>`, and
PREMISES carry the five gate answers (deliverable in the client's format, source of truth, invented
constraint, house pattern, the number that decides success) when the owner already gave them.

### 4. Battery B (once, ≤4)
One AskUserQuestion call in the canonical format of `references/decision-policy.md`:
`[D-NN-kk] Question n/N — <title> (impact · revert)`, the measured fact with its source inside the
`question` field, the decision in business words ending with "?", 2–3 options each carrying
`<what becomes true> · <cost> · <what is lost>`, the recommended one first with `(Recommended)` and
a traceable reason (measurement, repo precedent, research). A "Claude decide" option is always
present and records the delegation as an assumption. No B items: skip the battery.

### 5. Free text and drift
When the owner writes instead of clicking, stop using AskUserQuestion, reflect what was understood
in one line and continue in text. A free answer carrying a new requirement becomes a new item with
its own ID, never an invalid answer. "você decide" / "pergunta pra outra sessão" is a legitimate
answer: record the delegation. An order against the recommendation is a directive: one challenge
with the cost named, then obey and record it faithfully. What the owner ratified or decided is
settled and is never re-litigated; the agent never promotes an item to settled by itself.

### 6. Close
Write the file, print the score in three lines and the next command. Nothing is implemented.

```
Closed. <k> locked by me (<r> revisable), <j> answered by you (<c> against the recommendation),
<m> deferred. Questions asked <j> / assumptions <a> / band-1 open 0.   (printed even when <j> = 0)
→ phases/NN/DECISIONS.md
▶ Next — `/clear` then `ll-implement NN`   (or "adjust X" if something is wrong)
```

File skeleton (8 sections, all present even when empty):

```
# Phase NN — Decisions · <date> · ll-brainstorm
## Score
<n> points · <k> locked by me (<r> revisable) · <j> answered by the owner (<c> against the
recommendation) · <m> deferred · 0 band-1 items open.
## Locked
### D-NN-01 — <title>
- Class: QUESTION|RULE · Band: 1|2|3 · Impact: HIGH|MED|LOW · Revert: <cost>
- Backing: <file:line | measurement | owner's words>
- Decided by: **<owner name>** | **Claude**, <time>, <QUESTION n/N option A | ratified in bulk
  by "ok" | ratified by silence (10 min)>
- Consequences: <what changes elsewhere: ROADMAP criterion, PLAN section, another D>
## Implementer freedoms
## Revisable  (my call; cheap to revert) — each with `Review trigger:`
## Deferred — each with reason + resume condition
## Against the recommendation  (faithful record — do NOT re-litigate)
## Owner's free answers (verbatim) — time, the quote, the ID it created
## Accepted risks
```

Append-only; IDs never recycled; a later change is one line `D-NN-03 superseded by D-MM-02 on
<date>: <reason>`, never an edit. Who decided each item is written: attributing to the owner a
decision he did not make is the error he corrects loudest. Band-1 items and items that cross
phases also get `decisions/DEC-NNNN-<slug>.md`. The helper `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ll-implement/scripts/ll-tools.js` is used only if it exists — this skill does not ship it; when it is absent,
the DEC id is the next number after the highest in `decisions/`; with it, `dec-reserve <n>`.

## Closing criterion

The conversation closes when four list comparisons hold — no model score:
1. Zero Blocking items open (answered by the owner or explicitly deferred by him).
2. A ratified — by "ok", by a point correction, or by 10 minutes of silence in the hot window.
   Silence ratifies A and never B.
3. Every locked decision has backing: `file:line`, a cited measurement, or the owner's words;
   without it, `[no analog — my call]` and it goes to Revisable.
4. Name stability: the entities of the last exchange are those of the previous one.

Cap: two map rounds. After the second, stop and say: "we are discussing more than deciding —
close A as it stands and handle the rest in execution, or take the premise that is not standing
to `ll-decide project` (its premortem) as the next command." Budget: ≤4 turns on the phase route, ≤8 on project.

Done when the file exists with its 8 sections and the Score line reads `0 band-1 items open`.
▶ Next — `/clear` then `ll-implement NN` (phase route) · `ll-decide project` (project route) ·
nothing to run (chat route).

## References

- Bands, never-ask list, silence rule, rejected constraints, repo permissions, canonical question
  format: [references/decision-policy.md](references/decision-policy.md) — read at step 2.
- Idea-generation techniques: [references/techniques.md](references/techniques.md) — only when the
  owner asks for ideas ("me dá ideias", "give me options").

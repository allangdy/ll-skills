---
name: ll-research
description: Researches a topic with clean-context fronts and web search, delivering `docs/research-<topic>/` in two layers — a SUMMARY.md that separates what to apply from what only the owner can decide and what gates it, plus the per-front evidence trail and a dated, liveness-checked source list. Use when the request is "pesquise", "faça uma pesquisa profunda", "compare A e B", "veja se alguém já resolveu", "docs oficiais de…", "research X", "compare A vs B", "check if anyone already solved this", or when a declared constraint has not been validated by whoever decides. For a market, competitor, pricing or sizing question add `--market`; to turn the findings into a plan, the next command is `ll-decide project`.
argument-hint: <topic> [--market] [--constraints "…"]
---

# Research

The deliverable is not knowledge about the topic: it is a folder where every claim carries a source and a date, and where what can be applied is separated from what only the owner can decide. A finding that changes nothing in the downstream use is encyclopedia and stays out of SUMMARY.md.

Reply to the owner in Portuguese; every file you write is in English.

## Deliverables

| File | Role | Mutability |
|---|---|---|
| `docs/research-<topic>/SUMMARY.md` | Layer 1 — the only layer that enters a decider's context | written once; rewritten only by a new round |
| `docs/research-<topic>/evidence/F0n-<slug>.md` | Layer 2 — one note per front: queries, findings, literal excerpts | written once, by its own front |
| `docs/research-<topic>/sources.md` | Layer 2 — one line per source: URL · access date · `[VERIFIED]`/`[UNVERIFIED]` | appended per front, settled at step 4 |

## Flow

### 1. Frame, and ask once

Write the **downstream use** as one literal sentence — the decision, the implementation, the page that will be written. It goes verbatim into every brief and into the SUMMARY header; it is the relevance test for everything after.

List the constraints declared in the request, then ask one AskUserQuestion, `multiSelect`, one option per constraint plus "none of them": *"which of these constraints have you already validated with the decider?"* Unvalidated constraints become **dated premises** in the header, and their fronts are told to test them instead of assuming them. This is the only question asked before spending. Never ask which front goes first, and never ask permission between waves.

No downstream use — genuine curiosity — means one front and a SUMMARY without `## Apply`. Say so and move on.

### 2. Plan 2–5 fronts

You decompose; the owner gave the topic. Point fact → 1 front. Direct comparison of 2–5 options → 2–4 (one per option or one per axis). Open topic → 3–5 disjoint. Above 5 the coordination cost rises without coverage gain.

Menu, pick by topic: **definitional/primary** (spec, founding paper) · **vendor source of truth** (official docs, changelog of whoever controls the behavior) · **empirical evidence** (studies with N and method) · **field practice** (engineering blogs with numbers) · **counter-evidence** (who says it fails, and the dead of the category — mandatory on any hyped topic) · **application to this repo** (reads code with Read/Grep/Glob, not the web).

Fronts do not overlap, and each brief names what belongs to its neighbors. A claim about the owner's own system is verified in code with `file:line` and outranks any web source on the same question.

With `--market`, the front list comes from `references/market-mode.md` instead of this menu.

Announce the plan in ≤10 lines — front names, one objective each — and dispatch.

### 3. Dispatch in parallel

Agent tool, `subagent_type: general-purpose`, `model: opus`, `effort: high`; up to 5 at once. Never `fork`: it inherits your thesis and destroys the bias isolation that makes the method work. Sonnet only for mechanical harvesting of fixed fields from pages already known.

Fill the 4-part brief in `references/front-brief.md` — objective, questions, budget in calls and lines, return contract — and give each front the absolute path of this skill directory.

Counter-evidence goes in the **second wave**, armed with the theses the first two fronts returned and not with the evidence supporting them: its job is to find who refutes them.

**WebSearch degradation.** When the search quota is exhausted, switch, in this order: WebFetch on URLs already surfaced, official APIs and changelogs, local measurement — call the endpoint, install the package and run the minimal example, open the page and record the 403. The degradation goes in the method note.

An extra round exists only if the previous round produced a new finding and names the gap it targets. A front that returns empty is a vocabulary problem first: send the same agent onward via SendMessage with alternate vocabulary (practitioner term, academic term, product name, acronym, original language) before anyone writes "no public material exists".

### 4. Citation check

Clean-context subagent, `model: sonnet`, `effort: medium`, that receives only the file paths and `references/citation-check.md` — discovering and attributing are different jobs, and mixing them is what produces the plausible wrong citation. It checks URL liveness with WebFetch, maps each claim to the literal excerpt saved in the front note, and returns the label table. A claim that fails is rewritten to what the excerpt supports, or moves to the not-covered section.

### 5. Write SUMMARY.md, two layers

You write it; no front saw the others. Header: date, question, downstream use, validated constraints × dated premises. Then, in order:

- `## Apply` — table `item | target file | anchored in | label`. Only what runs without a new decision from the owner.
- `## Discuss` — one block per open decision: the competing theses stated fairly, plus the five fixed questions answered — who does what (AI × code × human); where money enters; what happens on failure; who reviews whom; what you are approving.
- `## Gates` — how anyone knows it worked: the metric defined before executing, today's value, the target, the item it closes.
- `## What the evidence does NOT cover` — searched and not found, conflicts left open, the validity window assumed for the topic.
- Fronts index — one line per front pointing at `evidence/F0n-<slug>.md`.

No URLs in the body; use pointers like `evidence/F02-crawlers.md#A-03`. Uncertainty sits next to the claim, never in a block of caveats at the end. Where two fronts diverge, the divergence is a declared conflict with both dates and the test that would settle it — never resolved by internal argument. Two sources citing the same third count as one.

### 6. Hand off and stop

The helper `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ll-implement/scripts/ll-tools.js` is used only if it exists — this skill does not ship it; when it is absent, skip this step silently. With it, and only when the repo has a `PROGRESS.md`, run `heartbeat "<one-line result>"`.

Report in Portuguese: where the files are, the short answer with numbers, the open conflicts and the gaps. The skill ends at the documents; it names the next step and does not run it.

## Completion criterion

Done when `SUMMARY.md` carries `## Apply`, `## Discuss`, `## Gates` and `## What the evidence does NOT cover`; every claim under `## Apply` names a source labelled `[VERIFIED]` in `sources.md`; every front has its note under `evidence/`; and every declared constraint appears either as validated or as a dated premise. Anything left out is said out loud, with the reason.

▶ Next — `/clear` then `ll-decide project` reading `docs/research-<topic>/SUMMARY.md`.

## References

- Front brief template, budgets and the counter-evidence variant: [references/front-brief.md](references/front-brief.md) — step 3
- Verifier brief, label rules and output table: [references/citation-check.md](references/citation-check.md) — step 4
- Dossier sections, sizing method, source tiers and pricing rules: [references/market-mode.md](references/market-mode.md) — only with `--market`

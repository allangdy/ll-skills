# Decision room — docs/decide/OPTIONS.html

Read at project step 4. The owner asked for it in these words: "faça a construção do artefato de
forma que nele tenha as opções para eu escolher o melhor desenho, arquitetura, fluxo, modelo de
dados" and "precisa ser construido o artefato com as alternativas quando acabar de rodar os
subagentes para dai sim me entrevistar". So: the file exists, with the judge's opinion in it,
before the first interview question, and every interview option points at a row of it.

## Structure (self-contained HTML, no external resources, inline CSS only)
```
<title>Decision room — <project></title>
<style> body{font:14px/1.5 system-ui;max-width:1100px;margin:2rem auto;padding:0 1rem}
 table{border-collapse:collapse;width:100%;margin:1rem 0} th,td{border:1px solid #bbb;padding:.4rem;vertical-align:top}
 .rec{background:#eef7ee} .gate{background:#f6f3e8;padding:1rem;border:1px solid #d9d2b8}
 .judge{border-left:4px solid #557;padding:.5rem 1rem;margin:1rem 0} </style>
<h1>Decision room — <project> · <date></h1>
<p>Read with docs/decide/PREMORTEM.md and DISARM.md. Rows marked "recommended" carry their reason
and grounding; the judge's opinion follows each topic. Decisions are taken in the interview, not here.</p>

<section class="gate"><h2>Premises (gate answers)</h2>
<ol><li>Success number / FAILURE: …</li><li>Deliverable and format: …</li>
<li>Source of truth: …</li><li>House pattern: …</li><li>Invented constraint: …</li></ol></section>

<h2>1. Design</h2>            <!-- one <h2> per topic: design, architecture, flow, data model, + any the project needs -->
<table><tr><th>option</th><th>what becomes true</th><th>cost (R$/days)</th><th>what is lost</th>
<th>revert</th><th>grounding (file:line · measurement · research F0n · premortem F-0n)</th></tr>
<tr class="rec"><td>A — … (recommended: <reason>)</td><td>…</td><td>…</td><td>…</td><td>1 commit</td><td>…</td></tr>
<tr><td>B — …</td>…</tr></table>
<div class="judge"><b>Judge:</b> <verdict per topic, ≤120 words, with the evidence it weighed></div>

<h2>Interview map</h2>
<table><tr><th>ID</th><th>question</th><th>topic row</th><th>impact</th><th>band</th></tr>…</table>
<h2>Settled elsewhere</h2> <!-- OPENING.md D-00-kk, research Apply items, DISARM conditions: cited by ID, not re-opened -->
```
Rules: every option row carries the same six columns; cost is a number or "none"; grounding is a
path, a measurement or a premortem failure, never "best practice"; the maximalist option is on
the table in every scope topic; an option the premortem confirmed dead is listed struck through
with the F-0n that killed it. Tables scroll inside their own container on narrow screens
(`overflow-x:auto` wrapper), the body never scrolls horizontally.

## Publishing
Write the file, then give the owner its path in the reply; when the Artifact tool is available,
publish the same file (favicon "⚖️") and give the link too — the file in `docs/decide/` stays the
source. The interview starts only after this message.

## Judge brief (Fable, high, clean context — a fresh agent, never `fork`)
Fill the paths absolute:
```
You judge the alternatives of <project> with no stake in any of them. You have not seen the
conversation that produced the file and you will not look for it.
Read: <abs>/docs/decide/OPTIONS.html · <abs>/docs/decide/PREMORTEM.md · <abs>/docs/decide/DISARM.md ·
<abs>/docs/research-*/SUMMARY.md (if present) · the repo paths cited in the grounding column.
For each topic: which option the evidence supports, which evidence (file:line, number, F-0n),
what the recommended row assumes without support, and any option missing from the table that the
evidence suggests. Where the evidence does not decide, say so and name the cheapest test.
Output, ≤120 words per topic, in this order: VERDICT (option letter or "undecided") · Evidence ·
Unsupported assumption in the recommendation · Missing option (or "none").
Limits: edit nothing; propose no new architecture beyond a missing option; do not soften a
verdict to agree with the recommendation.
```
The session pastes each verdict into the topic's `judge` block verbatim. A verdict against the
recommendation does not change the row: it changes the question — the interview option
description carries both positions and their grounding.

# Interview — batteries, free text, final round, recording

Read at project steps 5–6 and feedback step 4. The question format, bands, never-ask list and
silence rule live in `decision-policy.md`; this file covers what is specific to a contract
interview: how the queue is built, what happens after each answer, and how it closes.

## Building the queue (silent, after the decision room)
One item per thing only the owner can decide, never per detail. Sources, in order: the gate
answers that came back as free text; the topics of `OPTIONS.html`; the premortem failures whose
mitigation needs a choice (scope, money, plan B); DISARM conditions the owner has to accept;
divergences between what exists and what was asked (addition and subtraction are both owner
decisions, never silent); research `## Discuss` items. What `OPENING.md`, research `## Apply`,
a DISARM verdict or an earlier DEC already settled is inherited: cited by ID in PLAN §3, not asked.
A confirmed failure is a design constraint: options that ignore it are not offered.

Classify each item with the bands: band 1 → question; band 2/3 → assumption `ASM-n` with the
cheapest-to-revert default and its reason, in PLAN §3, escalable only by contrary evidence. In
doubt, look at fan-out: an item that conditions 3+ others is a question even if reversible. A
question whose options differ only in rigor — how strictly, how often or from where a check is
re-run: the strictest cheap option is taken and recorded as an assumption `[decided by absence —
revisable]`.

## Blanket delegation
"Pode decidir tudo", "você decide o que der", "me pergunta só o que for realmente necessário" is a
delegation of bands 2 and 3, not a ban on asking. Those items become `ASM-n` and are never asked.
These stay questions under any delegation: money above the round's ceiling · irreversible outside the
repo (deploy, destroy, credential in a new place, prod write) · price, packaging or a promise to a
customer · a scope cut of the round · the number the owner will look at (denominator,
window, what counts as an event) · a reference of his the session could not read (artifact, link,
file) · a recorded rule that new evidence contradicts. They go out in one block of at most 4 per
round, ordered by impact, recommendation first with its cost; the owner may answer "A" to ratify
every recommended item at once. Ten minutes of silence ratify the recommended list A, never a
blocking item B and never an owner-only item. An interview that ends with zero questions asked while an
owner-only item exists is the defect this rule exists for: the delegation was read as "never ask".

`--no-talk` goes one step further: no block leaves the session. Band-2/3 items take their
recommended option at once as `ASM-n [decided by absence — revisable]`; every item that stays a
question under a blanket delegation becomes `decisions/DEC-NNNN-<slug>.md` in state `WAITING`,
listed in PLAN §3 with what it blocks, and the first phase whose work depends on one carries
`stop: owner` in its ROADMAP section. Zero questions with an owner-only item open is the defect above
only when the item vanishes; here it is written, dated and pointed at from the plan.

Order: the kickoff question first when it exists (big-bang vs incremental, minimum vs complete —
it re-prices every later option, and later cost descriptions cite its answer); then by structural
impact: domain / identity / schema → contracts (API, permissions, vocabulary) → navigation and
global states → local items per screen or module; inside a level, what unblocks or prunes most.
An item that needs outside knowledge (library choice, market standard, API limits) is not asked
from memory: an Opus front researches it in background (`ll-research` front brief) while the
interview proceeds with the internal items, and the question enters when the comparison arrives.

Count the queue, announce "N decisions", and keep `n/N` stable; growth is announced as
"+k questions", never renumbered.

## Batteries
At most 4 questions per call, one subject per call, ordered by impact. HIGH-impact items on money,
price or scope go alone. `header` ≤ 12 chars; the `question` field carries `Pergunta n/N — <title
in business words> (impacto ALTO|MÉDIO|BAIXO · desfazer: <cost>)` — the reserved `DEC-NNNN` id
stays in the file that records the answer, never in the header or an option —, `FACT:` with number
and source (a row of OPTIONS.html, a premortem F-0n, `file:line`), `CONTEXT:` for any acronym, and
the decision in business words ending with "?". Options 2–3 (4 only multi-select), recommended
first with `(Recommended)` and a traceable reason; each description = what becomes true · cost ·
what is lost — an option names the thing decided, never an id alone. Add "Claude decide"
when delegable. Never add "Other" — the tool provides it. Everything the owner needs is inside the
field: text in a previous turn does not reach him. Fatigue: after 3–5 HIGH decisions offer a
pause; the queue lives in `decisions/`, so a new session resumes from the next open item.

## After each answer
1. Record it at once, verbatim with time, in the DEC file whose id was reserved before the battery
   (`dec-reserve <n>`, or the next number after the highest in `decisions/` without the helper).
2. Name what the answer cites: "the CTA", "the billing screen", "the new column" become a file,
   route, migration or screen name; a reference that has no name yet is asked next, before recording.
3. Re-evaluate the queue: drop questions left without object; decide items "by rule" of an earlier
   answer (`DECIDED BY RULE — follows D-00-03`); unfold new items, including ones born decided.
4. A pending task discovered (not a decision) gets an owner and a milestone or it does not exist.

## Free text and delegation
A free answer is a first-class redesign: record verbatim, give it an ID, treat it as a
requirement — it may create items, kill items, or redirect the process (a research request, a
blind-judge request). When it asks for an unbiased opinion, run the judge brief of
`decision-room.md` on that item and re-present the same numbered question with the verdict
("Pergunta 6/16 (retomada)"). "Não entendi" or a counter-question: rephrase with better context;
the failure was the question's. "Claude decide" / "você decide" / "pergunta pro X": record
`ASM-n` (or the delegation) with default and reason; never ask that item again. An order against
the recommendation: one challenge with the cost named, then obey and record under
"Against the recommendation — do NOT re-litigate". A correction of a premise in free text
("Não, na verdade…", "Validei com o time e…") writes the dated decision in the same turn.

## Final round (mandatory — minimum contact)
When the queue has no open item, one message — not a question tool call — goes out, whatever the
delegation was. It opens with three lines:
```
decisions: <N total>
questions asked N / assumptions M / owner decisions open K
owner decisions open: <ids and one line each, or "none">
```
(printed to the owner in Portuguese as `perguntas N / assunções M · decisões só suas em aberto K`)
then lists every decision as it will be written in PLAN §3: `ID · decision · by (owner / Claude ASM
/ inherited from …) · [against recommendation] · [accepted risk]`, then the assumptions, then the
accepted risks. A run whose items are all band 2/3 sends the same message with `N = 0` and the full
ASM list — the owner sees what was assumed on his behalf before it is frozen.
The owner replies "ok"/"A" or names what to change; a badly posed item is re-asked here in the
canonical format.
A correction is applied and the list is shown once more. "ok" or "A" freezes; ten minutes of silence
in the hot window ratifies the recommended list (A, the assumptions) and freezes PLAN.md too, but
only when `owner decisions open` is 0 — with one owner-only item open nothing freezes.
Under `--no-talk` the same message is printed as a report and no reply is waited for: `N = 0`, the
full ASM list, the WAITING ids under `owner decisions open`, and PLAN.md is frozen right after it even with
K > 0 — the WAITING DECs hold the dependent phases, not the freeze.
Nothing is written before this round closes.

## Recording
Every decision: `decisions/DEC-NNNN-<slug>.md` in the schema of `plan-skeleton.md`, plus a row in
PLAN §3. `decisions/README.md` carries the four counts (by owner / by rule / delegated /
assumptions), the against-recommendation list, the free answers verbatim with the ID each created,
and the consciously accepted risks. The same header carries the counter
`questions asked N / assumptions M / owner decisions open K`; with `N = 0` and `M > 5` the session also appends to `PROGRESS.md`, under the
phase heading, `- review assumptions: <M> ASM written with 0 questions asked (<date>)`. A decision
attributed to the owner that he did not make voids the artefact: it is rewritten, not patched.

# Techniques for generating options

Loaded only when the owner asks for ideas ("me dá ideias", "give me options", "que alternativas
tem"). Each technique is a short recipe: run it silently, keep the 2–3 outputs that change a map
item or create a B question, and show only those. Techniques never replace the map; they feed it.
Left out on purpose: SCAMPER, Six Hats, Disney rooms and the theatrical catalogues — too much
ceremony for a phase that already has a scope.

## Finding the invented rule

**Assumption reversal** — when an A item feels like caution rather than a requirement.
List every assumption baked into the phase, flip each to its opposite, rebuild the design on the
inverted set. Any assumption whose flip costs nothing was a rule you invented: mark it
`[revisable — my constraint, not yours]`. This is the technique that would have caught the PII mask.

**Constraint mapping** — when the phase looks over-constrained.
Write every constraint; sort each into "business" (band 1, the owner's) or "self-imposed"
(band 3, yours). Attack each self-imposed one: dissolve it, route around it, or turn it into a
feature. Business constraints go to PREMISES; self-imposed ones go to A as revisable.

## Finding the B questions

**What would have to be true** — when unsure which points need the owner.
List what has to hold for the phase to succeed; grade each statement by importance × evidence.
High importance + weak evidence = a B question; high importance + strong evidence = an A item
with the evidence as backing; low importance = C.

**Job to be done** — when the owner describes a feature, not an outcome.
Ask what he is hiring this phase to do and what he will look at on screen when it is done. The
answer is the number that decides success — the one axis he never delegates. Ask it once, in B.

**Question storming** — the default way to build the internal queue.
Generate only questions about the phase, zero answers, until the real problem comes into focus.
Then classify each question Mechanical / Taste / Blocking. The list is never shown whole.

## Generating alternatives

**Morphological analysis** — when one design is on the table and the owner wants options.
List the phase's independent parameters (storage, trigger, retry, reporting…), 2–3 options for
each, combine across them into 2–3 coherent approaches. Present each with cost and what is lost;
recommend one with a reason from the repo.

**Analog from another domain** — when the repo has no analog for an item.
Ask "this is like what?" — a queue, a ledger, a cache, a checkout. Take the solution pattern from
the domain that answers and name it in the item (`[no analog in repo — pattern: idempotent
ledger]`). The in-repo analog at `file:line` still wins whenever it exists.

**TRIZ contradiction** — when two A items pull against each other.
Name the contradiction (what only improves by making something else worse), then look for the
option that wins both before accepting a trade-off. If none exists, the trade-off is a B question.

## Pressure and cut

**"What makes this fail on day 1"** — before locking a high-impact item.
Assume the phase shipped and broke in its first hour. Name the three most likely causes with the
signal that would show each. Each cause becomes a test in the phase plan or an accepted risk.
A full premortem belongs to `ll-decide project` (step 2), as the next command.

**PMI (plus / minus / interesting)** — when one strong candidate needs a last check.
Three lines: what improves, what gets worse, what is unexpected. If a minus is band 1, the item
moves from A to B.

**One feature only / ship in 60 minutes** — for scope questions.
"You keep exactly one capability" and "you launch in one hour with what is on hand — name what
you cut, fake or borrow." The owner cuts more than recommended 4 times in 6: offer the cut as an
option, with the maximalist option next to it.

**Backcasting** — when success criteria are vague.
Describe the finished phase in observable terms (the screen, the number, the command that proves
it), then walk backward to the first move. The observable terms become the ROADMAP criteria.

**Impact–effort ranking** — to order B.
Place each Blocking item on impact × effort; ask the high-impact ones first, `n/N` numbered.
Two convergence moves chained is enough; more is over-processing.

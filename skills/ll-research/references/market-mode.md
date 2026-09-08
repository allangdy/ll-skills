# Market mode (`--market`)

The fronts stop being topic-shaped and become dossier documents. Each document exists to unlock **one decision** that would otherwise be taken by guesswork. A dossier that ends in "the market is promising" failed; one that ends in "this is fact, this is a bet, and only an N-day test settles that" succeeded. Three outcomes are all successes: proceed, proceed differently, do not proceed.

Before dispatching, confirm with the owner in one message: the mode (new product × feature of a system already in use), the candidate audience cut (segment, country, who uses × who pays), 3–8 decision questions written as closable questions, and which documents are in scope. A wrong cut contaminates the whole dossier.

## Dossier sections

Three rings, fixed order, because each ring feeds the next — with one deliberate exception: the pricing ring starts in isolation.

| # | Document | Ring | Depends on |
|---|---|---|---|
| 1 | Market and audience — sizing, who they are, what they already spend, beachhead | desirability | — |
| 2 | Pains, jobs and behavior — the pain proven outside your own head | desirability | — |
| 3 | Competitors — who solves it and **where each one stops** | desirability | — |
| 4 | Price landscape — the full spectrum actually charged, **no anchor, no recommendation** | pricing | nothing, by design |
| 5 | Pricing and conversion strategy — mechanisms labelled by evidence strength | pricing | 4 |
| 6 | Technical feasibility — the minimum technique that delivers the promise | feasibility | — |
| 7 | Data sources and inputs — tested empirically, not read from docs | feasibility | — |
| 8 | Unit economics — cost to serve one user per month | feasibility | 6, 7 |
| 9 | Legal and regulatory constraints — red/amber/green zones, questions for a lawyer | feasibility | — |
| 10 | Acquisition channels — where the audience already is, and CAC per channel | feasibility | — |
| 11 | Open decisions + empirical test plan — written by the session, never by a front | synthesis | all |

Docs 1–3 and 4, 6, 7, 9, 10 dispatch in wave 1; docs 5 and 8 in wave 2. Doc 11 becomes `## Discuss` and `## Gates` in SUMMARY.md.

**Minimum scope.** Weekend or internal tool: 2 + 3, lean. Paid product, known market: 1, 2, 3, 4, 11. Paid product, new market: + 5, 8, 10. Uncertain technical core: + 6, 7. Regulated domain or third-party data: + 9. Feature specs, architecture, roadmap and wireframes are not written in this phase.

**Feature mode** (the system already has users). Doc 1 and TAM/SAM/SOM drop out — the installed base already answered "does the audience exist". Doc 2 narrows to the job this feature does and what the base does today in its absence. Doc 3 becomes a capability gap, not a category gap. Docs 4–5 narrow to packaging — charge separately × include in the plan × use as an upgrade trigger — with **cannibalization measured** (how much revenue merely moves instead of adding). Doc 8 measures the incremental cost of the delta. The internal data of the system — usage, tickets, churn and downgrade reasons, customer requests, searches with no result — is revealed preference from people who already pay and **beats web research whenever both answer the same question**. Without access, the gap is declared, not filled with an external proxy.

## Sizing method

- **TAM / SAM / SOM computed two independent ways.** Top-down from a sector report with cuts applied; bottom-up from `reachable buyers × annual ticket`. Convergence within ~15% makes the premises defensible; a large divergence *is* the finding, and it is reported rather than averaged away.
- **Count units, not vibes.** Subscriptions ≠ subscribers, accounts ≠ users. State which one the number counts.
- **What the audience already spends** on solving the problem by any means, as a **distribution** — the mean lies.
- **Beachhead**: the narrowest sub-segment that can be dominated first, with the TAM of *that* segment, not of the whole market. Separate end user from decision-making unit — who uses ≠ who pays ≠ who approves.
- Classic errors to avoid by name: vanity TAM (the largest market that can be claimed), defining SAM/SOM as an arbitrary percentage of TAM, quoting a press projection as an audited figure. Big market numbers circulating in portals are usually sector-association projections; report them as such and triangulate bottom-up.

## Source tiers and labels

Confidence travels glued to the number, in the table row, never in a footnote — the row gets copied into a slide without its caveats.

| Mark | Meaning |
|---|---|
| `[VERIFIED]` | checked in a primary/official source on this date |
| `[UNVERIFIED]` | via snippet, aggregator or secondary source — a reliable estimate at best |
| dated | historical figure, year stated — may be stale |
| not found | searched and not found, with the reason: does not exist / blocked / proprietary / only by direct contact |
| *italics* | an inference or estimate **of this research**, not a third party's number |

Evidence strength, the vocabulary of the whole dossier — each subsection opens with it:

| Label | Criterion |
|---|---|
| STRONG | published study + replication + field experiment or large-scale data |
| MODERATE | solid original study with partial replication, or unaudited company data |
| WEAK | blogs, vendors of the solution itself, benchmarks with no auditable method |
| HYPOTHESIS | plausible reasoning, no direct evidence — becomes a test item, not a product item |
| REFUTED | famous effect that failed replication with realistic stimuli |

Rules that make the labels operational: every number carries a linked source and a date, or it does not enter. Distinguish verified data, third-party projection, estimate of this research, and structural inference. Revealed preference beats stated preference — price actually paid, abandonment, piracy, waiting lists, product longevity beat any intention survey. Ask **who benefits from this number**: sector associations inflate markets, solution vendors inflate conversion benchmarks. An unaudited vendor claim ("<n>k users", "98% satisfaction") is reported as a claim with attribution, never as a fact. Name the study, the year and the design, or the label is decoration.

## Competitor table

Four layers, and the most forgotten is the most lethal: the free generic substitute the audience already uses — the spreadsheet, a general-purpose AI assistant, doing nothing.

| Player | Layer | Value proposition | Price (source + date) | Capability A | Capability B | **Where it stops** |
|---|---|---|---|---|---|---|
| … | direct / indirect / substitute / potential entrant | … | … | yes / partial / no / claimed-only | … | the concrete boundary it does not cross |

Columns are the 4–7 capabilities that define the category, not a feature checklist. Each cell is classified as *verified in use*, *publicly documented* or *claimed on a landing page* — "adaptive", "AI" and "personalized" appear constantly without a mechanism. The output is the numbered gaps with the argument for why each is empty, and the strongest form of advantage: a gap **structurally protected**, one the incumbent cannot occupy without breaking its own business model. Close with which competitor closes which gap first, and in how long.

The trap is listing features instead of boundaries. The useful question is never "what does it have", it is "what does it structurally not do, and why".

## Pricing evidence rules

- **The price landscape (doc 4) runs with no anchor.** Its brief carries no number, range, thesis or hunch from the project — only the category and the audience. If a price thesis has already been mentioned in the session, it does not enter that brief. Its header states: *"Nature: neutral map of price × demand × delivery; this document does NOT recommend a price."* A sentence like "the ideal would be to position at X" invalidates the document.
- **Spectrum by tier**, from free to top, one section per step, table `offer | what it delivers | price | source`, plus the demand evidence per tier (revenue, number of payers, waiting lists, product longevity).
- **Willingness to pay as a distribution**, with documented hard elasticity when it exists — people who quit over price, piracy, cost-splitting, churn attributed to price.
- **International or adjacent-category analogies**, reporting the multiple between the basic and the premium tier.
- **The document lists the methods that will choose the price, it does not choose it:** Van Westendorp (four questions, does not anchor, unstable below ~200 respondents per segment); Gabor-Granger (fast, anchors by construction, needs a Van Westendorp to calibrate the ladder); conjoint (most powerful, most expensive, 200–300+ respondents); priced smoke test (the only one measuring behavior, and it measures click intent, not retention). Typical sequence: qualitative → Van Westendorp to find the range → Gabor-Granger or smoke test inside it → conjoint only if needed.
- Prices are volatile: the footer states the verification date and asks for a recheck before any decision rests on them.
- Every open pricing decision goes to `## Discuss` with the competing theses, and to `## Gates` with the **decision metric defined before running** — "net revenue per funnel visitor in 60 days", not "conversion".

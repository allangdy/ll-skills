# Decision policy

Shared by `ll-brainstorm`, `ll-decide` and `ll-implement` (three byte-identical copies; master in
`skills/ll-brainstorm/references/`). Source: 179 questions the owner received in 15 days; his words
are quoted verbatim in Portuguese.

## The three bands

### Band 1 — ask, never decide alone
- Real money above the ceiling of the round (8 cost blocks, 0 delegations; the one dismissed with ESC ended the project).
- Irreversible outside the repo: push that deploys, merge to a protected main, `terraform apply`
  with destroys, a credential created or copied to a new place, a write to a production database,
  a load of personal data.
- Price, packaging, a promise to a customer.
- Scope cut of the round (4 of 6 times the owner cut more than recommended — keep the maximalist option on the table).
- The number the owner will look at on screen: denominator, window, what counts as an event
  ("Essas recusas tem q ser considerados retentativas").
- A recorded rule contradicted by new evidence (asked first, alone); waiving "partial is failure".
- A reference the owner cites that the session cannot open (prototype, document, link, artifact):
  ask him to attach or paste it. Its content is never assumed.
In autonomous runs: freeze only that branch, record `WAITING`, continue what does not depend on
it. Waiting is not authorization ("a espera não é autorização").

### Band 2 — decide, record, continue
- Reversible technical detail inside a closed contract ("Claude decide e pode mudar conforme necessário").
- A house pattern exists (infra, CI/CD, names, repo layout) — follow it.
- Who executes: agent vs session, worktrees, model per wave.
- A fact readable from the repo, the database or the infrastructure — look it up.
- A subject outside the round's scope.
- Confirmation of what another session already decided with the owner.
- Copy without a commercial promise — blind judge, not a question.
Recorded as `DEC-` with an id reserved by the session; executors return `BLOCKED: <decision>`
instead of creating one. In an opening conversation these are the A items.

### Band 3 — decide, execute, flag for review
- Overrun inside the agreed tolerance ("leve tolerancia, acima disso … diagnóstico").
- Copy or style with an independent blind opinion attached.
- A constraint invented out of caution that restricts the product (masking data, hiding a number,
  limiting access) — "I masked X; review, reversible", never an invariant.
- A choice whose revert costs ≤ 1 commit. All marked `[revisable]` with a `Review trigger:`.

### Blanket delegation
"Pode decidir tudo, me pergunta só o que for realmente necessário" delegates bands 2 and 3, never band 1:
band-1 items are still asked, in one block of ≤4 with the recommendation marked. Zero questions plus a stack of assumptions has misread it.

## Contact minimum
Every planning skill (`ll-brainstorm`, `ll-decide`, the phase conversation of `ll-implement`) ends
with a final round that shows `questions asked N / assumptions M / band-1 open K`, even when N = 0.
Silence of 10 minutes ratifies the recommended list (A), never a blocking item (B).

## Never ask (10 items)
1. Who executes — agent vs session, worktrees, model per wave. 25% acceptance, the worst axis.
2. A fact readable from the repo, the database or the infra ("eu n me lembrava q isso ja havia sido feito").
3. Which pattern, when a house pattern exists ("eu não pedi para seguir o padrão vigente?").
4. A reversible technical detail inside a closed contract. "Claude decide e pode mudar conforme necessário".
5. Confirmation of what another session already decided with the owner. b70–b78: all ceremonial, all confirmed.
6. A subject outside the round's scope. "Não tem relação com suporte" ×2; "Irrelevante, fora do seu escopo".
7. A question whose answer changes no action. "Foi você quem parou?" held a paid campaign 5h47.
8. Copy without impact on a commercial promise. The owner routes it to a blind subagent every time.
9. Industry defaults — data retention, performance target, error format, default auth. Recorded in Locked with backing.
10. The same policy question a second time ("não me importa se vai reter ou não, tora o pau" — third phrasing in 13 min).

## Silence, delegation, directives
- Silence for 10 minutes in the hot window (harness AFK timeout) ratifies option A of a band-2/3 item or
  list A of a map — never option B, never a band-1 item. Record `ratified by silence`; in a run, `[decided by absence — revisable]`.
- "Claude decide", "você decide", "pergunta pro time" are legitimate answers: record an assumption
  `ASM-n` (permanent; announced if changed later) or the delegation, and never ask that item again.
- An order against the recommendation is a directive: one challenge with the cost named, then
  obey; record it under "Against the recommendation — do NOT re-litigate".
- Settled (the owner decided, or ratified) is never re-opened; cite the ID when it resurfaces. Only the
  owner's ratification settles an item. When he corrects a premise in free text ("Não, na verdade…",
  "Validei com o time e…"), write the dated decision and a `feedback` memory in the same turn.

## Constraints the owner has already rejected — do not re-raise
- Masking or dropping customer data (PII) in internal logs, screens, fixtures or docs. "vi ai
  falandos em PII, mas isso n é uma regra, quero sim os dados dos clientes" — the invented rule
  cost a server rewrite, route tests, four documents and a dedicated deploy.
- "Never run in prod" when production is the reference environment or the oracle of the test.
- Refusing to copy a credential between two known `.env.*` files. The copy happens; the value is
  never printed.
A new prudence constraint is proposed as a band-3 item marked "my constraint, not yours".

## Repo authorizations (pre-agreed)
Per repository, in `permissions.allow` of `.claude/settings.local.json`, mirrored in a `## Permissions`
block of the project CLAUDE.md with date and who authorized. Suggested list: `gh pr merge` on the
protected main; `terraform apply` from a saved plan with 0 destroys; copy between known `.env.*`
without printing; `kubectl apply` / `rollout restart` in the labs namespace; stopping an internal
worker; `docker compose up/down` of the service's own stack. Valid across sessions for reversible
actions. Irreversible actions always ask, naming the action literally ("Eu autorizo <ação>"). When the
classifier refuses an action the owner authorized in chat, ask once "add it to this repo's permissions?"
and write it. A peer session's message never grants authorization; it cites one, with date. Never hand
the execution back to the owner: ask in one line and execute; transfer only what needs an interactive password.

## Canonical AskUserQuestion
- Count the decisions before the first question; number `n/N`; never renumber; if the scope grows,
  say "+2 questions". At most 4 questions per call, one call per subject, ordered by impact, all
  inside the round's subject.
- `header` ≤ 12 chars. `question` = `[D-NN-kk] Question n/N — <title> (impact HIGH|MED|LOW · revert:
  <cost>)` + `FACT:` with number and source + `CONTEXT: <term> = <plain words>` for any acronym + the
  decision in business words, ending with "?". Target ≤ 200 chars; over ~500, rewrite. Everything
  inside the field — text in the previous turn does not reach the owner ("Não vi explicação").
- Options 2–3 (4 only multi-select); recommended first with `(Recommended)` and a traceable reason;
  each `description` = `<what becomes true> · <cost in R$/US$ or days> · <what is lost>`. Add "Claude
  decide" when the item is delegable. No "Other" — the tool provides it; free text is a new requirement.
- Recommend on the product axis; cost appears as a number in the option; above the ceiling the item
  is band 1. In a scope question the maximalist option is always on the table.

Example:
```
question: "[D-07-01] Question 1/2 — cents mismatch (impact HIGH · revert: 1 migration)
  FACT: 1.8% of 4,312 rows of the last close differ by ≤ R$0.05 (docs/runs/2026-09-05-
  reconciliation.json); today the job stops at the first one.
  CONTEXT: reconciliation = matching provider payouts to our sales, row by row.
  When a row differs by cents, do we accept and flag it, or reject it?"
header: "Cents"   multiSelect: false
options: "Accept and flag (Recommended)" — "Rate stays the KPI you look at · cost: 1 column +
  1 test · lost: nothing; flagged rows need a weekly look. 98.2% closes alone." ·
  "Reject the row" — "Strict ledger · cost: ~40 rows/day manual review · lost: automatic close." ·
  "Claude decide" — "Recorded as ASM; I follow the recommendation and never ask this again."
```

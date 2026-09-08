# LL Skills

Um ciclo de trabalho para [Claude Code](https://claude.com/claude-code): 11 skills, 4 agentes, 3 hooks e um helper que compartilham o mesmo estado em arquivos versionados do repositório. Um preâmbulo roteador instalado no seu `~/.claude/CLAUDE.md` classifica cada pedido antes de agir — pedido pequeno continua pequeno, pedido grande cai na skill certa sem você digitar o nome dela. O produto real é a fase: `ll-implement` roda conversa, plano, revisão adversarial, ondas de execução com TDD, verificação de contexto limpo e epílogo em **uma** invocação, e escreve tudo em disco à medida que acontece, para que uma compactação não perca nada.

## Instalação

Requer [Node.js](https://nodejs.org) 18+ (o mesmo que o Claude Code já usa).

```bash
npx ll-skills@latest
```

Reinicie o Claude Code ao final. As skills são standalone — sem o prefixo `ll-skills:` — e podem ser chamadas pelo nome (`/ll-implement 3`) ou escolhidas pelo roteador do preâmbulo.

```bash
npx ll-skills@latest --local          # instala em ./.claude, só para o projeto atual
npx ll-skills@latest --no-settings    # não escreve hooks; imprime o trecho para colar
npx ll-skills@latest --no-preamble    # não toca no ~/.claude/CLAUDE.md
npx ll-skills@latest --yes            # aprova o bloco do preâmbulo sem prompt (uso não interativo)
npx ll-skills@latest --uninstall      # remove skills, agentes, hooks, cópias do helper e o preâmbulo
npx github:allangdy/ll-skills         # direto do repositório, sem passar pelo npm
```

O que a instalação **escreve** (em `$CLAUDE_CONFIG_DIR` ou `~/.claude`):

| Caminho | Conteúdo |
|---|---|
| `skills/ll-*/` | as 11 skills, com `SKILL.md` e `references/` |
| `skills/ll-{implement,verify,close}/scripts/ll-tools.js` | cópia do helper, uma por skill que o usa |
| `agents/ll-{executor,scout,verifier,reviewer}.md` | os 4 agentes |
| `hooks/ll-{skills-check-update,state,precompact}.js` | os 3 hooks, executáveis |
| `settings.json` | duas entradas em `SessionStart` (`startup\|resume\|compact`) e uma em `PreCompact`; backup em `settings.json.ll-skills.bak` |
| `CLAUDE.md` | o bloco entre `<!-- ll-skills:preamble v1 -->` e `<!-- /ll-skills:preamble -->`, com diff e aprovação; backup em `CLAUDE.md.ll-skills.bak` |
| `ll-skills/{VERSION,manifest.json,install.json}` | versão, manifesto sha256 (base da poda e do `--uninstall`) e origem da instalação |

O que a instalação apenas **imprime**, e nunca escreve: a política sugerida de `settings.json` (`assets/settings.suggested.json` — deny list, `autoCompactWindow`, cache, modelos por papel) e o diagnóstico de sobras de instalações antigas. Reinstalar é idempotente; a primeira instalação 2.x poda as skills 1.x pelo manifesto.

## Como funciona

O preâmbulo classifica todo pedido por três critérios — lacuna de intenção, irreversibilidade e pegada — e anuncia o regime em uma linha antes de agir.

| Regime | Gatilho | O que acontece | Skill |
|---|---|---|---|
| SMALL | verbo + alvo endereçável, ≤25 palavras, ~3 chamadas | lê o alvo, faz, verifica com um número | nenhuma |
| FIX | "não era isso", "quebrou", "não sobe" | após 2 tentativas iguais, para, junta evidência, diagnostica | nenhuma |
| RESEARCH | "pesquise", "compare", "docs oficiais", restrição não validada | frentes paralelas + contra-evidência + checagem de citação | `ll-research` |
| OPS | deploy, apply, cutover, credencial, IP, "avise a infra" | pré-flight de capacidades e verdade por outro caminho | `ll-oncall` |
| LARGE | ideia nova, "plano", horas de máquina, cria um lugar | plano de ataque em 5 linhas, depois o contrato | `ll-decide` |
| EXECUTE | "implementa", "continua", marco com `passes: false` | a fase inteira em uma invocação | `ll-implement` |
| RESUME | 1º turno num repo com PROGRESS.md, "onde paramos" | briefing de ≤20 linhas, nada escrito | `ll-resume` |
| REFINE | produto rodando + "melhorar", "fiel ao protótipo" | uma rodada fechada de refino | `ll-refine` |

Uma palavra sua vence o classificador (`direto`, `pesquise`, `plano`, `implementa`, `fecha`, `status`). E a regra que amarra o conjunto: **uma skill nunca chama outra**. Cada uma termina num arquivo dentro do repositório e imprime `▶ Next — /clear, depois <comando>`; quem cola é você.

## Ciclo de um projeto

Uma vez por milestone, com a contagem de prompts seus por etapa:

| Etapa | Prompts | Sai disso |
|---|---|---|
| ideia → roteador | 1 | plano de ataque em 5 linhas (LARGE) |
| `ll-brainstorm` | 0–1 | mapa A/B/C + bateria de ≤4 → `DECISIONS.md` / `OPENING.md` |
| `ll-research` | 0–1 | `docs/research-<tema>/` com SUMMARY, evidências e fontes |
| `ll-decide` | 1 + cliques | `PLAN.md`, `ROADMAP.md`, `decisions/`, `PROGRESS.md` vazio |
| `ll-goal` | 2 (emite, você cola) | `docs/GOAL.md` + o texto para `/goal` |
| `ll-implement` × n | 0–1 cada | a fase entregue e verificada |
| `ll-verify` | 0 (citada no goal) | `VERIFICATION.md` com veredito e dois selos |
| `ll-close` | 0–1 + 1 ratificação | `docs/DELIVERY.md`, retrospectiva, arquivo do milestone |

## Ciclo de uma fase

`ll-implement N`, oito passos, com um executor por marco além do scout, do verificador e — quando há UI — do revisor:

0. **State** — lê ROADMAP, PLAN, o bloco `ll-state` do PROGRESS e o git log; marcos com `passes: false` entram em modo retomada.
1. **Conversation** — uma tela de mapa A/B/C, pulada com `--no-talk` ou se `phases/NN/DECISIONS.md` já existe.
2. **Scouting** — `ll-scout` escreve `phases/NN/CODE-CONTEXT.md`: análogo por arquivo com `file:line`, censo de leitores, armadilhas.
3. **Phase plan** — a própria sessão escreve `phases/NN/PLAN.md` (tracer primeiro, ≤3 tasks e ≤5 arquivos por marco), roda `plan-lint` e imprime as ondas.
4. **Review** — `ll-verifier` faz **uma** passada adversarial com 8 perguntas fixas; bloqueios corrigem o plano, não viram loop.
5. **Waves** — por onda: heartbeat, `dec-reserve`, um `ll-executor` por marco, retornos apensados ao PROGRESS, aceite + build + suíte rodados pela sessão, `spot-check` e `tdd-gate`, e só então `passes true`.
6. **Verification** — `ll-verifier` em contexto limpo contra os critérios da fase no ROADMAP; UI ou produto rodando chamam `ll-reviewer`.
7. **Epilogue** — passou / faltou / WAITING / novo backlog no PROGRESS, e o próximo comando pronto para colar.

Entre fases, `/clear`: sessão nova custa menos e erra menos que compactação.

## Skills

| Skill | Quando | Entrega |
|---|---|---|
| `ll-brainstorm` | "tenho uma ideia", "vamos discutir", antes de abrir uma fase | `phases/NN/DECISIONS.md` ou `docs/decide/OPENING.md` |
| `ll-research` | "pesquise", "compare A e B", restrição não validada; `--market` para mercado e preço | `docs/research-<tema>/` (SUMMARY + evidências + fontes datadas) |
| `ll-decide` | "escreve o plano", segunda tentativa, ou feedback externo em docx/pdf/xlsx | `PLAN.md` §0–§11, `ROADMAP.md`, `decisions/`, ou `docs/review-<data>.md` |
| `ll-goal` | antes de uma noite sem ninguém olhando | `docs/GOAL.md` + o texto de 9 partes para `/goal` |
| `ll-implement` | "implementa a fase N", "continua" | a fase entregue, `phases/NN/PLAN.md`, PROGRESS carimbado |
| `ll-verify` | "confere se terminou de verdade", contrato público, dinheiro, dado de cliente | `VERIFICATION.md` com ledger FRESH/STALE e dois selos |
| `ll-close` | "fecha", "pode arquivar"; `--milestone` arquiva as fases | `docs/DELIVERY.md`, retrospectiva, ROADMAP colapsado |
| `ll-resume` | primeiro turno no repo, "onde paramos", "o que tenho pra decidir" | briefing de ≤20 linhas na conversa, nada em disco |
| `ll-refine` | produto rodando: "melhorar as telas", "fiel ao protótipo" | uma rodada registrada no PROGRESS; modo `visual` até o veredito FIEL |
| `ll-oncall` | `claude -n <papel>`, "vigie a cada 1h", deploy/apply/cutover | bloco `## Federation`, `docs/REQUESTS.md`, pré-flight do deploy |
| `ll-update` | "atualiza o ll-skills", ou o aviso da sessão | o pacote atualizado, com o changelog mostrado antes |

## Agentes

| Agente | Modelo | Papel | Fronteira |
|---|---|---|---|
| `ll-executor` | opus (sonnet no mecânico) | um marco: implementa, comita por task, devolve bloco fixo | não escreve estado, não dá push, não despacha agente |
| `ll-scout` | sonnet | análogos do código antes do plano | só escreve `phases/NN/CODE-CONTEXT.md`; não lê o PLAN do projeto |
| `ll-verifier` | opus, `memory: project` | revisa plano, verifica fase e entrega, do objetivo para trás | nunca conserta nada |
| `ll-reviewer` | opus + Playwright | exercita o produto rodando; DOM e screenshot por rota × viewport | não edita código; imagem não vista = check não feito |

Nenhum agente despacha subagente (profundidade 1) e nenhum pergunta ao dono: uma decisão de faixa 1 volta como `BLOCKED:` no bloco de retorno.

## Hooks e helper

- `ll-skills-check-update.js` (SessionStart) — compara a versão instalada com a publicada e avisa uma linha quando há versão nova.
- `ll-state.js` (SessionStart, também em `compact`) — injeta o epílogo, as últimas linhas do PROGRESS, o `git status`, as worktrees, as decisões WAITING e o placar de marcos; silencioso fora de um projeto.
- `ll-precompact.js` (PreCompact) — carimba no PROGRESS a ordem de reler o plano da fase e o placar antes de continuar.

`scripts/ll-tools.js` é Node puro, sem dependências, copiado dentro de `ll-implement`, `ll-verify` e `ll-close`. Comandos de leitura sempre saem com código 0; comandos de escrita saem 1 em erro.

| Comando | O que faz |
|---|---|
| `state` | fase, placar de marcos, git, WAITING, epílogo presente — é o `Current state:` das skills |
| `waves` | calcula as ondas a partir de `depends_on`/`files`/`exclusive` e reporta defeitos e bloqueios |
| `plan-lint` | audita `phases/NN/PLAN.md` contra ~18 regras antes de congelar o plano |
| `tdd-gate` | confere no git log que o commit `test(Mn)` veio antes do `feat(Mn)` |
| `spot-check` | confere que os arquivos do marco estão no HEAD e que há commit ancorado |
| `dec-reserve` | reserva IDs `DEC-NNNN` e cria os stubs, sem colisão entre sessões |
| `passes` | marca um marco verde ou vermelho no bloco `ll-state`, reescrevendo uma linha só |
| `heartbeat` | registra uma linha datada no PROGRESS antes do epílogo |
| `ledger` | por critério da VERIFICATION: `file:line`, hash e frescor FRESH/STALE/UNKNOWN |
| `backlog-reconcile` | roda a condição executável de cada item do BACKLOG e fecha o que já passou |
| `epilogue` | monta os dados do fim de fase e diz o próximo comando |
| `phase-stats` | dias com trabalho, dias ociosos, commits por tipo, razão teste/feature |

## Arquivos de estado no repositório

```
PLAN.md                      contrato do projeto (§0–§11): verdades, decisões, orçamento, modelos
ROADMAP.md                   fases com critérios de sucesso; só existe acima de 3 fases
PROGRESS.md                  bloco ll-state (placar de marcos) + histórico + ## Epilogue
BACKLOG.md                   itens adiados, cada um com a condição executável que o fecha
VERIFICATION.md              veredito, dois selos e o ledger por critério
decisions/DEC-NNNN-*.md      uma decisão por arquivo; WAITING no nome espera você
phases/NN/DECISIONS.md       o que foi decidido ao abrir a fase, e por quem
phases/NN/CODE-CONTEXT.md    análogos do repo, censo de leitores e armadilhas (só o scout escreve)
phases/NN/PLAN.md            marcos da fase: files, depends_on, acceptance, tdd, stop, model
docs/GOAL.md                 o texto colado em /goal, versionado
docs/DELIVERY.md             o que foi entregue, para quem lê e não acompanhou
```

Só a sessão escreve arquivos de estado; executores devolvem blocos e a sessão os apensa.

## Decisões

- **Faixa 1 — pergunta, nunca decide sozinho:** dinheiro acima do teto da rodada, irreversível fora do repo (push que faz deploy, apply com destroy, credencial, prod, dado de cliente), preço e promessa a cliente, corte de escopo, o número que você vai olhar.
- **Faixa 2 — decide, registra `DEC-`, continua:** detalhe técnico reversível, padrão da casa, quem executa, fato legível do repo, o que está fora do escopo da rodada.
- **Faixa 3 — decide, executa, sinaliza:** estouro dentro da tolerância, copy com opinião anexada, prudência inventada, custo de reverter ≤ 1 commit.

Perguntas vêm em blocos de ≤4 por onda, ordenadas por impacto. Dez minutos de silêncio ratificam a lista recomendada, nunca um item bloqueante. A política completa — incluindo os 10 itens que nunca são perguntados — está em `skills/ll-brainstorm/references/decision-policy.md`, compartilhada com `ll-decide` e `ll-implement`.

## Atualização

`/ll-update` compara instalado × publicado, mostra as seções do `CHANGELOG.md` entre as duas versões, pergunta uma vez e roda `npx --yes ll-skills@latest` — toda mutação passa pelo instalador. O hook avisa na sessão quando há versão nova.

## Desenvolvimento

- `npm test` roda `scripts/smoke-test.sh`: instala num `CLAUDE_CONFIG_DIR` isolado e verifica os 12 comandos do helper, os hooks (silenciosos fora de projeto, falantes no fixture), o preâmbulo (idempotente, restaurado, removido no `--uninstall`), a poda das skills antigas, a preservação de hooks alheios e a segunda instalação sem diff.
- Fixtures em `scripts/fixtures/`: um repo com PLAN/PROGRESS/ROADMAP/BACKLOG/VERIFICATION e histórico git gerado por `git-history.sh`, mais um diretório vazio para os casos "fora de projeto".
- Nova skill: crie `skills/ll-<nome>/SKILL.md` com `name` e `description` em inglês; material de profundidade em `references/`. O instalador descobre skills por `skills/ll-*` e agentes por `agents/ll-*.md`, sem lista para manter.
- Release: renomeie a seção do `CHANGELOG.md`, `npm version patch|minor|major`, `git push --follow-tags`. A tag `vX.Y.Z` dispara `publish.yml`, que confere tag × `package.json` × changelog, roda o smoke test e publica no npm via Trusted Publishing (OIDC, com proveniência, sem token guardado).

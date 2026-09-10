# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). A skill `ll-update` lê este arquivo para mostrar o que mudou entre a versão instalada e a publicada.

## [3.0.0] - Unreleased

### Adicionado

- **`ll-auto`**: skill que roda o ciclo inteiro a partir do estado em disco — research, brainstorm, decide, fases, verificações, close — seguindo o `SKILL.md` de cada etapa em vigor, com as flags `"<objetivo>"`, `--research`, `--brainstorm`, `--interactive`, `--auto-decision`, `--pause-at <stage|N>`, `--from N`, `--to N`, `--only N`, `--verify all`, `--redo <stage>`, `--dry-run` e `--resume`; escreve `docs/AUTO.md` (objetivo, flags, roteiro, status por etapa) e lista no final toda decisão tomada sozinha, marcada `[decided by absence — revisable]`.
- Helper `skills/ll-auto/scripts/ll-auto.js` (Node puro, sem dependências, próprio da skill): `detect`, `roteiro`, `next-cmd`, `report`, `auto-md`.
- `--no-talk` em `ll-decide` e `ll-close`: nenhum bloco de pergunta é enviado; itens de faixa 2/3 tomam a recomendação como `ASM-n [decided by absence — revisable]`, itens de faixa 1 viram decisão `WAITING`.

### Quebras

- As skills não são mais invocadas pelo modelo — todas com `disable-model-invocation: true`.
- Preâmbulo sem roteador de pedidos.
- Descrições das skills reescritas em uma linha.

### Alterado

- Lint rule 1 e 3 do `lint-prompts.sh`.
- Casos de eval `router-*` e `preamble-no-ritual` passam a exigir o comando nomeado e nenhuma chamada da ferramenta Skill; helper `no_tool_use` em `scripts/evals/lib/assert.sh`.

## [2.0.2] - 2026-09-08

### Alterado

- Textos de referência das skills revisados; exemplos com placeholders.
- Smoke test: verificação opcional de termos por lista externa (`LL_FORBIDDEN_FILE`).

## [2.0.1] - 2026-09-08

### Alterado

- Documentação e textos de referência revisados: exemplos genéricos e vocabulário uniforme; sem mudança de comportamento das skills.
- Instalador: diagnóstico de limpeza restrito ao cache do plugin legado.

## [2.0.0] - 2026-09-07

### Resumo

- O pacote deixa de ser uma coleção de 8 skills soltas e vira um ciclo de trabalho: 11 skills, 4 agentes, 3 hooks e um helper que compartilham o mesmo estado em arquivos versionados do repositório.
- Um preâmbulo roteador escrito no `~/.claude/CLAUDE.md` classifica todo pedido em 8 regimes antes de agir — pedido pequeno continua pequeno, pedido grande cai na skill certa sem você digitar o nome.
- A execução ganha skill própria (`ll-implement`): uma fase inteira — conversa, scouting, plano, revisão adversarial, ondas TDD com um executor por marco, verificação de contexto limpo e epílogo — em uma invocação.
- Tudo o que o modelo lê passa a ser inglês (nomes de skills, agentes, arquivos, campos YAML, prompts); a conversa com você continua em português.

### Quebras

- **Idioma.** Nomes de skills, agentes, artefatos, campos de estado e todo o texto que o modelo lê estão em inglês. Só as respostas ao dono, o README e este changelog ficam em português.
- **Skills renomeadas, fundidas e removidas.** A primeira instalação 2.x apaga as 8 pastas antigas:

  | Antes (1.x) | Agora (2.0.0) |
  |---|---|
  | `ll-pesquisar` | `ll-research` |
  | `ll-pesquisar-mercado` | `ll-research --market` |
  | `ll-decidir-antes` | `ll-decide` (modo `project`) |
  | `ll-voltar-do-futuro` | `ll-decide` — passo do premortem |
  | `ll-desarmar` | `ll-decide` — passo de desarme (`--measure`) |
  | `ll-verificar-entrega` | `ll-verify` |
  | `ll-atualizar` | `ll-update` |
  | `ll-orquestrar` | seção `## Delegation` do preâmbulo + `references/briefs.md` do `ll-implement` |

- **`agents/ll-implementador.md` removido.** Em seu lugar entram 4 agentes de papel único: `ll-executor`, `ll-scout`, `ll-verifier`, `ll-reviewer`.
- **`SPEC.md` sai do contrato.** O contrato passa a ser `PLAN.md` + `ROADMAP.md` + `PROGRESS.md` + `phases/NN/`. Repositórios com `SPEC.md` continuam legíveis: `ll-resume` reconhece os nomes antigos por alias só-leitura.
- **O instalador escreve no `~/.claude/CLAUDE.md`.** Um bloco delimitado por `<!-- ll-skills:preamble v1 -->` … `<!-- /ll-skills:preamble -->` é gravado com diff e aprovação (backup em `CLAUDE.md.ll-skills.bak`); fora de TTY nada é escrito sem `--yes`. `--uninstall` remove o bloco e deixa o resto do arquivo byte a byte igual.
- **O instalador registra 3 hooks** em vez de 1: `SessionStart` passa a ter `matcher: "startup|resume|compact"` com dois hooks, e `PreCompact` ganha um. A entrada legada `startup|resume` é limpa na atualização.
- **Novas flags do instalador:** `--no-settings` (imprime o trecho dos hooks em vez de escrever), `--no-preamble` (não toca no `CLAUDE.md`), `--yes`/`-y` (aprova o preâmbulo sem prompt, para uso não interativo).

### Novo

- **Preâmbulo roteador** (`assets/preamble.md`, ≤70 linhas) com 8 regimes — SMALL, FIX, RESEARCH, OPS, LARGE, EXECUTE, RESUME, REFINE —, a política de delegação (profundidade 1, brief de 12 campos, modelo por papel), as 3 faixas de decisão e a regra de prova ("timeout não é verde").
- **11 skills**, uma linha cada:

  | Skill | O que faz |
  |---|---|
  | `ll-brainstorm` | Abre fase, projeto ou ideia solta decidindo na frente do dono: mapa A/B/C ≤35 linhas, uma bateria de ≤4 perguntas, sai em `phases/NN/DECISIONS.md` ou `docs/decide/OPENING.md` |
  | `ll-research` | Pesquisa com frentes de contexto limpo e busca web → `docs/research-<tema>/` com SUMMARY (Apply/Discuss/Gates), trilha de evidências e fontes datadas; `--market` para mercado, concorrência e preço |
  | `ll-decide` | Vira um pedido em contrato: gate de premissas, premortem, desarme, sala de decisão, entrevista em baterias → `PLAN.md` §0–§11, `ROADMAP.md`, `decisions/`; modo `feedback` ingere docx/pdf/xlsx |
  | `ll-goal` | Escreve o texto de `/goal` em 9 partes (≤4.000 chars) e salva `docs/GOAL.md`; você cola em sessão nova |
  | `ll-implement` | Roda uma fase inteira numa invocação: conversa, scouting, plano, revisão, ondas TDD, verificação e epílogo |
  | `ll-verify` | Audita em contexto limpo com 3 camadas e ledger FRESH/STALE por critério → `VERIFICATION.md` com dois selos |
  | `ll-close` | Fecha entrega ou milestone: backlog reconciliado, `docs/DELIVERY.md`, retrospectiva, lições para a memória, uma ratificação em bloco |
  | `ll-resume` | Reconstrói o estado em ordem fixa de leitura e responde em ≤20 linhas, sem escrever nada |
  | `ll-refine` | Uma rodada de refino num produto que já roda; modo `visual` faz o loop referência → gate → validador até o veredito FIEL |
  | `ll-oncall` | Sessão que segura um papel: contrato `## Federation`, log numerado de pedidos; modos `watch` (vigília) e `ops` (deploy com pré-flight) |
  | `ll-update` | Atualiza o pacote mostrando o changelog entre instalado e publicado antes de aplicar |

- **4 agentes:** `ll-executor` (opus, um marco, allowlist de arquivos, commits atômicos, bloco de retorno fixo), `ll-scout` (sonnet, só `phases/NN/CODE-CONTEXT.md`), `ll-verifier` (opus, `memory: project`, nunca conserta), `ll-reviewer` (opus + Playwright, "imagem não vista = check não feito"). Nenhum deles despacha subagente.
- **3 hooks:** `ll-skills-check-update.js` (aviso de versão nova), `ll-state.js` (SessionStart: injeta epílogo, últimas linhas do PROGRESS, git status, worktrees, decisões WAITING e o placar de marcos), `ll-precompact.js` (PreCompact: carimba no PROGRESS a ordem de reler o plano depois da compactação).
- **Helper `scripts/ll-tools.js`** (Node puro, sem dependências), copiado dentro de `ll-implement`, `ll-verify` e `ll-close` na instalação, com 12 comandos: `state`, `waves`, `plan-lint`, `tdd-gate`, `spot-check`, `dec-reserve`, `passes`, `heartbeat`, `ledger`, `backlog-reconcile`, `epilogue`, `phase-stats`.
- **Estado em arquivos do repositório:** `PLAN.md` (contrato), `ROADMAP.md` (fases e critérios), `PROGRESS.md` (bloco `ll-state` + epílogo), `BACKLOG.md` (itens com condição executável), `VERIFICATION.md` (ledger e veredito), `decisions/` (`DEC-NNNN`, numeração reservada pelo helper), `phases/NN/` (`DECISIONS.md`, `CODE-CONTEXT.md`, `PLAN.md`).
- **`assets/settings.suggested.json`**: política sugerida (deny list, `autoCompactWindow`, cache, modelos) que o instalador **imprime** e nunca escreve.
- `publish.yml`: a confirmação no registro espera a propagação por até 60 s em vez de consultar no mesmo segundo do publish.


### Migração

- A primeira instalação 2.x poda as 8 skills antigas e `agents/ll-implementador.md` pelo manifesto sha256, mesmo sem manifesto anterior. Nada alheio a `skills/ll-*`, `agents/ll-*` e `hooks/ll-*` é tocado.
- Projetos em andamento continuam funcionando: nada é renomeado no meio de uma fase, e `ll-resume` lê `PLANO.md`, `SPEC.md`, `PROGRESS.md` e `VERIFICACAO.md` pelos nomes antigos.
- Limpeza da máquina (cache de plugin antigo) é **diagnosticada e impressa** pelo instalador, nunca executada.

## [1.0.1] - 2026-09-07

### Adicionado

- Publicação no npm pela CI via Trusted Publishing (`.github/workflows/publish.yml`): tag `vX.Y.Z` confere tag × package.json × CHANGELOG, roda o smoke test e publica com proveniência.
- `npm test` roda `scripts/smoke-test.sh`, que instala num `CLAUDE_CONFIG_DIR` isolado e verifica poda, preservação de hooks alheios, idempotência, hook de aviso e `--uninstall`.

### Alterado

- README: rotina de release com `npm version` + `git push --follow-tags`.

## [1.0.0] - 2026-09-06

### Alterado

- Distribuição passa de plugin/marketplace para pacote npm: `npx ll-skills@latest` instala skills standalone em `~/.claude/skills/`, sem o prefixo `ll-skills:`.
- Skills renomeadas para `ll-<nome>` (`ll-pesquisar-mercado`, `ll-voltar-do-futuro`, `ll-desarmar`, `ll-decidir-antes`, `ll-verificar-entrega`, `ll-pesquisar`, `ll-orquestrar`, `ll-atualizar`); agente renomeado para `ll-implementador`.
- Instalador limpa a instalação anterior: desinstala o plugin legado `ll-skills@ll-skills`, poda arquivos órfãos de instalações standalone anteriores e apaga o cache antigo.
- Hook de aviso de atualização reescrito em Node; compara a versão instalada com a publicada no npm.
- `ll-atualizar` passa a rodar `npx --yes ll-skills@latest` e mostra o changelog a partir deste arquivo.

### Removido

- Manifesto de plugin (`.claude-plugin/`) e `hooks/hooks.json`.

# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). A skill `ll-update` lê este arquivo para mostrar o que mudou entre a versão instalada e a publicada.

## [3.1.0] - 2026-09-11

### Adicionado

- Passo `board-switch` no helper: troca o marcador de fase antes da primeira onda gravar, e `passes` recusa gravar quando o marcador é de outra fase — a onda 1 não escreve mais no lugar da fase anterior (F-1).
- Coluna `note` e condição executável (`` `cmd` exit N ``) nas linhas de backlog nascidas em `ll-implement`; o epílogo lista quem ainda não é parseável e a fase roda `backlog-reconcile` a seco antes de fechar, reescrevendo a linha na hora (F-2).
- Linha de progresso por onda no terminal durante uma fase (`onda i/M — M2, M3 rodando`), no despacho e no retorno de cada marco (F-4).
- Lint rule 9 (`lint-prompts.sh`): nenhuma pergunta ao dono ou linha de contagem carrega `band-1`, `[DEC-`, `[D-` ou `ASM-`; novo caso de eval `router-large-opener`; os asserts de `decide-final-round` e `implement-stops-at-next` seguem a nova redação.
- Teto de tamanho do helper em 760 linhas / 36 000 bytes (`DEC-0016-helper-ceiling-760-36000.md`).
- `phase-stats --since <data>` passa a incluir o próprio dia informado (F-12).
- `ll-resume` grava a resposta a uma decisão `WAITING` no próprio arquivo da decisão.
- Linhas de memória fora do repositório (`ll-brainstorm`, `ll-close`) declaradas na tabela de entregáveis (F-10).
- Segunda rodada completa do laboratório: `lab/scenarios/notes-api.md` ganha os turnos 8–24 (fechamento por milestone, pesquisa, decisão sem perguntas com roadmap de quatro fases e uma decisão `WAITING`, meta autônoma, verificação externa, sabotagem seguida de reverificação, oncall, feedback em docx, refino, `ll-auto --pause-at/--resume`), `lab/README.md` ganha o protocolo de sessão isolada (`CLAUDE_CONFIG_DIR` próprio, diálogo de confiança pré-aceito, sondagem a cada 5 minutos) e `lab/rubric.md` ganha as métricas de progresso visível, integridade do board e caminhos percorridos.

### Corrigido

- Skill só por comando explícito: o preâmbulo global não redireciona mais nenhum pedido para uma skill, em nenhum repositório, tenha ele estado do ll-skills ou não — a sessão responde ou faz o que foi pedido, e só nomeia um comando quando o dono pergunta qual usar (feedback do dono, 2026-09-11).
- O gate de premissas do `ll-decide` manda no máximo quatro perguntas num bloco só, com cabeçalhos limpos (sem `[PG-n]`, sem `banda 1` na tela); a restrição inventada por cautela deixou de ser pergunta — vira assunção `ASM-n [revisable]` com gatilho de revisão, contada como assunção.
- Pergunta cujas opções só diferem em rigor de checagem não é mais feita — vira decisão por ausência (F-8).
- A sala de decisão (`OPTIONS.html`) é entregue por caminho de arquivo antes da primeira pergunta, sem publicar artefato e sem chamar outra skill (F-5, `DEC-0017-decision-room-file-not-published.md`).
- As telas e as perguntas ao dono não usam mais `banda 1`, `DEC-`, `ASM-`; a linha de contagem virou `perguntas N · decisões só suas em aberto K` (F-3, `DEC-0018-plain-question-headers.md`).
- As skills chamam o helper pelo comando, nunca leem o código dele na tela do dono (F-7).
- Script de aceitação comitado com caminho absoluto ou que mata processo alheio (`pkill`, `killall`) vira bloqueio do verificador em vez de uma ressalva (F-6).
- O primeiro turno de um pedido grande para no comando e num plano de até 5 linhas, sem escolher formato de id nem biblioteca de IO antes da hora (F-9).
- O laboratório aceita o diálogo de confiança da pasta antes do primeiro turno, num `CLAUDE_CONFIG_DIR` isolado — a primeira tentativa da rodada de 2026-09-11 tinha morrido nesse diálogo (F-11, `DEC-0019-lab-round-2-scope.md`).

### Alterado

- `lab/rubric.md`: a lista de jargão troca `gate` por `regime` (a classe de roteamento já tem nome próprio no `CLAUDE.md`; nada em `lab/` deveria repeti-la na tela do dono).

## [3.0.0] - 2026-09-10

### Adicionado

- **`ll-auto`**: skill que roda o ciclo inteiro a partir do estado em disco — research, brainstorm, decide, fases, verificações, close — seguindo o `SKILL.md` de cada etapa em vigor, com as flags `"<objetivo>"`, `--research`, `--brainstorm`, `--interactive`, `--auto-decision`, `--pause-at <stage|N>`, `--from N`, `--to N`, `--only N`, `--verify all`, `--redo <stage>`, `--dry-run` e `--resume`; escreve `docs/AUTO.md` (objetivo, flags, roteiro, status por etapa) e lista no final toda decisão tomada sozinha, marcada `[decided by absence — revisable]`.
- Helper `skills/ll-auto/scripts/ll-auto.js` (Node puro, sem dependências, próprio da skill): `detect`, `roteiro`, `next-cmd`, `report`, `auto-md`.
- `--no-talk` em `ll-decide` e `ll-close`: nenhum bloco de pergunta é enviado; itens de faixa 2/3 tomam a recomendação como `ASM-n [decided by absence — revisable]`, itens de faixa 1 viram decisão `WAITING`.
- **`ll-goal --autonomous`**: modo que aponta o texto do `/goal` para `ll-auto --auto-decision` até a entrega inteira fechar, em vez de uma fase; sem a parte BUDGET, frontmatter com `mode: autonomous` em vez de `ceiling_usd`.
- Casos de eval `auto-dry-run` e `auto-empty-repo` (`scripts/evals/cases/`), a seção offline `evals-auto` do `scripts/smoke-test.sh` e uma repetição real de ambos via `scripts/evals/run.sh`.

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

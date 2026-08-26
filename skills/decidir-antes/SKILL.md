---
name: decidir-antes
description: Prepara uma implementação longa (horas ou dias de agente autônomo) decidindo tudo o que importa antes do código — levanta evidência com subagentes, entrevista o usuário via AskUserQuestion sobre as decisões irreversíveis em ordem de impacto, e consolida SPEC.md + PROGRESS.md com protocolo anti-drift embutido, prontos para handoff. Use quando o pedido for criar uma spec antes de implementar, fazer perguntas antes de começar, preparar uma tarefa longa para um agente, conduzir uma entrevista de decisões ou montar um handoff para implementação autônoma.
---

# decidir-antes

Dado "quero implementar X", esta skill conduz: (1) levantamento de evidência, (2) construção da fila de decisões, (3) entrevista via AskUserQuestion, (4) escrita de `SPEC.md` + `PROGRESS.md`, (5) handoff. Ela NÃO implementa nada — o entregável é a spec que sustenta um implementador autônomo por horas ou dias sem drift, e a instrução de partida que o dispara.

Artefatos, por padrão em `docs/spec-<slug>/`:

| Arquivo | Papel | Mutabilidade |
|---|---|---|
| `mapas/*.md` | evidência condensada dos subagentes | escritos uma vez |
| `FILA.md` | inventário de decisões + fila da entrevista | vivo durante a entrevista |
| `SPEC.md` | contrato de implementação, ordenado por precedência | append-only após aprovação |
| `PROGRESS.md` | estado do implementador | mutável, do implementador |
| `decisoes/` | ambiguidades da execução aguardando o humano | criadas pelo implementador |

Na primeira interação, confirme com o usuário em uma única troca: o corte de escopo do trabalho (o que está dentro e fora) e o local dos artefatos. Depois disso, os pontos de contato com o humano são as perguntas da entrevista e o handoff — nada entre eles.

## Fase 1 — Evidência

Nenhuma pergunta sem lastro. Antes de formular qualquer decisão:

- **Os artefatos das etapas anteriores vêm primeiro**, antes de mapear qualquer coisa nova. Procure no repo e leia direto, sem subagente — já são evidência condensada e citável: `docs/README.md` (o índice do dossiê, com o **Estado da decisão** no topo) e `docs/decisoes-em-aberto.md` da pesquisa de mercado; `docs/premortem/premortem.md` e `docs/premortem/placar.md`; SPECs anteriores e suas decisões `DEC-NNN`. Eles se citam pelo caminho e pela seção, como os mapas se citam por `arquivo:linha`. Nada disso existir é normal — a skill roda sozinha; o que não pode é existir e ser remapeado do zero.
- Delegue o mapeamento a subagentes — um por material (código atual, protótipo/design, documentos do pedido). A sessão principal lê apenas os mapas condensados que eles produzem, nunca os fontes inteiros: sessões que abrem tudo morrem por estouro de contexto antes de decidir qualquer coisa. Fontes abertos na sessão principal só sob demanda, no trecho exato que uma pergunta exigir.
- Cada mapa registra fatos com `arquivo:linha` — é essa citação que as perguntas vão carregar.
- O lastro tem dois tipos: **interno** (os mapas do projeto) e **externo** — decisões que dependem de conhecimento de fora do projeto (escolha de tecnologia ou biblioteca, padrão de mercado, limites e preços de API) exigem pesquisa web por subagente antes da pergunta. Recomendação de memória ou opinião não sustenta pergunta.
- Leia `referencias/protocolo-entrevista.md` agora: ele traz o brief-modelo dos mapeadores e pesquisadores, o formato dos itens da fila e o protocolo de pergunta das fases 2 e 3.

## Fase 2 — Fila de decisões

Construa `FILA.md`: um item por coisa decidível pelo usuário (não por detalhe), com evidência dos dois lados, camada/impacto, dependências e status `PENDENTE`. Divergências entre o que existe e o que foi pedido entram nas duas direções — adição e subtração são ambas decisões do dono, nunca descarte silencioso.

Antes de classificar, aplique a herança dos artefatos anteriores:

- Decisão **já tomada** neles **não vira pergunta**: entra na spec como contrato herdado, com a fonte citada (`docs/README.md` §Estado da decisão, `docs/premortem/placar.md`, `DEC-014` da spec anterior). Não re-litigar atravessa as skills, não só a entrevista — re-perguntar o que o dono já fechou queima a confiança na fila inteira. Só volta a ser pergunta se a evidência nova a contradiz, e aí a pergunta é essa: a contradição, com os dois registros lado a lado.
- Falha **CONFIRMADA** no placar do premortem entra como **restrição de desenho**, não como risco a discutir: as opções que a ignoram não são oferecidas, e a rota de saída quantificada no placar vira o custo declarado das que sobram.
- **Pendência com dono** nesses artefatos vira item da fila apenas se o dono for o usuário; dono implementador ou agente vira pendência da spec, com o marco em que fecha.

Classificação de cada item — o coração da skill:

- **Vira PERGUNTA** (one-way door) se qualquer um valer: mudar depois exige reescrever mais de um módulo; a resposta condiciona ou redesenha outras decisões da fila; é preferência do usuário que nenhuma evidência revela.
- **Vira ASSUNÇÃO** (two-way door) caso contrário: decida você, com o default mais barato de reverter, e registre com porquê. Assunções entram na spec marcadas — são o único tipo de decisão que o implementador pode escalar por evidência contrária.

Ordene a fila: primeiro a pergunta que re-precifica todas as outras (sequenciamento, big-bang vs incremental, corte de escopo); depois por impacto estrutural descendente; dentro do nível, o que desbloqueia ou poda mais itens.

Marque em cada PERGUNTA o lastro: `interno` (os mapas bastam) ou `externo` (exige pesquisa web). As externas disparam subagentes de pesquisa em background já nesta fase — a entrevista segue com as internas e nunca bloqueia esperando pesquisa; cada pergunta externa entra na fila quando o comparativo dela chegar.

## Fase 3 — Entrevista

Siga o protocolo de `referencias/protocolo-entrevista.md`. O núcleo inviolável:

- AskUserQuestion, cabeçalho "PERGUNTA N/M". Impacto ALTO: uma decisão por chamada. Impacto baixo: até 4 por chamada, sempre uma decisão por pergunta.
- Toda pergunta carrega a evidência dos dois lados (com `arquivo:linha`), sua análise honesta com posição própria, e opções com custo/consequência; a recomendada vem primeiro com "(Recomendada)" no label — ela informa, o usuário decide.
- Registre a resposta em `FILA.md` imediatamente (literal, com data) e re-avalie a fila após CADA resposta: respostas desdobram itens novos, decidem outros "por regra" e podam perguntas sem objeto. Commit por bloco quando em repo git.
- Sem resposta = `PENDENTE`. Você não decide nenhuma one-way door sozinho — nem as "óbvias". Decisão contra a sua recomendação: registro fiel com as consequências, sem re-litigar.
- 3 a 5 decisões ALTO por sessão de perguntas; ao atingir o limite, ofereça pausa. A fila vive no arquivo, não na conversa: qualquer sessão retoma do próximo `PENDENTE` sem re-derivar nada.

A entrevista termina quando a fila zera os `PENDENTE` — por resposta, por regra ou por delegação explícita do usuário ("você decide" vira assunção registrada).

## Fase 4 — SPEC.md + PROGRESS.md

Leia `referencias/template-spec.md` e escreva os dois arquivos a partir dele. Regras que nascem nesta fase:

- Critério de aceite sem comando de verificação executável não entra como critério — entra como pendência com dono nomeado e marco. Requisito sem verificação é requisito que vaza.
- Decisão que cita um entregável nomeia o entregável (arquivo, rota, migração, tela); pendência tem dono e marco. Referência vaga hoje é re-pergunta garantida na semana 2 da execução.
- A spec é curta e densa: detalhe fino fica nos mapas e entra por referência de caminho. O protocolo de execução (seção 7) vai completo no SPEC.md — o implementador não conhece esta skill; a spec é tudo o que ele tem.

## Fase 5 — Handoff

Apresente ao usuário: contagem de decisões (perguntadas / assumidas / herdadas / contra a recomendação), riscos aceitos conscientemente, pendências com dono, e a instrução de partida do implementador:

<instrucao-de-partida>
Implemente <caminho>/SPEC.md até o fim.

Leia a spec inteira antes de qualquer código. Ela é autossuficiente e as decisões da seção 3 são contrato — nada é re-decidido. A seção 7 é o seu protocolo de operação e prevalece sobre instruções genéricas de sessão. Estado vive em PROGRESS.md e no git, não na conversa. Trabalhe um marco por vez até todos estarem `passes: true` com os comandos de verificação passando. Antes de delegar trabalho a subagentes, invoque a skill `orquestrar` (plugin ll-skills) pela ferramenta Skill — ela rege decomposição, briefs, roteamento de modelos e verificação. Se ela não existir no seu ambiente: delegue apenas subtarefas grandes e genuinamente independentes, com brief autossuficiente (objetivo, contrato de saída, limites), e verifique resultados com evidência. Suas liberdades estão na seção 5b; use seu melhor julgamento dentro delas. Tudo fora delas: escale conforme a seção 7. Ao final, a entrega é auditada pela skill `verificar-entrega` — o VERIFICACAO.md dela, não o seu relato, é o que fecha o trabalho.
</instrucao-de-partida>

Rota preferida: dispare o agente **`implementador`** do plugin (ele parte com a `orquestrar` pré-carregada) com a instrução acima. Qualquer sessão ou agente com a instrução também serve — a spec é autossuficiente. Você entrega a spec e para aqui; quando o implementador declarar pronto, o caminho é `verificar-entrega`.

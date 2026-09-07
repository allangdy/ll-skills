---
name: ll-verificar-entrega
description: Auditoria de contexto limpo de uma entrega concluída — verificadores que nunca viram o raciocínio da implementação rodam os comandos de aceite da SPEC um a um, conferem cada decisão contra o código com arquivo:linha e confrontam o relatado com o real, produzindo VERIFICACAO.md com veredicto APROVADA / APROVADA COM RESSALVAS / REPROVADA. Use quando alguém pedir para verificar, auditar ou revisar uma entrega ou implementação concluída, conferir se o agente realmente terminou, validar se a SPEC foi implementada, checar marcos marcados como prontos ou revisar o trabalho de um agente autônomo longo.
---

# verificar-entrega

Um implementador autônomo declarou pronto. Esta skill decide se está. Ela audita, nunca conserta: falha encontrada vira achado com evidência e, quando é estrutural, vira decisão nova para `ll-decidir-antes` — nunca patch silencioso desta sessão.

**O relato do implementador é a ré, não a testemunha.** A primeira passada é cega ao `PROGRESS.md`, ao diário e a qualquer justificativa de quem implementou: os verificadores recebem apenas o `SPEC.md`, o repositório e o código entregue. Só depois de o veredicto independente estar formado é que o relato entra — e a divergência entre o relatado e o real é achado de primeira classe, não nota de rodapé. Isso existe porque o auto-relato de agentes degrada com o tempo de execução: em execuções longas, o "passes: true" é a afirmação menos confiável do repositório.

Entregável: `docs/spec-<slug>/VERIFICACAO.md`, ao lado da spec auditada.

## Fase 0 — Enquadramento

Localize `SPEC.md` e `PROGRESS.md` (padrão: `docs/spec-*/`). Sem SPEC, vá para o modo degradado no fim deste arquivo.

Numa única troca com o usuário, feche: **o que é a entrega** (todos os marcos ou um subconjunto) e **o recorte de código** (branch, range de commits, worktree). Delimite o range agora — `git log --oneline` e `git diff --stat` do recorte são insumo dos verificadores. Nada mais é perguntado até o veredicto.

Leia o `SPEC.md` inteiro nesta sessão: §2 invariantes, §3 decisões, §4 critérios, §5 escopo negativo e pendências, §6 marcos com o estado `passes`, §7 protocolo. Você precisa dele para montar os briefs; os verificadores o leem por conta própria.

Enquanto isso, **não abra o `PROGRESS.md` nem `decisoes/`**. Guarde-os para a fase 2 — ler o relato antes de ver o resultado ancora o veredicto exatamente no lugar que esta skill existe para evitar.

## Fase 1 — Auditoria em camadas, em contexto limpo

Delegue as três camadas a subagentes paralelos, cada um com contexto limpo. Leia `referencias/briefs-auditoria.md` agora: ele traz os três briefs prontos, o contrato de saída de cada um e o esqueleto do relatório. Roteamento: camada (a) é mecânica (Sonnet, esforço baixo); (b) é adversarial e é onde um defeito perdido vai para produção (Opus); (c) é varredura contra critérios explícitos (Sonnet).

- **(a) Mecânica — os comandos.** Roda TODOS os comandos de verificação da §4 e da §6, um a um, literalmente como escritos, e registra exit code e saída real. Sem substituir comando por equivalente, sem inferir resultado. Marco com `passes: true` cujo comando falha é a violação mais grave do repositório.
- **(b) Contrato — as decisões.** Cada DEC-NNN e ASS-NNN da §3 conferida contra o código com `arquivo:linha`: implementada, contornada, ou re-decidida silenciosamente? Invariantes MUST/NEVER da §2 varridos um a um. Escopo negativo da §5a: o que foi construído fora dele? Assunções escaladas quando a evidência as contradizia?
- **(c) Integridade do processo.** O histórico do próprio contrato: critérios de aceite ou testes editados, afrouxados ou deletados durante a execução sem DEC-P correspondente; commits fora do padrão da §7; `decisoes/DEC-P-NNN.md` ainda `AGUARDANDO HUMANO` cuja pergunta o código respondeu sozinho.

Regras que valem para as três camadas e vão em todo brief:

- Cobertura total com rótulo, filtragem depois. Cada item da spec recebe um veredicto — **CONFORME**, **FALHA** ou **NÃO VERIFICÁVEL** — e o relatório lista os três. "Verificado e conforme", item a item, é resultado; "não encontrei nada" dito claramente também.
- **NÃO VERIFICÁVEL** carrega o porquê e o que seria necessário (serviço no ar, credencial, fixture ausente, comando que não existe). Nunca vira CONFORME por plausibilidade.
- Achado exige `arquivo:linha` ou saída de comando colada. Sem evidência, é hipótese — e hipótese entra como AVISO, marcada como tal.
- Nenhum verificador edita código, testes, a spec ou o estado dos marcos.

## Fase 2 — Confronto relato × real

Com os três veredictos em mãos, só então abra `PROGRESS.md`, o diário e `decisoes/`. Confronte:

- marcos declarados `passes: true` cujos comandos falharam ou não rodam;
- diário afirmando verde em comando que o verificador viu vermelho;
- decisões "two-way" registradas na §5b que na verdade contradizem uma decisão da §3 ou um invariante da §2;
- pendências e DEC-P tratadas como resolvidas sem resposta do humano;
- trabalho relatado sem contraparte no código, e código sem contraparte no relato.

Cada divergência entra no relatório com as duas versões lado a lado: **relatado** (citação do PROGRESS.md) × **real** (evidência do verificador).

## Fase 3 — Relatório e veredicto

Escreva `docs/spec-<slug>/VERIFICACAO.md` no esqueleto de `referencias/briefs-auditoria.md`. Vocabulário fechado de severidade:

| Rótulo | Significado |
|---|---|
| **BLOQUEIA ENTREGA** | comando de aceite falha, invariante violado, decisão da §3 contrariada, ou marco `passes: true` sem comando passando |
| **DIVERGÊNCIA DE CONTRATO** | o entregue difere do combinado sem violar invariante: escopo extrapolado, decisão re-decidida com resultado defensável, critério editado, relato × real |
| **AVISO** | risco observado, dívida, item NÃO VERIFICÁVEL, hipótese sem evidência dura |

O veredicto global é mecânico, não julgamento: qualquer BLOQUEIA ENTREGA → **REPROVADA**; nenhum BLOQUEIA mas algum DIVERGÊNCIA ou NÃO VERIFICÁVEL → **APROVADA COM RESSALVAS**; todos os critérios e marcos CONFORME → **APROVADA**.

Feche com a lista de pendências que realimenta `ll-decidir-antes`: cada falha estrutural — a que exige escolher de novo, não corrigir — vira uma decisão a ser tomada, com as opções e o custo de cada uma. Falha local (teste quebrado, bug pontual) fica como item de correção, sem virar decisão.

Apresente ao usuário, em poucas linhas: o veredicto, a contagem por severidade, os BLOQUEIA ENTREGA nomeados, e as decisões que sobraram para ele — com a sugestão de rodar `ll-decidir-antes` sobre elas se houver mais de uma estrutural. Você entrega o relatório e para aqui.

## Modo degradado — sem SPEC.md

Sem contrato escrito, a verificação é mais fraca e isso é declarado, não disfarçado.

Reconstrua a definição de pronto: extraia do pedido original, dos testes existentes e do README o que se pode inferir, e leve ao usuário numa única rodada de perguntas o que ficou ambíguo — critério que duas pessoas poderiam ler diferente não serve de oráculo. Registre os critérios reconstruídos no topo do `VERIFICACAO.md`, com a origem de cada um (inferido / confirmado pelo usuário), e a nota de que a auditoria vale contra eles e não contra um contrato acordado antes do código.

Rode as camadas (a) e (b) contra esses critérios; a camada (c) cai — sem spec versionada não há integridade de processo a auditar. Feche sugerindo `ll-decidir-antes` para a próxima entrega, para que a verificação seguinte tenha um oráculo em vez de uma reconstrução.

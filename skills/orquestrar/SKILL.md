---
name: orquestrar
description: Regras de orquestração multi-agente — quando delegar a subagentes, como decompor tarefas, escrever briefs precisos, rotear cada etapa para o modelo certo e verificar resultados com evidência. Use antes de qualquer trabalho que envolva subagentes, fan-out paralelo, revisões independentes ou tarefas amplas (auditorias, migrações, features que tocam vários módulos).
---

# Orquestração e delegação

Ao planejar como executar a tarefa atual, siga estas regras na ordem em que aparecem.

## Quando delegar (e quando não)

- **Agente único primeiro.** Só faça fan-out quando pelo menos um destes valer: os
  subtrabalhos geram contexto volumoso e irrelevante entre si; o trabalho é genuinamente
  paralelo em arquivos disjuntos; ou os papéis precisam de independência (implementador
  vs revisor). O custo escala aproximadamente linear por worker, até ~15× uma sessão
  simples — gaste onde o resultado compensa.
- **Escale o esforço à complexidade**: lookup/correção trivial = inline; algumas peças
  independentes = 2–4 subagentes; varredura ampla ou auditoria = um agente por fatia
  estreita. Três workers focados vencem cinco dispersos; escopos pequenos são a defesa
  contra apodrecimento de contexto.
- **Decomponha por fronteiras de contexto, não por fase.** Um agente é dono de um
  módulo/página/fatia de ponta a ponta. Evite correntes plano→implementa→testa entre
  agentes — cada handoff perde fidelidade.
- **Delegue de forma assíncrona** e continue trabalhando enquanto os subagentes rodam;
  para subtarefas de acompanhamento sobre o mesmo material, envie mensagem ao agente
  existente em vez de criar outro (preserva contexto e cache).

## Briefs para subagentes

- **Subagentes não veem nada desta conversa.** Todo brief carrega: objetivo, contrato
  de saída exato (schema ou formato), caminhos/payloads/restrições verificados, e
  limites explícitos (o que não tocar). Escreva o brief certo da primeira vez; uma vez
  delegado, confie — não refaça o trabalho do subagente nem re-derive suas descobertas.
- **Anatomia de um brief**, nesta ordem: papel em uma frase → contexto e motivação (a
  tarefa maior, para quem é, o que a saída habilita) → dados/referências → instruções →
  contrato de saída → limites de escopo → critérios de sucesso. Material longo vai no
  topo, instruções depois dele. Critérios de sucesso nomeiam verificações explícitas
  ("rode o typecheck e o build, liste cada rota verificada"), nunca "garanta que
  funciona" — vagueza convida a declarações prematuras de sucesso.
- **Delimite conteúdo misto com tags XML** (`<context>`, `<instructions>`, `<input>`,
  uma tag por tipo de conteúdo). Para documentos longos, peça ao agente para citar as
  partes relevantes primeiro e agir sobre as citações.
- **Especificação completa de uma vez.** Modelos atuais rendem melhor recebendo a
  tarefa inteira e sendo deixados rodar; pingar requisitos aos poucos desperdiça tokens
  e fidelidade.
- **Instruções positivas e específicas** ("componha parágrafos de prosa fluida", não
  "não use markdown"). Teste de ouro: um colega com contexto mínimo, lendo só o prompt,
  conseguiria fazer a tarefa.
- **Formato de saída**: declare o schema ou formato diretamente. Prompts de revisão
  pedem cobertura completa + rótulos de confiança, filtrados depois — "só reporte
  severidade alta" é seguido ao pé da letra e colapsa o recall.
- **Não use andaimes de raciocínio**: nada de "pense passo a passo", planos manuais de
  chain-of-thought, "seja minucioso", "verifique duas vezes" ou instruções repetidas —
  hoje isso degrada a saída. Um "pense a fundo sobre X" genérico basta.

## Handoffs e contexto

- **Handoff = condensado e estruturado** (≲2k tokens), nunca transcrições. Artefatos
  pesados (screenshots, relatórios longos, datasets) vão para arquivos; passe caminhos
  de volta, não conteúdos.
- **Contexto mínimo eficaz**: o menor conjunto de tokens de alto sinal que alcança o
  resultado. Dê caminhos e queries e deixe os agentes lerem just-in-time; nunca cole
  conteúdo de arquivo que o agente pode ler sozinho.
- Referências ricas (código real, uma suíte de testes, um protótipo) vencem descrições
  em prosa. Não repita instrução que já está em contexto.
- **Trabalho de longo horizonte**: externalize estado para arquivos e git. Resumos são
  um índice do que mudou e de como foi verificado — o detalhe vive no diff e nos
  commits.

## Roteamento de modelos (roteie cada etapa, não o trabalho inteiro)

Tiers por capacidade e custo — cada tier custa ~2–3× o de baixo:
Fable > Opus > Sonnet. Sonnet é o piso — não roteie abaixo dele.

- **Fable** — orquestração: decomposição, briefs, julgamentos finais e builds de longo
  horizonte com verificadores periódicos. Não gaste tokens de Fable em execução.
- **Opus** — código complexo, refatorações profundas, revisão adversarial onde um
  defeito perdido vai para produção, debugging não trivial.
- **Sonnet** — cavalo de batalha padrão: implementação bem especificada, varreduras de
  revisão contra critérios explícitos, testes, checklists e leitura/extração em massa.
- Na dúvida entre dois tiers → pegue o mais barato; contexto limpo e brief preciso
  compram mais qualidade que um modelo maior. Rode etapas mecânicas em esforço baixo.

## Verificação e evidência

- **Verificação com contexto limpo.** Um agente revisor/verificador nunca vê o
  raciocínio da implementação — ele checa o resultado contra a especificação.
  Descobertas exigem evidência arquivo:linha; "não encontrei nada" dito claramente é um
  resultado válido. Para descartar uma descoberta, refute com evidência, não opinião.
- Valide as afirmações dos subagentes você mesmo com evidência barata (diff, grep
  focado, um teste dirigido), proporcional ao risco — mais fundo para migrações,
  contratos de dados, efeitos externos e hot paths.
- **QA visual/de browser roda dentro de subagentes** — screenshots apodrecem o contexto
  principal rápido. O agente de QA visualiza cada screenshot que captura (screenshot
  nunca visto é checagem nunca feita) e retorna só uma lista estruturada de achados.
- Toda afirmação de "funciona"/"pronto" rastreia a um resultado de ferramenta desta
  sessão: saída de teste, arquivo:linha, uma query real, um screenshot. Nomeie
  suposições e o que não foi verificado.
- Quando um requisito, contrato ou semântica de dados está indefinido, reporte a lacuna
  e pergunte — nunca preencha com uma interpretação plausível e siga em frente.

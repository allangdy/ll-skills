# Briefs dos verificadores e esqueleto do relatório

Leitor: o agente da skill `ll-verificar-entrega`, na fase 1. Abaixo, os três briefs prontos para despachar (preencha os `<placeholders>` com os caminhos e o range fechados na fase 0), o contrato de saída de cada camada e o esqueleto do `VERIFICACAO.md`.

Os verificadores não veem a conversa nem uns aos outros: cada brief é autossuficiente. Despache os três em paralelo, numa única mensagem.

---

## Bloco comum — cole em todo brief

<regras-comuns>
Você audita, não conserta. Nenhuma edição de código, teste, spec ou estado de marco;
nenhum commit. Encontrou defeito: reporte com evidência e siga.

Você NÃO abre `PROGRESS.md`, o diário de execução, `decisoes/` nem mensagens de
commit como justificativa. O relato de quem implementou não é insumo do seu
veredicto — quem confronta relato com realidade é a sessão que te despachou, depois
de receber o seu resultado. Suas fontes são o SPEC.md, o repositório e o que os
comandos devolvem.

Cobertura completa, com rótulo — a filtragem é feita depois de você. Todo item do
seu escopo recebe um veredicto:
- CONFORME — evidência de que está como a spec exige.
- FALHA — evidência de que não está.
- NÃO VERIFICÁVEL — você não conseguiu decidir. Diga o porquê e o que seria
  necessário (serviço no ar, credencial, fixture, comando inexistente). Nunca
  promova a CONFORME por plausibilidade.

Todo achado carrega evidência dura: `arquivo:linha` ou a saída do comando colada.
Sem evidência dura é hipótese — reporte assim mesmo, rotulada `hipótese`.
"Verifiquei e está conforme", item a item, é resultado válido; um relatório sem
falhas é um resultado, não um fracasso seu.
</regras-comuns>

---

## Camada (a) — mecânica: os comandos

Modelo: Sonnet, esforço baixo. É execução literal e transcrição fiel.

<brief-mecanica>
Você é o verificador mecânico de uma entrega de software. Roda os comandos de
verificação que o contrato de entrega define e registra o que eles realmente
devolvem.

Contexto: um agente autônomo implementou `<caminho>/SPEC.md` ao longo de dias e
declarou a entrega pronta. O auto-relato desse tipo de execução degrada com o
tempo, então nada é aceito por declaração. Seu resultado é a base factual de uma
auditoria que decide se a entrega é aprovada.

Dados:
- Contrato: `<caminho>/SPEC.md` — leia a §4 (critérios de aceite) e a §6 (marcos)
  na íntegra; a §7 traz o comando de sanidade.
- Repositório: `<raiz do repo>`, recorte `<branch/range>`.

Instruções:
1. Rode o comando de sanidade da §7 primeiro e registre o baseline.
2. Rode TODOS os comandos de verificação da §4 e da §6, um a um, na ordem em que
   aparecem, exatamente como escritos. Comando que não roda como escrito é
   NÃO VERIFICÁVEL com o motivo — não o substitua por equivalente, não o ajuste,
   não o divida.
3. Para cada comando registre: o comando literal, o exit code, e as linhas da
   saída que sustentam o veredicto (o resumo de testes, o status HTTP, a mensagem
   de erro). Comando que falha é repetido uma vez, para separar instabilidade de
   falha real; os dois resultados entram.
4. Confronte o resultado com o campo `passes` de cada marco da §6, lido como está
   escrito no arquivo. Marco `passes: true` cujo comando não passa nesta execução
   é o achado de maior severidade que existe: nomeie-o explicitamente.

Contrato de saída (markdown, nesta ordem):
- `## Sanidade` — comando, exit code, veredicto.
- `## Critérios (§4)` — tabela: ID | comando literal | exit code | evidência (≤2
  linhas da saída) | CONFORME/FALHA/NÃO VERIFICÁVEL.
- `## Marcos (§6)` — tabela: marco | passes declarado | comandos | resultado real
  | CONFORME/FALHA/NÃO VERIFICÁVEL.
- `## Marcos declarados prontos que não passam` — lista, ou "nenhum".
- `## Ambiente` — o que precisou existir para os comandos rodarem e o que faltou.

Limites: não escreva nem edite arquivo algum do repositório; não instale
dependências nem suba serviços além do que a §7 prescreve como sanidade — o que
faltar vira NÃO VERIFICÁVEL com o requisito nomeado.

Critérios de sucesso: todo comando das §4 e §6 aparece na sua saída com exit code
real; nenhum veredicto vem de leitura de código no lugar de execução.

<regras-comuns aqui>
</brief-mecanica>

---

## Camada (b) — contrato: as decisões e os invariantes

Modelo: Opus. É a camada adversarial, onde um defeito perdido vai para produção.

<brief-contrato>
Você é o verificador de contrato de uma entrega de software. Confere, decisão por
decisão, se o código entregue é o que foi acordado — e nomeia onde ele divergiu.

Contexto: antes do código, o dono do projeto e um agente fecharam um contrato de
decisões (`SPEC.md`, §2 invariantes e §3 decisões). Um implementador autônomo
rodou por dias com essa spec como única fonte. O modo de falha conhecido dessas
execuções é o implementador re-decidir sob atrito — encontra resistência no
código, escolhe outro caminho e segue sem escalar. Seu trabalho é achar essas
re-decisões silenciosas, que passam despercebidas justamente porque o código
funciona.

Dados:
- Contrato: `<caminho>/SPEC.md` — §2 (invariantes MUST/NEVER), §3 (decisões
  DEC-NNN e assunções ASS-NNN, cada uma com escolha, porquê, alternativa rejeitada
  e entregáveis nomeados), §5a (escopo negativo).
- Repositório: `<raiz do repo>`, recorte `<branch/range>`. Use
  `git diff --stat <range>` para ver o que a entrega tocou.

Instruções:
1. Para cada DEC-NNN e ASS-NNN da §3: abra os entregáveis que ela nomeia e
   classifique com `arquivo:linha` — IMPLEMENTADA (o código faz o que a decisão
   escolheu); CONTORNADA (o código atende à letra mas frustra o porquê declarado);
   RE-DECIDIDA (o código faz outra coisa, em geral a alternativa rejeitada);
   AUSENTE (o entregável não existe). Decisão marcada CONTRA A RECOMENDAÇÃO do
   dono é conferida com o mesmo rigor: o risco aceito não é seu para revisar.
2. Para cada invariante da §2: procure violações no recorte inteiro, não só nos
   entregáveis. Invariante NEVER exige varredura ativa (grep pelo que é proibido),
   não leitura passiva.
3. Escopo negativo (§5a): o que foi construído que a spec mandou não construir?
   Cite `arquivo:linha`.
4. Assunções ASS-NNN: cada uma declara "escalar se <condição>". A condição
   ocorreu? Se ocorreu e a assunção seguiu em pé sem escalada, é achado.
5. Liberdades da §5b: decisões tomadas dentro delas são legítimas — verifique
   apenas que ficaram dentro, sem invadir a §3.

Contrato de saída (markdown):
- `## Decisões (§3)` — uma entrada por DEC/ASS: ID | classificação | evidência
  `arquivo:linha` | o que o código faz, em uma frase | CONFORME/FALHA/NÃO
  VERIFICÁVEL.
- `## Invariantes (§2)` — um por linha: ID | como varreu (comando/grep) | achados
  com `arquivo:linha` | veredicto.
- `## Escopo negativo (§5a)` — construído fora do escopo, com evidência, ou
  "nada encontrado".
- `## Assunções que deveriam ter sido escaladas` — lista, ou "nenhuma".
- `## Hipóteses` — suspeitas sem evidência dura, rotuladas.

Limites: você não julga se a decisão foi boa — julga se foi cumprida. Não proponha
refatoração, não corrija código, não edite a spec.

Critérios de sucesso: toda DEC-NNN, ASS-NNN e todo invariante da spec aparecem na
sua saída com veredicto e evidência; nenhuma entrada fica sem `arquivo:linha` ou
sem um motivo explícito de NÃO VERIFICÁVEL.

<regras-comuns aqui>
</brief-contrato>

---

## Camada (c) — integridade do processo

Modelo: Sonnet. Varredura contra critérios explícitos, sobre o histórico do repo.

<brief-integridade>
Você audita a integridade do processo de uma entrega de software: se o contrato
que está sendo verificado hoje é o mesmo que foi acordado antes do código.

Contexto: a spec `<caminho>/SPEC.md` é append-only depois de aprovada, e os
critérios de aceite e testes dela são intocáveis pelo implementador (invariante
I-02 típico): critério errado é motivo de escalada, nunca de edição. A ambiguidade
que aparece em voo vira um arquivo `decisoes/DEC-P-NNN.md` com status AGUARDANDO
HUMANO. O modo de falha que você procura é o oráculo mutilado — o implementador
que afrouxou o teste, editou o critério ou respondeu sozinho a própria pergunta e
seguiu.

Dados:
- `<caminho>/SPEC.md` e o histórico dele: `git log -p --follow -- <caminho>/SPEC.md`.
- `<caminho>/decisoes/` (os arquivos DEC-P, se existirem).
- Repositório `<raiz do repo>`, recorte `<branch/range>`; §7 do SPEC.md traz o
  protocolo de execução com as regras de commit e escalada.

Instruções:
1. Histórico da spec após a aprovação: toda mudança que não seja acréscimo
   append-only (entrada nova, supersede explícito, `passes: false` → `true`) é
   achado. Critério de aceite reescrito, comando de verificação afrouxado, marco
   removido: cite o commit e o diff.
2. Testes e fixtures no recorte: procure teste deletado, `skip`/`only`/`xfail`
   adicionado, asserção afrouxada, timeout inflado, mock que substituiu integração
   real. Compare com o baseline do início do recorte. Cite `arquivo:linha` e o
   commit.
3. `decisoes/DEC-P-NNN.md`: para cada um com status AGUARDANDO HUMANO, procure no
   código se a pergunta foi respondida na prática. Pergunta aberta implementada é
   achado — decisão one-way tomada em silêncio.
4. Pendências da §5c: cada uma tem dono e marco. As de dono "humano" foram
   tratadas como resolvidas sem resposta? As de dono "implementador" foram
   cumpridas (por exemplo, promovidas a critério com comando)?
5. Commits do recorte contra a §7: unidades pequenas e descritivas, ou um despejo
   final? Houve force push, rebase que reescreveu histórico, migração destrutiva
   ou ação irreversível que nenhum marco autorizava?

Contrato de saída (markdown):
- `## Mudanças na spec após aprovação` — commit | trecho | append-only? | veredicto.
- `## Oráculo mutilado` — testes/critérios enfraquecidos, com `arquivo:linha` e
  commit, ou "nada encontrado".
- `## DEC-P e pendências` — ID | status declarado | o que o código mostra |
  veredicto.
- `## Higiene de commits e ações irreversíveis` — achados com hash, ou
  "conforme a §7".

Limites: não reverta nada, não recrie testes deletados, não edite a spec. Você
descreve o que aconteceu com o contrato, com o commit como prova.

Critérios de sucesso: cada uma das cinco frentes acima aparece na saída, com
achados citando commit e `arquivo:linha` ou com um "nada encontrado" explícito.

<regras-comuns aqui>
</brief-integridade>

---

## Esqueleto do VERIFICACAO.md

Escrito pela sessão principal na fase 3, a partir dos três resultados e do
confronto da fase 2. Ordem fixa: o veredicto primeiro — é o que o usuário lê.

<template>
# VERIFICAÇÃO — <nome da spec> — <data>

**Veredicto: <APROVADA | APROVADA COM RESSALVAS | REPROVADA>**

Auditado: `<caminho>/SPEC.md` · recorte `<branch/range>` · <N> commits.
Camadas: mecânica, contrato, integridade — todas em contexto limpo, sem acesso ao
PROGRESS.md na formação do veredicto.

| Severidade | Qtd |
|---|---|
| BLOQUEIA ENTREGA | <n> |
| DIVERGÊNCIA DE CONTRATO | <n> |
| AVISO | <n> |

Critérios: <n> CONFORME · <n> FALHA · <n> NÃO VERIFICÁVEL.
Em uma frase: <o que a entrega faz de fato e o que falta para estar pronta>.

## 1. Critérios de aceite

| ID | Comando | Saída real | Veredicto |
|---|---|---|---|
| CA-03 | `npm test -- import.spec.ts -t "linha inválida"` | exit 1 — `2 failing: expected 401, got 500` | FALHA |
| CA-07 | `curl -s -o /dev/null -w "%{http_code}" localhost:3000/api/v1/reports` | `401` | CONFORME |

## 2. Marcos

| Marco | passes declarado | Verificação real | Veredicto |
|---|---|---|---|
| M2 — Categorização | true | `npm test -- categorize.spec.ts` → exit 1 | FALHA |

## 3. Achados

Um bloco por achado, do mais grave ao menos:

### A-01 · BLOQUEIA ENTREGA · M2 marcado pronto com suíte vermelha
- Evidência: `npm test -- categorize.spec.ts` → exit 1, `3 failing`
  (`src/import/categorize.ts:44`).
- Contrato ferido: §6 M2; §7 item 5 (`passes: true` só com comando passando).
- Consequência: o marco seguinte foi construído sobre base vermelha.

### A-02 · DIVERGÊNCIA DE CONTRATO · DEC-004 re-decidida
- Evidência: `src/services/contact-identity.ts:120` normaliza in place.
- Contrato ferido: DEC-004 escolheu coluna canônica ao lado; in place é a
  alternativa rejeitada, pela trilha de auditoria.
- Consequência: <o que quebra ou fica em risco>.

## 4. Relatado × real

| Relatado no PROGRESS.md | Real | Severidade |
|---|---|---|
| "M2: `categorize.spec.ts` verde; passes: true" (2026-08-22) | exit 1, 3 failing | BLOQUEIA ENTREGA |

## 5. Não verificável

| Item | Por que | O que seria necessário |
|---|---|---|
| CA-09 | serviço de e-mail não sobe no ambiente | credencial SMTP de sandbox ou fixture de fila |

## 6. Conforme

Lista enxuta do que foi verificado e está de acordo — critérios, invariantes,
decisões, escopo negativo. Item a item, sem prosa.

## 7. Pendências

**Decisões para o dono** (realimentam `ll-decidir-antes` — escolha, não correção):
- D-01 — <a pergunta em uma linha>. Opções: A) <custo> B) <custo>. Origem: A-02.

**Correções** (falhas locais, sem decisão nova):
- C-01 — <o que corrigir>. Origem: A-01.
</template>

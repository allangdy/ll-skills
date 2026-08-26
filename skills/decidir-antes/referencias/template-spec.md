# Template comentado — SPEC.md + PROGRESS.md

Leitor: o agente da skill `decidir-antes`, na fase 4. Você escreve o SPEC.md a partir da FILA.md fechada; o consumidor é um implementador autônomo que NÃO conhece esta skill e pode rodar por dias — a spec é tudo o que ele tem. Autossuficiência é o requisito; cada seção abaixo vem com o seu papel e o que a invalida.

Orçamento: o SPEC.md inteiro cabe em ~300 linhas. Detalhe fino (mapa do sistema, comparativos de pesquisa, copy literal extensa) entra por referência de caminho, lido just-in-time — spec longa é spec que o implementador para de consultar. Após aprovação, o SPEC.md é append-only: decisões novas são entradas novas com supersede explícito, nunca reescrita silenciosa.

Precedência entre seções: em conflito, a de número menor vence. Declare isso no preâmbulo — sem hierarquia explícita, o implementador sob pressão sacrifica o inegociável para salvar a preferência.

---

## §0 — Cabeçalho e preâmbulo

Papel: contrato de leitura. Fixa autossuficiência, precedência e o "não re-litigar" antes de qualquer conteúdo. Invalidado por: pivô de escopo aprovado pelo dono → versão nova, com a anterior preservada no git.

<template>
# SPEC: <nome> — v1 (<data>) — status: APROVADA

Para o implementador: leia este arquivo inteiro antes de qualquer código. Ele é
autossuficiente — os materiais de origem só são abertos nos caminhos citados aqui,
no trecho citado. As decisões da seção 3 foram tomadas com o dono do projeto: são
contrato, não sugestões — não as re-litigue. Em conflito entre seções, a de número
menor prevalece (2 > 3 > 4 > 5).
</template>

## §1 — Objetivo e resultado final

Papel: âncora anti-drift. É o parágrafo que o implementador relê a cada marco para responder "o que estou construindo mesmo?". Um parágrafo, com o teste de sucesso de mais alto nível — comportamento de ponta a ponta, não lista de features. Invalidado por: mudança de objetivo = spec nova, não edição.

<template>
## 1. Objetivo e resultado final
Quando este trabalho terminar, um assinante importa um extrato CSV do banco, revisa
as transações categorizadas automaticamente e exporta o relatório mensal em PDF —
de ponta a ponta, sem intervenção manual. Teste de mais alto nível: o fluxo
importar → revisar → exportar completa com `fixtures/extrato-real.csv` e o PDF
gerado contém as 3 seções do relatório.
</template>

## §2 — Invariantes (inegociáveis)

Papel: a constituição. Lista numerada, ≤15 itens, linguagem normativa MUST/NEVER — o implementador segue palavras normativas com mais fidelidade que parágrafos. Ficam no topo porque compactação de contexto e primazia preservam o início do arquivo. Entram aqui: stack travada, contratos que não podem quebrar, proibições absolutas. Invariante só muda pelo dono, via escalada — nunca pelo implementador.

<template>
## 2. Invariantes (MUST/NEVER)
I-01. MUST manter todas as suítes existentes verdes em todo commit.
I-02. NEVER deletar, desabilitar ou editar teste ou critério de aceite — mudança
      neles é escalada (seção 7), sem exceção.
I-03. MUST usar o Postgres já provisionado; NEVER introduzir outro datastore.
I-04. NEVER rodar migração destrutiva, deleção de dados ou push forçado fora do
      que um marco autoriza explicitamente.
I-05. MUST manter compatibilidade do endpoint público `GET /api/v1/reports`
      (contrato em `docs/spec-relatorios/mapas/api.md`).
</template>

## §3 — Decisões tomadas (mini-ADRs, append-only)

Papel: onde o porquê vive. Sem o porquê e a alternativa rejeitada, o implementador re-decide errado no primeiro atrito — e redescobre com entusiasmo exatamente a alternativa que o dono rejeitou. A **Origem** separa o que é escalável do que não é: resposta do dono = contrato fechado; assunção = escalável por evidência contrária. Transcreva da FILA.md só as decisões materiais (todo ALTO; MÉDIO que muda contrato); o restante fica na FILA, referenciada por caminho.

Regras herdadas do registro (falhas reais que esta seção previne):
- Decisão que cita um entregável **nomeia o entregável** (arquivo, rota, migração, tela). "Alimenta o CTA" sem nomear o CTA é re-pergunta na semana 2.
- Decisão contra a recomendação carrega a marca e as consequências aceitas — e não é re-litigada.
- Supersede é explícito: entrada nova com `Supersede: DEC-NNN`; a original ganha ~~strikethrough~~ + data + quem decidiu. Nunca reescrita silenciosa.

<template>
## 3. Decisões
### DEC-004 — Identidade de contato: chave canônica ao lado (dono, 2026-08-20)
- Escolha: coluna canônica DERIVADA ao lado da original, sem backfill.
- Porquê: com DEC-001 = big-bang, o schema novo nasce sem custo de migração
  incremental; a original preserva o histórico de auditoria.
- Alternativa rejeitada: normalizar in place — reescreveria os 4 writers de
  `contact-service` e quebraria a trilha de auditoria.
- Origem: resposta do dono (entrevista, PERGUNTA 4/12).
- Entregáveis: migração `migrations/2026xxxx_add_canonical_key.sql`; atualização
  de `src/services/contact-identity.ts`.

### DEC-007 — Retenção de uploads: 90 dias (dono, CONTRA a recomendação, 2026-08-20)
- Escolha: reter CSVs originais por 90 dias. Recomendação era 30 dias (custo de
  storage + LGPD); dono aceitou o custo pelo suporte a re-processamento.
- Risco aceito conscientemente: ~3× storage; revisão de política LGPD é pendência
  P-02 (dono: humano, marco M4). NÃO re-litigar.

### ASS-002 — Datas: date-fns (assunção, two-way door)
- Default: date-fns, já presente no lockfile e usada em 12 módulos.
- Porquê: troca posterior é um codemod local; não condiciona outra decisão.
- Escalar se: a evidência exigir aritmética de timezone que date-fns não cobre.
</template>

## §4 — Critérios de aceite (verificáveis por comando)

Papel: o oráculo. Critério bom é binário, observável e inequívoco — teste: duas pessoas poderiam discordar se passou? Então não é critério. Formato QUANDO/O SISTEMA (ou Given/When/Then), com valores exatos e caminhos de erro cobertos.

**Regra dura: critério sem comando de verificação executável não entra nesta seção.** Ele vira pendência com dono nomeado e marco (seção 5c) até ganhar um comando — foi assim que "maximizar cache ≥90%" vazou numa execução real: estava escrito, ninguém tinha como verificar, e quem pegou a falha foi o dono olhando a fatura. Verificação é por comando, nunca por julgamento do implementador.

<template>
## 4. Critérios de aceite
CA-03 — Importação com linha inválida
  QUANDO o CSV contém uma linha com valor não numérico, O SISTEMA importa as
  demais linhas e lista a rejeitada com o motivo "valor inválido na coluna N".
  Verificação: `npm test -- import.spec.ts -t "linha inválida"` → exit 0.

CA-07 — Endpoint protegido
  QUANDO a requisição não tem token, `GET /api/v1/reports` responde 401 com corpo
  `{"error":"unauthorized"}`.
  Verificação: `curl -s -o /dev/null -w "%{http_code}" localhost:3000/api/v1/reports` → `401`.
</template>

Contra-exemplo (não entra): "a importação lida bem com dados ruins" — não falseável; ou o CA-03 sem a linha de Verificação — vira P-NN com dono, não critério.

## §5 — Fora de escopo, liberdades e pendências

Papel: a cerca dos dois lados — previne tanto scope creep quanto paralisia. (a) lista o que NÃO construir (o não-escopo é listado, não omitido); (b) lista as two-way doors delegadas ao implementador — cada uma registrada no PROGRESS.md quando tomada; (c) pendências que sobraram da entrevista, cada uma com dono e marco — pendência sem dono some.

<template>
## 5. Escopo negativo, liberdades, pendências
(a) Fora de escopo — não construir: exportação para Excel; multi-moeda;
    onboarding novo (fica como está).
(b) Liberdade do implementador (registrar no PROGRESS.md ao decidir): estrutura
    interna de componentes; naming de módulos novos; texto de mensagens de erro
    (tom: direto, sem jargão).
(c) Pendências: P-02 — revisão LGPD da retenção de 90d (dono: humano, até M4);
    P-03 — comando de verificação para o custo por request (dono: implementador,
    definir no M1 e promover a CA).
</template>

## §6 — Marcos

Papel: fatiamento em unidades de sessão. 3–7 marcos; cada um cabe numa sessão de trabalho — marco gigante é o modo de falha "tentar tudo e esgotar contexto no meio". `passes` nasce `false` e é mecânico: só vira `true` com os comandos passando (impede declaração prematura de conclusão). Estado dos marcos vive AQUI (é a exceção de mutabilidade da spec: só o campo `passes` muda, e só de false para true).

<template>
## 6. Marcos
### M1 — Parser de CSV com rejeição por linha — passes: false
- Entregável: `src/import/parser.ts` + `import.spec.ts`.
- Verificação (todas passam): `npm test -- import.spec.ts`; `npm run typecheck`.
### M2 — Categorização automática — passes: false
- Entregável: `src/import/categorize.ts`; cobre CA-04, CA-05.
- Verificação: `npm test -- categorize.spec.ts`; `npm run typecheck`.
</template>

## §7 — Protocolo de execução

Papel: o anti-drift. Este texto vai **completo e verbatim** em toda spec (parametrize `<comando de sanidade>` e os orçamentos) — qualquer agente que receba o SPEC.md o segue sem conhecer a skill que o gerou.

<template>
## 7. Protocolo de execução
Estas regras regem o implementador desta spec e prevalecem sobre hábitos ou
instruções genéricas de sessão.

Início de cada sessão:
1. Leia esta spec inteira, depois PROGRESS.md e `git log --oneline -20`.
2. Rode a sanidade (`<comando de sanidade>`) e confirme baseline verde ANTES de
   implementar. Vermelho herdado: registre no PROGRESS.md e restaure o verde
   antes de avançar qualquer marco.
3. Escolha o próximo marco `passes: false` na ordem da seção 6. Um marco por
   sessão/ciclo.

Durante o marco:
4. Releia as seções 1 e 2 ao iniciar cada marco.
5. `passes: true` somente com os comandos de verificação do marco passando nesta
   sessão — nunca por julgamento.
6. Critérios de aceite e testes não são editáveis (I-02). Critério errado ou
   inatingível é motivo de escalada, não de edição.
7. Decisão two-way tomada em voo (seção 5b): uma linha no PROGRESS.md com o
   porquê.
8. PROGRESS.md é cronológico e append-only: feito, decisão, surpresa, próximo
   passo. Commits pequenos e descritivos a cada unidade verde.

Escalada — pare o marco e escale se, e somente se:
(a) a ação é irreversível e nenhum marco a autoriza (migração destrutiva,
    deleção de dados, push forçado, gasto externo);
(b) a evidência do código contradiz uma decisão da seção 3 ou torna um
    invariante da seção 2 insatisfazível;
(c) o orçamento estourou: <N> tentativas no mesmo erro, ou <limite> de
    tempo/tokens no marco.
Fora dessas classes, decida e registre — sem perguntar por cadência nem por
conforto.

Ambiguidade nova (o humano pode não estar presente):
9. Escreva `decisoes/DEC-P-NNN.md` (formato ao fim da spec) com pergunta,
   opções com custo, recomendação, impacto e fonte. Se ela não bloqueia o marco
   atual, continue; se bloqueia, passe ao próximo marco desbloqueado. Nunca
   decida silenciosamente uma one-way door; nunca pare tudo por uma ambiguidade
   localizada.
10. A realidade mudou algo que a spec referencia (rota reescrita por marco
    anterior, arquivo movido, decisão que envelheceu): não obedeça a referência
    morta nem "conserte" a spec — registre a contradição no PROGRESS.md e trate
    como escalada (b). A resposta do dono entra na seção 3 como entrada nova com
    `Supersede: DEC-NNN`.

Precedência: seção 2 > 3 > 4 > 5. Intenção: spec > código existente. Fato
descoberto: código > spec — reporte o conflito em vez de resolvê-lo
reinterpretando a spec.
</template>

---

## PROGRESS.md — esqueleto (criado por você na fase 4, mantido pelo implementador)

Estado mutável fica aqui, fora da spec — a spec permanece estável e cacheável; o par spec/progress é o que permite a qualquer sessão nova reconstruir o estado só do filesystem.

<template>
# PROGRESS — <nome da spec>

## Estado
- Marco atual: M1 — <título> · passes: false
- Sanidade: <verde|vermelho> (<data>, `<comando>`)
- Pendências abertas: P-02 (dono: humano, até M4) · DEC-P-001 (aguarda humano)
- Próximo passo: <concreto>

## Diário (append-only, mais recente por último)
- <data hora> — M1: parser implementado; `npm test -- import.spec.ts` verde;
  commit abc123. passes: true.
- <data hora> — [two-way, §5b] mensagens de erro em pt-BR sem código interno —
  tom da spec pede "sem jargão".
- <data hora> — [surpresa] `contact-service` já normaliza telefone na
  escrita (src/services/contact.ts:88) — sem conflito com DEC-004; registrado.
</template>

## decisoes/DEC-P-NNN.md — formato da ambiguidade serializada

A mesma anatomia de uma pergunta da entrevista, gravada em arquivo para o humano responder assincronamente. Inclua este formato ao fim do SPEC.md (após a seção 7) para o implementador copiar.

<template>
# DEC-P-001 — <a pergunta em uma linha>
- Contexto: <o que a spec diz + o que o código mostra, com arquivo:linha>
- Opções:
  A) <opção> — <custo/consequência>  ← recomendada, porque <porquê>
  B) <opção> — <custo/consequência>
- Impacto: <marcos afetados; bloqueia M-n? o que segue enquanto isso>
- Status: AGUARDANDO HUMANO (<data>)
</template>

---

## Fecho da fase 4

Escritos os dois arquivos: confira que toda decisão ALTO da FILA.md está na seção 3 ou referenciada; que cada critério da seção 4 tem comando; que cada pendência tem dono e marco; que a seção 7 está completa com sanidade e orçamentos preenchidos. Commit. Siga para a fase 5 do SKILL.md.

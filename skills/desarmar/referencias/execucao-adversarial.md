# Execução adversarial, relatório e auditoria

Lido por quem orquestra antes de despachar (D2) e por **todo executor e todo auditor** como
referência de método. Traz: a disciplina de execução, as receitas por tipo de incógnita, o
esqueleto obrigatório do relatório e o protocolo de auditoria de contexto limpo.

---

## A disciplina: reprova primeiro

O teste não existe para mostrar que o sistema funciona. Existe para descobrir **onde ele
para de funcionar**, enquanto isso ainda é barato. Três consequências operacionais:

- **Procure o resultado que reprova.** Depois do primeiro número bom, a tarefa não acabou:
  ela vira "qual entrada faz este número desabar?". Quem executa é o adversário do próprio
  sistema durante a execução inteira.
- **Desconfie da folga.** Aceite de 95% batido com 99,8% costuma significar uma de três
  coisas: a amostra é fácil, a métrica é proxy do que importa, ou o ground truth veio do
  próprio sistema. Teste as três hipóteses antes de comemorar.
- **Aprovação falsa é pior que não testar.** Não testar deixa a incerteza visível; aprovar
  errado compra confiança que será transferida para camadas que ninguém olhou.

### Amostra adversarial

Monte por **composição declarada**, não por sorteio. Uma amostra de 30 bem escolhida vence
uma de 500 aleatória, porque o que decide é a cobertura de classes de entrada, não o n:

- os formatos e origens **distintos** (fornecedores, layouts, dialetos, versões de API);
- o caso que já deu problema uma vez em contexto de baixo risco — o presságio;
- o caso com histórico sujo (retificação, correção posterior, dado migrado, duplicata);
- o caso fora do perfil-alvo (usuário atípico, volume extremo, campo vazio, acento, unidade
  diferente);
- a cauda que o desenho assume ser rara — meça se ela é mesmo.

Registre no relatório a composição real e **toda substituição**: "previstos 3 fornecedores,
o terceiro não tinha dado público na janela; substituído por X, que compartilha o layout de
duas colunas — a propriedade que interessava".

### Ground truth independente

Em ordem de força: fonte oficial externa conferida à mão > dois revisores independentes com
adjudicação do desacordo > critério preditivo externo (o instrumento acerta o que aconteceu
depois?) > caminho duplo independente com juiz nos desacordos. Medir a saída do sistema
contra outra saída do mesmo sistema não é ground truth — é consistência interna, e ela é
alta justamente quando o erro é sistemático.

Quando o ground truth exige conferência manual, declare **quantos itens foram conferidos
visualmente** — é esse número, não o n total, que sustenta a afirmação de erro zero.

### Quebra por classe de entrada

O agregado é a média de coisas diferentes e mente por construção. Toda métrica sai em tabela
por classe: por fonte, por formato, por faixa de tamanho, por tier de modelo, por período.
É dessa tabela que sai a **fronteira de validade** — "0% de erro neste formato; layouts de
duas colunas têm 35–100% de erro e ficam fora do MVP" é um resultado útil; "erro médio de
6%" não decide nada.

### Regras de execução que mudam o número

- **Determinístico fica em script.** Hash, dedupe, contagem, replay, diff, junção: código.
  Julgamento de modelo só onde há ambiguidade real — e ali, com o resultado auditável.
- **Meça com o tier que o produto vai usar.** Tier melhor infla qualidade; tier pior infla
  custo. Num caso real, o modelo mínimo errou classificações com confiança máxima e derrubou
  o recall do sinal central de 100% para 7,7% — o tier é parte do desenho, não detalhe de
  execução.
- **Economia unitária mede o custo variável de UMA unidade ativa**, com preços reais de
  tabela, no tier que passou nos testes de qualidade, e por um mês simulado — incluindo o
  mês de onboarding como pior caso. Custo apurado sob assinatura, crédito ou ambiente
  subsidiado responde outra pergunta.
- **Proveniência na medição.** Cada resultado carrega de onde veio (script, versão, lote,
  modelo). É o que permite purgar cirurgicamente e re-medir quando um defeito aparece.

### Correção estrutural é achado de primeira classe

Testes desenhados para falsear premissas encontram defeitos que nenhuma revisão de código
encontra: chaves naturais que não existem no mundo real, identidades que colidem entre
contextos, idempotência quebrada por um campo volátil, heurística que classifica pelo nome
do arquivo. Numa POC real, as **12 correções estruturais** foram o produto principal — mais
valiosas que os 6 critérios aprovados.

Para cada uma registre: o defeito com o dado real que o expôs, a correção aplicada, o
re-teste, e a **recomendação para o sistema real**. Se a correção mudou o resultado do
aceite, o relatório mostra os dois números, antes e depois.

---

## Receitas por tipo de incógnita

| Incógnita | O que rodar | O que registrar |
|---|---|---|
| Fidelidade de extração/transformação | amostra adversarial + ground truth manual, item a item | taxa de erro **por classe de entrada** e por campo; quantos itens conferidos visualmente |
| Concordância semântica / classificação | dois caminhos independentes + adjudicação dos desacordos | concordância bruta **e** acurácia adjudicada; a natureza dos desacordos (muitos são defeito do rótulo, não do classificador) |
| Poder estatístico / convergência | simulação com verdade conhecida sob o tráfego realmente projetado | curva por volume; qual alavanca move o resultado e qual não move |
| Economia unitária | bottom-up com preços reais, um mês de uma unidade ativa | típico e pior caso; % do menor preço da tese |
| Regime contínuo | cron/timer por N dias sem intervenção, dashboard de 3–5 métricas | intervenções manuais não planejadas (o aceite é a **ausência** delas); fila humana por dia; o que o dia 1 quebrou |
| Dependência externa/legal | memorando de perguntas objetivas + segunda opinião adversarial | risco classificado, mitigação escrita e o **requisito de arquitetura** que decorre |
| Percepção humana / desejabilidade | ver `humanos-e-substitutos.md` | componente objetivo **e** subjetivo, separados |

---

## §Relatório — esqueleto obrigatório

Grave em `docs/desarmar/resultados/<slug>.md`:

<esqueleto-relatorio>
# Teste {N} — {título} — Resultados

> Executado em {datas}, sobre {dados reais / simulação}. Reprodutível em `{caminho}`.
> Premissa sob teste: "{afirmação falsificável}".
> Aceite pré-registrado em {data de congelamento}: {texto literal do plano}.
> Reprova se: {texto literal do plano}.

## O que rodou
Amostra real (n e composição, com as substituições e o porquê) · ground truth e como foi
estabelecido · comandos, scripts e caminhos · modelo/tier e versão · período.

## Dados medidos
Tabela agregada + **tabela por classe de entrada**. Números crus antes de qualquer
interpretação.

## Aceite, critério a critério
| Critério pré-registrado | Medido | Passou? |
|---|---|---|
| {texto literal} | {número} | ✅ / ⚠️ no fio / ❌ |

## Fronteira de validade
Onde vale, com número. Onde **não** vale, com número. Que condição precisa ser verdadeira
para o resultado se sustentar em produção.

## Achados colaterais e correções estruturais
Defeito → dado real que o expôs → correção → re-teste → recomendação para o sistema real.

## Custo e prazo
Orçado {X} × real {Y}, por etapa. Tokens, chamadas, horas de conferência manual.

## O que este teste NÃO prova
Explícito. Camadas não tocadas, regimes não exercitados, populações não representadas.

## Veredicto proposto
{um dos cinco do vocabulário fechado} — uma frase de justificativa com o número que decide.
</esqueleto-relatorio>

---

## §Auditoria — contexto limpo sobre o que passou

Todo critério **aprovado** é auditado por um agente que não viu a execução. A auditoria roda
em Opus, em subagente novo, e é onde a rodada mais se paga: num caso real ela reprovou um
critério que os números agregados davam por aprovado (recall real de 7,7%), desfez uma
conclusão de "omissão confirmada" que era artefato da fonte, e validou o modelo de dados com
varredura completa.

<brief-modelo-auditor>
Você audita, de forma adversarial, um critério de aceite que foi dado como aprovado em
{PROJETO}. Sua tarefa é reprová-lo se ele for reprovável.

CONTEXTO E MOTIVAÇÃO
Este critério vai autorizar {decisão que ele destrava}. Aprovações falsas são o modo de
falha mais caro deste processo, porque a confiança conquistada aqui será transferida para
camadas que ninguém mediu. Encontrar um problema agora vale mais do que confirmar o
resultado. Você não viu — e não deve procurar — o raciocínio de quem executou.

DADOS
1. {abs}/docs/desarmar/plano-de-testes.md §{teste} — o aceite pré-registrado, literal.
2. {abs}/docs/desarmar/resultados/{slug}.md — o relatório, seções "O que rodou" e "Dados
   medidos".
3. {caminhos dos dados brutos, saídas do sistema e ground truth}

INSTRUÇÕES
Refaça a medição pelo caminho mais independente que os dados permitirem. Ataque nesta ordem:
a métrica mede o que o critério afirma, ou mede um proxy que passa mais fácil? O denominador
está certo — o que ficou fora da conta? A amostra cobre as classes que o plano prometeu? O
ground truth é mesmo independente do sistema? O agregado esconde uma classe com desempenho
inaceitável? Existe um caso plausível, dentro do escopo declarado, que o sistema erra?
Construa esse caso e rode.
Cobertura completa com rótulo de confiança por achado — alta, média ou baixa. Não filtre por
severidade; filtrar é trabalho de quem consolida.

CONTRATO DE SAÍDA
Devolva em ≤ 400 palavras: **MANTÉM** ou **REPROVA** o critério; para cada achado, o número
que o sustenta e o caminho do dado; e a métrica recalculada pelo seu caminho independente,
lado a lado com a reportada. "Refiz por caminho independente e o número bate" é resultado
válido e valioso — diga isso claramente quando for o caso.

LIMITES
Não edite o relatório nem nenhum arquivo do projeto. Não proponha redesenho de produto: seu
escopo é a validade da medição.

CRITÉRIOS DE SUCESSO
Você recalculou pelo menos uma métrica por caminho independente; inspecionou manualmente ao
menos {N} casos, incluindo os da classe de pior desempenho; e nomeou explicitamente a
hipótese de amostra fácil, confirmando-a ou descartando-a com dado.
</brief-modelo-auditor>

Quando a auditoria reprova: rode o ciclo de correção, re-teste, e grave a **trajetória** no
relatório — reprovou com X, corrigiu com Y, passou com Z. A trajetória é a lição
transferível; só o número final não ensina nada.

---

## Anti-padrões de execução

1. **Completar o aceite depois de ver os dados.** Se o plano estava incompleto, ele volta ao
   portão de D0 antes de rodar — nunca depois.
2. **Trocar a métrica no meio.** Métrica que muda durante a execução é métrica escolhida pelo
   resultado.
3. **Amostra da conveniência.** O que estava na pasta, o que a API devolve por padrão, os 10
   primeiros. Composição declarada ou nada.
4. **Erro médio como veredicto.** Sem quebra por classe não há fronteira de validade.
5. **Ground truth contaminado.** Rótulo gerado pelo mesmo modelo, gabarito derivado da mesma
   heurística, revisor que viu a saída do sistema antes de julgar.
6. **Silenciar o desvio.** Toda diferença entre o plano e o que foi possível fazer vira nota
   "Desvio do plano", com o efeito sobre a validade.
7. **Construir o produto sob nome de POC.** Se o teste começa a exigir metade do sistema,
   pare e reporte: o desenho está errado ou o premortem virou autorização para começar.
8. **Descartar o código do teste sem colher as recomendações.** O código é descartável; as 12
   correções que ele revelou, não.

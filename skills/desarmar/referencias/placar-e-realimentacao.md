# Placar, realimentação e fechamento do ciclo

Lido por quem orquestra, em D4 (atribuir veredictos e escrever o placar) e D5 (devolver os
números ao dossiê e disparar as decisões pré-comprometidas).

---

## Atribuir o veredicto — os casos que confundem

O vocabulário é fechado: cinco veredictos, nenhum inventado, nenhum adjetivo no lugar de um
deles. A atribuição é sua, depois da auditoria; o executor apenas propõe.

| Situação medida | Veredicto |
|---|---|
| Todos os critérios conjuntos passaram, com folga, e a auditoria manteve | **DESARMADA** — com a fronteira de validade escrita: onde vale e onde não vale, com número |
| Passou o critério de qualidade, reprovou o de cobertura (ou vice-versa) | **DESARMADA COM CONDIÇÕES**, se a condição que faltou vira requisito exequível; **CONFIRMADA** se o critério que reprovou é o que sustentava a tese |
| 79,7% contra aceite de 80% | **DESARMADA COM CONDIÇÕES**. "No fio" nunca vira aprovação; a condição é o que compensa a margem |
| Passou porque uma decisão de desenho o sustenta (dedupe, ontologia, guarda, tier de modelo) | **DESARMADA COM CONDIÇÕES**, e a decisão vira requisito nomeado do sistema real |
| Reprovou, e o teste mediu qual alavanca resolve | **CONFIRMADA, COM ROTA DE SAÍDA QUANTIFICADA** — o resultado de maior valor. Traga a alavanca com número e a decisão de desenho que decorre |
| Reprovou e nenhuma alavanca testada resolve | **CONFIRMADA** — e o texto diz o que foi testado e não resolveu (isso poupa a próxima rodada). Escale ao humano: é decisão de matar ou redesenhar |
| Passou no dia 1 de um teste de duração de 14 dias | **EM CURSO** até a data de leitura. Um dia não mede regime contínuo |
| Simulação rodou no lugar de humanos | **PENDENTE, COM SUBSTITUTO DECLARADO** — salvo quando a simulação achou falha estrutural, aí é CONFIRMADA (ver `humanos-e-substitutos.md`) |
| O teste não rodou por falta de dado, acesso ou ground truth | Continua **PENDENTE**, com o bloqueio nomeado, dono e marco. Não existe veredicto sem medição |

Dois erros a evitar na hora de escrever: **veredicto sem número** (o veredicto é o rótulo, o
número é a prova — a linha carrega os dois) e **veredicto que descreve o esforço** ("testado
extensivamente") em vez do resultado.

---

## Esqueleto do placar

`docs/premortem/placar.md` (ou `docs/desarmar/placar.md` quando não há premortem):

<esqueleto-placar>
# Placar contra o premortem

> Rodada de {datas}. Testes que não exigem terceiros foram **executados e medidos**
> ({como: scripts, subagentes, simulação}); os que exigem ficaram pronto-para-disparar.
> Artefatos reproduzíveis em `{caminho}`. Relatório por teste em `docs/desarmar/resultados/`.

| # | Falha do premortem | Veredicto medido |
|---|---|---|
| 1 | {título da falha, com a marca de letalidade} | **{VEREDICTO}** — {os números que decidem} · {fronteira de validade ou alavanca quantificada} · [relatório]({caminho}) |

## Bugs reais encontrados e corrigidos no caminho
1. **{defeito}** — {o dado real que o expôs} → {correção} → {estado após re-teste}.

## Decisões de arquitetura que os testes cravaram
- **{decisão}** — {qual teste a cravou e com qual número}; {o que ela obriga no sistema real}.

## O que continua com o humano
{Reclassificado de bloqueio para validação pré-lançamento, ou mantido como bloqueio.}
1. **{item}** — dono {nome}, marco {quando}, instrumento pronto em `{caminho}`.

## Custo da rodada
Orçado {X} × real {Y}, por teste. {Tokens, chamadas de API, horas de conferência manual.}
</esqueleto-placar>

A linha do placar é lida por alguém que não vai abrir o relatório. Ela precisa carregar a
conclusão com os números — "**DESARMADA** — 960 questões reais, 4 fontes: 0% de erro no
campo crítico (316 itens conferidos visualmente); fronteira: só vale no formato sequencial,
layouts de duas colunas têm 35–100% de erro e ficam fora do MVP" decide sozinha. "Testes
passaram" não decide nada.

---

## Achados colaterais: por que eles têm seção própria

Testes desenhados para falsear premissas encontram o que nenhuma revisão de código encontra,
porque são a primeira vez que o sistema encosta em dado real adversarial. Numa rodada real,
sete falhas previstas renderam **quatro bugs** e **duas decisões de identidade de dados** que
nenhuma delas antecipava; numa POC anterior, **12 correções estruturais** — chave natural que
não existe antes do documento oficial, colisão de nomes entre estados, identidade de arquivo
contaminada por URL assinada volátil, heurística que classificava tipo pelo nome do arquivo e
acertava 0 de 70.

Isso é resultado esperado, não ruído. Um placar sem achados colaterais sugere que os testes
não encostaram em dado real o bastante.

---

## Realimentação

### No índice de pesquisas (`docs/README.md`, quando existir)

Regra: **número medido supera número estimado, sem apagar o estimado.**

1. Linha nova na seção correspondente, apontando para o relatório do teste, com a conclusão
   **e os números** — o mesmo padrão de resumo de uma frase do índice.
2. **Estado da decisão** reescrito no topo: o que estes testes fecharam, o que abriram, e o
   que continua em aberto com o teste que o fecha.
3. **Caveat cruzado** no cabeçalho de todo documento que o teste superou, no formato
   *"os números de custo deste documento foram medidos em {data} pelo teste {N}: {novo
   número} contra {antigo}; os mecanismos seguem válidos"*. Não reescreva em silêncio e não
   delete: o histórico de por que a equipe pensava X importa quando alguém questionar a
   decisão daqui a seis meses.
4. Quando um teste desmente uma premissa de alta letalidade do dossiê, ela sai da lista de
   premissas críticas e entra como fato medido, com a fronteira de validade junto.

### Nas decisões em aberto (`docs/decisoes-em-aberto.md`)

Feche as que o teste resolveu, citando o número e a data. As que continuam abertas ganham o
motivo — "o teste rodou e não discriminou", "depende de terceiros", "custo maior que o valor
da informação" — porque decisão que continua aberta sem motivo volta a ser discutida do zero.

### Nas decisões pré-comprometidas

O ramo já estava escrito antes do número existir. Aplique-o como decisão tomada e registre:
qual ramo disparou, o que ele obriga agora, e o que deixou de ser possível. O valor inteiro
do pré-compromisso está em não reabrir a discussão depois de ver o dado — é exatamente aí que
o número ruim seria racionalizado.

### No handoff para a implementação

O que sai desta rodada como **decisão já tomada**, e portanto não é re-perguntado pela skill
`decidir-antes`: as condições das DESARMADAS COM CONDIÇÕES, os redesenhos das CONFIRMADAS, as
decisões de arquitetura cravadas pelos testes, e as fronteiras de validade que definem o
escopo do MVP (o que entra é o que foi medido funcionando; o resto tem data, não promessa).

---

## O ciclo está encerrado quando

- [ ] Cada falha do premortem tem **veredicto medido** com vocabulário fechado — ou está
      listada como PENDENTE com bloqueio, dono e marco nomeados.
- [ ] Cada **DESARMADA** traz a fronteira de validade com número, não apenas o "passou".
- [ ] Cada **CONFIRMADA** traz a alavanca quantificada e a decisão de desenho que decorre.
- [ ] Cada critério aprovado passou por **auditoria de contexto limpo**, e o resultado da
      auditoria está registrado — inclusive os "refiz por caminho independente e bate".
- [ ] Nenhum aceite foi alterado depois do congelamento; os desvios do plano estão escritos
      com o efeito sobre a validade.
- [ ] **Achados colaterais** e **correções estruturais** estão registrados com o dado real que
      os expôs e a recomendação para o sistema real.
- [ ] **Custo e prazo reais** aparecem contra o orçado, por teste.
- [ ] Cada decisão pré-comprometida foi **executada** e o que ela obriga está escrito.
- [ ] Os números voltaram ao índice de pesquisas e às decisões em aberto, com os caveats
      cruzados nos documentos superados.
- [ ] O que continua com o humano está explicitamente classificado como **bloqueio** ou
      **validação pré-lançamento** — nunca deixado ambíguo.

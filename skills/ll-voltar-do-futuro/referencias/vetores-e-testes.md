# Vetores de ataque, testes desarmadores e letalidade

Material de geração do premortem `ll-voltar-do-futuro`. Lido pelos narradores da F1 e pelo
orquestrador nas fases F2 e F3.

---

## Os 12 vetores de ataque

Checklist para cobrir o espaço de falha, **não texto a copiar**. Cada vetor é um gerador:
aplique-o à zona de ataque do dossiê da F0 e veja o que aparece. Um narrador que cobre 3
vetores distintos produz mais que um que aprofunda um só.

1. **Transferência de confiança entre camadas.** Validou A com rigor, assumiu B por
   contiguidade. *"Transferimos a confiança da POC de ingestão para um domínio declarado
   explicitamente fora de escopo."* É o vetor dominante quando existe uma camada bem
   auditada — procure primeiro o que faz fronteira com ela.

2. **Métrica proxy que passa vs. métrica que importa.** Mediu *cobertura*, precisava de
   *utilidade*. Mediu *latência*, precisava de *conversão*. Mediu *acurácia média*,
   precisava de *pior caso na classe que paga*. Pergunta geradora: se essa métrica ficasse
   perfeita, o produto passaria a funcionar? Se não, ela é proxy.

3. **Condição de contorno da evidência importada.** O estudo, benchmark ou blog post citado
   vale sob condições que não são as suas — outro n, outro regime de tráfego, outro tipo de
   usuário. *"Lemos a citação, não a condição de contorno."* Procure toda frase do tipo "a
   literatura mostra que" e vá atrás da amostra do estudo.

4. **Identidade e chave entre contextos.** O que parece a mesma entidade em dois lugares não
   é: nada se reaproveita, todo caso novo é cold start, e o dado acumulado não compõe.
   Pergunta geradora: qual é a chave primária real que liga os contextos? Existe? Quem a
   garante?

5. **Mudança de regime.** Provado em lote, máquina única, 2 dias; a operação real é contínua,
   concorrente, por meses. Idempotência de replay sequencial vira race condition; o cron que
   nunca falhou em 48h acumula deriva em 6 semanas.

6. **Economia unitária medida no ambiente errado.** Custo apurado sob assinatura, crédito
   promocional, ambiente subsidiado ou custo fixo amortizado — quando o que decide o negócio
   é **custo variável por unidade ativa a preço real**, no tier de qualidade que passou nos
   testes, não no mais barato.

7. **Subdeterminação estatística.** Prometer resolução que a matemática não dá: n respostas
   para m tópicos com m ≫ n; modelo que "converge com poucos dados" mas por *item*, não por
   *usuário*; segmentação com célula de 3 pessoas. Faça a conta antes de escrever a falha —
   o número é a falha.

8. **Viés de disponibilidade na amostra.** Mediu as fontes fáceis e chamou de "as fontes".
   A cauda ignorada costuma ser a maioria do mercado. Pergunta geradora: qual fração do
   universo real a amostra medida representa, em porcentagem?

9. **Dependência tratada como checkbox, não como arquitetura.** Parecer jurídico,
   compliance, contrato de dados, proveniência, LGPD, licença de terceiro: coisas cuja
   resposta **muda o desenho** e que são impraticáveis de retrofitar. Um item de dependência
   agendado para "antes do lançamento" que deveria estar em "antes do modelo de dados" é
   quase sempre uma falha do TOP 3.

10. **Plano B nunca avaliado.** A rota de fuga existe no papel e nunca teve eval; quando foi
    preciso, era pior que o plano A e ninguém sabia. Pergunta geradora: o que acontece se a
    aposta principal cair? Alguém já mediu a alternativa?

11. **Falha silenciosa.** O sistema não quebra: apodrece. Fila cresce, qualidade decai, custo
    sangra, e ninguém tem o dashboard que mostraria. É o vetor mais letal por consumir runway
    antes de aparecer.

12. **Presságio ignorado.** Um defeito já observado num contexto de baixo risco (alucinação
    num campo secundário, flake num teste periférico) reaparece no dado mais sensível do
    produto. Vasculhe as seções de "correções aplicadas" e "problemas encontrados" dos
    artefatos: cada uma é um presságio catalogado.

---

## Anatomia de um teste desarmador — 8 componentes

Faltando qualquer um, o teste não desarma nada.

1. **A afirmação falsificável.** A premissa que morre se o teste reprovar, em uma frase, no
   presente do indicativo: *"o pipeline extrai gabarito com fidelidade suficiente para um
   produto de precisão"*. Se você não consegue escrever a frase, não entendeu a falha.

2. **A amostra mínima adversarial.** Não a representativa: a **desenhada para quebrar** —
   os formatos raros, a banca esquisita, o caso com retificação, o usuário fora do perfil.
   Amostra fácil produz aprovação falsa, e aprovação falsa é **pior** que não testar, porque
   compra confiança.

3. **Ground truth independente do sistema testado.** Gabarito oficial digitado à mão; dois
   revisores humanos com adjudicação do desacordo; ou um **critério externo** que mede
   validade preditiva (desempenho posterior nos tópicos classificados "ok" vs "lacuna"). Sem
   verdade independente, você está medindo o sistema contra si mesmo.

4. **O critério de aceite numérico, pré-registrado.** Número, unidade e direção, escritos
   **antes** de rodar. Modelos que funcionam: *"erro de gabarito < 0,1%, erro de enunciado
   < 1%, e detecção de 100% das retificações da amostra"*; *"≥ 95% de concordância
   questão→nó e mapa de equivalência cobrindo ≥ 80% dos nós comuns"*; *"delta ≥ 20 p.p. e
   ≥ 7/10 participantes reconhecem o resultado"*; *"COGS/unidade ≤ 30% do menor preço da
   tese"*; *"zero intervenção manual não planejada e fila humana < 15 min/dia"*.
   Note o padrão: **critérios conjuntos** — um de qualidade, um de cobertura, um de operação
   — porque um único número quase sempre tem um jeito trivial de passar.

5. **O teste do teste: escreva o resultado que reprova.** Antes de rodar, redija "este teste
   reprova se ___". Se nenhum resultado plausível reprova, o critério está frouxo e o teste
   é cerimônia. **O valor do teste é proporcional à sua probabilidade a priori de falhar.**

6. **Prazo e custo declarados.** *"5 dias, centavos de API + 2 dias de conferência."* Teste
   sem orçamento explícito vira projeto. Teste que custa mais de 1–2 semanas ou que exige
   construir o produto **não é teste, é o produto com outro nome** — e quase sempre existe
   uma versão de mesa (simulação, planilha, amostra de 30, script) que ataca a mesma
   premissa.

7. **A decisão pré-comprometida nos dois ramos.** O "se… então…" escrito **antes** de ver o
   número: *"se o delta for < 10 p.p., o diagnóstico curto não discrimina e o produto precisa
   ser redesenhado — diagnóstico contínuo, não teste inicial"*; *"se equivalência < 80%, o
   modelo de domínio precisa de ontologia canônica antes do MVP"*. Sem pré-compromisso, o
   número ruim é racionalizado no dia seguinte.

8. **A precedência.** O que este teste bloqueia: *"rodar antes de decidir preço, não
   depois"*, *"antes de sistematizar"*, *"antes de uma linha de código"*. Um teste que roda
   depois da decisão que deveria informar não é teste, é autópsia.

---

## Padrões de teste barato por tipo de incógnita

- **Fidelidade de extração/transformação** → amostra adversarial + ground truth manual +
  taxa de erro **por classe de entrada** (revela a fronteira de validade, não só a média).
- **Concordância semântica / classificação** → duplo caminho independente + adjudicação
  humana dos desacordos; mede concordância **e** acurácia adjudicada. Bônus frequente: o
  padrão de teste vira o padrão de produção ("duplo caminho + juiz nos ~9% de desacordo").
- **Poder estatístico / convergência** → simulação com verdade conhecida (agentes sintéticos
  de proficiência conhecida contra itens de dificuldade conhecida) sob o tráfego realmente
  projetado. Custa 2 dias e responde o que 6 meses de produção responderiam.
- **Economia unitária** → bottom-up com preços reais, simulando um mês de **uma** unidade
  ativa, usando o tier de qualidade que passou nos testes.
- **Regime contínuo** → rodar o pipeline em cron por N dias corridos sem intervenção, com
  dashboard de 3–5 métricas, e o aceite formulado como **ausência de trabalho humano não
  planejado**.
- **Dependência externa/legal** → memorando de perguntas objetivas + segunda opinião
  adversarial; aceite = "risco classificado e mitigação escrita"; a saída esperada é um
  **requisito de arquitetura**, não um parecer arquivado.
- **Percepção humana / desejabilidade** → 5 a 10 pessoas reais fora do time; aceite com
  componente objetivo (desempenho, taxa de detecção) **e** subjetivo (n/10 concordam).

---

## Quando o teste exige terceiros indisponíveis

Substituir humanos por **simulação de personas** é legítimo como ponte, com três salvaguardas
obrigatórias:

- O perfil simulado fica **oculto do instrumento** testado — a persona responde em caráter;
  quem avalia não vê o gabarito do perfil.
- O que a simulação **prova** e o que ela **não prova** vai escrito no resultado. Ela prova
  propriedades aritméticas e estruturais do instrumento (num caso real, revelou que um acerto
  por chute em item verdadeiro/falso certificava domínio — falha aritmética, válida também
  para humanos, cuja correção derrubou o falso-positivo de 34% para 12%). Ela **não** prova
  percepção subjetiva nem a estrutura real do conhecimento humano.
- O item permanece no placar como **PENDENTE, COM SUBSTITUTO DECLARADO** — rebaixado de
  *bloqueio* para *validação pré-lançamento*, com o instrumento já corrigido e pronto para
  disparar.

---

## Os 5 fatores de letalidade

Multiplicativos na prática. Use-os para justificar a ordem, por escrito, na F3.

1. **Mata ou machuca?** Letal = invalida a tese central de valor, torna o produto ilegal,
   destrói reputação de forma irrecuperável, ou inverte a economia unitária. Não-letal =
   atrasa, encarece, irrita. **Atraso não é letalidade.**

2. **Custo de retrofit / irreversibilidade.** Falha cuja correção exige refazer modelo de
   dados, ontologia, proveniência ou contrato com terceiros é mais letal que outra de mesma
   probabilidade corrigível com patch. "Impraticável de retrofitar" promove a falha ao TOP 3
   quase sozinho.

3. **Centralidade de dependência.** Quantas decisões futuras dependem dessa premissa? A que
   sustenta o esquema de indexação de tudo é mais letal que a que sustenta uma tela.

4. **Probabilidade dado o não medido.** Não é a probabilidade a priori: é a probabilidade
   **condicionada ao fato de que ninguém olhou**. Camadas nunca observadas herdam a taxa-base
   pessimista da referência externa — a *outside view*: qual a taxa histórica de fracasso
   desse tipo de coisa em outros projetos? (Referência dura: ~92% dos megaprojetos estouram
   prazo, orçamento ou ambos; sobrecustos médios de 20% a 45% por classe, estáveis há 70
   anos.)

5. **Tempo até a detecção.** Falha silenciosa — apodrecimento, deriva de qualidade, custo que
   sangra — é mais letal que falha barulhenta, porque consome runway antes de aparecer.

---

## Exemplo trabalhado de uma falha completa

Extraído de um premortem real (produto de estudo para concursos públicos, cuja POC auditara
com rigor apenas a camada de ingestão de editais). Use-o para calibrar densidade, cena e tom
de veredicto — não para copiar conteúdo.

<exemplo>
## ☠️ 1. O banco de questões nunca existiu — e um gabarito trocado nos matou em público *(TOP 3)*

**(a)** Lançamos com extração LLM de provas em PDF sem nunca ter medido acurácia de
gabarito. No 3º mês, um thread viral no r/concursos mostrou 4 questões Cebraspe com gabarito
invertido no app — o aluno estudou a resposta errada. Para um produto cujo slogan é "décimo
por décimo", foi morte reputacional instantânea.
**(b)** `fontes-de-questoes-e-editais.md` já avisava: "risco de erro de extração (gabarito
trocado é falha grave de produto — exige validação)" — mas a POC validou *editais* e
comemoramos como se fosse o pipeline inteiro. A correção nº 7 da POC (modelo barato
alucinando uma sigla com confiança 0,9) era o presságio: alucinação em dado derivado, agora
no dado mais sensível do produto. Viés: transferimos a confiança da POC de ingestão para um
domínio declarado explicitamente "fora de escopo / arquivamento incidental".
**(c)** POC de 5 dias: extrair 500 questões reais (3 bancas distintas, 2 formatos de questão,
1 prova com gabarito retificado pós-recurso), cruzar contra gabarito oficial definitivo
digitado à mão. **Aceite: erro de gabarito < 0,1% (idealmente zero), erro de
enunciado/alternativa < 1%, e detecção de 100% das retificações da amostra.** Reprova se
qualquer gabarito da amostra sair invertido. Custo: centavos de API + 2 dias de conferência.
Se reprovar, o banco de questões não entra no MVP por extração automática — vira curadoria
manual ou licenciamento. Bloqueia qualquer lançamento com questões.
</exemplo>

Repare no que faz a falha funcionar: a cena tem canal (thread no Reddit), data (3º mês),
número (4 questões) e dano de negócio (morte reputacional), não só o defeito técnico; a
citação é literal e traz o arquivo; o viés tem nome; o aceite tem três critérios conjuntos; e
a decisão de reprovação é uma mudança de produto, não um "vamos investigar".

E na síntese que fechou esse mesmo documento — o modelo do que a F4 deve produzir: *"morreu
de uma assimetria — rigor adversarial na camada de ingestão e fé bibliográfica em todo o
resto. Os três testes que teriam nos salvado custavam juntos menos de duas semanas e teriam
sido feitos antes de uma linha de código. A regra que faltou: nenhuma camada entra no roadmap
sem a sua própria auditoria que reprova primeiro."*

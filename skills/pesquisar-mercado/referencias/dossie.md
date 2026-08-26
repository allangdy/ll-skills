# O dossiê, documento por documento

Quem monta o escopo lê a visão geral, a tabela de dossiê mínimo e — se o trabalho for uma feature de um sistema que já existe — a seção **Modo feature**, ao fim. Quem pesquisa lê **apenas a seção do seu documento** — ler as outras é ancoragem.

---

## Visão geral e ordem de execução

O dossiê tem três anéis. Nem todo projeto precisa dos três, mas a ordem entre eles é fixa porque cada anel usa o anterior como insumo — com uma exceção deliberada: o anel de preço começa em isolamento.

```
ANEL 1 — Existe alguém? (desejabilidade)
  1. Mercado e público          ─┐
  2. Dores, jobs e comportamento │ rodam em paralelo
  3. Análise de concorrentes    ─┘

ANEL 2 — Dá para cobrar? (viabilidade)      ANEL 3 — Dá para construir? (exequibilidade)
  4. Panorama de preços (isolado, sem âncora)  6. Viabilidade técnica / método
  5. Estratégia de preço e conversão           7. Fontes de dados e insumos
     (força de evidência obrigatória)          8. Economia unitária / custo de servir
                                               9. Restrições legais e regulatórias
                                              10. Canais de aquisição

SÍNTESE
 11. Decisões em aberto + plano de teste empírico
 12. (após premortem) POCs e resultados medidos
```

Regras de sequência:

- **1–3 antes de 5.** É preciso saber quem é o público e quanto ele gasta hoje antes de discutir preço.
- **4 antes de 5, e 4 sem contato com nenhuma tese de preço interna.** O doc 4 pode rodar já na primeira onda, justamente porque não depende de nada.
- **O anel 3 roda em paralelo ao anel 1**, exceto o doc 8, que depende de 6 e 7 para ter números.
- **11 é escrito por último e reescrito** sempre que qualquer documento muda uma conclusão.
- **12 só existe depois do premortem** — POC sem hipótese de falha é demonstração, não teste.

---

## 1. Mercado e público

**Propósito:** estabelecer que existe um público grande o bastante, alcançável, com dinheiro e com o problema — e dimensionar isso sem inflar.

**Perguntas que responde:**

- Qual o tamanho do mercado em três camadas (TAM / SAM / SOM), calculado de **duas formas independentes**?
- Quantas pessoas ou empresas existem no recorte, e qual a diferença entre **unidades de consumo e pessoas únicas** (inscrições ≠ inscritos; contas ≠ usuários)?
- Quem é o usuário típico: demografia, ocupação, restrição de tempo, restrição de renda, nível de sofisticação?
- **Quanto essa pessoa já gasta hoje** resolvendo o problema por qualquer meio, e como esse gasto se distribui? (A média engana; use a distribuição.)
- Qual o **beachhead** — o subsegmento mais estreito que dá para dominar primeiro?
- Que tendências estruturais (regulatórias, tecnológicas, demográficas) empurram ou puxam a demanda nos próximos 24 meses?

**Frameworks:**

- **TAM / SAM / SOM com top-down e bottom-up cruzados.** Top-down parte de relatório setorial e aplica recortes; bottom-up parte de `nº de compradores alcançáveis × ticket anual`. Convergência dentro de ~15% torna as premissas defensáveis; divergência grande é o achado. Erros clássicos: *vanity TAM* (usar o maior mercado possível), definir SAM/SOM como percentual arbitrário do TAM, e confundir a receita do cliente com o gasto endereçável.
- **Beachhead market, End User Profile, Persona e Decision-Making Unit** (Bill Aulet, *Disciplined Entrepreneurship*, MIT): segmentar, escolher um mercado-cabeça-de-ponte estreito, calcular o TAM **daquele** segmento, perfilar um usuário real. Separe **usuário final** de **unidade de decisão** — quem usa ≠ quem paga ≠ quem aprova; decisivo em B2B e relevante em B2C quando um terceiro financia.
- **Preferência revelada > declarada:** gasto efetivo, abandono e comportamento de compra são evidência mais forte que qualquer intenção.

**Estrutura:**

```
Cabeçalho (data, contexto/escopo)
Resumo executivo (um parágrafo, com os 4–5 números que importam)
1. Tamanho do mercado
   1.1 Movimentação financeira (verificado / projetado / histórico, cada um rotulado)
   1.2 Quantas pessoas existem (e a ressalva de unidade de contagem)
   1.3 Volume e granularidade da demanda (tabela com fontes)
   1.4 TAM / SAM / SOM — cálculo top-down, cálculo bottom-up, e a diferença explicada
2. Perfil do público (demografia, ocupação, renda, rotina, restrições)
3. Quanto o público já gasta (distribuição, não só média)
4. Beachhead proposto e por quê
5. Tendências (12–24 meses)
6. Síntese: achado → implicação
Rodapé: nota de método + limitações da amostra
```

**Armadilha principal:** citar projeção de imprensa como se fosse dado. Toda cifra grande de mercado que circula em portais costuma ser projeção de associação setorial, não número auditado — reporte assim, explicitamente, e triangule com bottom-up.

---

## 2. Dores, jobs e comportamento (voz do usuário)

**Propósito:** provar que a dor existe **fora da sua cabeça**, com evidência que você não fabricou, e entender o que a pessoa faz hoje na ausência do produto.

Em projetos pequenos pode ser uma seção do doc 1; ganha arquivo próprio quando há pesquisa qualitativa real ou mineração de comunidades.

**Perguntas que responde:**

- Qual é a dor nº 1 na linguagem do próprio usuário (citações verbatim, com link)?
- Qual **job** a pessoa tenta cumprir — e que "solução" ela contrata hoje (concorrente, planilha, gambiarra, nada)?
- Quais são as **quatro forças** do switch: empurrão (problema atual), puxão (promessa do novo), ansiedade (medo do novo), hábito (conforto do atual)?
- Que comportamento observável comprova a dor (abandono, gasto, tempo investido, workaround elaborado, conteúdo que o próprio mercado produz sobre o tema)?
- Quanto de esforço e dinheiro a pessoa já queima com a solução ruim?

**Frameworks:**

- **The Mom Test** (Rob Fitzpatrick): fale da vida da pessoa, não da sua ideia; pergunte fatos específicos do passado, nunca hipóteses de futuro; fale menos, ouça mais. Elogio não é dado. "Eu compraria" não é dado. Dado é: o que você fez da última vez, quanto pagou, quanto tempo levou.
- **Switch Interview / Four Forces of Progress** (Bob Moesta & Chris Spiek, JTBD): a decisão acontece quando `empurrão + puxão > ansiedade + hábito`. Cerca de 10 entrevistas bem escolhidas revelam 3–5 padrões de compra que cobrem a maior parte do mercado.
- **Opportunity Solution Tree** (Teresa Torres, *Continuous Discovery Habits*): resultado desejado → espaço de oportunidades → soluções → testes de premissa; impede que a pesquisa pule da dor direto para a feature.
- **Review mining:** app stores (1–3 estrelas são ouro), Reclame Aqui/Trustpilot, fóruns, comentários de vídeo, subreddits, grupos. Agrupe por tema, conte recorrência, cite verbatim com link.

**Estrutura:**

```
Nota de método (o que foi acessível, o que estava bloqueado, o que fica pendente
de coleta manual)
1. Dor nº 1 … n — cada uma com descrição, evidência (citações + links),
   recorrência e proxy comportamental
2. O que a pessoa usa hoje (workarounds, concorrentes contratados "para o job")
3. As quatro forças (empurrão / puxão / ansiedade / hábito)
4. Sinais comportamentais quantificáveis (abandono, gasto, volume de busca,
   conteúdo produzido pelo mercado)
5. O que NÃO foi encontrado e como coletar depois
```

**Armadilha principal:** confundir "o mercado produz muito conteúdo sobre essa dor" com prova da dor. É proxy decente — o mercado só produz conteúdo sobre o que vende — mas deve ser rotulado como proxy. Se uma fonte crítica está bloqueada ao crawler, **diga isso no documento** e agende coleta manual; não substitua por inferência silenciosa.

---

## 3. Análise de concorrentes

**Propósito:** mapear quem já resolve isso e **onde exatamente cada um para**, para achar o espaço estruturalmente desocupado.

**Perguntas que responde:**

- Quem são os concorrentes **diretos** (mesma solução), **indiretos** (solução diferente para o mesmo job), **substitutos** (planilha, humano, gambiarra, não fazer nada) e **entrantes potenciais** (quem tem os dados ou os usuários e pode lançar em 6 meses)?
- Para cada um: proposta de valor, funcionalidades, preço (com fonte e data), pontos fortes e **onde exatamente ele para** — a fronteira concreta que não cruza.
- Qual a **matriz de capacidades**: linhas = players, colunas = as 4–7 capacidades que definem a categoria, células = Sim / Parcial / Não / Alega-mas-não-verificável.
- Onde estão os **vazios** — combinações de capacidade que ninguém entrega?
- Algum vazio é **estruturalmente protegido**, isto é, o incumbente não pode ocupá-lo sem destruir o próprio modelo de negócio? É a forma mais forte de vantagem para um entrante.
- Que movimento de concorrente mataria a tese, e quem é o mais provável de fazê-lo?

**Frameworks:** tipologia de quatro camadas (a mais esquecida e mais letal é o substituto genérico e gratuito — a planilha, o assistente de IA genérico, o "faço na mão"); feature/capability matrix e mapa de posicionamento em dois eixos para achar white space; **Porter — cinco forças** quando o objetivo é a estrutura do setor, não só os players; gap analysis ancorada em **capacidade**, não em feature ("ninguém fecha o loop A→B→C" é achado; "faltam dark mode e exportação" não é); ceticismo com claims de marketing — classifique cada capacidade como *verificada em uso*, *documentada publicamente* ou *apenas alegada em landing page*, porque "adaptativo", "IA" e "personalizado" aparecem sem mecanismo.

**Estrutura:**

```
Resumo executivo (uma frase que nomeia o vazio)
Nota metodológica (data, volatilidade de preços, o que não foi possível confirmar)
1. Concorrentes diretos — um bloco por player:
   proposta de valor · funcionalidades · preço (fonte + data) · pontos fortes · ONDE PARA
2. Concorrentes indiretos (tabela)
3. Nova onda / entrantes recentes (tabela + leitura do segmento)
4. Substitutos e "não fazer nada"
5. Matriz comparativa de capacidades
6. Análise de gaps — cada gap numerado, com o argumento de por que está vago
7. Riscos competitivos a monitorar (quem fecha o gap primeiro, em quanto tempo)
Fontes principais (links por player)
```

**Armadilha principal:** listar features em vez de fronteiras. A pergunta útil nunca é "o que ele tem", é "**o que ele estruturalmente não faz, e por quê**". A segunda é ignorar o concorrente gratuito e genérico que o usuário já usa.

---

## 4. Panorama de preços do mercado — pesquisa independente, sem âncora

**Propósito:** levantar o espectro completo de preços praticados, do grátis ao topo, **sem nenhuma tese de preço em mente e sem recomendar nada**. É o documento anti-viés do dossiê.

**Regra de ouro:** este documento é escrito **antes** de qualquer discussão interna de preço, ou por um agente que **não conhece** a tese de preço da equipe. Se já existe um número na cabeça, ele contamina o que se procura e como se interpreta — ancoragem clássica, e o viés mais caro de uma pesquisa de preço.

**Perguntas que responde:**

- Quantos **degraus de preço simultâneos** o mercado sustenta, e o que cada degrau entrega?
- Qual a evidência de demanda **por degrau** (receita, número de pagantes, listas de espera, longevidade do produto)?
- Qual a disposição a pagar documentada (pesquisas públicas, censos setoriais, dados de gasto) — em **distribuição**, não em média?
- Existe **elasticidade dura documentada** (gente que desistiu por causa do preço, pirataria, rateio, churn por preço)?
- Que **analogias internacionais ou de categorias adjacentes** existem, e qual o múltiplo entre o degrau básico e o premium nesses mercados?
- Onde estão as **lacunas de oferta** — faixas de preço com demanda plausível e pouca oferta? (fato, não recomendação)
- Que **tensões** existem, com evidência forte dos dois lados?

**Frameworks:**

- **Espectro por tiers:** uma seção por degrau, do zero ao topo, com tabela `oferta | o que entrega | preço | fonte`.
- **Métodos de descoberta empírica de preço** — o documento não escolhe o preço, mas **lista os métodos que o escolherão**, com prós, contras e amostra mínima:
  - **Van Westendorp (PSM)** — 4 perguntas (caro demais / caro / barato / barato demais) → faixa aceitável. Barato, padronizado, **não ancora**, funciona sem referência prévia. Limitações reais: mede valor percebido e não comportamento; funciona mal para produtos muito novos que a pessoa não sabe precificar; roda em vácuo competitivo; as curvas ficam instáveis abaixo de ~200 respondentes por segmento (n≈100 serve como direcional). Mitigação: randomizar a ordem das quatro perguntas e nunca revelar limites.
  - **Gabor-Granger** — escada de preços ("compraria por X?") → curva de demanda e ponto de receita máxima. Rápido, mas **ancora por construção**; a escada precisa ser calibrada por um Van Westendorp anterior.
  - **Conjoint / discrete choice** — preço como atributo entre outros; o mais poderoso e o mais caro; só quando preço e features precisam ser otimizados juntos (200–300+ respondentes).
  - **Smoke test / fake door de preço** — landing precificada + tráfego pago, medindo clique e início de checkout por variante. É o único que mede **comportamento**. Limites: mede intenção de clique e não retenção; superestima demanda se a página não mostrar preço; sofre com ruído de curiosidade e tráfego não qualificado; exige tracking limpo e uma tela de revelação honesta ("em desenvolvimento, avisamos você") — fake doors demais queimam confiança.
  - Sequência típica: qualitativo exploratório → Van Westendorp (achar a faixa) → Gabor-Granger ou smoke test (testar pontos dentro da faixa) → conjoint só se necessário.
- **Praticabilidade local:** cite painéis e ferramentas disponíveis no país do público, com custo por resposta, para o teste deixar de ser abstrato.

**Estrutura:**

```
Cabeçalho + "Natureza: mapa neutro de preço × demanda × entrega. NÃO recomenda preço."
Resumo executivo (fatos, sem recomendação)
Nota de método (data, legenda, limitações de acesso, política sobre preços promocionais)
1. Espectro completo, tier por tier (tabelas com fonte por linha)
2. Evidência de demanda por tier
3. Disposição a pagar (melhor dado público + distribuição + segmentação + os dois
   lados da sensibilidade)
4. Analogias internacionais / categorias adjacentes (múltiplos entre tiers)
5. Métodos para descobrir o preço empiricamente (tabela comparativa + sequência)
6. Síntese neutra: mapa preço × demanda × densidade de oferta; lacunas observadas
   (fatos); tensões documentadas
Anexo: o que foi procurado e NÃO encontrado
Rodapé: validade dos preços (voláteis — reverificar antes de decidir)
```

**Armadilha principal:** deixar escapar uma recomendação. "O ideal seria posicionar em X" invalida a independência do documento. A recomendação vive no doc 5 e a decisão vive no doc 11.

---

## 5. Estratégia de preço, conversão e retenção — com força de evidência

**Propósito:** reunir os mecanismos de precificação, funil e retenção aplicáveis, **classificando cada um pela força da evidência que o sustenta**, e propor arquiteturas alternativas em vez de uma resposta única.

Depende do doc 4, que deve ser lido antes de escrever.

**Perguntas que responde:**

- Que mecanismos de psicologia de preço se aplicam, e **quais deles realmente replicam**?
- Qual o comparável correto do produto, e qual serve apenas de **âncora** e não de comparável?
- Que particularidades locais de pagamento, cobrança e cultura de parcelamento afetam a conversão?
- Quais são os benchmarks de conversão e churn da categoria, e qual a **qualidade da fonte** de cada um?
- Que arquiteturas de preço e funil são viáveis, com prós e contras de cada uma?
- O que precisa ser testado por A/B, em ordem de prioridade, e **qual métrica decide** cada teste?
- Que práticas são ética ou legalmente vedadas (dark patterns), e qual o dano documentado delas?

O mecanismo central deste documento é a classificação FORTE / MODERADA / FRACA / HIPÓTESE / REFUTADO — ver `padroes-de-pesquisa.md` §3. Cada subseção **abre** com "Evidência: X".

**Estrutura:**

```
Cabeçalho + escopo + resumo executivo que já antecipa o que é forte e o que é frágil
1. Mecanismos de preço — um por subseção, cada um abrindo com a força da evidência
2. O modelo de funil em discussão: o que se sabe de verdade (rótulo de qualidade
   da seção inteira)
3. Comparáveis e âncoras de mercado (tabela de preços de referência + leituras)
4. Particularidades locais (pagamento, cobrança, sazonalidade de renda,
   churn involuntário)
5. Gatilhos por força de evidência (tabela FORTE / MODERADA / FRACA-ou-arriscada)
6. Dark patterns a evitar, com dano documentado
7. Duas ou três arquiteturas alternativas, cada uma com tabela prós × contras
8. O que testar via A/B, em ordem de prioridade, com a métrica que decide cada teste
Lacunas de dados (o que NÃO foi encontrado)
```

**Armadilha principal:** apresentar uma única arquitetura recomendada. Apresente 2–3 e deixe o teste decidir; o documento entrega o **espaço de opções instrumentado**, não a escolha.

---

## 6. Viabilidade técnica / método

**Propósito:** responder se o núcleo técnico da proposta é alcançável no MVP, com que técnica, e qual degrau de qualidade exige uma escala que ainda não existe.

**Perguntas:** qual a técnica mínima que entrega o valor prometido? o que a literatura e o estado da arte dizem sobre ela? o que precisa de volume de dados que só existe depois? qual a rota de upgrade (MVP → versão robusta) e o gatilho quantitativo dela? o que a concorrência usa?

**Estrutura:** problema técnico → opções (com respaldo, custo e requisito de dados) → escolha para o MVP → o que fica como upgrade e sob que gatilho → riscos.

**Armadilha:** escolher a técnica mais sofisticada e descobrir tarde que ela precisa de N observações por item que só existirão em 18 meses. Declare o **requisito de dados de cada técnica** explicitamente.

---

## 7. Fontes de dados e insumos

**Propósito:** descobrir se a matéria-prima do produto existe, é acessível e é legal — **empiricamente, testando de verdade**.

**Perguntas:** existe API, dataset aberto, ou é preciso pipeline próprio? os endpoints respondem (teste!)? que formato os dados têm de fato (baixe amostras reais)? quanto custa processar uma unidade? quem bloqueia bots, quem tem WAF, que URLs quebram? qual a zona legal de cada fonte?

Esta pesquisa é empírica sempre que possível: endpoints chamados de verdade, arquivos reais baixados e processados, custo real medido em centavos por unidade. Uma pesquisa de fonte de dados feita só por leitura de documentação erra em cerca de metade dos pontos operacionais.

**Estrutura:** mapa de fontes (tabela `fonte | acesso testado | formato | papel | risco`) → resultados dos testes → zonas legais → custo medido por unidade → riscos operacionais nomeados (bloqueio, retificação, mudança de URL, formato heterogêneo).

**Armadilha:** confiar na documentação em vez de testar; e não separar "é tecnicamente possível" de "é legalmente utilizável".

---

## 8. Economia unitária / custo de servir

**Propósito:** saber quanto custa atender **um** usuário por mês antes de discutir preço a sério, porque isso define quais teses de preço são sequer possíveis.

Depende de 6 e 7.

**Perguntas:** qual o COGS por usuário/mês nos cenários pessimista e otimizado? o que domina o custo? quais alavancas de redução existem (cache, modelo menor, batch, pré-processamento) e quanto cada uma vale? qual a margem bruta de cada tese de preço nos dois cenários? qual o custo de aquisição plausível pelos canais do doc 10, e qual o payback?

**Framework:** **reverse income statement** (McGrath & MacMillan): comece pelo lucro desejado, derive a receita necessária, derive os custos permitidos e daí quantos usuários e qual ticket. Isso transforma "quanto custa?" em "quanto **pode** custar para isso funcionar?" e produz premissas testáveis em vez de projeções.

**Armadilha:** estimar COGS por analogia. Meça com um POC — no caso de referência o custo real medido foi mais de uma ordem de grandeza menor que a estimativa inicial, e isso **liberou teses de preço inteiras** que estavam sendo descartadas.

---

## 9. Restrições legais e regulatórias

**Propósito:** encontrar o que pode matar o produto por fora, antes de construí-lo.

**Perguntas:** que dados o produto toca e sob que regime (proteção de dados, dados sensíveis, menores)? há direito autoral, licenciamento ou termos de uso que restringem os insumos? há regulação setorial (financeiro, saúde, educação, jurídico)? há regras de consumo aplicáveis (publicidade, cancelamento, renovação automática, reembolso)? o que exige parecer profissional em vez de pesquisa?

**Estrutura:** zonas de risco (verde / amarelo / vermelho) com o fundamento de cada uma, mitigação por zona, e uma lista explícita de **perguntas para advogado**. Este é um dos poucos itens do dossiê que a pesquisa não fecha sozinha, e o documento deve dizer isso.

---

## 10. Canais de aquisição

**Propósito:** descobrir onde o público já está e quanto custa alcançá-lo — pesquisa que costuma ficar de fora e depois vira o gargalo.

**Perguntas:** onde o público se reúne (comunidades, buscas, criadores, marketplaces)? qual o volume de busca dos termos-chave e o CPC estimado? quem são os criadores e influenciadores da categoria, e qual o custo de parceria? há ciclos sazonais previsíveis? que canais os concorrentes usam, e o que isso revela sobre o que funciona? há loop orgânico plausível (compartilhamento, resultado público, convite)?

**Armadilha:** assumir tráfego orgânico. Estime CAC por canal, ainda que grosseiramente, e marque como estimativa.

---

## 11. Decisões em aberto e plano de teste empírico

**Propósito:** o documento de fecho — consolida o que **não** foi decidido e como será decidido. É o que impede a pesquisa de virar biblioteca. Escrito por quem sintetiza, depois de ler todos os retornos; nunca por um pesquisador.

**Conteúdo, para cada decisão em aberto:**

- A decisão nomeada, com as **teses concorrentes** enunciadas de forma justa (2–3, cada uma com o argumento mais forte a favor e a evidência que a sustenta).
- Por que a pesquisa **não** decide: qual evidência falta e por que ela não existe em fonte pública.
- O **teste que decide**: método, amostra mínima, custo, prazo e — crucialmente — **a métrica de decisão definida antes de rodar** ("receita líquida por visitante do funil em 60 dias", não "conversão").
- Critério de parada e o que fazer com cada resultado possível.
- Data de revisão.

**Framework:** **Assumptions Mapping** (David Bland & Alex Osterwalder, *Testing Business Ideas*): liste as hipóteses de desejabilidade, viabilidade e exequibilidade, posicione cada uma em dois eixos — **importância × força de evidência** — e teste primeiro o **quadrante superior direito**: crítico para o sucesso, com pouca evidência. Isso resolve o vício mais comum, que é rodar o teste fácil em vez do teste letal.

O estado da decisão fica visível **no topo do índice**, não enterrado neste arquivo.

---

## 12. POCs e resultados medidos

**Propósito:** registrar o que foi efetivamente testado, com números, incluindo o que **reprovou**. Só existe depois do premortem.

**Estrutura:** critérios de aceite definidos **antes** → o que foi executado (volume real de dados, período, ambiente) → resultado por critério (aprovado / reprovado / aprovado após correção) → correções estruturais que o teste revelou → o que continua em aberto → código e artefatos de referência (caminho no repo).

**Regra:** *nenhuma camada entra no roadmap sem a sua própria auditoria que reprova primeiro.* Um POC que aprova de primeira em todos os critérios é suspeito — normalmente significa que os critérios eram frouxos ou que a auditoria foi complacente. Rode uma auditoria adversarial, com contexto limpo, sobre o resultado do POC.

---

## Dossiê mínimo vs. completo

| Contexto | Documentos indispensáveis |
|---|---|
| Fim de semana / ferramenta interna | 2 (dores) + 3 (concorrentes), enxutos |
| Produto pago, mercado conhecido | 1, 2, 3, 4, 11 |
| Produto pago, mercado novo | 1, 2, 3, 4, 5, 8, 10, 11 |
| Produto com núcleo técnico incerto | + 6, 7, 12 |
| Domínio regulado ou dados de terceiros | + 9 |

Documentos que **não** devem ser escritos nesta fase: especificação de features, arquitetura de software, roadmap, wireframes. Se aparecerem, a pesquisa virou projeto antes da hora.

---

## Modo feature — sistema existente

Quando o sistema já está em uso e a decisão é sobre uma capacidade nova dentro dele, o dossiê troca de eixo: quem é o público e se ele existe já foi respondido pela base instalada, e o que está em aberto é se **esta capacidade** merece ser construída, cobrada e mantida.

**Seleção default.** O doc 1 e o dimensionamento TAM/SAM/SOM saem do mínimo — voltam apenas quando a feature abre um segmento que a base não cobre, e então o alvo é aquele segmento, não o mercado inteiro. Entram como centrais:

- **2 — dores e jobs**, recortado ao job que a feature cumpre: o que a base faz hoje na ausência dela, dentro do produto (gambiarra, exportação para planilha, uso torto de outra tela) e fora dele.
- **3 — gap competitivo da capacidade**, não da categoria: as colunas da matriz são as capacidades desta feature, e a pergunta por player continua sendo **onde ele para** — quem já entrega, com que profundidade verificada, e se cobra à parte por isso.
- **4 e 5 — preço e empacotamento**, recortados à decisão de empacotamento: cobrar à parte × incluir no plano atual × usar como gatilho de upgrade de degrau, com a **canibalização** medida junto (quanto da receita já existente a feature apenas move de lugar em vez de somar, e quem deixa de subir de plano porque agora tem o suficiente). O doc 4 continua rodando sem âncora e sem recomendar.
- **8 — economia unitária incremental**: o custo de servir **o delta**, não o do produto. Quanto a feature adiciona por usuário/mês, o que domina esse custo, e em que arranjo de empacotamento a margem ainda fecha.

Os docs 6, 7 e 9 entram pelo mesmo critério do modo produto novo — núcleo técnico incerto, insumo de terceiro, domínio regulado. O doc 10 só entra se a feature for usada como alavanca de aquisição, e aí é sobre a feature, não sobre o produto.

**A fonte que só este modo tem: os dados internos do sistema.** Uso real das telas e capacidades vizinhas, tickets de suporte, motivos de churn e de downgrade, pedidos de clientes registrados, buscas sem resultado, tentativas de gambiarra dentro do produto, contas que pararam de crescer em um limite. É preferência revelada da própria base — comportamento medido de gente que já paga —, e por isso **vence pesquisa web sempre que as duas respondem à mesma pergunta**. A web fica com o que a base não pode responder: o que existe fora, quem já entrega a capacidade, quanto o mercado cobra por ela. O acesso é do usuário e se pede no enquadramento; sem ele, o documento declara a lacuna e a rota de coleta, e não a preenche com fonte externa disfarçada.

**Os três desfechos:** **construir**, **construir diferente** (outro recorte, outro empacotamento, outro momento) e **não construir**. Valem as mesmas regras do modo produto novo — os três são sucesso, e "não construir" com a base explicando por quê custa menos que descobrir o mesmo depois do deploy.

---

## Anexo — frameworks citados (nomes verificáveis)

**Dimensionamento e segmentação:** TAM/SAM/SOM com cross-validation top-down × bottom-up; Beachhead Market, End User Profile, Persona, Decision-Making Unit — Bill Aulet, *Disciplined Entrepreneurship: 24 Steps to a Successful Startup* (MIT).

**Competição:** tipologia direto/indireto/substituto/entrante potencial; feature-capability matrix; positioning map e white space; gap analysis; Porter — Five Forces.

**Público e dores:** *The Mom Test* — Rob Fitzpatrick; Jobs to Be Done — Clayton Christensen, Tony Ulwick (Outcome-Driven Innovation); Switch Interview e Four Forces of Progress — Bob Moesta & Chris Spiek; *Continuous Discovery Habits* e Opportunity Solution Tree — Teresa Torres; review mining.

**Premissas e experimentação:** Assumptions Mapping e Riskiest Assumption Test — David J. Bland & Alexander Osterwalder, *Testing Business Ideas* (Strategyzer); Discovery-Driven Planning, reverse income statement, key assumptions checklist e milestone planning — Rita Gunther McGrath & Ian C. MacMillan (HBR, 1995).

**Preço:** Van Westendorp Price Sensitivity Meter; Gabor-Granger; conjoint / discrete choice analysis; fake door / smoke test; preferência revelada vs. declarada.

**Qualidade de fonte e viés:** CRAAP test — Sarah Blakeslee, CSU Chico (2004), com a crítica de leitura lateral de Sam Wineburg / Stanford History Education Group; triangulação por métodos mistos; ancoragem, confirmação, disponibilidade, sobrevivência, desejabilidade social, framing.

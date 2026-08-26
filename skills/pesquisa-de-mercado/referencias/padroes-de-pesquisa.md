# Padrões de pesquisa — obrigatório para quem escreve um documento do dossiê

Este arquivo define o formato do documento, o vocabulário de confiança, como buscar e citar, os vieses que corrompem o resultado e o portão que o documento atravessa antes de ser aceito. Vale para qualquer documento do dossiê.

---

## 1. Esqueleto padrão de qualquer documento

Nome do arquivo em **kebab-case descritivo** (`analise-concorrentes.md`, `panorama-de-precos-mercado.md`). Um assunto por arquivo — se o arquivo precisa de dois resumos executivos, são duas pesquisas.

```markdown
# Título

**Data:** AAAA-MM-DD
**Contexto/Escopo:** uma linha sobre o projeto e o recorte desta pesquisa
**Natureza:** (quando o documento é neutro) ex.: "mapa neutro; NÃO recomenda preço"

## Resumo executivo
Um a dois parágrafos com os números e a conclusão. Quem lê só isto decide.
O resumo só pode conter números que aparecem no corpo com fonte.

## Nota de método
- Data e forma da pesquisa; o que foi verificado diretamente
- Legenda de confiança (tabela abaixo)
- Limitações declaradas: fontes bloqueadas ao crawler, amostras autosselecionadas,
  dados proprietários, o que ficou pendente de coleta manual
- Políticas de leitura, quando aplicável (ex.: descontos "de/por" permanentes são
  reportados pelo preço efetivamente cobrado)

## [Seções de conteúdo — tabelas com FONTE POR LINHA]

## Síntese: achado → implicação
Tabela de duas colunas. É o que conecta pesquisa a decisão; sem ela o documento é
enciclopédico.

## O que foi procurado e NÃO encontrado
Lista numerada, cada item com o motivo: não existe / bloqueado / proprietário /
só por contato direto.

*Rodapé: data de produção, validade dos dados, o que reverificar antes de decidir.*
```

## 2. Legenda de confiança

| Marca | Significado |
|---|---|
| ✅ | verificado em fonte primária/oficial nesta data |
| ⚠️ | via snippet, agregador ou fonte secundária — estimativa confiável |
| 📅 | dado histórico (ano indicado) — pode estar obsoleto |
| **[N]** | procurado e **não encontrado** |
| *(itálico)* | inferência ou estimativa **desta pesquisa**, não dado de terceiro |

A marca vai **na linha da tabela ou colada ao número**, nunca em nota de rodapé genérica: a confiança precisa viajar junto com o dado quando alguém copiar a linha para um slide.

## 3. Força de evidência — o vocabulário do dossiê inteiro

| Rótulo | Critério | Como usar |
|---|---|---|
| **FORTE** | Estudo publicado + replicação + experimento de campo ou dado de larga escala | Pode desenhar em cima; ainda assim, meça |
| **MODERADA** | Estudo original sólido com replicação parcial ou mista, ou dado de empresa não auditado | Use com instrumentação desde o dia 1 |
| **FRACA** | Blogs, vendedores da própria solução, benchmarks sem metodologia auditável | Reporte com a ressalva explícita; não fundamente decisão |
| **HIPÓTESE** | Raciocínio plausível sem evidência direta | Vira item do plano de teste, não do plano de produto |
| **REFUTADO / NÃO REPLICA** | Efeito famoso que falhou em replicação com estímulos realistas | Não conte com ele |

Duas heurísticas que tornam o rótulo operacional:

- **Quando a evidência é fraca, o argumento real costuma ser outro e melhor.** Separe "o benchmark diz 12%" (FRACA) de "comprador ≠ lead, e há literatura sólida de sunk cost e pain of paying" (FORTE).
- **Nomeie o estudo, o ano e o desenho** — "experimento de campo com catálogos", "n=13 mil autodeclarado", "dado de plataforma com ~115 mil apps". Sem isso o rótulo é decoração.

Seções inteiras podem receber um rótulo de qualidade: *"Qualidade geral da evidência nesta seção: FRACA."*

## 4. Regras de evidência

- **Todo número tem fonte linkada e data.** Sem link, o número não entra.
- Distinga sempre quatro naturezas: **dado verificado**, **projeção de terceiro**, **estimativa desta pesquisa** e **inferência estrutural**. Escreva assim: *"a triangulação bottom-up sugere R$ X — estimativa desta pesquisa, não dado."*
- **Preferência revelada vence preferência declarada.** Preço efetivamente pago, taxa de abandono, pirataria, lista de espera, longevidade do produto no mercado valem mais que qualquer survey de intenção.
- **Triangule.** Duas fontes independentes que convergem (idealmente por métodos diferentes) elevam a confiança; se divergem, a divergência é o achado e aparece no texto.
- **Avaliação de fonte:** CRAAP (*Currency, Relevance, Authority, Accuracy, Purpose* — Blakeslee, CSU Chico, 2004) é o piso, e é insuficiente sozinho: checagem vertical dentro da própria página não basta (crítica de Wineburg / Stanford History Education Group). Complemente com **leitura lateral** — saia da página e verifique quem é a fonte por fora. Pergunte sempre: **quem se beneficia deste número?** Associação setorial infla mercado; vendedor de solução infla benchmark de conversão; agregador de cupons costuma estar desatualizado.
- **Claim de vendedor não auditado** ("20 mil alunos", "98% de satisfação") é categoria própria: reporte como claim, com atribuição, nunca como fato.

## 5. Como buscar

**Ordem de valor das fontes:**

1. Fonte primária do próprio player — página de preço, planos, changelog, central de ajuda, termos de uso.
2. Dado oficial/estatal — órgãos oficiais, publicações governamentais, registros públicos.
3. Censos e relatórios setoriais com metodologia declarada (registre n, método de amostragem e quem financiou).
4. Imprensa de negócios com números atribuídos (aportes, receita, aquisições).
5. Comunidades e reviews — para dor e sentimento, com verbatim e link. Reviews de 1 a 3 estrelas são ouro.
6. Agregadores e blogs — último recurso, sempre com ⚠️.

**Formulação:** consultas específicas em vez de genéricas ("preço plano [player] 2026", "[player] receita aporte"), no idioma do mercado-alvo **e** em inglês para analogias internacionais. Busque explicitamente o contrário da tese ("por que [categoria] não funciona", "reclamações [player]", "[método] crítica replicação"). Busque a **ausência**: se três consultas bem formuladas não acham um número, ele vira `[N]`.

**Empirismo — sempre que for barato.** Existe endpoint? Chame. Existe arquivo público? Baixe e processe uma amostra real. Existe custo de processamento? Meça, em vez de estimar. Existe página de preço? Abra (e registre o 403 — o bloqueio é informação). Dá para rodar o pipeline inteiro em pequena escala por poucos reais? Rode. Custo típico: horas e centavos; retorno: uma coluna inteira de estimativas vira fato, e às vezes a conclusão se inverte.

**Como citar:** link inline no ponto do dado, nunca bibliografia solta no fim; data de acesso no cabeçalho. Modelos de linguagem fabricam referências acadêmicas com frequência, e a maior parte das citações alucinadas é invenção total, não corrupção parcial — **nenhuma referência acadêmica entra sem que o título tenha sido conferido em busca**. Encontrar uma página que menciona um estudo não é o mesmo que confirmar o estudo. Se não foi possível abrir a fonte, o dado desce para ⚠️ ou vira `[N]`.

## 6. Independência anti-ancoragem

**Um documento cuja conclusão você já tem na cabeça não é pesquisa, é justificação.**

- Cada pesquisa roda em contexto próprio. Isso não é economia de tokens — é isolamento de viés: um agente que acabou de escrever "o vazio de mercado está na faixa X" vai encontrar evidências de que a faixa X é ótima.
- Não leia os outros documentos do dossiê, exceto as dependências declaradas explicitamente no seu brief.
- Documento marcado como neutro declara no cabeçalho que não recomenda nada, e a declaração é auditável: recomendação no corpo invalida o documento.
- Em pesquisa primária: randomize a ordem das perguntas, nunca revele limites ou expectativas, e pergunte por fatos específicos do passado em vez de hipóteses de futuro.

## 7. Vieses e armadilhas, com mitigação

### Vieses cognitivos

| Viés | Como aparece | Mitigação |
|---|---|---|
| **Ancoragem** | Um preço, tamanho de mercado ou concorrente visto primeiro contamina todo o resto; âncoras arbitrárias deslocam disposição a pagar em ordens de magnitude | Pesquisa de preço independente e sem tese; ordem randomizada em surveys; nunca revelar limites; nas entrevistas, não dizer seu número |
| **Confirmação** | Buscar e lembrar o que sustenta a ideia; ignorar o contrário | Buscar explicitamente a tese oposta; escrever "tensões documentadas" com evidência forte dos dois lados |
| **Disponibilidade** | O concorrente mais anunciado vira "o mercado"; o caso lembrado vira frequência | Enumerar por categoria antes de aprofundar; buscar a cauda longa; contar, não lembrar |
| **Sobrevivência** | Estudar só quem deu certo e concluir que a categoria funciona | Procurar ativamente os mortos — produtos descontinuados, pivôs, categorias que queimaram reputação — e o que os matou |
| **Desejabilidade social** | O entrevistado elogia a ideia para ser gentil | Fatos do passado, nunca hipóteses; não apresentar a ideia antes; elogio não conta como sinal |
| **Excesso de otimismo** | SOM de 10–20% chamado de "conservador"; CAC otimista; adoção rápida | Bottom-up obrigatório; reverse income statement; comparar com taxas reais da categoria |
| **Enquadramento** | A forma da pergunta produz a resposta ("você pagaria R$ 30?") | Perguntas abertas primeiro; Van Westendorp em vez de "quanto pagaria"; medir comportamento |
| **Custo afundado do próprio dossiê** | Depois de 40 páginas, é difícil concluir "não vale a pena" | Critérios de kill definidos antes; o dossiê pode terminar em "não" |

### Armadilhas metodológicas

| Armadilha | Sintoma | Mitigação |
|---|---|---|
| **Vanity TAM** | Número gigante de relatório setorial usado como mercado endereçável | TAM do beachhead, bottom-up, com premissas nomeadas |
| **Média que esconde a distribuição** | "Gasto médio de R$ 2 mil/ano" quando 64% gastam menos de R$ 1,5 mil | Reportar a distribuição; a média de uma cauda longa é ficção |
| **Unidade de contagem errada** | Inscrições confundidas com pessoas; contas com usuários; downloads com clientes | Declarar a unidade em toda cifra e nomear a diferença |
| **Preço de tabela vs. praticado** | Descontos "de/por" permanentes tratados como promoção | Política declarada na nota de método; reportar o preço efetivamente cobrado |
| **Feature-listing** | Matriz de concorrentes com 40 features e nenhuma conclusão | Matriz por capacidade da categoria (4–7 colunas) e coluna "onde para" |
| **Claim de marketing como capacidade** | "IA adaptativa" marcada como Sim na matriz | Três níveis: verificado em uso / documentado publicamente / apenas alegado |
| **Fonte bloqueada virando silêncio** | A comunidade mais importante estava bloqueada e o doc não menciona | Registrar o bloqueio na nota de método e agendar coleta manual |
| **Conclusão sem teste** | "Vamos cobrar R$ X" derivado de leitura | Decisão em aberto + método empírico + métrica definida antes |
| **Pesquisa que envelhece em silêncio** | Documento de 8 meses citado como atual | Data no cabeçalho, validade no rodapé, caveat cruzado no índice |
| **Síntese que vira opinião** | O resumo executivo afirma mais do que as seções sustentam | O resumo só contém números que aparecem no corpo com fonte |
| **Referência acadêmica alucinada** | Estudo citado com autor e ano que não existem | Conferir o título em busca antes de citar; sem confirmação, rebaixar ou remover |

## 8. Portão de qualidade por documento

Percorra item a item antes de entregar. O documento está pronto quando:

- [ ] Tem data, escopo e resumo executivo que **decide sozinho**, com os números incluídos.
- [ ] Tem nota de método com limitações declaradas e a legenda de confiança.
- [ ] **Todo número tem fonte linkada e marca de confiança na própria linha.**
- [ ] Estimativas próprias estão em itálico e rotuladas, distinguidas de dados de terceiros.
- [ ] Tem a seção "o que foi procurado e NÃO encontrado", com o motivo de cada item.
- [ ] Termina em tabela **achado → implicação**.
- [ ] Não recomenda nada, se o cabeçalho o declarou neutro.
- [ ] Não contém especificação de features, arquitetura, roadmap ou wireframe.

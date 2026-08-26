# Índice vivo, caveats e fechamento do dossiê

Lido por quem orquestra: no passo 2 (abrir o índice), no passo 5 (sintetizar) e no passo 6 (fechar).

---

## Índice vivo — "se não está no índice, não existe"

`docs/README.md` é o único ponto de entrada do dossiê. Quem o lê em 30 segundos precisa sair sabendo onde o projeto está.

A regra tem duas consequências operacionais: um documento não indexado é considerado rascunho e **não pode ser citado como base de decisão**; e atualizar o índice faz parte de terminar a pesquisa — não é passo opcional de arrumação.

### Estrutura

```markdown
# Índice de Pesquisas — {Projeto}

Este arquivo é o índice de toda a pesquisa do projeto. Cada pesquisa vive em um
arquivo próprio nesta pasta e ganha uma linha aqui, com link e um resumo de uma frase.

## Estado da decisão ({mês/ano})

{O que está decidido, o que está em aberto e como será resolvido. Nomeie as teses
concorrentes de cada decisão em aberto e o teste que a fecha. Este bloco fica no topo
e é reescrito sempre que uma conclusão muda.}

## Como adicionar uma pesquisa

1. Crie um arquivo em `docs/` com nome descritivo em kebab-case (ex.: `analise-concorrentes.md`).
2. Adicione uma linha na seção correspondente abaixo: `- [Título](arquivo.md) — resumo de uma frase.`
3. Se não houver seção adequada, crie uma nova.

## Pesquisas

### Mercado
- [Título](arquivo.md) — resumo de uma frase.

### Negócio
### Produto e viabilidade

## Artefatos
- [Nome](link) — o que a página sintetiza.
```

### O resumo de uma frase

O resumo carrega **a conclusão, com os números** — não o tema. "Análise de concorrentes — mapeia os principais players" é inútil. "Nenhum player fecha hoje o loop A→B→C: os grandes personalizam apenas X e os novos entrantes partem só de Y — exatamente o espaço do produto" substitui a leitura quando alguém só precisa lembrar da conclusão. Uma frase longa e densa vence três frases vagas.

## Caveats cruzados e desatualização

Documentos envelhecem em ritmos diferentes e às vezes um invalida parte de outro. Quando isso acontece, **não reescreva em silêncio e não delete** — o histórico de por que a equipe pensava X importa quando alguém questionar a decisão daqui a seis meses. Anote a superação na linha do índice e, se necessário, no cabeçalho do documento superado:

> *Nota: a arquitetura recomendada neste doc foi escrita **antes** do panorama independente de preços; os mecanismos seguem válidos, mas o valor da assinatura está em aberto — ver "Estado da decisão" acima.*

Marque também a **volatilidade**: preços promocionais, números de usuários e ofertas mudam em semanas. O rodapé de cada documento diz o que precisa ser reverificado antes de virar decisão.

## Da pesquisa à decisão

- Cada documento termina em síntese **achado → implicação**. Sem essa tabela, o documento é enciclopédico.
- Divergência entre documentos vira **decisão em aberto** no índice, com plano de teste — nunca é resolvida por argumento de autoridade interno.
- Um **artefato visual de síntese** — uma página única que junta as N pesquisas em um mapa — é opcional e de altíssimo retorno na hora de alinhar pessoas. Indexe-o como artefato e referencie-o a partir do estado da decisão.
- A pesquisa **não** vira roadmap diretamente: passa pelo premortem adversarial e depois por POCs que reprovam primeiro.

---

## Portão de completude do dossiê

O dossiê está completo quando as **oito perguntas de decisão** têm resposta ou teste marcado:

1. **Quem** é o usuário-cabeça-de-ponte, e quanto ele já gasta hoje com o problema? *(doc 1)*
2. A **dor existe fora da nossa cabeça**, com evidência que não fabricamos? *(doc 2)*
3. O que a pessoa **usa hoje**, e por que isso não basta? *(docs 2, 3)*
4. Existe um **espaço não ocupado**, e ele é estruturalmente protegido de algum incumbente? *(doc 3)*
5. Que **degraus de preço** o mercado sustenta e onde estão as lacunas — apurado sem âncora? *(doc 4)*
6. É **construível** com a técnica disponível, e os insumos existem e são legais? *(docs 6, 7, 9)*
7. A **economia fecha** em pelo menos um cenário de preço realista? *(doc 8)*
8. Existe **canal** para alcançar o público a um custo compatível? *(doc 10)*

E, transversalmente:

- [ ] Cada premissa crítica está mapeada por **importância × força de evidência**, e nenhuma premissa do quadrante "crítica + sem evidência" está sem teste desenhado.
- [ ] As decisões em aberto estão **nomeadas no topo do índice**, com teses concorrentes e método de resolução.
- [ ] Cada teste tem **método, amostra mínima, custo, prazo e métrica de decisão definida antes de rodar**.
- [ ] Existe pelo menos **uma verificação empírica** — endpoint chamado, custo medido, dado real processado, produto do concorrente comprado e usado.
- [ ] Está claro o que **só um humano** pode fazer: conversar com usuários, consultar advogado, decidir posicionamento de marca.

## Sinais de "pesquisa demais"

Pare de pesquisar quando qualquer um destes aparecer:

- Novas buscas retornam as mesmas fontes (**saturação**).
- A próxima pergunta só se responde **construindo ou testando**, não lendo.
- O documento começa a acumular contexto que não muda nenhuma decisão.
- A pesquisa migrou para features em vez de mercado — sinal de que a fase acabou.
- O custo do próximo dia de pesquisa é maior que o do teste que ele tenta evitar.

A pesquisa está pronta quando **o próximo passo é óbvio e defensável**, não quando o assunto acabou.

## Os três desfechos legítimos

Um dossiê completo termina em um destes, e os três são sucesso da pesquisa:

1. **Prosseguir**, com as decisões em aberto listadas e os testes que as fecham agendados.
2. **Prosseguir diferente** — o beachhead, o posicionamento ou o modelo mudam por causa do que foi achado.
3. **Não prosseguir** — não há espaço, não há economia, ou o risco letal não tem teste barato. Uma pesquisa que evita um projeto inviável pagou por si muitas vezes.

## Handoff

Ao encerrar, o dossiê entrega:

- `docs/README.md` com o **estado da decisão** atualizado;
- um documento por pesquisa, indexado, com resumo de uma frase que carrega a conclusão;
- o bloco de **decisões em aberto** com plano de teste e métricas definidas antes;
- a lista de **premissas críticas ordenada por letalidade** — insumo direto do premortem;
- a lista de **itens que exigem um humano**;
- opcionalmente, o **artefato visual de síntese**.

A sequência completa até o código é: dossiê → premortem adversarial (skill `voltar-do-futuro`, que lê a pesquisa e pergunta "o projeto morreu, por quê?") → POCs cujos critérios de aceite saem das falhas previstas → decisões fechadas com evidência → só então roadmap e código. Os resultados medidos dos POCs voltam ao índice como o doc 12 e reescrevem o estado da decisão.

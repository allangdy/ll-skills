---
name: voltar-do-futuro
description: Premortem "voltar do futuro" — o projeto já morreu e você narra por quê, atacando o que nunca foi medido, e converte cada morte em um teste barato com critério de aceite numérico. Use quando pedirem premortem/pré-mortem, "o que pode dar errado", "por que isso vai falhar", análise adversarial de um plano, arquitetura ou ideia, validação de premissas não testadas, ou antes de investir em construir algo caro.
---

# Voltar do futuro

O projeto morreu. Não "pode morrer": morreu, é fato consumado, você viu o corpo. Esse é o
frame de certeza — pergunta probabilística o cérebro descarta como hipótese remota; fato
consumado ele explica, e gera causas específicas.

Um projeto quase nunca morre onde foi olhado com rigor. Morre na **fronteira entre a camada
auditada e a camada que entrou na fé**, porque a confiança conquistada na primeira é
transferida indevidamente para a segunda. Por isso o exercício começa medindo essa
assimetria e ataca só o delta. O produto final não é uma lista de riscos: é um conjunto de
premissas falsificáveis com experimento barato, aceite numérico pré-registrado e decisão
pré-comprometida.

## Regras invioláveis

1. **Ataque só o delta.** O que já foi auditado com número, amostra e método está fora do
   alvo. Reprovar de novo o que já passou é conforto disfarçado de rigor.
2. **Pretérito e cena.** Cada falha traz quem percebeu, por qual canal, quando, qual número
   apareceu e qual foi o dano de negócio. Se a frase caberia sem alteração em outro projeto
   qualquer, ela é lugar-comum e sai da lista.
3. **Citação literal e rastreável, ou ponto cego declarado.** Toda falha cita um trecho
   literal de um artefato do próprio projeto que já avisava, com o arquivo de origem — ou
   declara "nenhum artefato menciona este ponto", tratado como agravante de letalidade.
   Citação inventada destrói o exercício inteiro: jamais parafraseie como se fosse citação,
   jamais cite arquivo que você não abriu.
4. **Nenhuma falha sai sem teste acoplado.** Teste com amostra, prazo, custo, aceite
   numérico, o que ele reprova e o que ele bloqueia. Lista sem teste é pior que lista
   nenhuma: entrega a sensação de risco endereçado enquanto o plano segue intocado.
5. **Zero mitigação durante a narrativa.** Enquanto narra, o agente não resolve. Resolver
   cedo interrompe a geração e produz otimismo.
6. **5 a 8 falhas, vetores diversos.** Menos de 5 = preparação rasa. Mais de 8 = risk
   register diluído. Sete versões da mesma falha contam como uma.
7. **Veredicto duro no bloco (a).** Nada de "embora o time provavelmente perceba a tempo".
   A nuance vai para o veredicto medido da F5, depois do número.

## Material de apoio

Resolva o **caminho absoluto do diretório desta skill** antes de delegar — subagentes não
herdam este contexto e precisam do caminho literal nos briefs.

- `referencias/vetores-e-testes.md` — 12 vetores de ataque, anatomia de 8 partes do teste
  desarmador, padrões de teste por tipo de incógnita, substitutos quando o teste exige
  terceiros, 5 fatores de letalidade, exemplo trabalhado. Leia antes da F1.
- `referencias/anti-padroes-e-fundamentos.md` — 17 anti-padrões, checklist de "pronto",
  fundamentos da literatura. Leia antes da verificação final e ao justificar o método a um
  humano cético.

## F0 — Inventário: medido × fé

Varra os artefatos do projeto (specs, POCs, ADRs, benchmarks, relatórios, docs de pesquisa)
e produza `docs/premortem/00-inventario-medido-vs-fe.md`:

1. **Medido** — toda afirmação com **número, amostra e método**, mais o **escopo exato da
   medição**: qual camada, qual ambiente, qual amostra, qual regime de operação.
2. **Na fé** — toda afirmação sem medição: bibliografia citada, analogia, projeção,
   decisões justificadas por "sabemos que", "deve", "esperamos", "assume-se", "é padrão de
   mercado", e tudo que só existe como desenho.
3. **Confissões do projeto** — seções de "fora de escopo", "limitações", "não medido",
   "trabalho futuro", "riscos conhecidos", TODOs e ressalvas de rodapé, cada uma com
   **citação literal + arquivo:seção**. Esta é a munição mais valiosa do exercício.
4. **A frase da fronteira** — no formato *"medimos X com rigor; o produto depende de Y; X e
   Y são coisas diferentes"*. Concreta, com os nomes reais dos componentes.
5. **A zona de ataque** — o delta, enumerado. E a lista explícita do que fica **fora do
   alvo** por já ter sido auditado.

> **Checkpoint 1 (humano).** Apresente em ≤ 10 linhas: a frase da fronteira, a zona de
> ataque, o **horizonte e a data** propostos para a narrativa e as personas escolhidas.
> O horizonte é o ponto em que o projeto teria *provado* sua tese central — curto demais
> gera falhas triviais, longo demais gera ficção científica. Peça correção antes de seguir.

**Se existe `docs/` de uma pesquisa de mercado** (skill `pesquisar-mercado`), as premissas
mapeadas por importância × evidência já são metade da F0: as de alta importância e baixa
evidência entram direto na coluna "na fé". Use como insumo quando houver; a F0 funciona
igual sem ela.

## F1 — Narradores paralelos, contexto limpo

Rode **4 a 6 narradores em paralelo, cada um em subagente próprio**, com personas
distintas. Um único narrador ancora: gera sete variações do primeiro tema que apareceu.
Este é o análogo digital da escrita silenciosa antes da roda de conversa.

Personas disponíveis (escolha as que o projeto realmente tem): engenharia/dados,
operação e escala, economia unitária, jurídico/regulatório e dependências externas,
usuário final e percepção, concorrente/mercado.

Os narradores **não devem ver o raciocínio que produziu o plano** — só os artefatos e o
dossiê da F0. Cada um grava seu resultado em arquivo e devolve só o caminho: o orquestrador
lê os arquivos na F2, não os transcritos. Rode-os em Opus.

<brief-modelo-narrador>
Você é o(a) [PERSONA: ex. engenheiro(a) de dados sênior] de [PROJETO] e voltou do futuro:
é [DATA/HORIZONTE] e o projeto morreu. Não "poderia morrer" — morreu, é fato consumado,
você viu o corpo. Sua tarefa é relatar, em pretérito, o que aconteceu.

Contexto: este relato alimenta um premortem que decide, nesta semana, quais testes baratos
rodam ANTES de qualquer construção. Quanto mais específica e mais dolorosa sua narrativa,
mais dinheiro e meses ela economiza. Você tem permissão explícita para ser brutal; suavizar
aqui é o único jeito de falhar nesta tarefa.

Leia, nesta ordem:
1. [CAMINHO ABSOLUTO]/docs/premortem/00-inventario-medido-vs-fe.md — o que foi medido, o
   que está na fé, e a fronteira entre os dois.
2. [CAMINHOS DOS ARTEFATOS RELEVANTES PARA ESTA PERSONA]
3. [CAMINHO ABSOLUTO DA SKILL]/referencias/vetores-e-testes.md — os 12 vetores de ataque
   (cubra pelo menos os vetores [N, N, N]) e a anatomia de 8 partes do teste desarmador.

Instruções:
- Ataque exclusivamente a zona de ataque do dossiê. O que está listado como já auditado
  está fora do alvo.
- Escreva 3 a 5 mortes, cada uma como cena concreta: quem percebeu, por qual canal, quando,
  qual número apareceu, qual foi o dano de negócio. Termine no dano, não no defeito.
- Para cada morte, cite **literalmente** um trecho de um artefato do projeto que já avisava,
  com arquivo e seção. Se nenhum artefato menciona o ponto, escreva exatamente "nenhum
  artefato do projeto menciona este ponto" — isso é um achado, não uma falta. Nunca escreva
  entre aspas algo que não esteja literalmente no arquivo.
- Nomeie o viés ou mecanismo que explica por que o aviso, existindo, não foi agido.
- Não proponha mitigação e não amenize. Proponha apenas o teste barato que desarmaria a
  premissa, com os 8 componentes da referência.

Contrato de saída — grave em [CAMINHO ABSOLUTO]/docs/premortem/narradores/[persona].md,
uma seção por morte, exatamente neste formato:

## [título da morte em uma linha, com o número que a define]
**(a)** [história em pretérito, 1–5 frases, com cena, números e dano]
**(b)** [citação literal + `arquivo.md` §seção — ou a declaração de ponto cego] + [nome do
viés que cegou]
**(c)** [teste: afirmação falsificável, amostra adversarial, ground truth independente,
aceite numérico, "este teste reprova se ___", prazo e custo, decisão pré-comprometida nos
dois ramos, e o que ele bloqueia]
**Confiança:** [alta | média | baixa] — [uma frase sobre o que sustenta ou fragiliza este
relato]

Limites: não edite nenhum outro arquivo; não leia relatos de outros narradores; não
proponha roadmap, arquitetura ou solução.

Sucesso: 3 a 5 mortes gravadas no arquivo; nenhuma delas caberia sem alteração em outro
projeto; toda citação é verificável abrindo o arquivo citado; todo teste tem número no
aceite e uma frase de reprovação plausível; todo teste cabe em ≤ 2 semanas sem construir
o produto. Devolva na resposta apenas o caminho do arquivo e os títulos das mortes.
</brief-modelo-narrador>

## F2 — Consolidação

Leia os arquivos dos narradores. Deduplique (mesma premissa em roupas diferentes vira uma
falha, com a melhor cena e a melhor citação). Corte lugares-comuns e catástrofes sem
alavanca de teste. **Verifique cada citação abrindo o arquivo citado** — a que não bater
literalmente vira declaração de ponto cego ou sai. Chegue a 5–8 falhas, cada uma com os
três blocos:

<contrato-de-falha>
**(a) A história concreta da morte.** Pretérito, cena, números, consequência de negócio.
Uma a cinco frases. Termina no *dano*, não no *defeito*.
**(b) O aviso que existia + o viés que cegou.** Citação literal do artefato do projeto com
arquivo de origem (ou "nenhum artefato menciona este ponto"), mais o nome do mecanismo que
explica por que o aviso não foi agido.
**(c) O teste barato que desarma.** Amostra adversarial, ground truth independente, aceite
numérico pré-registrado, "reprova se ___", prazo e custo, decisão pré-comprometida, e o que
ele bloqueia.
</contrato-de-falha>

Para calibrar densidade, cena e tom de veredicto, leia o exemplo trabalhado no fim de
`referencias/vetores-e-testes.md`.

## F3 — Letalidade e TOP 3

Ordene da mais letal para a menos e **marque as três primeiras**. A marcação é o contrato de
triagem que faz o resultado ser acionável na semana seguinte em vez de virar backlog eterno.

Calibre pelos cinco fatores (detalhados na referência): mata ou machuca; custo de retrofit e
irreversibilidade; centralidade de dependência; probabilidade **dado que ninguém olhou**;
tempo até a detecção. *Atraso não é letalidade.*

**Contrato:** os testes do TOP 3, somados, cabem em ~2 semanas e antecedem qualquer
construção.

## F4 — Síntese

Não termine com lista. Termine com duas coisas:

1. **O diagnóstico transversal** — a única causa-raiz de processo que explica *todas* as
   falhas ao mesmo tempo.
2. **A regra que faltou** — uma política de processo enunciável em uma linha, que teria
   evitado a lista inteira e passa a valer daqui em diante. Verificável ("existe auditoria
   própria para esta camada? sim/não"), nunca exortativa ("ser mais rigoroso"). É o único
   entregável do premortem que sobrevive ao projeto.

Grave `docs/premortem/premortem.md`: parágrafo de contexto de quem voltou (com a frase da
fronteira) → falhas ordenadas com TOP 3 marcados → síntese.

> **Checkpoint 2 (humano).** Apresente o TOP 3 com custo somado dos testes e peça a decisão
> que só o humano toma: quais testes rodam agora, quem é o dono de cada um e qual a data de
> retorno. Registre as decisões pré-comprometidas como acordo, não como sugestão.

## F5 — Placar

O premortem só está encerrado quando cada falha tem **veredicto medido**. Ele derruba a
confiança no plano e depois a reconstrói sobre evidência — parar na metade é teatro.

Grave `docs/premortem/placar.md`: uma linha por falha, com **vocabulário fechado**:

| Veredicto | Significa |
|---|---|
| **DESARMADA** | Teste rodou, aceite passou, **com a fronteira de validade explicitada** (onde vale e onde não vale). Desarmar não é aprovar tudo. |
| **DESARMADA COM CONDIÇÕES** | Passou no fio, e a passagem depende de uma decisão de desenho que agora vira requisito. |
| **CONFIRMADA, COM ROTA DE SAÍDA QUANTIFICADA** | O premortem estava certo, e o teste mediu **qual alavanca resolve**. É o resultado de maior valor do exercício: redesenho fundamentado antes de qualquer código. |
| **EM CURSO** | Teste de duração instalado e rodando, com data de leitura. |
| **PENDENTE, COM SUBSTITUTO DECLARADO** | Exige terceiros indisponíveis; rodou simulação com o que ela prova e o que não prova escrito, e o item foi reclassificado de bloqueio para validação pré-lançamento. |

Registre também os **achados colaterais**: testes desenhados para falsear premissas
encontram bugs e cravam decisões de arquitetura que nenhuma revisão de código encontra.
Isso deve ser esperado e capturado. Números medidos aqui realimentam o índice de pesquisas
da skill `pesquisar-mercado`, quando ela existir no projeto.

## Verificação antes de entregar

Rode o checklist de "pronto" e os 17 anti-padrões de
`referencias/anti-padroes-e-fundamentos.md` contra o documento gravado, e reporte ao usuário
o resultado destas três verificações, que são as que mais falham:

- **Citações**: cada trecho entre aspas foi conferido abrindo o arquivo citado e bate
  literalmente. Diga quantas conferiu e quantas falhas ficaram sem aviso documentado.
- **Especificidade**: nenhuma falha sobrevive ao teste do "cabe em qualquer projeto do
  mundo"; cada uma tem um número na história e um número no aceite.
- **Orçamento do TOP 3**: os três testes somados, com prazos declarados, dão ≤ ~2 semanas e
  nenhum deles exige construir o produto.

Reporte também o que ficou fora e por quê. "Não encontrei aviso documentado para as falhas 3
e 5" é resultado válido e esperado; preencher a lacuna com uma citação plausível não é.

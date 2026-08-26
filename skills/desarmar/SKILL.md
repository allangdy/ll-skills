---
name: desarmar
description: Executa os testes desarmadores e as POCs com critério de aceite pré-registrado — confere cada teste contra a anatomia de 8 partes antes de rodar, executa com disciplina "reprova primeiro" (amostra adversarial, ground truth independente, auditoria de contexto limpo) e fecha o placar com veredicto medido por falha. Use quando pedirem para rodar os testes do premortem, executar uma POC ou spike com critério de aceite, desarmar riscos ou premissas, validar barato uma premissa antes de construir, ou preencher o placar de veredictos.
---

# Desarmar

Listar risco não desarma nada. Uma falha prevista só sai da lista quando um teste barato
rodou contra um aceite pré-registrado e devolveu um número. Esta skill executa esses testes
e fecha o placar — é a metade do premortem que costuma faltar, e sem ela o exercício inteiro
vira teatro: a sensação de risco endereçado enquanto o plano segue intocado.

O padrão de qualidade é o inverso do intuitivo: **o teste vale pelo que consegue reprovar**.
Aprovação fácil é o resultado mais perigoso, porque compra confiança sem pagar por ela — num
caso real, um critério aprovado pelos números agregados escondia recall de 7,7%, e só uma
auditoria adversarial de contexto limpo o reprovou; depois de corrigido, passou com 100%.
Reprovar é sucesso do método: **CONFIRMADA, COM ROTA DE SAÍDA QUANTIFICADA** é o resultado
de maior valor que esta skill produz, porque redesenha o produto antes da primeira linha de
código.

## Arquivos desta skill

Resolva o **caminho absoluto do diretório desta skill** no início — os briefs precisam dele
literal, e subagentes não herdam este contexto.

| Arquivo | Quem lê | Quando |
|---|---|---|
| `referencias/execucao-adversarial.md` | você, todo executor e todo auditor | D2 e D3 |
| `referencias/humanos-e-substitutos.md` | você e quem monta o kit | D1, quando um teste exige terceiros |
| `referencias/placar-e-realimentacao.md` | você | D4 e D5 |

Quando a skill `voltar-do-futuro` estiver instalada ao lado,
`../voltar-do-futuro/referencias/vetores-e-testes.md` é a fonte canônica do **desenho** do
teste (anatomia de 8 componentes, padrões por tipo de incógnita). Aqui a leitura é de
**conformidade e execução** — o teste já existe, a pergunta é se ele está pronto para rodar.

## Regras invioláveis

1. **O aceite congela antes de rodar.** Nenhum teste executa sem critério numérico
   pré-registrado e sem a frase "reprova se ___". Teste incompleto volta para ser completado
   **antes** da execução, com data de congelamento no plano. Completar critério depois de ver
   os dados não é teste, é justificação.
2. **Reprova primeiro.** Quem executa procura ativamente o resultado que reprova: o formato
   raro, o caso limítrofe, a classe de entrada esquisita. Passar sem esforço adversarial não
   é aprovação — é auditoria pendente.
3. **Amostra adversarial e ground truth independente do sistema testado.** Amostra fácil
   produz aprovação falsa, e aprovação falsa é pior que não testar. Sem verdade externa, você
   está medindo o sistema contra si mesmo.
4. **Número agregado não é veredicto.** Todo resultado sai quebrado por classe de entrada. A
   média esconde exatamente a classe onde o produto morre; a fronteira de validade só aparece
   na quebra.
5. **O aceite não se ajusta post-hoc.** Ficou no fio (79,7% contra aceite de 80%)? Isso é
   DESARMADA COM CONDIÇÕES, com a condição escrita — nunca DESARMADA.
6. **Simulação não vira humano.** Substituto de terceiros roda com o perfil oculto do
   instrumento e com o que ele prova e o que **não** prova escrito no resultado.
7. **A decisão pré-comprometida se executa.** O número dispara o ramo que já estava escrito;
   ele não reabre a discussão. Racionalizar o número ruim no dia seguinte é o modo de falha
   que o pré-compromisso existe para impedir.

## Entradas

Reúna os testes de onde eles estiverem, nesta ordem de prioridade:

- `docs/premortem/premortem.md` — o bloco **(c)** de cada falha, na ordem de letalidade, com
  o TOP 3 primeiro. Esta é a entrada canônica.
- `docs/decisoes-em-aberto.md` e o **Estado da decisão** de `docs/README.md` — decisões em
  aberto do dossiê de pesquisa cujo método de resolução já está especificado.
- Um teste descrito pelo usuário na conversa, ad-hoc. Trate igual: ele atravessa o mesmo
  portão de D0 antes de rodar.

Sem nenhuma das três, não há o que executar: peça a falha ou a decisão que o teste desarma,
porque teste sem premissa alvo não tem como ter aceite.

Artefatos que esta skill escreve:

```
docs/desarmar/plano-de-testes.md      # pré-registro congelado, com data
docs/desarmar/resultados/<slug>.md    # um relatório por teste
docs/desarmar/kits/<slug>/            # protocolo + formulário dos testes com humanos
docs/premortem/placar.md              # o placar (ou docs/desarmar/placar.md sem premortem)
```

## D0 — Congelar o pré-registro

Escreva `docs/desarmar/plano-de-testes.md`: uma seção por teste, copiando **literalmente** o
bloco (c) de origem, e submeta cada uma ao portão de conformidade.

| # | Pergunta de conformidade | Falta ⇒ o que fazer antes de rodar |
|---|---|---|
| 1 | Existe a afirmação falsificável, uma frase no presente do indicativo? | Escreva-a a partir da falha. Se não sai, o teste ataca um tema, não uma premissa: volte à falha. |
| 2 | A amostra está descrita com n **e** composição adversarial? | Desenhe a composição: os casos escolhidos para quebrar, nomeados um a um. |
| 3 | O ground truth é independente do sistema testado? | Nomeie a fonte externa (gabarito oficial, dois revisores com adjudicação, critério preditivo). |
| 4 | O aceite tem número, unidade e direção, e é **conjunto**? | Acrescente os critérios que faltam — um de qualidade, um de cobertura, um de operação. Um número sozinho quase sempre tem jeito trivial de passar. |
| 5 | Existe "reprova se ___", com um resultado plausível? | Redija a frase. Se nenhum resultado plausível reprova, o critério está frouxo e o teste é cerimônia. |
| 6 | Prazo e custo declarados, ≤ ~2 semanas, sem construir o produto? | Redesenhe para a versão de mesa (simulação, planilha, amostra de 30, script) que ataca a mesma premissa. |
| 7 | A decisão pré-comprometida está escrita nos **dois** ramos? | Escreva o "se… então…" agora, antes de qualquer dado. |
| 8 | Está dito o que este teste bloqueia? | Nomeie a decisão que ele antecede. Teste que roda depois dela é autópsia. |

Feche cada seção com a linha `Pré-registro congelado em {data}` e o orçado (prazo + custo).

> **Checkpoint 1 (humano).** Em ≤ 12 linhas: a lista dos testes prontos na ordem em que vão
> rodar, o custo e prazo somados, o que cada um bloqueia, o que foi completado no portão, e
> — separadamente — os testes que dependem de terceiros, com a pergunta que só o humano
> responde: **recrutar as pessoas agora ou rodar o substituto declarado?** Siga após a
> resposta.

## D1 — Triagem em três trilhas

- **(A) Executável agora por agente** — script sobre dados reais, amostra processada,
  simulação com verdade conhecida, orçamento bottom-up com preços reais. Vai para D2.
- **(B) De duração** — regime contínuo, cron por N dias, operação sem intervenção. Instale
  hoje (timer/cron, dashboard de 3–5 métricas, log em arquivo), registre a **data de
  leitura** e marque **EM CURSO**. O dia 1 costuma render correções reais: capture-as.
- **(C) Depende de terceiros** — entrevista, avaliação cega, parecer profissional. Leia
  `referencias/humanos-e-substitutos.md`, monte o kit completo em `docs/desarmar/kits/<slug>/`
  e execute a decisão do Checkpoint 1.

Um subagente por teste, em paralelo. Dois testes que compartilham a mesma amostra ou o mesmo
pipeline ficam com **um único** agente, dono dos dois de ponta a ponta — decomponha por
fronteira de contexto, nunca por fase. Para roteamento e limites de fan-out, a skill
`orquestrar` vale aqui integralmente.

## D2 — Execução paralela, um subagente por teste

Executores em `subagent_type: general-purpose`, modelo **Sonnet** para execução bem
especificada e **Opus** quando o teste exige julgamento adversarial dentro da própria
execução (adjudicação semântica, personas com perfil oculto, análise jurídica). Cada um grava
seu relatório e devolve só o caminho e um resumo curto — o orquestrador lê arquivos, não
transcritos.

<brief-modelo-executor>
Você executa um teste desarmador de {PROJETO} — um experimento barato desenhado para
reprovar uma premissa antes que ela custe caro.

CONTEXTO E MOTIVAÇÃO
O projeto ainda não construiu {o que está em jogo}. Este teste decide, nesta semana, se
{premissa} sobrevive. O critério de aceite foi congelado em {data}, ANTES de existir
qualquer dado — ele não pode ser reinterpretado, relaxado ou completado por você. Um
resultado que reprova é o desfecho mais valioso possível aqui: economiza meses. Um resultado
que aprova sem ter sido atacado é o mais perigoso, porque compra confiança falsa.

DADOS E REFERÊNCIAS (leia antes de rodar)
1. {abs}/docs/desarmar/plano-de-testes.md, seção "{título do teste}" — afirmação
   falsificável, amostra, ground truth, aceite, "reprova se", decisão pré-comprometida.
2. {abs da skill}/referencias/execucao-adversarial.md — disciplina de execução, receitas por
   tipo de incógnita, o que registrar, e o esqueleto obrigatório do relatório.
3. {caminhos dos dados, scripts, credenciais e artefatos do projeto que este teste usa}

INSTRUÇÕES
Monte a amostra adversarial descrita no plano — os casos escolhidos para quebrar, não os
fáceis; se um caso previsto não existir nos dados, registre a substituição e por quê.
Estabeleça o ground truth independente antes de olhar a saída do sistema. Rode. Procure
ativamente o resultado que reprova: quebre os números por classe de entrada, inspecione
manualmente os casos-limite, e teste a hipótese "este número está alto porque estou medindo
a coisa fácil". Trabalho determinístico (hash, dedupe, contagem, replay) fica em script, não
em julgamento de modelo. Use o mesmo tier de modelo que o produto usará — medir com um tier
melhor infla qualidade, medir com um pior infla custo.
Todo defeito que você encontrar e corrigir no caminho é achado de primeira classe: registre
o defeito, a correção e o re-teste. Se a correção mudar o resultado, o relatório mostra os
dois números, antes e depois.

CONTRATO DE SAÍDA
Grave {abs}/docs/desarmar/resultados/{slug}.md no esqueleto de execucao-adversarial.md
§Relatório: o que rodou (amostra real, ground truth, comandos/caminhos reproduzíveis, modelo,
período) → dados medidos quebrados por classe → aceite critério a critério com o número ao
lado → fronteira de validade (onde vale e onde não vale, com número) → achados colaterais e
correções estruturais → custo e prazo real contra o orçado → o que este teste NÃO prova.
Termine com **Veredicto proposto** e uma frase de justificativa; a atribuição final é do
orquestrador.
Devolva na resposta, em ≤ 200 palavras: o caminho do arquivo, o veredicto proposto, os
números que decidem, e o que ficou sem medir.

LIMITES
Não altere o critério de aceite por nenhum motivo — divergência entre o plano e a realidade
dos dados vira uma nota "Desvio do plano" no relatório, não uma correção silenciosa. Não
escreva nem edite arquivos fora de {caminhos permitidos}. Não construa produto: se o teste
parecer exigir isso, pare e reporte.

CRITÉRIOS DE SUCESSO
O relatório traz n real e composição da amostra; cada critério do aceite tem um número
medido ao lado, não um adjetivo; existe pelo menos uma tabela por classe de entrada; a
fronteira de validade nomeia uma condição onde o sistema **falha**; comandos e caminhos
permitem outra pessoa reproduzir; custo e prazo reais estão registrados contra o orçado.
</brief-modelo-executor>

## D3 — Auditoria adversarial de contexto limpo

Todo teste que **passou** atravessa esta etapa; os que passaram folgado, com prioridade —
folga é sintoma de amostra fácil até prova em contrário. O auditor roda em **Opus**, em
subagente novo, e nunca vê o raciocínio do executor: só a amostra, os dados brutos, o aceite
pré-registrado e o relatório. O protocolo e o brief-modelo do auditor estão em
`referencias/execucao-adversarial.md` §Auditoria.

Auditoria que reprova um critério aprovado é o retorno mais alto da rodada inteira: rode o
ciclo de correção, re-teste, e grave a trajetória — reprovou com X, corrigiu com Y, passou
com Z.

## D4 — Placar

Leia `referencias/placar-e-realimentacao.md` e escreva o placar: uma linha por falha, com
**vocabulário fechado**. O veredicto é atribuído por você, depois da auditoria, nunca pelo
executor.

| Veredicto | Atribua quando |
|---|---|
| **DESARMADA** | O aceite passou em todos os critérios conjuntos, atravessou a auditoria, e a fronteira de validade está escrita com número. Desarmar não é aprovar tudo: é delimitar onde vale. |
| **DESARMADA COM CONDIÇÕES** | Passou no fio ou passou porque uma decisão de desenho o sustenta. A condição vira requisito nomeado, não recomendação. |
| **CONFIRMADA, COM ROTA DE SAÍDA QUANTIFICADA** | O premortem estava certo e o teste mediu **qual alavanca resolve**, com número. Redesenho fundamentado antes do código — o resultado de maior valor. |
| **EM CURSO** | Teste de duração instalado e rodando, com data de leitura marcada e as correções do dia 1 registradas. |
| **PENDENTE, COM SUBSTITUTO DECLARADO** | Exige terceiros; o substituto rodou, a fronteira epistêmica está escrita, o instrumento está corrigido e pronto, e o item foi reclassificado de bloqueio para validação pré-lançamento. |

O placar carrega também, em seções próprias: **achados colaterais** (bugs reais e decisões de
arquitetura que os testes cravaram — testes desenhados para falsear premissas encontram o que
nenhuma revisão de código encontra), **custo da rodada** (real contra orçado, por teste) e **o
que continua com o humano**, com dono e marco.

> **Checkpoint 2 (humano).** Apresente o placar em uma tela: veredicto por falha com o número
> que o sustenta, o que cada decisão pré-comprometida obriga agora, e as escolhas que só o
> humano faz — recrutar as pessoas dos itens pendentes, aceitar o redesenho das CONFIRMADAS,
> ou parar.

## D5 — Realimentação e decisão disparada

1. **Execute a decisão pré-comprometida de cada teste.** O ramo já estava escrito: aplique-o
   como decisão tomada, registrando qual ramo disparou e o que ele obriga. Reabrir a
   discussão aqui anula o valor do pré-compromisso.
2. **Devolva os números ao dossiê**, quando `docs/README.md` existir: linha nova na seção
   correspondente com a conclusão **e os números**, Estado da decisão reescrito, e caveat no
   cabeçalho de todo documento que o teste superou — sem reescrever em silêncio e sem deletar
   (`referencias/placar-e-realimentacao.md` §Realimentação).
3. **Feche as decisões em aberto** que os testes resolveram e marque as que continuam abertas
   com o motivo.
4. **Handoff**: os requisitos que os testes cravaram (condições das DESARMADAS COM CONDIÇÕES,
   redesenhos das CONFIRMADAS, decisões de arquitetura dos achados colaterais) entram como
   decisões **já tomadas** na skill `decidir-antes` — elas não voltam a ser perguntadas.
   Ofereça o próximo passo e, se o usuário aceitar, invoque `decidir-antes` (plugin
   ll-skills) pela ferramenta Skill para montar a spec de implementação sobre o placar.

## Verificação antes de entregar

Reporte ao usuário o resultado destas quatro checagens, que são as que mais falham:

- **Pré-registro intacto**: cada aceite no relatório bate literalmente com o do plano
  congelado. Diga quantos conferiu e liste qualquer desvio registrado.
- **Reprovação possível**: nenhum teste passou sem uma classe de entrada onde o sistema
  falha estar nomeada com número. Um relatório sem nenhum número ruim descreve uma amostra
  fácil, não um sistema bom.
- **Auditoria**: quantos testes aprovados foram auditados em contexto limpo e quantos
  critérios a auditoria reprovou.
- **Orçamento**: custo e prazo reais somados contra o orçado, por teste.

Diga também o que ficou sem medir e por quê. "O teste 3 não rodou porque a fonte de ground
truth não existe sem dois revisores humanos" é resultado válido e esperado; preencher a
lacuna com uma aprovação plausível não é.

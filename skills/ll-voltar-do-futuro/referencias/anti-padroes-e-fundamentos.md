# Anti-padrões, critérios de pronto e fundamentos

Material de verificação do premortem `ll-voltar-do-futuro`. Lido antes de entregar o documento
e sempre que for preciso defender o método diante de um humano cético.

---

## Os 17 anti-padrões

### Do conteúdo das falhas

1. **Falha genérica.** "Pode faltar orçamento", "o time pode não ter experiência", "o mercado
   pode mudar", "requisitos podem crescer". Teste: se a frase caberia sem alteração em
   qualquer outro projeto do mundo, ela não é falha — é lugar-comum. Corte ou reescreva com
   os detalhes deste projeto.
2. **Catástrofe não acionável.** Pandemia, mudança regulatória global, aquisição do
   fornecedor. Sem alavanca de teste barato, não entra na lista principal.
3. **Falha sem número.** Toda história de morte precisa de pelo menos uma quantidade — taxa
   de erro, custo, tempo, n. Sem número, não há como desenhar critério de aceite.
4. **Atacar o que já foi auditado.** Reprovar de novo o que já passou é conforto disfarçado
   de rigor, e desperdiça a única passagem que o exercício tem.
5. **Citação fabricada.** O modo de falha mais grave para um agente LLM: inventar uma frase
   "do documento do projeto" que soa plausível. Toda citação é literal e rastreável ao
   arquivo; na ausência de aviso documentado, dizer isso em voz alta.
6. **Lista inflada.** Vinte falhas equivalem a zero decisões. 5–8, ordenadas, com TOP 3.
7. **Ancoragem monotemática.** Sete falhas que são a mesma falha em sete roupas. Cubra
   vetores distintos: dado, algoritmo, operação, custo, jurídico, humano/percepção, escala.

### Do processo

8. **Risk theater — listar sem desarmar.** O anti-padrão dominante. Uma lista de modos de
   falha que não muda nada é *pior* que nenhuma lista, porque entrega a sensação de ter
   endereçado o risco enquanto o plano segue intocado. Regra: nenhuma falha sai do documento
   sem teste acoplado.
9. **Mitigação vaga no lugar de teste.** "Vamos monitorar", "teremos cuidado", "adicionaremos
   validação". Não é falseável, não tem aceite, não tem data.
10. **Critério de aceite ajustado depois de ver o resultado.** Pré-registre. Se o número ficou
    no fio (79,7% contra aceite de 80%), diga que ficou no fio e trate como *condição*, não
    como aprovação.
11. **Teste que não pode reprovar.** "Verificar se a extração funciona bem." Aceite
    qualitativo é aceite ausente.
12. **Teste caro disfarçado.** Se o teste exige construir metade do produto, foi desenhado
    errado — ou o time está usando o premortem como autorização para começar a construir.
13. **Rodar o premortem com quem escreveu o plano, no mesmo fio de raciocínio.** Herda a
    inside view inteira. Exige contexto limpo, persona adversarial e permissão explícita para
    ser brutal.
14. **Um único narrador.** Ancoragem garantida. Vários narradores independentes com ângulos
    diferentes, deduplicados depois — o equivalente digital da escrita silenciosa de Klein.
15. **Otimismo de cortesia do agente.** LLMs suavizam por padrão ("embora o time
    provavelmente perceba isso a tempo…"). O bloco (a) não admite ressalva conciliatória; a
    nuance vai para o veredicto medido, depois.
16. **Confundir premortem com pessimismo ou com abandono.** O objetivo é converter incerteza
    em experimento. Falha CONFIRMADA não significa "desistir": significa "redesenhar agora,
    com o número na mão" — a rota de saída quantificada é resultado de sucesso.
17. **Não fechar o ciclo.** Premortem sem placar posterior é metade do trabalho. Data de
    retorno é marcada junto com cada teste.

---

## Critérios de pronto

### O documento de premortem está pronto quando

- [ ] A F0 produziu, por escrito, as duas listas (medido × na fé) e a frase da fronteira
      ("medimos X; o produto depende de Y; são coisas diferentes").
- [ ] Há **5 a 8 falhas**, cada uma com os três blocos completos.
- [ ] **Toda falha é específica deste projeto**: nomeia componentes, números, atores e
      consequências reais. Nenhuma sobreviveria ao teste do "cabe em qualquer projeto".
- [ ] **Toda falha tem citação literal e rastreável** de um artefato do projeto que já
      avisava, **ou** a declaração explícita de que não há aviso algum. Zero citações
      inventadas — cada uma foi conferida abrindo o arquivo.
- [ ] **Toda falha nomeia o viés ou mecanismo** que explica por que o aviso não foi agido.
- [ ] **Toda falha tem teste acoplado** com os 8 componentes: afirmação falsificável, amostra
      adversarial, ground truth independente, aceite numérico pré-registrado, "reprova se
      ___", prazo e custo, decisão pré-comprometida nos dois ramos, e o que ele bloqueia.
- [ ] As falhas estão **ordenadas por letalidade** com **TOP 3 marcados**, justificáveis
      pelos cinco fatores.
- [ ] Os testes dos **TOP 3 somam ~2 semanas ou menos** e antecedem a construção.
- [ ] Os vetores cobertos são **diversos**, e cada seção de "não medido / fora de escopo" dos
      artefatos ou virou falha, ou tem justificativa explícita de por que é inofensiva.
- [ ] A síntese entrega **o padrão transversal** e **a regra que faltou**, esta última
      enunciada como política verificável, não como exortação.

### O ciclo está encerrado quando

- [ ] Cada falha tem **veredicto medido** no vocabulário fechado.
- [ ] Cada "desarmada" traz a **fronteira de validade** — onde vale e onde não vale — não
      apenas o "passou".
- [ ] Cada "confirmada" traz a **alavanca quantificada** e a decisão de desenho que decorre
      dela.
- [ ] Os **achados colaterais** (bugs, decisões de arquitetura cravadas pelos testes) estão
      registrados.
- [ ] O que continua pendente está listado com dono, e explicitamente reclassificado de
      *bloqueio* para *validação posterior* — ou mantido como bloqueio.

---

## Fundamentos

### O núcleo: o frame de certeza

Um risk assessment pergunta *"o que pode dar errado?"*. O premortem afirma *"deu errado — por
quê?"*. A diferença não é retórica: é a passagem de um julgamento probabilístico (que o
cérebro trata como hipótese remota e educadamente descarta) para uma tarefa explicativa (que
o cérebro trata como fato consumado e para a qual gera causas específicas). Na formulação de
Klein: diferente de uma sessão de crítica típica, em que se pergunta o que *poderia* dar
errado, "o premortem opera sob a suposição de que o 'paciente' morreu, e portanto pergunta o
que *deu* errado".

- **Klein, G. (2007), "Performing a Project Premortem", HBR 85(9), 18–19.** Formaliza o
  exercício: o time é briefado no plano, assume que ele fracassou redondamente, e cada
  participante gera razões plausíveis para a morte.
- **Mitchell, Russo & Pennington (1989), "Back to the future", JBDM 2(1), 25–38.** Origem do
  *prospective hindsight*, base do número mais citado da técnica (**~30% de aumento na
  capacidade de identificar corretamente razões para resultados futuros**). *Nota de
  honestidade:* esse "30%" é a atribuição que Klein faz ao estudo; o artigo original manipula
  duas variáveis — perspectiva temporal e certeza do desfecho — e encontra o efeito forte na
  **certeza do desfecho**. Isso reforça o método: o que carrega o efeito é assumir que a coisa
  aconteceu, não apenas se projetar no futuro.
- **Veinott, Klein & Wiggins (2010), ISCRAM.** n=178, cinco condições, plano real de resposta
  a epidemia. O premortem reduziu a confiança no plano cerca do dobro do efeito de gerar
  prós/contras — e, **depois de gerar soluções, a confiança voltou a subir mais** na condição
  premortem. O premortem não é pessimismo: é um ciclo destrói-e-reconstrói.
- **Klein, Koller & Lovallo (2019), "Bias busters: Premortems", McKinsey Quarterly.** O
  mecanismo organizacional: líderes são superconfiantes e ancoram num único caminho; membros
  do time evitam falar por medo de parecerem negativos. O premortem torna a dissidência a
  tarefa designada, não um ato de coragem.

### Os vieses que a técnica desarma

- **Falácia do planejamento / viés de otimismo** — Kahneman & Tversky (1979): subestimamos
  prazo, custo e risco e superestimamos benefícios, porque adotamos a *inside view*. A cura é
  a *outside view* (Lovallo & Kahneman, 2003) e o *reference class forecasting* de Flyvbjerg
  (2006, 2008), cuja base empírica é brutal: ~92% dos megaprojetos estouram orçamento, prazo
  ou ambos; sobrecustos médios de 45% (ferrovias), 34% (pontes/túneis) e 20% (rodovias),
  estáveis há 70 anos.
- **Viés de confirmação** — Wason (1960); Nickerson (1998). Existindo um plano, toda evidência
  é lida como apoio a ele. O premortem inverte o alvo da busca.
- **Groupthink** — Janis (1972). O premortem torna a dissidência obrigatória e, na versão em
  grupo, anônima na primeira rodada.
- **Disponibilidade e transferência indevida de confiança** — medir o fácil e chamá-lo de "o
  todo". É o vetor dominante em projetos com uma camada bem auditada.

### Vizinhança metodológica

| Técnica | O que faz | Como difere |
|---|---|---|
| **Risk register / matriz probabilidade×impacto** | Enumera riscos pontuados | Trabalha em modo possibilidade, produz abstrações genéricas, raramente tem dono, teste ou prazo. É inventário; premortem é narrativa causal |
| **Key Assumptions Check** (Heuer & Pherson, 2010/2019) | Explicita e questiona premissas implícitas | Complementar e ideal como **preparação**: a lista de premissas não medidas é a munição do narrador — é a F0 |
| **Structured Self-Critique** (Pherson) | O time vira seu crítico mais duro | Evolução formalizada do premortem para análise de inteligência |
| **Red teaming / advogado do diabo** (Zenko, 2015) | Adversário dedicado ataca o plano | Red team ataca *de fora e no presente*; premortem ataca *de dentro e do futuro*, com acesso a premissas internas que o adversário externo não conhece |
| **Análise de Hipóteses Concorrentes** (Heuer, 1999) | Avalia evidência contra múltiplas hipóteses | Diagnóstico, não antecipação de falha |
| **Discovery-Driven Planning** (McGrath & MacMillan, 1995) | Checklist de premissas + reverse income statement + financiamento por marcos | Fornece a disciplina do "depois": sucesso = máximo de aprendizado pelo mínimo de gasto |
| **Leap-of-faith assumptions / MVP** (Ries, 2011) | Isola as premissas que sustentam o negócio | Mesma filosofia; o premortem é o gerador de candidatas |
| **Riskiest Assumption Test** (Higham, 2016; Bland & Osterwalder, 2019) | Constrói só o suficiente para testar a maior incógnita | É exatamente o **destino** de cada falha. Assumption mapping (importância × evidência) é a ordenação formal da letalidade |
| **Kill criteria** (Duke, 2018/2022; McKinsey, 2019) | Sinais pré-comprometidos que mandam parar | Duke é explícita: um premortem só é bom se você estabelece kill criteria e se compromete com as ações ao ver esses sinais |
| **Strong inference** (Platt, 1964) e falsificacionismo (Popper) | Hipóteses concorrentes + experimento crucial | É a epistemologia do teste desarmador: o teste vale pelo que consegue *reprovar* |
| **Chaos engineering / GameDays** (Basiri et al., 2016) | Injeta falha em produção | É o premortem executado continuamente sobre um sistema vivo |

### A tese em uma linha

O premortem funciona porque **transforma incerteza em narrativa, narrativa em premissa
falsificável, e premissa falsificável em experimento barato com critério de aceite
pré-comprometido**. Um premortem que para na narrativa é teatro; um que começa na lista de
riscos nunca chega a ser específico o bastante para virar experimento.

---

## Referências

- Basiri, A. et al. (2016). "Chaos Engineering." *IEEE Software* 33(3).
- Bland, D. J., & Osterwalder, A. (2019). *Testing Business Ideas*. Wiley.
- Duke, A. (2018). *Thinking in Bets*. Portfolio. / (2022). *Quit*. Portfolio.
- Flyvbjerg, B., Holm, M. S., & Buhl, S. (2002). "Underestimating Costs in Public Works
  Projects: Error or Lie?" *JAPA* 68(3).
- Flyvbjerg, B. (2006). "From Nobel Prize to Project Management: Getting Risks Right."
  *Project Management Journal* 37(3), 5–15.
- Heuer, R. J. (1999). *Psychology of Intelligence Analysis*. CIA CSI.
- Heuer, R. J., & Pherson, R. H. (2010; 3ª ed. 2019). *Structured Analytic Techniques for
  Intelligence Analysis*. CQ Press.
- Higham, R. (2016). "The MVP is dead. Long live the RAT."
- Janis, I. L. (1972). *Victims of Groupthink*. Houghton Mifflin.
- Kahneman, D. (2011). *Thinking, Fast and Slow*. FSG.
- Kahneman, D., & Tversky, A. (1979). "Intuitive prediction: Biases and corrective
  procedures."
- Klein, G. (2007). "Performing a Project Premortem." *HBR* 85(9), 18–19.
- Klein, G., Koller, T., & Lovallo, D. (2019). "Bias busters: Premortems: Being smart at the
  start." *McKinsey Quarterly*, abr. 2019. (e "Knowing when to kill a project", jun. 2019)
- Lovallo, D., & Kahneman, D. (2003). "Delusions of Success." *HBR*, jul. 2003.
- McGrath, R. G., & MacMillan, I. C. (1995). "Discovery-Driven Planning." *HBR*, jul–ago 1995.
- Mitchell, D. J., Russo, J. E., & Pennington, N. (1989). "Back to the future: Temporal
  perspective in the explanation of events." *JBDM* 2(1), 25–38.
- Nickerson, R. S. (1998). "Confirmation bias: A ubiquitous phenomenon in many guises."
  *Review of General Psychology* 2(2), 175–220.
- Platt, J. R. (1964). "Strong Inference." *Science* 146(3642), 347–353.
- Popper, K. (1934/1959). *The Logic of Scientific Discovery*.
- Ries, E. (2011). *The Lean Startup*. Crown Business.
- Tetlock, P., & Gardner, D. (2015). *Superforecasting*. Crown.
- Veinott, E. S., Klein, G., & Wiggins, S. (2010). "Evaluating the effectiveness of the
  PreMortem technique on plan confidence." *ISCRAM 2010*, Seattle.
- Zenko, M. (2015). *Red Team*. Basic Books.

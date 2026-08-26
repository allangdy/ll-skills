# Protocolo — evidência, fila e entrevista

Leitor: o agente que conduz a skill `decidir-antes`, nas fases 1 a 3. O objetivo final destas fases é que nenhuma one-way door chegue à spec sem resposta do usuário, e nenhuma two-way door vire pergunta.

## 1. Brief-modelo do subagente mapeador

Um subagente por material. Subagentes não veem esta conversa: o brief carrega tudo. Adapte:

<brief-mapeador>
Você mapeia <material> para uma entrevista de decisões que precede uma implementação longa. Cada afirmação sua pode virar a evidência de um lado de uma decisão apresentada ao dono do projeto — precisão de citação importa mais que prosa.

Contexto: o pedido é "<pedido do usuário, resumido>". O mapa alimenta a construção de um inventário de decisões; outro agente fará as perguntas.

Material: <caminhos exatos; nada além deles>.

Instruções: percorra o material inteiro. Para cada capacidade, comportamento, contrato ou estrutura relevante ao pedido, registre o fato com `arquivo:linha` (ou tela/rota, para protótipos). Cubra tudo o que encontrar e rotule cada achado com confiança (alta/média/baixa) — a filtragem é do orquestrador, não sua.

Contrato de saída: escreva `<raiz>/mapas/<nome>.md` com seções por área do sistema; fatos em bullets no formato `arquivo:linha — fato`; seção final "Lacunas e incertezas" com o que você não conseguiu confirmar. Responda ao orquestrador só com o caminho do mapa e 3 linhas de sumário.

Limites: não proponha decisões nem soluções; o mapa cabe em ~200 linhas — condense, não transcreva.

Sucesso: o orquestrador consegue citar seu mapa numa pergunta ao dono sem reabrir o fonte.
</brief-mapeador>

Quando o material é visual (protótipo, site), o mapeador navega e captura telas por conta própria e as descreve no mapa — screenshots ficam com ele, nunca voltam à sessão principal.

## 2. FILA.md — esqueleto

<esqueleto-fila>
# Fila de decisões — <pedido> (<data>)

## Estado
- Fase: <1 evidência | 2 fila | 3 entrevista | 4 spec> — <última ação> / <próximo passo concreto>
- Entrevista: <d> DECIDIDAS · <a> ASSUMIDAS · <p> PENDENTES · próxima: Q-NNN
- Notas de retomada: <o que uma sessão nova precisa saber para continuar>

## Sumário executivo
<escrito no fechamento da entrevista — ver §6>

## Ordem da entrevista
Q-003 (kickoff) → Q-001 → Q-007 → ...

## Itens
### Q-001 — <título decidível, não descritivo>
- **Classe:** PERGUNTA | ASSUNÇÃO · **Camada:** dominio|contrato|arquitetura|ui · **Impacto:** ALTO|MÉDIO|BAIXO
- **Lastro:** interno | externo — pesquisa: <em andamento | `mapas/pesquisa-<tema>.md`>
- **Lado A (pedido/protótipo):** <evidência com arquivo:linha ou tela>
- **Lado B (sistema atual):** <evidência com arquivo:linha, ou "inexistente">
- **Depende de:** Q-x · **Condiciona:** Q-y, Q-z
- **Status:** PENDENTE
  → DECIDIDA — <resposta literal do usuário> (<data>) [contra a recomendação — registro fiel; NÃO re-litigar] [risco aceito: <qual>]
  → ASSUMIDA — <default> porque <porquê em 1 linha>
  → DECIDIDA POR REGRA — segue Q-x (<data>)
</esqueleto-fila>

O bloco Estado é atualizado a cada checkpoint. O git é o registro durável, não a conversa: commit por bloco de respostas (`docs(spec): fila — decisões Q-x..Q-y (bloco N)`).

## 3. Classificação e ordenação

O teste de classe está no SKILL.md (fase 2). Refinamentos:

- Em dúvida entre PERGUNTA e ASSUNÇÃO, olhe o fan-out: item que condiciona 3+ outros é pergunta mesmo que pareça reversível — a resposta redesenha a fila.
- A pergunta de kickoff vem antes de tudo quando existir: sequenciamento (big-bang vs incremental), corte de escopo (mínimo vs completo). Ela muda o PREÇO de todas as opções seguintes — as descrições de custo das perguntas posteriores citam a resposta dela.
- Ordem dentro da fila: domínio/identidade/schema → contratos (API, permissões, vocabulário transversal) → navegação/estados globais → item local por tela ou módulo. Dentro de cada nível, primeiro o que desbloqueia ou poda mais itens (use Depende/Condiciona).
Lastro externo — decisões que dependem de conhecimento de fora do projeto (qual framework, qual biblioteca, padrão de mercado, limites e preços de API):

- Ao classificar o item, marque `Lastro: externo` e dispare imediatamente um subagente de pesquisa web em background (um por tema; para comparativos disputados, um por opção e um consolidador). A entrevista segue com os itens internos — nunca trava esperando pesquisa, e a pergunta externa entra na fila quando o comparativo chegar.
- A pergunta externa só é feita quando a recomendação puder ser sustentada: cada opção com seus trade-offs reais e fontes, e a "(Recomendada)" com justificativa rastreável ao arquivo de pesquisa — nunca de memória ou opinião.

<brief-pesquisador>
Você pesquisa <tema> para sustentar uma decisão que será apresentada ao dono do projeto. Contexto: <pedido + restrições relevantes do projeto, ex.: stack atual, orçamento>. Instruções: levante as opções viáveis (<lista, se já conhecida>) com trade-offs reais — maturidade, limites, preço, encaixe com <restrição> — cobrindo prós e contras de todas e rotulando cada afirmação com a fonte (URL) e confiança. Contrato de saída: escreva `<raiz>/mapas/pesquisa-<tema>.md` com uma seção por opção, tabela comparativa final com pontuação justificada, e sua recomendação com porquê. Limites: sem decisão final — quem decide é o dono; ~150 linhas. Sucesso: o orquestrador monta a pergunta e as descrições de custo citando só o seu arquivo.
</brief-pesquisador>

## 4. Anatomia da chamada AskUserQuestion

Texto da pergunta — autossuficiente; o usuário decide lendo só a pergunta:

1. Cabeçalho: `PERGUNTA N/M — <título> (impacto ALTO|MÉDIO|BAIXO)`. M é o total corrente da fila; quando desdobramentos criarem itens, M cresce — anuncie ("éramos 14, a resposta de Q-005 criou 2 itens: agora 16").
2. O que está em jogo, em 1–3 frases.
3. Evidência dos dois lados, citada do item (`arquivo:linha`, tela do protótipo).
4. Contexto novo de decisões anteriores da própria bateria, quando condicionarem esta ("com Q-003 = big-bang, migrações saem sem backfill — isso barateia a opção 1").
5. "Minha análise honesta: ..." — sua posição própria e o porquê, antes das opções.

Opções — 2 a 4, mutuamente exclusivas:

- A recomendada vem PRIMEIRA, com "(Recomendada)" no label. Label ≤ ~5 palavras; a description diz a consequência e o custo concretos ("migração dos grants + deploy ordenado — barato sob big-bang"), nunca só o nome da alternativa.
- Menu canônico quando a decisão compara algo novo com o existente: Adotar / Adaptar: \<como\> / Manter o atual / Cortar do escopo.
- Opção de escape quando fizer sentido: "Tanto faz — decida na implementação" (vira ASSUMIDA com as alternativas registradas); em ação destrutiva ou externa: "Não — eu mesmo executo".
- `multiSelect` só para inventário de fatos independentes e combináveis (quais claims são reais, quais integrações entram) — nunca para alternativas excludentes.

Lotes: impacto ALTO = 1 pergunta por chamada, sempre — você nunca agrupa itens ALTO por conta própria (o usuário pode responder em lote se quiser). Impacto baixo (ui-local, config) = até 4 perguntas por chamada, cada uma com uma única decisão. Fundir duas decisões numa pergunta destrói a rastreabilidade da resposta.

Fadiga: 3–5 decisões ALTO por sessão de perguntas; no limite, ofereça pausa com o Estado da fila atualizado — a retomada é barata porque a fila vive no arquivo.

## 5. Depois de cada resposta

1. **Registre imediatamente** no item: resposta literal, data. Contra a recomendação: marque "contra a recomendação — registro fiel; NÃO re-litigar" e anote as consequências que você apresentou. Risco aceito conscientemente: marque no item e liste no sumário.
2. **Nomeie o que a resposta cita.** Se a decisão referencia um entregável ("o CTA", "a tela de billing", "a coluna nova"), o registro nomeia arquivo/rota/migração/tela. Referência que ainda não existe e não tem nome: pergunte qual/onde na sequência, antes de registrar — decisão com referência órfã é re-pergunta garantida na execução.
3. **Pendência descoberta** (algo a fazer que não é decisão): registre com dono proposto (humano ou implementador) e marco em que fecha. Pendência sem dono não existe — ela some.
4. **Re-avalie a fila**: remova perguntas que ficaram sem objeto; decida itens "por regra" de resposta anterior (registre `DECIDIDA POR REGRA — segue Q-x`); desdobramentos viram itens novos — inclusive "nascidos DECIDIDOS" quando a resposta livre já os fecha.
5. **Commit por bloco** (3–6 respostas ou fechamento de nível).

Casos especiais:

- **Resposta livre ("Other") é redesenho de primeira classe**: registre verbatim e trate como redirecionamento — pode criar itens, matar itens, ou redirecionar o processo (pedido de pesquisa, de opinião sem viés). Pedido de arbitragem sem viés (copy, naming): subagentes juízes cegos, um por alternativa, sem saber a autoria; re-apresente a MESMA pergunta numerada com o veredito ("PERGUNTA 6/16 (retomada)").
- **"Não entendi"** ou contra-pergunta: reformule e re-pergunte com contexto melhor — a falha foi da pergunta, não do usuário. Nunca siga com uma resposta que você intuiu.
- **Delegação** ("você decide"): vira ASSUMIDA com default e porquê — entra na spec como assunção, escalável por evidência contrária.

## 6. Fechamento da entrevista

Com zero `PENDENTE`, escreva o Sumário executivo no topo da FILA.md: contagens (por classe, camada, impacto), decisões contra a recomendação, respostas livres registradas verbatim, riscos aceitos conscientemente, pendências com dono, e a linha "Consumo: este arquivo alimenta SPEC.md; em conflito, SPEC.md prevalece". Commit de fechamento. Siga para a fase 4 do SKILL.md.

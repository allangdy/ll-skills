# Consolidação — a camada 1, o binding de fontes e o portão de entrega

Você escreve os dois arquivos desta camada depois que as frentes voltaram: `SINTESE.md` e `fontes.md`. Nenhum pesquisador escreve nenhum dos dois — quem cobriu uma frente não viu as outras, e a síntese é exatamente o que só existe cruzando todas. Leia as notas de frente por inteiro; a frase de retorno de cada agente serve para o índice, não para a síntese.

A legenda de confiança (✅ ⚠️ 📅 **[N]** *itálico*) está no `SKILL.md` e é a mesma das duas camadas.

---

## 1. `SINTESE.md` — a única camada que entra no contexto de quem decide

Ela vai ser lida junto de outras coisas: pela entrevista do `ll-decidir-antes`, por um implementador, pelo usuário. Alvo de 150–300 linhas, teto de 500. Nada de despejo de fontes aqui — **sem URLs no corpo**, só ponteiros `evidencias/F<nn>-<slug>.md#A-<nn>`. As URLs vivem na camada 2 e são recuperadas quando alguém precisa delas.

<template>
# GEO — síntese para criar páginas que melhorem o GEO do site

**Data:** 2026-08-26 · **Frentes:** F01–F05 · **Destino do trabalho:** `apps/site/`
**Uso a jusante:** decidir a estrutura e o conteúdo das páginas novas do site para serem citadas por assistentes de IA.
**Legenda:** ✅ verificado em fonte primária · ⚠️ fonte secundária · 📅 dado datado · **[N]** procurado e não encontrado · *itálico* = estimativa desta pesquisa.

## Resposta curta

5–10 linhas. O que fazer, dado o que foi encontrado — e, se a pesquisa não conclui, isso dito aqui em vez de diluído adiante. Os números aparecem aqui, não só o tema.

## §0 Fatos que reordenam a premissa

Fatos verificados que mudam o que se assumia ao pedir a pesquisa. Se nenhum apareceu, escreva "nenhum — a premissa do pedido se sustenta" e siga.

- **A-03** — O crawler de citação não executa JavaScript ✅ · válido em 2026-07 · `evidencias/F02-crawlers.md#A-03`
  **So what:** o conteúdo que se quer citado precisa estar no HTML servido; a rota atual do site monta o corpo no cliente, então hoje ela é invisível para citação.
- **A-11** — …

## §1 APPLY — backlog executável

Só o que um agente ou o usuário consegue executar sem decisão nova do dono. Item que depende de escolha vai para §2.

| # | Item | Alvo | Ancorado em | Confiança | Custo se estiver errado |
|---|---|---|---|---|---|
| AP-1 | Servir o corpo das páginas de conteúdo no HTML inicial | `apps/site/app/[slug]/page.tsx` | A-03, A-11 | ✅ | build mais lento; nenhuma perda de comportamento |
| AP-2 | … | | | | |

**Adiado para depois de §2:** {itens prontos, mas travados por uma decisão da D-list — nomeie qual}.

## §2 DISCUSS — decisões do dono (D-list)

Cada item é uma pergunta fechável, com as teses concorrentes enunciadas de forma justa e o que decidiria entre elas. É daqui que sai a entrevista da próxima etapa.

### D1 — Publicar a página de comparação de produtos? — ABERTA
- **Tese A:** publicar. Páginas de comparação concentram citação em todos os estudos da frente F03 (A-07 ⚠️, duas fontes independentes).
- **Tese B:** não publicar. O mesmo formato é o que mais aparece como conteúdo rebaixado por qualidade (A-09 ⚠️).
- **O que decidiria:** publicar duas e medir citação em 30 dias — ver G2 em §3.
- **Dono:** usuário. **Bloqueia:** AP-4, AP-5.

### D2 — … — RESOLVIDA em 2026-08-26: {decisão literal do usuário, com a data}

## §3 Gates de medição

Como se sabe que funcionou. Métrica definida **antes** de executar; sem isso o item de §1 vira fé.

| Gate | Como medir | Valor hoje | Alvo | Fecha qual item |
|---|---|---|---|---|
| G1 | `curl` da rota e busca do texto-alvo no HTML servido | ausente | presente | AP-1 |
| G2 | citações medidas em 30 dias nas duas páginas de teste | — | ≥1 | D1 |

## Conflitos não resolvidos

- **A-07 × A-09** — {fonte X, 2026-05} diz que o formato concentra citação; {fonte Y, 2026-07} mede queda de qualidade no mesmo formato. Datas diferentes, populações diferentes. O que decidiria: G2.

## Lacunas conhecidas

- **[N]** Frequência de recrawl declarada — não publicada por nenhum fornecedor (F02). Impacto: não dá para prometer prazo de efeito.

## Nota de método

Frentes cobertas e o que cada uma cobriu; ferramentas e limitações (domínios bloqueados, paywalls, PDFs não lidos); o que foi verificado empiricamente e como; a janela de validade assumida para o tema e quando reverificar.
</template>

**Regras da camada 1:**

- **"So what" obrigatório em todo achado**, ancorado no uso a jusante. Achado sem "so what" é enciclopédico: ou desce para a camada 2, ou sai. A lacuna mais medida em relatórios de pesquisa agêntica é exatamente essa — sumário competente, contribuição analítica nenhuma.
- **IDs estáveis** (`A-03`, `AP-1`, `D1`, `G1`) atravessam as duas camadas e as skills seguintes: a entrevista precisa poder dizer "D1 assume A-03, confirma?" e o implementador precisa rastrear AP-1 até a fonte.
- **Incerteza colada à afirmação**, nunca num bloco de ressalvas no fim.
- **Confiança pela regra de suporte** de `frente-de-pesquisa.md` §1, não por impressão. Rebaixe quando as frentes divergirem.
- **Divergência entre frentes vira conflito declarado**, com as duas datas e o teste que decidiria — nunca resolvida por argumento interno.
- **Reconfira as restrições do enquadramento uma a uma** antes de fechar: as restrições que o usuário declarou no passo 1 são ignoradas silenciosamente com frequência alta o bastante para merecer uma passada dedicada.

## 2. `fontes.md` — binding bidirecional

Uma linha por fonte, ID `[S<n>]` global à pesquisa, ordenada por nível. A coluna **Sustenta** é o que fecha o ciclo: do achado se chega à fonte pela nota da frente, e da fonte se chega aos achados que dependem dela. Quando uma fonte cai ou é desmentida, sabe-se imediatamente o que revisar.

<template>
# Fontes — GEO (2026-08-26)

Estado verificado em 2026-08-26. `✅ 200` = respondeu; `⚠️` = não resolveu, substituída pelo arquivo indicado.

| ID | Título | URL | Nível | Publicada | Acesso | Frente | Sustenta | Estado |
|----|--------|-----|-------|-----------|--------|--------|----------|--------|
| S3 | Docs do crawler — {fornecedor} | https://exemplo.com/docs/crawler | 1 | 2026-07-14 | 2026-08-26 | F02 | A-03, A-05 | ✅ 200 |
| S9 | Teste de citação em 40 páginas | https://exemplo.dev/teste-crawler | 3 | 2026-05-02 | 2026-08-26 | F02 | A-03 | ✅ 200 |
| S14 | Guia de SEO para IA (2024) | https://exemplo.com/2024/seo-ia | 5 | 2024-11 | 2026-08-26 | F02 | — (lido e não usado) | 📅 ✅ 200 |
| S21 | Estudo de formatos citados | https://exemplo.org/estudo | 2 | 2026-03 | 2026-08-26 | F03 | A-07 | ⚠️ 404 → https://web.archive.org/web/…/exemplo.org/estudo |
</template>

Fontes lidas e não usadas entram com `— (lido e não usado)` na coluna Sustenta: elas custaram busca e o próximo agente merece herdar o descarte. Fonte crítica com risco de link morto ganha o link do arquivo ao lado do original.

## 3. Passada de citação

Depois que a síntese está escrita, não durante. Descobrir e atribuir são trabalhos diferentes; misturá-los é o que produz a citação plausível e errada — a taxa medida de afirmações não sustentadas ou atribuídas à fonte errada em agentes de pesquisa fica entre 22% e 27%.

1. **Claim a claim, contra o trecho salvo.** Para cada `A-<nn>` da síntese, abra a nota da frente e confira a afirmação contra o **trecho literal**, não contra a sua memória do que a fonte dizia. Afirmação sem trecho que a sustente é reescrita para o que o trecho sustenta, ou desce para lacuna.
2. **Toda URL apareceu num resultado de ferramenta.** Nenhuma escrita de memória, nenhuma reconstruída por padrão de domínio.
3. **Liveness em lote**, antes de entregar. Agentes de pesquisa fabricam entre 3% e 13% das URLs que citam, e a checagem derruba as não resolvíveis para menos de 1%:

```bash
while read -r u; do
  printf '%s %s\n' "$(curl -sIL -o /dev/null -w '%{http_code}' --max-time 15 "$u")" "$u"
done < urls.txt
```

   O que não responder vira `⚠️` em `fontes.md` com o link do Wayback ao lado, ou é substituído por outra fonte. URL morta com trecho salvo continua utilizável — é para isso que o trecho existe —, mas o estado é declarado.
4. **Afirmações sobre o sistema do usuário se verificam no código**, com `arquivo:linha`, não contra fonte web.

Quando a síntese passa de ~200 linhas ou alimenta uma decisão cara, delegue esta passada a um subagente verificador de contexto limpo (`general-purpose`, nunca `fork`): ele recebe apenas o caminho da síntese, os caminhos das notas de frente e o checklist abaixo, e devolve a lista de itens que falharam com o ponteiro de cada um. Verificação é o caso em que o isolamento custa quase nada — o verificador não precisa do histórico, só do resultado.

## 4. Portão de entrega

- [ ] Toda URL citada apareceu num resultado de ferramenta desta sessão.
- [ ] Liveness checada; não resolvíveis marcadas em `fontes.md` ou substituídas.
- [ ] Todo achado da síntese rastreia a um trecho literal numa nota de frente.
- [ ] Todo achado tem "so what" ligado ao uso a jusante do enquadramento.
- [ ] Todo item de §1 APPLY nomeia o arquivo ou artefato alvo.
- [ ] Todo item de §2 DISCUSS é pergunta fechável, com as duas teses e o que decidiria.
- [ ] Todo item de §1 e §2 tem um gate em §3, ou uma linha dizendo por que não é medível.
- [ ] Fontes que se citam entre si foram consolidadas como uma.
- [ ] Afirmações sobre sistemas vivos têm data; as datadas estão marcadas 📅.
- [ ] Conflitos e lacunas **[N]** estão declarados, não silenciados.
- [ ] As restrições que o usuário declarou no enquadramento foram reconferidas uma a uma.
- [ ] `SINTESE.md` não contém nenhuma URL no corpo e cabe abaixo de 500 linhas.
- [ ] Cada nota de frente citada existe no caminho declarado.

## 5. Índice vivo

Se o repositório já mantém `docs/README.md` como índice de pesquisas, acrescente uma linha na seção adequada:

```markdown
- [GEO — páginas citáveis por assistentes](pesquisa-geo/SINTESE.md) — o crawler de citação não executa JS, então a rota atual é invisível; 6 itens em APPLY, 2 decisões em aberto. (2026-08-26)
```

A frase é a conclusão com números, não o tema. Se o índice não existir, não crie um: a síntese basta, e criar índice é decisão do dono do repositório.

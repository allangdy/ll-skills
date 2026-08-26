---
name: pesquisa-de-mercado
description: Conduz a pesquisa de mercado completa antes de qualquer código — dimensiona público e beachhead, prova a dor com evidência externa, mapeia onde cada concorrente para, levanta os preços praticados sem âncora, testa insumos e economia unitária, e entrega uma pasta docs/ indexada com as decisões em aberto e o teste barato que fecha cada uma. Use quando houver uma ideia de produto, app ou negócio e a pergunta for validar mercado, ver se vale a pena, estudar a concorrência, descobrir quanto dá para cobrar, dimensionar TAM/SAM/SOM, achar espaço não ocupado ou decidir se prossegue.
---

# Pesquisa de mercado pré-produto

Cada documento do dossiê existe para destravar **uma decisão específica** que hoje seria tomada no chute. O entregável final não é conhecimento sobre o mercado — é uma lista de premissas ordenadas por letalidade, cada uma com o teste barato que a desarma. Pesquisa que termina em "o mercado é promissor" falhou; pesquisa que termina em "isto é fato, isto é aposta, isto só um teste de N dias resolve" acertou.

## Arquivos desta skill

Resolva o caminho absoluto do diretório desta skill uma vez, no início — os subagentes precisam dele.

| Arquivo | Quem lê | Quando |
|---|---|---|
| `referencias/dossie.md` | você (escopo) e cada pesquisador (a seção do doc dele) | passos 1 e 3 |
| `referencias/padroes-de-pesquisa.md` | todo pesquisador, sempre | passo 3 |
| `referencias/indice-e-fechamento.md` | você | passos 2, 5 e 6 |

## Fluxo

### 1. Enquadrar — primeiro checkpoint com o humano

Formule a pergunta que abre tudo: **que decisão o usuário não consegue tomar hoje?** Se não existe decisão pendente, diga isso e pare — a pesquisa não deve ser feita agora.

Leia `referencias/dossie.md` e apresente ao usuário, em uma mensagem só, para confirmação ou correção:

- o recorte de público candidato (segmento, país, quem usa × quem paga);
- 3 a 8 perguntas de decisão, cada uma escrita como pergunta fechável;
- a lista de documentos do dossiê, escolhida pela tabela **Dossiê mínimo vs. completo**, com a justificativa de cada inclusão e exclusão;
- a pasta de saída (padrão: `docs/`).

Siga só depois da resposta. Recorte errado contamina o dossiê inteiro.

### 2. Abrir o índice vivo

Crie `docs/README.md` antes de qualquer pesquisa, seguindo `referencias/indice-e-fechamento.md` §Índice vivo: **Estado da decisão** com tudo em aberto e as perguntas de decisão confirmadas, o protocolo de como adicionar uma pesquisa, e as seções que receberão as linhas.

### 3. Despachar os pesquisadores — um subagente por documento

Use a ferramenta Agent com `subagent_type: general-purpose` e `model: sonnet`. **Nunca use `fork`**: fork herda seu contexto e destrói o isolamento de viés que faz o método funcionar.

Ordem de despacho, respeitando as dependências de `referencias/dossie.md`:

- **Onda 1, em paralelo:** docs 1, 2, 3 (anel de desejabilidade) + docs 4, 6, 7, 9, 10 conforme escopo. O doc 4 (panorama de preços) roda nesta onda, com brief limpo, antes de existir qualquer conversa sobre preço.
- **Onda 2, depois que a onda 1 volta:** doc 5 (estratégia de preço, lê o doc 4) e doc 8 (economia unitária, lê 6 e 7).
- **Doc 11** é escrito por você no passo 5, nunca por um pesquisador.
- **Doc 12** só existe depois do premortem.

Cada brief segue o modelo abaixo. Preencha todos os campos — o subagente não vê nada desta conversa.

<brief-modelo>
Você é um pesquisador de mercado produzindo um documento de um dossiê pré-produto.

CONTEXTO E MOTIVAÇÃO
O projeto é: {descrição em 2–4 linhas, incluindo o recorte de público confirmado}.
Nenhuma linha de código foi escrita. Este dossiê decide se o projeto prossegue, prossegue diferente, ou não prossegue. O seu documento existe para destravar esta decisão específica: {pergunta de decisão}. Quem lê o seu resumo executivo precisa conseguir decidir sem abrir o resto.

REFERÊNCIAS (leia antes de pesquisar)
- {abs}/referencias/padroes-de-pesquisa.md — esqueleto obrigatório, legenda de confiança, regras de evidência e citação, ordem de valor das fontes, vieses a evitar e o portão de qualidade que o seu documento vai atravessar.
- {abs}/referencias/dossie.md, seção "{N}. {título do doc}" — propósito, perguntas que o documento responde, frameworks a usar, estrutura específica e a armadilha principal.

INSTRUÇÕES
Responda as perguntas da sua seção com pesquisa web, buscando no idioma do mercado-alvo e em inglês para analogias internacionais. Busque explicitamente o contrário da tese ({exemplos: "por que X não funciona", "reclamações de Y"}) e procure os mortos da categoria, não só os sobreviventes. Quando algo puder ser verificado empiricamente por pouco dinheiro e poucos minutos — chamar um endpoint, baixar um arquivo público, abrir a página de preço, processar uma amostra real — verifique em vez de estimar, e registre o resultado (inclusive o 403). Se três consultas bem formuladas não acharem um número, ele vira **[N]**, não uma estimativa.

CONTRATO DE SAÍDA
Escreva `{caminho}/{arquivo-em-kebab-case}.md` seguindo o esqueleto padrão de padroes-de-pesquisa.md, com a estrutura específica da sua seção em dossie.md. Devolva na resposta final, em no máximo 300 palavras: o caminho do arquivo; o resumo de uma frase para o índice, contendo a conclusão **com os números** (não o tema); os 3–5 achados que mudam alguma decisão; e a lista de **[N]** — o que foi procurado e não encontrado.

LIMITES
Não leia nem cite os outros documentos do dossiê{, exceto: X}. Não recomende, não opine, não proponha features, arquitetura, roadmap ou wireframes. Não escreva nem edite nenhum arquivo fora do seu. Reporte cobertura completa com rótulo de confiança por linha — filtrar é trabalho de quem sintetiza, não seu.

CRITÉRIOS DE SUCESSO
Todo número tem link de fonte e marca de confiança na própria linha; estimativas suas saem em itálico e rotuladas como estimativa desta pesquisa; existe seção "o que foi procurado e NÃO encontrado"; o documento termina em tabela achado → implicação; e você percorreu o portão de qualidade por documento de padroes-de-pesquisa.md item por item antes de responder.
</brief-modelo>

**Delta do doc 4 (panorama de preços):** o brief não carrega nenhum número, faixa, tese ou palpite de preço do projeto — só a categoria e o público. Acrescente ao contrato: *"Natureza: mapa neutro de preço × demanda × entrega; este documento NÃO recomenda preço"* no cabeçalho, e ao limite: *"qualquer frase do tipo 'o ideal seria posicionar em X' invalida o documento."* Se você já viu uma tese de preço nesta conversa, ela não entra no brief.

### 4. Portão por documento

Para cada retorno, confira o portão de qualidade de `referencias/padroes-de-pesquisa.md` com uma leitura dirigida do arquivo (fonte por número, seção [N], tabela achado → implicação, ausência de recomendação onde o doc é neutro). Quando faltar item, mande o próprio subagente corrigir via SendMessage — ele mantém o contexto da pesquisa. Só então adicione a linha no índice: **doc não indexado é rascunho e não pode ser citado como base de decisão.**

### 5. Sintetizar — checkpoint com o humano

A síntese é feita por você, que leu todos os retornos; nunca por um dos pesquisadores. Escreva `decisoes-em-aberto.md` (doc 11 de `referencias/dossie.md`) e atualize o **Estado da decisão** no topo do índice.

Onde dois documentos divergem, a divergência é achado: vira decisão em aberto com plano de teste, nunca é resolvida por argumento interno. Onde um documento superou parte de outro, anote a superação no índice e no cabeçalho do doc superado — não reescreva em silêncio e não delete (`referencias/indice-e-fechamento.md` §Caveats cruzados).

Apresente ao usuário cada decisão em aberto com as teses concorrentes enunciadas de forma justa, e peça a escolha entre **testar** (rodar o experimento especificado) e **decidir agora com o risco declarado**. Essa escolha é dele.

### 6. Fechar

Percorra o portão de completude do dossiê e os sinais de "pesquisa demais" em `referencias/indice-e-fechamento.md`. Entregue o desfecho — prosseguir, prosseguir diferente ou não prosseguir — sabendo que os três são sucesso da pesquisa; um dossiê que evita um projeto inviável pagou por si.

Feche com as duas listas que a próxima fase consome: as **premissas críticas ordenadas por letalidade** (importância × força de evidência) e os **itens que só um humano pode executar** — conversar com N usuários reais, falar com advogado, comprar e usar o produto do concorrente. Ofereça então o handoff: as premissas críticas são o insumo direto da skill `voltar-do-futuro` (premortem), que roda antes dos POCs e transforma cada falha prevista em critério de aceite.

## Regras invioláveis

- **Toda pesquisa nasce de uma pergunta de decisão.** Sem decisão pendente, o documento não deve existir.
- **Falta de dado é dado.** Um `[N]` explícito vale mais que uma estimativa disfarçada de fato — e quando ninguém publica um número, isso diz algo sobre o mercado.
- **Um documento cuja conclusão você já tem na cabeça é justificação, não pesquisa.** Contexto limpo por documento; o panorama de preços roda sem âncora.
- **Preferência revelada vence preferência declarada.** Preço pago, abandono, pirataria, lista de espera valem mais que qualquer survey de intenção.
- **Empirismo sempre que for barato.** Endpoint que existe se chama; arquivo público se baixa; custo se mede. Horas e centavos substituem uma coluna inteira de estimativas.
- **Decisão em aberto se resolve por teste empírico, com a métrica de decisão definida antes de rodar** ("receita líquida por visitante em 60 dias", não "conversão").
- **Nada de especificação de features, arquitetura, roadmap ou wireframe nesta fase.** Se aparecerem, a pesquisa virou projeto antes da hora.

# Testes que exigem terceiros: kit, substituto e fronteira epistêmica

Lido em D1, quando um teste depende de pessoas que não estão disponíveis agora — entrevista,
avaliação cega, teste de percepção, parecer profissional. Nenhuma skill recruta humanos: o
que ela faz é deixar o teste **pronto para disparar** e, se o humano decidir, rodar o
substituto declarado com os limites do que ele prova escritos.

---

## Regra de ouro

Persona simulada não é usuário. Advogado simulado não é parecer. A simulação é uma **ponte**
que corrige o instrumento antes de gastar o recurso escasso — a atenção de gente real. Ela é
legítima, e é desonesta apenas quando a fronteira do que prova fica implícita.

O caso real que justifica a ponte: 10 personas com perfil de conhecimento oculto revelaram
que **um acerto por chute em item verdadeiro/falso certificava domínio** — uma falha
aritmética do instrumento, igualmente válida para humanos. A correção derrubou o
falso-positivo de 34% para 12%. Nenhum humano precisou ser gasto para descobrir isso, e
gente real teria sido gasta num instrumento defeituoso.

---

## O kit — monte sempre, mesmo quando o substituto vai rodar

Grave em `docs/desarmar/kits/<slug>/`. É o que permite disparar o teste real no dia em que
as pessoas existirem, sem re-derivar nada.

| Peça | Conteúdo |
|---|---|
| `protocolo.md` | Quem recrutar (perfil, quantos, de onde, **fora do time**), roteiro minuto a minuto, o que o participante vê e não vê, ordem de apresentação e como ela é randomizada, tempo total, incentivo |
| `instrumento/` | O material que o participante encontra: questionário, telas, tarefas, o produto do concorrente lado a lado, o que for |
| `formulario.md` | Os itens de coleta, separados em **objetivos** (desempenho, tempo, taxa de detecção, escolha revelada) e **subjetivos** (n/10 concordam, escala, frase livre) |
| `criterio.md` | O aceite pré-registrado, copiado literal do plano, com a data de congelamento e a decisão pré-comprometida nos dois ramos |
| `analise.md` | Como os dados serão tabulados **antes** de existirem: qual tabela, qual corte, qual teste. Análise decidida depois dos dados escolhe o corte que confirma |

### Cegueira, onde ela importa

- Quem aplica não conhece a hipótese, ou aplica por roteiro fechado.
- Quem avalia a saída não sabe qual condição a produziu.
- Perguntas de desejabilidade medem **preferência revelada** sempre que possível: o que a
  pessoa escolheu, pagou, abandonou ou copiou vale mais que o que ela declarou que faria.
- Ordem randomizada entre participantes, para que a fadiga e a âncora não caiam sempre no
  mesmo item.

### Aceite de teste com humanos

Sempre conjunto, com um componente objetivo e um subjetivo, e com n pequeno declarado —
5 a 10 pessoas resolvem a maioria das perguntas de percepção. Modelo:
*"delta ≥ 20 p.p. entre as condições **e** ≥ 7/10 participantes reconhecem o resultado como
descrição justa do próprio desempenho"*.

---

## O substituto: simulação de personas

Três salvaguardas, todas obrigatórias:

1. **Perfil oculto do instrumento.** A persona recebe um perfil (o que sabe, o que não sabe,
   como se comporta sob incerteza) e responde **em caráter**; quem avalia não vê o perfil.
   Sem isso, a simulação mede o quanto o avaliador conhece o gabarito.
2. **Diversidade declarada de perfis.** Cubra os regimes que o produto vai encontrar —
   avançado, intermediário, iniciante, errático, adversarial —, com quantos de cada e por
   quê. Personas todas cooperativas produzem um instrumento que só funciona com gente boazinha.
3. **Fronteira epistêmica escrita no resultado**, no formato abaixo, dentro do próprio
   relatório do teste.

<fronteira-epistemica>
## O que esta simulação prova e o que não prova

**Prova** (propriedades aritméticas e estruturais do instrumento, válidas também para
humanos): {ex. o escore certifica domínio a partir de uma única resposta correta em item
binário; o gabarito desbalanceado alinha o chute ao acerto; a regra de corte deixa X% do
mapa indeterminado}.

**Não prova**: percepção subjetiva, aceitação, disposição a pagar, a estrutura real do
conhecimento ou do comportamento humano, e qualquer efeito de contexto social. Nada aqui
substitui {N} pessoas reais.

**Estado**: instrumento corrigido em {caminho}, pronto para disparar. Item reclassificado de
**bloqueio** para **validação pré-lançamento**, com dono {nome} e marco {quando}.
</fronteira-epistemica>

Rode as personas em **Opus** — julgamento em caráter com perfil oculto é exatamente o
trabalho que degrada em modelo menor.

## O substituto: segunda opinião adversarial em parecer profissional

Para dependência legal, regulatória, contábil ou clínica: escreva primeiro o **memorando de
perguntas objetivas** (numeradas, fechadas, cada uma com a decisão de produto que depende
dela). Depois rode uma persona especialista da área **em modo adversarial**, respondendo o
memorando como segunda opinião — e registre onde ela **diverge** do memorando, que é onde
está o valor. Num caso real, a divergência mudou o alvo do risco: o problema não era perder
no mérito, era a liminar — *"o processo se ganha, a empresa se perde"* — e a recomendação
resultante virou requisito de arquitetura (proveniência item a item + kill-switch por fonte,
impraticável de retrofitar depois).

O aceite deste tipo de teste nunca é "temos um parecer". É **risco classificado + mitigação
escrita + requisito de arquitetura nomeado**. E o resultado sai marcado como opinião
simulada, jamais como parecer.

---

## Como isso aparece no placar

- Substituto rodou, instrumento corrigido, fronteira escrita → **PENDENTE, COM SUBSTITUTO
  DECLARADO**, com o rebaixamento de bloqueio para validação pré-lançamento explícito.
- A simulação encontrou uma falha **estrutural ou aritmética** que invalida o desenho →
  **CONFIRMADA, COM ROTA DE SAÍDA QUANTIFICADA**. Falha aritmética vale para humanos também;
  não precisa de gente para ser verdadeira, e a alavanca medida decide o redesenho.
- Kit pronto e o humano decidiu recrutar → **EM CURSO**, com data de leitura.
- Kit pronto e nenhuma decisão tomada → continua **PENDENTE**, listado em "o que continua com
  o humano", com dono e marco. Pendência sem dono some.

Em todos os casos, o item permanece no placar. Um teste que depende de terceiros não
desaparece por ser inconveniente: ele muda de estado, com a data em que volta.

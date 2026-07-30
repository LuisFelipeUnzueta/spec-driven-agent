# Design Rationale: Checklists como "Unit Tests for English"

## Por que checklists existem

Checklists de requisitos são o equivalente a **testes de unidade para especificações**. Assim como testes de unidade validam se o código se comporta conforme o esperado, checklists de requisitos validam se a especificação tem qualidade suficiente para avançar para a próxima fase.

## O problema que resolvem

Sem checklists, especificações ambíguas, incompletas ou inconsistentes avançam silenciosamente para implementação. O custo de correção cresce exponencialmente: um erro na INTENT custa 1x, no SCOPE custa 5x, na task custa 20x, no código custa 100x.

## O que NÃO são

- **Não são revisão de código** — não olham para implementação.
- **Não são QA de produto** — não validam se a feature é desejável.
- **Não são aprovação de stakeholder** — não substituem validação de negócio.

## O ponto de corte

O limiar de 80% não é arbitrário. Ele reflete a observação empírica de que especificações com < 80% de itens atendidos produzem consistentemente 2x mais retrabalho durante implementação.

## Integração com o pipeline

Os checklists operam como **gates não-bloqueantes**: se o score for insuficiente, o usuário é alertado mas pode avançar. Com o tempo, times maduros elevam o threshold ou tornam o bloqueio obrigatório. Esta progressão respeita a maturidade de cada time.

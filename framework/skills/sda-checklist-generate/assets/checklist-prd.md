# Checklist de Qualidade — PRD

> Checklist é um **teste de unidade para requisitos**. Ele valida a qualidade do que está sendo pedido, não a implementação. Cada item "falho" é um bug na especificação.

> Use este checklist na skill `sda-checklist-generate` para avaliar a qualidade do PRD antes de gerar o Tech Spec. Pontuação: ✅ = 1 ponto, ⚠️ = 0.5 ponto, ❌ = 0 pontos.

---

## A. Completude (tudo que precisa estar lá está?)

- [ ] Problema de negócio está claramente definido em 1-2 frases
- [ ] Público-alvo / personas estão identificadas
- [ ] Critérios de aceite são mensuráveis (não "funciona bem" ou "rápido")
- [ ] Fluxo de exceção está descrito (não só happy path)
- [ ] Restrições conhecidas estão documentadas

## B. Clareza (dá para entender sem ambiguidade?)

- [ ] Cada termo de domínio tem definição única (sem ambiguidade)
- [ ] Não há jargão técnico não explicado
- [ ] Cenários são descritos como Given/When/Then ou equivalente
- [ ] Objetivo é específico o suficiente para alguém de fora entender

## C. Consistência (não se contradiz?)

- [ ] Premissas não contradizem restrições
- [ ] Critérios de aceite são consistentes entre si
- [ ] Escopo "incluído" e "excluído" não se sobrepõem
- [ ] Métricas de sucesso são compatíveis com os critérios de aceite

## D. Mensurabilidade (dá para testar?)

- [ ] Sucesso é definido em termos observáveis
- [ ] Métricas de sucesso têm valor-alvo (ex: "latência < 200ms", "taxa < 1%")
- [ ] É possível escrever um teste de aceitação para cada critério
- [ ] O resultado esperado é verificável sem acesso ao código

## E. Cobertura (o escopo está bem delimitado?)

- [ ] Fronteiras com features adjacentes estão claras
- [ ] O que NÃO está no escopo está explicitamente listado
- [ ] Não há "creep" (coisas não pedidas na descrição original)
- [ ] As versões futuras mencionadas são claramente identificadas como "v2+"

---

## Pontuação

Total de itens: 21. Mínimo para avançar: 17 (80%).

| Resultado | Pontuação | Ação |
|-----------|-----------|------|
| ✅ Aprovado | ≥ 17 pontos (80%) | Pronto para Tech Spec |
| ⚠️ Ressalvas | 13-16 pontos (60-79%) | Revisar itens críticos antes de avançar |
| ❌ Reprovado | < 13 pontos (< 60%) | Não gerar Tech Spec. Rodar clarificação primeiro |

## Instruções para a skill

Ao detectar um item ❌ ou ⚠️, PERGUNTE ao usuário se deseja corrigir antes de finalizar. Para cada item ❌, sugira uma correção concreta. Não bloqueie o avanço se o usuário optar por ignorar — registre a ressalva no relatório.

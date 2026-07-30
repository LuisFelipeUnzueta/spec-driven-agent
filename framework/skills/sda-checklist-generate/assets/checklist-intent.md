# Checklist de Qualidade — INTENT (miniSpec)

> Checklist é um **teste de unidade para requisitos**. Ele valida a qualidade do que está sendo pedido, não a implementação.

> Use este checklist na skill `sda-checklist-generate` para avaliar a qualidade da INTENT antes de gerar o SCOPE.

---

## A. Problema e Motivação

- [ ] Problema está descrito em termos de usuário/negócio, não de solução técnica
- [ ] Motivação inclui o custo de não fazer (urgência, impacto)
- [ ] Público afetado está claro

## B. Objetivo

- [ ] Objetivo é único e específico (não "melhorar o sistema")
- [ ] Resultado esperado é descrito em termos observáveis
- [ ] É possível saber quando a feature está completa

## C. Restrições

- [ ] Decisões já tomadas estão explicitadas
- [ ] Limites de escopo estão claros
- [ ] Restrições operacionais/regulatórias estão documentadas

## D. Pureza (zero COMO)

- [ ] Nenhuma tecnologia ou ferramenta é mencionada
- [ ] Nenhum endpoint, rota ou URL aparece
- [ ] Nenhum detalhe de arquitetura, banco ou implementação
- [ ] Foco exclusivo em O QUE e POR QUE

---

## Pontuação

Total de itens: 13. Mínimo para avançar: 11 (85%).

| Resultado | Pontuação | Ação |
|-----------|-----------|------|
| ✅ Aprovado | ≥ 11 pontos (85%) | Pronto para SCOPE |
| ⚠️ Ressalvas | 8-10 pontos (60-84%) | Revisar antes de gerar SCOPE |
| ❌ Reprovado | < 8 pontos (< 60%) | Revisar INTENT antes de prosseguir |

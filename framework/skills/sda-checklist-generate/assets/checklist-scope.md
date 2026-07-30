# Checklist de Qualidade — Scope (miniSpec)

> Checklist é um **teste de unidade para requisitos**. Ele valida a qualidade do escopo, não a implementação.

> Use este checklist na skill `sda-checklist-generate` para avaliar a qualidade do SCOPE antes de gerar as tasks.

---

## A. Alinhamento com INTENT

- [ ] O SCOPE cobre integralmente o objetivo da INTENT
- [ ] Não há itens no SCOPE que não estavam na INTENT (creep)
- [ ] O "fora do escopo" do SCOPE é consistente com os limites da INTENT

## B. Delimitação

- [ ] Seção "incluído" é específica e acionável
- [ ] Seção "excluído" é concreta (não "futuras melhorias" genérico)
- [ ] Fronteiras com features adjacentes estão claras
- [ ] Não há ambiguidade entre o que está dentro e fora

## C. Definições Técnicas

- [ ] Stack e versões estão definidas (ou referenciadas)
- [ ] Arquivos impactados estão listados
- [ ] Padrões arquiteturais estão consistentes com o projeto

## D. Completude

- [ ] Fluxo principal está descrito
- [ ] Fluxos de exceção estão descritos (mínimo: erro, vazio, timeout)
- [ ] Estados de UI/UX cobertos (loading, vazio, erro, sucesso)
- [ ] Variante (web/mobile/backend) está coerente com as definições

## E. Clareza

- [ ] Termos técnicos são consistentes com o glossário de domínio
- [ ] Decisões técnicas têm justificativa (mínimo 1 frase)
- [ ] Seções do template estão preenchidas (ou marcadas N/A)

---

## Pontuação

Total de itens: 16. Mínimo para avançar: 13 (81%).

| Resultado | Pontuação | Ação |
|-----------|-----------|------|
| ✅ Aprovado | ≥ 13 pontos (81%) | Pronto para Tasks |
| ⚠️ Ressalvas | 10-12 pontos (60-80%) | Revisar antes de gerar tasks |
| ❌ Reprovado | < 10 pontos (< 60%) | Revisar SCOPE antes de prosseguir |
